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

@WebServlet("/auth/applicant")
public class ApplicantAuthServlet extends HttpServlet {
    private final ApplicantDao applicantDao = new ApplicantDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        String mode = AuthSupport.trim(req.getParameter("mode"));
        String phone = AuthSupport.trim(req.getParameter("phone"));
        if (!AuthSupport.isMobile(phone)) {
            AuthSupport.redirectLogin(req, resp, "applicant", mode, "phone");
            return;
        }
        try {
            Applicant applicant = applicantDao.findByPhone(phone);
            if ("sms".equals(mode)) {
                if (!AuthSupport.consumeSmsCode(req.getParameter("smsCode"))) {
                    AuthSupport.redirectLogin(req, resp, "applicant", "sms", "sms");
                    return;
                }
            } else {
                if (!AuthSupport.consumeImageCaptcha(req, req.getParameter("captcha"))) {
                    AuthSupport.redirectLogin(req, resp, "applicant", "pwd", "imgcode");
                    return;
                }
                String password = AuthSupport.trim(req.getParameter("password"));
                if (applicant == null || !password.equals(applicant.getApplicantPwd())) {
                    AuthSupport.redirectLogin(req, resp, "applicant", "pwd", "login");
                    return;
                }
            }
            if (applicant == null) {
                AuthSupport.redirectLogin(req, resp, "applicant", mode, "noreg");
                return;
            }
            applicant.setApplicantPwd(null);
            req.getSession(true).setAttribute(Dict.SESSION_APPLICANT, applicant);
            req.getSession().removeAttribute(Dict.SESSION_ADMIN);
            resp.sendRedirect(req.getContextPath() + "/");
        } catch (Exception e) {
            AuthSupport.redirectLogin(req, resp, "applicant", mode, "server");
        }
    }
}
