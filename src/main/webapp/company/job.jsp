<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "本企业职位 · 锐聘");
    request.setAttribute("navKey", "jobs");
    request.setAttribute("moduleTitle", "本企业职位");
    request.setAttribute("moduleDesc", "模块待开发。企业用户将在此维护本企业发布的职位。");
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
