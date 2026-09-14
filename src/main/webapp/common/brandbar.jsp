<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    User mastUser = (User) session.getAttribute(Dict.SESSION_ADMIN);
    if (mastUser == null) {
%>
<div class="mast">
    <div>
        <a class="brand" href="<%= request.getContextPath() %>/"><i></i>锐聘</a>
        <span class="tagline">提供岗前培训的IT职位</span>
    </div>
    <div class="hotline"><small>免费咨询热线</small>400-658-1022</div>
</div>
<%
    }
%>
