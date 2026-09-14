<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="com.qitoffer.util.OnlineUserTracker" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "在线用户 · 锐聘");
    request.setAttribute("navKey", "online");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    List<OnlineUserTracker.Record> rows = OnlineUserTracker.list();
    String selfId = session.getId();
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="manage-sheet">
    <div class="sheet-bar">
        <div>
            <h1>在线用户</h1>
            <p class="muted">当前共 <%= rows.size() %> 个登录会话，退出或超时后自动消失。</p>
        </div>
    </div>
    <div class="manage-body">
    <div class="table-wrap">
        <table class="data">
            <thead>
            <tr>
                <th>身份</th>
                <th>名称</th>
                <th>账号</th>
                <th>登录时间</th>
                <th></th>
            </tr>
            </thead>
            <tbody>
            <% if (rows.isEmpty()) { %>
            <tr>
                <td colspan="5" class="muted">当前没有在线账号。</td>
            </tr>
            <% } else {
                for (OnlineUserTracker.Record row : rows) {
                    boolean self = selfId.equals(row.getSessionId());
            %>
            <tr>
                <td><span class="tag"><%= row.getRoleLabel() %></span></td>
                <td><b><%= row.getDisplayName() %></b></td>
                <td><%= row.getAccount() %></td>
                <td><%= OnlineUserTracker.format(row.getLoginAt()) %></td>
                <td><% if (self) { %><span class="tag">本机</span><% } %></td>
            </tr>
            <%
                }
            }
            %>
            </tbody>
        </table>
    </div>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
