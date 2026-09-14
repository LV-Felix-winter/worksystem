<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "管理后台 · 锐聘");
    request.setAttribute("navKey", "workbench");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String ctx = request.getContextPath();
    if (backend != null && backend.getUserRole() != Dict.ROLE_ADMIN) {
        response.sendRedirect(ctx + "/company/dashboard");
        return;
    }
    if (backend != null && backend.getUserRole() == Dict.ROLE_ADMIN) {
        response.sendRedirect(ctx + "/manage/user.jsp");
        return;
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else {
    String display = backend.getUserRealname() != null && !backend.getUserRealname().isEmpty()
            ? backend.getUserRealname() : backend.getUserLogname();
%>
<div class="manage-sheet">
    <div class="sheet-bar">
        <div class="admin-hero">
            <h1>管理后台</h1>
            <p class="muted">管理员 · <%= display %>。功能入口已集中在顶栏，也可从下方卡片进入。</p>
        </div>
    </div>
    <div class="manage-body">
    <% if ("denied".equals(request.getParameter("err"))) { %>
    <p class="err">当前账号没有该菜单权限，已回到工作台。</p>
    <% } %>
    <div class="admin-grid">
        <a class="admin-tile" href="<%= ctx %>/manage/user.jsp"><strong>用户管理</strong><span>添加 / 修改 / 分页查询后台账号</span></a>
        <a class="admin-tile" href="<%= ctx %>/manage/company.jsp"><strong>企业管理</strong><span>企业信息添加、修改与列表</span></a>
        <a class="admin-tile" href="<%= ctx %>/manage/job.jsp"><strong>职位管理</strong><span>全站职位查询与上下架</span></a>
        <a class="admin-tile" href="<%= ctx %>/manage/apply.jsp"><strong>申请查询</strong><span>全站投递记录与状态处理</span></a>
        <a class="admin-tile" href="<%= ctx %>/manage/resume.jsp"><strong>简历管理</strong><span>分页查询与详情展示</span></a>
        <a class="admin-tile" href="<%= ctx %>/manage/online.jsp"><strong>在线用户</strong><span>当前登录会话一览</span></a>
        <a class="admin-tile" href="<%= ctx %>/manage/password.jsp"><strong>密码修改</strong><span>管理员账号安全设置</span></a>
    </div>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
