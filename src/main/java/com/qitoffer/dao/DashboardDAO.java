package com.qitoffer.dao;

import com.qitoffer.entity.ApplyRow;
import com.qitoffer.entity.DashboardStats;
import com.qitoffer.util.DbUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class DashboardDAO {

    /** 一次性查 4 个卡片数字（一条 SQL 搞定，避免 4 次连库） */
    public DashboardStats loadStats(int companyId) throws SQLException {
        DashboardStats s = new DashboardStats();

        // 在招职位
        String sql1 = "SELECT COUNT(*) FROM tb_job WHERE company_id=? AND job_state=1";

        // 投递总数 / 待处理 / 今日（JOIN tb_job 限定企业）
        String sql2 =
                "SELECT " +
                        "  COUNT(*) AS total, " +
                        "  SUM(CASE WHEN a.apply_state=1 THEN 1 ELSE 0 END) AS pending, " +
                        "  SUM(CASE WHEN DATE(a.apply_date)=CURDATE() THEN 1 ELSE 0 END) AS today " +
                        "FROM tb_apply a JOIN tb_job j ON a.job_id=j.job_id " +
                        "WHERE j.company_id=?";

        try (Connection conn = DbUtil.getConnection()) {
            // 卡片1：在招职位
            try (PreparedStatement ps = conn.prepareStatement(sql1)) {
                ps.setInt(1, companyId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) s.setHiringJobs(rs.getInt(1));
                }
            }
            // 卡片2/3/4：投递总数、待处理、今日
            try (PreparedStatement ps = conn.prepareStatement(sql2)) {
                ps.setInt(1, companyId);
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        s.setTotalApplies(rs.getInt("total"));
                        s.setPendingApplies(rs.getInt("pending"));
                        s.setTodayApplies(rs.getInt("today"));
                    }
                }
            }
        }
        return s;
    }

    /** 投递列表，applyState 为 null 表示全部 */
    public List<ApplyRow> listApplies(int companyId, Integer applyState) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT a.apply_id, j.job_name, a.resume_id, a.apply_date, a.apply_state, " +
                        "r.realname AS applicant_name " +
                        "FROM tb_apply a JOIN tb_job j ON a.job_id=j.job_id " +
                        "JOIN tb_resume r ON a.resume_id=r.resume_id " +
                        "WHERE j.company_id=? ");
        if (applyState != null) sql.append(" AND a.apply_state=? ");
        sql.append(" ORDER BY a.apply_date DESC LIMIT 200");

        List<ApplyRow> list = new ArrayList<>();
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int i = 1;
            ps.setInt(i++, companyId);
            if (applyState != null) ps.setInt(i, applyState);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    ApplyRow r = new ApplyRow();
                    r.setApplyId(rs.getInt("apply_id"));
                    r.setJobName(rs.getString("job_name"));
                    r.setResumeId(rs.getInt("resume_id"));
                    r.setApplyDate(rs.getTimestamp("apply_date"));
                    r.setApplyState(rs.getInt("apply_state"));
                    r.setApplicantName(rs.getString("applicant_name"));
                    list.add(r);
                }
            }
        }
        return list;
    }

    /** 前台首页数据条：企业 / 在招 / 求职者 / 投递 / 简历 / 浏览 */
    public int[] loadHomeCounts() throws SQLException {
        String sql = "SELECT "
                + "(SELECT COUNT(*) FROM tb_company) AS companies, "
                + "(SELECT COUNT(*) FROM tb_job WHERE job_state = 1) AS jobs, "
                + "(SELECT COUNT(*) FROM tb_applicant) AS applicants, "
                + "(SELECT COUNT(*) FROM tb_apply) AS applies, "
                + "(SELECT COUNT(*) FROM tb_resume) AS resumes, "
                + "(SELECT COALESCE(SUM(job_viewnum), 0) FROM tb_job) AS views";
        try (Connection conn = DbUtil.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            int[] n = new int[6];
            if (rs.next()) {
                n[0] = rs.getInt("companies");
                n[1] = rs.getInt("jobs");
                n[2] = rs.getInt("applicants");
                n[3] = rs.getInt("applies");
                n[4] = rs.getInt("resumes");
                n[5] = rs.getInt("views");
            }
            return n;
        }
    }
}