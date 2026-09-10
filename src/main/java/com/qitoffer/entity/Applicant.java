package com.qitoffer.entity;

import java.util.Date;

public class Applicant {
    private int applicantId;
    private String applicantEmail;
    private String applicantPwd;
    private String applicantName;
    private String applicantPhone;
    private Date applicantRegistdate;

    public int getApplicantId() {
        return applicantId;
    }

    public void setApplicantId(int applicantId) {
        this.applicantId = applicantId;
    }

    public String getApplicantEmail() {
        return applicantEmail;
    }

    public void setApplicantEmail(String applicantEmail) {
        this.applicantEmail = applicantEmail;
    }

    public String getApplicantPwd() {
        return applicantPwd;
    }

    public void setApplicantPwd(String applicantPwd) {
        this.applicantPwd = applicantPwd;
    }

    public String getApplicantName() {
        return applicantName;
    }

    public void setApplicantName(String applicantName) {
        this.applicantName = applicantName;
    }

    public String getApplicantPhone() {
        return applicantPhone;
    }

    public void setApplicantPhone(String applicantPhone) {
        this.applicantPhone = applicantPhone;
    }

    public Date getApplicantRegistdate() {
        return applicantRegistdate;
    }

    public void setApplicantRegistdate(Date applicantRegistdate) {
        this.applicantRegistdate = applicantRegistdate;
    }
}
