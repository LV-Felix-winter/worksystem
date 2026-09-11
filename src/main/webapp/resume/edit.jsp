<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Resume" %>
<%
    request.setAttribute("pageTitle", "编辑简历 · 锐聘");
    request.setAttribute("navKey", "resume");
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
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<div class="wrap">
<style>
.ed{background:#fff;border-radius:12px;box-shadow:0 2px 12px rgba(0,0,0,.06);padding:26px 28px}
.ed h1{font-size:20px;margin-bottom:4px}
.ed .sub{font-size:12px;color:#888;margin-bottom:18px}
.row{display:flex;gap:14px;margin-bottom:12px}
.f{display:flex;flex-direction:column;gap:4px;flex:1}
.f label{font-size:12px;color:#888}
.f input,.f textarea{border:1px solid #ddd;border-radius:8px;padding:9px 10px;font-size:14px;outline:none}
.f textarea{resize:vertical;min-height:70px}
.btn{height:38px;padding:0 22px;border:none;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer}
.btn-p{background:linear-gradient(135deg,#4facfe,#00f2fe);color:#fff}
.btn-o{background:#fff;color:#4facfe;border:1px solid #4facfe}
</style>
<% if (applicant == null) { %>
<jsp:include page="/common/applicant-gate.jsp"/>
<% } else { %>
<div class="ed">
    <h1>编辑简历（#71099535）</h1>
    <p class="sub">保存后自动重算完整度（#71099536）；缺字段完整度会下降，附件是技能证书模块的主要得分项。</p>
    <form method="post" action="<%= ctx %>/resume/update">
        <div class="row">
            <div class="f"><label>姓名</label><input name="realname" value="<%= vRealname %>"></div>
            <div class="f"><label>性别</label><input name="gender" value="<%= vGender %>" placeholder="男 / 女"></div>
        </div>
        <div class="row">
            <div class="f"><label>所在地</label><input name="current_loc" value="<%= vCur %>"></div>
            <div class="f"><label>户籍</label><input name="resident_loc" value="<%= vRes %>"></div>
        </div>
        <div class="row">
            <div class="f"><label>手机</label><input name="telephone" value="<%= vPhone %>"></div>
            <div class="f"><label>邮箱</label><input name="email" value="<%= vMail %>"></div>
        </div>
        <div class="row">
            <div class="f"><label>意向岗位</label><input name="job_intension" value="<%= vIntent %>" placeholder="如 Java 开发"></div>
        </div>
        <div class="row">
            <div class="f"><label>求职 / 工作经历</label>
                <textarea name="job_experience" placeholder="公司、职位、职责、成果…"><%= vExp %></textarea>
            </div>
        </div>
        <div style="display:flex;gap:10px">
            <button class="btn btn-p" type="submit">保存并重算完整度</button>
            <a class="btn btn-o" href="<%= ctx %>/resume/">返回简历</a>
        </div>
    </form>
</div>
<% } %>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
