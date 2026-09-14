<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Company" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    Company company = (Company) request.getAttribute("company");
    Job job = (Job) request.getAttribute("job");
    if (job == null) {
        job = new Job();
        job.setJobHiringnum(1);
        job.setJobState(Dict.JOB_ONLINE);
    }
    String ctx = request.getContextPath();
    boolean editing = job.getJobId() > 0;
    String end = job.getJobEndtime() == null ? "" : job.getJobEndtime();
    if (end.length() > 10) {
        end = end.substring(0, 10);
    }
    String name = job.getJobName() == null ? "" : job.getJobName();
    String salary = job.getJobSalary() == null ? "" : job.getJobSalary();
    String area = job.getJobArea() == null ? "" : job.getJobArea();
    String desc = job.getJobDesc() == null ? "" : job.getJobDesc();
    String cover = job.getJobCover() == null ? "" : job.getJobCover();
    String thumb = job.getJobThumb() == null ? "" : job.getJobThumb();
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="crumb">位置：<a href="<%= ctx %>/company/dashboard">工作台</a> / <a href="<%= ctx %>/company/job.jsp">职位列表</a> / <span class="now"><%= editing ? "修改职位" : "发布职位" %></span></div>
<div class="sheet">
    <div class="sheet-bar">
        <h2><%= editing ? "修改职位" : "发布职位" %></h2>
        <p class="muted"><%= company != null ? company.getCompanyName() : "" %></p>
    </div>
    <form class="sheet-form" method="post" action="<%= ctx %>/company/job" enctype="multipart/form-data">
        <input type="hidden" name="jobId" value="<%= job.getJobId() %>">
        <div class="form-row">
            <div class="form-col">
                <label>职位名称</label>
                <input class="input" name="jobName" value="<%= name %>" required>
            </div>
            <div class="form-col">
                <label>招聘人数</label>
                <input class="input" name="jobHiringnum" type="number" min="1" value="<%= job.getJobHiringnum() < 1 ? 1 : job.getJobHiringnum() %>">
            </div>
        </div>
        <div class="form-row">
            <div class="form-col">
                <label>薪资</label>
                <input class="input" name="jobSalary" value="<%= salary %>" placeholder="如 8k-12k">
            </div>
            <div class="form-col">
                <label>工作地区</label>
                <input class="input js-region" name="jobArea" value="<%= area %>" placeholder="选择省 / 市 / 区县" readonly>
            </div>
        </div>
        <div class="form-row">
            <div class="form-col">
                <label>结束日期</label>
                <input class="input js-date" name="jobEndtime" value="<%= end %>" placeholder="选择截止日期" readonly>
            </div>
            <div class="form-col">
                <label>招聘状态</label>
                <select class="input" name="jobState">
                    <option value="1" <%= job.getJobState() != Dict.JOB_OFFLINE ? "selected" : "" %>>招聘中</option>
                    <option value="0" <%= job.getJobState() == Dict.JOB_OFFLINE ? "selected" : "" %>>已下架</option>
                </select>
            </div>
        </div>
        <label>职位描述</label>
        <textarea class="input" name="jobDesc" rows="6"><%= desc %></textarea>
        <div class="pic-pair">
            <div class="pic-field">
                <label>职位大图<span class="muted"> 替换用户页绿色横幅，建议 1200×480</span></label>
                <% if (!cover.isEmpty()) { %>
                <img class="pic-preview wide" src="<%= ctx + cover %>" alt="当前大图">
                <% } %>
                <label class="upload">
                    <input type="file" name="jobCover" accept="image/png,image/jpeg,image/webp,image/svg+xml" <%= editing ? "" : "required" %>>
                    <%= editing ? "更换大图（可选）" : "上传大图（必填）" %>
                </label>
            </div>
            <div class="pic-field">
                <label>职位缩略图<span class="muted"> 替换横幅左上角标志位，建议 320×160</span></label>
                <% if (!thumb.isEmpty()) { %>
                <img class="pic-preview" src="<%= ctx + thumb %>" alt="当前缩略图">
                <% } %>
                <label class="upload">
                    <input type="file" name="jobThumb" accept="image/png,image/jpeg,image/webp,image/svg+xml" <%= editing ? "" : "required" %>>
                    <%= editing ? "更换缩略图（可选）" : "上传缩略图（必填）" %>
                </label>
            </div>
        </div>
        <div class="actions" style="margin-top:16px">
            <button class="primary inline" type="submit">保存</button>
            <a class="btn-lite" href="<%= ctx %>/company/job.jsp">返回列表</a>
        </div>
    </form>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
