<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="zh-CN">
<head>
    <meta charset="UTF-8">
    <title>锐聘 Q_ITOffer</title>
    <style>
        body { font-family: "Microsoft YaHei", sans-serif; margin: 48px; color: #222; }
        a { color: #0b57d0; }
        .card { max-width: 640px; padding: 24px 28px; border: 1px solid #ddd; border-radius: 8px; }
    </style>
</head>
<body>
<div class="card">
    <h1>锐聘 Q_ITOffer</h1>
    <p>Java Web 实训项目已初始化，本地库 <code>q_itoffer</code> 已就绪。</p>
    <p><a href="<%= request.getContextPath() %>/dbtest">测试数据库连接</a>
        （含扩展表 tb_favorite / tb_message）</p>
    <ul>
        <li>后台管理员：admin / 123456</li>
        <li>求职者账号：test@itoffer.cn / 123456</li>
        <li>JDBC：127.0.0.1:3306 / root / 888</li>
    </ul>
</div>
</body>
</html>
