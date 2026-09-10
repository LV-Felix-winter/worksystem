<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "锐聘 Q_ITOffer");
    request.setAttribute("navKey", "jobs");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    String ctx = request.getContextPath();
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="home">
    <h1>锐聘招聘平台</h1>
    <% if (backend != null) { %>
    <p class="muted">已登录<%= backend.getUserRole() == Dict.ROLE_ADMIN ? "管理员" : "企业" %>：<%=
            backend.getUserRealname() != null && !backend.getUserRealname().isEmpty()
                    ? backend.getUserRealname() : backend.getUserLogname()
    %>。请从工作台进入对应菜单。</p>
    <div class="actions">
        <a class="primary" href="<%= ctx %>/manage/">进入工作台</a>
    </div>
    <% } else if (applicant != null) { %>
    <p class="muted">已登录求职者：<%= applicant.getApplicantName() != null && !applicant.getApplicantName().isEmpty()
            ? applicant.getApplicantName() : applicant.getApplicantPhone() %>。可从顶栏进入个人中心或投递记录。</p>
    <div class="actions">
        <a class="primary" href="<%= ctx %>/user/center.jsp">个人中心</a>
    </div>
    <% } else { %>
    <p class="muted">同一个入口，求职者与企业分身份登录，互不串号。</p>
    <div class="actions">
        <a class="primary" href="<%= ctx %>/login">进入登录</a>
    </div>
    <% } %>
</main>
<jsp:include page="/common/footer.jsp"/>
