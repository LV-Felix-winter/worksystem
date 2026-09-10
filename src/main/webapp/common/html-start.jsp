<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String htmlCtx = request.getContextPath();
    String pageTitle = (String) request.getAttribute("pageTitle");
    if (pageTitle == null || pageTitle.isEmpty()) {
        pageTitle = "锐聘 Q_ITOffer";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><%= pageTitle %></title>
    <link rel="stylesheet" href="<%= htmlCtx %>/common/login.css">
</head>
<body>
<jsp:include page="/common/header.jsp"/>
