package com.qitoffer.dao;

import com.qitoffer.entity.Company;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

/**
 * 企业 DAO
 * 处理人：佟乐 | 任务：#71099539（投递状态更新需校验职位归属企业）
 */
public class CompanyDao {

    /** 按后台账号找企业，找不到返回 null */
    public Company findByUserId(int userId) throws SQLException {
        String sql = "SELECT * FROM tb_company WHERE user_id = ? ORDER BY company_id LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            rs = ps.executeQuery();
            return rs.next() ? mapCompany(rs) : null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 按企业 id 查企业 */
    public Company findById(int companyId) throws SQLException {
        String sql = "SELECT * FROM tb_company WHERE company_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, companyId);
            rs = ps.executeQuery();
            return rs.next() ? mapCompany(rs) : null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private Company mapCompany(ResultSet rs) throws SQLException {
        Company c = new Company();
        c.setCompanyId(rs.getInt("company_id"));
        c.setUserId(rs.getInt("user_id"));
        c.setCompanyName(rs.getString("company_name"));
        c.setCompanyArea(rs.getString("company_area"));
        c.setCompanySize(rs.getString("company_size"));
        c.setCompanyType(rs.getString("company_type"));
        c.setCompanyBrief(rs.getString("company_brief"));
        c.setCompanyState(rs.getInt("company_state"));
        c.setCompanyViewnum(rs.getInt("company_viewnum"));
        c.setCompanyPic(rs.getString("company_pic"));
        return c;
    }
}
