# 工作项 #71098791 · 简历列表分页与详情

| 属性 | 值 |
|---|---|
| 类型 | Story |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
作为管理员我想要分页查看简历并打开详情，以便于筛选求职者。

## 实现说明
manage/resume.jsp 全库简历分页（每页10条）+ 关键词（姓名/手机/意向岗位）+ ?detail= 只读详情；ResumeDao 新增 listPage/countPage 动态 SQL + LIMIT 分页。

## 相关文件（项目内路径）
- `src/main/webapp/manage/resume.jsp`
- `src/main/java/com/qitoffer/dao/ResumeDao.java`
- `src/main/java/com/qitoffer/entity/Resume.java`

## 验证方式
管理员登录 → 左侧「简历管理」：分页、关键词查询、点详情看全字段/完整度/附件。
