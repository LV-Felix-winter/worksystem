<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Message" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "站内消息 · 锐聘");
    request.setAttribute("navKey", "message");
    String ctx = request.getContextPath();
    List<Message> msgList = (List<Message>) request.getAttribute("msgList");
    Integer unreadCount = (Integer) request.getAttribute("unreadCount");
    if (unreadCount == null) {
        unreadCount = 0;
    }
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    int total = msgList == null ? 0 : msgList.size();
%>
<jsp:include page="/common/html-start.jsp"/>
<% if (backend != null) { %>
<jsp:include page="/common/shell-open.jsp"/>
<% } else { %>
<main class="page wide">
<% } %>
<% if (backend != null) { %>
<div class="crumb">位置：<a href="<%= ctx %>/company/dashboard">工作台</a> / <span class="now">站内消息</span></div>
<% } %>
<div class="sheet sheet-pro msg-sheet">
    <div class="sheet-bar">
        <div>
            <h2>站内消息</h2>
            <p class="muted">共 <%= total %> 条，未读 <b class="accent-text"><%= unreadCount %></b> 条。投递与状态变化会写到这里。</p>
        </div>
        <form method="post" action="<%= ctx %>/message/read">
            <input type="hidden" name="action" value="readAll">
            <button class="primary inline" type="submit" <%= unreadCount == 0 ? "disabled" : "" %>>全部标为已读</button>
        </form>
    </div>
    <div class="msg-list">
        <% if (msgList == null || msgList.isEmpty()) { %>
        <div class="msg-empty">
            <div class="msg-empty-ico">✉</div>
            <p>暂无消息</p>
            <span class="muted">有新投递或状态变化时，会显示在这里。</span>
        </div>
        <% } else {
            for (Message m : msgList) {
                boolean unread = m.getIsRead() == Dict.MSG_UNREAD;
                String time = m.getCreateTime() == null ? "" : String.valueOf(m.getCreateTime());
                if (time.length() > 19) {
                    time = time.substring(0, 19);
                }
        %>
        <article class="msg-item <%= unread ? "unread" : "" %>">
            <div class="msg-rail"></div>
            <div class="msg-body">
                <div class="msg-top">
                    <span class="tag <%= unread ? "" : "off" %>"><%= unread ? "未读" : "已读" %></span>
                    <h3><%= m.getTitle() == null ? "系统通知" : m.getTitle() %></h3>
                    <time><%= time %></time>
                </div>
                <p class="msg-content"><%= m.getContent() == null ? "" : m.getContent().replaceAll("「([^」]+)」", "<span class=\"hl\">「$1」</span>") %></p>
            </div>
            <div class="msg-act">
                <% if (unread) { %>
                <form method="post" action="<%= ctx %>/message/read">
                    <input type="hidden" name="messageId" value="<%= m.getMessageId() %>">
                    <button class="btn-lite" type="submit">标为已读</button>
                </form>
                <% } else { %>
                <span class="muted tiny">已处理</span>
                <% } %>
            </div>
        </article>
        <%
            }
        }
        %>
    </div>
</div>
<% if (backend != null) { %>
<jsp:include page="/common/shell-close.jsp"/>
<% } else { %>
</main>
<jsp:include page="/common/footer.jsp"/>
<% } %>
