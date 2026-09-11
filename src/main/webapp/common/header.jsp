<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    String ctx = request.getContextPath();
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    String headerMode = (String) request.getAttribute("headerMode");
    String navKey = (String) request.getAttribute("navKey");
    if (navKey == null) {
        navKey = "";
    }
    boolean loginHeader = "login".equals(headerMode);
    String brandHref = backend != null ? ctx + "/manage/" : ctx + "/";
    String whoName = "";
    String whoRole = "";
    if (backend != null) {
        whoRole = backend.getUserRole() == Dict.ROLE_ADMIN ? "管理员" : "企业";
        whoName = backend.getUserRealname() != null && !backend.getUserRealname().isEmpty()
                ? backend.getUserRealname() : backend.getUserLogname();
    } else if (applicant != null) {
        whoRole = "求职者";
        whoName = applicant.getApplicantName() != null && !applicant.getApplicantName().isEmpty()
                ? applicant.getApplicantName() : applicant.getApplicantPhone();
    }
%>
<header class="top">
    <a class="brand" href="<%= brandHref %>"><i></i>锐聘</a>
    <nav class="nav">
        <% if (backend != null) { %>
        <a class="<%= "workbench".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/">工作台</a>
        <% } else if (applicant != null) { %>
        <a class="<%= "jobs".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/job/search">找工作</a>
        <a class="<%= "center".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/resume/">我的简历</a>
        <a class="<%= "apply".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/user/apply.jsp">我的投递</a>
        <a class="<%= "fav".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/favorite/list">收藏职位</a>
        <% } else { %>
        <a class="<%= "jobs".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/job/search">找工作</a>
        <a href="<%= ctx %>/login?view=company">招人才</a>
        <span>帮助中心</span>
        <% } %>
    </nav>
    <% if (loginHeader) { %>
    <span class="help">使用说明</span>
    <% } else if (backend != null || applicant != null) { %>
    <div class="who">
        <span><%= whoRole %> · <%= whoName %></span>
        <a class="help" href="<%= ctx %>/logout">退出</a>
    </div>
    <% } else { %>
    <a class="help" href="<%= ctx %>/login">登录</a>
    <% } %>
</header>
