<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.dao.ResumeDao" %>
<%@ page import="com.qitoffer.entity.Resume" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "简历管理 · 锐聘");
    request.setAttribute("navKey", "resumes");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String kw = request.getParameter("kw") == null ? "" : request.getParameter("kw").trim();
    int page = 1;
    try {
        page = Integer.parseInt(request.getParameter("page") == null ? "1" : request.getParameter("page"));
    } catch (NumberFormatException ignored) {
    }
    if (page < 1) {
        page = 1;
    }
    final int pageSize = 10;
    int detailId = 0;
    try {
        detailId = Integer.parseInt(request.getParameter("detail") == null ? "0" : request.getParameter("detail"));
    } catch (NumberFormatException ignored) {
    }
    ResumeDao dao = new ResumeDao();
    List<Resume> resumes = new ArrayList<>();
    int total = 0;
    Resume detail = null;
    String dataErr = "";
    try {
        if (detailId > 0) {
            detail = dao.findById(detailId);
        } else {
            resumes = dao.listPage(kw, page, pageSize);
            total = dao.countPage(kw);
        }
    } catch (Exception e) {
        dataErr = "数据库查询失败：请确认 MySQL 服务与 q_itoffer 库（见 README）。";
    }
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
    if (page > pageCount && detailId == 0) {
        page = pageCount;
    }
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
    String ctx = request.getContextPath();
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="card">
    <h1>简历管理（#71098791/#71098792 分页与详情）</h1>
    <p class="muted">分页查看全库简历，点「详情」打开只读视图；关键词匹配姓名 / 手机 / 意向岗位。</p>
    <% if (!dataErr.isEmpty()) { %><p class="err"><%= dataErr %></p><% } %>
    <% if (detailId > 0) { %>
    <div style="margin-bottom:12px"><a class="btn-lite" href="<%= ctx %>/manage/resume.jsp">← 返回简历列表</a></div>
    <% if (detail == null) { %>
    <p class="err">简历 #<%= detailId %> 不存在。</p>
    <% } else { %>
    <table class="data" style="border-collapse:collapse;width:100%">
        <tr><th style="text-align:left">姓名</th><td><%= detail.getRealname() == null || detail.getRealname().isEmpty() ? "（未填）" : detail.getRealname() %></td></tr>
        <tr><th style="text-align:left">性别 / 生日</th><td><%= detail.getGender() == null ? "-" : detail.getGender() %> / <%= detail.getBirthday() == null ? "-" : fmt.format(detail.getBirthday()) %></td></tr>
        <tr><th style="text-align:left">所在地 / 户籍</th><td><%= detail.getCurrentLoc() == null ? "-" : detail.getCurrentLoc() %> / <%= detail.getResidentLoc() == null ? "-" : detail.getResidentLoc() %></td></tr>
        <tr><th style="text-align:left">手机 / 邮箱</th><td><%= detail.getTelephone() == null ? "-" : detail.getTelephone() %> / <%= detail.getEmail() == null ? "-" : detail.getEmail() %></td></tr>
        <tr><th style="text-align:left">意向岗位</th><td><%= detail.getJobIntension() == null || detail.getJobIntension().isEmpty() ? "（未填）" : detail.getJobIntension() %></td></tr>
        <tr><th style="text-align:left">求职/工作经历</th><td><%= detail.getJobExperience() == null || detail.getJobExperience().isEmpty() ? "（未填）" : detail.getJobExperience() %></td></tr>
        <tr><th style="text-align:left">完整度（#71099536 加权）</th><td>
            <div style="display:flex;align-items:center;gap:10px">
                <div style="flex:1;max-width:220px;height:8px;background:#eee;border-radius:4px;overflow:hidden">
                    <div style="width:<%= Math.min(100, Math.max(0, detail.getCompleteness())) %>%;height:100%;background:linear-gradient(90deg,#4facfe,#00f2fe)"></div>
                </div>
                <b><%= detail.getCompleteness() %>%</b>
            </div></td></tr>
        <tr><th style="text-align:left">附件</th><td><% if (detail.getAttachment() != null && !detail.getAttachment().isEmpty()) { %>
            <a href="<%= ctx %><%= detail.getAttachment() %>" target="_blank">查看附件</a><% } else { %>（未上传）<% } %></td></tr>
        <tr><th style="text-align:left">来源求职者</th><td><%= detail.getApplicantName() == null ? ("#" + detail.getApplicantId()) : detail.getApplicantName() %>（<%= detail.getApplicantEmail() == null ? "-" : detail.getApplicantEmail() %>）</td></tr>
    </table>
    <% } %>
    <% } else { %>
    <form method="get" action="<%= ctx %>/manage/resume.jsp" style="display:flex;gap:8px;flex-wrap:wrap;margin:12px 0">
        <input name="kw" value="<%= kw %>" placeholder="姓名 / 手机 / 意向岗位" style="height:34px;border:1px solid #ddd;border-radius:8px;padding:0 10px;min-width:240px">
        <button class="btn-lite" type="submit">查询</button>
        <a class="btn-lite" href="<%= ctx %>/manage/resume.jsp">重置</a>
        <span class="muted">共 <%= total %> 条</span>
    </form>
    <table class="data" style="width:100%;border-collapse:collapse">
        <tr>
            <th>ID</th><th>姓名</th><th>手机</th><th>邮箱</th><th>意向岗位</th><th>完整度</th><th>附件</th><th>操作</th>
        </tr>
        <% if (resumes.isEmpty()) { %>
        <tr><td colspan="8" class="muted">没有符合条件的简历</td></tr>
        <% } else {
            for (Resume r : resumes) {
                String name = r.getRealname() != null && !r.getRealname().isEmpty() ? r.getRealname() : r.getApplicantName();
        %>
        <tr>
            <td><%= r.getResumeId() %></td>
            <td><%= name == null || name.isEmpty() ? "（未填）" : name %></td>
            <td><%= r.getTelephone() == null || r.getTelephone().isEmpty() ? "-" : r.getTelephone() %></td>
            <td><%= r.getEmail() == null ? "-" : r.getEmail() %></td>
            <td><%= r.getJobIntension() == null || r.getJobIntension().isEmpty() ? "（未填）" : r.getJobIntension() %></td>
            <td style="min-width:120px">
                <div style="display:flex;align-items:center;gap:6px">
                    <div style="flex:1;height:6px;background:#eee;border-radius:3px;overflow:hidden">
                        <div style="width:<%= Math.min(100, Math.max(0, r.getCompleteness())) %>%;height:100%;background:linear-gradient(90deg,#4facfe,#00f2fe)"></div>
                    </div><span><%= r.getCompleteness() %>%</span>
                </div>
            </td>
            <td><% if (r.getAttachment() != null && !r.getAttachment().isEmpty()) { %>✓<% } else { %>-<% } %></td>
            <td><a href="<%= ctx %>/manage/resume.jsp?kw=<%= java.net.URLEncoder.encode(kw, "UTF-8") %>&detail=<%= r.getResumeId() %>" style="display:inline-block">详情</a></td>
        </tr>
        <% }
            } %>
    </table>
    <% if (pageCount > 1) { %>
    <div style="display:flex;gap:8px;align-items:center;margin-top:12px">
        <% if (page > 1) { %><a class="btn-lite" href="<%= ctx %>/manage/resume.jsp?kw=<%= java.net.URLEncoder.encode(kw, "UTF-8") %>&page=<%= page - 1 %>">‹ 上一页</a><% } %>
        <span class="muted">第 <%= page %> / <%= pageCount %> 页</span>
        <% if (page < pageCount) { %><a class="btn-lite" href="<%= ctx %>/manage/resume.jsp?kw=<%= java.net.URLEncoder.encode(kw, "UTF-8") %>&page=<%= page + 1 %>">下一页 ›</a><% } %>
    </div>
    <% } %>
    <% } %>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
