<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.dao.ApplyDao" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Apply" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "我的投递 · 锐聘");
    request.setAttribute("navKey", "apply");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    @SuppressWarnings("unchecked")
    List<Apply> applyList = (List<Apply>) request.getAttribute("applyList");
    if (applyList == null) {
        applyList = new ArrayList<>();
        if (applicant != null) {
            try {
                applyList = new ApplyDao().listByApplicant(applicant.getApplicantId());
            } catch (Exception ignored) {
            }
        }
    }
    String msg = (String) session.getAttribute("applyMsg");
    if (msg != null) {
        session.removeAttribute("applyMsg");
    }
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String ctx = request.getContextPath();
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<div class="wrap">
<style>
.my-head{display:flex;justify-content:space-between;align-items:center;margin-bottom:16px}
.my-head h1{font-size:20px}
.msg{font-size:13px;padding:10px 14px;border-radius:8px;margin-bottom:14px;background:#e8f8ef;color:#27ae60}
.tbl{background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,.06);overflow:hidden}
.trow{display:flex;align-items:center;padding:14px 20px;border-bottom:1px solid #f5f5f5;font-size:13px}
.trow.hd{background:#f8f9fc;color:#888;font-weight:600}
.trow .c{padding:0 10px}
.c1{flex:1.4}.c2{flex:1}.c3{flex:.9}.c4{flex:.8}.c5{flex:1.2}
.c5 .st{display:inline-block;padding:3px 12px;border-radius:20px;font-size:12px;font-weight:600}
.st-pending{background:#eef4ff;color:#4facfe}
.st-viewed{background:#e8f8ef;color:#27ae60}
.st-interview{background:#f5eef8;color:#9b59b6}
.st-rejected{background:#fff5f5;color:#ff6b6b}
.a-link{font-size:12px;color:#4facfe;text-decoration:none}
.empty{text-align:center;padding:44px;color:#aaa}
</style>
<div class="my-head">
    <h1>我的投递（#71099538 状态流转展示）</h1>
    <a class="a-link" href="<%= ctx %>/job/search">去投递新职位 →</a>
</div>
<% if (msg != null) { %><div class="msg"><%= msg %></div><% } %>
<div class="tbl">
    <div class="trow hd">
        <span class="c c1">职位</span><span class="c c2">企业</span><span class="c c3">投递时间</span>
        <span class="c c4">状态</span><span class="c c5">操作</span>
    </div>
    <% if (applyList.isEmpty()) { %>
    <div class="empty">暂无投递记录。<a class="a-link" href="<%= ctx %>/job/search">去搜个职位投一下</a></div>
    <% } else {
        for (Apply a : applyList) { %>
    <div class="trow">
        <span class="c c1"><b><%= a.getJobName() %></b><br><span style="color:#999"><%= a.getJobSalary() %> · <%= a.getJobArea() %></span></span>
        <span class="c c2"><%= a.getCompanyName() %></span>
        <span class="c c3"><%= a.getApplyDate() == null ? "-" : fmt.format(a.getApplyDate()) %></span>
        <span class="c c4"><span class="st <%= Labels.applyStateClass(a.getApplyState()) %>"><%= Labels.applyStateLabel(a.getApplyState()) %></span></span>
        <span class="c c5"><a class="a-link" href="<%= ctx %>/job/detail?id=<%= a.getJobId() %>">查看职位</a></span>
    </div>
    <% }
    } %>
</div>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
