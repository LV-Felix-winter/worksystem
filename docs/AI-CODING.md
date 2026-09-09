# 锐聘 Q_ITOffer · AI Coding 约定

组员用 CodeArts AI Coding / 其它 AI 生成代码前，把本文和 `docs/aicoding-prompt.txt` 一起贴进提示词。生成后必须人工改校验、权限和文案，禁止整段粘贴讲义样例。

## 工程

- 根目录：`C:\Users\25876\IdeaProjects\Q_ITOffer`
- JDK 17 编译，运行用本机 IDEA JDK 26 即可
- 包名只允许：`com.qitoffer.*`
- JDBC：只用 `com.qitoffer.util.DbUtil`，配置在 `src/main/resources/jdbc.properties`
- 状态码：只用 `com.qitoffer.common.Dict`，不要自己写 0/1/2
- 数据库：本机 MySQL 5.5.22，`127.0.0.1:3306`，库 `q_itoffer`，账号 `root / 888`

## 包与页面目录

| 用途 | 位置 |
|---|---|
| 实体 | `com.qitoffer.entity` |
| DAO | `com.qitoffer.dao` |
| Servlet | `com.qitoffer.servlet` |
| Filter | `com.qitoffer.filter` |
| 工具 | `com.qitoffer.util` |
| 常量 | `com.qitoffer.common` |
| 公共 JSP | `/common/` |
| 职位 | `/job/` |
| 简历 | `/resume/` |
| 收藏 | `/favorite/` |
| 求职者中心 | `/user/` |
| 企业管理 | `/company/` |
| 消息 | `/message/` |
| 上传文件 | `/upload/` |

Servlet 路径用英文小写，例如：`/job/search`、`/favorite/add`、`/apply/list`。

## 禁止出现的样例痕迹

不要生成或提交这些名字（讲义样例常见）：

- 包名：`cn.itcast`、`com.itheima`、`org.qst`
- 类名：`ApplicantDAO` 若与现有 `ApplicantDao` 混用、`CompanyServlet` 直接复制样例方法名
- 页面：`public/index.jsp` 原样、`manage/login.jsp` 原样套 CSS
- 自己再写一套 `JDBCUtil` / `DBConnection`

实体类名：`User`、`Company`、`Job`、`Applicant`、`Resume`、`Apply`、`Favorite`、`Message`。

## 表与字段（扩展已落地）

必做表：`tb_users` `tb_company` `tb_job` `tb_applicant` `tb_resume` `tb_apply`

扩展表：

- `tb_favorite`：applicant_id + job_id 唯一
- `tb_message`：receiver_type = applicant / user，is_read = 0 未读 / 1 已读

扩展列：

- `tb_resume.attachment` 附件路径
- `tb_resume.completeness` 0–100
- `tb_job.job_viewnum` 浏览量，热门排序用这个，不要再用企业浏览量凑

`tb_job.job_state`：1 上架，0 下架（见 `Dict.JOB_ONLINE` / `JOB_OFFLINE`）  
`tb_apply.apply_state`：0 拒绝，1 待处理，2 已查看，3 面试

## SQL 脚本

- 空库全量：`src/main/resources/sql/q_itoffer.sql`（会删表重建，勿在有数据时乱跑）
- 给现有库打补丁：`src/main/resources/sql/q_itoffer_ext.sql`（可重复执行）

## AI 生成后必做

1. 编译能过，包名全是 `com.qitoffer`
2. 查询走 Dao，页面走 JSP，Servlet 不拼一大段 HTML
3. 写操作校验登录和归属（只能改自己的简历 / 本企业职位）
4. 前台列表只显示 `job_state = 1` 的职位
5. 文案用「锐聘」，不要出现样例公司广告语原句
