package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.common.ResumeBlocks;
import com.qitoffer.common.ResumePdf;
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
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.Arrays;

/**
 * 简历模块（#71098791/#71098792 后台分页在 JSP 内走 ResumeDao；
 * #71099535/#71099536 完整度、附件上传、编辑保存）
 * 处理人：佟乐
 */
@WebServlet(urlPatterns = {
        "/resume", "/resume/",
        "/resume/edit", "/resume/update", "/resume/upload", "/resume/photo",
        "/resume/edu", "/resume/proj", "/resume/work", "/resume/skill", "/resume/honor", "/resume/eval",
        "/resume/completeness", "/resume/recalculate", "/resume/preview", "/resume/pdf"
})
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
        String path = action(req);
        if ("completeness".equals(path)) {
            resp.setContentType("application/json;charset=UTF-8");
            int score = 0;
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                score = resume == null ? 0 : resume.getCompleteness();
            } catch (Exception ignored) {
            }
            resp.getWriter().write("{\"completeness\":" + score + "}");
        } else if ("recalculate".equals(path)) {
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
            if ("pdf".equals(path)) {
                writePdf(req, resp, applicant);
                return;
            }
            // 简历编辑页（#71099535：字段维护后完整度变化）
            if ("edit".equals(path) || "preview".equals(path)) {
                try {
                    Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                    if (resume == null) {
                        int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
                        resume = resumeDao.findById(resumeId);
                    }
                    req.setAttribute("resume", resume);
                } catch (Exception ignored) {
                }
                req.setAttribute("navKey", "center");
                if ("preview".equals(path)) {
                    req.setAttribute("pageTitle", "简历预览 · 锐聘");
                    req.getRequestDispatcher("/resume/preview.jsp").forward(req, resp);
                    return;
                }
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
            req.setAttribute("navKey", "center");
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
        String path = action(req);
        if ("update".equals(path)) {
            // 保存字段后重算完整度（#71099536：缺字段完整度下降）
            int resumeId;
            try {
                resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
                resumeDao.updateFields(resumeId,
                        param(req, "realname"), param(req, "gender"), param(req, "birthday"),
                        param(req, "current_loc"), param(req, "resident_loc"),
                        param(req, "telephone"), param(req, "email"),
                        param(req, "job_intension"), param(req, "job_experience"));
                resumeDao.recalculateCompleteness(resumeId);
                putMsg(req, "简历已保存，完整度已重新计算。");
            } catch (Exception e) {
                putMsg(req, "保存失败，请稍后再试。");
            }
            resp.sendRedirect(req.getContextPath() + "/resume/");
        } else if ("edu".equals(path)) {
            handleEdu(req, resp, applicant);
        } else if ("proj".equals(path)) {
            handleProj(req, resp, applicant);
        } else if ("work".equals(path)) {
            handleWork(req, resp, applicant);
        } else if ("skill".equals(path)) {
            handleSkill(req, resp, applicant);
        } else if ("honor".equals(path)) {
            handleHonor(req, resp, applicant);
        } else if ("eval".equals(path)) {
            handleEval(req, resp, applicant);
        } else if ("upload".equals(path) || "photo".equals(path)) {
            handleUpload(req, resp, applicant, "photo".equals(path));
        } else {
            resp.sendError(404);
        }
    }

    private void handleEdu(HttpServletRequest req, HttpServletResponse resp, Applicant applicant) throws IOException {
        try {
            int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
            Resume resume = resumeDao.findById(resumeId);
            java.util.List<ResumeBlocks.Edu> list = ResumeBlocks.parseEdu(resume == null ? "" : resume.getEducation());
            int index = parseIndex(req.getParameter("index"));
            if ("delete".equals(param(req, "action"))) {
                list = ResumeBlocks.removeAt(list, index);
                putMsg(req, "已删除教育经历。");
            } else {
                ResumeBlocks.Edu item = new ResumeBlocks.Edu();
                item.school = param(req, "school");
                item.major = param(req, "major");
                item.degree = param(req, "degree");
                item.years = param(req, "years");
                item.gpa = param(req, "gpa");
                item.courses = param(req, "courses");
                if (item.school.isEmpty()) {
                    putMsg(req, "请填写学校名称。");
                    resp.sendRedirect(req.getContextPath() + "/resume/?open=edu#edu");
                    return;
                }
                list = ResumeBlocks.upsertEdu(list, index, item);
                putMsg(req, index >= 0 ? "教育经历已更新。" : "教育经历已添加。");
            }
            resumeDao.saveEducation(resumeId, ResumeBlocks.encodeEdu(list));
            resumeDao.recalculateCompleteness(resumeId);
        } catch (Exception e) {
            putMsg(req, "教育经历保存失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/resume/#edu");
    }

    private void handleProj(HttpServletRequest req, HttpServletResponse resp, Applicant applicant) throws IOException {
        try {
            int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
            Resume resume = resumeDao.findById(resumeId);
            java.util.List<ResumeBlocks.Proj> list = ResumeBlocks.parseProj(resume == null ? "" : resume.getProjectExp());
            int index = parseIndex(req.getParameter("index"));
            if ("delete".equals(param(req, "action"))) {
                list = ResumeBlocks.removeAt(list, index);
                putMsg(req, "已删除项目经验。");
            } else {
                ResumeBlocks.Proj item = new ResumeBlocks.Proj();
                item.name = param(req, "name");
                item.role = param(req, "role");
                item.period = param(req, "period");
                item.desc = param(req, "desc");
                if (item.name.isEmpty() && item.desc.isEmpty()) {
                    putMsg(req, "请填写项目名称或项目描述。");
                    resp.sendRedirect(req.getContextPath() + "/resume/?open=proj#proj");
                    return;
                }
                list = ResumeBlocks.upsertProj(list, index, item);
                putMsg(req, index >= 0 ? "项目经验已更新。" : "项目经验已添加。");
            }
            resumeDao.saveProjectExp(resumeId, ResumeBlocks.encodeProj(list));
            resumeDao.recalculateCompleteness(resumeId);
        } catch (Exception e) {
            putMsg(req, "项目经验保存失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/resume/#proj");
    }

    private void handleWork(HttpServletRequest req, HttpServletResponse resp, Applicant applicant) throws IOException {
        try {
            int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
            Resume resume = resumeDao.findById(resumeId);
            java.util.List<ResumeBlocks.Work> list = ResumeBlocks.parseWork(resume == null ? "" : resume.getWorkExp());
            int index = parseIndex(req.getParameter("index"));
            if ("delete".equals(param(req, "action"))) {
                list = ResumeBlocks.removeAt(list, index);
                putMsg(req, "已删除工作经历。");
            } else {
                ResumeBlocks.Work item = new ResumeBlocks.Work();
                item.company = param(req, "company");
                item.title = param(req, "title");
                item.period = param(req, "period");
                item.duties = ResumeBlocks.dutiesFromLines(req.getParameter("duties"));
                if (item.company.isEmpty() && item.title.isEmpty()) {
                    putMsg(req, "请填写公司或职位。");
                    resp.sendRedirect(req.getContextPath() + "/resume/?open=work#work");
                    return;
                }
                list = ResumeBlocks.upsertWork(list, index, item);
                putMsg(req, index >= 0 ? "工作经历已更新。" : "工作经历已添加。");
            }
            resumeDao.saveWorkExp(resumeId, ResumeBlocks.encodeWork(list));
            resumeDao.saveJobExperience(resumeId, ResumeBlocks.summarizeWork(list));
            resumeDao.recalculateCompleteness(resumeId);
        } catch (Exception e) {
            putMsg(req, "工作经历保存失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/resume/#work");
    }

    private void handleSkill(HttpServletRequest req, HttpServletResponse resp, Applicant applicant) throws IOException {
        try {
            int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
            ResumeBlocks.Skills skills = new ResumeBlocks.Skills();
            skills.language = param(req, "language");
            skills.computer = param(req, "computer");
            skills.team = param(req, "team");
            String[] names = req.getParameterValues("barName");
            String[] levels = req.getParameterValues("barLevel");
            if (names != null) {
                for (int i = 0; i < names.length; i++) {
                    ResumeBlocks.Bar bar = new ResumeBlocks.Bar();
                    bar.name = names[i] == null ? "" : names[i].trim();
                    bar.level = levels != null && i < levels.length && levels[i] != null ? levels[i].trim() : "";
                    if (!bar.name.isEmpty()) {
                        skills.bars.add(bar);
                    }
                }
            }
            resumeDao.saveSkills(resumeId, ResumeBlocks.encodeSkills(skills));
            resumeDao.recalculateCompleteness(resumeId);
            putMsg(req, "技能特长已保存。");
        } catch (Exception e) {
            putMsg(req, "技能特长保存失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/resume/#skill");
    }

    private void handleHonor(HttpServletRequest req, HttpServletResponse resp, Applicant applicant) throws IOException {
        try {
            int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
            Resume resume = resumeDao.findById(resumeId);
            java.util.List<String> list = ResumeBlocks.parseHonors(resume == null ? "" : resume.getHonors());
            int index = parseIndex(req.getParameter("index"));
            if ("delete".equals(param(req, "action"))) {
                list = ResumeBlocks.removeAt(list, index);
                putMsg(req, "已删除荣誉证书。");
            } else {
                String item = param(req, "honor");
                if (item.isEmpty()) {
                    putMsg(req, "请填写荣誉或证书内容。");
                    resp.sendRedirect(req.getContextPath() + "/resume/?open=honor#honor");
                    return;
                }
                list = ResumeBlocks.upsertHonor(list, index, item);
                putMsg(req, index >= 0 ? "荣誉证书已更新。" : "荣誉证书已添加。");
            }
            resumeDao.saveHonors(resumeId, ResumeBlocks.encodeHonors(list));
            resumeDao.recalculateCompleteness(resumeId);
        } catch (Exception e) {
            putMsg(req, "荣誉证书保存失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/resume/#honor");
    }

    private void handleEval(HttpServletRequest req, HttpServletResponse resp, Applicant applicant) throws IOException {
        try {
            int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
            resumeDao.saveSelfEval(resumeId, param(req, "self_eval"));
            resumeDao.recalculateCompleteness(resumeId);
            putMsg(req, "自我评价已保存。");
        } catch (Exception e) {
            putMsg(req, "自我评价保存失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/resume/#eval");
    }

    private static int parseIndex(String raw) {
        try {
            return Integer.parseInt(raw == null ? "" : raw.trim());
        } catch (NumberFormatException e) {
            return -1;
        }
    }

    /** 附件上传（#71099535：仅限常见文档/图片，10MB 内） */
    private void handleUpload(HttpServletRequest req, HttpServletResponse resp, Applicant applicant, boolean photo)
            throws ServletException, IOException {
        int resumeId;
        try {
            resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
        } catch (Exception e) {
            putMsg(req, "简历初始化失败。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        String partName = photo ? "photo" : "file";
        Part part = req.getPart(partName);
        if (part == null || part.getSize() == 0) {
            part = req.getPart("file");
        }
        String fileName = part == null ? "" : part.getSubmittedFileName();
        String extension = extensionOf(fileName);
        java.util.List<String> allowed = photo
                ? java.util.Arrays.asList("png", "jpg", "jpeg")
                : java.util.Arrays.asList(ALLOWED_EXTENSIONS.split(","));
        if (part == null || extension.isEmpty() || !allowed.contains(extension)) {
            putMsg(req, photo ? "照片仅限 JPG / PNG。" : "附件仅限 PDF / Word / 图片，且不超过 10MB。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        if (part.getSize() > MAX_UPLOAD_BYTES) {
            putMsg(req, "附件超过 10MB，请压缩后再传。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        String storedName = (photo ? "photo_" : "resume_") + resumeId + "_" + System.currentTimeMillis() + "." + extension;
        File dir = new File(req.getServletContext().getRealPath("/upload"));
        if (!dir.exists() && !dir.mkdirs()) {
            putMsg(req, "上传目录不可写。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        part.write(new File(dir, storedName).getAbsolutePath());
        try {
            if (photo) {
                resumeDao.saveHeadShot(resumeId, "/upload/" + storedName);
                putMsg(req, "照片已更新。");
            } else {
                resumeDao.saveAttachment(resumeId, "/upload/" + storedName);
                putMsg(req, "附件已上传：" + safeName(fileName));
            }
            resumeDao.recalculateCompleteness(resumeId);
        } catch (Exception e) {
            putMsg(req, "附件保存失败。");
        }
        resp.sendRedirect(req.getContextPath() + "/resume/");
    }

    private void writePdf(HttpServletRequest req, HttpServletResponse resp, Applicant applicant) throws IOException {
        Resume resume = null;
        try {
            resume = resumeDao.findByApplicantId(applicant.getApplicantId());
            if (resume == null) {
                int resumeId = resumeDao.ensureForApplicant(applicant.getApplicantId());
                resume = resumeDao.findById(resumeId);
            }
        } catch (Exception ignored) {
        }
        String photoFile = null;
        if (resume != null && resume.getHeadShot() != null && !resume.getHeadShot().isEmpty()) {
            String stored = resume.getHeadShot();
            if (stored.startsWith("/upload") || stored.startsWith("/images")) {
                photoFile = req.getServletContext().getRealPath(stored);
            }
        }
        boolean download = "1".equals(req.getParameter("dl"));
        String fileName = ResumePdf.fileName(resume, applicant);
        resp.setContentType("application/pdf");
        resp.setHeader("Content-Disposition",
                (download ? "attachment" : "inline")
                        + "; filename=\"" + URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20") + "\";"
                        + " filename*=UTF-8''" + URLEncoder.encode(fileName, StandardCharsets.UTF_8).replace("+", "%20"));
        try {
            ResumePdf.write(resume, applicant, photoFile, resp.getOutputStream());
        } catch (Exception e) {
            resp.reset();
            resp.setContentType("text/html;charset=UTF-8");
            resp.getWriter().write("<p>PDF 生成失败，请稍后重试。</p>");
        }
    }

    private static String action(HttpServletRequest req) {
        String path = req.getServletPath();
        int slash = path.lastIndexOf('/');
        return slash >= 0 ? path.substring(slash + 1) : path;
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
