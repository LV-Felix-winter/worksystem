package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/login/status")
public class LoginStatusServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain;charset=UTF-8");
        HttpSession session = req.getSession(false);
        Object value = session == null ? null : session.getAttribute(Dict.SESSION_ADMIN);
        if (!(value instanceof User)) {
            resp.getWriter().write("ANONYMOUS");
            return;
        }
        User user = (User) value;
        resp.getWriter().write("OK userId=" + user.getUserId()
                + " role=" + user.getUserRole()
                + " logname=" + user.getUserLogname());
    }
}
