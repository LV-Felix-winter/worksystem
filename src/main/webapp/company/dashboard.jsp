<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Apply" %>
<%@ page import="com.qitoffer.entity.Company" %>
<%@ page import="com.qitoffer.entity.DashboardStats" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.util.List" %>
<%
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    Company company = (Company) request.getAttribute("company");
    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
    if (stats == null) {
        stats = new DashboardStats();
    }
    @SuppressWarnings("unchecked")
    List<Apply> applies = (List<Apply>) request.getAttribute("applies");
    Integer applyState = (Integer) request.getAttribute("applyState");
    String ctx = request.getContextPath();
    List<Apply> shown = new ArrayList<>();
    if (applies != null) {
        for (Apply a : applies) {
            if (applyState == null || a.getApplyState() == applyState) {
                shown.add(a);
            }
        }
    }
    request.setAttribute("applyCards", shown);
    request.setAttribute("applyCardShowForm", Boolean.FALSE);
    request.setAttribute("applyCardEmpty", "暂无投递数据。");
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="crumb">位置：<span class="now">工作台</span></div>
<div class="page-head">
    <div>
        <h1 style="font-size:20px">企业工作台</h1>
        <p class="muted"><%= company != null ? company.getCompanyName() : "尚未关联企业资料" %></p>
    </div>
    <div class="actions">
        <a class="primary inline" href="<%= ctx %>/company/job?action=add">发布职位</a>
        <a class="btn-lite" href="<%= ctx %>/apply/company">应聘信息</a>
        <a class="btn-lite" href="<%= ctx %>/company/profile.jsp">企业资料</a>
    </div>
</div>
<% if (company == null) { %>
<div class="sheet"><div class="sheet-form"><p class="err">当前账号尚未关联企业，请先到顶栏「资料」完善。</p></div></div>
<% } else { %>
<div class="metric-row">
    <a class="metric" href="<%= ctx %>/company/job.jsp"><span class="label">在招职位</span><span class="num"><%= stats.getHiringJobs() %></span></a>
    <a class="metric" href="<%= ctx %>/apply/company"><span class="label">投递总数</span><span class="num"><%= stats.getTotalApplies() %></span></a>
    <a class="metric" href="<%= ctx %>/company/dashboard?applyState=1"><span class="label">待处理</span><span class="num"><%= stats.getPendingApplies() %></span></a>
    <a class="metric" href="<%= ctx %>/apply/company"><span class="label">今日投递</span><span class="num"><%= stats.getTodayApplies() %></span></a>
</div>
<div class="sheet">
    <div class="sheet-bar">
        <h2>应聘信息</h2>
        <a class="btn-lite" href="<%= ctx %>/apply/company">查看全部</a>
    </div>
    <form class="sheet-filter" method="get" action="<%= ctx %>/company/dashboard">
        <label>投递状态</label>
        <select class="input" name="applyState">
            <option value="" <%= applyState == null ? "selected" : "" %>>全部</option>
            <option value="1" <%= applyState != null && applyState == 1 ? "selected" : "" %>>待处理</option>
            <option value="2" <%= applyState != null && applyState == 2 ? "selected" : "" %>>已查看</option>
            <option value="3" <%= applyState != null && applyState == 3 ? "selected" : "" %>>已面试</option>
            <option value="0" <%= applyState != null && applyState == 0 ? "selected" : "" %>>已拒绝</option>
        </select>
        <button class="primary inline" type="submit">查询</button>
    </form>
    <jsp:include page="/company/apply-cards.jsp"/>
    <div class="sheet-foot">
        <span>共 <%= shown.size() %> 位候选人</span>
        <a href="<%= ctx %>/apply/company">进入应聘处理</a>
    </div>
</div>
<% } %>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
