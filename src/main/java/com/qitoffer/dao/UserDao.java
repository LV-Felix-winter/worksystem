package com.qitoffer.dao;

import com.qitoffer.entity.User;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class UserDao {

    public User findByLogname(String logname) throws SQLException {
        return queryOne("SELECT * FROM tb_users WHERE user_logname = ?", logname);
    }

    public User findByPhone(String phone) throws SQLException {
        return queryOne("SELECT * FROM tb_users WHERE user_phone = ? OR user_logname = ?", phone, phone);
    }

    public boolean companyNameMatches(User user, String companyName) throws SQLException {
        if (user == null || companyName == null || companyName.isEmpty()) {
            return false;
        }
        if (companyName.equals(user.getUserRealname())) {
            return true;
        }
        String sql = "SELECT 1 FROM tb_company WHERE user_id = ? AND company_name = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, user.getUserId());
            ps.setString(2, companyName);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private User queryOne(String sql, String... params) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                ps.setString(i + 1, params[i]);
            }
            rs = ps.executeQuery();
            if (!rs.next()) {
                return null;
            }
            return map(rs);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private User map(ResultSet rs) throws SQLException {
        User user = new User();
        user.setUserId(rs.getInt("user_id"));
        user.setUserLogname(rs.getString("user_logname"));
        user.setUserPwd(rs.getString("user_pwd"));
        user.setUserRealname(rs.getString("user_realname"));
        user.setUserEmail(rs.getString("user_email"));
        user.setUserRole(rs.getInt("user_role"));
        user.setUserState(rs.getInt("user_state"));
        return user;
    }
}
