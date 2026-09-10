package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/auth/sms")
public class SmsSendServlet extends HttpServlet {
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        String phone = AuthSupport.trim(req.getParameter("phone"));
        if (!AuthSupport.isMobile(phone)) {
            AuthSupport.writeText(resp, "PHONE_INVALID");
            return;
        }
        req.getSession(true).setAttribute(Dict.SESSION_SMS_PHONE, phone);
        AuthSupport.writeText(resp, "OK");
    }
}
