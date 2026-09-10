<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    User shellUser = (User) session.getAttribute(Dict.SESSION_ADMIN);
    request.setAttribute("shellBackend", shellUser != null);
    if (shellUser != null) {
%>
<div class="shell">
<jsp:include page="/common/manage-left.jsp"/>
<main class="page">
<%
    } else {
%>
<main class="page front">
<%
    }
%>
