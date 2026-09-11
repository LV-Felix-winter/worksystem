<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="com.qitoffer.dao.FavoriteDao" %>
<%
    String ctx = request.getContextPath();
    Job job = (Job) request.getAttribute("job");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    boolean faved = false;
    String favMsg = request.getParameter("fav");
    if (applicant != null && job != null) {
        try {
            faved = new FavoriteDao().exists(applicant.getApplicantId(), job.getJobId());
        } catch (Exception ignored) {
        }
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<div class="wrap">
<style>
.jd{background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,.06);padding:26px 28px;margin-bottom:16px}
.jd h1{font-size:22px;margin-bottom:6px}
.jd .co{font-size:14px;color:#666;margin-bottom:14px}
.tag{display:inline-block;padding:3px 12px;border-radius:20px;font-size:13px;font-weight:500;margin-right:8px}
.t-s{background:#e8f8ef;color:#27ae60}.t-l{background:#eef4ff;color:#4facfe}.t-h{background:#fff5f5;color:#ff6b6b}
.t-off{background:#f0f0f0;color:#999}
.meta{display:flex;gap:18px;flex-wrap:wrap;font-size:13px;color:#888;margin:12px 0}
.desc{font-size:14px;line-height:1.8;color:#444;white-space:pre-wrap;border-top:1px solid #f0f0f0;padding-top:14px;margin-top:14px}
.ops{display:flex;gap:10px;margin-top:18px;flex-wrap:wrap}
.ops form{display:flex}
.btn{height:40px;padding:0 22px;border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center}
.btn-apply{background:linear-gradient(135deg,#4facfe,#00f2fe);color:#fff}
.btn-collect{background:#fff;border:1px solid #ddd;color:#888}
.btn-collect.on{border-color:#ff6b6b;color:#ff6b6b;background:#fff5f5}
.msg{font-size:13px;padding:10px 14px;border-radius:8px;margin-bottom:14px}
.msg.ok{background:#e8f8ef;color:#27ae60}.msg.bad{background:#fff5f5;color:#ff6b6b}
.empty{text-align:center;padding:48px;color:#aaa;background:#fff;border-radius:12px}
</style>
<% if (request.getParameter("fav") != null) {
    String fv = request.getParameter("fav");
    if ("1".equals(fv)) { %><div class="msg ok">已收藏职位，可在「收藏职位」页管理。</div><% }
    else if ("0".equals(fv)) { %><div class="msg ok">已取消收藏。</div><% }
} %>
<% if ("1".equals(request.getParameter("favErr"))) { %><div class="msg bad">收藏操作失败（职位可能已下架或数据库异常）。</div><% } %>
<% if (job == null) { %>
<div class="empty">职位不存在或已删除。<a href="<%= ctx %>/job/search">返回检索</a></div>
<% } else { %>
<div class="jd">
    <h1><%= job.getJobName() %><% if (job.getJobState() != Dict.JOB_ONLINE) { %> <span class="tag t-off"><%= Labels.jobStateLabel(job.getJobState()) %></span><% } %></h1>
    <div class="co"><%= job.getCompanyName() %><% if (job.getCompanyType() != null) { %> · <%= job.getCompanyType() %><% } %><% if (job.getCompanySize() != null) { %> · <%= job.getCompanySize() %><% } %></div>
    <span class="tag t-s"><%= job.getJobSalary() %></span>
    <span class="tag t-l"><%= job.getJobArea() %></span>
    <span class="tag t-h">招 <%= job.getJobHiringnum() %> 人</span>
    <div class="meta">
        <span>浏览 <%= job.getJobViewnum() %> 次</span>
        <% if (job.getJobEndtime() != null && !job.getJobEndtime().isEmpty()) { %><span>截止日期 <%= job.getJobEndtime() %></span><% } %>
    </div>
    <div class="desc"><%= job.getJobDesc() %></div>
    <div class="ops">
        <% if (applicant != null) { %>
        <% if (job.getJobState() == Dict.JOB_ONLINE) { %>
        <form method="post" action="<%= ctx %>/apply/add">
            <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
            <button class="btn btn-apply" type="submit">立即投递</button>
        </form>
        <% } else { %><span class="tag t-off">职位已下架，暂不可投递</span><% } %>
        <form method="post" action="<%= ctx %>/favorite/<%= faved ? "delete" : "add" %>">
            <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
            <button class="btn btn-collect <%= faved ? "on" : "" %>" type="submit"><%= faved ? "★ 已收藏" : "☆ 收藏职位" %></button>
        </form>
        <a class="btn" style="background:#f0f0f0;color:#666" href="<%= ctx %>/favorite/list">我的收藏</a>
        <% } else { %>
        <a class="btn btn-apply" href="<%= ctx %>/login">登录后即可投递 / 收藏</a>
        <% } %>
    </div>
</div>
<% } %>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
