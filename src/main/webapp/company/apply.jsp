<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "应聘信息 · 锐聘");
    request.setAttribute("navKey", "applies");
    request.setAttribute("moduleTitle", "应聘信息");
    request.setAttribute("moduleDesc", "模块待开发。企业用户将在此查看本企业职位的投递记录。");
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
