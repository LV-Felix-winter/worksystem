package com.qitoffer.filter;

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

/** 求职者中心：未登录回登录页；企业/管理员会话则回工作台。 */
@WebFilter(urlPatterns = {"/user", "/user/*"})
public class ApplicantFilter implements Filter {
    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse resp = (HttpServletResponse) response;
        req.setCharacterEncoding("UTF-8");
        if (AuthSupport.applicant(req) != null) {
            chain.doFilter(request, response);
            return;
        }
        if (AuthSupport.backendUser(req) != null) {
            AuthSupport.redirectTo(req, resp, "/manage/");
            return;
        }
        AuthSupport.redirectLogin(req, resp, "applicant", "sms", "auth");
    }
}
