# 工作项 #71099532 · 收藏表接口 Servlet

| 属性 | 值 |
|---|---|
| 类型 | Task |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
tb_favorite 增删查，按 applicant_id + job_id 唯一。

## 实现说明
FavoriteDao（exists/add/remove/listByApplicant/jobIdsByApplicant）+ FavoriteServlet（POST /favorite/add、/favorite/delete 校验职位存在且在招，GET /favorite/list 列表页）；唯一键 uk_fav_user_job 兜底防重。

## 相关文件（项目内路径）
- `src/main/java/com/qitoffer/dao/FavoriteDao.java`
- `src/main/java/com/qitoffer/servlet/FavoriteServlet.java`
- `src/main/webapp/favorite/list.jsp`

## 验证方式
重复收藏不产生重复行；取消收藏生效；未登录跳登录页。
