package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.CompanyDao;
import com.qitoffer.entity.Company;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;

@WebServlet("/company/profile")
@MultipartConfig(maxFileSize = 5 * 1024 * 1024, maxRequestSize = 6 * 1024 * 1024)
public class CompanyProfileServlet extends HttpServlet {
    private final CompanyDao companyDao = new CompanyDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.sendRedirect(req.getContextPath() + "/company/profile.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException, ServletException {
        req.setCharacterEncoding("UTF-8");
        User backend = AuthSupport.backendUser(req);
        if (backend == null || backend.getUserRole() == Dict.ROLE_ADMIN) {
            AuthSupport.redirectLogin(req, resp, "company", "pwd", "auth");
            return;
        }
        try {
            Company company = companyDao.findByUserId(backend.getUserId());
            if (company == null) {
                req.getSession().setAttribute("profileMsg", "当前账号尚未关联企业。");
                resp.sendRedirect(req.getContextPath() + "/company/profile.jsp");
                return;
            }
            company.setCompanyArea(AuthSupport.trim(req.getParameter("companyArea")));
            company.setCompanySize(AuthSupport.trim(req.getParameter("companySize")));
            company.setCompanyType(AuthSupport.trim(req.getParameter("companyType")));
            company.setCompanyBrief(AuthSupport.trim(req.getParameter("companyBrief")));
            String uploaded = storeImage(req, "companyPic", company.getCompanyId());
            if (uploaded != null) {
                company.setCompanyPic(uploaded);
            }
            boolean ok = companyDao.updateOwned(company);
            req.getSession().setAttribute("profileMsg", ok ? "企业资料已保存。" : "保存失败。");
        } catch (Exception e) {
            req.getSession().setAttribute("profileMsg", "保存失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/company/profile.jsp");
    }

    private String storeImage(HttpServletRequest req, String field, int companyId)
            throws IOException, ServletException {
        Part part;
        try {
            part = req.getPart(field);
        } catch (IllegalStateException | ServletException e) {
            return null;
        }
        if (part == null || part.getSize() <= 0) {
            return null;
        }
        String fileName = part.getSubmittedFileName();
        String ext = extensionOf(fileName);
        if (!("png".equals(ext) || "jpg".equals(ext) || "jpeg".equals(ext) || "webp".equals(ext))) {
            req.getSession().setAttribute("profileMsg", "宣传图片仅限 JPG / PNG / WebP。");
            return null;
        }
        File dir = new File(req.getServletContext().getRealPath("/upload"));
        if (!dir.exists() && !dir.mkdirs()) {
            return null;
        }
        String stored = "company_promo_" + companyId + "_" + System.currentTimeMillis() + "." + ext;
        part.write(new File(dir, stored).getAbsolutePath());
        return "/upload/" + stored;
    }

    private static String extensionOf(String fileName) {
        if (fileName == null) {
            return "";
        }
        int dot = fileName.lastIndexOf('.');
        return dot < 0 ? "" : fileName.substring(dot + 1).toLowerCase();
    }
}
