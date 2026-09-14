<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.common.Pics" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="com.qitoffer.dao.FavoriteDao" %>
<%@ page import="java.util.List" %>
<%
    String ctx = request.getContextPath();
    Job job = (Job) request.getAttribute("job");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    boolean faved = false;
    if (applicant != null && job != null) {
        try {
            faved = new FavoriteDao().exists(applicant.getApplicantId(), job.getJobId());
        } catch (Exception ignored) {
        }
    }
    String fav = request.getParameter("fav");
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page wide">
<% if ("1".equals(fav)) { %><p class="ok">已收藏该职位。</p><% }
   else if ("0".equals(fav)) { %><p class="ok">已取消收藏。</p><% } %>
<% if ("1".equals(request.getParameter("favErr"))) { %><p class="err">收藏失败，职位可能已下架。</p><% } %>
<% if (job == null) { %>
<div class="empty">职位不存在或已删除。<a href="<%= ctx %>/job/search">返回职位列表</a></div>
<% } else {
    List<String> points = Pics.highlights(job.getCompanyBrief(), job.getCompanyArea(), job.getCompanySize(), job.getCompanyType());
    int cid = job.getCompanyId();
%>
<div class="board">
    <a class="board-hero" href="<%= ctx %>/firm?id=<%= cid %>">
        <img class="board-bg" src="<%= Pics.jobCover(job.getJobCover(), cid, ctx) %>" alt=""
             onerror="this.onerror=null;this.src='<%= ctx %>/images/hero-1.jpg'">
        <div class="board-overlay">
            <img class="board-logo" src="<%= Pics.jobThumb(job.getJobThumb(), job.getJobId(), ctx) %>" alt="">
            <h2><%= job.getCompanyName() %></h2>
            <ul>
                <% for (String point : points) { %><li><%= point %></li><% } %>
            </ul>
            <p class="board-slogan"><%= Pics.slogan(job.getCompanyName(), job.getCompanyType()) %></p>
        </div>
    </a>
</div>
<div class="card">
    <h1><%= job.getJobName() %>
        <% if (job.getJobState() != Dict.JOB_ONLINE) { %>
        <span class="tag off"><%= Labels.jobStateLabel(job.getJobState()) %></span>
        <% } %>
    </h1>
    <p class="muted"><a href="<%= ctx %>/firm?id=<%= job.getCompanyId() %>"><%= job.getCompanyName() %></a>
        <% if (job.getCompanyType() != null) { %> · <%= job.getCompanyType() %><% } %>
        <% if (job.getCompanySize() != null) { %> · <%= job.getCompanySize() %><% } %>
    </p>
    <p>
        <span class="tag"><%= job.getJobSalary() %></span>
        <span class="tag"><%= job.getJobArea() %></span>
        <span class="tag off">招 <%= job.getJobHiringnum() %> 人</span>
    </p>
    <p class="muted">浏览 <%= job.getJobViewnum() %> 次
        <% if (job.getJobEndtime() != null && !job.getJobEndtime().isEmpty()) { %> · 截止日期 <%= job.getJobEndtime() %><% } %>
    </p>
    <p class="muted" style="white-space:pre-wrap"><%= job.getJobDesc() == null ? "" : job.getJobDesc() %></p>
    <div class="actions">
        <% if (applicant != null) { %>
        <% if (job.getJobState() == Dict.JOB_ONLINE) { %>
        <form method="post" action="<%= ctx %>/apply/add">
            <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
            <button class="primary inline" type="submit">立即投递</button>
        </form>
        <a class="btn-lite" href="<%= ctx %>/talk?jobId=<%= job.getJobId() %>">去谈谈</a>
        <% } else { %>
        <span class="tag off">职位已下架，暂不可投递</span>
        <% } %>
        <form method="post" action="<%= ctx %>/favorite/<%= faved ? "delete" : "add" %>">
            <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
            <button class="<%= faved ? "btn-danger" : "btn-lite" %>" type="submit"><%= faved ? "取消收藏" : "收藏职位" %></button>
        </form>
        <a class="btn-lite" href="<%= ctx %>/job/search">返回列表</a>
        <% } else { %>
        <a class="primary inline" href="<%= ctx %>/login">登录后投递</a>
        <a class="btn-lite" href="<%= ctx %>/login">去谈谈</a>
        <a class="btn-lite" href="<%= ctx %>/job/search">返回列表</a>
        <% } %>
    </div>
</div>
<% } %>
</main>
<jsp:include page="/common/footer.jsp"/>
