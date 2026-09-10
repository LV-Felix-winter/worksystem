package com.qitoffer.dao;

import com.qitoffer.entity.Applicant;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;

public class ApplicantDao {

    public Applicant findByPhone(String phone) throws SQLException {
        return queryOne("SELECT * FROM tb_applicant WHERE applicant_phone = ?", phone);
    }

    public Applicant findByEmail(String email) throws SQLException {
        return queryOne("SELECT * FROM tb_applicant WHERE applicant_email = ?", email);
    }

    public void insert(Applicant applicant) throws SQLException {
        String sql = "INSERT INTO tb_applicant (applicant_email, applicant_pwd, applicant_name, "
                + "applicant_phone, applicant_registdate) VALUES (?,?,?,?,?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, applicant.getApplicantEmail());
            ps.setString(2, applicant.getApplicantPwd());
            ps.setString(3, applicant.getApplicantName());
            ps.setString(4, applicant.getApplicantPhone());
            ps.setTimestamp(5, new Timestamp(System.currentTimeMillis()));
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    private Applicant queryOne(String sql, String value) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, value);
            rs = ps.executeQuery();
            if (!rs.next()) {
                return null;
            }
            Applicant a = new Applicant();
            a.setApplicantId(rs.getInt("applicant_id"));
            a.setApplicantEmail(rs.getString("applicant_email"));
            a.setApplicantPwd(rs.getString("applicant_pwd"));
            a.setApplicantName(rs.getString("applicant_name"));
            a.setApplicantPhone(rs.getString("applicant_phone"));
            a.setApplicantRegistdate(rs.getTimestamp("applicant_registdate"));
            return a;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }
}
