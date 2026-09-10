package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.JobDao;
import com.qitoffer.dao.FavoriteDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Job;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

/**
 * 职位列表 Servlet - 多条件筛选 + 分页展示
 * 任务：#71098793/#71098794/#71099527/#71099528/#71099529
 * 处理人：佟乐
 */
@WebServlet("/job/list")
public class JobListServlet extends HttpServlet {
    private final JobDao jobDao = new JobDao();
    private final FavoriteDao favoriteDao = new FavoriteDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 获取筛选条件
        String keyword = req.getParameter("keyword");
        String area = req.getParameter("area");
        String salary = req.getParameter("salary");
        String pageStr = req.getParameter("page");

        int page = 1;
        try { page = Math.max(1, Integer.parseInt(pageStr)); } catch (NumberFormatException ignored) {}
        int pageSize = 10;

        try {
            // 多条件筛选 (#71099529)
            List<Job> jobs = jobDao.findByConditions(keyword, area, salary, Dict.JOB_ONLINE, page, pageSize);
            int totalCount = jobDao.countByConditions(keyword, area, salary, Dict.JOB_ONLINE);
            int totalPages = (int) Math.ceil((double) totalCount / pageSize);

            // 获取筛选选项
            List<String> areas = jobDao.findDistinctAreas();
            List<String> salaries = jobDao.findDistinctSalaries();

            req.setAttribute("jobs", jobs);
            req.setAttribute("totalCount", totalCount);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", keyword != null ? keyword : "");
            req.setAttribute("area", area != null ? area : "");
            req.setAttribute("salary", salary != null ? salary : "");
            req.setAttribute("areas", areas);
            req.setAttribute("salaries", salaries);
            req.setAttribute("navKey", "jobs");
            req.setAttribute("pageTitle", "职位检索 · 锐聘");
        } catch (Exception e) {
            req.setAttribute("error", "加载职位失败：" + e.getMessage());
            req.setAttribute("jobs", java.util.Collections.emptyList());
        }

        req.getRequestDispatcher("/job/list.jsp").forward(req, resp);
    }
}
