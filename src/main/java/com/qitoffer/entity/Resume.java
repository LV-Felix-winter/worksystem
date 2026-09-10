package com.qitoffer.entity;

import java.util.Date;
import java.util.List;

/**
 * 简历实体 - 对应 tb_resume 表
 * 处理人：佟乐 | 任务：#71098791/#71098792/#71099535/#71099536
 */
public class Resume {
    private int resumeId;
    private int applicantId;
    private String realname;
    private String gender;
    private Date birthday;
    private String currentLoc;
    private String residentLoc;
    private String telephone;
    private String email;
    private String jobIntension;
    private String jobExperience;
    private String headShot;
    private String attachment;
    private int completeness;

    // 关联字段
    private String applicantName;
    private String applicantEmail;

    public int getResumeId() { return resumeId; }
    public void setResumeId(int resumeId) { this.resumeId = resumeId; }
    public int getApplicantId() { return applicantId; }
    public void setApplicantId(int applicantId) { this.applicantId = applicantId; }
    public String getRealname() { return realname; }
    public void setRealname(String realname) { this.realname = realname; }
    public String getGender() { return gender; }
    public void setGender(String gender) { this.gender = gender; }
    public Date getBirthday() { return birthday; }
    public void setBirthday(Date birthday) { this.birthday = birthday; }
    public String getCurrentLoc() { return currentLoc; }
    public void setCurrentLoc(String currentLoc) { this.currentLoc = currentLoc; }
    public String getResidentLoc() { return residentLoc; }
    public void setResidentLoc(String residentLoc) { this.residentLoc = residentLoc; }
    public String getTelephone() { return telephone; }
    public void setTelephone(String telephone) { this.telephone = telephone; }
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }
    public String getJobIntension() { return jobIntension; }
    public void setJobIntension(String jobIntension) { this.jobIntension = jobIntension; }
    public String getJobExperience() { return jobExperience; }
    public void setJobExperience(String jobExperience) { this.jobExperience = jobExperience; }
    public String getHeadShot() { return headShot; }
    public void setHeadShot(String headShot) { this.headShot = headShot; }
    public String getAttachment() { return attachment; }
    public void setAttachment(String attachment) { this.attachment = attachment; }
    public int getCompleteness() { return completeness; }
    public void setCompleteness(int completeness) { this.completeness = completeness; }
    public String getApplicantName() { return applicantName; }
    public void setApplicantName(String applicantName) { this.applicantName = applicantName; }
    public String getApplicantEmail() { return applicantEmail; }
    public void setApplicantEmail(String applicantEmail) { this.applicantEmail = applicantEmail; }
}
