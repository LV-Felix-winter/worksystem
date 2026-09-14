<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Resume" %>
<%
    request.setAttribute("pageTitle", "编辑简历 · 锐聘");
    request.setAttribute("navKey", "center");
    request.setAttribute("resumeTab", "resume");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    Resume resume = (Resume) request.getAttribute("resume");
    String ctx = request.getContextPath();
    String vRealname = resume != null && resume.getRealname() != null ? resume.getRealname() : (applicant != null && applicant.getApplicantName() != null ? applicant.getApplicantName() : "");
    String vGender = resume != null && resume.getGender() != null ? resume.getGender() : "";
    String vCur = resume != null && resume.getCurrentLoc() != null ? resume.getCurrentLoc() : "";
    String vRes = resume != null && resume.getResidentLoc() != null ? resume.getResidentLoc() : "";
    String vPhone = resume != null && resume.getTelephone() != null ? resume.getTelephone() : (applicant != null && applicant.getApplicantPhone() != null ? applicant.getApplicantPhone() : "");
    String vMail = resume != null && resume.getEmail() != null ? resume.getEmail() : (applicant != null && applicant.getApplicantEmail() != null ? applicant.getApplicantEmail() : "");
    String vIntent = resume != null && resume.getJobIntension() != null ? resume.getJobIntension() : "";
    String vExp = resume != null && resume.getJobExperience() != null ? resume.getJobExperience() : "";
    String vBirth = "";
    if (resume != null && resume.getBirthday() != null) {
        vBirth = new java.text.SimpleDateFormat("yyyy-MM-dd").format(resume.getBirthday());
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<% if (applicant == null) { %>
<jsp:include page="/common/applicant-gate.jsp"/>
<% } else { %>
<jsp:include page="/common/resume-tabs.jsp"/>
<div class="card">
    <h1>编辑简历</h1>
    <p class="muted">保存后会按已填字段重新计算完整度。</p>
    <form method="post" action="<%= ctx %>/resume/update">
        <div class="form-row">
            <div class="form-col"><label>姓名</label><input class="input" name="realname" value="<%= vRealname %>"></div>
            <div class="form-col"><label>性别</label><input class="input" name="gender" value="<%= vGender %>" placeholder="男 / 女"></div>
            <div class="form-col"><label>出生日期</label><input class="input js-date" name="birthday" value="<%= vBirth %>" placeholder="选择年月日" readonly></div>
        </div>
        <div class="form-row">
            <div class="form-col"><label>所在地</label><input class="input js-region" name="current_loc" value="<%= vCur %>" placeholder="选择省 / 市 / 区县" readonly></div>
            <div class="form-col"><label>户籍</label><input class="input js-region" name="resident_loc" value="<%= vRes %>" placeholder="选择省 / 市 / 区县" readonly></div>
        </div>
        <div class="form-row">
            <div class="form-col"><label>手机</label><input class="input" name="telephone" value="<%= vPhone %>"></div>
            <div class="form-col"><label>邮箱</label><input class="input" name="email" value="<%= vMail %>"></div>
        </div>
        <div class="form-row">
            <div class="form-col"><label>意向岗位</label><input class="input" name="job_intension" value="<%= vIntent %>" placeholder="如 Java 开发"></div>
        </div>
        <input type="hidden" name="job_experience" value="<%= vExp %>">
        <p class="muted">工作经历、技能、荣誉和自我评价请回到简历页按条目填写。</p>
        <div class="actions">
            <button class="primary inline" type="submit">保存</button>
            <a class="btn-lite" href="<%= ctx %>/resume/">返回</a>
        </div>
    </form>
</div>
<% } %>
</main>
<jsp:include page="/common/footer.jsp"/>
