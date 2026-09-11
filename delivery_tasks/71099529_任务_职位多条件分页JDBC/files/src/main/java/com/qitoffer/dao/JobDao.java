package com.qitoffer.dao;

import com.qitoffer.entity.Job;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * 职位 DAO - 多条件动态 SQL + LIMIT 分页 + 热门排序（按 job_viewnum）
 * 处理人：佟乐 | 任务：#71099529（多条件分页 JDBC）/#71098794
 *
 * 说明：薪资字段按「6k-8k」文本存储，SQL 里用 SUBSTRING_INDEX 取下限/上限后 CAST 成数字比较；
 * 前台只出 job_state=1，后台可传 state 过滤或看全部。
 */
public class JobDao {

    /** 薪资下限过滤：取下限数字（"6k-8k" → 6） */
    private static final String SALARY_MIN_SQL =
            "CAST(REPLACE(SUBSTRING_INDEX(j.job_salary, '-', 1), 'k', '') AS SIGNED) >= ?";
    /** 薪资上限过滤：取上限数字（"6k-8k" → 8） */
    private static final String SALARY_MAX_SQL =
            "CAST(REPLACE(SUBSTRING_INDEX(j.job_salary, '-', -1), 'k', '') AS SIGNED) <= ?";

    private static final String BASE_SELECT =
            "SELECT j.*, c.company_name, c.company_area, c.company_size, c.company_type "
            + "FROM tb_job j JOIN tb_company c ON j.company_id = c.company_id ";

    /**
     * 多条件分页查询。
     *
     * @param admin 后台视角传 true（可看下架职位），前台传 false（固定 job_state=1）
     * @param state 后台可选：null 全部 / 1 上架 / 0 下架；前台忽略
     */
    public List<Job> search(String keyword, String area, int salaryMin, int salaryMax,
                            boolean popular, int page, int pageSize, boolean admin, Integer state)
            throws SQLException {
        StringBuilder where = new StringBuilder();
        List<Object> params = new ArrayList<>();
        appendWhere(where, params, keyword, area, salaryMin, salaryMax, admin, state);

        String orderSql = popular ? " ORDER BY j.job_viewnum DESC, j.job_id DESC" : " ORDER BY j.job_id DESC";
        String sql = BASE_SELECT + where + orderSql
                + " LIMIT ? OFFSET ?";
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            bindParams(ps, params);
            rs = ps.executeQuery();
            return mapJobs(rs);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 同条件总数，配合分页 */
    public int count(String keyword, String area, int salaryMin, int salaryMax, boolean admin, Integer state)
            throws SQLException {
        StringBuilder where = new StringBuilder();
        List<Object> params = new ArrayList<>();
        appendWhere(where, params, keyword, area, salaryMin, salaryMax, admin, state);
        String sql = "SELECT COUNT(*) FROM tb_job j JOIN tb_company c ON j.company_id = c.company_id " + where;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            bindParams(ps, params);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 职位详情；incViewnum=true 时浏览量 +1（前台详情页调用） */
    public Job findById(int jobId, boolean incViewnum) throws SQLException {
        String sql = BASE_SELECT + "WHERE j.job_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            rs = ps.executeQuery();
            Job job = rs.next() ? mapJob(rs) : null;
            if (job != null && incViewnum) {
                addViewnum(conn, jobId);
                job.setJobViewnum(job.getJobViewnum() + 1);
            }
            return job;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private void addViewnum(Connection conn, int jobId) throws SQLException {
        try (PreparedStatement up = conn.prepareStatement(
                "UPDATE tb_job SET job_viewnum = job_viewnum + 1 WHERE job_id = ?")) {
            up.setInt(1, jobId);
            up.executeUpdate();
        }
    }

    private void appendWhere(StringBuilder where, List<Object> params,
                             String keyword, String area, int salaryMin, int salaryMax,
                             boolean admin, Integer state) {
        boolean first = true;
        if (!admin) {
            where.append(" WHERE j.job_state = ").append(1);
            first = false;
        } else if (state != null) {
            where.append(" WHERE j.job_state = ?");
            params.add(state);
            first = false;
        }
        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(first ? " WHERE " : " AND (");
            where.append(" j.job_name LIKE ? OR c.company_name LIKE ?");
            where.append(")");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            first = false;
        }
        if (area != null && !area.trim().isEmpty()) {
            where.append(first ? " WHERE " : " AND ").append("j.job_area LIKE ?");
            params.add("%" + area.trim() + "%");
            first = false;
        }
        if (salaryMin > 0) {
            where.append(first ? " WHERE " : " AND ").append(SALARY_MIN_SQL);
            params.add(salaryMin);
            first = false;
        }
        if (salaryMax > 0) {
            where.append(first ? " WHERE " : " AND ").append(SALARY_MAX_SQL);
            params.add(salaryMax);
        }
    }

    private void bindParams(PreparedStatement ps, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            ps.setObject(i + 1, params.get(i));
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
        job.setJobEndtime(rs.getString("job_endtime"));
        job.setJobState(rs.getInt("job_state"));
        job.setJobViewnum(rs.getInt("job_viewnum"));
        job.setCompanyName(rs.getString("company_name"));
        job.setCompanyArea(rs.getString("company_area"));
        job.setCompanySize(rs.getString("company_size"));
        job.setCompanyType(rs.getString("company_type"));
        return job;
    }
}
