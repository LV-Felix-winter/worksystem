package com.qitoffer.entity;

/** 4 个统计卡片的数据 */
public class DashboardStats {
    private int hiringJobs;      // 在招职位数
    private int totalApplies;    // 投递总数
    private int pendingApplies;  // 待处理
    private int todayApplies;    // 今日投递

    public int getHiringJobs() { return hiringJobs; }
    public void setHiringJobs(int hiringJobs) { this.hiringJobs = hiringJobs; }

    public int getTotalApplies() { return totalApplies; }
    public void setTotalApplies(int totalApplies) { this.totalApplies = totalApplies; }

    public int getPendingApplies() { return pendingApplies; }
    public void setPendingApplies(int pendingApplies) { this.pendingApplies = pendingApplies; }

    public int getTodayApplies() { return todayApplies; }
    public void setTodayApplies(int todayApplies) { this.todayApplies = todayApplies; }
}