<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.common.Pics" %>
<%@ page import="com.qitoffer.dao.CompanyDao" %>
<%@ page import="com.qitoffer.dao.JobDao" %>
<%@ page import="com.qitoffer.entity.Company" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "职位列表 · 锐聘");
    request.setAttribute("navKey", "jobs");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String ctx = request.getContextPath();
    Company company = null;
    List<Job> jobs = new ArrayList<>();
    String dataErr = "";
    String kw = request.getParameter("kw") == null ? "" : request.getParameter("kw").trim();
    int state = -1;
    if ("1".equals(request.getParameter("state"))) {
        state = 1;
    } else if ("0".equals(request.getParameter("state"))) {
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
    int total = 0;
    if (backend != null) {
        try {
            company = new CompanyDao().findByUserId(backend.getUserId());
            if (company != null) {
                Integer stateOrNull = state >= 0 ? state : null;
                jobs = new JobDao().listByCompany(company.getCompanyId(), kw, stateOrNull, curPage, pageSize);
                total = new JobDao().countByCompany(company.getCompanyId(), kw, stateOrNull);
            }
        } catch (Exception e) {
            dataErr = "职位数据暂时无法加载。";
        }
    }
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
    if (curPage > pageCount) {
        curPage = pageCount;
    }
    String listQuery = "kw=" + URLEncoder.encode(kw, "UTF-8") + "&state=" + (state >= 0 ? state : "all");
    String msg = (String) session.getAttribute("jobMsg");
    if (msg != null) {
        session.removeAttribute("jobMsg");
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="crumb">位置：<a href="<%= ctx %>/company/dashboard">工作台</a> / <span class="now">职位列表</span></div>
<% if (msg != null) { %><p class="ok toast-ok"><%= msg %></p><% } %>
<% if (!dataErr.isEmpty()) { %><p class="err"><%= dataErr %></p><% } %>
<div class="sheet sheet-pro">
    <div class="sheet-bar">
        <div>
            <h2>职位列表</h2>
            <p class="muted"><%= company != null ? company.getCompanyName() : "尚未关联企业" %> · 共 <%= total %> 个职位</p>
        </div>
        <a class="primary inline" href="<%= ctx %>/company/job?action=add">发布职位</a>
    </div>
    <form class="sheet-filter filter-pro" method="get" action="<%= ctx %>/company/job.jsp">
        <div class="filter-field">
            <label>职位名称</label>
            <input class="input" name="kw" value="<%= kw %>" placeholder="输入职位名称">
        </div>
        <div class="filter-field">
            <label>招聘状态</label>
            <select class="input" name="state">
                <option value="all" <%= state < 0 ? "selected" : "" %>>全部</option>
                <option value="1" <%= state == 1 ? "selected" : "" %>>招聘中</option>
                <option value="0" <%= state == 0 ? "selected" : "" %>>已下架</option>
            </select>
        </div>
        <div class="filter-actions">
            <button class="primary inline" type="submit">查询</button>
            <a class="btn-lite" href="<%= ctx %>/company/job.jsp">重置</a>
        </div>
    </form>
    <div class="job-card-list">
        <% if (company == null) { %>
        <div class="empty-row">当前账号尚未关联企业。</div>
        <% } else if (jobs.isEmpty()) { %>
        <div class="empty-row">暂无符合条件的职位，点击右上角「发布职位」开始招聘。</div>
        <% } else {
            for (Job job : jobs) {
                String end = job.getJobEndtime();
                if (end != null && end.length() > 10) {
                    end = end.substring(0, 10);
                }
                String cover = Pics.jobCover(job.getJobCover(), company.getCompanyId(), ctx);
                String thumb = Pics.jobThumb(job.getJobThumb(), job.getJobId(), ctx);
        %>
        <article class="job-mcard">
            <a class="job-mcard-media" href="<%= ctx %>/job/detail?id=<%= job.getJobId() %>" target="_blank">
                <img src="<%= cover %>" alt="" onerror="this.onerror=null;this.src='<%= ctx %>/images/hero-1.jpg'">
                <img class="job-mcard-logo" src="<%= thumb %>" alt="">
            </a>
            <div class="job-mcard-body">
                <div class="job-mcard-top">
                    <h3><%= job.getJobName() %></h3>
                    <span class="tag <%= job.getJobState() == Dict.JOB_ONLINE ? "" : "off" %>"><%= Labels.jobStateLabel(job.getJobState()) %></span>
                </div>
                <ul class="job-mcard-meta">
                    <li><span>招聘</span><b><%= job.getJobHiringnum() %></b> 人</li>
                    <li><span>申请</span><b class="accent-text"><%= job.getApplyCount() %></b> 份</li>
                    <li><span>截止</span><b><%= end == null || end.isEmpty() ? "—" : end %></b></li>
                </ul>
                <div class="job-mcard-ops">
                    <a class="op-link" href="<%= ctx %>/company/job?action=edit&id=<%= job.getJobId() %>">修改</a>
                    <a class="op-link" href="<%= ctx %>/job/detail?id=<%= job.getJobId() %>" target="_blank">预览</a>
                    <form method="post" action="<%= ctx %>/company/job" onsubmit="return confirm('确定删除该职位？已有投递的职位不能删除。');">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="id" value="<%= job.getJobId() %>">
                        <button class="op-danger" type="submit">删除</button>
                    </form>
                </div>
            </div>
        </article>
        <%
            }
        } %>
    </div>
    <div class="sheet-foot">
        <span>共 <%= total %> 条，当前显示第 <%= curPage %> 页</span>
        <div class="pager">
            <a href="<%= ctx %>/company/job.jsp?<%= listQuery %>&page=1">首页</a>
            <% if (curPage > 1) { %><a href="<%= ctx %>/company/job.jsp?<%= listQuery %>&page=<%= curPage - 1 %>">上一页</a><% } else { %><span>上一页</span><% } %>
            <a class="on" href="<%= ctx %>/company/job.jsp?<%= listQuery %>&page=<%= curPage %>"><%= curPage %></a>
            <% if (curPage < pageCount) { %><a href="<%= ctx %>/company/job.jsp?<%= listQuery %>&page=<%= curPage + 1 %>">下一页</a><% } else { %><span>下一页</span><% } %>
            <a href="<%= ctx %>/company/job.jsp?<%= listQuery %>&page=<%= pageCount %>">尾页</a>
        </div>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
