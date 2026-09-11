package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.ResumeDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Resume;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.util.Arrays;

/**
 * 简历模块（#71098791/#71098792 后台分页在 JSP 内走 ResumeDao；
 * #71099535/#71099536 完整度、附件上传、编辑保存）
 * 处理人：佟乐
 */
@WebServlet("/resume/*")
@MultipartConfig(maxFileSize = 10L * 1024 * 1024, maxRequestSize = 15L * 1024 * 1024)
public class ResumeServlet extends HttpServlet {
    private static final long MAX_UPLOAD_BYTES = 10L * 1024 * 1024;
    private static final String ALLOWED_EXTENSIONS = "pdf,doc,docx,png,jpg,jpeg";
    private final ResumeDao resumeDao = new ResumeDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = applicant(req);
        if (applicant == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String path = req.getPathInfo() == null ? "" : req.getPathInfo();
        if ("/completeness".equals(path)) {
            resp.setContentType("application/json;charset=UTF-8");
            int score = 0;
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                score = resume == null ? 0 : resume.getCompleteness();
            } catch (Exception ignored) {
            }
            resp.getWriter().write("{\"completeness\":" + score + "}");
        } else if ("/recalculate".equals(path)) {
            resp.setContentType("application/json;charset=UTF-8");
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                if (resume == null) {
                    int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
                    resume = resumeDao.findById(resumeId);
                }
                if (resume != null) {
                    resumeDao.recalculateCompleteness(resume.getResumeId());
                    resp.getWriter().write("{\"success\":true}");
                } else {
                    resp.getWriter().write("{\"error\":\"NO_RESUME\"}");
                }
            } catch (Exception e) {
                resp.getWriter().write("{\"error\":\"SERVER_ERROR\"}");
            }
        } else {
            // 简历编辑页（#71099535：字段维护后完整度变化）
            if ("/edit.jsp".equals(path)) {
                try {
                    Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                    if (resume == null) {
                        int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
                        resume = resumeDao.findById(resumeId);
                    }
                    req.setAttribute("resume", resume);
                } catch (Exception ignored) {
                }
                req.setAttribute("navKey", "resume");
                req.setAttribute("pageTitle", "编辑简历 · 锐聘");
                req.getRequestDispatcher("/resume/edit.jsp").forward(req, resp);
                return;
            }
            // 只读预览页（#71099535 验收项）
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                if (resume == null) {
                    int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
                    resume = resumeDao.findById(resumeId);
                }
                req.setAttribute("resume", resume);
            } catch (Exception ignored) {
            }
            req.setAttribute("navKey", "resume");
            req.setAttribute("pageTitle", "我的简历 · 锐聘");
            req.getRequestDispatcher("/resume/detail.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = applicant(req);
        if (applicant == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        String path = req.getPathInfo() == null ? "" : req.getPathInfo();
        if ("/update".equals(path)) {
            // 保存字段后重算完整度（#71099536：缺字段完整度下降）
            int resumeId;
            try {
                resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
                resumeDao.updateFields(resumeId,
                        param(req, "realname"), param(req, "gender"),
                        param(req, "current_loc"), param(req, "resident_loc"),
                        param(req, "telephone"), param(req, "email"),
                        param(req, "job_intension"), param(req, "job_experience"));
                resumeDao.recalculateCompleteness(resumeId);
                putMsg(req, "简历已保存，完整度已重新计算。");
            } catch (Exception e) {
                putMsg(req, "保存失败，请稍后再试。");
            }
            resp.sendRedirect(req.getContextPath() + "/resume/");
        } else if ("/upload".equals(path)) {
            handleUpload(req, resp, applicant);
        } else {
            resp.sendError(404);
        }
    }

    /** 附件上传（#71099535：仅限常见文档/图片，10MB 内） */
    private void handleUpload(HttpServletRequest req, HttpServletResponse resp, Applicant applicant)
            throws ServletException, IOException {
        int resumeId;
        try {
            resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
        } catch (Exception e) {
            putMsg(req, "简历初始化失败。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        Part part = req.getPart("file");
        String fileName = part == null ? "" : part.getSubmittedFileName();
        String extension = extensionOf(fileName);
        if (part == null || extension.isEmpty() || !Arrays.asList(ALLOWED_EXTENSIONS.split(",")).contains(extension)) {
            putMsg(req, "附件仅限 PDF / Word / 图片，且不超过 10MB。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        if (part.getSize() > MAX_UPLOAD_BYTES) {
            putMsg(req, "附件超过 10MB，请压缩后再传。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        String storedName = "resume_" + resumeId + "_" + System.currentTimeMillis() + "." + extension;
        File dir = new File(req.getServletContext().getRealPath("/upload"));
        if (!dir.exists() && !dir.mkdirs()) {
            putMsg(req, "上传目录不可写。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        part.write(new File(dir, storedName).getAbsolutePath());
        try {
            resumeDao.saveAttachment(resumeId, "/upload/" + storedName);
            resumeDao.recalculateCompleteness(resumeId);
            putMsg(req, "附件已上传：" + safeName(fileName));
        } catch (Exception e) {
            putMsg(req, "附件保存失败。");
        }
        resp.sendRedirect(req.getContextPath() + "/resume/");
    }

    private static String param(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }

    private static String extensionOf(String fileName) {
        if (fileName == null) {
            return "";
        }
        int dot = fileName.lastIndexOf('.');
        return dot < 0 ? "" : fileName.substring(dot + 1).toLowerCase();
    }

    private static String safeName(String fileName) {
        String name = fileName == null ? "" : new File(fileName).getName();
        return name.length() > 24 ? name.substring(0, 24) + "…" : name;
    }

    private static void putMsg(HttpServletRequest req, String text) {
        HttpSession session = req.getSession();
        session.setAttribute("resumeMsg", text);
    }

    private static Applicant applicant(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(Dict.SESSION_APPLICANT);
        return value instanceof Applicant ? (Applicant) value : null;
    }

}
