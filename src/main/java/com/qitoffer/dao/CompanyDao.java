package com.qitoffer.dao;

import com.qitoffer.entity.Company;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

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

    /** 前台企业详情浏览量 +1 */
    public void addViewnum(int companyId) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement("UPDATE tb_company SET company_viewnum = company_viewnum + 1 WHERE company_id = ?");
            ps.setInt(1, companyId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
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
        c.setCompanySort(rs.getInt("company_sort"));
        return c;
    }

    public boolean updateOwned(Company company) throws SQLException {
        String sql = "UPDATE tb_company SET company_area=?, company_size=?, company_type=?, company_brief=?, company_pic=? "
                + "WHERE company_id=? AND user_id=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, company.getCompanyArea());
            ps.setString(2, company.getCompanySize());
            ps.setString(3, company.getCompanyType());
            ps.setString(4, company.getCompanyBrief());
            ps.setString(5, company.getCompanyPic());
            ps.setInt(6, company.getCompanyId());
            ps.setInt(7, company.getUserId());
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    public List<Company> listPage(String keyword, Integer state, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT * FROM tb_company WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendWhere(sql, params, keyword, state);
        sql.append(" ORDER BY company_sort ASC, company_id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));
        return queryList(sql.toString(), params);
    }

    public int countPage(String keyword, Integer state) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM tb_company WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendWhere(sql, params, keyword, state);
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            rs.next();
            return rs.getInt(1);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public int insert(Company company) throws SQLException {
        String sql = "INSERT INTO tb_company (user_id, company_name, company_area, company_size, company_type, "
                + "company_brief, company_state, company_sort, company_viewnum, company_pic) "
                + "VALUES (?,?,?,?,?,?,?,?,0,?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, company.getUserId());
            ps.setString(2, company.getCompanyName());
            ps.setString(3, company.getCompanyArea());
            ps.setString(4, company.getCompanySize());
            ps.setString(5, company.getCompanyType());
            ps.setString(6, company.getCompanyBrief());
            ps.setInt(7, company.getCompanyState());
            ps.setInt(8, company.getCompanySort());
            ps.setString(9, company.getCompanyPic());
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public boolean updateAdmin(Company company) throws SQLException {
        String sql = "UPDATE tb_company SET user_id=?, company_name=?, company_area=?, company_size=?, company_type=?, "
                + "company_brief=?, company_state=?, company_sort=?, company_pic=? WHERE company_id=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, company.getUserId());
            ps.setString(2, company.getCompanyName());
            ps.setString(3, company.getCompanyArea());
            ps.setString(4, company.getCompanySize());
            ps.setString(5, company.getCompanyType());
            ps.setString(6, company.getCompanyBrief());
            ps.setInt(7, company.getCompanyState());
            ps.setInt(8, company.getCompanySort());
            ps.setString(9, company.getCompanyPic());
            ps.setInt(10, company.getCompanyId());
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    private static void appendWhere(StringBuilder sql, List<Object> params, String keyword, Integer state) {
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (company_name LIKE ? OR IFNULL(company_area,'') LIKE ? OR IFNULL(company_type,'') LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (state != null) {
            sql.append(" AND company_state = ?");
            params.add(state);
        }
    }

    private List<Company> queryList(String sql, List<Object> params) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Company> list = new ArrayList<>();
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapCompany(rs));
            }
            return list;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }
}
