<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Pics" %>
<%@ page import="com.qitoffer.common.ResumeBlocks" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Resume" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", Boolean.TRUE.equals(request.getAttribute("preview")) ? "简历预览 · 锐聘" : "我的 · 简历");
    request.setAttribute("navKey", "center");
    request.setAttribute("resumeTab", "resume");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    Resume resume = (Resume) request.getAttribute("resume");
    String ctx = request.getContextPath();
    boolean preview = Boolean.TRUE.equals(request.getAttribute("preview"));
    int totalScore = resume == null ? 0 : resume.getCompleteness();
    String resumeMsg = (String) session.getAttribute("resumeMsg");
    if (resumeMsg != null) {
        session.removeAttribute("resumeMsg");
    }
    SimpleDateFormat dayFmt = new SimpleDateFormat("yyyy-MM-dd");
    String name = resume != null && resume.getRealname() != null && !resume.getRealname().isEmpty()
            ? resume.getRealname()
            : (applicant != null && applicant.getApplicantName() != null ? applicant.getApplicantName() : "—");
    String gender = resume != null && resume.getGender() != null && !resume.getGender().isEmpty() ? resume.getGender() : "—";
    String birthday = resume != null && resume.getBirthday() != null ? dayFmt.format(resume.getBirthday()) : "—";
    String currentLoc = resume != null && resume.getCurrentLoc() != null && !resume.getCurrentLoc().isEmpty() ? resume.getCurrentLoc() : "—";
    String residentLoc = resume != null && resume.getResidentLoc() != null && !resume.getResidentLoc().isEmpty() ? resume.getResidentLoc() : "—";
    String phone = resume != null && resume.getTelephone() != null && !resume.getTelephone().isEmpty()
            ? resume.getTelephone()
            : (applicant != null && applicant.getApplicantPhone() != null ? applicant.getApplicantPhone() : "—");
    String email = resume != null && resume.getEmail() != null && !resume.getEmail().isEmpty()
            ? resume.getEmail()
            : (applicant != null && applicant.getApplicantEmail() != null ? applicant.getApplicantEmail() : "—");
    String intent = resume != null && resume.getJobIntension() != null && !resume.getJobIntension().isEmpty() ? resume.getJobIntension() : "—";
    boolean hasPhoto = resume != null && resume.getHeadShot() != null && !resume.getHeadShot().isEmpty();
    boolean hasAttach = resume != null && resume.getAttachment() != null && !resume.getAttachment().isEmpty();
    boolean hasBasic = resume != null && resume.getRealname() != null && !resume.getRealname().isEmpty();
    String photoUrl = Pics.photo(resume == null ? null : resume.getHeadShot(), ctx);
    List<ResumeBlocks.Edu> eduList = ResumeBlocks.parseEdu(resume == null ? "" : resume.getEducation());
    List<ResumeBlocks.Proj> projList = ResumeBlocks.parseProj(resume == null ? "" : resume.getProjectExp());
    List<ResumeBlocks.Work> workList = ResumeBlocks.worksOrFallback(
            resume == null ? "" : resume.getWorkExp(),
            resume == null ? "" : resume.getJobExperience());
    ResumeBlocks.Skills skills = ResumeBlocks.parseSkills(resume == null ? "" : resume.getSkills());
    List<String> honorList = ResumeBlocks.parseHonors(resume == null ? "" : resume.getHonors());
    String selfEval = resume == null || resume.getSelfEval() == null ? "" : resume.getSelfEval();
    boolean hasEdu = !eduList.isEmpty();
    boolean hasProj = !projList.isEmpty();
    boolean hasWork = !workList.isEmpty();
    boolean hasSkill = ResumeBlocks.skillsFilled(skills);
    boolean hasHonor = !honorList.isEmpty();
    boolean hasEval = !selfEval.isBlank();
    String open = request.getParameter("open") == null ? "" : request.getParameter("open");
    int editEdu = -1, editProj = -1, editWork = -1, editHonor = -1;
    try { editEdu = Integer.parseInt(request.getParameter("editEdu")); } catch (Exception ignored) {}
    try { editProj = Integer.parseInt(request.getParameter("editProj")); } catch (Exception ignored) {}
    try { editWork = Integer.parseInt(request.getParameter("editWork")); } catch (Exception ignored) {}
    try { editHonor = Integer.parseInt(request.getParameter("editHonor")); } catch (Exception ignored) {}
    boolean showEduForm = !preview && ("edu".equals(open) || editEdu >= 0);
    boolean showWorkForm = !preview && ("work".equals(open) || editWork >= 0);
    boolean showSkillForm = !preview && "skill".equals(open);
    boolean showHonorForm = !preview && ("honor".equals(open) || editHonor >= 0);
    boolean showEvalForm = !preview && "eval".equals(open);
    boolean showProjForm = !preview && ("proj".equals(open) || editProj >= 0);
    ResumeBlocks.Edu eduEdit = new ResumeBlocks.Edu();
    if (editEdu >= 0 && editEdu < eduList.size()) eduEdit = eduList.get(editEdu);
    ResumeBlocks.Proj projEdit = new ResumeBlocks.Proj();
    if (editProj >= 0 && editProj < projList.size()) projEdit = projList.get(editProj);
    ResumeBlocks.Work workEdit = new ResumeBlocks.Work();
    if (editWork >= 0 && editWork < workList.size()) workEdit = workList.get(editWork);
    String honorEdit = (editHonor >= 0 && editHonor < honorList.size()) ? honorList.get(editHonor) : "";
    java.util.List<ResumeBlocks.Bar> formBars = new java.util.ArrayList<>(skills.bars);
    while (formBars.size() < 3) {
        formBars.add(new ResumeBlocks.Bar());
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page wide">
<% if (applicant == null) { %>
<jsp:include page="/common/applicant-gate.jsp"/>
<% } else { %>
<jsp:include page="/common/resume-tabs.jsp"/>
<% if (resumeMsg != null) { %><p class="ok"><%= resumeMsg %></p><% } %>
<div class="resume-layout">
    <div class="cv-paper">
        <div class="sec">
            <div class="sec-head">
                <h2>基本信息</h2>
                <% if (!preview) { %><a class="btn-lite" href="<%= ctx %>/resume/edit">修改</a><% } %>
            </div>
            <div class="info-photo">
                <table class="info-table">
                    <tr><th>姓名：</th><td><%= name %></td></tr>
                    <tr><th>性别：</th><td><%= gender %></td></tr>
                    <tr><th>出生日期：</th><td><%= birthday %></td></tr>
                    <tr><th>当前所在地：</th><td><%= currentLoc %></td></tr>
                    <tr><th>户口所在地：</th><td><%= residentLoc %></td></tr>
                    <tr><th>手机：</th><td><%= phone %></td></tr>
                    <tr><th>邮件：</th><td><%= email %></td></tr>
                    <tr><th>求职意向：</th><td><%= intent %></td></tr>
                </table>
                <div class="photo-box">
                    <img src="<%= photoUrl %>" alt="简历照片">
                    <% if (!preview) { %>
                    <form method="post" action="<%= ctx %>/resume/photo" enctype="multipart/form-data">
                        <label class="change">更换照片
                            <input type="file" name="photo" accept=".png,.jpg,.jpeg" style="display:none" onchange="this.form.submit()">
                        </label>
                    </form>
                    <% } %>
                </div>
            </div>
        </div>

        <section class="cv-sec" id="edu">
            <div class="cv-banner">教育背景<% if (!preview) { %><a href="<%= ctx %>/resume/?open=edu#edu">添加</a><% } %></div>
            <% if (eduList.isEmpty()) { %><p class="muted cv-empty">暂未填写教育背景。</p><% } %>
            <% for (int i = 0; i < eduList.size(); i++) {
                ResumeBlocks.Edu e = eduList.get(i); %>
            <div class="cv-block">
                <div class="cv-row">
                    <span><%= e.years %></span>
                    <b><%= e.school %></b>
                    <em><%= e.major %><%= e.degree.isEmpty() ? "" : "（" + e.degree + "）" %></em>
                </div>
                <% if (!e.gpa.isEmpty()) { %><p>专业成绩：<%= e.gpa %></p><% } %>
                <% if (!e.courses.isEmpty()) { %><p>主修课程：<%= e.courses %></p><% } %>
                <% if (!preview) { %>
                <div class="record-ops">
                    <a class="btn-lite" href="<%= ctx %>/resume/?editEdu=<%= i %>#edu">修改</a>
                    <form method="post" action="<%= ctx %>/resume/edu">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="index" value="<%= i %>">
                        <button class="btn-danger" type="submit">删除</button>
                    </form>
                </div>
                <% } %>
            </div>
            <% } %>
            <% if (showEduForm) { %>
            <form class="editor-card" method="post" action="<%= ctx %>/resume/edu">
                <h3><%= editEdu >= 0 ? "修改教育背景" : "添加教育背景" %></h3>
                <input type="hidden" name="index" value="<%= editEdu %>">
                <div class="form-row">
                    <div class="form-col"><label>学校</label><input class="input" name="school" value="<%= eduEdit.school %>" required></div>
                    <div class="form-col"><label>专业</label><input class="input" name="major" value="<%= eduEdit.major %>"></div>
                </div>
                <div class="form-row">
                    <div class="form-col"><label>学历</label><input class="input" name="degree" value="<%= eduEdit.degree %>" placeholder="本科 / 硕士"></div>
                    <div class="form-col"><label>时间</label>
                        <div class="range-pair js-daterange">
                            <input type="hidden" name="years" value="<%= eduEdit.years %>">
                            <input class="input js-date-start" readonly placeholder="开始年月日">
                            <span class="range-tilde">至</span>
                            <input class="input js-date-end" readonly placeholder="结束年月日">
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-col"><label>专业成绩</label><input class="input" name="gpa" value="<%= eduEdit.gpa %>" placeholder="如 GPA 3.66/4（专业前5%）"></div>
                </div>
                <div class="form-row">
                    <div class="form-col"><label>主修课程</label>
                        <textarea class="input" name="courses" placeholder="用顿号分隔课程名称"><%= eduEdit.courses %></textarea>
                    </div>
                </div>
                <div class="actions">
                    <button class="primary inline" type="submit">保存教育背景</button>
                    <a class="btn-lite" href="<%= ctx %>/resume/#edu">取消</a>
                </div>
            </form>
            <% } %>
        </section>

        <section class="cv-sec" id="work">
            <div class="cv-banner">工作经历<% if (!preview) { %><a href="<%= ctx %>/resume/?open=work#work">添加</a><% } %></div>
            <% if (workList.isEmpty()) { %><p class="muted cv-empty">暂未填写工作经历。</p><% } %>
            <% for (int i = 0; i < workList.size(); i++) {
                ResumeBlocks.Work w = workList.get(i); %>
            <div class="cv-block">
                <div class="cv-row">
                    <span><%= w.period %></span>
                    <b><%= w.company %></b>
                    <em><%= w.title %></em>
                </div>
                <ul>
                    <% for (String duty : ResumeBlocks.dutiesOf(w)) { %><li><%= duty %></li><% } %>
                </ul>
                <% if (!preview) { %>
                <div class="record-ops">
                    <a class="btn-lite" href="<%= ctx %>/resume/?editWork=<%= i %>#work">修改</a>
                    <form method="post" action="<%= ctx %>/resume/work">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="index" value="<%= i %>">
                        <button class="btn-danger" type="submit">删除</button>
                    </form>
                </div>
                <% } %>
            </div>
            <% } %>
            <% if (showWorkForm) { %>
            <form class="editor-card" method="post" action="<%= ctx %>/resume/work">
                <h3><%= editWork >= 0 ? "修改工作经历" : "添加工作经历" %></h3>
                <input type="hidden" name="index" value="<%= editWork %>">
                <div class="form-row">
                    <div class="form-col"><label>公司</label><input class="input" name="company" value="<%= workEdit.company %>" required></div>
                    <div class="form-col"><label>职位</label><input class="input" name="title" value="<%= workEdit.title %>"></div>
                </div>
                <div class="form-row">
                    <div class="form-col"><label>时间</label>
                        <div class="range-pair js-daterange">
                            <input type="hidden" name="period" value="<%= workEdit.period %>">
                            <input class="input js-date-start" readonly placeholder="开始年月日">
                            <span class="range-tilde">至</span>
                            <input class="input js-date-end" readonly placeholder="结束年月日">
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-col"><label>工作内容</label>
                        <textarea class="input" name="duties" placeholder="每行一条职责"><%= ResumeBlocks.dutiesToLines(workEdit.duties) %></textarea>
                    </div>
                </div>
                <div class="actions">
                    <button class="primary inline" type="submit">保存工作经历</button>
                    <a class="btn-lite" href="<%= ctx %>/resume/#work">取消</a>
                </div>
            </form>
            <% } %>
        </section>

        <section class="cv-sec" id="skill">
            <div class="cv-banner">技能特长<% if (!preview) { %><a href="<%= ctx %>/resume/?open=skill#skill">编辑</a><% } %></div>
            <% if (!hasSkill && !showSkillForm) { %><p class="muted cv-empty">暂未填写技能特长。</p><% } %>
            <% if (hasSkill) { %>
            <div class="cv-block">
                <% if (!skills.language.isEmpty()) { %><p><b>语言能力：</b><%= skills.language %></p><% } %>
                <% if (!skills.computer.isEmpty()) { %><p><b>计算机：</b><%= skills.computer %></p><% } %>
                <% if (!skills.team.isEmpty()) { %><p><b>团队能力：</b><%= skills.team %></p><% } %>
                <% if (!skills.bars.isEmpty()) { %>
                <div class="cv-meters">
                    <% for (ResumeBlocks.Bar bar : skills.bars) { %>
                    <div class="cv-meter">
                        <b><%= bar.name %></b>
                        <i><s style="width:<%= ResumeBlocks.barPercent(bar.level) %>%"></s></i>
                        <em><%= bar.level %></em>
                    </div>
                    <% } %>
                </div>
                <% } %>
            </div>
            <% } %>
            <% if (showSkillForm) { %>
            <form class="editor-card" method="post" action="<%= ctx %>/resume/skill">
                <h3>编辑技能特长</h3>
                <div class="form-row"><div class="form-col"><label>语言能力</label><textarea class="input" name="language"><%= skills.language %></textarea></div></div>
                <div class="form-row"><div class="form-col"><label>计算机</label><textarea class="input" name="computer"><%= skills.computer %></textarea></div></div>
                <div class="form-row"><div class="form-col"><label>团队能力</label><textarea class="input" name="team"><%= skills.team %></textarea></div></div>
                <% for (int i = 0; i < formBars.size(); i++) {
                    ResumeBlocks.Bar bar = formBars.get(i); %>
                <div class="form-row">
                    <div class="form-col"><label>技能条 <%= i + 1 %></label><input class="input" name="barName" value="<%= bar.name %>" placeholder="如 Java / 英语"></div>
                    <div class="form-col"><label>掌握程度</label>
                        <select class="input" name="barLevel">
                            <option value="" <%= bar.level.isEmpty() ? "selected" : "" %>>请选择</option>
                            <option <%= "精通".equals(bar.level) ? "selected" : "" %>>精通</option>
                            <option <%= "熟练".equals(bar.level) ? "selected" : "" %>>熟练</option>
                            <option <%= "良好".equals(bar.level) ? "selected" : "" %>>良好</option>
                            <option <%= "一般".equals(bar.level) ? "selected" : "" %>>一般</option>
                        </select>
                    </div>
                </div>
                <% } %>
                <div class="actions">
                    <button class="primary inline" type="submit">保存技能特长</button>
                    <a class="btn-lite" href="<%= ctx %>/resume/#skill">取消</a>
                </div>
            </form>
            <% } %>
        </section>

        <section class="cv-sec" id="honor">
            <div class="cv-banner">荣誉证书<% if (!preview) { %><a href="<%= ctx %>/resume/?open=honor#honor">添加</a><% } %></div>
            <% if (honorList.isEmpty()) { %><p class="muted cv-empty">暂未填写荣誉证书。</p><% } %>
            <% if (!honorList.isEmpty()) { %>
            <ul class="cv-bullets">
                <% for (int i = 0; i < honorList.size(); i++) { %>
                <li>
                    <%= honorList.get(i) %>
                    <% if (!preview) { %>
                    <span class="record-ops">
                        <a class="btn-lite" href="<%= ctx %>/resume/?editHonor=<%= i %>#honor">修改</a>
                        <form method="post" action="<%= ctx %>/resume/honor">
                            <input type="hidden" name="action" value="delete">
                            <input type="hidden" name="index" value="<%= i %>">
                            <button class="btn-danger" type="submit">删除</button>
                        </form>
                    </span>
                    <% } %>
                </li>
                <% } %>
            </ul>
            <% } %>
            <% if (showHonorForm) { %>
            <form class="editor-card" method="post" action="<%= ctx %>/resume/honor">
                <h3><%= editHonor >= 0 ? "修改荣誉证书" : "添加荣誉证书" %></h3>
                <input type="hidden" name="index" value="<%= editHonor %>">
                <div class="form-row"><div class="form-col"><label>内容</label><input class="input" name="honor" value="<%= honorEdit %>" required></div></div>
                <div class="actions">
                    <button class="primary inline" type="submit">保存</button>
                    <a class="btn-lite" href="<%= ctx %>/resume/#honor">取消</a>
                </div>
            </form>
            <% } %>
        </section>

        <section class="cv-sec" id="eval">
            <div class="cv-banner">自我评价<% if (!preview) { %><a href="<%= ctx %>/resume/?open=eval#eval">编辑</a><% } %></div>
            <% if (!hasEval && !showEvalForm) { %><p class="muted cv-empty">暂未填写自我评价。</p><% } %>
            <% if (hasEval) { %><div class="cv-block"><p><%= selfEval %></p></div><% } %>
            <% if (showEvalForm) { %>
            <form class="editor-card" method="post" action="<%= ctx %>/resume/eval">
                <h3>编辑自我评价</h3>
                <div class="form-row"><div class="form-col">
                    <textarea class="input" name="self_eval" placeholder="工作态度、能力特点、职业目标"><%= selfEval %></textarea>
                </div></div>
                <div class="actions">
                    <button class="primary inline" type="submit">保存自我评价</button>
                    <a class="btn-lite" href="<%= ctx %>/resume/#eval">取消</a>
                </div>
            </form>
            <% } %>
        </section>

        <section class="cv-sec" id="proj">
            <div class="cv-banner">项目经验<% if (!preview) { %><a href="<%= ctx %>/resume/?open=proj#proj">添加</a><% } %></div>
            <% if (projList.isEmpty()) { %><p class="muted cv-empty">暂未填写项目经验。</p><% } %>
            <% for (int i = 0; i < projList.size(); i++) {
                ResumeBlocks.Proj p = projList.get(i); %>
            <div class="cv-block">
                <div class="cv-row">
                    <span><%= p.period %></span>
                    <b><%= p.name %></b>
                    <em><%= p.role %></em>
                </div>
                <% if (p.desc != null && !p.desc.isEmpty()) { %><p><%= p.desc %></p><% } %>
                <% if (!preview) { %>
                <div class="record-ops">
                    <a class="btn-lite" href="<%= ctx %>/resume/?editProj=<%= i %>#proj">修改</a>
                    <form method="post" action="<%= ctx %>/resume/proj">
                        <input type="hidden" name="action" value="delete">
                        <input type="hidden" name="index" value="<%= i %>">
                        <button class="btn-danger" type="submit">删除</button>
                    </form>
                </div>
                <% } %>
            </div>
            <% } %>
            <% if (showProjForm) { %>
            <form class="editor-card" method="post" action="<%= ctx %>/resume/proj">
                <h3><%= editProj >= 0 ? "修改项目经验" : "添加项目经验" %></h3>
                <input type="hidden" name="index" value="<%= editProj %>">
                <div class="form-row">
                    <div class="form-col"><label>项目名称</label><input class="input" name="name" value="<%= projEdit.name %>"></div>
                    <div class="form-col"><label>担任角色</label><input class="input" name="role" value="<%= projEdit.role %>"></div>
                </div>
                <div class="form-row">
                    <div class="form-col"><label>时间</label>
                        <div class="range-pair js-daterange">
                            <input type="hidden" name="period" value="<%= projEdit.period %>">
                            <input class="input js-date-start" readonly placeholder="开始年月日">
                            <span class="range-tilde">至</span>
                            <input class="input js-date-end" readonly placeholder="结束年月日">
                        </div>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-col"><label>项目描述</label>
                        <textarea class="input" name="desc" placeholder="技术栈、职责、成果"><%= projEdit.desc %></textarea>
                    </div>
                </div>
                <div class="actions">
                    <button class="primary inline" type="submit">保存项目经验</button>
                    <a class="btn-lite" href="<%= ctx %>/resume/#proj">取消</a>
                </div>
            </form>
            <% } %>
        </section>
    </div>

    <aside class="side-panel">
        <a class="primary side-btn" href="<%= ctx %>/resume/preview">PDF 预览</a>
        <a class="btn-lite side-btn" href="<%= ctx %>/resume/pdf?dl=1">导出 PDF</a>
        <% if (!preview) { %>
        <a class="btn-lite side-btn" href="<%= ctx %>/resume/edit">编辑基本信息</a>
        <% } else { %>
        <a class="btn-lite side-btn" href="<%= ctx %>/resume/">返回编辑</a>
        <% } %>
        <div class="complete-box">简历完整度<b><%= totalScore %>%</b></div>
        <div class="side-item"><span>基本信息</span><span class="<%= hasBasic ? "ok" : "wait" %>"><%= hasBasic ? "已填写" : "暂未填写" %></span></div>
        <div class="side-item"><span>教育背景</span><span class="<%= hasEdu ? "ok" : "wait" %>"><%= hasEdu ? "已填写" : "暂未填写" %></span></div>
        <div class="side-item"><span>工作经历</span><span class="<%= hasWork ? "ok" : "wait" %>"><%= hasWork ? "已填写" : "暂未填写" %></span></div>
        <div class="side-item"><span>技能特长</span><span class="<%= hasSkill ? "ok" : "wait" %>"><%= hasSkill ? "已填写" : "暂未填写" %></span></div>
        <div class="side-item"><span>荣誉证书</span><span class="<%= hasHonor ? "ok" : "wait" %>"><%= hasHonor ? "已填写" : "暂未填写" %></span></div>
        <div class="side-item"><span>自我评价</span><span class="<%= hasEval ? "ok" : "wait" %>"><%= hasEval ? "已填写" : "暂未填写" %></span></div>
        <div class="side-item"><span>项目经验</span><span class="<%= hasProj ? "ok" : "wait" %>"><%= hasProj ? "已填写" : "暂未填写" %></span></div>
        <div class="side-item"><span>简历照片</span><span class="<%= hasPhoto ? "ok" : "wait" %>"><%= hasPhoto ? "已填写" : "暂未填写" %></span></div>
        <div class="side-item"><span>简历附件</span><span class="<%= hasAttach ? "ok" : "wait" %>"><%= hasAttach ? "已填写" : "暂未填写" %></span></div>
        <% if (!preview) { %>
        <form method="post" action="<%= ctx %>/resume/upload" enctype="multipart/form-data" style="margin-top:12px">
            <label class="upload">上传附件
                <input type="file" name="file" accept=".pdf,.doc,.docx,.png,.jpg,.jpeg" style="display:none" onchange="this.form.submit()">
            </label>
        </form>
        <% if (hasAttach) { %>
        <p class="muted" style="margin-top:8px"><a href="<%= ctx %><%= resume.getAttachment() %>" target="_blank">查看已上传附件</a></p>
        <% } %>
        <% } %>
    </aside>
</div>
<% } %>
</main>
<jsp:include page="/common/footer.jsp"/>
