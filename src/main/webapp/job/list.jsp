<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="java.util.List" %>
<%
    request.setAttribute("pageTitle", "职位检索 · 锐聘");
    request.setAttribute("navKey", "jobs");
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    List<Job> jobs = (List<Job>) request.getAttribute("jobs");
    Integer totalCount = (Integer) request.getAttribute("totalCount");
    Integer currentPage = (Integer) request.getAttribute("currentPage");
    Integer totalPages = (Integer) request.getAttribute("totalPages");
    String keyword = (String) request.getAttribute("keyword");
    String area = (String) request.getAttribute("area");
    String salary = (String) request.getAttribute("salary");
    List<String> areas = (List<String>) request.getAttribute("areas");
    List<String> salaries = (List<String>) request.getAttribute("salaries");
    String ctx = request.getContextPath();
%>
<jsp:include page="/common/html-start.jsp"/>
<main class="page front">
<div class="wrap">
    <div class="page-header">
        <h1 class="page-title">#71099527 职位检索与收藏</h1>
        <p class="page-subtitle">处理人：佟乐 | #71098793/#71098794/#71099528/#71099529</p>
    </div>

    <!-- 统计卡片 -->
    <div class="stats-bar">
        <div class="stat-card">
            <div class="stat-num"><%= totalCount != null ? totalCount : 0 %></div>
            <div class="stat-label">热门职位</div>
        </div>
        <div class="stat-card">
            <div class="stat-num" style="color:#ff6b6b" id="fav-count">0</div>
            <div class="stat-label">我的收藏</div>
        </div>
        <div class="stat-card">
            <div class="stat-num" style="color:#27ae60"><%= areas != null ? areas.size() : 0 %></div>
            <div class="stat-label">覆盖城市</div>
        </div>
    </div>

    <!-- 筛选条件 -->
    <div class="filter-card">
        <div class="card-title">筛选条件</div>
        <form method="get" action="<%= ctx %>/job/list" class="filter-row">
            <div class="f">
                <label>关键词</label>
                <input type="text" name="keyword" class="w" value="<%= keyword != null ? keyword : "" %>" placeholder="职位/公司/技能...">
            </div>
            <div class="f">
                <label>城市</label>
                <select name="area">
                    <option value="">全部城市</option>
                    <% if (areas != null) { for (String a : areas) { %>
                    <option value="<%= a %>" <%= area != null && area.equals(a) ? "selected" : "" %>><%= a %></option>
                    <% } } %>
                </select>
            </div>
            <div class="f">
                <label>薪资</label>
                <select name="salary">
                    <option value="">全部薪资</option>
                    <% if (salaries != null) { for (String s : salaries) { %>
                    <option value="<%= s %>" <%= salary != null && salary.equals(s) ? "selected" : "" %>><%= s %></option>
                    <% } } %>
                </select>
            </div>
            <button type="submit" class="btn btn-p">🔍 搜索</button>
            <a href="<%= ctx %>/job/list" class="btn btn-o" style="margin-left:auto">重置</a>
        </form>
    </div>

    <!-- 结果信息 -->
    <div class="result-info">
        <span>共 <strong><%= totalCount != null ? totalCount : 0 %></strong> 个职位</span>
        <% if (currentPage != null && totalPages != null && totalPages > 1) { %>
        <span style="float:right">第 <strong><%= currentPage %></strong> / <strong><%= totalPages %></strong> 页</span>
        <% } %>
    </div>

    <!-- 职位列表 -->
    <div class="job-list" id="job-list">
        <% if (jobs != null && !jobs.isEmpty()) {
            for (Job job : jobs) { %>
        <div class="job-item" data-job-id="<%= job.getJobId() %>" data-job-name="<%= job.getJobName() %>" data-company="<%= job.getCompanyName() != null ? job.getCompanyName() : "" %>">
            <div class="job-info">
                <div class="j-name"><%= job.getJobName() %></div>
                <div class="j-company"><%= job.getCompanyName() != null ? job.getCompanyName() : "" %> · <%= job.getJobArea() != null ? job.getJobArea() : "" %></div>
                <div class="j-desc"><%= job.getJobDesc() != null && job.getJobDesc().length() > 60 ? job.getJobDesc().substring(0, 60) + "..." : job.getJobDesc() %></div>
                <div class="tags">
                    <span class="tag tag-salary"><%= job.getJobSalary() != null ? job.getJobSalary() : "" %></span>
                    <span class="tag tag-location"><%= job.getJobArea() != null ? job.getJobArea() : "" %></span>
                    <span class="tag" style="background:#fff3e8;color:#e67e22">招聘中</span>
                </div>
            </div>
            <div class="job-actions">
                <button class="btn-collect" data-id="<%= job.getJobId() %>" onclick="toggleFavorite(this)">☆ 收藏职位</button>
            </div>
        </div>
        <% }
        } else { %>
        <div class="empty-state">暂无匹配职位，请调整筛选条件</div>
        <% } %>
    </div>

    <!-- 分页 -->
    <% if (totalPages != null && totalPages > 1) { %>
    <div class="pagination">
        <% int startPage = Math.max(1, currentPage - 2);
           int endPage = Math.min(totalPages, currentPage + 2);
           if (startPage > 1) { %>
        <a class="page-btn" href="?page=1">1</a>
        <% if (startPage > 2) { ?><span class="page-btn" style="cursor:default">...</span><% } %>
        <% }
           for (int i = startPage; i <= endPage; i++) { %>
        <a class="page-btn <%= i == currentPage ? "active" : "" %>" href="?page=<%= i %>&keyword=<%= java.net.URLEncoder.encode(keyword != null ? keyword : "", "UTF-8") %>&area=<%= java.net.URLEncoder.encode(area != null ? area : "", "UTF-8") %>&salary=<%= java.net.URLEncoder.encode(salary != null ? salary : "", "UTF-8") %>"><%= i %></a>
        <% }
           if (endPage < totalPages) {
               if (endPage < totalPages - 1) { ?><span class="page-btn" style="cursor:default">...</span><% }
               %><a class="page-btn" href="?page=<%= totalPages %>"><%= totalPages %></a><%
           }
        %>
    </div>
    <% } %>
</div>
</main>
<jsp:include page="/common/footer.jsp"/>
<script>
// 收藏职位功能 (#71099531/#71099532/#71099533)
function toggleFavorite(btn) {
    const jobId = btn.dataset.id;
    const item = btn.closest('.job-item');
    const jobName = item.dataset.jobName;
    const company = item.dataset.company;

    fetch('<%= ctx %>/favorite/check?jobId=' + jobId)
        .then(r => r.json())
        .then(data => {
            if (data.error) { alert('请先登录'); window.location.href = '<%= ctx %>/login'; return; }
            if (data.favorited) {
                // 取消收藏
                fetch('<%= ctx %>/favorite/' + jobId, {method: 'DELETE'}).then(() => {
                    btn.className = 'btn-collect';
                    btn.textContent = '☆ 收藏职位';
                    updateFavCount(-1);
                });
            } else {
                // 添加收藏
                fetch('<%= ctx %>/favorite', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify({jobId: parseInt(jobId), jobName, company})
                }).then(() => {
                    btn.className = 'btn-collect on';
                    btn.textContent = '★ 已收藏';
                    updateFavCount(1);
                });
            }
        });
}

function updateFavCount(delta) {
    const el = document.getElementById('fav-count');
    if (el) el.textContent = Math.max(0, parseInt(el.textContent || '0') + delta);
}
</script>
<style>
.stats-bar{display:flex;gap:12px;margin-bottom:20px}
.stat-card{flex:1;background:#fff;border-radius:10px;padding:14px;text-align:center;box-shadow:0 2px 8px rgba(0,0,0,0.05)}
.stat-num{font-size:26px;font-weight:700;color:#4facfe}
.stat-label{font-size:12px;color:#888;margin-top:4px}
.filter-card,.card-title{background:#fff;border-radius:12px;padding:20px;margin-bottom:16px;box-shadow:0 2px 8px rgba(0,0,0,0.05)}
.card-title{font-size:15px;font-weight:600;margin-bottom:12px}
.filter-row{display:flex;gap:12px;align-items:flex-end;flex-wrap:wrap}
.f{display:flex;flex-direction:column;gap:4px}
.f label{font-size:12px;color:#888}
.f input,.f select{height:36px;padding:0 10px;border:1px solid #ddd;border-radius:6px;font-size:13px}
.f input.w{width:200px}
.btn{height:36px;padding:0 16px;border:none;border-radius:6px;font-size:13px;font-weight:600;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:4px}
.btn-p{background:linear-gradient(135deg,#4facfe,#00f2fe);color:#fff}
.btn-o{background:#fff;color:#4facfe;border:1px solid #4facfe}
.result-info{font-size:13px;color:#888;margin-bottom:12px}
.job-item{background:#fff;border-radius:10px;padding:16px 20px;margin-bottom:10px;box-shadow:0 1px 6px rgba(0,0,0,0.05);display:flex;justify-content:space-between;align-items:center;border:1px solid transparent;transition:all .2s}
.job-item:hover{border-color:#4facfe}
.j-name{font-size:15px;font-weight:600}.j-company{font-size:13px;color:#666;margin-top:2px}.j-desc{font-size:12px;color:#999;margin-top:4px}
.tag{display:inline-block;padding:2px 8px;border-radius:10px;font-size:11px;margin-right:4px}
.tag-salary{background:#e8f8ef;color:#27ae60}.tag-location{background:#eef4ff;color:#4facfe}
.btn-collect{padding:6px 14px;border-radius:6px;font-size:12px;font-weight:600;cursor:pointer;border:1px solid #ddd;background:#fff;color:#888;transition:all .2s}
.btn-collect.on{border-color:#ff6b6b;color:#ff6b6b;background:#fff5f5}
.empty-state{text-align:center;padding:40px;color:#aaa}
.pagination{display:flex;justify-content:center;gap:6px;margin-top:20px}
.page-btn{width:34px;height:34px;border:1px solid #ddd;border-radius:6px;background:#fff;cursor:pointer;font-size:13px;display:flex;align-items:center;justify-content:center;text-decoration:none;color:#333}
.page-btn.active{border-color:#4facfe;color:#4facfe;background:#f0f8ff}
</style>
