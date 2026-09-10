package com.qitoffer.dao;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.Apply;
import com.qitoffer.util.DbUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 投递记录 DAO - 状态流转与更新
 * 处理人：佟乐 | 任务：#71099538/#71099539
 */
public class ApplyDao {

    /** 查询求职者的投递记录（含状态流转） */
    public List<Apply> findByApplicantId(int applicantId, int resumeId) throws SQLException {
        String sql = "SELECT a.*, j.job_name, c.company_name, j.job_salary, j.job_area, c.company_pic, r.realname as resume_realname "
                + "FROM tb_apply a "
                + "LEFT JOIN tb_job j ON a.job_id = j.job_id "
                + "LEFT JOIN tb_company c ON j.company_id = c.company_id "
                + "LEFT JOIN tb_resume r ON a.resume_id = r.resume_id "
                + "WHERE a.applicant_id = ? AND a.resume_id = ? "
                + "ORDER BY a.apply_date DESC";
        // 注意：tb_apply 没有 applicant_id 字段，需要通过 resume 关联
        // 修正：从 tb_resume 关联
        sql = "SELECT a.*, j.job_name, c.company_name, j.job_salary, j.job_area, c.company_pic, r.realname as resume_realname "
                + "FROM tb_apply a "
                + "LEFT JOIN tb_job j ON a.job_id = j.job_id "
                + "LEFT JOIN tb_company c ON j.company_id = c.company_id "
                + "LEFT JOIN tb_resume r ON a.resume_id = r.resume_id "
                + "WHERE r.applicant_id = ? "
                + "ORDER BY a.apply_date DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            return mapApplies(rs);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 按状态统计投递数量 (#71099538) */
    public java.util.Map<String, Integer> countByStatus(int applicantId) throws SQLException {
        String sql = "SELECT a.apply_state, COUNT(*) as cnt FROM tb_apply a "
                + "JOIN tb_resume r ON a.resume_id = r.resume_id "
                + "WHERE r.applicant_id = ? GROUP BY a.apply_state";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        java.util.Map<String, Integer> result = new java.util.HashMap<>();
        result.put("pending", 0);
        result.put("reviewing", 0);
        result.put("accepted", 0);
        result.put("rejected", 0);
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            while (rs.next()) {
                int state = rs.getInt("apply_state");
                int cnt = rs.getInt("cnt");
                switch (state) {
                    case Dict.APPLY_PENDING: result.put("pending", cnt); break;
                    case Dict.APPLY_VIEWED: result.put("reviewing", cnt); break;
                    case Dict.APPLY_INTERVIEW: result.put("accepted", cnt); break;
                    case Dict.APPLY_REJECTED: result.put("rejected", cnt); break;
                }
            }
        } finally {
            DbUtil.close(rs, ps, conn);
        }
        return result;
    }

    /**
     * 更新投递状态 (#71099539 核心接口)
     * 状态流转: 1(待处理) → 2(已查看) → 3(已面试) 或 0(已拒绝)
     */
    public void updateStatus(int applyId, int newState, int operatorId) throws SQLException {
        String sql = "UPDATE tb_apply SET apply_state = ? WHERE apply_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, newState);
            ps.setInt(2, applyId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /**
     * 求职者投递职位 (#71099538 流程入口)
     */
    public int apply(int resumeId, int jobId) throws SQLException {
        String sql = "INSERT INTO tb_apply (job_id, resume_id, apply_date, apply_state) VALUES (?, ?, NOW(), 1)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, jobId);
            ps.setInt(2, resumeId);
            ps.executeUpdate();
            ResultSet rs = ps.getGeneratedKeys();
            if (rs.next()) return rs.getInt(1);
            return -1;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** 检查是否已投递 */
    public boolean exists(int resumeId, int jobId) throws SQLException {
        String sql = "SELECT 1 FROM tb_apply WHERE resume_id = ? AND job_id = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, resumeId);
            ps.setInt(2, jobId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private List<Apply> mapApplies(ResultSet rs) throws SQLException {
        List<Apply> list = new ArrayList<>();
        while (rs.next()) {
            Apply a = new Apply();
            a.setApplyId(rs.getInt("apply_id"));
            a.setJobId(rs.getInt("job_id"));
            a.setResumeId(rs.getInt("resume_id"));
            a.setApplyDate(rs.getTimestamp("apply_date"));
            a.setApplyState(rs.getInt("apply_state"));
            a.setJobName(rs.getString("job_name"));
            a.setCompanyName(rs.getString("company_name"));
            a.setJobSalary(rs.getString("job_salary"));
            a.setJobArea(rs.getString("job_area"));
            a.setCompanyPic(rs.getString("company_pic"));
            a.setResumeRealname(rs.getString("resume_realname"));
            list.add(a);
        }
        return list;
    }
}
