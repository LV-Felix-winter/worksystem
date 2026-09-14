<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.dao.ApplyDao" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Apply" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "我的 · 投递");
    request.setAttribute("navKey", "apply");
    request.setAttribute("resumeTab", "apply");
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
<main class="page wide">
<jsp:include page="/common/resume-tabs.jsp"/>
<div class="page-head">
    <div>
        <h1>我的投递</h1>
        <p class="muted">投递后可在此查看企业处理进度。</p>
    </div>
    <a class="primary inline" href="<%= ctx %>/job/search">去投递</a>
</div>
<% if (msg != null) { %><p class="ok"><%= msg %></p><% } %>
<div class="card">
    <div class="table-wrap">
        <table class="data">
            <thead>
            <tr>
                <th>职位</th>
                <th>企业</th>
                <th>投递时间</th>
                <th>状态</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <% if (applyList.isEmpty()) { %>
            <tr><td colspan="5" class="muted">暂无投递记录。</td></tr>
            <% } else {
                for (Apply a : applyList) { %>
            <tr>
                <td><%= a.getJobName() %><div class="muted"><%= a.getJobSalary() %> · <%= a.getJobArea() %></div></td>
                <td><%= a.getCompanyName() %></td>
                <td><%= a.getApplyDate() == null ? "-" : fmt.format(a.getApplyDate()) %></td>
                <td><span class="tag <%= Labels.applyStateClass(a.getApplyState()) %>"><%= Labels.applyStateLabel(a.getApplyState()) %></span></td>
                <td><a href="<%= ctx %>/job/detail?id=<%= a.getJobId() %>">查看职位</a></td>
            </tr>
            <% }
            } %>
            </tbody>
        </table>
    </div>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
