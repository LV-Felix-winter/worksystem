<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.dao.ResumeDao" %>
<%@ page import="com.qitoffer.entity.Resume" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>
<%
    request.setAttribute("pageTitle", "简历管理 · 锐聘");
    request.setAttribute("navKey", "resumes");
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    String kw = request.getParameter("kw") == null ? "" : request.getParameter("kw").trim();
    int curPage = 1;
    try {
        curPage = Integer.parseInt(request.getParameter("page") == null ? "1" : request.getParameter("page"));
    } catch (NumberFormatException ignored) {
    }
    if (curPage < 1) {
        curPage = 1;
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
            resumes = dao.listPage(kw, curPage, pageSize);
            total = dao.countPage(kw);
        }
    } catch (Exception e) {
        dataErr = "数据库查询失败，请确认 MySQL 服务与 q_itoffer 库。";
    }
    int pageCount = Math.max(1, (total + pageSize - 1) / pageSize);
    if (curPage > pageCount && detailId == 0) {
        curPage = pageCount;
    }
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd");
    String ctx = request.getContextPath();
    String kwEnc = URLEncoder.encode(kw, "UTF-8");
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="manage-sheet">
    <div class="sheet-bar">
        <div>
            <h1>简历管理</h1>
            <p class="muted">分页查看全库简历，关键词匹配姓名、手机或意向岗位。</p>
        </div>
    </div>
    <div class="manage-body">
    <% if (!dataErr.isEmpty()) { %><p class="err"><%= dataErr %></p><% } %>
    <% if (detailId > 0) { %>
    <div class="actions" style="margin-bottom:12px"><a class="btn-lite" href="<%= ctx %>/manage/resume.jsp">返回简历列表</a></div>
    <% if (detail == null) { %>
    <p class="err">简历不存在。</p>
    <% } else { %>
    <table class="kv-pro">
        <tr><th>姓名</th><td><%= detail.getRealname() == null || detail.getRealname().isEmpty() ? "（未填）" : detail.getRealname() %></td></tr>
        <tr><th>性别 / 生日</th><td><%= detail.getGender() == null ? "-" : detail.getGender() %> / <%= detail.getBirthday() == null ? "-" : fmt.format(detail.getBirthday()) %></td></tr>
        <tr><th>所在地 / 户籍</th><td><%= detail.getCurrentLoc() == null ? "-" : detail.getCurrentLoc() %> / <%= detail.getResidentLoc() == null ? "-" : detail.getResidentLoc() %></td></tr>
        <tr><th>手机 / 邮箱</th><td><%= detail.getTelephone() == null ? "-" : detail.getTelephone() %> / <%= detail.getEmail() == null ? "-" : detail.getEmail() %></td></tr>
        <tr><th>意向岗位</th><td><%= detail.getJobIntension() == null || detail.getJobIntension().isEmpty() ? "（未填）" : detail.getJobIntension() %></td></tr>
        <tr><th>工作经历</th><td><%= detail.getJobExperience() == null || detail.getJobExperience().isEmpty() ? "（未填）" : detail.getJobExperience() %></td></tr>
        <tr><th>完整度</th><td>
            <div class="progress" style="max-width:240px">
                <div class="track"><div class="fill" style="width:<%= Math.min(100, Math.max(0, detail.getCompleteness())) %>%"></div></div>
                <b><%= detail.getCompleteness() %>%</b>
            </div>
        </td></tr>
        <tr><th>附件</th><td>
            <% if (detail.getAttachment() != null && !detail.getAttachment().isEmpty()) { %>
            <a href="<%= ctx %><%= detail.getAttachment() %>" target="_blank">查看附件</a>
            <% } else { %>（未上传）<% } %>
        </td></tr>
        <tr><th>来源求职者</th><td><%= detail.getApplicantName() == null ? ("#" + detail.getApplicantId()) : detail.getApplicantName() %></td></tr>
    </table>
    <% } %>
    <% } else { %>
    <form class="toolbar" method="get" action="<%= ctx %>/manage/resume.jsp">
        <input class="input" name="kw" value="<%= kw %>" placeholder="姓名 / 手机 / 意向岗位">
        <button class="primary inline" type="submit">查询</button>
        <a class="btn-lite" href="<%= ctx %>/manage/resume.jsp">重置</a>
        <span class="muted">共 <%= total %> 条</span>
    </form>
    <div class="table-wrap">
        <table class="data">
            <thead>
            <tr>
                <th>ID</th><th>姓名</th><th>手机</th><th>邮箱</th><th>意向岗位</th><th>完整度</th><th>附件</th><th></th>
            </tr>
            </thead>
            <tbody>
            <% if (resumes.isEmpty()) { %>
            <tr><td colspan="8" class="muted">没有符合条件的简历</td></tr>
            <% } else {
                for (Resume r : resumes) {
                    String name = r.getRealname() != null && !r.getRealname().isEmpty() ? r.getRealname() : r.getApplicantName();
            %>
            <tr>
                <td><%= r.getResumeId() %></td>
                <td><b><%= name == null || name.isEmpty() ? "（未填）" : name %></b></td>
                <td><%= r.getTelephone() == null || r.getTelephone().isEmpty() ? "-" : r.getTelephone() %></td>
                <td><%= r.getEmail() == null ? "-" : r.getEmail() %></td>
                <td><%= r.getJobIntension() == null || r.getJobIntension().isEmpty() ? "（未填）" : r.getJobIntension() %></td>
                <td>
                    <div class="progress">
                        <div class="track"><div class="fill" style="width:<%= Math.min(100, Math.max(0, r.getCompleteness())) %>%"></div></div>
                        <span><%= r.getCompleteness() %>%</span>
                    </div>
                </td>
                <td><%= r.getAttachment() != null && !r.getAttachment().isEmpty() ? "有" : "-" %></td>
                <td><a class="op-link" href="<%= ctx %>/manage/resume.jsp?kw=<%= kwEnc %>&detail=<%= r.getResumeId() %>">详情</a></td>
            </tr>
            <% }
            } %>
            </tbody>
        </table>
    </div>
    <% if (pageCount > 1) { %>
    <div class="pager">
        <% if (curPage > 1) { %><a href="<%= ctx %>/manage/resume.jsp?kw=<%= kwEnc %>&page=<%= curPage - 1 %>">上一页</a><% } %>
        <span>第 <%= curPage %> / <%= pageCount %> 页</span>
        <% if (curPage < pageCount) { %><a href="<%= ctx %>/manage/resume.jsp?kw=<%= kwEnc %>&page=<%= curPage + 1 %>">下一页</a><% } %>
    </div>
    <% } %>
    <% } %>
    </div>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
