package com.qitoffer.entity;

import java.util.Date;

/** 求职者与企业就某一职位的沟通会话。 */
public class Talk {
    private int talkId;
    private int jobId;
    private int companyId;
    private int applicantId;
    private Date lastTime;
    private String jobName;
    private String jobSalary;
    private String jobArea;
    private String companyName;
    private String applicantName;
    private String lastContent;

    public int getTalkId() { return talkId; }
    public void setTalkId(int talkId) { this.talkId = talkId; }
    public int getJobId() { return jobId; }
    public void setJobId(int jobId) { this.jobId = jobId; }
    public int getCompanyId() { return companyId; }
    public void setCompanyId(int companyId) { this.companyId = companyId; }
    public int getApplicantId() { return applicantId; }
    public void setApplicantId(int applicantId) { this.applicantId = applicantId; }
    public Date getLastTime() { return lastTime; }
    public void setLastTime(Date lastTime) { this.lastTime = lastTime; }
    public String getJobName() { return jobName; }
    public void setJobName(String jobName) { this.jobName = jobName; }
    public String getJobSalary() { return jobSalary; }
    public void setJobSalary(String jobSalary) { this.jobSalary = jobSalary; }
    public String getJobArea() { return jobArea; }
    public void setJobArea(String jobArea) { this.jobArea = jobArea; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }
    public String getLastContent() { return lastContent; }
    public void setLastContent(String lastContent) { this.lastContent = lastContent; }
}
