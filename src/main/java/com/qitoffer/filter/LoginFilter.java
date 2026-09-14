package com.qitoffer.filter;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/** 后台页：未登录回企业登录；非管理员不能打开管理专属页。 */
@WebFilter(urlPatterns = {"/manage", "/manage/*", "/company", "/company/*"})
public class LoginFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        req.setCharacterEncoding("UTF-8");
        String path = AuthSupport.appPath(req);
        User backend = AuthSupport.backendUser(req);
        if (backend == null) {
            if (AuthSupport.applicant(req) != null) {
                AuthSupport.redirectTo(req, resp, "/");
            } else if (AuthSupport.isAdminWorkspace(path)) {
                AuthSupport.redirectLogin(req, resp, "admin", null, "auth");
            } else {
                AuthSupport.redirectLogin(req, resp, "company", "pwd", "auth");
            }
            return;
        }
        if (AuthSupport.isAdminOnlyPath(path) && backend.getUserRole() != Dict.ROLE_ADMIN) {
            AuthSupport.redirectTo(req, resp, "/manage/user.jsp?err=denied");
            return;
        }
        chain.doFilter(request, response);
    }
}
