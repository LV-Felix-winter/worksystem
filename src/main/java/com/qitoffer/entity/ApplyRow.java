package com.qitoffer.entity;

import java.util.Date;

/**
 * 投递列表行
 * 对应 SQL：SELECT a.apply_id, j.job_name, a.resume_id, a.apply_date, a.apply_state
 */
public class ApplyRow {
    private int applyId;
    private String jobName;
    private int resumeId;
    private Date applyDate;
    private int applyState;   // 1待处理 2已查看 3已面试 0已拒绝

    public int getApplyId() { return applyId; }
    public void setApplyId(int applyId) { this.applyId = applyId; }

    public String getJobName() { return jobName; }
    public void setJobName(String jobName) { this.jobName = jobName; }

    public int getResumeId() { return resumeId; }
    public void setResumeId(int resumeId) { this.resumeId = resumeId; }

    public Date getApplyDate() { return applyDate; }
    public void setApplyDate(Date applyDate) { this.applyDate = applyDate; }

    public int getApplyState() { return applyState; }
    public void setApplyState(int applyState) { this.applyState = applyState; }

    /** 状态中文名，JSP 直接用 ${row.stateText} */
    public String getStateText() {
        switch (applyState) {
            case 1: return "待处理";
            case 2: return "已查看";
            case 3: return "已面试";
            case 0: return "已拒绝";
            default: return "未知";
        }
    }
}