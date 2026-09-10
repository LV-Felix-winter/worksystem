<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String title = (String) request.getAttribute("moduleTitle");
    String desc = (String) request.getAttribute("moduleDesc");
    if (title == null) {
        title = "功能模块";
    }
    if (desc == null) {
        desc = "模块待开发。";
    }
%>
<div class="card">
    <h1><%= title %></h1>
    <p class="muted"><%= desc %></p>
</div>
