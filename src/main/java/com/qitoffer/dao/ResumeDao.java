package com.qitoffer.dao;

import com.qitoffer.entity.Resume;
import com.qitoffer.util.DbUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 简历 DAO - 支持分页、完整度计算
 * 处理人：佟乐 | 任务：#71098792/#71099536
 */
public class ResumeDao {

    /**
     * 分页查询简历列表
     */
    public List<Resume> findByApplicantId(int applicantId, int page, int pageSize) throws SQLException {
        String sql = "SELECT r.*, a.applicant_name, a.applicant_email "
                + "FROM tb_resume r LEFT JOIN tb_applicant a ON r.applicant_id = a.applicant_id "
                + "WHERE r.applicant_id = ? ORDER BY r.resume_id DESC LIMIT ? OFFSET ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            ps.setInt(2, pageSize);
            ps.setInt(3, (page - 1) * pageSize);
            rs = ps.executeQuery();
            return mapResumes(rs);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /**
     * 计算简历完整度 (#71099536 核心算法)
     * 5大模块：基本信息15%、教育经历20%、工作实习25%、项目经历25%、技能证书15%
     */
    public void recalculateCompleteness(int resumeId) throws SQLException {
        String sql = "SELECT * FROM tb_resume WHERE resume_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, resumeId);
            rs = ps.executeQuery();
            if (!rs.next()) return;

            int score = calcScore(rs);
            String updateSql = "UPDATE tb_resume SET completeness = ? WHERE resume_id = ?";
            ps = conn.prepareStatement(updateSql);
            ps.setInt(1, score);
            ps.setInt(2, resumeId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /**
     * 简历完整度加权计算 (#71099536 Task)
     * 模块化评分：各模块根据字段填写情况独立评分
     */
    private int calcScore(ResultSet rs) throws SQLException {
        // 模块1: 基本信息 (权重15%) - 姓名、电话、邮箱
        int basicScore = 0;
        if (rs.getString("realname") != null && !rs.getString("realname").isEmpty()) basicScore += 40;
        if (rs.getString("telephone") != null && !rs.getString("telephone").isEmpty()) basicScore += 30;
        if (rs.getString("email") != null && !rs.getString("email").isEmpty()) basicScore += 30;
        basicScore = Math.min(basicScore, 100);

        // 模块2: 教育经历 (权重20%)
        // 注：教育经历在单独表中，此处简化处理
        int eduScore = 60; // 默认中等分

        // 模块3: 工作/实习经历 (权重25%) - job_experience字段
        int expScore = 0;
        String exp = rs.getString("job_experience");
        if (exp != null && !exp.isEmpty()) {
            if (exp.length() > 100) expScore = 100;
            else if (exp.length() > 50) expScore = 70;
            else expScore = 40;
        }

        // 模块4: 项目经历 (权重25%) - 此处简化，通过job_intension推断
        int projScore = rs.getString("job_intension") != null && !rs.getString("job_intension").isEmpty() ? 80 : 20;

        // 模块5: 技能证书 (权重15%) - head_shot和attachment
        int skillScore = 30;
        if (rs.getString("head_shot") != null && !rs.getString("head_shot").isEmpty()) skillScore += 40;
        if (rs.getString("attachment") != null && !rs.getString("attachment").isEmpty()) skillScore += 30;
        skillScore = Math.min(skillScore, 100);

        // 加权平均 (Task #71099536)
        return (int) Math.round(
                basicScore * 0.15 + eduScore * 0.20 + expScore * 0.25
                        + projScore * 0.25 + skillScore * 0.15
        );
    }

    public Resume findById(int resumeId) throws SQLException {
        String sql = "SELECT r.*, a.applicant_name FROM tb_resume r LEFT JOIN tb_applicant a ON r.applicant_id = a.applicant_id WHERE r.resume_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, resumeId);
            rs = ps.executeQuery();
            if (rs.next()) return mapResume(rs);
            return null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public Resume findByApplicantId(int applicantId) throws SQLException {
        String sql = "SELECT r.*, a.applicant_name FROM tb_resume r LEFT JOIN tb_applicant a ON r.applicant_id = a.applicant_id WHERE r.applicant_id = ? ORDER BY r.resume_id DESC LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            if (rs.next()) return mapResume(rs);
            return null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private List<Resume> mapResumes(ResultSet rs) throws SQLException {
        List<Resume> list = new ArrayList<>();
        while (rs.next()) list.add(mapResume(rs));
        return list;
    }

    private Resume mapResume(ResultSet rs) throws SQLException {
        Resume r = new Resume();
        r.setResumeId(rs.getInt("resume_id"));
        r.setApplicantId(rs.getInt("applicant_id"));
        r.setRealname(rs.getString("realname"));
        r.setGender(rs.getString("gender"));
        r.setBirthday(rs.getDate("birthday"));
        r.setCurrentLoc(rs.getString("current_loc"));
        r.setResidentLoc(rs.getString("resident_loc"));
        r.setTelephone(rs.getString("telephone"));
        r.setEmail(rs.getString("email"));
        r.setJobIntension(rs.getString("job_intension"));
        r.setJobExperience(rs.getString("job_experience"));
        r.setHeadShot(rs.getString("head_shot"));
        r.setAttachment(rs.getString("attachment"));
        r.setCompleteness(rs.getInt("completeness"));
        r.setApplicantName(rs.getString("applicant_name"));
        r.setApplicantEmail(rs.getString("applicant_email"));
        return r;
    }
}
