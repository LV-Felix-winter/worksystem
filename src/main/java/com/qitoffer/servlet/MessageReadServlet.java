package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.MessageDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/message/read")
public class MessageReadServlet extends HttpServlet {
    private final MessageDao messageDao = new MessageDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        User user = (User) req.getSession().getAttribute(Dict.SESSION_ADMIN);
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        boolean ajax = wantsJson(req);
        if (user == null && applicant == null) {
            if (ajax) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.setContentType("application/json;charset=UTF-8");
                resp.getWriter().write("{\"ok\":false}");
            } else {
                resp.sendRedirect(req.getContextPath() + "/login");
            }
            return;
        }
        int messageId = parseInt(req.getParameter("messageId"), 0);
        String action = AuthSupport.trim(req.getParameter("action"));
        try {
            if ("readAll".equals(action)) {
                if (user != null) {
                    messageDao.markAllRead(Dict.RECEIVER_USER, user.getUserId());
                } else {
                    messageDao.markAllRead(Dict.RECEIVER_APPLICANT, applicant.getApplicantId());
                }
            } else if (messageId > 0) {
                messageDao.markRead(messageId);
            }
        } catch (Exception ignored) {
        }
        if (ajax) {
            resp.setContentType("application/json;charset=UTF-8");
            resp.getWriter().write("{\"ok\":true}");
            return;
        }
        String fallback = req.getContextPath() + "/job/search";
        if (user != null) {
            fallback = user.getUserRole() == Dict.ROLE_ADMIN
                    ? req.getContextPath() + "/manage/"
                    : req.getContextPath() + "/company/dashboard";
        }
        resp.sendRedirect(fallback);
    }

    private static boolean wantsJson(HttpServletRequest req) {
        String accept = req.getHeader("Accept");
        return accept != null && accept.contains("application/json");
    }

    private static int parseInt(String value, int defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return defaultValue;
        }
    }
}
