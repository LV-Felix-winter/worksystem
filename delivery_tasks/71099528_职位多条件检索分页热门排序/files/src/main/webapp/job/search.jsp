<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="com.qitoffer.dao.FavoriteDao" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Job> jobs = (List<Job>) request.getAttribute("jobs");
    if (jobs == null) {
        jobs = Collections.emptyList();
    }
    int total = request.getAttribute("total") instanceof Integer ? (Integer) request.getAttribute("total") : 0;
    int page = request.getAttribute("page") instanceof Integer ? (Integer) request.getAttribute("page") : 1;
    int pageCount = request.getAttribute("pageCount") instanceof Integer ? (Integer) request.getAttribute("pageCount") : 1;
    int pageSize = request.getAttribute("pageSize") instanceof Integer ? (Integer) request.getAttribute("pageSize") : 6;
    String keyword = request.getAttribute("keyword") != null ? (String) request.getAttribute("keyword") : "";
    String area = request.getAttribute("area") != null ? (String) request.getAttribute("area") : "";
    int salaryMin = request.getAttribute("salaryMin") instanceof Integer ? (Integer) request.getAttribute("salaryMin") : 0;
    int salaryMax = request.getAttribute("salaryMax") instanceof Integer ? (Integer) request.getAttribute("salaryMax") : 0;
    boolean popular = Boolean.TRUE.equals(request.getAttribute("popular"));
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    Set<Integer> favIds = new HashSet<>();
    if (applicant != null) {
        try {
            favIds.addAll(new FavoriteDao().jobIdsByApplicant(applicant.getApplicantId()));
        } catch (Exception ignored) {
        }
    }
    String baseQuery = "keyword=" + URLEncoder.encode(keyword, "UTF-8")
            + "&area=" + URLEncoder.encode(area, "UTF-8")
            + "&salaryMin=" + salaryMin + "&salaryMax=" + salaryMax
            + "&sort=" + (popular ? "hot" : "new");
    String encErr = request.getParameter("err");
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<div class="wrap">
<style>
.search-hero{background:linear-gradient(135deg,#1a1a2e,#16213e);border-radius:14px;color:#fff;padding:26px 28px;margin-bottom:18px}
.search-hero h1{font-size:20px;margin-bottom:6px}
.search-hero p{font-size:12px;color:rgba(255,255,255,.6)}
.filter-card{background:#fff;border-radius:12px;padding:20px 24px;box-shadow:0 2px 12px rgba(0,0,0,.06);margin-bottom:18px}
.filter-card h2{font-size:15px;font-weight:600;margin-bottom:14px}
.filter-row{display:flex;gap:10px;flex-wrap:wrap;align-items:flex-end}
.f{display:flex;flex-direction:column;gap:4px}
.f label{font-size:12px;color:#888}
.f input,.f select{height:36px;padding:0 10px;border:1px solid #ddd;border-radius:8px;font-size:14px;outline:none}
.f input.w{width:220px}
.f input.num{width:90px}
.btn{height:36px;padding:0 18px;border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer}
.btn-p{background:linear-gradient(135deg,#4facfe,#00f2fe);color:#fff}
.btn-o{background:#fff;color:#4facfe;border:1px solid #4facfe}
.res-header{display:flex;justify-content:space-between;align-items:center;margin:4px 2px 12px}
.res-count{font-size:13px;color:#888}
.job-item{background:#fff;border-radius:12px;padding:18px 22px;margin-bottom:12px;box-shadow:0 2px 8px rgba(0,0,0,.05);display:flex;justify-content:space-between;align-items:flex-start;gap:16px;border:1px solid transparent;transition:border-color .2s}
.job-item:hover{border-color:#4facfe}
.j-name{font-size:16px;font-weight:600;margin-bottom:4px}
.j-name a{color:#1a1a2e;text-decoration:none}
.j-company{font-size:13px;color:#666;margin-bottom:8px}
.j-desc{font-size:12px;color:#999;line-height:1.6;margin-bottom:10px}
.tag{display:inline-block;padding:2px 10px;border-radius:20px;font-size:12px;font-weight:500;margin-right:6px}
.t-s{background:#e8f8ef;color:#27ae60}
.t-l{background:#eef4ff;color:#4facfe}
.t-h{background:#fff5f5;color:#ff6b6b}
.ops{display:flex;flex-direction:column;gap:8px;min-width:130px}
.ops form{display:flex;gap:8px;justify-content:flex-end}
.btn-sm{height:32px;padding:0 12px;font-size:12px}
.btn-collect{background:#fff;border:1px solid #ddd;color:#888}
.btn-collect.on{border-color:#ff6b6b;color:#ff6b6b;background:#fff5f5}
.btn-apply{background:linear-gradient(135deg,#4facfe,#00f2fe);border:none;color:#fff}
.empty{text-align:center;padding:48px;color:#aaa;background:#fff;border-radius:12px}
.pager{display:flex;gap:8px;justify-content:center;align-items:center;margin:18px 0}
.pager a,.pager span{min-width:36px;height:36px;padding:0 12px;display:inline-flex;align-items:center;justify-content:center;border-radius:8px;background:#fff;font-size:13px;box-shadow:0 2px 8px rgba(0,0,0,.05)}
.pager a.cur{background:linear-gradient(135deg,#4facfe,#00f2fe);color:#fff}
.pager .hint{font-size:12px;color:#888}
</style>

<div class="search-hero">
    <h1>职位检索</h1>
    <p>关键词、地区、薪资最多可叠加 4 个条件；「热门」排序按职位浏览量（job_viewnum）</p>
</div>

<% if ("db".equals(encErr)) { %>
<div class="empty">数据库连接失败，请检查 MySQL 服务与 q_itoffer 库（见 README 本地运行说明）。</div>
<% } else { %>

<form class="filter-card" method="get" action="<%= ctx %>/job/search">
    <h2>筛选条件（#71099528 多条件组合）</h2>
    <div class="filter-row">
        <div class="f"><label>关键词（职位/企业）</label>
            <input class="w" name="keyword" value="<%= keyword %>" placeholder="如 Java、青软"></div>
        <div class="f"><label>工作地区</label>
            <input class="w" name="area" value="<%= area %>" placeholder="如 青岛"></div>
        <div class="f"><label>薪资下限（k）</label>
            <input class="num" name="salaryMin" value="<%= salaryMin > 0 ? salaryMin : "" %>" placeholder="如 6"></div>
        <div class="f"><label>薪资上限（k）</label>
            <input class="num" name="salaryMax" value="<%= salaryMax > 0 ? salaryMax : "" %>" placeholder="如 20"></div>
        <div class="f"><label>排序</label>
            <select name="sort">
                <option value="new" <%= popular ? "" : "selected" %>>最新发布</option>
                <option value="hot" <%= popular ? "selected" : "" %>>热门（按浏览量）</option>
            </select></div>
        <button class="btn btn-p" type="submit">🔍 搜索</button>
        <a class="btn btn-o" href="<%= ctx %>/job/search">重置</a>
    </div>
</form>

<div class="res-header">
    <span class="res-count">共 <%= total %> 个职位 · 第 <%= page %> / <%= pageCount %> 页（每页 <%= pageSize %>）</span>
    <span class="res-count">条件：关键词“<%= keyword %>” / 地区“<%= area %>” / <%= salaryMin > 0 ? "≥" + salaryMin + "k" : "" %><%= salaryMax > 0 ? " ≤" + salaryMax + "k" : "" %></span>
</div>

<% if (jobs.isEmpty()) { %>
<div class="empty">暂无匹配职位，请调整筛选条件</div>
<% } else { %>
<% for (Job job : jobs) {
    boolean faved = favIds.contains(job.getJobId()); %>
<div class="job-item">
    <div>
        <div class="j-name"><a href="<%= ctx %>/job/detail?id=<%= job.getJobId() %>"><%= job.getJobName() %></a></div>
        <div class="j-company"><%= job.getCompanyName() %> · 浏览 <%= job.getJobViewnum() %> 次</div>
        <div class="j-desc"><%= job.getJobDesc() %></div>
        <span class="tag t-s"><%= job.getJobSalary() %></span>
        <span class="tag t-l"><%= job.getJobArea() %></span>
        <span class="tag t-h">招 <%= job.getJobHiringnum() %> 人</span>
    </div>
    <div class="ops">
        <a class="btn btn-sm btn-apply" href="<%= ctx %>/job/detail?id=<%= job.getJobId() %>">查看详情 / 投递</a>
        <% if (applicant != null) { %>
        <form method="post" action="<%= ctx %>/favorite/<%= faved ? "delete" : "add" %>">
            <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
            <input type="hidden" name="back" value="list">
            <button class="btn btn-sm btn-collect <%= faved ? "on" : "" %>" type="submit"><%= faved ? "★ 已收藏" : "☆ 收藏职位" %></button>
        </form>
        <% } else { %>
        <a class="btn btn-sm btn-collect" href="<%= ctx %>/login">登录后可收藏</a>
        <% } %>
    </div>
</div>
<% } %>
<% } %>

<% if (pageCount > 1) { %>
<div class="pager">
    <% if (page > 1) { %>
    <a href="<%= ctx %>/job/search?<%= baseQuery %>&page=<%= page - 1 %>">‹ 上一页</a>
    <% } else { %><span>‹ 上一页</span><% } %>
    <span class="hint">第 <%= page %> / <%= pageCount %> 页</span>
    <% if (page < pageCount) { %>
    <a href="<%= ctx %>/job/search?<%= baseQuery %>&page=<%= page + 1 %>">下一页 ›</a>
    <% } else { %><span>下一页 ›</span><% } %>
</div>
<% } %>

<% } %>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
