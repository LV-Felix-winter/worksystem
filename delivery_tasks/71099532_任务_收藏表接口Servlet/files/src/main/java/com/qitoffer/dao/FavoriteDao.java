package com.qitoffer.dao;

import com.qitoffer.entity.Favorite;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * 收藏 DAO - tb_favorite 增删查，applicant_id + job_id 唯一
 * 处理人：佟乐 | 任务：#71099532
 */
public class FavoriteDao {

    public boolean exists(int applicantId, int jobId) throws SQLException {
        String sql = "SELECT 1 FROM tb_favorite WHERE applicant_id = ? AND job_id = ?";
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

    /** 收藏；已存在则不重复写（唯一键 uk_fav_user_job 兜底） */
    public void add(int applicantId, int jobId) throws SQLException {
        if (exists(applicantId, jobId)) {
            return;
        }
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

    /** 取消收藏，返回是否真的删掉了 */
    public boolean remove(int applicantId, int jobId) throws SQLException {
        String sql = "DELETE FROM tb_favorite WHERE applicant_id = ? AND job_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            ps.setInt(2, jobId);
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** 我的收藏职位，含职位/企业关联信息 */
    public List<Favorite> listByApplicant(int applicantId) throws SQLException {
        String sql = "SELECT f.*, j.job_name, c.company_name, j.job_salary, j.job_area "
                + "FROM tb_favorite f "
                + "JOIN tb_job j ON f.job_id = j.job_id "
                + "JOIN tb_company c ON j.company_id = c.company_id "
                + "WHERE f.applicant_id = ? ORDER BY f.create_time DESC, f.favorite_id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            List<Favorite> list = new ArrayList<>();
            while (rs.next()) {
                Favorite f = new Favorite();
                f.setFavoriteId(rs.getInt("favorite_id"));
                f.setApplicantId(applicantId);
                f.setJobId(rs.getInt("job_id"));
                f.setCreateTime(rs.getTimestamp("create_time"));
                f.setJobName(rs.getString("job_name"));
                f.setCompanyName(rs.getString("company_name"));
                f.setJobSalary(rs.getString("job_salary"));
                f.setJobArea(rs.getString("job_area"));
                list.add(f);
            }
            return list;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 该求职者收藏的职位 id 集合（搜索结果页标「已收藏」用） */
    public List<Integer> jobIdsByApplicant(int applicantId) throws SQLException {
        String sql = "SELECT job_id FROM tb_favorite WHERE applicant_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            List<Integer> ids = new ArrayList<>();
            while (rs.next()) {
                ids.add(rs.getInt(1));
            }
            return ids;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }
}
