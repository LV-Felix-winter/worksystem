package com.qitoffer.util;

import com.qitoffer.common.Dict;
import com.qitoffer.util.CaptchaUtil;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

public final class AuthSupport {
    private AuthSupport() {
    }

    public static String trim(String value) {
        return value == null ? "" : value.trim();
    }

    public static boolean isMobile(String phone) {
        return phone != null && phone.matches("1\\d{10}");
    }

    public static boolean consumeImageCaptcha(HttpServletRequest req, String input) {
        HttpSession session = req.getSession(false);
        String expected = session == null ? null : (String) session.getAttribute(Dict.SESSION_CAPTCHA);
        if (session != null) {
            session.removeAttribute(Dict.SESSION_CAPTCHA);
        }
        return CaptchaUtil.matches(expected, input);
    }

    public static boolean consumeSmsCode(String input) {
        return Dict.SMS_DEMO_CODE.equals(trim(input));
    }

    public static void redirectLogin(HttpServletRequest req, HttpServletResponse resp,
                                    String view, String tab, String error) throws IOException {
        String ctx = req.getContextPath();
        StringBuilder url = new StringBuilder(ctx).append("/login?view=").append(view);
        if (tab != null && !tab.isEmpty()) {
            url.append("&tab=").append(tab);
        }
        if (error != null && !error.isEmpty()) {
            url.append("&err=").append(error);
        }
        resp.sendRedirect(url.toString());
    }

    public static void writeText(HttpServletResponse resp, String body) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        resp.setContentType("text/plain;charset=UTF-8");
        resp.getWriter().write(body);
    }
}
