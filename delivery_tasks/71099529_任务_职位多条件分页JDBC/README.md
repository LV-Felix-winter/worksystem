# 工作项 #71099529 · 编写职位多条件分页 JDBC

| 属性 | 值 |
|---|---|
| 类型 | Task |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
JobDao 动态 SQL：关键词/地区/薪资 + LIMIT 分页 + 排序。

## 实现说明
JobDao.search/count：StringBuilder 动态 WHERE + PreparedStatement 参数绑定 + LIMIT ? OFFSET ?；薪资文本「6k-8k」用 SUBSTRING_INDEX 取下限/上限 CAST 数字比较（兼容 MySQL 5.5）。

## 相关文件（项目内路径）
- `src/main/java/com/qitoffer/dao/JobDao.java`

## 验证方式
执行 SQL 观察日志/Debug：WHERE 片段随条件增减；LIMIT 参数 = 页大小/偏移。
