package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** 消息已改为顶栏铃铛弹窗，旧列表页入口重定向。 */
@WebServlet("/message/list")
public class MessageListServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        User user = (User) req.getSession().getAttribute(Dict.SESSION_ADMIN);
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        if (user != null) {
            if (user.getUserRole() == Dict.ROLE_ADMIN) {
                resp.sendRedirect(req.getContextPath() + "/manage/");
            } else {
                resp.sendRedirect(req.getContextPath() + "/company/dashboard");
            }
            return;
        }
        if (applicant != null) {
            resp.sendRedirect(req.getContextPath() + "/job/search");
            return;
        }
        resp.sendRedirect(req.getContextPath() + "/login");
    }
}
