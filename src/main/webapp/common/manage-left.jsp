<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    String ctx = request.getContextPath();
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String navKey = (String) request.getAttribute("navKey");
    if (navKey == null) {
        navKey = "";
    }
    if (backend != null) {
%>
<aside class="side">
    <% if (backend.getUserRole() == Dict.ROLE_ADMIN) { %>
    <a class="<%= "workbench".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/">工作台</a>
    <a class="<%= "users".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/user.jsp">用户管理</a>
    <a class="<%= "companies".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/company.jsp">企业管理</a>
    <a class="<%= "jobs".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/job.jsp">职位管理</a>
    <a class="<%= "resumes".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/resume.jsp">简历管理</a>
    <a class="<%= "online".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/online.jsp">在线用户</a>
    <% } else { %>
    <a class="<%= "workbench".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/">工作台</a>
    <a class="<%= "jobs".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/company/job.jsp">本企业职位</a>
    <a class="<%= "applies".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/company/apply.jsp">应聘信息</a>
    <a class="<%= "profile".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/company/profile.jsp">企业资料</a>
    <% } %>
</aside>
<%
    }
%>
