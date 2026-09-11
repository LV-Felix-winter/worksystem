# 工作项 #71099528 · 按关键词地区薪资搜索职位并分页按热门排序

| 属性 | 值 |
|---|---|
| 类型 | Story |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
关键词、地区、薪资筛选 + 分页 + 按浏览量（job_viewnum）热门排序。验收：≥3 条件可组合；分页；热门排序按职位浏览量。

## 实现说明
JobDao 动态 SQL（LIKE 关键词/地区 + SUBSTRING_INDEX/CAST 薪资上下限 + LIMIT 分页 + ORDER BY job_viewnum DESC）；JobSearchServlet 组装分页参数；job/search.jsp 搜索表单 + 结果卡 + 分页条 + 排序切换；详情页访问浏览量+1。

## 相关文件（项目内路径）
- `src/main/java/com/qitoffer/dao/JobDao.java`
- `src/main/java/com/qitoffer/servlet/JobSearchServlet.java`
- `src/main/java/com/qitoffer/servlet/JobDetailServlet.java`
- `src/main/webapp/job/search.jsp`
- `src/main/webapp/job/detail.jsp`

## 验证方式
自测清单「职位检索」4 条全过（组合条件、分页、热门、非法参数容错）。
