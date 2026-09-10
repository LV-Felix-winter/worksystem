package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.UserDao;
import com.qitoffer.entity.User;
import com.qitoffer.util.CaptchaUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

/** 后台登录入口。GET 打开登录页，POST 校验图形验证码后写入 SESSION_USER。 */
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session != null && (session.getAttribute(Dict.SESSION_ADMIN) != null
                || session.getAttribute(Dict.SESSION_APPLICANT) != null)) {
            resp.sendRedirect(req.getContextPath() + "/");
            return;
        }
        req.getRequestDispatcher("/login.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain;charset=UTF-8");

        String logname = trim(req.getParameter("userLogname"));
        String password = trim(req.getParameter("userPwd"));
        String captcha = trim(req.getParameter("captcha"));

        HttpSession session = req.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute(Dict.SESSION_CAPTCHA);
        if (session != null) {
            session.removeAttribute(Dict.SESSION_CAPTCHA);
        }
        if (!CaptchaUtil.matches(expected, captcha)) {
            resp.getWriter().write("CAPTCHA_INVALID");
            return;
        }
        if (logname.isEmpty() || password.isEmpty()) {
            resp.getWriter().write("PARAM_MISSING");
            return;
        }

        try {
            User user = userDao.findByLogname(logname);
            if (user == null || !password.equals(user.getUserPwd())) {
                resp.getWriter().write("LOGIN_FAILED");
                return;
            }
            if (user.getUserState() != Dict.STATE_ENABLED) {
                resp.getWriter().write("USER_DISABLED");
                return;
            }
            if (user.getUserRole() != Dict.ROLE_ADMIN && user.getUserRole() != Dict.ROLE_COMPANY) {
                resp.getWriter().write("ROLE_DENIED");
                return;
            }
            user.setUserPwd(null);
            HttpSession loginSession = req.getSession(true);
            loginSession.setAttribute(Dict.SESSION_ADMIN, user);
            resp.getWriter().write("OK userId=" + user.getUserId()
                    + " role=" + user.getUserRole()
                    + " name=" + nullToEmpty(user.getUserRealname()));
        } catch (Exception e) {
            resp.getWriter().write("SERVER_ERROR");
        }
    }

    private static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    private static String nullToEmpty(String value) {
        return value == null ? "" : value;
    }
}
