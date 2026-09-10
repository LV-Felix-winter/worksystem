<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "工作台 · 锐聘");
    request.setAttribute("navKey", "workbench");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else {
    boolean admin = backend.getUserRole() == Dict.ROLE_ADMIN;
    String roleName = admin ? "管理员" : "企业";
    String display = backend.getUserRealname() != null && !backend.getUserRealname().isEmpty()
            ? backend.getUserRealname() : backend.getUserLogname();
%>
<div class="card">
    <h1><%= admin ? "管理后台" : "企业工作台" %></h1>
    <p class="muted">当前身份：<%= roleName %> · <%= display %>。左侧菜单按角色显示，后续模块接入后可从这里进入。</p>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
