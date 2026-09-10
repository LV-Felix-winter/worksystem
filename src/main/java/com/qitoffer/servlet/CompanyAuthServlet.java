package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.UserDao;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/auth/company")
public class CompanyAuthServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        String companyName = AuthSupport.trim(req.getParameter("companyName"));
        String phone = AuthSupport.trim(req.getParameter("phone"));
        String password = AuthSupport.trim(req.getParameter("password"));
        if (companyName.isEmpty() || phone.isEmpty() || password.isEmpty()) {
            AuthSupport.redirectLogin(req, resp, "company", "pwd", "param");
            return;
        }
        if (!AuthSupport.consumeImageCaptcha(req, req.getParameter("captcha"))) {
            AuthSupport.redirectLogin(req, resp, "company", "pwd", "imgcode");
            return;
        }
        try {
            User user = userDao.findByPhone(phone);
            if (user == null) {
                user = userDao.findByLogname(phone);
            }
            if (user == null || !password.equals(user.getUserPwd())) {
                AuthSupport.redirectLogin(req, resp, "company", "pwd", "login");
                return;
            }
            if (user.getUserState() != Dict.STATE_ENABLED) {
                AuthSupport.redirectLogin(req, resp, "company", "pwd", "disabled");
                return;
            }
            boolean nameOk = userDao.companyNameMatches(user, companyName)
                    || (user.getUserRole() == Dict.ROLE_ADMIN && "系统管理员".equals(companyName));
            if (!nameOk) {
                AuthSupport.redirectLogin(req, resp, "company", "pwd", "company");
                return;
            }
            user.setUserPwd(null);
            req.getSession(true).setAttribute(Dict.SESSION_ADMIN, user);
            req.getSession().removeAttribute(Dict.SESSION_APPLICANT);
            resp.sendRedirect(req.getContextPath() + "/");
        } catch (Exception e) {
            AuthSupport.redirectLogin(req, resp, "company", "pwd", "server");
        }
    }
}
