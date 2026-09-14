<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    request.setAttribute("pageTitle", "简历预览 · 锐聘");
    request.setAttribute("navKey", "center");
    request.setAttribute("resumeTab", "resume");
    String ctx = request.getContextPath();
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page wide">
<jsp:include page="/common/resume-tabs.jsp"/>
<div class="page-head">
    <div>
        <h1>简历 PDF 预览</h1>
        <p class="muted">按在线简历生成，可直接导出或打印保存。</p>
    </div>
    <div class="actions">
        <a class="primary inline" href="<%= ctx %>/resume/pdf?dl=1">导出 PDF</a>
        <a class="btn-lite" href="<%= ctx %>/resume/">返回编辑</a>
    </div>
</div>
<iframe class="pdf-frame" title="简历 PDF" src="<%= ctx %>/resume/pdf"></iframe>
</main>
<jsp:include page="/common/footer.jsp"/>
