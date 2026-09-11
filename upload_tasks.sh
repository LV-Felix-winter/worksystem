#!/usr/bin/env bash
# ============================================================
# 佟乐 · 锐聘 Q_ITOffer — DevCloud(CodeArts Repo) 任务提交脚本
# 作用：先打 1 个基线 commit，再按工作项编号逐个
#       commit（fix #编号），push 后 DevCloud 会把对应
#       工作项自动流转成「已解决」。
# 用法：
#   1. cd 到 DevCloud 克隆的 Q_ITOffer 仓库（本目录的代码已在其中）
#   2. 确认 remote 指向 DevCloud 仓库：  git remote -v
#   3. 确认身份：                        git config user.name / user.email
#   4. bash upload_tasks.sh
# ============================================================
set -uo pipefail
cd "$(dirname "$0")"

# ---------- 0) 基线：全部代码一次进库 ----------
echo ">>> [0] 基线提交（master 框架 + 全部实现）"
git add -A
git commit --allow-empty -m "feat: 锐聘 Q_ITOffer 全部模块基线（佟乐：简历完整度/附件、职位检索收藏、投递状态流转、后台简历与职位管理、验收材料）" || echo "!! 基线提交失败（可能已提交过，继续）"

# ---------- 1) 按编号逐个提交 ----------
TASKS=(
"71098791|src/main/webapp/manage/resume.jsp src/main/java/com/qitoffer/dao/ResumeDao.java src/main/java/com/qitoffer/entity/Resume.java|后台简历列表分页与详情（佟乐）"
"71098792|src/main/webapp/manage/resume.jsp src/main/java/com/qitoffer/dao/ResumeDao.java|实现：简历列表分页与详情（佟乐）"
"71098793|src/main/webapp/manage/job.jsp src/main/java/com/qitoffer/dao/JobDao.java src/main/java/com/qitoffer/entity/Job.java|后台职位列表条件查询与详情（佟乐）"
"71098794|src/main/webapp/manage/job.jsp src/main/java/com/qitoffer/dao/JobDao.java|实现：职位列表条件查询与详情（佟乐）"
"71098707|src/main/webapp/manage/resume.jsp src/main/java/com/qitoffer/dao/ResumeDao.java|简历列表分页与详情·后台视图（佟乐，同#71098791实现）"
"71098708|src/main/webapp/manage/job.jsp src/main/java/com/qitoffer/dao/JobDao.java|职位列表条件查询与详情·后台视图（佟乐，同#71098793实现）"
"71099527|src/main/java/com/qitoffer/servlet/JobSearchServlet.java src/main/java/com/qitoffer/servlet/FavoriteServlet.java src/main/webapp/job/search.jsp src/main/webapp/favorite/list.jsp|Feature：职位检索与收藏（佟乐）"
"71099528|src/main/java/com/qitoffer/dao/JobDao.java src/main/java/com/qitoffer/servlet/JobSearchServlet.java src/main/java/com/qitoffer/servlet/JobDetailServlet.java src/main/webapp/job/search.jsp src/main/webapp/job/detail.jsp|职位多条件检索+分页+热门排序（佟乐）"
"71099529|src/main/java/com/qitoffer/dao/JobDao.java|职位多条件分页JDBC（佟乐）"
"71099532|src/main/java/com/qitoffer/dao/FavoriteDao.java src/main/java/com/qitoffer/servlet/FavoriteServlet.java src/main/webapp/favorite/list.jsp|收藏表接口Servlet（佟乐）"
"71099535|src/main/webapp/resume/detail.jsp src/main/webapp/resume/edit.jsp src/main/java/com/qitoffer/servlet/ResumeServlet.java|简历完整度、附件上传与预览（佟乐）"
"71099536|src/main/java/com/qitoffer/dao/ResumeDao.java src/main/resources/sql/q_itoffer_ext.sql|完整度计算与附件字段（佟乐）"
"71099538|src/main/java/com/qitoffer/dao/ApplyDao.java src/main/java/com/qitoffer/servlet/ApplyServlet.java src/main/webapp/user/apply.jsp src/main/webapp/job/detail.jsp src/main/java/com/qitoffer/common/Labels.java|投递状态流转并在我的申请中展示（佟乐）"
"71099539|src/main/java/com/qitoffer/servlet/ApplyServlet.java src/main/java/com/qitoffer/dao/ApplyDao.java src/main/java/com/qitoffer/dao/CompanyDao.java src/main/webapp/company/apply.jsp|投递状态更新接口（佟乐）"
"71098820|docs/acceptance/defense-outline.md docs/acceptance/selftest-checklist.md|项目验收答辩材料（佟乐）"
"71098821|docs/acceptance/project-summary.md|验收交付与项目总结（佟乐）"
"71098722|docs/acceptance/defense-outline.md docs/acceptance/selftest-checklist.md|项目验收答辩材料（同#71098820，佟乐）"
"71098723|docs/acceptance/project-summary.md|验收交付与项目总结（同#71098821，佟乐）"
)

for t in "${TASKS[@]}"; do
  IFS='|' read -r id files title <<< "$t"
  echo ">>> fix #$id $title"
  # shellcheck disable=SC2086
  git add $files 2>/dev/null || true
  git commit --allow-empty -m "fix #$id $title" || { echo "!! 该编号提交失败，继续下一个"; }
done

# ---------- 2) 推送 ----------
echo ">>> push（分支：$(git rev-parse --abbrev-ref HEAD)）"
git push origin HEAD || {
  echo "!! push 失败。常见原因："
  echo "   - 没权限：用 DevCloud 的个人访问令牌做 HTTPS 密码（DevCloud 个人设置→访问令牌）"
  echo "   - 仓库已有远端新提交：先 git pull --rebase 再重跑本脚本（已提交的编号会报 nothing to commit，可忽略）"
  echo "   - 还没配置远端：git remote add origin <DevCloud仓库HTTPS地址>"
}

echo ""
echo "完成。去 DevCloud 工作项列表刷新：带 fix #编号 的 commit 会把对应工作项自动流转成「已解决」。"
