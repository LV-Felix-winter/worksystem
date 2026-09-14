<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Pics" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="com.qitoffer.entity.Talk" %>
<%@ page import="com.qitoffer.entity.TalkMsg" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Talk> inbox = (List<Talk>) request.getAttribute("talkInbox");
    if (inbox == null) {
        inbox = Collections.emptyList();
    }
    Talk talk = (Talk) request.getAttribute("talk");
    @SuppressWarnings("unchecked")
    List<TalkMsg> messages = (List<TalkMsg>) request.getAttribute("talkMessages");
    if (messages == null) {
        messages = Collections.emptyList();
    }
    Job talkJob = (Job) request.getAttribute("talkJob");
    String mine = request.getAttribute("talkMine") == null ? "applicant" : (String) request.getAttribute("talkMine");
    boolean applicantSide = "applicant".equals(mine);
    SimpleDateFormat clock = new SimpleDateFormat("HH:mm");
    SimpleDateFormat day = new SimpleDateFormat("MM-dd HH:mm");
    String peerName = "";
    String peerLogo = ctx + "/images/logo-1.jpg";
    String myLogo = applicantSide ? ctx + Pics.PORTRAIT : ctx + "/images/logo-1.jpg";
    if (talk != null) {
        peerName = applicantSide
                ? (talk.getCompanyName() == null ? "企业招聘" : talk.getCompanyName())
                : (talk.getApplicantName() == null || talk.getApplicantName().isEmpty() ? "求职者" : talk.getApplicantName());
        peerLogo = applicantSide ? Pics.logo(talk.getCompanyId(), ctx) : ctx + Pics.PORTRAIT;
        myLogo = applicantSide ? ctx + Pics.PORTRAIT : Pics.logo(talk.getCompanyId(), ctx);
    }
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="talk-page">
<div class="talk-im">
    <aside class="im-inbox">
        <div class="im-inbox-title">消息</div>
        <div class="im-search">
            <span>⌕</span>
            <input id="talkFilter" type="search" placeholder="搜索指定联系人" autocomplete="off">
        </div>
        <div class="im-list">
            <% if (inbox.isEmpty()) { %>
            <p class="talk-empty">还没有会话。在职位卡片点「去谈谈」即可开始。</p>
            <% } %>
            <% for (Talk row : inbox) {
                boolean on = talk != null && talk.getTalkId() == row.getTalkId();
                String preview = row.getLastContent() == null ? "暂无消息" : row.getLastContent();
                if (preview.startsWith("「职位」")) {
                    preview = "[职位卡片]";
                }
                String jobHint = row.getJobName() == null ? "" : row.getJobName();
                if (!jobHint.isEmpty()) {
                    preview = jobHint + " · " + preview;
                }
                if (preview.length() > 26) {
                    preview = preview.substring(0, 26) + "…";
                }
                String name = applicantSide ? row.getCompanyName() : row.getApplicantName();
                if (name == null || name.isEmpty()) {
                    name = "未署名";
                }
                String time = row.getLastTime() == null ? "" : clock.format(row.getLastTime());
                String avatar = applicantSide ? Pics.logo(row.getCompanyId(), ctx) : ctx + Pics.PORTRAIT;
            %>
            <a class="im-item <%= on ? "on" : "" %>" data-name="<%= name %>" href="<%= ctx %>/talk?talkId=<%= row.getTalkId() %>">
                <img src="<%= avatar %>" alt="">
                <div class="im-item-body">
                    <div class="im-item-top"><b><%= name %></b><time><%= time %></time></div>
                    <em><%= preview %></em>
                </div>
            </a>
            <% } %>
        </div>
    </aside>

    <section class="im-thread">
        <% if (talk == null) { %>
        <div class="talk-blank">选择左侧联系人，或从职位卡片进入「去谈谈」。</div>
        <% } else { %>
        <header class="im-head">
            <div>
                <strong><%= peerName %></strong>
                <p>针对「<%= talk.getJobName() %>」沟通</p>
            </div>
            <a href="<%= ctx %>/job/search">没有聊到点子上？更换职位</a>
        </header>
        <div class="im-stream" id="talkBubbles">
            <div class="im-sys">
                <span>没有聊到点子上？更换职位</span>
            </div>
            <%
                Date lastStamp = null;
                for (TalkMsg m : messages) {
                    boolean mineMsg = mine.equals(m.getSenderType());
                    boolean showTime = m.getCreateTime() != null && (lastStamp == null
                            || m.getCreateTime().getTime() - lastStamp.getTime() > 8 * 60 * 1000);
                    if (m.getCreateTime() != null) {
                        lastStamp = m.getCreateTime();
                    }
                    boolean jobCard = m.getContent() != null && m.getContent().startsWith("「职位」");
            %>
            <% if (showTime) { %>
            <div class="im-time"><%= day.format(m.getCreateTime()) %></div>
            <% } %>
            <% if (jobCard) { %>
            <div class="im-jobcard">
                <img src="<%= Pics.banner(talk.getCompanyId(), ctx) %>" alt="">
                <div>
                    <b><%= talk.getJobName() %></b>
                    <p><%= talk.getJobSalary() == null ? "面议" : talk.getJobSalary() %></p>
                    <p class="muted"><%= talk.getJobArea() == null ? "" : talk.getJobArea() %></p>
                    <a href="<%= ctx %>/job/detail?id=<%= talk.getJobId() %>">查看职位</a>
                </div>
            </div>
            <% } else { %>
            <div class="im-row <%= mineMsg ? "mine" : "peer" %>">
                <img class="im-avatar" src="<%= mineMsg ? myLogo : peerLogo %>" alt="">
                <div class="im-bubble"><%= m.getContent() == null ? "" : m.getContent() %></div>
            </div>
            <% } %>
            <% } %>
            <% if (talkJob != null) { %>
            <div class="im-jobcard">
                <img src="<%= Pics.banner(talk.getCompanyId(), ctx) %>" alt="">
                <div>
                    <b><%= talk.getJobName() %></b>
                    <p class="im-price"><%= talk.getJobSalary() == null ? "面议" : talk.getJobSalary() %></p>
                    <p class="muted"><%= talk.getJobArea() == null ? "" : talk.getJobArea() %></p>
                    <form method="post" action="<%= ctx %>/talk">
                        <input type="hidden" name="talkId" value="<%= talk.getTalkId() %>">
                        <input type="hidden" name="content" value="「职位」<%= talk.getJobName() %>">
                        <button type="submit">发送职位 ›</button>
                    </form>
                </div>
            </div>
            <% } %>
        </div>
        <form class="im-composer" method="post" action="<%= ctx %>/talk">
            <input type="hidden" name="talkId" value="<%= talk.getTalkId() %>">
            <div class="im-tools">
                <span title="表情">☺</span>
                <span title="图片">▣</span>
            </div>
            <textarea name="content" maxlength="800" placeholder="请输入您想咨询的内容…" required></textarea>
            <button type="submit">发送</button>
        </form>
        <% } %>
    </section>

    <aside class="im-side">
        <% if (talk == null) { %>
        <div class="talk-blank">会话详情</div>
        <% } else { %>
        <div class="im-shop">
            <img src="<%= peerLogo %>" alt="">
            <div>
                <b><%= peerName %></b>
                <p class="muted"><%= applicantSide ? "企业招聘官" : "求职者" %></p>
            </div>
        </div>
        <div class="im-icons">
            <a href="<%= ctx %>/job/detail?id=<%= talk.getJobId() %>"><i>职</i>职位</a>
            <% if (applicantSide) { %>
            <a href="<%= ctx %>/apply/mine"><i>投</i>投递</a>
            <a href="<%= ctx %>/favorite/list"><i>藏</i>收藏</a>
            <% } else { %>
            <a href="<%= ctx %>/apply/company"><i>投</i>投递</a>
            <a href="<%= ctx %>/company/job.jsp"><i>岗</i>职位</a>
            <% } %>
            <a href="<%= ctx %>/firm?id=<%= talk.getCompanyId() %>"><i>企</i>企业</a>
        </div>
        <div class="im-order">
            <img src="<%= Pics.banner(talk.getCompanyId(), ctx) %>" alt="">
            <div>
                <b><%= talk.getJobName() %></b>
                <p class="im-price"><%= talk.getJobSalary() == null ? "面议" : talk.getJobSalary() %></p>
                <p class="muted"><%= talk.getJobArea() == null ? "—" : talk.getJobArea() %></p>
                <% if (talkJob != null) { %>
                <p class="muted">招 <%= talkJob.getJobHiringnum() %> 人 · 浏览 <%= talkJob.getJobViewnum() %></p>
                <% } %>
                <span class="im-state">沟通中</span>
            </div>
        </div>
        <div class="im-links">
            <a href="<%= ctx %>/job/detail?id=<%= talk.getJobId() %>">查看职位</a>
            <% if (applicantSide) { %>
            <a href="<%= ctx %>/job/detail?id=<%= talk.getJobId() %>">立即投递</a>
            <% } %>
            <a href="<%= ctx %>/firm?id=<%= talk.getCompanyId() %>">企业主页</a>
            <a href="<%= ctx %>/job/search">返回职位列表</a>
        </div>
        <% } %>
    </aside>
</div>
</main>
<script>
(function () {
  var box = document.getElementById("talkBubbles");
  if (box) box.scrollTop = box.scrollHeight;
  var filter = document.getElementById("talkFilter");
  if (!filter) return;
  filter.addEventListener("input", function () {
    var q = filter.value.trim().toLowerCase();
    document.querySelectorAll(".im-item").forEach(function (el) {
      var name = (el.getAttribute("data-name") || "").toLowerCase();
      el.style.display = !q || name.indexOf(q) >= 0 ? "" : "none";
    });
  });
})();
</script>
<jsp:include page="/common/footer.jsp"/>
