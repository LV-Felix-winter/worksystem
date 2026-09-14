<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    User shellUser = (User) session.getAttribute(Dict.SESSION_ADMIN);
    boolean adminShell = shellUser != null && shellUser.getUserRole() == Dict.ROLE_ADMIN;
    request.setAttribute("shellBackend", Boolean.FALSE);
    if (adminShell) {
%>
<main class="page admin">
<%
    } else if (shellUser != null) {
%>
<main class="page firm">
<%
    } else {
%>
<main class="page front">
<%
    }
%>
