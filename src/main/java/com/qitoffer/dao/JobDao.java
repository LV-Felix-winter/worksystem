package com.qitoffer.dao;

import com.qitoffer.entity.Job;
import com.qitoffer.util.DbUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 职位 DAO - 多条件筛选查询
 * 处理人：佟乐 | 任务：#71098794/#71099529
 */
public class JobDao {

    /**
     * 多条件筛选职位列表（#71099529 核心算法）
     * @param keyword 关键词（职位名/公司名/技能标签）
     * @param area 城市
     * @param salary 薪资范围
     * @param state 招聘状态（默认招聘中）
     * @param page 页码（从1开始）
     * @param pageSize 每页数量
     * @return 分页后的职位列表
     */
    public List<Job> findByConditions(String keyword, String area, String salary, int state, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT j.*, c.company_name FROM tb_job j "
                + "LEFT JOIN tb_company c ON j.company_id = c.company_id "
                + "WHERE j.job_state = ?");
        List<Object> params = new ArrayList<>();
        params.add(state);

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (j.job_name LIKE ? OR c.company_name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (area != null && !area.trim().isEmpty()) {
            sql.append(" AND j.job_area = ?");
            params.add(area.trim());
        }
        if (salary != null && !salary.trim().isEmpty()) {
            sql.append(" AND j.job_salary = ?");
            params.add(salary.trim());
        }
        sql.append(" ORDER BY j.job_id DESC");

        // 分页
        sql.append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add((page - 1) * pageSize);

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
            return mapJobs(rs);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /**
     * 获取符合条件的总记录数（用于分页）
     */
    public int countByConditions(String keyword, String area, String salary, int state) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM tb_job j LEFT JOIN tb_company c ON j.company_id = c.company_id WHERE j.job_state = ?");
        List<Object> params = new ArrayList<>();
        params.add(state);
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (j.job_name LIKE ? OR c.company_name LIKE ?)");
            String kw = "%" + keyword.trim() + "%";
            params.add(kw);
            params.add(kw);
        }
        if (area != null && !area.trim().isEmpty()) {
            sql.append(" AND j.job_area = ?");
            params.add(area.trim());
        }
        if (salary != null && !salary.trim().isEmpty()) {
            sql.append(" AND j.job_salary = ?");
            params.add(salary.trim());
        }

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
            if (rs.next()) return rs.getInt(1);
            return 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /**
     * 获取所有城市列表（去重）
     */
    public List<String> findDistinctAreas() throws SQLException {
        String sql = "SELECT DISTINCT job_area FROM tb_job WHERE job_state = 1 AND job_area IS NOT NULL ORDER BY job_area";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            List<String> areas = new ArrayList<>();
            while (rs.next()) {
                String area = rs.getString("job_area");
                if (area != null) areas.add(area);
            }
            return areas;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /**
     * 获取所有薪资范围列表（去重）
     */
    public List<String> findDistinctSalaries() throws SQLException {
        String sql = "SELECT DISTINCT job_salary FROM tb_job WHERE job_state = 1 AND job_salary IS NOT NULL ORDER BY job_salary";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            List<String> salaries = new ArrayList<>();
            while (rs.next()) {
                String s = rs.getString("job_salary");
                if (s != null) salaries.add(s);
            }
            return salaries;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public Job findById(int jobId) throws SQLException {
        String sql = "SELECT j.*, c.company_name FROM tb_job j LEFT JOIN tb_company c ON j.company_id = c.company_id WHERE j.job_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            rs = ps.executeQuery();
            if (rs.next()) return mapJob(rs);
            return null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private List<Job> mapJobs(ResultSet rs) throws SQLException {
        List<Job> list = new ArrayList<>();
        while (rs.next()) {
            list.add(mapJob(rs));
        }
        return list;
    }

    private Job mapJob(ResultSet rs) throws SQLException {
        Job job = new Job();
        job.setJobId(rs.getInt("job_id"));
        job.setCompanyId(rs.getInt("company_id"));
        job.setJobName(rs.getString("job_name"));
        job.setJobHiringnum(rs.getInt("job_hiringnum"));
        job.setJobSalary(rs.getString("job_salary"));
        job.setJobArea(rs.getString("job_area"));
        job.setJobDesc(rs.getString("job_desc"));
        job.setJobEndtime(rs.getDate("job_endtime"));
        job.setJobState(rs.getInt("job_state"));
        job.setJobViewnum(rs.getInt("job_viewnum"));
        job.setCompanyName(rs.getString("company_name"));
        return job;
    }
}
