# Q_ITOffer 锐聘网站

Java Web 实训（Servlet / JSP / JDBC / MySQL）。

本地运行：IDEA 打开本仓库，运行配置 `Q_ITOffer`（Smart Tomcat）。  
数据库：`127.0.0.1:3306`，库 `q_itoffer`，账号 `root / 888`。  
建库脚本：`src/main/resources/sql/q_itoffer.sql`  
扩展脚本：`src/main/resources/sql/q_itoffer_ext.sql`  
AI Coding 约定：`docs/AI-CODING.md`

## 模块速查（佟乐任务已实现）

| 入口 | 说明 |
|---|---|
| `/job/search` | 职位检索：关键词/地区/薪资 + 分页 + 热门（浏览量）排序 |
| `/job/detail?id=` | 职位只读预览（浏览量+1）、投递、收藏 |
| `/favorite/list` | 收藏职位（tb_favorite 唯一键 applicant_id+job_id） |
| `/user/apply.jsp`、`/apply/mine` | 我的投递：状态 待处理/已查看/已面试/已拒绝 中文展示 |
| `/apply/company`、`/apply/detail?id=` | 企业应聘信息：查看简历自动流转「已查看」 |
| `POST /apply/state` | 企业更新投递状态（JOIN 校验职位归属，越权改不动） |
| `/resume/`、`/resume/edit.jsp` | 简历只读预览（完整度加权）/ 编辑（保存后重算）/ 附件上传（类型+10MB 校验） |
| `/manage/resume.jsp` | 后台简历分页与详情 |
| `/manage/job.jsp` | 后台职位条件查询与详情（含下架职位） |

验收答辩与总结：`docs/acceptance/`。
扩展库脚本 `q_itoffer_ext.sql` 会补演示数据（多职位/投递/收藏/消息，可重复执行）。
