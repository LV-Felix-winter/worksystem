# 项目验收答辩材料（#71098820 / #71098821 / #71098722 / #71098723）

> 项目：刘璟灏组 · 锐聘 Q_ITOffer（Java Web 实训）
> 处理人：佟乐（职位/简历/收藏/投递模块 + 验收）
> 建议答辩 15 分钟：架构 3' + 模块演示 8' + 技术点与自测 4'

## 一、PPT 大纲

1. **项目定位**：求职招聘网站「锐聘」——企业发职位、求职者投递、管理员管账号；
   Servlet + JSP + JDBC + MySQL，无框架依赖，纯 Java Web。
2. **架构分层**：
   - 实体 `com.qitoffer.entity`（User / Company / Job / Applicant / Resume / Apply / Favorite）
   - DAO `com.qitoffer.dao`（全部走 `DbUtil` 连接池配置 + PreparedStatement）
   - Servlet `com.qitoffer.servlet`（URL 英文小写，`/job/search`、`/favorite/add`、`/apply/state`…）
   - Filter `com.qitoffer.filter`（后台登录拦截 + 角色越权拦截 + 求职者会话拦截）
   - 常量 `com.qitoffer.common.Dict`（状态码统一，页面不写裸数字）
3. **数据库**：6 张必做表 + 2 张扩展表（tb_favorite 唯一键 applicant_id+job_id、tb_message 站内信）；
   扩展列 tb_resume.attachment / completeness、tb_job.job_viewnum（热门排序口径）。
4. **演示脚本**（对应验收标准，逐条过）：
   - 职位检索：关键词 + 地区 + 薪资上下限组合 3 个条件、分页、切「热门」按浏览量排序
   - 收藏：搜索页/详情页一键收藏与取消，收藏职位页管理（唯一键去重）
   - 简历完整度：编辑页删掉「工作经历」保存 → 完整度立刻下降；传附件 → 分数回升
   - 投递流转：求职者投递（待处理）→ 企业查看简历（自动变已查看）→ 企业改为已面试/已拒绝
     （归属校验：拿别的企业的投递 id 调 /apply/state 改不动）
   - 后台：简历分页 + 详情、职位条件查询 + 详情（可见下架职位，前台不可见）
5. **AI Coding 说明**：初稿由 CodeArts AI 生成，人工改了包名（com.qitoffer.*）、
   越权校验、状态码统一走 Dict、页面文案；无讲义样例痕迹。
6. **不足与改进**：无分页缓存/搜索索引；上传仅存 webapp 目录（重启丢失）；
   消息中心待开发（表已就绪）。

## 二、答辩预问

| 问题 | 回答要点 |
|---|---|
| 收藏如何防重复？ | tb_favorite 唯一键 uk_fav_user_job(applicant_id, job_id)，DAO 先查再插兜底 |
| 企业改投递状态怎么防越权？ | UPDATE 语句 JOIN tb_job 同句校验 j.company_id = 当前会话企业，改 0 行即拒绝 |
| 热门排序数据从哪来？ | 职位详情页每次访问 job_viewnum+1，排序 LIMIT 分页按该列 DESC |
| 完整度怎么算？ | 5 模块加权：基本 15% + 教育 20% + 经历 25% + 项目 25% + 技能证书 15%（含附件得分） |
| 为什么前台只看到部分职位？ | JobDao 前台固定 WHERE job_state=1；后台传 state 参数可看全部 |
