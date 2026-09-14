package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.CompanyDao;
import com.qitoffer.dao.JobDao;
import com.qitoffer.entity.Company;
import com.qitoffer.entity.Job;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

/** 前台企业详情（公开页，不走 /company 后台过滤） */
@WebServlet("/firm")
public class FirmServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        int companyId = 0;
        try {
            companyId = Integer.parseInt(req.getParameter("id") == null ? "" : req.getParameter("id"));
        } catch (NumberFormatException ignored) {
        }
        Company company = null;
        List<Job> jobs = new ArrayList<>();
        try {
            company = new CompanyDao().findById(companyId);
            if (company != null) {
                new CompanyDao().addViewnum(companyId);
                company.setCompanyViewnum(company.getCompanyViewnum() + 1);
                for (Job job : new JobDao().listByCompany(companyId)) {
                    if (job.getJobState() == Dict.JOB_ONLINE) {
                        jobs.add(job);
                    }
                }
            }
        } catch (Exception ignored) {
        }
        req.setAttribute("company", company);
        req.setAttribute("jobs", jobs);
        req.setAttribute("navKey", "jobs");
        req.setAttribute("pageTitle", company == null ? "企业详情 · 锐聘" : company.getCompanyName() + " · 锐聘");
        req.getRequestDispatcher("/firm/detail.jsp").forward(req, resp);
    }
}
