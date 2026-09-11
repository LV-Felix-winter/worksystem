package com.qitoffer.entity;

/**
 * 企业实体 - 对应 tb_company 表
 * 处理人：佟乐 | 任务：#71098793/#71098794/#71099539
 */
public class Company {
    private int companyId;
    private int userId;
    private String companyName;
    private String companyArea;
    private String companySize;
    private String companyType;
    private String companyBrief;
    private int companyState;
    private int companySort;
    private int companyViewnum;
    private String companyPic;

    public int getCompanyId() { return companyId; }
    public void setCompanyId(int companyId) { this.companyId = companyId; }
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    public String getCompanyArea() { return companyArea; }
    public void setCompanyArea(String companyArea) { this.companyArea = companyArea; }
    public String getCompanySize() { return companySize; }
    public void setCompanySize(String companySize) { this.companySize = companySize; }
    public String getCompanyType() { return companyType; }
    public void setCompanyType(String companyType) { this.companyType = companyType; }
    public String getCompanyBrief() { return companyBrief; }
    public void setCompanyBrief(String companyBrief) { this.companyBrief = companyBrief; }
    public int getCompanyState() { return companyState; }
    public void setCompanyState(int companyState) { this.companyState = companyState; }
    public int getCompanySort() { return companySort; }
    public void setCompanySort(int companySort) { this.companySort = companySort; }
    public int getCompanyViewnum() { return companyViewnum; }
    public void setCompanyViewnum(int companyViewnum) { this.companyViewnum = companyViewnum; }
    public String getCompanyPic() { return companyPic; }
    public void setCompanyPic(String companyPic) { this.companyPic = companyPic; }
}
