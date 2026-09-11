# 工作项 #71099535 · 简历完整度、附件上传与预览

| 属性 | 值 |
|---|---|
| 类型 | Story |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
求职者看到完整度百分比，可上传附件并预览简历。验收：缺字段完整度下降；附件仅限常见文档/图片；有只读预览页。

## 实现说明
resume/detail.jsp 只读预览（完整度环 + 5 模块得分 + 附件链接）；resume/edit.jsp 字段编辑 → POST /resume/update 保存并重算；/resume/upload 真实 multipart 上传（白名单 pdf/doc/docx/png/jpg/jpeg + 10MB 限制，存 webapp/upload）。

## 相关文件（项目内路径）
- `src/main/webapp/resume/detail.jsp`
- `src/main/webapp/resume/edit.jsp`
- `src/main/java/com/qitoffer/servlet/ResumeServlet.java`

## 验证方式
自测清单「简历完整度与附件」3 条全过。
