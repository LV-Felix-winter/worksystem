<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.dao.JobDao" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "职位管理 · 锐聘");
    request.setAttribute("navKey", "jobs");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String ctx = request.getContextPath();
    String kw = request.getParameter("kw") == null ? "" : request.getParameter("kw").trim();
    String area = request.getParameter("area") == null ? "" : request.getParameter("area").trim();
    int state = -1;
    String stateParam = request.getParameter("state");
    if ("1".equals(stateParam)) {
        state = 1;
    } else if ("0".equals(stateParam)) {
        state = 0;
    }
    int page = 1;
    try {
        page = Integer.parseInt(request.getParameter("page") == null ? "1" : request.getParameter("page"));
    } catch (NumberFormatException ignored) {
    }
    if (page < 1) {
        page = 1;
    }
    final int pageSize = 10;
    boolean popular = "hot".equals(request.getParameter("sort"));
    int detailId = 0;
    try {
        detailId = Integer.parseInt(request.getParameter("detail") == null ? "0" : request.getParameter("detail"));
    } catch (NumberFormatException ignored) {
    }
    JobDao dao = new JobDao();
    List<Job> jobs = new ArrayList<>();
    int total = 0;
    Job detail = null;
    String dataErr = "";
    Integer stateOrNull = state >= 0 ? state : null;
    try {
        if (detailId > 0) {
            detail = dao.findById(detailId, false);
        } else {
            jobs = dao.search(kw, area, 0, 0, popular, page, pageSize, true, stateOrNull);
            total = dao.count(kw, area, 0, 0, true, stateOrNull);
        }
    } catch (Exception e) {
        dataErr = "数据库查询失败：请确认 MySQL 服务与 q_itoffer 库（见 README）。";
    }
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
    if (page > pageCount && detailId == 0) {
        page = pageCount;
    }
    String listQuery = "kw=" + URLEncoder.encode(kw, "UTF-8") + "&area=" + URLEncoder.encode(area, "UTF-8")
            + "&state=" + (state >= 0 ? state : "all") + "&sort=" + (popular ? "hot" : "new");
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="card">
    <h1>职位管理（#71098793/#71098794 条件查询与详情）</h1>
    <p class="muted">按职位/企业关键词、地区、状态组合筛选，支持分页与热门（浏览量）排序；后台可见下架职位。</p>
    <% if (!dataErr.isEmpty()) { %><p class="err"><%= dataErr %></p><% } %>
    <% if (detailId > 0) { %>
    <div style="margin-bottom:12px"><a class="btn-lite" href="<%= ctx %>/manage/job.jsp">← 返回职位列表</a></div>
    <% if (detail == null) { %>
    <p class="err">职位 #<%= detailId %> 不存在。</p>
    <% } else { %>
    <table class="data" style="border-collapse:collapse;width:100%">
        <tr><th style="text-align:left">职位</th><td><%= detail.getJobName() %></td></tr>
        <tr><th style="text-align:left">企业</th><td><%= detail.getCompanyName() %>（ID <%= detail.getCompanyId() %>）</td></tr>
        <tr><th style="text-align:left">薪资 / 地区</th><td><%= detail.getJobSalary() %> / <%= detail.getJobArea() %></td></tr>
        <tr><th style="text-align:left">招聘人数 / 截止</th><td><%= detail.getJobHiringnum() %> 人 / <%= detail.getJobEndtime() == null ? "-" : detail.getJobEndtime() %></td></tr>
        <tr><th style="text-align:left">状态</th><td><%= Labels.jobStateLabel(detail.getJobState()) %></td></tr>
        <tr><th style="text-align:left">浏览量（热门排序口径）</th><td><%= detail.getJobViewnum() %></td></tr>
        <tr><th style="text-align:left">职位描述</th><td><%= detail.getJobDesc() %></td></tr>
    </table>
    <% } %>
    <% } else { %>
    <form method="get" action="<%= ctx %>/manage/job.jsp" style="display:flex;gap:8px;flex-wrap:wrap;margin:12px 0">
        <input name="kw" value="<%= kw %>" placeholder="职位 / 企业名称" style="height:34px;border:1px solid #ddd;border-radius:8px;padding:0 10px;min-width:180px">
        <input name="area" value="<%= area %>" placeholder="地区" style="height:34px;border:1px solid #ddd;border-radius:8px;padding:0 10px;width:120px">
        <select name="state" style="height:34px;border:1px solid #ddd;border-radius:8px;padding:0 8px">
            <option value="all" <%= state < 0 ? "selected" : "" %>>全部状态</option>
            <option value="1" <%= state == 1 ? "selected" : "" %>>招聘中</option>
            <option value="0" <%= state == 0 ? "selected" : "" %>>已下架</option>
        </select>
        <select name="sort" style="height:34px;border:1px solid #ddd;border-radius:8px;padding:0 8px">
            <option value="new" <%= popular ? "" : "selected" %>>最新发布</option>
            <option value="hot" <%= popular ? "selected" : "" %>>热门（浏览量）</option>
        </select>
        <button class="btn-lite" type="submit">查询</button>
        <a class="btn-lite" href="<%= ctx %>/manage/job.jsp">重置</a>
        <span class="muted">共 <%= total %> 条</span>
    </form>
    <table class="data" style="width:100%;border-collapse:collapse">
        <tr>
            <th>ID</th><th>职位</th><th>企业</th><th>薪资</th><th>地区</th><th>状态</th><th>浏览量</th><th>操作</th>
        </tr>
        <% if (jobs.isEmpty()) { %>
        <tr><td colspan="8" class="muted">没有符合条件的职位</td></tr>
        <% } else {
            for (Job job : jobs) {
        %>
        <tr>
            <td><%= job.getJobId() %></td>
            <td><b><%= job.getJobName() %></b></td>
            <td><%= job.getCompanyName() %></td>
            <td><%= job.getJobSalary() %></td>
            <td><%= job.getJobArea() %></td>
            <td><span class="<%= job.getJobState() == Dict.JOB_ONLINE ? "tag t-s" : "tag t-off" %>" style="padding:2px 10px;border-radius:20px;font-size:12px"><%= Labels.jobStateLabel(job.getJobState()) %></span></td>
            <td><%= job.getJobViewnum() %></td>
            <td><a href="<%= ctx %>/manage/job.jsp?<%= listQuery %>&detail=<%= job.getJobId() %>" style="display:inline-block">详情</a></td>
        </tr>
        <% }
            } %>
    </table>
    <% if (pageCount > 1) { %>
    <div style="display:flex;gap:8px;align-items:center;margin-top:12px">
        <% if (page > 1) { %><a class="btn-lite" href="<%= ctx %>/manage/job.jsp?<%= listQuery %>&page=<%= page - 1 %>">‹ 上一页</a><% } %>
        <span class="muted">第 <%= page %> / <%= pageCount %> 页</span>
        <% if (page < pageCount) { %><a class="btn-lite" href="<%= ctx %>/manage/job.jsp?<%= listQuery %>&page=<%= page + 1 %>">下一页 ›</a><% } %>
    </div>
    <% } %>
    <% } %>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
