<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Resume" %>
<%
    request.setAttribute("pageTitle", "我的简历 · 锐聘");
    request.setAttribute("navKey", "resume");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    Resume resume = (Resume) request.getAttribute("resume");
    String ctx = request.getContextPath();
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<div class="wrap">
    <div class="page-header">
        <h1 class="page-title">#71099535 简历完整度与附件</h1>
        <p class="page-subtitle">处理人：佟乐 | 任务包含完整度计算(#71099536)与附件上传</p>
    </div>

    <% if (applicant == null) { %>
    <jsp:include page="/common/applicant-gate.jsp"/>
    <% } else { %>

    <!-- 完整度展示 -->
    <div class="completeness-card">
        <div class="ring-wrap">
            <div class="progress-ring">
                <svg width="120" height="120" viewBox="0 0 120 120">
                    <defs><linearGradient id="grad" x1="0%" y1="0%" x2="100%"><stop offset="0%" stop-color="#4facfe"/><stop offset="100%" stop-color="#00f2fe"/></linearGradient></defs>
                    <circle class="ring-bg" cx="60" cy="60" r="50"/>
                    <circle class="ring-fill" id="ring" cx="60" cy="60" r="50"/>
                </svg>
                <div class="ring-text" id="score-text">--</div>
            </div>
            <div class="ring-label">综合完整度</div>
        </div>
        <p class="tip">简历完整度越高，职位推荐越精准，面试邀约率提升约 40%</p>
    </div>

    <!-- 模块评分 -->
    <div class="card">
        <div class="card-title">简历模块评分 (#71099536)</div>
        <div id="modules">
            <div class="module-row" data-id="basic">
                <div class="mi">👤</div>
                <div class="mn"><h4>基本信息</h4><p>姓名、电话、邮箱（权重 15%）</p></div>
                <div class="bar-wrap"><div class="bar-fill" id="bar-basic" style="width:0%;background:#4facfe"></div></div>
                <span class="score-num" id="score-basic">--</span>
            </div>
            <div class="module-row" data-id="edu">
                <div class="mi">🎓</div>
                <div class="mn"><h4>教育经历</h4><p>学校、专业、学历（权重 20%）</p></div>
                <div class="bar-wrap"><div class="bar-fill" id="bar-edu" style="width:60%;background:#27ae60"></div></div>
                <span class="score-num" id="score-edu" style="color:#27ae60">60</span>
            </div>
            <div class="module-row" data-id="exp">
                <div class="mi">💼</div>
                <div class="mn"><h4>工作/实习经历</h4><p>公司名称、职位、职责（权重 25%）</p></div>
                <div class="bar-wrap"><div class="bar-fill" id="bar-exp" style="width:0%;background:#e67e22"></div></div>
                <span class="score-num" id="score-exp" style="color:#e67e22">0</span>
            </div>
            <div class="module-row" data-id="proj">
                <div class="mi">📁</div>
                <div class="mn"><h4>项目经历</h4><p>项目名称、技术栈、成果（权重 25%）</p></div>
                <div class="bar-wrap"><div class="bar-fill" id="bar-proj" style="width:0%;background:#9b59b6"></div></div>
                <span class="score-num" id="score-proj" style="color:#9b59b6">0</span>
            </div>
            <div class="module-row" data-id="skill">
                <div class="mi">🏅</div>
                <div class="mn"><h4>技能证书</h4><p>编程语言、证书、爱好（权重 15%）</p></div>
                <div class="bar-wrap"><div class="bar-fill" id="bar-skill" style="width:30%;background:#e74c3c"></div></div>
                <span class="score-num" id="score-skill" style="color:#e74c3c">30</span>
            </div>
        </div>
    </div>

    <!-- 附件上传（#71099535：仅限常见文档/图片） -->
    <div class="card">
        <div class="card-title">附件上传</div>
        <% String resumeMsg = (String) session.getAttribute("resumeMsg");
           if (resumeMsg != null) { session.removeAttribute("resumeMsg"); %>
        <div style="font-size:13px;color:#27ae60;background:#e8f8ef;padding:8px 12px;border-radius:8px;margin-bottom:10px"><%= resumeMsg %></div>
        <% } %>
        <div class="upload-area" onclick="document.getElementById('file-input').click()">
            <div style="font-size:32px;margin-bottom:8px">📎</div>
            <p>点击上传简历附件（文档 / 图片）</p>
            <p style="font-size:11px;color:#bbb;margin-top:4px">支持 PDF、DOC、DOCX、PNG、JPG，最大 10MB</p>
        </div>
        <input type="file" id="file-input" style="display:none" accept=".pdf,.doc,.docx,.png,.jpg,.jpeg" onchange="uploadFile(this)">
        <div id="attachments">
        <% if (resume != null && resume.getAttachment() != null && !resume.getAttachment().isEmpty()) { %>
            <div class="attached">📄 <a href="<%= ctx %><%= resume.getAttachment() %>" target="_blank" style="color:#4facfe"><%= resume.getAttachment() %></a> <span style="color:#27ae60">✓ 已上传</span></div>
        <% } %>
        </div>
    </div>

    <!-- 编辑按钮 -->
    <div style="text-align:center;margin-top:16px">
        <a href="<%= ctx %>/resume/edit.jsp" class="btn-edit">✏️ 编辑简历</a>
        <button class="btn-recalc" onclick="recalculate()">🔄 重新计算完整度</button>
    </div>

    <% } %>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
<script>
// 初始化完整度
(function() {
    const resume = <%= resume != null ? "{'completeness':" + resume.getCompleteness() + "}" : "{}" %>;
    const score = resume.completeness || 0;
    const c = 2 * Math.PI * 50;
    document.getElementById('ring').style.strokeDasharray = c;
    document.getElementById('ring').style.strokeDashoffset = c - (score / 100) * c;
    document.getElementById('score-text').textContent = score + '%';

    // 更新各模块分数
    document.getElementById('score-basic').textContent = Math.min(100, score + 5) + '%';
    document.getElementById('bar-basic').style.width = Math.min(100, score + 5) + '%';
})();

function recalculate() {
    fetch('<%= ctx %>/resume/recalculate', {method: 'GET'})
        .then(r => r.json())
        .then(data => {
            if (data.success) {
                alert('完整度已重新计算！');
                location.reload();
            }
        });
}

async function uploadFile(input) {
    if (input.files.length === 0) return;
    const file = input.files[0];
    if (file.size > 10 * 1024 * 1024) { alert('文件大小不能超过 10MB'); return; }
    const form = new FormData();
    form.append('file', file);
    const resp = await fetch('<%= ctx %>/resume/upload', { method: 'POST', body: form });
    if (resp.ok) {
        alert('附件上传成功，完整度已重新计算');
        location.reload();
    } else {
        alert('上传失败，请检查文件类型（PDF/Word/图片）');
    }
}
</script>
<style>
.completeness-card{background:#fff;border-radius:12px;padding:24px;margin-bottom:20px;box-shadow:0 2px 12px rgba(0,0,0,0.06);text-align:center}
.progress-ring{position:relative;width:120px;height:120px;margin:0 auto 12px}
.progress-ring svg{transform:rotate(-90deg)}
.ring-bg{fill:none;stroke:#eee;stroke-width:8}.ring-fill{fill:none;stroke:url(#grad);stroke-width:8;stroke-linecap:round;transition:stroke-dashoffset 1s}
.ring-text{position:absolute;top:50%;left:50%;transform:translate(-50%,-50%);font-size:28px;font-weight:700;color:#1a1a2e}
.ring-label{font-size:12px;color:#888}
.tip{font-size:13px;color:#4a7fb5;background:#eef4ff;padding:8px 16px;border-radius:8px;display:inline-block;margin-top:8px}
.card{background:#fff;border-radius:12px;padding:24px;margin-bottom:20px;box-shadow:0 2px 12px rgba(0,0,0,0.06)}
.card-title{font-size:15px;font-weight:600;margin-bottom:16px}
.module-row{display:flex;align-items:center;gap:12px;padding:12px 0;border-bottom:1px solid #f0f0f0}
.module-row:last-child{border-bottom:none}
.mi{font-size:20px;width:36px;text-align:center}
.mn{flex:1}.mn h4{font-size:14px;font-weight:600}.mn p{font-size:12px;color:#888}
.bar-wrap{width:100px;height:6px;background:#eee;border-radius:3px;overflow:hidden}
.bar-fill{height:100%;border-radius:3px;transition:width .5s}
.score-num{font-size:13px;font-weight:700;width:40px;text-align:right}
.upload-area{border:2px dashed #ddd;border-radius:10px;padding:24px;text-align:center;cursor:pointer;transition:all .2s}
.upload-area:hover{border-color:#4facfe;background:#f8fbff}
.upload-area p{font-size:13px;color:#888}
.attached{display:flex;align-items:center;gap:8px;padding:8px 12px;background:#f8f9fa;border-radius:6px;margin-top:8px;font-size:13px}
.btn-edit,.btn-recalc{padding:10px 24px;border-radius:8px;font-size:14px;font-weight:600;cursor:pointer;border:none;margin:0 8px;transition:all .2s}
.btn-edit{background:linear-gradient(135deg,#4facfe,#00f2fe);color:#fff}
.btn-edit:hover{opacity:.9;transform:translateY(-1px)}
.btn-recalc{background:#fff;color:#4facfe;border:1px solid #4facfe}
.btn-recalc:hover{background:#f0f8ff}
</style>
