package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.ResumeDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Resume;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * 简历完整性 Servlet
 * 任务：#71098791/#71098792/#71099535/#71099536
 * 处理人：佟乐
 */
@WebServlet("/resume/*")
public class ResumeServlet extends HttpServlet {
    private final ResumeDao resumeDao = new ResumeDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        if (applicant == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String pathInfo = req.getPathInfo();

        if ("/completeness".equals(pathInfo)) {
            // 获取简历完整度 JSON
            resp.setContentType("application/json;charset=UTF-8");
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                int score = resume != null ? resume.getCompleteness() : 0;
                resp.getWriter().write("{\"completeness\":" + score + "}");
            } catch (Exception e) {
                resp.getWriter().write("{\"completeness\":0}");
            }
        } else if ("/recalculate".equals(pathInfo)) {
            // 重新计算完整度
            resp.setContentType("application/json;charset=UTF-8");
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
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
            // 默认：简历详情
            req.setAttribute("navKey", "resume");
            req.setAttribute("pageTitle", "我的简历 · 锐聘");
            req.getRequestDispatcher("/resume/detail.jsp").forward(req, resp);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        if (applicant == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }

        String pathInfo = req.getPathInfo();
        if ("/update".equals(pathInfo)) {
            // 更新简历模块 → 重新计算完整度
            String realname = req.getParameter("realname");
            String telephone = req.getParameter("telephone");
            String email = req.getParameter("email");
            String jobExperience = req.getParameter("job_experience");

            // 这里简化处理，实际应调用 ResumeDao.update()
            // 重新计算完整度
            try {
                Resume resume = resumeDao.findByApplicantId(applicant.getApplicantId());
                if (resume != null) {
                    resumeDao.recalculateCompleteness(resume.getResumeId());
                }
            } catch (Exception e) { /* ignore */ }

            resp.sendRedirect(req.getContextPath() + "/resume/");
        } else {
            resp.sendError(404);
        }
    }
}
