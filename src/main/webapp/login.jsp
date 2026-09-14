<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    String ctx = request.getContextPath();
    String view = request.getParameter("view");
    String tab = request.getParameter("tab");
    String err = request.getParameter("err");
    if (view == null || view.isEmpty()) {
        view = "applicant";
    }
    if (tab == null || tab.isEmpty()) {
        tab = "sms";
    }
    String errText = "";
    if ("sms".equals(err)) {
        errText = "短信验证码不正确，演示验证码为 246810。";
    } else if ("imgcode".equals(err)) {
        errText = "图形验证码不正确，请点击图片刷新后重试。";
    } else if ("phone".equals(err)) {
        errText = "请输入 11 位大陆手机号。";
    } else if ("login".equals(err)) {
        errText = "账号或密码不正确。";
    } else if ("noreg".equals(err)) {
        errText = "该手机号尚未注册，请先注册。";
    } else if ("exist".equals(err)) {
        errText = "该手机号已注册，请直接登录。";
    } else if ("company".equals(err)) {
        errText = "企业名称与账号不匹配。";
    } else if ("disabled".equals(err)) {
        errText = "账号已禁用。";
    } else if ("name".equals(err)) {
        errText = "请填写姓名。";
    } else if ("param".equals(err)) {
        errText = "admin".equals(view) ? "请填写管理员账号和密码。" : "请完整填写企业名称、手机号和密码。";
    } else if ("server".equals(err)) {
        errText = "服务暂时不可用，请稍后重试。";
    } else if ("auth".equals(err)) {
        errText = "请先登录后再访问该页面。";
    } else if ("role".equals(err)) {
        errText = "该账号不是管理员，请使用管理员入口登录。";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>锐聘 · 招聘平台登录</title>
    <link rel="stylesheet" href="<%= ctx %>/common/login.css?v=admin-console-1">
</head>
<body class="page-login">
<div class="login-ambient" aria-hidden="true">
    <div class="login-grid"></div>
    <div class="login-blob b1"></div>
    <div class="login-blob b2"></div>
    <div class="login-blob b3"></div>
    <canvas id="loginParticles"></canvas>
</div>
<% request.setAttribute("headerMode", "login"); %>
<jsp:include page="/common/header.jsp"/>

<main class="stage">
    <section class="hero">
        <div class="kicker"><%= "admin".equals(view) ? "管理后台 · 登录" : "招聘平台 · 登录" %></div>
        <h1><%= "admin".equals(view) ? "系统管理入口" : "好工作，当面谈" %></h1>
        <p><%= "admin".equals(view)
                ? "仅限管理员账号。用户、企业、职位、申请与简历集中在此维护。"
                : "求职者投递与沟通，企业发布职位、筛选候选人。同一个入口，按身份切换，互不串号。" %></p>
        <img class="hero-photo" alt="办公沟通"
             src="https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=1200&q=80">
        <div class="caption">照片 Brooke Cagle，Unsplash</div>
    </section>

    <section class="panel" id="panel">
        <% if (!errText.isEmpty()) { %>
        <p class="err"><%= errText %></p>
        <% } %>

        <div id="view-applicant" class="view <%= "applicant".equals(view) ? "" : "hidden" %>">
            <div class="role">
                <button type="button" class="on" data-go="applicant">求职者</button>
                <button type="button" data-go="company">企业招聘</button>
            </div>
            <h2>欢迎回来</h2>
            <p class="lead">登录后继续投递、沟通和下一次面试安排。</p>
            <div class="tabs">
                <button type="button" class="tab-btn <%= "sms".equals(tab) ? "on" : "" %>" data-tab="sms">验证码登录</button>
                <button type="button" class="tab-btn <%= "pwd".equals(tab) ? "on" : "" %>" data-tab="pwd">密码登录</button>
            </div>
            <form method="post" action="<%= ctx %>/auth/applicant" id="form-applicant-sms" class="<%= "sms".equals(tab) ? "" : "hidden" %>">
                <input type="hidden" name="mode" value="sms">
                <label>手机号</label>
                <div class="phone"><span>+86</span><input name="phone" maxlength="11" placeholder="11 位大陆手机号" autocomplete="tel"></div>
                <label>短信验证码</label>
                <div class="sms-row">
                    <div class="field"><input name="smsCode" maxlength="6" placeholder="6 位数字"></div>
                    <button type="button" class="btn-lite js-sms">获取验证码</button>
                </div>
                <label class="agree"><input type="checkbox" required> 我已阅读并同意《用户协议》和《隐私政策》。未满 16 周岁请在监护人指导下使用。</label>
                <button class="primary" type="submit">登录</button>
            </form>
            <form method="post" action="<%= ctx %>/auth/applicant" id="form-applicant-pwd" class="<%= "pwd".equals(tab) ? "" : "hidden" %>">
                <input type="hidden" name="mode" value="pwd">
                <label>手机号</label>
                <div class="phone"><span>+86</span><input name="phone" maxlength="11" placeholder="11 位大陆手机号"></div>
                <label>密码</label>
                <div class="field"><input type="password" name="password" placeholder="不少于 8 位（演示账号可用 123456）"></div>
                <label class="agree"><input type="checkbox" required> 我已阅读并同意《用户协议》和《隐私政策》。未满 16 周岁请在监护人指导下使用。</label>
                <button class="primary" type="submit">登录</button>
            </form>
            <div class="links">
                <a href="<%= ctx %>/login?view=register">没有账号？立即注册</a>
                <a href="<%= ctx %>/login?view=admin">管理员入口</a>
            </div>
            <div class="other">其他登录方式</div>
            <button type="button" class="wx" data-go="wechat">微信扫码</button>
        </div>

        <div id="view-company" class="view <%= "company".equals(view) ? "" : "hidden" %>">
            <div class="role">
                <button type="button" data-go="applicant">求职者</button>
                <button type="button" class="on" data-go="company">企业招聘</button>
            </div>
            <h2>欢迎回来</h2>
            <p class="lead">登录后发布职位、查看候选人与沟通进度。</p>
            <div class="tabs"><button type="button" class="on">密码登录</button></div>
            <form method="post" action="<%= ctx %>/auth/company">
                <label>企业名称</label>
                <div class="field"><input name="companyName" placeholder="与营业执照一致的名称"></div>
                <label>手机号</label>
                <div class="phone"><span>+86</span><input name="phone" placeholder="11 位大陆手机号或后台账号"></div>
                <label>密码</label>
                <div class="field"><input type="password" name="password" placeholder="不少于 8 位"></div>
                <label class="agree"><input type="checkbox" required> 我已阅读并同意《用户协议》和《隐私政策》。未满 16 周岁请在监护人指导下使用。</label>
                <button class="primary" type="submit">登录</button>
            </form>
            <div class="links">
                <a href="<%= ctx %>/login?view=register">没有账号？立即注册</a>
                <a href="<%= ctx %>/login?view=admin">管理员入口</a>
            </div>
            <div class="other">其他登录方式</div>
            <button type="button" class="wx" data-go="wechat">微信扫码</button>
        </div>

        <div id="view-admin" class="view <%= "admin".equals(view) ? "" : "hidden" %>">
            <h2>管理员登录</h2>
            <p class="lead">使用专有管理员账号进入系统后台，与企业招聘入口分离。</p>
            <form method="post" action="<%= ctx %>/auth/admin">
                <label>管理员账号</label>
                <div class="field"><input name="account" placeholder="登录名，演示账号 admin" autocomplete="username"></div>
                <label>密码</label>
                <div class="field"><input type="password" name="password" placeholder="演示密码 123456" autocomplete="current-password"></div>
                <button class="primary" type="submit">进入管理后台</button>
            </form>
            <div class="links">
                <a href="<%= ctx %>/login?view=company">返回企业登录</a>
                <a href="<%= ctx %>/login?view=applicant">求职者登录</a>
            </div>
            <p class="note" style="margin-top:14px">演示账号：admin / 123456</p>
        </div>

        <div id="view-wechat" class="view <%= "wechat".equals(view) ? "" : "hidden" %>">
            <h2>微信扫码登录</h2>
            <p class="lead">使用微信扫描下方演示码。此码不能登录真实微信账号。</p>
            <div class="qr-box">
                <div class="qr" aria-hidden="true"></div>
                <div class="caption">职页演示码 · 非真实登录凭证</div>
            </div>
            <button type="button" class="primary" data-go="applicant" style="margin-top:16px;">返回账号登录</button>
        </div>

        <div id="view-register" class="view <%= "register".equals(view) ? "" : "hidden" %>">
            <div class="role">
                <button type="button" class="on" data-go="register">求职者</button>
                <button type="button" data-go="company">企业招聘</button>
            </div>
            <h2>创建求职者账号</h2>
            <p class="lead">注册后即可投递职位、保存沟通记录。</p>
            <form method="post" action="<%= ctx %>/auth/register">
                <label>姓名</label>
                <div class="field"><input name="name" placeholder="用于投递简历时展示"></div>
                <label>手机号</label>
                <div class="phone"><span>+86</span><input name="phone" maxlength="11" placeholder="11 位大陆手机号"></div>
                <label>短信验证码</label>
                <div class="sms-row">
                    <div class="field"><input name="smsCode" maxlength="6" placeholder="6 位数字"></div>
                    <button type="button" class="btn-lite js-sms">获取验证码</button>
                </div>
                <label class="agree"><input type="checkbox" required> 我已阅读并同意《用户协议》和《隐私政策》。未满 16 周岁请在监护人指导下使用。</label>
                <button class="primary" type="submit">注册</button>
            </form>
            <div class="links">
                <a href="<%= ctx %>/login?view=applicant">已有账号？返回登录</a>
                <span></span>
            </div>
            <div class="other">其他登录方式</div>
            <button type="button" class="wx" data-go="wechat">微信扫码</button>
        </div>

        <% if (!"admin".equals(view)) { %>
        <p class="note">演示约定：手机号须为 11 位；短信验证码固定为 246810；已有账号用密码登录无需图形验证码。课程演示密码可用 123456。</p>
        <% } %>
    </section>
</main>

<footer class="foot">
    <span>© 2026 锐聘 · 演示站点，非正式运营主体</span>
    <span>备案号占位 京ICP备00000000号-1 · 照片 Brooke Cagle / Unsplash</span>
</footer>
<script>
(function () {
  var ctx = "<%= ctx %>";
  function show(view, tab) {
    document.querySelectorAll(".view").forEach(function (el) { el.classList.add("hidden"); });
    var target = document.getElementById("view-" + view) || document.getElementById("view-applicant");
    target.classList.remove("hidden");
    if (view === "applicant") {
      var sms = tab !== "pwd";
      document.getElementById("form-applicant-sms").classList.toggle("hidden", !sms);
      document.getElementById("form-applicant-pwd").classList.toggle("hidden", sms);
      target.querySelectorAll(".tab-btn").forEach(function (b) {
        b.classList.toggle("on", (sms && b.getAttribute("data-tab") === "sms") || (!sms && b.getAttribute("data-tab") === "pwd"));
      });
    }
    var url = ctx + "/login?view=" + view + (tab ? "&tab=" + tab : "");
    history.replaceState(null, "", url);
    refreshCaptcha();
  }
  function refreshCaptcha() {
    document.querySelectorAll(".js-captcha").forEach(function (img) {
      if (img.closest(".hidden")) {
        return;
      }
      img.src = ctx + "/captcha?t=" + Date.now();
    });
  }
  refreshCaptcha();
  document.querySelectorAll("[data-go]").forEach(function (el) {
    el.addEventListener("click", function () { show(el.getAttribute("data-go")); });
  });
  document.querySelectorAll("[data-tab]").forEach(function (el) {
    el.addEventListener("click", function () { show("applicant", el.getAttribute("data-tab")); });
  });
  document.querySelectorAll(".js-captcha").forEach(function (img) {
    img.addEventListener("click", refreshCaptcha);
  });
  document.querySelectorAll(".js-sms").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var form = btn.closest("form");
      var phone = form.querySelector("input[name=phone]").value.trim();
      fetch(ctx + "/auth/sms", {
        method: "POST",
        headers: { "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8" },
        body: "phone=" + encodeURIComponent(phone)
      }).then(function (r) { return r.text(); }).then(function (t) {
        btn.textContent = t === "OK" ? "已发送 246810" : "号码无效";
      });
    });
  });

  (function particles() {
    var canvas = document.getElementById("loginParticles");
    var layer = document.querySelector(".login-ambient");
    if (!canvas || !layer) return;
    layer.style.cssText = "position:fixed;top:0;left:0;right:0;bottom:0;width:100vw;height:100vh;z-index:0;pointer-events:none;overflow:hidden;flex:0 0 0;";
    canvas.style.cssText = "position:absolute;top:0;left:0;width:100%;height:100%;display:block;";
    var ctx2 = canvas.getContext("2d");
    var dots = [];
    var mouse = { x: -9999, y: -9999 };
    function resize() {
      var w = window.innerWidth;
      var h = window.innerHeight;
      canvas.width = w;
      canvas.height = h;
      var n = Math.max(48, Math.floor(w * h / 18000));
      dots = [];
      for (var i = 0; i < n; i++) {
        dots.push({
          x: Math.random() * w,
          y: Math.random() * h,
          r: 0.8 + Math.random() * 2.2,
          vx: (Math.random() - 0.5) * 0.35,
          vy: -0.15 - Math.random() * 0.35,
          a: 0.18 + Math.random() * 0.45
        });
      }
    }
    function tick() {
      ctx2.clearRect(0, 0, canvas.width, canvas.height);
      for (var i = 0; i < dots.length; i++) {
        var d = dots[i];
        var dx = d.x - mouse.x;
        var dy = d.y - mouse.y;
        var dist = Math.sqrt(dx * dx + dy * dy);
        if (dist < 120 && dist > 0.01) {
          d.x += dx / dist * 0.6;
          d.y += dy / dist * 0.6;
        }
        d.x += d.vx;
        d.y += d.vy;
        if (d.y < -10) { d.y = canvas.height + 10; d.x = Math.random() * canvas.width; }
        if (d.x < -10) d.x = canvas.width + 10;
        if (d.x > canvas.width + 10) d.x = -10;
        ctx2.beginPath();
        ctx2.arc(d.x, d.y, d.r, 0, Math.PI * 2);
        ctx2.fillStyle = "rgba(15, 159, 110, " + d.a + ")";
        ctx2.fill();
      }
      requestAnimationFrame(tick);
    }
    window.addEventListener("resize", resize);
    window.addEventListener("mousemove", function (e) {
      mouse.x = e.clientX; mouse.y = e.clientY;
    });
    resize();
    tick();
  })();
})();
</script>
</body>
</html>
