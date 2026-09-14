package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.CompanyDao;
import com.qitoffer.dao.JobDao;
import com.qitoffer.entity.Company;
import com.qitoffer.entity.Job;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;

@WebServlet("/company/job")
@MultipartConfig(maxFileSize = 5L * 1024 * 1024, maxRequestSize = 12L * 1024 * 1024)
public class CompanyJobServlet extends HttpServlet {
    private final JobDao jobDao = new JobDao();
    private final CompanyDao companyDao = new CompanyDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Company company = companyOf(req, resp);
        if (company == null) {
            return;
        }
        String action = AuthSupport.trim(req.getParameter("action"));
        if ("add".equals(action) || "edit".equals(action)) {
            Job job = new Job();
            job.setCompanyId(company.getCompanyId());
            job.setJobHiringnum(1);
            job.setJobState(Dict.JOB_ONLINE);
            if ("edit".equals(action)) {
                int jobId = parseInt(req.getParameter("id"));
                try {
                    Job found = jobDao.findById(jobId, false);
                    if (found == null || found.getCompanyId() != company.getCompanyId()) {
                        req.getSession().setAttribute("jobMsg", "职位不存在或不属于本企业。");
                        resp.sendRedirect(req.getContextPath() + "/company/job.jsp");
                        return;
                    }
                    job = found;
                } catch (Exception e) {
                    req.getSession().setAttribute("jobMsg", "职位加载失败。");
                    resp.sendRedirect(req.getContextPath() + "/company/job.jsp");
                    return;
                }
            }
            req.setAttribute("company", company);
            req.setAttribute("job", job);
            req.setAttribute("navKey", "jobs");
            req.setAttribute("pageTitle", ("add".equals(action) ? "发布职位" : "修改职位") + " · 锐聘");
            req.getRequestDispatcher("/company/job-edit.jsp").forward(req, resp);
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/company/job.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Company company = companyOf(req, resp);
        if (company == null) {
            return;
        }
        String action = AuthSupport.trim(req.getParameter("action"));
        if ("delete".equals(action)) {
            int jobId = parseInt(req.getParameter("id"));
            try {
                boolean ok = jobDao.deleteOwned(jobId, company.getCompanyId());
                req.getSession().setAttribute("jobMsg", ok ? "职位已删除。" : "删除失败：职位不存在或已有投递记录，请先下架。");
            } catch (Exception e) {
                req.getSession().setAttribute("jobMsg", "删除失败，请稍后再试。");
            }
            resp.sendRedirect(req.getContextPath() + "/company/job.jsp");
            return;
        }
        Job job = new Job();
        job.setJobId(parseInt(req.getParameter("jobId")));
        job.setCompanyId(company.getCompanyId());
        job.setJobName(AuthSupport.trim(req.getParameter("jobName")));
        job.setJobHiringnum(Math.max(1, parseInt(req.getParameter("jobHiringnum"))));
        job.setJobSalary(AuthSupport.trim(req.getParameter("jobSalary")));
        job.setJobArea(AuthSupport.trim(req.getParameter("jobArea")));
        job.setJobDesc(AuthSupport.trim(req.getParameter("jobDesc")));
        job.setJobEndtime(AuthSupport.trim(req.getParameter("jobEndtime")));
        job.setJobState("0".equals(req.getParameter("jobState")) ? Dict.JOB_OFFLINE : Dict.JOB_ONLINE);
        Job existing = null;
        if (job.getJobId() > 0) {
            try {
                existing = jobDao.findById(job.getJobId(), false);
            } catch (Exception ignored) {
            }
            if (existing == null || existing.getCompanyId() != company.getCompanyId()) {
                req.getSession().setAttribute("jobMsg", "职位不存在或不属于本企业。");
                resp.sendRedirect(req.getContextPath() + "/company/job.jsp");
                return;
            }
        }
        String cover = storeImage(req, "jobCover", "cover", company.getCompanyId());
        String thumb = storeImage(req, "jobThumb", "thumb", company.getCompanyId());
        if (cover == null && existing != null) {
            cover = existing.getJobCover();
        }
        if (thumb == null && existing != null) {
            thumb = existing.getJobThumb();
        }
        job.setJobCover(cover);
        job.setJobThumb(thumb);
        if (job.getJobName().isEmpty()) {
            req.getSession().setAttribute("jobMsg", "职位名称不能为空。");
            resp.sendRedirect(req.getContextPath() + "/company/job?action=" + (job.getJobId() > 0 ? "edit&id=" + job.getJobId() : "add"));
            return;
        }
        if (job.getJobId() <= 0 && (isBlank(cover) || isBlank(thumb))) {
            req.getSession().setAttribute("jobMsg", "发布职位需同时上传大图和缩略图。");
            resp.sendRedirect(req.getContextPath() + "/company/job?action=add");
            return;
        }
        try {
            if (job.getJobId() > 0) {
                boolean ok = jobDao.updateOwned(job);
                req.getSession().setAttribute("jobMsg", ok ? "职位已更新。" : "更新失败：职位不属于本企业。");
            } else {
                jobDao.insert(job);
                req.getSession().setAttribute("jobMsg", "职位已发布。");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("jobMsg", "保存失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/company/job.jsp");
    }

    private String storeImage(HttpServletRequest req, String field, String kind, int companyId)
            throws IOException, ServletException {
        Part part;
        try {
            part = req.getPart(field);
        } catch (IllegalStateException | ServletException e) {
            return null;
        }
        if (part == null || part.getSize() <= 0) {
            return null;
        }
        String fileName = part.getSubmittedFileName();
        String ext = extensionOf(fileName);
        if (!("png".equals(ext) || "jpg".equals(ext) || "jpeg".equals(ext) || "webp".equals(ext) || "svg".equals(ext))) {
            req.getSession().setAttribute("jobMsg", "职位图片仅限 JPG / PNG / WebP / SVG。");
            return null;
        }
        File dir = new File(req.getServletContext().getRealPath("/upload"));
        if (!dir.exists() && !dir.mkdirs()) {
            return null;
        }
        String stored = "job_" + kind + "_" + companyId + "_" + System.currentTimeMillis() + "." + ext;
        part.write(new File(dir, stored).getAbsolutePath());
        return "/upload/" + stored;
    }

    private static String extensionOf(String fileName) {
        if (fileName == null) {
            return "";
        }
        int dot = fileName.lastIndexOf('.');
        return dot < 0 ? "" : fileName.substring(dot + 1).toLowerCase();
    }

    private static boolean isBlank(String value) {
        return value == null || value.trim().isEmpty();
    }

    private Company companyOf(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User backend = AuthSupport.backendUser(req);
        if (backend == null) {
            AuthSupport.redirectLogin(req, resp, "company", "pwd", "auth");
            return null;
        }
        if (backend.getUserRole() == Dict.ROLE_ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/manage/job.jsp");
            return null;
        }
        try {
            Company company = companyDao.findByUserId(backend.getUserId());
            if (company == null) {
                req.getSession().setAttribute("jobMsg", "当前账号尚未关联企业。");
                resp.sendRedirect(req.getContextPath() + "/company/profile.jsp");
                return null;
            }
            return company;
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/company/dashboard");
            return null;
        }
    }

    private static int parseInt(String value) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return 0;
        }
    }
}
