<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%
    request.setAttribute("pageTitle", "我的投递 · 锐聘");
    request.setAttribute("navKey", "apply");
    request.setAttribute("moduleTitle", "我的投递");
    request.setAttribute("moduleDesc", "模块待开发。求职者将在此查看投递进度。");
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
