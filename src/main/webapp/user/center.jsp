<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%
    request.setAttribute("pageTitle", "个人中心 · 锐聘");
    request.setAttribute("navKey", "center");
    request.setAttribute("moduleTitle", "个人中心");
    request.setAttribute("moduleDesc", "模块待开发。求职者将在此维护简历与账号资料。");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<% if (applicant == null) { %>
<jsp:include page="/common/applicant-gate.jsp"/>
<% } else { %>
<jsp:include page="/common/pending-module.jsp"/>
<% } %>
</main>
<jsp:include page="/common/footer.jsp"/>
