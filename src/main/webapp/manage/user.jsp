<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.dao.UserDao" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "用户管理 · 锐聘");
    request.setAttribute("navKey", "users");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String ctx = request.getContextPath();
    String kw = request.getParameter("kw") == null ? "" : request.getParameter("kw").trim();
    Integer role = null;
    if ("1".equals(request.getParameter("role"))) {
        role = Dict.ROLE_ADMIN;
    } else if ("2".equals(request.getParameter("role"))) {
        role = Dict.ROLE_COMPANY;
    }
    int curPage = 1;
    try {
        curPage = Integer.parseInt(request.getParameter("page") == null ? "1" : request.getParameter("page"));
    } catch (NumberFormatException ignored) {
    }
    if (curPage < 1) {
        curPage = 1;
    }
    int editId = 0;
    try {
        editId = Integer.parseInt(request.getParameter("edit") == null ? "0" : request.getParameter("edit"));
    } catch (NumberFormatException ignored) {
    }
    boolean adding = "1".equals(request.getParameter("add"));
    final int pageSize = 10;
    UserDao dao = new UserDao();
    List<User> users = new ArrayList<>();
    User editing = null;
    int total = 0;
    String dataErr = "";
    try {
        if (editId > 0) {
            editing = dao.findById(editId);
        }
        users = dao.listPage(kw, role, curPage, pageSize);
        total = dao.countPage(kw, role);
    } catch (Exception e) {
        dataErr = "用户数据加载失败。";
    }
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
    if (curPage > pageCount) {
        curPage = pageCount;
    }
    String listQuery = "kw=" + URLEncoder.encode(kw, "UTF-8") + "&role=" + (role == null ? "all" : role);
    String msg = (String) session.getAttribute("manageMsg");
    if (msg != null) {
        session.removeAttribute("manageMsg");
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="manage-sheet">
    <div class="sheet-bar">
        <div>
            <h1>用户管理</h1>
            <p class="muted">分页查询、新增与维护后台账号（管理员 / 企业）。</p>
        </div>
        <a class="primary inline" href="<%= ctx %>/manage/user.jsp?add=1">添加用户</a>
    </div>
    <div class="manage-body">
    <% if (msg != null) { %><p class="ok toast-ok"><%= msg %></p><% } %>
    <% if (!dataErr.isEmpty()) { %><p class="err"><%= dataErr %></p><% } %>

    <% if (adding || editing != null) {
        User form = editing == null ? new User() : editing;
        boolean isNew = editing == null;
    %>
    <form class="sheet-form form-pro manage-form" method="post" action="<%= ctx %>/manage/user">
        <input type="hidden" name="action" value="save">
        <input type="hidden" name="id" value="<%= isNew ? 0 : form.getUserId() %>">
        <h3 class="form-sec"><%= isNew ? "添加用户" : "修改用户 #" + form.getUserId() %></h3>
        <div class="form-row">
            <div class="form-col"><label>登录名</label><input class="input" name="userLogname" value="<%= form.getUserLogname() == null ? "" : form.getUserLogname() %>" required></div>
            <div class="form-col"><label>真实姓名</label><input class="input" name="userRealname" value="<%= form.getUserRealname() == null ? "" : form.getUserRealname() %>" required></div>
        </div>
        <div class="form-row">
            <div class="form-col"><label>手机号</label><input class="input" name="userPhone" value="<%= form.getUserPhone() == null ? "" : form.getUserPhone() %>"></div>
            <div class="form-col"><label>邮箱</label><input class="input" name="userEmail" value="<%= form.getUserEmail() == null ? "" : form.getUserEmail() %>"></div>
        </div>
        <div class="form-row">
            <div class="form-col">
                <label>角色</label>
                <select class="input" name="userRole">
                    <option value="2" <%= form.getUserRole() != Dict.ROLE_ADMIN ? "selected" : "" %>>企业</option>
                    <option value="1" <%= form.getUserRole() == Dict.ROLE_ADMIN ? "selected" : "" %>>管理员</option>
                </select>
            </div>
            <div class="form-col">
                <label>状态</label>
                <select class="input" name="userState">
                    <option value="1" <%= form.getUserState() != Dict.STATE_DISABLED ? "selected" : "" %>>启用</option>
                    <option value="0" <%= form.getUserState() == Dict.STATE_DISABLED ? "selected" : "" %>>禁用</option>
                </select>
            </div>
        </div>
        <label>密码<%= isNew ? "" : "（留空则不修改）" %></label>
        <input class="input" type="password" name="userPwd" placeholder="<%= isNew ? "至少 6 位" : "可选，填写则重置" %>" <%= isNew ? "required" : "" %>>
        <div class="actions form-actions">
            <button class="primary inline" type="submit">保存</button>
            <a class="btn-lite" href="<%= ctx %>/manage/user.jsp">取消</a>
        </div>
    </form>
    <% } %>

    <form class="toolbar" method="get" action="<%= ctx %>/manage/user.jsp">
        <input class="input" name="kw" value="<%= kw %>" placeholder="登录名 / 姓名 / 手机 / 邮箱">
        <select class="input" name="role">
            <option value="all" <%= role == null ? "selected" : "" %>>全部角色</option>
            <option value="1" <%= role != null && role == Dict.ROLE_ADMIN ? "selected" : "" %>>管理员</option>
            <option value="2" <%= role != null && role == Dict.ROLE_COMPANY ? "selected" : "" %>>企业</option>
        </select>
        <button class="primary inline" type="submit">查询</button>
        <a class="btn-lite" href="<%= ctx %>/manage/user.jsp">重置</a>
        <span class="muted">共 <%= total %> 条</span>
    </form>
    <div class="table-wrap">
        <table class="data">
            <tr><th>ID</th><th>登录名</th><th>姓名</th><th>手机</th><th>角色</th><th>状态</th><th>操作</th></tr>
            <% if (users.isEmpty()) { %>
            <tr><td colspan="7" class="muted">没有符合条件的用户</td></tr>
            <% } else {
                for (User u : users) {
            %>
            <tr>
                <td><%= u.getUserId() %></td>
                <td><b><%= u.getUserLogname() %></b></td>
                <td><%= u.getUserRealname() %></td>
                <td><%= u.getUserPhone() == null ? "—" : u.getUserPhone() %></td>
                <td><span class="tag"><%= Labels.userRoleLabel(u.getUserRole()) %></span></td>
                <td><span class="tag <%= u.getUserState() == Dict.STATE_ENABLED ? "" : "off" %>"><%= Labels.userStateLabel(u.getUserState()) %></span></td>
                <td><a class="op-link" href="<%= ctx %>/manage/user.jsp?<%= listQuery %>&edit=<%= u.getUserId() %>">修改</a></td>
            </tr>
            <% } } %>
        </table>
    </div>
    <div class="pager">
        <a href="<%= ctx %>/manage/user.jsp?<%= listQuery %>&page=1">首页</a>
        <% if (curPage > 1) { %><a href="<%= ctx %>/manage/user.jsp?<%= listQuery %>&page=<%= curPage - 1 %>">上一页</a><% } %>
        <a class="on" href="<%= ctx %>/manage/user.jsp?<%= listQuery %>&page=<%= curPage %>"><%= curPage %></a>
        <% if (curPage < pageCount) { %><a href="<%= ctx %>/manage/user.jsp?<%= listQuery %>&page=<%= curPage + 1 %>">下一页</a><% } %>
        <a href="<%= ctx %>/manage/user.jsp?<%= listQuery %>&page=<%= pageCount %>">尾页</a>
    </div>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
