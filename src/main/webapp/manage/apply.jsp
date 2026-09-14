<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.dao.ApplyDao" %>
<%@ page import="com.qitoffer.entity.Apply" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "职位申请查询 · 锐聘");
    request.setAttribute("navKey", "applies");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String ctx = request.getContextPath();
    String kw = request.getParameter("kw") == null ? "" : request.getParameter("kw").trim();
    Integer state = null;
    String stateParam = request.getParameter("state");
    if (stateParam != null && !"all".equals(stateParam) && !stateParam.isEmpty()) {
        try {
            state = Integer.parseInt(stateParam);
        } catch (NumberFormatException ignored) {
        }
    }
    int curPage = 1;
    try {
        curPage = Integer.parseInt(request.getParameter("page") == null ? "1" : request.getParameter("page"));
    } catch (NumberFormatException ignored) {
    }
    if (curPage < 1) {
        curPage = 1;
    }
    final int pageSize = 10;
    ApplyDao dao = new ApplyDao();
    List<Apply> applies = new ArrayList<>();
    int total = 0;
    String dataErr = "";
    try {
        applies = dao.listPageAdmin(kw, state, curPage, pageSize);
        total = dao.countPageAdmin(kw, state);
    } catch (Exception e) {
        dataErr = "申请数据加载失败。";
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
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="manage-sheet">
    <div class="sheet-bar">
        <div>
            <h1>职位申请查询</h1>
            <p class="muted">全站投递记录查询，可调整处理状态。</p>
        </div>
    </div>
    <div class="manage-body">
    <% if (msg != null) { %><p class="ok toast-ok"><%= msg %></p><% } %>
    <% if (!dataErr.isEmpty()) { %><p class="err"><%= dataErr %></p><% } %>
    <form class="toolbar" method="get" action="<%= ctx %>/manage/apply.jsp">
        <input class="input" name="kw" value="<%= kw %>" placeholder="职位 / 企业 / 求职者">
        <select class="input" name="state">
            <option value="all" <%= state == null ? "selected" : "" %>>全部状态</option>
            <option value="1" <%= state != null && state == Dict.APPLY_PENDING ? "selected" : "" %>>待处理</option>
            <option value="2" <%= state != null && state == Dict.APPLY_VIEWED ? "selected" : "" %>>已查看</option>
            <option value="3" <%= state != null && state == Dict.APPLY_INTERVIEW ? "selected" : "" %>>已面试</option>
            <option value="0" <%= state != null && state == Dict.APPLY_REJECTED ? "selected" : "" %>>已拒绝</option>
        </select>
        <button class="primary inline" type="submit">查询</button>
        <a class="btn-lite" href="<%= ctx %>/manage/apply.jsp">重置</a>
        <span class="muted">共 <%= total %> 条</span>
    </form>
    <div class="table-wrap">
        <table class="data">
            <tr>
                <th>ID</th><th>求职者</th><th>职位</th><th>企业</th><th>投递时间</th><th>状态</th><th>操作</th>
            </tr>
            <% if (applies.isEmpty()) { %>
            <tr><td colspan="7" class="muted">没有符合条件的申请</td></tr>
            <% } else {
                for (Apply a : applies) {
                    String when = a.getApplyDate() == null ? "—" : fmt.format(a.getApplyDate());
            %>
            <tr>
                <td><%= a.getApplyId() %></td>
                <td><b><%= a.getResumeRealname() == null ? "—" : a.getResumeRealname() %></b></td>
                <td><%= a.getJobName() %></td>
                <td><%= a.getCompanyName() %></td>
                <td><%= when %></td>
                <td><span class="tag"><%= Labels.applyStateLabel(a.getApplyState()) %></span></td>
                <td>
                    <form method="post" action="<%= ctx %>/manage/apply" style="display:inline-flex;gap:6px;align-items:center;margin:0">
                        <input type="hidden" name="id" value="<%= a.getApplyId() %>">
                        <input type="hidden" name="kw" value="<%= kw %>">
                        <input type="hidden" name="qstate" value="<%= state == null ? "all" : state %>">
                        <select class="input" name="state" style="height:28px;min-width:96px">
                            <option value="1" <%= a.getApplyState() == Dict.APPLY_PENDING ? "selected" : "" %>>待处理</option>
                            <option value="2" <%= a.getApplyState() == Dict.APPLY_VIEWED ? "selected" : "" %>>已查看</option>
                            <option value="3" <%= a.getApplyState() == Dict.APPLY_INTERVIEW ? "selected" : "" %>>已面试</option>
                            <option value="0" <%= a.getApplyState() == Dict.APPLY_REJECTED ? "selected" : "" %>>已拒绝</option>
                        </select>
                        <button class="btn-lite" type="submit" style="height:28px;padding:0 10px">更新</button>
                    </form>
                </td>
            </tr>
            <% } } %>
        </table>
    </div>
    <div class="pager">
        <a href="<%= ctx %>/manage/apply.jsp?<%= listQuery %>&page=1">首页</a>
        <% if (curPage > 1) { %><a href="<%= ctx %>/manage/apply.jsp?<%= listQuery %>&page=<%= curPage - 1 %>">上一页</a><% } %>
        <a class="on" href="<%= ctx %>/manage/apply.jsp?<%= listQuery %>&page=<%= curPage %>"><%= curPage %></a>
        <% if (curPage < pageCount) { %><a href="<%= ctx %>/manage/apply.jsp?<%= listQuery %>&page=<%= curPage + 1 %>">下一页</a><% } %>
        <a href="<%= ctx %>/manage/apply.jsp?<%= listQuery %>&page=<%= pageCount %>">尾页</a>
    </div>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
