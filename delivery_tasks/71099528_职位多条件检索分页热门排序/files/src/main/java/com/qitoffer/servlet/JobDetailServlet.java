package com.qitoffer.servlet;

import com.qitoffer.dao.JobDao;
import com.qitoffer.entity.Job;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * 职位详情（只读预览 + 浏览量 +1），热门排序数据源即 job_viewnum
 * 处理人：佟乐 | 任务：#71099528（浏览量口径）/#71099538（投递入口）
 */
@WebServlet("/job/detail")
public class JobDetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        int jobId = 0;
        try {
            jobId = Integer.parseInt(req.getParameter("id") == null ? "" : req.getParameter("id"));
        } catch (NumberFormatException ignored) {
        }
        Job job = null;
        try {
            job = new JobDao().findById(jobId, true);
        } catch (Exception ignored) {
        }
        req.setAttribute("job", job);
        req.setAttribute("navKey", "jobs");
        req.setAttribute("pageTitle", "职位详情 · 锐聘");
        req.getRequestDispatcher("/job/detail.jsp").forward(req, resp);
    }
}
