package com.qitoffer.entity;

/**
 * 职位实体 - 对应 tb_job 表（含 join 出的企业字段）
 * 处理人：佟乐 | 任务：#71098793/#71098794/#71099528/#71099529
 */
public class Job {
    private int jobId;
    private int companyId;
    private String jobName;
    private int jobHiringnum;
    private String jobSalary;
    private String jobArea;
    private String jobDesc;
    private String jobEndtime;
    private int jobState;
    private int jobViewnum;

    // 关联字段（JOIN tb_company）
    private String companyName;
    private String companyArea;
    private String companySize;
    private String companyType;

    public int getJobId() { return jobId; }
    public void setJobId(int jobId) { this.jobId = jobId; }
    public int getCompanyId() { return companyId; }
    public void setCompanyId(int companyId) { this.companyId = companyId; }
    public String getJobName() { return jobName; }
    public void setJobName(String jobName) { this.jobName = jobName; }
    public int getJobHiringnum() { return jobHiringnum; }
    public void setJobHiringnum(int jobHiringnum) { this.jobHiringnum = jobHiringnum; }
    public String getJobSalary() { return jobSalary; }
    public void setJobSalary(String jobSalary) { this.jobSalary = jobSalary; }
    public String getJobArea() { return jobArea; }
    public void setJobArea(String jobArea) { this.jobArea = jobArea; }
    public String getJobDesc() { return jobDesc; }
    public void setJobDesc(String jobDesc) { this.jobDesc = jobDesc; }
    public String getJobEndtime() { return jobEndtime; }
    public void setJobEndtime(String jobEndtime) { this.jobEndtime = jobEndtime; }
    public int getJobState() { return jobState; }
    public void setJobState(int jobState) { this.jobState = jobState; }
    public int getJobViewnum() { return jobViewnum; }
    public void setJobViewnum(int jobViewnum) { this.jobViewnum = jobViewnum; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    public String getCompanyArea() { return companyArea; }
    public void setCompanyArea(String companyArea) { this.companyArea = companyArea; }
    public String getCompanySize() { return companySize; }
    public void setCompanySize(String companySize) { this.companySize = companySize; }
    public String getCompanyType() { return companyType; }
    public void setCompanyType(String companyType) { this.companyType = companyType; }
}
