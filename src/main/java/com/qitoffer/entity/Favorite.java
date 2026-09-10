package com.qitoffer.entity;

import java.util.Date;

/**
 * 收藏职位实体 - 对应 tb_favorite 表
 * 处理人：佟乐 | 任务：#71099532
 */
public class Favorite {
    private int favoriteId;
    private int applicantId;
    private int jobId;
    private Date createTime;
    private String jobName;
    private String companyName;
    private String jobSalary;
    private String jobArea;

    public int getFavoriteId() { return favoriteId; }
    public void setFavoriteId(int favoriteId) { this.favoriteId = favoriteId; }
    public int getApplicantId() { return applicantId; }
    public void setApplicantId(int applicantId) { this.applicantId = applicantId; }
    public int getJobId() { return jobId; }
    public void setJobId(int jobId) { this.jobId = jobId; }
    public Date getCreateTime() { return createTime; }
    public void setCreateTime(Date createTime) { this.createTime = createTime; }
    public String getJobName() { return jobName; }
    public void setJobName(String jobName) { this.jobName = jobName; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    public String getJobSalary() { return jobSalary; }
    public void setJobSalary(String jobSalary) { this.jobSalary = jobSalary; }
    public String getJobArea() { return jobArea; }
    public void setJobArea(String jobArea) { this.jobArea = jobArea; }
}
