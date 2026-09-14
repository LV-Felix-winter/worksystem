<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String resumeTab = (String) request.getAttribute("resumeTab");
    if (resumeTab == null) {
        resumeTab = "resume";
    }
    String tabCtx = request.getContextPath();
%>
<div class="subnav">
    <a class="<%= "resume".equals(resumeTab) ? "on" : "" %>" href="<%= tabCtx %>/resume/">简历</a>
    <a class="<%= "apply".equals(resumeTab) ? "on" : "" %>" href="<%= tabCtx %>/apply/mine">投递</a>
    <a class="<%= "fav".equals(resumeTab) ? "on" : "" %>" href="<%= tabCtx %>/favorite/list">收藏</a>
</div>
