package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.ApplicantDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/auth/register")
public class ApplicantRegisterServlet extends HttpServlet {
    private final ApplicantDao applicantDao = new ApplicantDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        String name = AuthSupport.trim(req.getParameter("name"));
        String phone = AuthSupport.trim(req.getParameter("phone"));
        String code = AuthSupport.trim(req.getParameter("smsCode"));
        if (name.isEmpty()) {
            AuthSupport.redirectLogin(req, resp, "register", "sms", "name");
            return;
        }
        if (!AuthSupport.isMobile(phone)) {
            AuthSupport.redirectLogin(req, resp, "register", "sms", "phone");
            return;
        }
        if (!AuthSupport.consumeSmsCode(code)) {
            AuthSupport.redirectLogin(req, resp, "register", "sms", "sms");
            return;
        }
        try {
            if (applicantDao.findByPhone(phone) != null) {
                AuthSupport.redirectLogin(req, resp, "register", "sms", "exist");
                return;
            }
            Applicant applicant = new Applicant();
            applicant.setApplicantName(name);
            applicant.setApplicantPhone(phone);
            applicant.setApplicantEmail(phone + "@itoffer.cn");
            applicant.setApplicantPwd("123456");
            applicantDao.insert(applicant);
            Applicant saved = applicantDao.findByPhone(phone);
            if (saved != null) {
                saved.setApplicantPwd(null);
                req.getSession(true).setAttribute(Dict.SESSION_APPLICANT, saved);
                req.getSession().removeAttribute(Dict.SESSION_ADMIN);
            }
            resp.sendRedirect(req.getContextPath() + "/");
        } catch (Exception e) {
            AuthSupport.redirectLogin(req, resp, "register", "sms", "server");
        }
    }
}
