<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String gateCtx = request.getContextPath();
%>
<div class="card">
    <h1>请先登录</h1>
    <p class="muted">个人中心与投递记录需要求职者账号。</p>
    <div class="actions">
        <a class="primary" href="<%= gateCtx %>/login">去登录</a>
    </div>
</div>
