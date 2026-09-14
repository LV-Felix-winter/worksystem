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
    int curPage = 1;
    try {
        curPage = Integer.parseInt(request.getParameter("page") == null ? "1" : request.getParameter("page"));
    } catch (NumberFormatException ignored) {
    }
    if (curPage < 1) {
        curPage = 1;
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
            jobs = dao.search(kw, area, 0, 0, popular, curPage, pageSize, true, stateOrNull);
            total = dao.count(kw, area, 0, 0, true, stateOrNull);
        }
    } catch (Exception e) {
        dataErr = "数据库查询失败：请确认 MySQL 服务与 q_itoffer 库（见 README）。";
    }
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
    if (curPage > pageCount && detailId == 0) {
        curPage = pageCount;
    }
    String listQuery = "kw=" + URLEncoder.encode(kw, "UTF-8") + "&area=" + URLEncoder.encode(area, "UTF-8")
            + "&state=" + (state >= 0 ? state : "all") + "&sort=" + (popular ? "hot" : "new");
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
            <h1>职位管理</h1>
            <p class="muted">按职位或企业关键词、地区、状态筛选，支持分页、详情和上下架。</p>
        </div>
    </div>
    <div class="manage-body">
    <% if (msg != null) { %><p class="ok toast-ok"><%= msg %></p><% } %>
    <% if (!dataErr.isEmpty()) { %><p class="err"><%= dataErr %></p><% } %>
    <% if (detailId > 0) { %>
    <div style="margin-bottom:12px"><a class="btn-lite" href="<%= ctx %>/manage/job.jsp">返回职位列表</a></div>
    <% if (detail == null) { %>
    <p class="err">职位不存在。</p>
    <% } else { %>
    <table class="kv-pro">
        <tr><th>职位</th><td><%= detail.getJobName() %></td></tr>
        <tr><th>企业</th><td><%= detail.getCompanyName() %></td></tr>
        <tr><th>薪资 / 地区</th><td><%= detail.getJobSalary() %> / <%= detail.getJobArea() %></td></tr>
        <tr><th>招聘人数 / 截止</th><td><%= detail.getJobHiringnum() %> 人 / <%= detail.getJobEndtime() == null ? "-" : detail.getJobEndtime() %></td></tr>
        <tr><th>状态</th><td><span class="tag"><%= Labels.jobStateLabel(detail.getJobState()) %></span></td></tr>
        <tr><th>浏览量</th><td><%= detail.getJobViewnum() %></td></tr>
        <tr><th>职位描述</th><td><%= detail.getJobDesc() %></td></tr>
    </table>
    <% } %>
    <% } else { %>
    <form class="toolbar" method="get" action="<%= ctx %>/manage/job.jsp">
        <input class="input" name="kw" value="<%= kw %>" placeholder="职位 / 企业名称">
        <input class="input js-region" name="area" value="<%= area %>" placeholder="选择省 / 市 / 区县" style="width:220px" readonly>
        <select class="input" name="state">
            <option value="all" <%= state < 0 ? "selected" : "" %>>全部状态</option>
            <option value="1" <%= state == 1 ? "selected" : "" %>>招聘中</option>
            <option value="0" <%= state == 0 ? "selected" : "" %>>已下架</option>
        </select>
        <select class="input" name="sort">
            <option value="new" <%= popular ? "" : "selected" %>>最新发布</option>
            <option value="hot" <%= popular ? "selected" : "" %>>热门浏览</option>
        </select>
        <button class="primary inline" type="submit">查询</button>
        <a class="btn-lite" href="<%= ctx %>/manage/job.jsp">重置</a>
        <span class="muted">共 <%= total %> 条</span>
    </form>
    <div class="table-wrap">
    <table class="data">
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
            <td><span class="tag <%= job.getJobState() == Dict.JOB_ONLINE ? "" : "off" %>"><%= Labels.jobStateLabel(job.getJobState()) %></span></td>
            <td><%= job.getJobViewnum() %></td>
            <td class="ops ops-pro">
                <a class="op-link" href="<%= ctx %>/manage/job.jsp?<%= listQuery %>&detail=<%= job.getJobId() %>">详情</a>
                <form method="post" action="<%= ctx %>/manage/job" style="display:inline;margin:0">
                    <input type="hidden" name="id" value="<%= job.getJobId() %>">
                    <input type="hidden" name="state" value="<%= job.getJobState() == Dict.JOB_ONLINE ? Dict.JOB_OFFLINE : Dict.JOB_ONLINE %>">
                    <button class="btn-lite" type="submit" style="height:28px;padding:0 10px">
                        <%= job.getJobState() == Dict.JOB_ONLINE ? "下架" : "上架" %>
                    </button>
                </form>
            </td>
        </tr>
        <% }
            } %>
    </table>
    </div>
    <% if (pageCount > 1) { %>
    <div class="pager">
        <% if (curPage > 1) { %><a href="<%= ctx %>/manage/job.jsp?<%= listQuery %>&page=<%= curPage - 1 %>">上一页</a><% } %>
        <span>第 <%= curPage %> / <%= pageCount %> 页</span>
        <% if (curPage < pageCount) { %><a href="<%= ctx %>/manage/job.jsp?<%= listQuery %>&page=<%= curPage + 1 %>">下一页</a><% } %>
    </div>
    <% } %>
    <% } %>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
