package com.qitoffer.entity;

import java.util.Date;

/**
 * 投递记录实体 - 对应 tb_apply 表（含 join 出的职位/企业/简历字段）
 * 状态常量见 com.qitoffer.common.Dict：0 拒绝 1 待处理 2 已查看 3 已面试
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

    // 简历摘要（企业查看用）
    private String resumeRealname;
    private String resumeGender;
    private String resumeTelephone;
    private String resumeEmail;
    private String resumeJobIntension;
    private String resumeJobExperience;
    private String resumeAttachment;
    private int resumeCompleteness;

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
    public String getResumeRealname() { return resumeRealname; }
    public void setResumeRealname(String resumeRealname) { this.resumeRealname = resumeRealname; }
    public String getResumeGender() { return resumeGender; }
    public void setResumeGender(String resumeGender) { this.resumeGender = resumeGender; }
    public String getResumeTelephone() { return resumeTelephone; }
    public void setResumeTelephone(String resumeTelephone) { this.resumeTelephone = resumeTelephone; }
    public String getResumeEmail() { return resumeEmail; }
    public void setResumeEmail(String resumeEmail) { this.resumeEmail = resumeEmail; }
    public String getResumeJobIntension() { return resumeJobIntension; }
    public void setResumeJobIntension(String resumeJobIntension) { this.resumeJobIntension = resumeJobIntension; }
    public String getResumeJobExperience() { return resumeJobExperience; }
    public void setResumeJobExperience(String resumeJobExperience) { this.resumeJobExperience = resumeJobExperience; }
    public String getResumeAttachment() { return resumeAttachment; }
    public void setResumeAttachment(String resumeAttachment) { this.resumeAttachment = resumeAttachment; }
    public int getResumeCompleteness() { return resumeCompleteness; }
    public void setResumeCompleteness(int resumeCompleteness) { this.resumeCompleteness = resumeCompleteness; }
}
