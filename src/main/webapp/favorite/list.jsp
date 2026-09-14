<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.entity.Favorite" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Favorite> favorites = (List<Favorite>) request.getAttribute("favorites");
    if (favorites == null) {
        favorites = new ArrayList<>();
    }
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    request.setAttribute("resumeTab", "fav");
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page wide">
<jsp:include page="/common/resume-tabs.jsp"/>
<div class="page-head">
    <div>
        <h1>收藏职位</h1>
        <p class="muted">已收藏的在招职位可从这里进入详情并投递。</p>
    </div>
    <a class="primary inline" href="<%= ctx %>/job/search">去找工作</a>
</div>
<% if (favorites.isEmpty()) { %>
<div class="empty">还没有收藏职位。<a href="<%= ctx %>/job/search">去职位列表看看</a></div>
<% } else {
    for (Favorite f : favorites) { %>
<div class="list-row">
    <div>
        <h2><a href="<%= ctx %>/job/detail?id=<%= f.getJobId() %>"><%= f.getJobName() %></a></h2>
        <p class="muted"><%= f.getCompanyName() %> · <%= f.getJobSalary() %> · <%= f.getJobArea() %>
            · 收藏于 <%= f.getCreateTime() == null ? "-" : fmt.format(f.getCreateTime()) %></p>
    </div>
    <div class="job-ops">
        <a class="primary inline" href="<%= ctx %>/job/detail?id=<%= f.getJobId() %>">查看职位</a>
        <a class="btn-lite" href="<%= ctx %>/talk?jobId=<%= f.getJobId() %>">去谈谈</a>
        <form method="post" action="<%= ctx %>/favorite/delete">
            <input type="hidden" name="jobId" value="<%= f.getJobId() %>">
            <input type="hidden" name="back" value="list">
            <button class="btn-danger" type="submit">取消收藏</button>
        </form>
    </div>
</div>
<% }
} %>
</main>
<jsp:include page="/common/footer.jsp"/>
