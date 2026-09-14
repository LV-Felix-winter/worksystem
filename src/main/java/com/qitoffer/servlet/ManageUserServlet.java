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

@WebServlet("/manage/user")
public class ManageUserServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        if (!requireAdmin(req, resp)) {
            return;
        }
        String action = AuthSupport.trim(req.getParameter("action"));
        try {
            if ("save".equals(action)) {
                save(req);
            } else if ("resetPwd".equals(action)) {
                int id = parseInt(req.getParameter("id"), 0);
                String pwd = AuthSupport.trim(req.getParameter("password"));
                if (id > 0 && pwd.length() >= 6) {
                    userDao.updatePassword(id, pwd);
                    req.getSession().setAttribute("manageMsg", "密码已重置。");
                } else {
                    req.getSession().setAttribute("manageMsg", "重置失败：密码至少 6 位。");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("manageMsg", "操作失败：" + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/manage/user.jsp");
    }

    private void save(HttpServletRequest req) throws Exception {
        int id = parseInt(req.getParameter("id"), 0);
        String logname = AuthSupport.trim(req.getParameter("userLogname"));
        String realname = AuthSupport.trim(req.getParameter("userRealname"));
        String email = AuthSupport.trim(req.getParameter("userEmail"));
        String phone = AuthSupport.trim(req.getParameter("userPhone"));
        int role = parseInt(req.getParameter("userRole"), Dict.ROLE_COMPANY);
        int state = parseInt(req.getParameter("userState"), Dict.STATE_ENABLED);
        String password = AuthSupport.trim(req.getParameter("userPwd"));
        if (logname.isEmpty() || realname.isEmpty()) {
            req.getSession().setAttribute("manageMsg", "请填写登录名和真实姓名。");
            return;
        }
        if (role != Dict.ROLE_ADMIN && role != Dict.ROLE_COMPANY) {
            role = Dict.ROLE_COMPANY;
        }
        if (userDao.existsLogname(logname, id)) {
            req.getSession().setAttribute("manageMsg", "登录名已存在。");
            return;
        }
        if (id <= 0) {
            if (password.length() < 6) {
                req.getSession().setAttribute("manageMsg", "新用户密码至少 6 位。");
                return;
            }
            User user = new User();
            user.setUserLogname(logname);
            user.setUserPwd(password);
            user.setUserRealname(realname);
            user.setUserEmail(email);
            user.setUserPhone(phone);
            user.setUserRole(role);
            user.setUserState(state);
            userDao.insert(user);
            req.getSession().setAttribute("manageMsg", "用户已添加。");
            return;
        }
        User existing = userDao.findById(id);
        if (existing == null) {
            req.getSession().setAttribute("manageMsg", "用户不存在。");
            return;
        }
        existing.setUserLogname(logname);
        existing.setUserRealname(realname);
        existing.setUserEmail(email);
        existing.setUserPhone(phone);
        existing.setUserRole(role);
        existing.setUserState(state);
        userDao.update(existing);
        if (!password.isEmpty()) {
            if (password.length() < 6) {
                req.getSession().setAttribute("manageMsg", "资料已保存，但新密码太短未更新。");
                return;
            }
            userDao.updatePassword(id, password);
        }
        req.getSession().setAttribute("manageMsg", "用户资料已保存。");
    }

    private boolean requireAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User backend = AuthSupport.backendUser(req);
        if (backend == null || backend.getUserRole() != Dict.ROLE_ADMIN) {
            AuthSupport.redirectLogin(req, resp, "admin", null, "auth");
            return false;
        }
        return true;
    }

    private static int parseInt(String value, int def) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return def;
        }
    }
}
