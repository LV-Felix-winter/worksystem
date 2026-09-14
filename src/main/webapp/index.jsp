<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    String ctx = request.getContextPath();
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    if (applicant != null) {
        response.sendRedirect(ctx + "/job/search");
        return;
    }
    if (backend != null && backend.getUserRole() == Dict.ROLE_ADMIN) {
        response.sendRedirect(ctx + "/manage/");
        return;
    }
    if (backend != null) {
        response.sendRedirect(ctx + "/company/dashboard");
        return;
    }
    response.sendRedirect(ctx + "/job/search");
%>
