package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.ApplyDao;
import com.qitoffer.dao.ResumeDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Apply;
import com.qitoffer.entity.Resume;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;
import java.util.Map;

/**
 * 投递状态管理 Servlet
 * 任务：#71099538/#71099539
 * 处理人：佟乐
 */
@WebServlet("/apply/*")
public class ApplyServlet extends HttpServlet {
    private final ApplyDao applyDao = new ApplyDao();
    private final ResumeDao resumeDao = new ResumeDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        if (applicant == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String pathInfo = req.getPathInfo();

        if ("/stats".equals(pathInfo)) {
            // 获取投递状态统计
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                if (resume == null) { out.write("{\"pending\":0,\"reviewing\":0,\"accepted\":0,\"rejected\":0}"); return; }
                Map<String, Integer> stats = applyDao.countByStatus(applicant.getApplicantId());
                out.write(String.format("{\"pending\":%d,\"reviewing\":%d,\"accepted\":%d,\"rejected\":%d}",
                        stats.getOrDefault("pending", 0), stats.getOrDefault("reviewing", 0),
                        stats.getOrDefault("accepted", 0), stats.getOrDefault("rejected", 0)));
            } catch (Exception e) { out.write("{\"error\":\"SERVER_ERROR\"}"); }
        } else if ("/list".equals(pathInfo)) {
            // 获取投递列表（用于AJAX）
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                if (resume == null) { out.write("[]"); return; }
                List<Apply> applies = applyDao.findByApplicantId(applicant.getApplicantId(), resume.getResumeId());
                out.write(toJson(applies));
            } catch (Exception e) { out.write("[]"); }
        } else {
            // 默认：展示投递页面
            req.setAttribute("navKey", "apply");
            req.setAttribute("pageTitle", "我的投递 · 锐聘");
            req.getRequestDispatcher("/user/apply.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        if (applicant == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String pathInfo = req.getPathInfo();
        if ("/apply".equals(pathInfo)) {
            // 求职者投递职位
            resp.setContentType("application/json;charset=UTF-8");
            PrintWriter out = resp.getWriter();
            int jobId = parseInt(req, "jobId");
            if (jobId <= 0) { out.write("{\"error\":\"INVALID_JOB_ID\"}"); return; }
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                if (resume == null) { out.write("{\"error\":\"NO_RESUME\"}"); return; }
                boolean already = applyDao.exists(resume.getResumeId(), jobId);
                if (already) { out.write("{\"error\":\"ALREADY_APPLIED\"}"); return; }
                applyDao.apply(resume.getResumeId(), jobId);
                out.write("{\"success\":true}");
            } catch (Exception e) { out.write("{\"error\":\"SERVER_ERROR\"}"); }
        } else {
            resp.sendError(404);
        }
    }

    @Override
    protected void doPut(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // 更新投递状态 (#71099539)
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        int applyId = parseInt(req, "applyId");
        int newState = parseInt(req, "newState");
        if (applyId <= 0 || newState < 0) { out.write("{\"error\":\"INVALID_PARAMS\"}"); return; }
        try {
            applyDao.updateStatus(applyId, newState, 0);
            out.write("{\"success\":true}");
        } catch (Exception e) { out.write("{\"error\":\"SERVER_ERROR\"}"); }
    }

    private int parseInt(HttpServletRequest req, String param) {
        String v = req.getParameter(param);
        try { return Integer.parseInt(v); } catch (Exception e) { return 0; }
    }

    private String toJson(List<Apply> applies) {
        if (applies == null || applies.isEmpty()) return "[]";
        StringBuilder sb = new StringBuilder("[");
        for (int i = 0; i < applies.size(); i++) {
            if (i > 0) sb.append(",");
            Apply a = applies.get(i);
            sb.append("{")
              .append("\"applyId\":").append(a.getApplyId())
              .append(",\"jobName\":\"").append(escape(a.getJobName()))
              .append("\",\"companyName\":\"").append(escape(a.getCompanyName()))
              .append("\",\"jobSalary\":\"").append(escape(a.getJobSalary()))
              .append("\",\"jobArea\":\"").append(escape(a.getJobArea()))
              .append(",\"applyState\":").append(a.getApplyState())
              .append(",\"applyDate\":\"").append(a.getApplyDate() != null ? a.getApplyDate().toString() : "")
              .append("\"}");
        }
        sb.append("]");
        return sb.toString();
    }

    private String escape(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\").replace("\"", "\\\"");
    }
}
