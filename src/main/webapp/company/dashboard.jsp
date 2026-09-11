<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>企业工作台</title>
    <style>
        * { box-sizing: border-box; }
        body { font-family: "Microsoft YaHei", sans-serif; background:#f5f6fa; margin:0; padding:24px; }
        h1 { font-size:20px; color:#333; margin-bottom:16px; }

        .cards { display:grid; grid-template-columns:repeat(4,1fr); gap:16px; margin-bottom:24px; }
        .card { background:#fff; border-radius:8px; padding:20px; box-shadow:0 1px 4px rgba(0,0,0,.06); }
        .card .label { color:#888; font-size:13px; }
        .card .num   { font-size:32px; font-weight:600; color:#2d6cdf; margin-top:8px; }

        .panel { background:#fff; border-radius:8px; padding:20px; box-shadow:0 1px 4px rgba(0,0,0,.06); }
        .toolbar { display:flex; align-items:center; gap:12px; margin-bottom:12px; }
        .toolbar select { padding:6px 10px; border:1px solid #ddd; border-radius:4px; }
        .toolbar button { padding:6px 16px; background:#2d6cdf; color:#fff; border:0; border-radius:4px; cursor:pointer; }

        table { width:100%; border-collapse:collapse; }
        th, td { padding:10px 12px; text-align:left; border-bottom:1px solid #eee; font-size:14px; }
        th { background:#fafafa; color:#666; font-weight:500; }
        tr:hover td { background:#f9fbff; }

        .tag { display:inline-block; padding:2px 8px; border-radius:10px; font-size:12px; }
        .tag.s1 { background:#fff3cd; color:#856404; }
        .tag.s2 { background:#d1ecf1; color:#0c5460; }
        .tag.s3 { background:#d4edda; color:#155724; }
        .tag.s0 { background:#f8d7da; color:#721c24; }

        .empty { text-align:center; color:#999; padding:40px 0; }
    </style>
</head>
<body>

<h1>企业工作台</h1>

<div class="cards">
    <div class="card">
        <div class="label">在招职位</div>
        <div class="num">${stats.hiringJobs}</div>
    </div>
    <div class="card">
        <div class="label">投递总数</div>
        <div class="num">${stats.totalApplies}</div>
    </div>
    <div class="card">
        <div class="label">待处理</div>
        <div class="num">${stats.pendingApplies}</div>
    </div>
    <div class="card">
        <div class="label">今日投递</div>
        <div class="num">${stats.todayApplies}</div>
    </div>
</div>

<div class="panel">
    <div class="toolbar">
        <form method="get" action="${pageContext.request.contextPath}/company/dashboard" style="display:flex;gap:12px;align-items:center;">
            <label>状态：</label>
            <select name="applyState">
                <option value=""  ${empty applyState ? 'selected' : ''}>全部</option>
                <option value="1" ${applyState == 1 ? 'selected' : ''}>待处理</option>
                <option value="2" ${applyState == 2 ? 'selected' : ''}>已查看</option>
                <option value="3" ${applyState == 3 ? 'selected' : ''}>已面试</option>
                <option value="0" ${applyState == 0 ? 'selected' : ''}>已拒绝</option>
            </select>
            <button type="submit">筛选</button>
        </form>
    </div>

    <table>
        <thead>
        <tr>
            <th>投递ID</th>
            <th>职位名称</th>
            <th>简历ID</th>
            <th>投递时间</th>
            <th>状态</th>
        </tr>
        </thead>
        <tbody>
        <c:choose>
            <c:when test="${empty applies}">
                <tr><td colspan="5" class="empty">暂无投递数据</td></tr>
            </c:when>
            <c:otherwise>
                <c:forEach var="row" items="${applies}">
                    <tr>
                        <td>${row.applyId}</td>
                        <td>${row.jobName}</td>
                        <td>${row.resumeId}</td>
                        <td><fmt:formatDate value="${row.applyDate}" pattern="yyyy-MM-dd HH:mm"/></td>
                        <td><span class="tag s${row.applyState}">${row.stateText}</span></td>
                    </tr>
                </c:forEach>
            </c:otherwise>
        </c:choose>
        </tbody>
    </table>
</div>

</body>
</html>