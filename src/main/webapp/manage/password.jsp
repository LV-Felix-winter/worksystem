<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "密码修改 · 锐聘");
    request.setAttribute("navKey", "password");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String ctx = request.getContextPath();
    String msg = (String) session.getAttribute("manageMsg");
    if (msg != null) {
        session.removeAttribute("manageMsg");
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="manage-sheet" style="max-width:560px">
    <div class="sheet-bar">
        <div>
            <h1>密码修改</h1>
            <p class="muted">修改当前管理员账号的登录密码。</p>
        </div>
    </div>
    <div class="manage-body">
    <% if (msg != null) { %><p class="ok toast-ok"><%= msg %></p><% } %>
    <form class="sheet-form form-pro" method="post" action="<%= ctx %>/manage/password">
        <label>原密码</label>
        <input class="input" type="password" name="oldPwd" required>
        <label>新密码</label>
        <input class="input" type="password" name="newPwd" placeholder="至少 6 位" required>
        <label>确认新密码</label>
        <input class="input" type="password" name="confirmPwd" required>
        <div class="actions form-actions">
            <button class="primary inline" type="submit">保存新密码</button>
        </div>
    </form>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
