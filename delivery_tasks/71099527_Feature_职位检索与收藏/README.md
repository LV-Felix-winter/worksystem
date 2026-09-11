# 工作项 #71099527 · 职位检索与收藏

| 属性 | 值 |
|---|---|
| 类型 | Feature |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
作为求职者我想要按条件找职位并收藏，以便于快速缩小岗位范围；答辩可演示检索和收藏。

## 实现说明
Feature 总项，子项拆分实现：#71099528/29 检索分页、#71099532 收藏接口。

## 相关文件（项目内路径）
- `src/main/java/com/qitoffer/servlet/JobSearchServlet.java`
- `src/main/java/com/qitoffer/servlet/FavoriteServlet.java`
- `src/main/webapp/job/search.jsp`
- `src/main/webapp/favorite/list.jsp`

## 验证方式
演示：检索 3 条件组合 + 分页 + 热门排序 → 收藏/取消 → 收藏职位管理页。
