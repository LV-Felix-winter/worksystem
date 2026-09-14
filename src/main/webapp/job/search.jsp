<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="com.qitoffer.common.Dict" %>
<%@ page import="com.qitoffer.common.Pics" %>
<%@ page import="com.qitoffer.entity.Applicant" %>
<%@ page import="com.qitoffer.entity.Job" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.util.*" %>
<%
    String ctx = request.getContextPath();
    @SuppressWarnings("unchecked")
    List<Job> jobs = (List<Job>) request.getAttribute("jobs");
    if (jobs == null) {
        jobs = Collections.emptyList();
    }
    int total = request.getAttribute("total") instanceof Integer ? (Integer) request.getAttribute("total") : 0;
    int curPage = request.getAttribute("page") instanceof Integer ? (Integer) request.getAttribute("page") : 1;
    int pageCount = request.getAttribute("pageCount") instanceof Integer ? (Integer) request.getAttribute("pageCount") : 1;
    String keyword = request.getAttribute("keyword") != null ? (String) request.getAttribute("keyword") : "";
    String area = request.getAttribute("area") != null ? (String) request.getAttribute("area") : "";
    int salaryMin = request.getAttribute("salaryMin") instanceof Integer ? (Integer) request.getAttribute("salaryMin") : 0;
    int salaryMax = request.getAttribute("salaryMax") instanceof Integer ? (Integer) request.getAttribute("salaryMax") : 0;
    boolean popular = Boolean.TRUE.equals(request.getAttribute("popular"));
    boolean dbErr = Boolean.TRUE.equals(request.getAttribute("dbErr"));
    Applicant applicant = (Applicant) session.getAttribute(Dict.SESSION_APPLICANT);
    String baseQuery = "keyword=" + URLEncoder.encode(keyword, "UTF-8")
            + "&area=" + URLEncoder.encode(area, "UTF-8")
            + "&salaryMin=" + salaryMin + "&salaryMax=" + salaryMax
            + "&sort=" + (popular ? "hot" : "new");
    Map<Integer, List<Job>> groups = new LinkedHashMap<Integer, List<Job>>();
    for (Job job : jobs) {
        List<Job> bucket = groups.get(job.getCompanyId());
        if (bucket == null) {
            bucket = new ArrayList<Job>();
            groups.put(job.getCompanyId(), bucket);
        }
        bucket.add(job);
    }
    boolean showHero = Boolean.TRUE.equals(request.getAttribute("showHero"));
    int[] homeCounts = request.getAttribute("homeCounts") instanceof int[]
            ? (int[]) request.getAttribute("homeCounts") : new int[6];
    int onlineCount = request.getAttribute("onlineCount") instanceof Integer
            ? (Integer) request.getAttribute("onlineCount") : 0;
    java.text.DecimalFormat nf = new java.text.DecimalFormat("#,###");
%>
<jsp:include page="/common/html-start.jsp"/>
<% if (showHero) { %>
<section class="showcase">
    <div class="carousel" id="homeCarousel">
            <article class="slide on">
                <img class="slide-bg" src="<%= ctx %>/images/hero-1.jpg" alt="提供岗前培训的 IT 职位">
            </article>
            <article class="slide">
                <img class="slide-bg" src="<%= ctx %>/images/hero-2.jpg" alt="Java / 前端 / 测试实习">
            </article>
            <article class="slide">
                <img class="slide-bg" src="<%= ctx %>/images/hero-3.jpg" alt="简历完整，投递更顺">
            </article>
            <button class="car-btn prev" type="button" aria-label="上一张">‹</button>
            <button class="car-btn next" type="button" aria-label="下一张">›</button>
            <div class="dots"></div>
        </div>
    <div class="showcase-inner">
        <div class="stat-strip">
            <div><b><%= nf.format(homeCounts[0]) %></b><span>合作企业</span></div>
            <div><b><%= nf.format(homeCounts[1]) %></b><span>在招职位</span></div>
            <div><b><%= nf.format(homeCounts[2]) %></b><span>注册求职者</span></div>
            <div><b><%= nf.format(homeCounts[3]) %></b><span>投递次数</span></div>
            <div><b><%= nf.format(homeCounts[4]) %></b><span>在线简历</span></div>
            <div><b><%= nf.format(homeCounts[5]) %></b><span>职位浏览</span></div>
            <div><b><%= nf.format(onlineCount) %></b><span>当前在线</span></div>
        </div>
    </div>
</section>
<script>
(function () {
  var root = document.getElementById("homeCarousel");
  if (!root) return;
  var slides = root.querySelectorAll(".slide");
  var dotsBox = root.querySelector(".dots");
  var i = 0, timer;
  slides.forEach(function (_, idx) {
    var b = document.createElement("button");
    b.type = "button";
    if (idx === 0) b.className = "on";
    b.onclick = function () { go(idx); };
    dotsBox.appendChild(b);
  });
  function go(n) {
    slides[i].classList.remove("on");
    dotsBox.children[i].classList.remove("on");
    i = (n + slides.length) % slides.length;
    slides[i].classList.add("on");
    dotsBox.children[i].classList.add("on");
    restart();
  }
  function restart() {
    clearInterval(timer);
    timer = setInterval(function () { go(i + 1); }, 4500);
  }
  root.querySelector(".prev").onclick = function () { go(i - 1); };
  root.querySelector(".next").onclick = function () { go(i + 1); };
  restart();
})();
</script>
<% } %>
<main class="page wide">
<form class="search-bar" method="get" action="<%= ctx %>/job/search">
    <input class="input" name="keyword" value="<%= keyword %>" placeholder="职位或企业">
    <input class="input js-region" name="area" value="<%= area %>" placeholder="选择省 / 市 / 区县" readonly>
    <input class="input" name="salaryMin" value="<%= salaryMin > 0 ? salaryMin : "" %>" placeholder="薪资下限 k" style="width:110px">
    <input class="input" name="salaryMax" value="<%= salaryMax > 0 ? salaryMax : "" %>" placeholder="薪资上限 k" style="width:110px">
    <select class="input" name="sort" style="width:130px">
        <option value="new" <%= popular ? "" : "selected" %>>最新发布</option>
        <option value="hot" <%= popular ? "selected" : "" %>>热门浏览</option>
    </select>
    <button class="primary inline" type="submit">搜索</button>
    <a class="btn-lite" href="<%= ctx %>/job/search">重置</a>
</form>

<% if (dbErr) { %>
<p class="err">数据库暂时不可用，请稍后再试。</p>
<% } else if (jobs.isEmpty()) { %>
<div class="empty">暂无匹配职位，请调整筛选条件。</div>
<% } else {
    for (Map.Entry<Integer, List<Job>> entry : groups.entrySet()) {
        List<Job> companyJobs = entry.getValue();
        Job first = companyJobs.get(0);
        int cid = first.getCompanyId();
        List<String> points = Pics.highlights(first.getCompanyBrief(), first.getCompanyArea(), first.getCompanySize(), first.getCompanyType());
%>
<div class="board">
    <a class="board-hero" href="<%= ctx %>/firm?id=<%= cid %>">
        <img class="board-bg" src="<%= Pics.jobCover(first.getJobCover(), cid, ctx) %>" alt=""
             onerror="this.onerror=null;this.src='<%= ctx %>/images/hero-1.jpg'">
        <div class="board-overlay">
            <img class="board-logo" src="<%= Pics.jobThumb(first.getJobThumb(), first.getJobId(), ctx) %>" alt="">
            <h2><%= first.getCompanyName() %></h2>
            <ul>
                <% for (String point : points) { %><li><%= point %></li><% } %>
            </ul>
            <p class="board-slogan"><%= Pics.slogan(first.getCompanyName(), first.getCompanyType()) %></p>
        </div>
    </a>
    <% for (int n = 0; n < companyJobs.size(); n++) {
        Job row = companyJobs.get(n);
        String rowApply = applicant == null ? ctx + "/login" : ctx + "/job/detail?id=" + row.getJobId();
        String rowTalk = applicant == null ? ctx + "/login" : ctx + "/talk?jobId=" + row.getJobId();
    %>
    <div class="board-job">
        <div class="job-cta">
            <a class="apply-cta" href="<%= rowApply %>">我要申请 »</a>
            <a class="talk-cta" href="<%= rowTalk %>">去谈谈</a>
        </div>
        <div class="job-grid">
            <div class="k">职位</div>
            <div><a href="<%= ctx %>/job/detail?id=<%= row.getJobId() %>"><%= row.getJobName() %></a></div>
            <div class="k">薪资</div>
            <div><%= row.getJobSalary() == null ? "面议" : row.getJobSalary() %></div>
        </div>
        <div class="job-grid">
            <div class="k">到期时间</div>
            <div><%= row.getJobEndtime() == null || row.getJobEndtime().isEmpty() ? "长期有效" : row.getJobEndtime() %></div>
            <div class="k">工作地区</div>
            <div><%= row.getJobArea() == null ? "—" : row.getJobArea() %></div>
            <% if (n == companyJobs.size() - 1) { %>
            <div class="more-jobs" style="grid-column:1 / -1;border-bottom:0">
                <a href="<%= ctx %>/firm?id=<%= cid %>">更多职位</a>
            </div>
            <% } %>
        </div>
    </div>
    <% } %>
</div>
<% }
} %>

<% if (!dbErr && pageCount >= 1 && total > 0) { %>
<div class="pager">
    <a href="<%= ctx %>/job/search?<%= baseQuery %>&page=1">首页</a>
    <% if (curPage > 1) { %>
    <a href="<%= ctx %>/job/search?<%= baseQuery %>&page=<%= curPage - 1 %>">上一页</a>
    <% } %>
    <% if (curPage < pageCount) { %>
    <a href="<%= ctx %>/job/search?<%= baseQuery %>&page=<%= curPage + 1 %>">下一页</a>
    <% } %>
    <a href="<%= ctx %>/job/search?<%= baseQuery %>&page=<%= pageCount %>">尾页</a>
    <span>当前是第<%= curPage %>页，共<%= pageCount %>页</span>
</div>
<% } %>
</main>
<jsp:include page="/common/footer.jsp"/>
