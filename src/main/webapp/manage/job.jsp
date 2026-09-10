<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "职位管理 · 锐聘");
    request.setAttribute("navKey", "jobs");
    request.setAttribute("moduleTitle", "职位管理");
    request.setAttribute("moduleDesc", "模块待开发。管理员将在此按条件查询职位并查看详情。");
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
