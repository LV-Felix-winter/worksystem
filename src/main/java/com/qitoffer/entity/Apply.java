package com.qitoffer.entity;

import java.util.Date;

/**
 * 投递记录实体 - 对应 tb_apply 表
 * 处理人：佟乐 | 任务：#71099538/#71099539
 */
public class Apply {
    private int applyId;
    private int jobId;
    private int resumeId;
    private Date applyDate;
    private int applyState;
    // 关联字段
    private String jobName;
    private String companyName;
    private String jobSalary;
    private String jobArea;
    private String companyPic;
    private String resumeRealname;

    public int getApplyId() { return applyId; }
    public void setApplyId(int applyId) { this.applyId = applyId; }
    public int getJobId() { return jobId; }
    public void setJobId(int jobId) { this.jobId = jobId; }
    public int getResumeId() { return resumeId; }
    public void setResumeId(int resumeId) { this.resumeId = resumeId; }
    public Date getApplyDate() { return applyDate; }
    public void setApplyDate(Date applyDate) { this.applyDate = applyDate; }
    public int getApplyState() { return applyState; }
    public void setApplyState(int applyState) { this.applyState = applyState; }
    public String getJobName() { return jobName; }
    public void setJobName(String jobName) { this.jobName = jobName; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    public String getJobSalary() { return jobSalary; }
    public void setJobSalary(String jobSalary) { this.jobSalary = jobSalary; }
    public String getJobArea() { return jobArea; }
    public void setJobArea(String jobArea) { this.jobArea = jobArea; }
    public String getCompanyPic() { return companyPic; }
    public void setCompanyPic(String companyPic) { this.companyPic = companyPic; }
    public String getResumeRealname() { return resumeRealname; }
    public void setResumeRealname(String resumeRealname) { this.resumeRealname = resumeRealname; }
}
