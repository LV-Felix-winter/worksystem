# 工作项 #71099539 · 投递状态更新接口

| 属性 | 值 |
|---|---|
| 类型 | Task |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
企业可改 apply_state，校验归属职位。

## 实现说明
ApplyServlet POST /apply/state：会话取企业 → CompanyDao.findByUserId → ApplyDao.updateStateOwned 单条 UPDATE JOIN tb_job 校验 j.company_id，改 0 行即越权失败；成功后给求职者写站内消息；/apply/detail 查看简历时 待处理→已查看。

## 相关文件（项目内路径）
- `src/main/java/com/qitoffer/servlet/ApplyServlet.java`
- `src/main/java/com/qitoffer/dao/ApplyDao.java`
- `src/main/java/com/qitoffer/dao/CompanyDao.java`
- `src/main/webapp/company/apply.jsp`

## 验证方式
企业改自己职位的投递成功；拿别家 apply_id 改 → 提示「不属于本企业职位」。
