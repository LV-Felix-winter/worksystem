<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Labels" %>
<%@ page import="com.qitoffer.common.Pics" %>
<%@ page import="com.qitoffer.common.ResumeBlocks" %>
<%@ page import="com.qitoffer.entity.Apply" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.List" %>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Apply> cards = (List<Apply>) request.getAttribute("applyCards");
    int detailId = request.getAttribute("applyCardDetailId") instanceof Integer
            ? (Integer) request.getAttribute("applyCardDetailId") : 0;
    boolean showForm = Boolean.TRUE.equals(request.getAttribute("applyCardShowForm"));
    String emptyText = (String) request.getAttribute("applyCardEmpty");
    if (emptyText == null) {
        emptyText = "暂无投递记录。";
    }
    SimpleDateFormat fmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<div class="talent-list">
<% if (cards == null || cards.isEmpty()) { %>
    <div class="talent-empty"><%= emptyText %></div>
<% } else {
    for (Apply a : cards) {
        String who = a.getResumeRealname() != null && !a.getResumeRealname().isEmpty()
                ? a.getResumeRealname() : "求职者 #" + a.getResumeId();
        int age = ResumeBlocks.ageOf(a.getResumeBirthday());
        String edu = ResumeBlocks.highestEduLabel(a.getResumeEducation());
        if (edu == null || edu.isEmpty()) {
            edu = "未填写";
        }
        String phone = a.getResumeTelephone() == null || a.getResumeTelephone().isEmpty() ? "未填写" : a.getResumeTelephone();
        String email = a.getResumeEmail() == null || a.getResumeEmail().isEmpty() ? "未填写" : a.getResumeEmail();
        String loc = a.getResumeCurrentLoc() == null || a.getResumeCurrentLoc().isEmpty() ? "" : a.getResumeCurrentLoc();
        String gender = a.getResumeGender() == null ? "" : a.getResumeGender();
        String photo = Pics.photo(a.getResumeHeadShot(), ctx);
        boolean isDetail = a.getApplyId() == detailId;
        StringBuilder meta = new StringBuilder();
        if (!gender.isEmpty()) {
            meta.append(gender);
        }
        if (age > 0) {
            if (meta.length() > 0) {
                meta.append(" · ");
            }
            meta.append(age).append("岁");
        }
        if (!loc.isEmpty()) {
            if (meta.length() > 0) {
                meta.append(" · ");
            }
            meta.append(loc);
        }
%>
    <article class="talent-card <%= isDetail ? "on" : "" %>">
        <img class="talent-photo" src="<%= photo %>" alt="<%= who %>">
        <div class="talent-main">
            <h3 class="talent-name"><%= who %><span class="tag <%= Labels.applyStateClass(a.getApplyState()) %>"><%= Labels.applyStateLabel(a.getApplyState()) %></span></h3>
            <p class="talent-sub">
                <%= meta.length() == 0 ? "简历信息待完善" : meta.toString() %>
                · 应聘「<%= a.getJobName() %>」
                · <%= a.getApplyDate() == null ? "-" : fmt.format(a.getApplyDate()) %>
            </p>
            <div class="talent-facts">
                <div>
                    <span class="k">联系方式</span>
                    <span class="v"><%= phone %><br><%= email %></span>
                </div>
                <div>
                    <span class="k">最高学历</span>
                    <span class="v"><%= edu %></span>
                </div>
                <div>
                    <span class="k">求职意向</span>
                    <span class="v"><%= a.getResumeJobIntension() == null || a.getResumeJobIntension().isEmpty() ? "未填写" : a.getResumeJobIntension() %></span>
                </div>
            </div>
            <% if (isDetail && showForm) { %>
            <div class="talent-extra">
                <div class="talent-facts">
                    <div>
                        <span class="k">完整度</span>
                        <span class="v"><%= a.getResumeCompleteness() %>%</span>
                    </div>
                    <div>
                        <span class="k">附件</span>
                        <span class="v">
                            <% if (a.getResumeAttachment() != null && !a.getResumeAttachment().isEmpty()) { %>
                            <a href="<%= ctx %><%= a.getResumeAttachment() %>" target="_blank">查看附件</a>
                            <% } else { %>未上传<% } %>
                        </span>
                    </div>
                </div>
                <p class="talent-exp"><%= a.getResumeJobExperience() == null || a.getResumeJobExperience().isEmpty() ? "暂无经历说明。" : a.getResumeJobExperience() %></p>
            </div>
            <% } %>
        </div>
        <div class="talent-side">
            <% if (showForm) { %>
            <a class="btn-lite" href="<%= ctx %>/apply/detail?id=<%= a.getApplyId() %>"><%= isDetail ? "收起摘要" : "查看简历" %></a>
            <form method="post" action="<%= ctx %>/apply/state">
                <input type="hidden" name="applyId" value="<%= a.getApplyId() %>">
                <select class="input" name="newState">
                    <option value="1" <%= a.getApplyState() == 1 ? "selected" : "" %>>待处理</option>
                    <option value="2" <%= a.getApplyState() == 2 ? "selected" : "" %>>已查看</option>
                    <option value="3" <%= a.getApplyState() == 3 ? "selected" : "" %>>已面试</option>
                    <option value="0" <%= a.getApplyState() == 0 ? "selected" : "" %>>已拒绝</option>
                </select>
                <button class="primary inline" type="submit">更新状态</button>
            </form>
            <% } else { %>
            <a class="primary inline" href="<%= ctx %>/apply/detail?id=<%= a.getApplyId() %>">查看简历</a>
            <% } %>
        </div>
    </article>
<% }
} %>
</div>
