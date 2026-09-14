<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Pics" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Company" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    Company company = (Company) request.getAttribute("company");
    @SuppressWarnings("unchecked")
    List<Job> jobs = (List<Job>) request.getAttribute("jobs");
    if (jobs == null) {
        jobs = Collections.emptyList();
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page wide">
<% if (company == null) { %>
<div class="empty">企业不存在或已下线。<a href="<%= ctx %>/job/search">返回职位列表</a></div>
<% } else {
    int cid = company.getCompanyId();
    Job heroJob = jobs.isEmpty() ? null : jobs.get(0);
    boolean hasPromo = Pics.hasStoredPic(company.getCompanyPic());
    String heroSrc = hasPromo
            ? Pics.companyPromo(company.getCompanyPic(), cid, ctx)
            : (heroJob == null ? Pics.banner(cid, ctx) : Pics.jobCover(heroJob.getJobCover(), cid, ctx));
    String logoSrc = heroJob == null
            ? Pics.logo(cid, ctx)
            : Pics.jobThumb(heroJob.getJobThumb(), heroJob.getJobId(), ctx);
    List<String> points = Pics.highlights(company.getCompanyBrief(), company.getCompanyArea(), company.getCompanySize(), company.getCompanyType());
%>
<div class="board">
    <div class="board-hero">
        <img class="board-bg" src="<%= heroSrc %>" alt=""
             onerror="this.onerror=null;this.src='<%= ctx %>/images/hero-1.jpg'">
        <div class="board-overlay">
            <img class="board-logo" src="<%= logoSrc %>" alt="">
            <h2><%= company.getCompanyName() %></h2>
            <ul>
                <% for (String point : points) { %><li><%= point %></li><% } %>
            </ul>
            <p class="board-slogan"><%= Pics.slogan(company.getCompanyName(), company.getCompanyType()) %></p>
        </div>
    </div>
</div>

<div class="card">
    <div class="sec-head">
        <h2>企业简介</h2>
        <span class="muted"><%= company.getCompanyViewnum() %> 浏览</span>
    </div>
    <div class="firm-meta">
        <span>所在地：<%= company.getCompanyArea() == null ? "—" : company.getCompanyArea() %></span>
        <span>规模：<%= company.getCompanySize() == null ? "—" : company.getCompanySize() %></span>
        <span>性质：<%= company.getCompanyType() == null ? "—" : company.getCompanyType() %></span>
    </div>
    <div class="firm-brief"><%= company.getCompanyBrief() == null || company.getCompanyBrief().isEmpty()
            ? "暂无企业简介。" : company.getCompanyBrief() %></div>
    <% if (hasPromo) { %>
    <div class="firm-promo">
        <h3>企业宣传</h3>
        <img src="<%= Pics.companyPromo(company.getCompanyPic(), cid, ctx) %>" alt="<%= company.getCompanyName() %> 宣传图"
             onerror="this.onerror=null;this.src='<%= ctx %>/images/hero-1.jpg'">
    </div>
    <% } %>
</div>

<% if (!jobs.isEmpty()) { %>
<div class="card">
    <div class="sec-head"><h2>在招职位</h2></div>
    <% for (Job job : jobs) { %>
    <div class="list-row">
        <div>
            <h2><a href="<%= ctx %>/job/detail?id=<%= job.getJobId() %>"><%= job.getJobName() %></a></h2>
            <p class="muted"><%= job.getJobSalary() %> · <%= job.getJobArea() %>
                <% if (job.getJobEndtime() != null && !job.getJobEndtime().isEmpty()) { %> · 到期 <%= job.getJobEndtime() %><% } %>
            </p>
        </div>
        <div class="job-ops">
            <a class="primary inline" href="<%= ctx %>/job/detail?id=<%= job.getJobId() %>">我要申请</a>
            <a class="btn-lite" href="<%= applicant == null ? ctx + "/login" : ctx + "/talk?jobId=" + job.getJobId() %>">去谈谈</a>
        </div>
    </div>
    <% } %>
</div>
<% } %>
<% } %>
</main>
<jsp:include page="/common/footer.jsp"/>
