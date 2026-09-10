<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Apply" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "我的投递 · 锐聘");
    request.setAttribute("navKey", "apply");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    List<Apply> applies = (List<Apply>) request.getAttribute("applies");
    Integer pending = (Integer) request.getAttribute("pending");
    Integer reviewing = (Integer) request.getAttribute("reviewing");
    Integer accepted = (Integer) request.getAttribute("accepted");
    Integer rejected = (Integer) request.getAttribute("rejected");
    String ctx = request.getContextPath();
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<div class="wrap">
    <div class="page-header">
        <h1 class="page-title">#71099538 投递状态流转与跟踪</h1>
        <p class="page-subtitle">处理人：佟乐 | 实时追踪每一份投递的最新进展</p>
    </div>

    <% if (applicant == null) { %>
    <jsp:include page="/common/applicant-gate.jsp"/>
    <% } else { %>

    <!-- 统计卡片 -->
    <div class="stats-row">
        <div class="stat-mini pend"><div class="num" id="stat-pending"><%= pending != null ? pending : 0 %></div><div class="label">已投递</div></div>
        <div class="stat-mini revi"><div class="num" id="stat-reviewing"><%= reviewing != null ? reviewing : 0 %></div><div class="label">审核中</div></div>
        <div class="stat-mini acc"><div class="num" id="stat-accepted"><%= accepted != null ? accepted : 0 %></div><div class="label">已通过</div></div>
        <div class="stat-mini rej"><div class="num" id="stat-rejected"><%= rejected != null ? rejected : 0 %></div><div class="label">未通过</div></div>
    </div>

    <!-- 状态说明 -->
    <div class="status-guide">
        <div class="guide-item pe"><span class="g-icon">📤</span><span class="g-label">已投递</span><span class="g-desc">简历已发送，等待HR筛选</span></div>
        <div class="guide-item re"><span class="g-icon">🔍</span><span class="g-label">审核中</span><span class="g-desc">简历通过初筛，进入面试评估</span></div>
        <div class="guide-item ac"><span class="g-icon">✅</span><span class="g-label">已通过</span><span class="g-desc">面试通过，等待 offer</span></div>
        <div class="guide-item rj"><span class="g-icon">❌</span><span class="g-label">未通过</span><span class="g-desc">暂未通过，可继续投递其他职位</span></div>
    </div>

    <!-- 投递时间线 -->
    <div class="card">
        <div class="card-title">投递时间线 (#71099540)</div>
        <div id="timeline" class="timeline">
            <% if (applies != null && !applies.isEmpty()) {
                for (Apply a : applies) {
                    String statusLabel = "";
                    String statusCls = "";
                    switch(a.getApplyState()) {
                        case Dict.APPLY_PENDING: statusLabel="已投递"; statusCls="pe"; break;
                        case Dict.APPLY_VIEWED: statusLabel="审核中"; statusCls="re"; break;
                        case Dict.APPLY_INTERVIEW: statusLabel="已通过"; statusCls="ac"; break;
                        case Dict.APPLY_REJECTED: statusLabel="未通过"; statusCls="rj"; break;
                        default: statusLabel="已投递"; statusCls="pe";
                    }
                    String desc = "";
                    switch(a.getApplyState()) {
                        case Dict.APPLY_PENDING: desc="简历已成功投递至企业，等待HR筛选，预计3-5个工作日有反馈"; break;
                        case Dict.APPLY_VIEWED: desc="您的简历已通过初筛，正在进入面试评估环节"; break;
                        case Dict.APPLY_INTERVIEW: desc="恭喜！您已通过该职位的面试，正在推进Offer发放流程"; break;
                        case Dict.APPLY_REJECTED: desc="感谢关注，本次暂未通过筛选，祝您早日找到理想工作"; break;
                        default: desc="简历已成功投递至企业";
                    }
            %>
            <div class="t-item">
                <div class="t-dot <%= statusCls %>"><%= statusCls.equals("pe")?"📤":statusCls.equals("re")?"🔍":statusCls.equals("ac")?"✅":"❌" %></div>
                <div class="t-content">
                    <div class="t-title"><%= a.getCompanyName() != null ? a.getCompanyName() : "" %> · <%= a.getJobName() %></div>
                    <div class="t-meta"><%= a.getApplyDate() != null ? a.getApplyDate().toLocaleString() : "" %> · <span class="s-tag <%= statusCls %>"><%= statusLabel %></span></div>
                    <div class="t-desc"><%= desc %></div>
                </div>
            </div>
            <% }
            } else { %>
            <div class="empty-timeline">
                <div style="font-size:48px;margin-bottom:12px">📭</div>
                <p>暂无投递记录</p>
                <a href="<%= ctx %>/job/list" class="btn-go">去浏览职位 →</a>
            </div>
            <% } %>
        </div>
    </div>

    <% } %>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
<script>
// 异步刷新统计 (#71099538)
(function() {
    fetch('<%= ctx %>/apply/stats')
        .then(r => r.json())
        .then(data => {
            if (data.pending !== undefined) {
                document.getElementById('stat-pending').textContent = data.pending;
                document.getElementById('stat-reviewing').textContent = data.reviewing;
                document.getElementById('stat-accepted').textContent = data.accepted;
                document.getElementById('stat-rejected').textContent = data.rejected;
            }
        });
})();
</script>
<style>
.stats-row{display:grid;grid-template-columns:repeat(4,1fr);gap:12px;margin-bottom:20px}
.stat-mini{background:#fff;border-radius:10px;padding:14px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,0.05)}
.stat-mini .num{font-size:22px;font-weight:700}.stat-mini .label{font-size:12px;color:#888;margin-top:4px}
.stat-mini.pend .num{color:#e67e22}.stat-mini.revi .num{color:#4facfe}.stat-mini.acc .num{color:#27ae60}.stat-mini.rej .num{color:#e74c3c}
.status-guide{display:flex;gap:12px;margin-bottom:20px;flex-wrap:wrap}
.guide-item{flex:1;min-width:140px;background:#fff;border-radius:10px;padding:14px;display:flex;align-items:center;gap:10px;box-shadow:0 2px 8px rgba(0,0,0,0.05)}
.g-icon{font-size:22px}.g-label{font-size:13px;font-weight:600}.g-desc{font-size:11px;color:#888;margin-left:auto}
.guide-item.pe .g-label{color:#e67e22}.guide-item.re .g-label{color:#4facfe}.guide-item.ac .g-label{color:#27ae60}.guide-item.rj .g-label{color:#e74c3c}
.card{background:#fff;border-radius:12px;padding:24px;margin-bottom:20px;box-shadow:0 2px 12px rgba(0,0,0,0.06)}
.card-title{font-size:15px;font-weight:600;margin-bottom:16px}
.timeline{position:relative;padding-left:28px}
.timeline::before{content:"";position:absolute;left:13px;top:0;bottom:0;width:2px;background:#e0e0e0}
.t-item{position:relative;padding:0 0 20px 0}
.t-item:last-child{padding-bottom:0}
.t-dot{position:absolute;left:-28px;top:4px;width:28px;height:28px;border-radius:50%;display:flex;align-items:center;justify-content:center;font-size:14px}
.t-dot.pe{background:#fff3e8}.t-dot.re{background:#eef4ff}.t-dot.ac{background:#e8f8ef}.t-dot.rj{background:#ffeaea}
.t-content{background:#f8f9fa;border-radius:10px;padding:14px}
.t-title{font-size:14px;font-weight:600}.t-meta{font-size:12px;color:#888;margin-top:4px}
.t-desc{font-size:13px;color:#555;margin-top:8px;line-height:1.6}
.s-tag{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;font-weight:600;margin-left:8px}
.s-tag.pe{background:#fff3e8;color:#e67e22}.s-tag.re{background:#eef4ff;color:#4facfe}
.s-tag.ac{background:#e8f8ef;color:#27ae60}.s-tag.rj{background:#ffeaea;color:#e74c3c}
.empty-timeline{text-align:center;padding:40px 0}
.empty-timeline p{color:#aaa;font-size:14px;margin-bottom:16px}
.btn-go{display:inline-block;padding:10px 24px;background:linear-gradient(135deg,#4facfe,#00f2fe);color:#fff;border-radius:8px;font-size:14px;font-weight:600;text-decoration:none}
.btn-go:hover{opacity:.9}
</style>
