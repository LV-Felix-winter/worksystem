package com.qitoffer.util;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.User;
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

    public static String appPath(HttpServletRequest req) {
        String uri = req.getRequestURI();
        String ctx = req.getContextPath();
        String path = uri.startsWith(ctx) ? uri.substring(ctx.length()) : uri;
        if (path.isEmpty()) {
            path = "/";
        }
        int semi = path.indexOf(';');
        if (semi >= 0) {
            path = path.substring(0, semi);
        }
        return path;
    }

    public static User backendUser(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(Dict.SESSION_ADMIN);
        return value instanceof User ? (User) value : null;
    }

    public static Applicant applicant(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(Dict.SESSION_APPLICANT);
        return value instanceof Applicant ? (Applicant) value : null;
    }

    /** 顶栏身份：applicant / company / admin / public-company / public-admin / guest */
    public static String navRealm(HttpServletRequest req) {
        User backend = backendUser(req);
        Applicant applicant = applicant(req);
        String path = appPath(req);
        boolean companyWork = isCompanyWorkspace(path);
        boolean adminWork = isAdminWorkspace(path);
        /* 管理员始终用管理顶栏，不随页面切到企业/访客态 */
        if (backend != null && backend.getUserRole() == Dict.ROLE_ADMIN) {
            return "admin";
        }
        if (applicant != null && !companyWork && !adminWork) {
            return "applicant";
        }
        if (backend != null && backend.getUserRole() == Dict.ROLE_COMPANY && companyWork) {
            return "company";
        }
        if (applicant != null) {
            return "applicant";
        }
        if (backend != null && backend.getUserRole() == Dict.ROLE_COMPANY) {
            return "public-company";
        }
        return "guest";
    }

    public static boolean isCompanyWorkspace(String path) {
        return path.startsWith("/company")
                || "/apply/company".equals(path)
                || path.startsWith("/apply/detail")
                || path.startsWith("/apply/state")
                || "/talk".equals(path)
                || path.startsWith("/talk/")
                || path.startsWith("/message");
    }

    public static boolean isAdminWorkspace(String path) {
        return "/manage".equals(path) || path.startsWith("/manage/");
    }

    public static boolean isAdminOnlyPath(String path) {
        return path.startsWith("/manage/user")
                || path.startsWith("/manage/company")
                || path.startsWith("/manage/job")
                || path.startsWith("/manage/apply")
                || path.startsWith("/manage/resume")
                || path.startsWith("/manage/online")
                || path.startsWith("/manage/password");
    }

    public static void redirectTo(HttpServletRequest req, HttpServletResponse resp, String path)
            throws IOException {
        resp.sendRedirect(req.getContextPath() + path);
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
