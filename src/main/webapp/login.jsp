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
        errText = "请完整填写企业名称、手机号、密码和验证码。";
    } else if ("server".equals(err)) {
        errText = "服务暂时不可用，请稍后重试。";
    }
%>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>锐聘 · 招聘平台登录</title>
    <link rel="stylesheet" href="<%= ctx %>/common/login.css">
</head>
<body>
<header class="top">
    <a class="brand" href="<%= ctx %>/"><i></i>锐聘</a>
    <nav class="nav">
        <a href="<%= ctx %>/">找工作</a>
        <a href="<%= ctx %>/login?view=company">招人才</a>
        <span>帮助中心</span>
    </nav>
    <span class="help">使用说明</span>
</header>

<main class="stage">
    <section class="hero">
        <div class="kicker">招聘平台 · 登录</div>
        <h1>好工作，当面谈</h1>
        <p>求职者投递与沟通，企业发布职位、筛选候选人。同一个入口，按身份切换，互不串号。</p>
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
                <label>图形验证码</label>
                <div class="captcha-row">
                    <div class="field"><input name="captcha" maxlength="8" placeholder="点击图片刷新"></div>
                    <img class="captcha-img js-captcha" alt="验证码">
                </div>
                <label class="agree"><input type="checkbox" required> 我已阅读并同意《用户协议》和《隐私政策》。未满 16 周岁请在监护人指导下使用。</label>
                <button class="primary" type="submit">登录</button>
            </form>
            <div class="links">
                <a href="<%= ctx %>/login?view=register">没有账号？立即注册</a>
                <span>忘记密码</span>
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
                <label>图形验证码</label>
                <div class="captcha-row">
                    <div class="field"><input name="captcha" maxlength="8" placeholder="点击图片刷新"></div>
                    <img class="captcha-img js-captcha" alt="验证码">
                </div>
                <label class="agree"><input type="checkbox" required> 我已阅读并同意《用户协议》和《隐私政策》。未满 16 周岁请在监护人指导下使用。</label>
                <button class="primary" type="submit">登录</button>
            </form>
            <div class="links">
                <a href="<%= ctx %>/login?view=register">没有账号？立即注册</a>
                <span>忘记密码</span>
            </div>
            <div class="other">其他登录方式</div>
            <button type="button" class="wx" data-go="wechat">微信扫码</button>
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

        <p class="note">演示约定：手机号须为 11 位；短信验证码固定为 246810；企业/密码登录需填写图形验证码。课程演示密码可用 123456。</p>
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
})();
</script>
</body>
</html>
