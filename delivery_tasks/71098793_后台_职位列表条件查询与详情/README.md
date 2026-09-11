# 工作项 #71098793 · 职位列表条件查询与详情

| 属性 | 值 |
|---|---|
| 类型 | Story |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
作为管理员我想要查询职位列表、按条件筛选并看详情，以便于管理招聘职位。

## 实现说明
manage/job.jsp：关键词（职位/企业）+ 地区 + 状态（全部/招聘中/已下架）组合 + 热门（浏览量）/最新 排序 + 分页 + 详情；JobDao.search 动态 SQL（admin 视角可看下架）。

## 相关文件（项目内路径）
- `src/main/webapp/manage/job.jsp`
- `src/main/java/com/qitoffer/dao/JobDao.java`
- `src/main/java/com/qitoffer/entity/Job.java`

## 验证方式
管理员 → 「职位管理」：组合条件查询、分页、点详情；能看到下架职位（前台看不到）。
