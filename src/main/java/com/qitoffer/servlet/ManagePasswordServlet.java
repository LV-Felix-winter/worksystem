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

@WebServlet("/manage/password")
public class ManagePasswordServlet extends HttpServlet {
    private final UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        User backend = AuthSupport.backendUser(req);
        if (backend == null || backend.getUserRole() != Dict.ROLE_ADMIN) {
            AuthSupport.redirectLogin(req, resp, "admin", null, "auth");
            return;
        }
        String oldPwd = AuthSupport.trim(req.getParameter("oldPwd"));
        String newPwd = AuthSupport.trim(req.getParameter("newPwd"));
        String confirm = AuthSupport.trim(req.getParameter("confirmPwd"));
        try {
            User db = userDao.findById(backend.getUserId());
            if (db == null || !oldPwd.equals(db.getUserPwd())) {
                req.getSession().setAttribute("manageMsg", "原密码不正确。");
            } else if (newPwd.length() < 6) {
                req.getSession().setAttribute("manageMsg", "新密码至少 6 位。");
            } else if (!newPwd.equals(confirm)) {
                req.getSession().setAttribute("manageMsg", "两次输入的新密码不一致。");
            } else {
                userDao.updatePassword(backend.getUserId(), newPwd);
                req.getSession().setAttribute("manageMsg", "密码已修改，请牢记新密码。");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("manageMsg", "修改失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/manage/password.jsp");
    }
}
