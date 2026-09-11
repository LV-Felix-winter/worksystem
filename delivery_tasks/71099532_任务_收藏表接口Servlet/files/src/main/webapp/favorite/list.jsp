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
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<div class="wrap">
<style>
.fav-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px}
.fav-head h1{font-size:20px}
.fav-head a{font-size:13px;color:#4facfe;text-decoration:none}
.fav-row{background:#fff;border-radius:12px;box-shadow:0 2px 8px rgba(0,0,0,.05);padding:16px 22px;margin-bottom:10px;display:flex;justify-content:space-between;align-items:center;gap:14px}
.fav-main .n{font-size:15px;font-weight:600}
.fav-main .n a{color:#1a1a2e;text-decoration:none}
.fav-main .c{font-size:12px;color:#888;margin-top:4px}
.fav-ops{display:flex;gap:8px;align-items:center}
.fav-ops form{display:flex}
.btn{height:32px;padding:0 14px;border-radius:8px;font-size:12px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center}
.btn-view{background:#eef4ff;color:#4facfe;border:none}
.btn-del{background:#fff;border:1px solid #ff6b6b;color:#ff6b6b}
.empty{text-align:center;padding:48px;color:#aaa;background:#fff;border-radius:12px}
</style>
<div class="fav-head">
    <h1>收藏职位（#71099532 tb_favorite 唯一键 applicant_id + job_id）</h1>
    <a href="<%= ctx %>/job/search">＋ 去搜职位</a>
</div>
<% if (favorites.isEmpty()) { %>
<div class="empty">还没有收藏职位。<a href="<%= ctx %>/job/search">去职位检索看看</a></div>
<% } else { %>
<% for (Favorite f : favorites) { %>
<div class="fav-row">
    <div class="fav-main">
        <div class="n"><a href="<%= ctx %>/job/detail?id=<%= f.getJobId() %>"><%= f.getJobName() %></a></div>
        <div class="c"><%= f.getCompanyName() %> · <%= f.getJobSalary() %> · <%= f.getJobArea() %> · 收藏于 <%= f.getCreateTime() == null ? "-" : fmt.format(f.getCreateTime()) %></div>
    </div>
    <div class="fav-ops">
        <a class="btn btn-view" href="<%= ctx %>/job/detail?id=<%= f.getJobId() %>">查看职位 / 投递</a>
        <form method="post" action="<%= ctx %>/favorite/delete">
            <input type="hidden" name="jobId" value="<%= f.getJobId() %>">
            <input type="hidden" name="back" value="list">
            <button class="btn btn-del" type="submit">取消收藏</button>
        </form>
    </div>
</div>
<% } %>
<% } %>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
