# 项目总结（#71098821 / #71098723 验收交付）

## 交付内容（佟乐负责部分）

| 工作项 | 内容 | 关键文件 |
|---|---|---|
| #71099527/#71099528/#71099529 | 职位检索：关键词/地区/薪资组合 + LIMIT 分页 + 热门（job_viewnum）排序 | `JobDao`、`JobSearchServlet`、`job/search.jsp` |
| #71099532 | 收藏：tb_favorite 增删查，applicant_id+job_id 唯一 | `FavoriteDao`、`FavoriteServlet`、`favorite/list.jsp` |
| #71099535/#71099536 | 简历完整度加权计算、附件上传（类型/10MB 校验）、只读预览、编辑页 | `ResumeDao`、`ResumeServlet`、`resume/detail.jsp`、`resume/edit.jsp` |
| #71099538/#71099539 | 投递状态流转（待处理/已查看/已面试/已拒绝）+ 企业状态更新接口（归属校验 + 站内消息） | `ApplyDao`、`ApplyServlet`、`user/apply.jsp`、`company/apply.jsp` |
| #71098791/#71098792 | 后台简历分页与详情 | `ResumeDao.listPage/countPage`、`manage/resume.jsp` |
| #71098793/#71098794 | 后台职位条件查询与详情 | `JobDao.search`、`manage/job.jsp` |
| #71098707/#71098708 | 同上（后台视图重复立项，同一套实现） | 同上 |
| #71098820/#71098821/#71098722/#71098723 | 验收答辩材料与总结 | `docs/acceptance/*`、`docs/acceptance/selftest-checklist.md` |

## 技术要点

- 动态 SQL 拼接全部参数化（`?` 占位 + PreparedStatement），关键词用 LIKE，薪资用
  `SUBSTRING_INDEX + CAST` 从「6k-8k」文本里取数字比较，兼容 MySQL 5.5。
- 越权控制三层：Filter 拦未登录/角色 → Servlet 校验会话身份 → DAO 语句内 JOIN 校验数据归属。
- 状态码只走 `Dict`，中文文案只走 `Labels`，页面不散落魔法数字。

## 本地运行

1. MySQL 5.5：`root / 888`，先跑 `src/main/resources/sql/q_itoffer.sql`（空库全量），
   再跑 `q_itoffer_ext.sql`（扩展表/列 + 演示数据，可重复执行）。
2. IDEA Smart Tomcat 部署 `Q_ITOffer`，JDK 17 编译即可。
3. 账号：管理员 admin/123456；企业 qingruan/123456；求职者 test@itoffer.cn / 123456（手机 13800138000）。

## 自测

见 `docs/acceptance/selftest-checklist.md`，逐条对验收标准打勾。
