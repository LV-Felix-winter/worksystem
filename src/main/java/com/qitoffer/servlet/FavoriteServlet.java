package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.FavoriteDao;
import com.qitoffer.entity.Applicant;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;

/**
 * 收藏职位 Servlet - CRUD接口
 * 任务：#71099531/#71099532/#71099533
 * 处理人：佟乐
 */
@WebServlet("/favorite/*")
public class FavoriteServlet extends HttpServlet {
    private final FavoriteDao favoriteDao = new FavoriteDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        String pathInfo = req.getPathInfo();

        if ("/check".equals(pathInfo)) {
            // GET /favorite/check?jobId=1
            int jobId = parseInt(req, "jobId");
            Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
            if (applicant == null) { out.write("{\"error\":\"NOT_LOGIN\"}"); return; }
            try {
                boolean exists = favoriteDao.exists(applicant.getApplicantId(), jobId);
                out.write("{\"favorited\":" + exists + "}");
            } catch (Exception e) { out.write("{\"error\":\"SERVER_ERROR\"}"); }
        } else if ("/list".equals(pathInfo)) {
            // GET /favorite/list
            Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
            if (applicant == null) { resp.sendRedirect(req.getContextPath() + "/login"); return; }
            try {
                out.write("{\"count\":" + favoriteDao.countByApplicantId(applicant.getApplicantId()) + "}");
            } catch (Exception e) { out.write("{\"error\":\"SERVER_ERROR\"}"); }
        } else {
            resp.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        if (applicant == null) { out.write("{\"error\":\"NOT_LOGIN\"}"); return; }
        int jobId = parseInt(req, "jobId");
        if (jobId <= 0) { out.write("{\"error\":\"INVALID_JOB_ID\"}"); return; }
        try {
            favoriteDao.add(applicant.getApplicantId(), jobId);
            out.write("{\"success\":true}");
        } catch (Exception e) { out.write("{\"error\":\"SERVER_ERROR\"}"); }
    }

    @Override
    protected void doDelete(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        if (applicant == null) { out.write("{\"error\":\"NOT_LOGIN\"}"); return; }
        int jobId = parseInt(req, "jobId");
        if (jobId <= 0) { out.write("{\"error\":\"INVALID_JOB_ID\"}"); return; }
        try {
            favoriteDao.remove(applicant.getApplicantId(), jobId);
            out.write("{\"success\":true}");
        } catch (Exception e) { out.write("{\"error\":\"SERVER_ERROR\"}"); }
    }

    private int parseInt(HttpServletRequest req, String param) {
        String v = req.getParameter(param);
        try { return Integer.parseInt(v); } catch (Exception e) { return 0; }
    }
}
