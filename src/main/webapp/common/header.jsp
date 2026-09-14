<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.User" %>
<%@ page import="com.qitoffer.util.AuthSupport" %>
<%
    String ctx = request.getContextPath();
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    String headerMode = (String) request.getAttribute("headerMode");
    String navKey = (String) request.getAttribute("navKey");
    if (navKey == null) {
        navKey = "";
    }
    boolean loginHeader = "login".equals(headerMode);
    String realm = AuthSupport.navRealm(request);
    boolean companyNav = "company".equals(realm);
    boolean adminNav = "admin".equals(realm);
    boolean applicantNav = "applicant".equals(realm);
    boolean publicCompany = "public-company".equals(realm);
    boolean publicAdmin = "public-admin".equals(realm);
    boolean showBell = applicantNav || companyNav || adminNav || publicCompany || publicAdmin;
    String brandHref = ctx + "/job/search";
    if (adminNav) {
        brandHref = ctx + "/manage/user.jsp";
    } else if (companyNav) {
        brandHref = ctx + "/company/dashboard";
    }
    String whoName = "";
    String whoRole = "";
    if (applicantNav && applicant != null) {
        whoRole = "求职者";
        whoName = applicant.getApplicantName() != null && !applicant.getApplicantName().isEmpty()
                ? applicant.getApplicantName() : applicant.getApplicantPhone();
    } else if (backend != null) {
        whoRole = backend.getUserRole() == Dict.ROLE_ADMIN ? "管理员" : "企业";
        whoName = backend.getUserRealname() != null && !backend.getUserRealname().isEmpty()
                ? backend.getUserRealname() : backend.getUserLogname();
    }
%>
<header class="top <%= adminNav ? "top-admin" : "" %>">
    <a class="brand" href="<%= brandHref %>"><i></i>锐聘</a>
    <nav class="nav <%= adminNav ? "nav-admin" : "" %>">
        <% if (adminNav) { %>
        <a class="<%= "users".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/user.jsp">用户</a>
        <a class="<%= "companies".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/company.jsp">企业</a>
        <a class="<%= "jobs".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/job.jsp">职位</a>
        <a class="<%= "applies".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/apply.jsp">申请</a>
        <a class="<%= "resumes".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/resume.jsp">简历</a>
        <a class="<%= "online".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/online.jsp">在线</a>
        <a class="<%= "password".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/manage/password.jsp">密码</a>
        <% } else if (companyNav) { %>
        <a class="<%= "workbench".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/company/dashboard">工作台</a>
        <a class="<%= "jobs".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/company/job.jsp">职位</a>
        <a class="<%= "talk".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/talk">沟通</a>
        <a class="<%= "profile".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/company/profile.jsp">资料</a>
        <% } else if (applicantNav) { %>
        <a class="<%= "jobs".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/job/search">首页</a>
        <a class="<%= ("center".equals(navKey) || "apply".equals(navKey) || "fav".equals(navKey)) ? "on" : "" %>" href="<%= ctx %>/resume/">我的</a>
        <a class="<%= "talk".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/talk">沟通</a>
        <% } else { %>
        <a class="<%= "jobs".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/job/search">首页</a>
        <% if (publicCompany || publicAdmin) { %>
        <a class="<%= "talk".equals(navKey) ? "on" : "" %>" href="<%= ctx %>/talk">沟通</a>
        <a href="<%= publicAdmin ? ctx + "/manage/" : ctx + "/company/dashboard" %>">工作台</a>
        <% } else { %>
        <a href="<%= ctx %>/login?view=company">招人才</a>
        <% } %>
        <% } %>
    </nav>
    <% if (loginHeader) { %>
    <span class="help">使用说明</span>
    <% } else if (applicantNav || companyNav || adminNav || publicCompany || publicAdmin) { %>
    <div class="who">
        <% if (showBell) { %>
        <div class="bell-wrap" id="msgBellWrap">
            <button type="button" class="bell-btn" id="msgBellBtn" aria-label="站内消息" aria-expanded="false">
                <svg viewBox="0 0 24 24" width="20" height="20" aria-hidden="true">
                    <path fill="currentColor" d="M12 22a2.2 2.2 0 0 0 2.2-2.2h-4.4A2.2 2.2 0 0 0 12 22zm7-6.2V11a7 7 0 1 0-14 0v4.8L3 18v1h18v-1l-2-2.2z"/>
                </svg>
                <span class="badge bell-badge hidden" id="msgBell">0</span>
            </button>
            <div class="bell-pop hidden" id="msgBellPop" role="dialog" aria-label="站内消息">
                <div class="bell-pop-hd">
                    <strong>站内消息</strong>
                    <button type="button" class="bell-link" id="msgReadAll">全部已读</button>
                </div>
                <div class="bell-pop-list" id="msgBellList">
                    <div class="bell-empty">加载中…</div>
                </div>
            </div>
        </div>
        <% } %>
        <span><%= whoRole %> · <%= whoName %></span>
        <a class="help" href="<%= ctx %>/logout">退出</a>
    </div>
    <% if (showBell) { %>
    <script>
    (function () {
      var ctx = "<%= ctx %>";
      var btn = document.getElementById("msgBellBtn");
      var pop = document.getElementById("msgBellPop");
      var badge = document.getElementById("msgBell");
      var list = document.getElementById("msgBellList");
      var readAll = document.getElementById("msgReadAll");
      if (!btn || !pop) return;

      function escapeHtml(s) {
        return String(s == null ? "" : s)
          .replace(/&/g, "&amp;").replace(/</g, "&lt;").replace(/>/g, "&gt;")
          .replace(/"/g, "&quot;");
      }
      function highlight(s) {
        return escapeHtml(s).replace(/「([^」]+)」/g, '<span class="hl">「$1」</span>');
      }
      function setBadge(n) {
        if (!badge) return;
        if (n > 0) {
          badge.textContent = n > 99 ? "99+" : String(n);
          badge.classList.remove("hidden");
        } else {
          badge.textContent = "0";
          badge.classList.add("hidden");
        }
      }
      function render(data) {
        setBadge(data.unread || 0);
        var items = data.items || [];
        if (!items.length) {
          list.innerHTML = '<div class="bell-empty">暂无消息</div>';
          return;
        }
        list.innerHTML = items.map(function (m) {
          var unread = !!m.unread;
          return '<article class="bell-item' + (unread ? " unread" : "") + '" data-id="' + m.id + '">'
            + '<div class="bell-item-top"><span class="tag' + (unread ? "" : " off") + '">'
            + (unread ? "未读" : "已读") + '</span><time>' + escapeHtml(m.time || "") + '</time></div>'
            + '<h4>' + escapeHtml(m.title || "系统通知") + '</h4>'
            + '<p>' + highlight(m.content || "") + '</p>'
            + '</article>';
        }).join("");
      }
      function load() {
        return fetch(ctx + "/message/bell?format=json", { credentials: "same-origin" })
          .then(function (r) { return r.json(); })
          .then(render)
          .catch(function () {
            list.innerHTML = '<div class="bell-empty">消息暂时无法加载</div>';
          });
      }
      function openPop() {
        pop.classList.remove("hidden");
        btn.setAttribute("aria-expanded", "true");
        load();
      }
      function closePop() {
        pop.classList.add("hidden");
        btn.setAttribute("aria-expanded", "false");
      }
      btn.addEventListener("click", function (e) {
        e.stopPropagation();
        if (pop.classList.contains("hidden")) openPop(); else closePop();
      });
      pop.addEventListener("click", function (e) { e.stopPropagation(); });
      document.addEventListener("click", closePop);
      list.addEventListener("click", function (e) {
        var item = e.target.closest(".bell-item.unread");
        if (!item) return;
        var id = item.getAttribute("data-id");
        var body = "messageId=" + encodeURIComponent(id);
        fetch(ctx + "/message/read", {
          method: "POST",
          credentials: "same-origin",
          headers: { "Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json" },
          body: body
        }).then(function () { load(); }).catch(function () {});
      });
      if (readAll) {
        readAll.addEventListener("click", function () {
          fetch(ctx + "/message/read", {
            method: "POST",
            credentials: "same-origin",
            headers: { "Content-Type": "application/x-www-form-urlencoded", "Accept": "application/json" },
            body: "action=readAll"
          }).then(function () { load(); }).catch(function () {});
        });
      }
      fetch(ctx + "/message/bell?format=json", { credentials: "same-origin" })
        .then(function (r) { return r.json(); })
        .then(function (data) { setBadge(data.unread || 0); })
        .catch(function () {});
    })();
    </script>
    <% } %>
    <% } else { %>
    <div class="who cta">
        <a class="btn-lite" href="<%= ctx %>/login">登录</a>
        <a class="primary inline" href="<%= ctx %>/login?view=register">注册</a>
    </div>
    <% } %>
</header>
