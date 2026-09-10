<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    String ctx = request.getContextPath();
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    boolean logged = backend != null || applicant != null;
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>锐聘 Q_ITOffer</title>
    <link rel="stylesheet" href="<%= ctx %>/common/login.css">
</head>
<body>
<header class="top">
    <a class="brand" href="<%= ctx %>/"><i></i>锐聘</a>
    <nav class="nav">
        <a href="<%= ctx %>/">找工作</a>
        <a href="<%= ctx %>/login?view=company">招人才</a>
        <span>帮助中心</span>
    </nav>
    <% if (logged) { %>
    <a class="help" href="<%= ctx %>/logout">退出</a>
    <% } else { %>
    <a class="help" href="<%= ctx %>/login">登录</a>
    <% } %>
</header>
<main class="home">
    <h1>锐聘招聘平台</h1>
    <% if (backend != null) { %>
    <p>已登录<%= backend.getUserRole() == Dict.ROLE_ADMIN ? "管理员" : "企业" %>：
        <%= backend.getUserRealname() != null ? backend.getUserRealname() : backend.getUserLogname() %></p>
    <div class="actions">
        <a class="primary" href="<%= ctx %>/logout" style="display:inline-flex;align-items:center;justify-content:center;width:auto;padding:0 24px;text-decoration:none;">退出</a>
    </div>
    <% } else if (applicant != null) { %>
    <p>已登录求职者：<%= applicant.getApplicantName() != null ? applicant.getApplicantName() : applicant.getApplicantPhone() %></p>
    <div class="actions">
        <a class="primary" href="<%= ctx %>/logout" style="display:inline-flex;align-items:center;justify-content:center;width:auto;padding:0 24px;text-decoration:none;">退出</a>
    </div>
    <% } else { %>
    <p>同一个入口，求职者与企业分身份登录，互不串号。</p>
    <div class="actions">
        <a class="primary" href="<%= ctx %>/login" style="display:inline-flex;align-items:center;justify-content:center;width:auto;padding:0 24px;text-decoration:none;">进入登录</a>
    </div>
    <% } %>
</main>
<footer class="foot">
    <span>© 2026 锐聘 · 演示站点，非正式运营主体</span>
    <span>备案号占位 京ICP备00000000号-1</span>
</footer>
</body>
</html>
