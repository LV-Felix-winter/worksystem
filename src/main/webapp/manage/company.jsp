<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.dao.CompanyDao" %>
<%@ page import="com.qitoffer.entity.Company" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "企业管理 · 锐聘");
    request.setAttribute("navKey", "companies");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String ctx = request.getContextPath();
    String kw = request.getParameter("kw") == null ? "" : request.getParameter("kw").trim();
    Integer state = null;
    if ("1".equals(request.getParameter("state"))) {
        state = Dict.STATE_ENABLED;
    } else if ("0".equals(request.getParameter("state"))) {
        state = Dict.STATE_DISABLED;
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
    CompanyDao dao = new CompanyDao();
    List<Company> companies = new ArrayList<>();
    Company editing = null;
    int total = 0;
    String dataErr = "";
    try {
        if (editId > 0) {
            editing = dao.findById(editId);
        }
        companies = dao.listPage(kw, state, curPage, pageSize);
        total = dao.countPage(kw, state);
    } catch (Exception e) {
        dataErr = "企业数据加载失败。";
    }
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
    if (curPage > pageCount) {
        curPage = pageCount;
    }
    String listQuery = "kw=" + URLEncoder.encode(kw, "UTF-8") + "&state=" + (state == null ? "all" : state);
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
            <h1>企业管理</h1>
            <p class="muted">企业列表查询、信息添加与修改。新增时可同步创建企业登录账号。</p>
        </div>
        <a class="primary inline" href="<%= ctx %>/manage/company.jsp?add=1">添加企业</a>
    </div>
    <div class="manage-body">
    <% if (msg != null) { %><p class="ok toast-ok"><%= msg %></p><% } %>
    <% if (!dataErr.isEmpty()) { %><p class="err"><%= dataErr %></p><% } %>

    <% if (adding || editing != null) {
        Company form = editing == null ? new Company() : editing;
        boolean isNew = editing == null;
        if (isNew) {
            form.setCompanyState(Dict.STATE_ENABLED);
            form.setCompanySort(100);
            form.setCompanySize("100-200人");
            form.setCompanyType("民营企业");
        }
    %>
    <form class="sheet-form form-pro manage-form" method="post" action="<%= ctx %>/manage/company">
        <input type="hidden" name="id" value="<%= isNew ? 0 : form.getCompanyId() %>">
        <h3 class="form-sec"><%= isNew ? "添加企业" : "修改企业 #" + form.getCompanyId() %></h3>
        <div class="form-row">
            <div class="form-col"><label>企业名称</label><input class="input" name="companyName" value="<%= form.getCompanyName() == null ? "" : form.getCompanyName() %>" required></div>
            <div class="form-col"><label>所在地</label><input class="input js-region" name="companyArea" value="<%= form.getCompanyArea() == null ? "" : form.getCompanyArea() %>" placeholder="选择省 / 市 / 区县" readonly></div>
        </div>
        <div class="form-row">
            <div class="form-col">
                <label>企业规模</label>
                <select class="input" name="companySize">
                    <% String[] sizes = {"1-49人","50-99人","100-200人","200-400人","300-500人","1000人以上"};
                       for (String s : sizes) { %>
                    <option value="<%= s %>" <%= s.equals(form.getCompanySize()) ? "selected" : "" %>><%= s %></option>
                    <% } %>
                </select>
            </div>
            <div class="form-col">
                <label>企业性质</label>
                <select class="input" name="companyType">
                    <% String[] types = {"民营企业","股份制企业","外商独资","合资企业","教育培训"};
                       for (String t : types) { %>
                    <option value="<%= t %>" <%= t.equals(form.getCompanyType()) ? "selected" : "" %>><%= t %></option>
                    <% } %>
                </select>
            </div>
        </div>
        <div class="form-row">
            <div class="form-col">
                <label>状态</label>
                <select class="input" name="companyState">
                    <option value="1" <%= form.getCompanyState() == Dict.STATE_ENABLED ? "selected" : "" %>>招聘中</option>
                    <option value="0" <%= form.getCompanyState() != Dict.STATE_ENABLED ? "selected" : "" %>>已停用</option>
                </select>
            </div>
            <div class="form-col"><label>排序</label><input class="input" name="companySort" value="<%= form.getCompanySort() %>"></div>
        </div>
        <label>企业简介</label>
        <textarea class="input brief-wide" name="companyBrief" rows="5"><%= form.getCompanyBrief() == null ? "" : form.getCompanyBrief() %></textarea>
        <% if (isNew) { %>
        <h3 class="form-sec">关联登录账号</h3>
        <div class="form-row">
            <div class="form-col"><label>登录账号</label><input class="input" name="account" placeholder="企业后台登录名 / 手机号" required></div>
            <div class="form-col"><label>初始密码</label><input class="input" type="password" name="password" placeholder="至少 6 位" required></div>
        </div>
        <% } else { %>
        <div class="form-row">
            <div class="form-col"><label>关联用户 ID</label><input class="input" name="userId" value="<%= form.getUserId() %>"></div>
        </div>
        <% } %>
        <div class="actions form-actions">
            <button class="primary inline" type="submit">保存</button>
            <a class="btn-lite" href="<%= ctx %>/manage/company.jsp">取消</a>
        </div>
    </form>
    <% } %>

    <form class="toolbar" method="get" action="<%= ctx %>/manage/company.jsp">
        <input class="input" name="kw" value="<%= kw %>" placeholder="企业名称 / 地区 / 性质">
        <select class="input" name="state">
            <option value="all" <%= state == null ? "selected" : "" %>>全部状态</option>
            <option value="1" <%= state != null && state == Dict.STATE_ENABLED ? "selected" : "" %>>招聘中</option>
            <option value="0" <%= state != null && state == Dict.STATE_DISABLED ? "selected" : "" %>>已停用</option>
        </select>
        <button class="primary inline" type="submit">查询</button>
        <a class="btn-lite" href="<%= ctx %>/manage/company.jsp">重置</a>
        <span class="muted">共 <%= total %> 条</span>
    </form>
    <div class="table-wrap">
        <table class="data">
            <tr><th>ID</th><th>企业</th><th>地区</th><th>规模</th><th>状态</th><th>浏览</th><th>操作</th></tr>
            <% if (companies.isEmpty()) { %>
            <tr><td colspan="7" class="muted">没有符合条件的企业</td></tr>
            <% } else {
                for (Company c : companies) {
            %>
            <tr>
                <td><%= c.getCompanyId() %></td>
                <td><b><%= c.getCompanyName() %></b></td>
                <td><%= c.getCompanyArea() == null ? "—" : c.getCompanyArea() %></td>
                <td><%= c.getCompanySize() == null ? "—" : c.getCompanySize() %></td>
                <td><span class="tag <%= c.getCompanyState() == Dict.STATE_ENABLED ? "" : "off" %>"><%= Labels.companyStateLabel(c.getCompanyState()) %></span></td>
                <td><%= c.getCompanyViewnum() %></td>
                <td>
                    <a href="<%= ctx %>/manage/company.jsp?<%= listQuery %>&edit=<%= c.getCompanyId() %>">修改</a>
                    <a href="<%= ctx %>/firm?id=<%= c.getCompanyId() %>" target="_blank">前台</a>
                </td>
            </tr>
            <% } } %>
        </table>
    </div>
    <div class="pager">
        <a href="<%= ctx %>/manage/company.jsp?<%= listQuery %>&page=1">首页</a>
        <% if (curPage > 1) { %><a href="<%= ctx %>/manage/company.jsp?<%= listQuery %>&page=<%= curPage - 1 %>">上一页</a><% } %>
        <a class="on" href="<%= ctx %>/manage/company.jsp?<%= listQuery %>&page=<%= curPage %>"><%= curPage %></a>
        <% if (curPage < pageCount) { %><a href="<%= ctx %>/manage/company.jsp?<%= listQuery %>&page=<%= curPage + 1 %>">下一页</a><% } %>
        <a href="<%= ctx %>/manage/company.jsp?<%= listQuery %>&page=<%= pageCount %>">尾页</a>
    </div>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
