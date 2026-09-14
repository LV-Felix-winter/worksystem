package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.ApplyDao;
import com.qitoffer.dao.CompanyDao;
import com.qitoffer.dao.DashboardDAO;
import com.qitoffer.entity.Apply;
import com.qitoffer.entity.Company;
import com.qitoffer.entity.DashboardStats;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

@WebServlet("/company/dashboard")
public class DashboardServlet extends HttpServlet {

    private final DashboardDAO dao = new DashboardDAO();
    private final ApplyDao applyDao = new ApplyDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        User backend = AuthSupport.backendUser(req);
        if (backend == null) {
            AuthSupport.redirectLogin(req, resp, "company", "pwd", "auth");
            return;
        }
        if (backend.getUserRole() == Dict.ROLE_ADMIN) {
            resp.sendRedirect(req.getContextPath() + "/manage/");
            return;
        }
        Company company = null;
        try {
            company = new CompanyDao().findByUserId(backend.getUserId());
        } catch (Exception ignored) {
        }
        int companyId = company == null ? 0 : company.getCompanyId();
        Integer applyState = parseState(req.getParameter("applyState"));
        DashboardStats stats = new DashboardStats();
        List<Apply> applies = Collections.emptyList();
        if (companyId > 0) {
            try {
                stats = dao.loadStats(companyId);
                applies = applyDao.listByCompany(companyId);
            } catch (Exception e) {
                throw new ServletException("工作台查询失败", e);
            }
        }
        req.setAttribute("company", company);
        req.setAttribute("stats", stats);
        req.setAttribute("applies", applies);
        req.setAttribute("applyState", applyState);
        req.setAttribute("navKey", "workbench");
        req.setAttribute("pageTitle", "企业工作台 · 锐聘");
        req.getRequestDispatcher("/company/dashboard.jsp").forward(req, resp);
    }

    private static Integer parseState(String value) {
        if (value == null || value.isEmpty()) {
            return null;
        }
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return null;
        }
    }
}
