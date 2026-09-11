# 工作项 #71099536 · 完整度计算与附件字段

| 属性 | 值 |
|---|---|
| 类型 | Task |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
按已填字段算百分比，resume 增加 attachment 字段。

## 实现说明
ResumeDao 加权算法（基本信息15%+教育20%+经历25%+项目25%+技能证书15%，技能模块含 attachment 得分）；attachment 列由 q_itoffer_ext.sql 幂等补列；保存/上传后自动重算。

## 相关文件（项目内路径）
- `src/main/java/com/qitoffer/dao/ResumeDao.java`
- `src/main/resources/sql/q_itoffer_ext.sql`

## 验证方式
清空「工作经历」保存 → 分数下降；传附件 → 分数回升；tb_resume.completeness/attachment 列有值。
