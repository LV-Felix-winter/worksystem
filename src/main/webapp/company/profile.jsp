<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Pics" %>
<%@ page import="com.qitoffer.dao.CompanyDao" %>
<%@ page import="com.qitoffer.entity.Company" %>
<%@ page import="com.qitoffer.entity.User" %>
<%
    request.setAttribute("pageTitle", "企业资料 · 锐聘");
    request.setAttribute("navKey", "profile");
    String ctx = request.getContextPath();
    User backend = (User) session.getAttribute(Dict.SESSION_ADMIN);
    Company company = null;
    if (backend != null) {
        try {
            company = new CompanyDao().findByUserId(backend.getUserId());
        } catch (Exception ignored) {
        }
    }
    String msg = (String) session.getAttribute("profileMsg");
    if (msg != null) {
        session.removeAttribute("profileMsg");
    }
    String area = company == null || company.getCompanyArea() == null ? "" : company.getCompanyArea();
    String size = company == null || company.getCompanySize() == null ? "" : company.getCompanySize();
    String type = company == null || company.getCompanyType() == null ? "" : company.getCompanyType();
    String brief = company == null || company.getCompanyBrief() == null ? "" : company.getCompanyBrief();
    String pic = company == null || company.getCompanyPic() == null ? "" : company.getCompanyPic();
    String picUrl = company == null ? "" : Pics.companyPromo(pic, company.getCompanyId(), ctx);
%>
<jsp:include page="/common/html-start.jsp"/>
<jsp:include page="/common/shell-open.jsp"/>
<% if (backend == null) { %>
<jsp:include page="/common/login-gate.jsp"/>
<% } else { %>
<div class="crumb">位置：<a href="<%= ctx %>/company/dashboard">工作台</a> / <span class="now">企业资料</span></div>
<% if (msg != null) { %><p class="ok toast-ok"><%= msg %></p><% } %>
<div class="sheet sheet-pro">
    <div class="sheet-bar">
        <div>
            <h2>企业资料</h2>
            <p class="muted">维护对外展示的企业信息，保存后前台同步更新。</p>
        </div>
        <% if (company != null) { %>
        <a class="btn-lite" href="<%= ctx %>/firm?id=<%= company.getCompanyId() %>" target="_blank">前台预览</a>
        <% } %>
    </div>
    <% if (company == null) { %>
    <div class="sheet-form"><p class="err">当前账号尚未关联企业记录。</p></div>
    <% } else { %>
    <div class="meta-grid">
        <div class="meta-card">
            <span class="meta-label">企业名称</span>
            <strong><%= company.getCompanyName() %></strong>
        </div>
        <div class="meta-card">
            <span class="meta-label">招聘状态</span>
            <span class="tag <%= company.getCompanyState() == Dict.STATE_ENABLED ? "" : "off" %>"><%= company.getCompanyState() == Dict.STATE_ENABLED ? "招聘中" : "已停用" %></span>
        </div>
        <div class="meta-card">
            <span class="meta-label">显示排序</span>
            <strong><%= company.getCompanySort() %></strong>
        </div>
        <div class="meta-card">
            <span class="meta-label">浏览数</span>
            <strong><%= company.getCompanyViewnum() %></strong>
        </div>
    </div>
    <form class="sheet-form form-pro" method="post" action="<%= ctx %>/company/profile" enctype="multipart/form-data">
        <h3 class="form-sec">基础信息</h3>
        <div class="form-row">
            <div class="form-col">
                <label>所在地</label>
                <input class="input js-region" name="companyArea" value="<%= area %>" placeholder="选择省 / 市 / 区县" readonly>
            </div>
            <div class="form-col">
                <label>企业规模</label>
                <select class="input" name="companySize">
                    <option value="1-49人" <%= "1-49人".equals(size) ? "selected" : "" %>>1-49人</option>
                    <option value="50-99人" <%= "50-99人".equals(size) ? "selected" : "" %>>50-99人</option>
                    <option value="100-200人" <%= "100-200人".equals(size) ? "selected" : "" %>>100-200人</option>
                    <option value="200-400人" <%= "200-400人".equals(size) ? "selected" : "" %>>200-400人</option>
                    <option value="300-500人" <%= "300-500人".equals(size) ? "selected" : "" %>>300-500人</option>
                    <option value="1000人以上" <%= "1000人以上".equals(size) ? "selected" : "" %>>1000人以上</option>
                    <% if (!size.isEmpty() && !"1-49人".equals(size) && !"50-99人".equals(size) && !"100-200人".equals(size) && !"200-400人".equals(size) && !"300-500人".equals(size) && !"1000人以上".equals(size)) { %>
                    <option value="<%= size %>" selected><%= size %></option>
                    <% } %>
                </select>
            </div>
        </div>
        <div class="form-row">
            <div class="form-col">
                <label>企业性质</label>
                <select class="input" name="companyType">
                    <option value="民营企业" <%= "民营企业".equals(type) ? "selected" : "" %>>民营企业</option>
                    <option value="股份制企业" <%= "股份制企业".equals(type) ? "selected" : "" %>>股份制企业</option>
                    <option value="外商独资" <%= "外商独资".equals(type) ? "selected" : "" %>>外商独资</option>
                    <option value="合资企业" <%= "合资企业".equals(type) ? "selected" : "" %>>合资企业</option>
                    <option value="教育培训" <%= "教育培训".equals(type) ? "selected" : "" %>>教育培训</option>
                    <% if (!type.isEmpty() && !"民营企业".equals(type) && !"股份制企业".equals(type) && !"外商独资".equals(type) && !"合资企业".equals(type) && !"教育培训".equals(type)) { %>
                    <option value="<%= type %>" selected><%= type %></option>
                    <% } %>
                </select>
            </div>
        </div>
        <h3 class="form-sec">对外简介</h3>
        <label>企业简介</label>
        <textarea class="input brief-wide" name="companyBrief" rows="8" placeholder="用 2～4 句话介绍业务方向、团队与优势"><%= brief %></textarea>
        <h3 class="form-sec">宣传图片</h3>
        <p class="muted form-hint">将展示在企业详情页顶部横幅。建议 1200×480，支持 JPG / PNG / WebP。</p>
        <% if (!pic.isEmpty()) { %>
        <img class="pic-preview wide promo-preview" src="<%= picUrl %>" alt="当前宣传图">
        <% } else { %>
        <img class="pic-preview wide promo-preview" src="<%= picUrl %>" alt="默认宣传图">
        <% } %>
        <label class="upload">
            <input type="file" name="companyPic" accept="image/png,image/jpeg,image/webp">
            <%= pic.isEmpty() ? "上传宣传图片" : "更换宣传图片（可选）" %>
        </label>
        <div class="actions form-actions">
            <button class="primary inline" type="submit">保存资料</button>
            <a class="btn-lite" href="<%= ctx %>/firm?id=<%= company.getCompanyId() %>" target="_blank">查看前台效果</a>
        </div>
    </form>
    <% } %>
</div>
<% } %>
<jsp:include page="/common/shell-close.jsp"/>
