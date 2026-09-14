package com.qitoffer.dao;

import com.qitoffer.common.Dict;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

/** 企业端应聘卡片与职位配图的演示占位数据。 */
public final class DemoSeed {
    private static volatile boolean done;

    private DemoSeed() {
    }

    public static synchronized void ensure() {
        if (done) {
            return;
        }
        Connection conn = null;
        try {
            conn = DbUtil.getConnection();
            seedApplicant(conn, "lisiqi@itoffer.cn", "李思琪", "13800138001", "女", "2003-05-18",
                    "杭州", "温州", "前端开发", "做过校园官网改版，熟悉 Vue 与切图还原。",
                    "浙江大学||计算机科学与技术||硕士||2024.09-2027.06||||前端工程、人机交互",
                    "/images/avatar-2.svg", 1, Dict.APPLY_PENDING, 3);
            seedApplicant(conn, "wanghaoran@itoffer.cn", "王浩然", "13800138002", "男", "2002-08-09",
                    "青岛", "潍坊", "软件测试", "能写用例、跟缺陷，熟悉接口联调。",
                    "中国海洋大学||软件工程||本科||2020.09-2024.06||GPA 3.5/4||软件测试、数据库原理",
                    "/images/avatar-3.svg", 4, Dict.APPLY_VIEWED, 8);
            seedApplicant(conn, "chenyuan@itoffer.cn", "陈予安", "13800138003", "女", "2004-03-22",
                    "济南", "临沂", "产品助理", "做过课程项目需求梳理和原型。",
                    "山东大学||数字媒体技术||本科||2022.09-2026.06||||交互设计、产品思维",
                    "/images/avatar-4.svg", 1, Dict.APPLY_INTERVIEW, 1);
            seedApplicant(conn, "zhaoqiming@itoffer.cn", "赵启明", "13800138004", "男", "2000-11-02",
                    "北京", "石家庄", "Java 开发", "有分布式课设经验，能独立完成接口。",
                    "北京邮电大学||软件工程||硕士||2023.09-2026.06||||分布式系统、Java 后端",
                    "/images/avatar-5.svg", 4, Dict.APPLY_PENDING, 5);
            updateIfEmpty(conn, "UPDATE tb_resume SET head_shot = '/images/avatar-1.svg' "
                    + "WHERE resume_id = 1 AND (head_shot IS NULL OR head_shot = '')");
            ensureApply(conn, "test@itoffer.cn", 1, Dict.APPLY_PENDING, 2);
            done = true;
        } catch (SQLException ignored) {
        } finally {
            DbUtil.close(null, null, conn);
        }
    }

    private static void seedApplicant(Connection conn, String email, String name, String phone,
                                      String gender, String birthday, String currentLoc, String resident,
                                      String intention, String experience, String education,
                                      String photo, int jobId, int applyState, int daysAgo)
            throws SQLException {
        if (exists(conn, "SELECT 1 FROM tb_applicant WHERE applicant_email = ?", email)) {
            ensureApply(conn, email, jobId, applyState, daysAgo);
            return;
        }
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement(
                    "INSERT INTO tb_applicant (applicant_email, applicant_pwd, applicant_name, applicant_phone, applicant_registdate) "
                            + "VALUES (?, '123456', ?, ?, NOW())",
                    Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, email);
            ps.setString(2, name);
            ps.setString(3, phone);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (!rs.next()) {
                return;
            }
            int applicantId = rs.getInt(1);
            DbUtil.close(rs, ps, null);
            rs = null;
            ps = conn.prepareStatement(
                    "INSERT INTO tb_resume (applicant_id, realname, gender, birthday, current_loc, resident_loc, "
                            + "telephone, email, job_intension, job_experience, education, head_shot, completeness) "
                            + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 76)");
            ps.setInt(1, applicantId);
            ps.setString(2, name);
            ps.setString(3, gender);
            ps.setString(4, birthday);
            ps.setString(5, currentLoc);
            ps.setString(6, resident);
            ps.setString(7, phone);
            ps.setString(8, email);
            ps.setString(9, intention);
            ps.setString(10, experience);
            ps.setString(11, education);
            ps.setString(12, photo);
            ps.executeUpdate();
        } finally {
            DbUtil.close(rs, ps, null);
        }
        ensureApply(conn, email, jobId, applyState, daysAgo);
    }

    private static void ensureApply(Connection conn, String email, int jobId, int applyState, int daysAgo)
            throws SQLException {
        if (!exists(conn, "SELECT 1 FROM tb_job WHERE job_id = ?", jobId)) {
            jobId = 1;
        }
        if (!exists(conn, "SELECT 1 FROM tb_job WHERE job_id = ?", jobId)) {
            return;
        }
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement(
                    "SELECT r.resume_id FROM tb_resume r JOIN tb_applicant a ON r.applicant_id = a.applicant_id "
                            + "WHERE a.applicant_email = ? LIMIT 1");
            ps.setString(1, email);
            rs = ps.executeQuery();
            if (!rs.next()) {
                return;
            }
            int resumeId = rs.getInt(1);
            if (exists(conn, "SELECT 1 FROM tb_apply WHERE resume_id = ? AND job_id = ?", resumeId, jobId)) {
                return;
            }
            DbUtil.close(rs, ps, null);
            rs = null;
            ps = conn.prepareStatement(
                    "INSERT INTO tb_apply (job_id, resume_id, apply_date, apply_state) "
                            + "VALUES (?, ?, DATE_SUB(NOW(), INTERVAL ? DAY), ?)");
            ps.setInt(1, jobId);
            ps.setInt(2, resumeId);
            ps.setInt(3, daysAgo);
            ps.setInt(4, applyState);
            ps.executeUpdate();
        } finally {
            DbUtil.close(rs, ps, null);
        }
    }

    private static boolean exists(Connection conn, String sql, Object... params) throws SQLException {
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, null);
        }
    }

    private static void updateIfEmpty(Connection conn, String sql) throws SQLException {
        PreparedStatement ps = null;
        try {
            ps = conn.prepareStatement(sql);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, null);
        }
    }
}
