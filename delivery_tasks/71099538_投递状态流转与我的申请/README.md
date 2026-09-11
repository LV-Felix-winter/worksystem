# 工作项 #71099538 · 投递状态流转并在我的申请中展示

| 属性 | 值 |
|---|---|
| 类型 | Story |
| 处理人 | 佟乐 |
| 状态 | 新建 → 已完成（代码就绪） |

## 任务要求
求职者看到投递处于待处理/已查看/面试/拒绝。验收：状态写入 tb_apply.apply_state；我的申请显示中文状态。

## 实现说明
ApplyDao（add 初始待处理、listByApplicant/listByCompany 联表、markViewedOwned 1→2 自动流转、notifyApplicant 写 tb_message）；user/apply.jsp 中文状态徽章（Labels.applyStateLabel/Class）；job/detail.jsp「立即投递」入口。

## 相关文件（项目内路径）
- `src/main/java/com/qitoffer/dao/ApplyDao.java`
- `src/main/webapp/user/apply.jsp`
- `src/main/webapp/job/detail.jsp`
- `src/main/java/com/qitoffer/common/Labels.java`

## 验证方式
自测清单「投递状态流转」6 条全过。
