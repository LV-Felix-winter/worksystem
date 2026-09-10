<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String gateCtx = request.getContextPath();
    String gateView = (String) request.getAttribute("loginView");
    if (gateView == null || gateView.isEmpty()) {
        gateView = "company";
    }
%>
<div class="card">
    <h1>请先登录</h1>
    <p class="muted">后台功能需要企业或管理员账号。</p>
    <div class="actions">
        <a class="primary" href="<%= gateCtx %>/login?view=<%= gateView %>">去登录</a>
    </div>
</div>
