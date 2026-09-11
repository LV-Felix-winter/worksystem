package com.qitoffer.servlet;

import com.qitoffer.dao.DashboardDAO;
import com.qitoffer.entity.ApplyRow;
import com.qitoffer.entity.DashboardStats;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/company/dashboard")
public class DashboardServlet extends HttpServlet {

    private final DashboardDAO dao = new DashboardDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        // 测试阶段：硬编码 companyId=1
        int companyId = 1;

        String stateStr = req.getParameter("applyState");
        Integer applyState = null;
        if (stateStr != null && !stateStr.isEmpty()) {
            applyState = Integer.parseInt(stateStr);
        }

        try {
            DashboardStats stats = dao.loadStats(companyId);
            List<ApplyRow> applies = dao.listApplies(companyId, applyState);

            req.setAttribute("stats", stats);
            req.setAttribute("applies", applies);
            req.setAttribute("applyState", applyState);

            req.getRequestDispatcher("/company/dashboard.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Dashboard 查询失败", e);
        }
    }
}