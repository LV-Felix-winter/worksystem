<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.dao.ApplyDao" %>
<%@ page import="com.qitoffer.entity.Apply" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
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
    String msg = (String) session.getAttribute("applyMsg");
    if (msg != null) {
        session.removeAttribute("applyMsg");
    }
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
    String ctx = request.getContextPath();
    Apply detail = null;
    if (detailId > 0) {
        for (Apply a : applyList) {
            if (a.getApplyId() == detailId) {
                detail = a;
                break;
            }
        }
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="card">
    <h1>应聘信息（#71099539 状态更新接口 /apply/state）</h1>
    <p class="muted">本企业职位收到的投递。查看简历摘要会把「待处理」自动流转为「已查看」；改状态需校验职位归属，越权改不动。</p>
    <% if (msg != null) { %><p class="note"><%= msg %></p><% } %>
    <% int companyIdAttr = request.getAttribute("companyId") instanceof Integer ? (Integer) request.getAttribute("companyId") : directCompanyId;
       if (companyIdAttr <= 0) { %>
    <p class="err">当前账号尚未关联企业，请先在「企业资料」完善信息。</p>
    <% } else if (applyList.isEmpty()) { %>
    <p class="muted">暂无投递记录。</p>
    <% } else {
        for (Apply a : applyList) {
            boolean isDetail = a.getApplyId() == detailId; %>
    <div class="data" style="border:1px solid <%= isDetail ? "#4facfe" : "#eee" %>;border-radius:10px;padding:14px 16px;margin-top:12px">
        <div style="display:flex;justify-content:space-between;gap:12px;flex-wrap:wrap">
            <div>
                <b><%= a.getResumeRealname() != null && !a.getResumeRealname().isEmpty() ? a.getResumeRealname() : "求职者 #" + a.getResumeId() %></b>
                <span class="muted"> 应聘「<%= a.getJobName() %>」 · 投递于 <%= a.getApplyDate() == null ? "-" : fmt.format(a.getApplyDate()) %></span>
            </div>
            <span class="st <%= Labels.applyStateClass(a.getApplyState()) %>" style="display:inline-block;padding:3px 12px;border-radius:20px;font-size:12px;font-weight:600;
                background:<%= a.getApplyState() == Dict.APPLY_REJECTED ? "#fff5f5;color:#ff6b6b" : a.getApplyState() == Dict.APPLY_PENDING ? "#eef4ff;color:#4facfe" : a.getApplyState() == Dict.APPLY_VIEWED ? "#e8f8ef;color:#27ae60" : "#f5eef8;color:#9b59b6" %>">
                <%= Labels.applyStateLabel(a.getApplyState()) %>
            </span>
        </div>
        <% if (isDetail) { %>
        <div class="note" style="background:#f8f9fc;border-radius:8px;padding:12px 14px;margin-top:10px;font-size:13px;line-height:1.9">
            <b>简历摘要</b>（完整度 <%= a.getResumeCompleteness() %> 分）<br>
            性别：<%= a.getResumeGender() == null ? "-" : a.getResumeGender() %>　
            手机：<%= a.getResumeTelephone() == null ? "-" : a.getResumeTelephone() %>　
            邮箱：<%= a.getResumeEmail() == null ? "-" : a.getResumeEmail() %><br>
            意向岗位：<%= a.getResumeJobIntension() == null ? "-" : a.getResumeJobIntension() %><br>
            经历：<%= a.getResumeJobExperience() == null ? "（未填写）" : a.getResumeJobExperience() %><br>
            附件：<% if (a.getResumeAttachment() != null && !a.getResumeAttachment().isEmpty()) { %>
            <a href="<%= ctx %><%= a.getResumeAttachment() %>" target="_blank">查看附件</a><% } else { %>（未上传）<% } %>
        </div>
        <% } %>
        <div style="display:flex;gap:10px;align-items:center;margin-top:10px;flex-wrap:wrap">
            <a class="btn-lite" href="<%= ctx %>/apply/detail?id=<%= a.getApplyId() %>"><%= isDetail ? "收起详情" : "查看简历" %></a>
            <form method="post" action="<%= ctx %>/apply/state" style="display:flex;gap:6px;align-items:center">
                <input type="hidden" name="applyId" value="<%= a.getApplyId() %>">
                <select name="newState" style="height:30px;border:1px solid #ddd;border-radius:6px;padding:0 8px;font-size:12px">
                    <option value="1" <%= a.getApplyState() == 1 ? "selected" : "" %>>待处理</option>
                    <option value="2" <%= a.getApplyState() == 2 ? "selected" : "" %>>已查看</option>
                    <option value="3" <%= a.getApplyState() == 3 ? "selected" : "" %>>已面试</option>
                    <option value="0" <%= a.getApplyState() == 0 ? "selected" : "" %>>已拒绝</option>
                </select>
                <button class="btn-lite" type="submit">更新状态</button>
            </form>
        </div>
    </div>
    <% }
    }
    }
    %>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
