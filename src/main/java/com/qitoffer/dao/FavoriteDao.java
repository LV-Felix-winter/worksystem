package com.qitoffer.dao;

import com.qitoffer.entity.Favorite;
import com.qitoffer.util.DbUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 收藏职位 DAO - CRUD接口 (#71099532)
 * 处理人：佟乐
 */
public class FavoriteDao {

    /** GET /api/favorites - 获取收藏列表 */
    public List<Favorite> findByApplicantId(int applicantId) throws SQLException {
        String sql = "SELECT f.*, j.job_name, c.company_name, j.job_salary, j.job_area "
                + "FROM tb_favorite f "
                + "LEFT JOIN tb_job j ON f.job_id = j.job_id "
                + "LEFT JOIN tb_company c ON j.company_id = c.company_id "
                + "WHERE f.applicant_id = ? ORDER BY f.create_time DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            return mapFavorites(rs);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** POST /api/favorites - 添加收藏 */
    public void add(int applicantId, int jobId) throws SQLException {
        String sql = "INSERT INTO tb_favorite (applicant_id, job_id, create_time) VALUES (?, ?, NOW())";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            ps.setInt(2, jobId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** DELETE /api/favorites/{id} - 取消收藏 */
    public void remove(int applicantId, int jobId) throws SQLException {
        String sql = "DELETE FROM tb_favorite WHERE applicant_id = ? AND job_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            ps.setInt(2, jobId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** GET /api/favorites/exists/{jobId} - 检查是否已收藏 */
    public boolean exists(int applicantId, int jobId) throws SQLException {
        String sql = "SELECT 1 FROM tb_favorite WHERE applicant_id = ? AND job_id = ? LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            ps.setInt(2, jobId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public int countByApplicantId(int applicantId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tb_favorite WHERE applicant_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            if (rs.next()) return rs.getInt(1);
            return 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private List<Favorite> mapFavorites(ResultSet rs) throws SQLException {
        List<Favorite> list = new ArrayList<>();
        while (rs.next()) {
            Favorite f = new Favorite();
            f.setFavoriteId(rs.getInt("favorite_id"));
            f.setApplicantId(rs.getInt("applicant_id"));
            f.setJobId(rs.getInt("job_id"));
            f.setCreateTime(rs.getTimestamp("create_time"));
            f.setJobName(rs.getString("job_name"));
            f.setCompanyName(rs.getString("company_name"));
            f.setJobSalary(rs.getString("job_salary"));
            f.setJobArea(rs.getString("job_area"));
            list.add(f);
        }
        return list;
    }
}
