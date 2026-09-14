<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Apply" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "应聘信息 · 锐聘");
    request.setAttribute("navKey", "applies");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    @SuppressWarnings("unchecked")
    List<Apply> applyList = (List<Apply>) request.getAttribute("applyList");
    int directCompanyId = 0;
    if (applyList == null) {
        applyList = new ArrayList<>();
        if (backend != null) {
            try {
                com.qitoffer.entity.Company c = new com.qitoffer.dao.CompanyDao().findByUserId(backend.getUserId());
                if (c != null) {
                    directCompanyId = c.getCompanyId();
                    applyList = new com.qitoffer.dao.ApplyDao().listByCompany(directCompanyId);
                }
            } catch (Exception ignored) {
            }
        }
    }
    int detailId = request.getAttribute("detailId") instanceof Integer ? (Integer) request.getAttribute("detailId") : 0;
    String kw = request.getParameter("kw") == null ? "" : request.getParameter("kw").trim();
    String stateParam = request.getParameter("state") == null ? "" : request.getParameter("state").trim();
    String msg = (String) session.getAttribute("applyMsg");
    if (msg != null) {
        session.removeAttribute("applyMsg");
    }
    String ctx = request.getContextPath();
    List<Apply> shown = new ArrayList<>();
    for (Apply a : applyList) {
        boolean nameOk = kw.isEmpty()
                || (a.getJobName() != null && a.getJobName().contains(kw))
                || (a.getResumeRealname() != null && a.getResumeRealname().contains(kw));
        boolean stateOk = stateParam.isEmpty() || String.valueOf(a.getApplyState()).equals(stateParam);
        if (nameOk && stateOk) {
            shown.add(a);
        }
    }
    request.setAttribute("applyCards", shown);
    request.setAttribute("applyCardDetailId", detailId);
    request.setAttribute("applyCardShowForm", Boolean.TRUE);
    request.setAttribute("applyCardEmpty", "暂无符合条件的投递记录。");
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="crumb">位置：<a href="<%= ctx %>/company/dashboard">工作台</a> / <span class="now">应聘信息</span></div>
<% if (msg != null) { %><p class="ok"><%= msg %></p><% } %>
<% int companyIdAttr = request.getAttribute("companyId") instanceof Integer ? (Integer) request.getAttribute("companyId") : directCompanyId; %>
<div class="sheet">
    <div class="sheet-bar">
        <h2>应聘信息</h2>
        <a class="btn-lite" href="<%= ctx %>/company/job.jsp">职位列表</a>
    </div>
    <form class="sheet-filter" method="get" action="<%= ctx %>/apply/company">
        <label>关键词</label>
        <input class="input" name="kw" value="<%= kw %>" placeholder="求职者 / 职位名称">
        <label>状态</label>
        <select class="input" name="state">
            <option value="" <%= stateParam.isEmpty() ? "selected" : "" %>>全部</option>
            <option value="1" <%= "1".equals(stateParam) ? "selected" : "" %>>待处理</option>
            <option value="2" <%= "2".equals(stateParam) ? "selected" : "" %>>已查看</option>
            <option value="3" <%= "3".equals(stateParam) ? "selected" : "" %>>已面试</option>
            <option value="0" <%= "0".equals(stateParam) ? "selected" : "" %>>已拒绝</option>
        </select>
        <button class="primary inline" type="submit">查询</button>
        <a class="btn-lite" href="<%= ctx %>/apply/company">重置</a>
    </form>
    <% if (companyIdAttr <= 0) { %>
    <div class="talent-list"><div class="talent-empty">当前账号尚未关联企业。</div></div>
    <% } else { %>
    <jsp:include page="/company/apply-cards.jsp"/>
    <% } %>
    <div class="sheet-foot">
        <span>共 <%= shown.size() %> 位候选人</span>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
