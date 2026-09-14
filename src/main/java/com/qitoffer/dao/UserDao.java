package com.qitoffer.dao;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.User;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class UserDao {

    public User findById(int userId) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement("SELECT * FROM tb_users WHERE user_id = ?");
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            return rs.next() ? map(rs) : null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

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

    public List<User> listPage(String keyword, Integer role, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM tb_users WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendUserWhere(sql, params, keyword, role);
        sql.append(" ORDER BY user_id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));
        return queryList(sql.toString(), params);
    }

    public int countPage(String keyword, Integer role) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM tb_users WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendUserWhere(sql, params, keyword, role);
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            bind(ps, params);
            rs = ps.executeQuery();
            rs.next();
            return rs.getInt(1);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public int insert(User user) throws SQLException {
        String sql = "INSERT INTO tb_users (user_logname, user_pwd, user_realname, user_email, user_phone, user_role, user_state) "
                + "VALUES (?,?,?,?,?,?,?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, user.getUserLogname());
            ps.setString(2, user.getUserPwd());
            ps.setString(3, user.getUserRealname());
            ps.setString(4, user.getUserEmail());
            ps.setString(5, blankToNull(user.getUserPhone()));
            ps.setInt(6, user.getUserRole());
            ps.setInt(7, user.getUserState());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
            return 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public boolean update(User user) throws SQLException {
        String sql = "UPDATE tb_users SET user_logname=?, user_realname=?, user_email=?, user_phone=?, "
                + "user_role=?, user_state=? WHERE user_id=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, user.getUserLogname());
            ps.setString(2, user.getUserRealname());
            ps.setString(3, user.getUserEmail());
            ps.setString(4, blankToNull(user.getUserPhone()));
            ps.setInt(5, user.getUserRole());
            ps.setInt(6, user.getUserState());
            ps.setInt(7, user.getUserId());
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    public boolean updatePassword(int userId, String newPwd) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement("UPDATE tb_users SET user_pwd=? WHERE user_id=?");
            ps.setString(1, newPwd);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    public boolean existsLogname(String logname, int excludeUserId) throws SQLException {
        String sql = "SELECT 1 FROM tb_users WHERE user_logname = ? AND user_id <> ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, logname);
            ps.setInt(2, excludeUserId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private static void appendUserWhere(StringBuilder sql, List<Object> params, String keyword, Integer role) {
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (user_logname LIKE ? OR user_realname LIKE ? OR IFNULL(user_phone,'') LIKE ? OR IFNULL(user_email,'') LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (role != null) {
            sql.append(" AND user_role = ?");
            params.add(role);
        }
    }

    private List<User> queryList(String sql, List<Object> params) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<User> list = new ArrayList<>();
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            bind(ps, params);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(map(rs));
            }
            return list;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private static void bind(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
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
        try {
            user.setUserPhone(rs.getString("user_phone"));
        } catch (SQLException ignored) {
            user.setUserPhone(null);
        }
        user.setUserRole(rs.getInt("user_role"));
        user.setUserState(rs.getInt("user_state"));
        return user;
    }

    private static String blankToNull(String value) {
        return value == null || value.isBlank() ? null : value.trim();
    }
}
