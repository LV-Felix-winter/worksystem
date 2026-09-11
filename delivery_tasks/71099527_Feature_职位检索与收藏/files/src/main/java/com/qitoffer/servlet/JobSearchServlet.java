package com.qitoffer.servlet;

import com.qitoffer.dao.JobDao;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * 职位检索 (#71099528)：关键词/地区/薪资 + LIMIT 分页 + 热门（job_viewnum）排序
 * 处理人：佟乐 | 任务：#71099528/#71099529
 */
@WebServlet("/job/search")
public class JobSearchServlet extends HttpServlet {
    private static final int PAGE_SIZE = 6;

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String keyword = param(req, "keyword");
        String area = param(req, "area");
        int salaryMin = paramInt(req, "salaryMin");
        int salaryMax = paramInt(req, "salaryMax");
        boolean popular = "hot".equals(req.getParameter("sort"));
        int page = Math.max(1, paramInt(req, "page"));

        JobDao dao = new JobDao();
        int total = 0;
        try {
            total = dao.count(keyword, area, salaryMin, salaryMax, false, null);
        } catch (Exception e) {
            resp.sendRedirect(req.getContextPath() + "/job/search?err=db");
            return;
        }
        int totalPages = Math.max(1, (total + PAGE_SIZE - 1) / PAGE_SIZE);
        if (page > totalPages) {
            page = totalPages;
        }

        req.setAttribute("jobs", safeSearch(dao, keyword, area, salaryMin, salaryMax, popular, page));
        req.setAttribute("total", total);
        req.setAttribute("page", page);
        req.setAttribute("pageCount", totalPages);
        req.setAttribute("pageSize", PAGE_SIZE);
        req.setAttribute("keyword", keyword);
        req.setAttribute("area", area);
        req.setAttribute("salaryMin", salaryMin);
        req.setAttribute("salaryMax", salaryMax);
        req.setAttribute("popular", popular);
        req.setAttribute("navKey", "jobs");
        req.setAttribute("pageTitle", "职位检索 · 锐聘");
        req.getRequestDispatcher("/job/search.jsp").forward(req, resp);
    }

    private java.util.List<com.qitoffer.entity.Job> safeSearch(JobDao dao, String keyword, String area,
                                                                int salaryMin, int salaryMax, boolean popular, int page) {
        try {
            return dao.search(keyword, area, salaryMin, salaryMax, popular, page, PAGE_SIZE, false, null);
        } catch (Exception e) {
            return java.util.Collections.emptyList();
        }
    }

    private static String param(HttpServletRequest req, String name) {
        String value = req.getParameter(name);
        return value == null ? "" : value.trim();
    }

    private static int paramInt(HttpServletRequest req, String name) {
        String value = param(req, name);
        if (value.isEmpty()) {
            return 0;
        }
        try {
            return Math.max(0, Integer.parseInt(value));
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
