<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String htmlCtx = request.getContextPath();
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null || pageTitle.isEmpty()) {
        pageTitle = "锐聘 Q_ITOffer";
    }
    String bodyClass = (String) request.getAttribute("bodyClass");
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= pageTitle %></title>
    <link rel="stylesheet" href="<%= htmlCtx %>/common/login.css?v=admin-topnav-1">
</head>
<body<%= bodyClass != null && !bodyClass.isEmpty() ? " class=\"" + bodyClass + "\"" : "" %>>
<jsp:include page="/common/header.jsp"/>
<% if (!Boolean.TRUE.equals(request.getAttribute("hideBrand"))) { %>
<jsp:include page="/common/brandbar.jsp"/>
<% } %>
