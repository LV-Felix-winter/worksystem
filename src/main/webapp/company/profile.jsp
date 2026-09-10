<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "企业资料 · 锐聘");
    request.setAttribute("navKey", "profile");
    request.setAttribute("moduleTitle", "企业资料");
    request.setAttribute("moduleDesc", "模块待开发。企业用户将在此维护企业名称、简介等信息。");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<jsp:include page="/common/pending-module.jsp"/>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
