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

/** 管理员专有登录：账号 + 密码，仅 ROLE_ADMIN。 */
@WebServlet("/auth/admin")
public class AdminAuthServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        String account = AuthSupport.trim(req.getParameter("account"));
        String password = AuthSupport.trim(req.getParameter("password"));
        if (account.isEmpty() || password.isEmpty()) {
            AuthSupport.redirectLogin(req, resp, "admin", null, "param");
            return;
        }
        try {
            User user = userDao.findByLogname(account);
            if (user == null) {
                user = userDao.findByPhone(account);
            }
            if (user == null || !password.equals(user.getUserPwd())) {
                AuthSupport.redirectLogin(req, resp, "admin", null, "login");
                return;
            }
            if (user.getUserRole() != Dict.ROLE_ADMIN) {
                AuthSupport.redirectLogin(req, resp, "admin", null, "role");
                return;
            }
            if (user.getUserState() != Dict.STATE_ENABLED) {
                AuthSupport.redirectLogin(req, resp, "admin", null, "disabled");
                return;
            }
            user.setUserPwd(null);
            req.getSession(true).setAttribute(Dict.SESSION_ADMIN, user);
            req.getSession().removeAttribute(Dict.SESSION_APPLICANT);
            resp.sendRedirect(req.getContextPath() + "/manage/user.jsp");
        } catch (Exception e) {
            AuthSupport.redirectLogin(req, resp, "admin", null, "server");
        }
    }
}
