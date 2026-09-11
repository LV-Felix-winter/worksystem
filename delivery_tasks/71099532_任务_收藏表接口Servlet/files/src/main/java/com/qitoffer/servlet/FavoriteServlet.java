package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.FavoriteDao;
import com.qitoffer.dao.JobDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Favorite;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * 收藏表接口 (#71099532)：tb_favorite 增删查，按 applicant_id + job_id 唯一
 * 路径：/favorite/add /favorite/delete /favorite/list
 * 处理人：佟乐
 */
@WebServlet("/favorite/*")
public class FavoriteServlet extends HttpServlet {
    private final FavoriteDao favoriteDao = new FavoriteDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = applicant(req);
        if (applicant == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        List<Favorite> favorites;
        try {
            favorites = favoriteDao.listByApplicant(applicant.getApplicantId());
        } catch (Exception e) {
            favorites = java.util.Collections.emptyList();
        }
        req.setAttribute("favorites", favorites);
        req.setAttribute("navKey", "fav");
        req.setAttribute("pageTitle", "收藏职位 · 锐聘");
        req.getRequestDispatcher("/favorite/list.jsp").forward(req, resp);
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
        int jobId = parseInt(req.getParameter("jobId"));
        String path = req.getPathInfo() == null ? "" : req.getPathInfo();
        String back = "list".equals(req.getParameter("back"))
                ? req.getContextPath() + "/favorite/list"
                : req.getContextPath() + "/job/detail?id=" + jobId;
        if (jobId <= 0) {
            resp.sendRedirect(req.getContextPath() + "/job/search");
            return;
        }
        if ("/add".equals(path)) {
            // 收藏前校验职位存在且在招
            boolean ok = true;
            try {
                com.qitoffer.entity.Job job = new JobDao().findById(jobId, false);
                ok = job != null && job.getJobState() == Dict.JOB_ONLINE;
            } catch (Exception ignored) {
            }
            boolean backIsList = back.endsWith("/favorite/list");
            String sep = backIsList ? "?" : "&";
            if (ok) {
                try {
                    favoriteDao.add(applicant.getApplicantId(), jobId);
                    back += sep + "fav=1";
                } catch (Exception ignored) {
                    back += sep + "favErr=1";
                }
            } else {
                back += sep + "favErr=1";
            }
        } else if ("/delete".equals(path)) {
            boolean backIsList = back.endsWith("/favorite/list");
            String sep = backIsList ? "?" : "&";
            try {
                favoriteDao.remove(applicant.getApplicantId(), jobId);
                back += sep + "fav=0";
            } catch (Exception ignored) {
                back += sep + "favErr=1";
            }
        } else {
            resp.sendError(404);
            return;
        }
        resp.sendRedirect(back);
    }

    private static Applicant applicant(HttpServletRequest req) {
        jakarta.servlet.http.HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(Dict.SESSION_APPLICANT);
        return value instanceof Applicant ? (Applicant) value : null;
    }

    private static int parseInt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
