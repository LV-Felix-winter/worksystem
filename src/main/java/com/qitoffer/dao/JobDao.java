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

    static {
        ensureImageColumns();
        DemoSeed.ensure();
    }

    /** 薪资下限过滤：取下限数字（"6k-8k" → 6） */
    private static final String SALARY_MIN_SQL =
            "CAST(REPLACE(SUBSTRING_INDEX(j.job_salary, '-', 1), 'k', '') AS SIGNED) >= ?";
    /** 薪资上限过滤：取上限数字（"6k-8k" → 8） */
    private static final String SALARY_MAX_SQL =
            "CAST(REPLACE(SUBSTRING_INDEX(j.job_salary, '-', -1), 'k', '') AS SIGNED) <= ?";

    private static final String BASE_SELECT =
            "SELECT j.*, c.company_name, c.company_area, c.company_size, c.company_type, "
            + "c.company_brief, c.company_pic "
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

    /** 本企业职位列表（企业工作台） */
    public List<Job> listByCompany(int companyId) throws SQLException {
        return listByCompany(companyId, null, null, 1, 500);
    }

    public List<Job> listByCompany(int companyId, String keyword, Integer state, int page, int pageSize)
            throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT j.*, c.company_name, c.company_area, c.company_size, c.company_type, "
                        + "c.company_brief, c.company_pic, "
                        + "(SELECT COUNT(*) FROM tb_apply a WHERE a.job_id = j.job_id) AS apply_count "
                        + "FROM tb_job j JOIN tb_company c ON j.company_id = c.company_id");
        List<Object> params = new ArrayList<>();
        appendCompanyWhere(sql, params, companyId, keyword, state);
        sql.append(" ORDER BY j.job_id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            bindParams(ps, params);
            rs = ps.executeQuery();
            List<Job> list = new ArrayList<>();
            while (rs.next()) {
                Job job = mapJob(rs);
                job.setApplyCount(rs.getInt("apply_count"));
                list.add(job);
            }
            return list;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public int countByCompany(int companyId, String keyword, Integer state) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM tb_job j");
        List<Object> params = new ArrayList<>();
        appendCompanyWhere(sql, params, companyId, keyword, state);
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql.toString());
            bindParams(ps, params);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public void insert(Job job) throws SQLException {
        String sql = "INSERT INTO tb_job (company_id, job_name, job_hiringnum, job_salary, job_area, job_desc, job_endtime, job_state, job_cover, job_thumb) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            bindJobWrite(ps, job, false);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    public boolean updateOwned(Job job) throws SQLException {
        String sql = "UPDATE tb_job SET job_name=?, job_hiringnum=?, job_salary=?, job_area=?, job_desc=?, job_endtime=?, job_state=?, job_cover=?, job_thumb=? "
                + "WHERE job_id=? AND company_id=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            bindJobWrite(ps, job, true);
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    public boolean deleteOwned(int jobId, int companyId) throws SQLException {
        Connection conn = null;
        PreparedStatement countPs = null;
        PreparedStatement delJob = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            countPs = conn.prepareStatement("SELECT COUNT(*) FROM tb_apply WHERE job_id=?");
            countPs.setInt(1, jobId);
            rs = countPs.executeQuery();
            int applies = rs.next() ? rs.getInt(1) : 0;
            if (applies > 0) {
                return false;
            }
            delJob = conn.prepareStatement("DELETE FROM tb_job WHERE job_id=? AND company_id=?");
            delJob.setInt(1, jobId);
            delJob.setInt(2, companyId);
            return delJob.executeUpdate() > 0;
        } finally {
            DbUtil.close(rs, countPs, null);
            DbUtil.close(null, delJob, conn);
        }
    }

    public boolean updateStateAdmin(int jobId, int state) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement("UPDATE tb_job SET job_state=? WHERE job_id=?");
            ps.setInt(1, state);
            ps.setInt(2, jobId);
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    private void appendCompanyWhere(StringBuilder sql, List<Object> params,
                                    int companyId, String keyword, Integer state) {
        sql.append(" WHERE j.company_id = ?");
        params.add(companyId);
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND j.job_name LIKE ?");
            params.add("%" + keyword.trim() + "%");
        }
        if (state != null) {
            sql.append(" AND j.job_state = ?");
            params.add(state);
        }
    }

    private void bindJobWrite(PreparedStatement ps, Job job, boolean update) throws SQLException {
        if (update) {
            ps.setString(1, job.getJobName());
            ps.setInt(2, job.getJobHiringnum());
            ps.setString(3, job.getJobSalary());
            ps.setString(4, job.getJobArea());
            ps.setString(5, job.getJobDesc());
            ps.setString(6, emptyToNull(job.getJobEndtime()));
            ps.setInt(7, job.getJobState());
            ps.setString(8, emptyToNull(job.getJobCover()));
            ps.setString(9, emptyToNull(job.getJobThumb()));
            ps.setInt(10, job.getJobId());
            ps.setInt(11, job.getCompanyId());
        } else {
            ps.setInt(1, job.getCompanyId());
            ps.setString(2, job.getJobName());
            ps.setInt(3, job.getJobHiringnum());
            ps.setString(4, job.getJobSalary());
            ps.setString(5, job.getJobArea());
            ps.setString(6, job.getJobDesc());
            ps.setString(7, emptyToNull(job.getJobEndtime()));
            ps.setInt(8, job.getJobState());
            ps.setString(9, emptyToNull(job.getJobCover()));
            ps.setString(10, emptyToNull(job.getJobThumb()));
        }
    }

    private static String emptyToNull(String value) {
        return value == null || value.trim().isEmpty() ? null : value.trim();
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
            where.append(first ? " WHERE (" : " AND (");
            where.append("j.job_name LIKE ? OR c.company_name LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            first = false;
        }
        if (area != null && !area.trim().isEmpty()) {
            where.append(first ? " WHERE " : " AND ").append("j.job_area LIKE ?");
            params.add("%" + areaSearchToken(area) + "%");
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
        job.setCompanyBrief(rs.getString("company_brief"));
        job.setCompanyPic(rs.getString("company_pic"));
        job.setJobCover(col(rs, "job_cover"));
        job.setJobThumb(col(rs, "job_thumb"));
        return job;
    }

    private static String col(ResultSet rs, String name) {
        try {
            return rs.getString(name);
        } catch (SQLException e) {
            return null;
        }
    }

    private static void ensureImageColumns() {
        Connection conn = null;
        java.sql.Statement st = null;
        try {
            conn = DbUtil.getConnection();
            st = conn.createStatement();
            try {
                st.executeUpdate("ALTER TABLE tb_job ADD COLUMN job_cover VARCHAR(255) DEFAULT NULL");
            } catch (SQLException ignored) {
            }
            try {
                st.executeUpdate("ALTER TABLE tb_job ADD COLUMN job_thumb VARCHAR(255) DEFAULT NULL");
            } catch (SQLException ignored) {
            }
            st.executeUpdate("UPDATE tb_job SET job_cover = CONCAT('/images/banner-', 1 + MOD(company_id - 1, 9), '.jpg') "
                    + "WHERE (job_cover IS NULL OR job_cover = '' OR job_cover LIKE '/images/%') "
                    + "AND (job_cover IS NULL OR job_cover NOT LIKE '/upload/%')");
            st.executeUpdate("UPDATE tb_job SET job_thumb = CONCAT('/images/job-thumb-', 1 + MOD(company_id - 1, 9), '.jpg') "
                    + "WHERE (job_thumb IS NULL OR job_thumb = '' OR job_thumb LIKE '/images/%') "
                    + "AND (job_thumb IS NULL OR job_thumb NOT LIKE '/upload/%')");
        } catch (SQLException ignored) {
        } finally {
            DbUtil.close(null, st, conn);
        }
    }

    /** 三级地区取市名匹配库里的简写（如 山东省/青岛市/崂山区 → 青岛）。 */
    static String areaSearchToken(String area) {
        String raw = area.trim();
        if (!raw.contains("/")) {
            return raw;
        }
        String[] parts = raw.split("/");
        for (int i = 0; i < parts.length; i++) {
            parts[i] = parts[i].trim();
        }
        String city = parts.length > 1 ? parts[1] : parts[0];
        if ("市辖区".equals(city) || "县".equals(city) || "离岛".equals(city) || "澳门半岛".equals(city)) {
            return parts[parts.length - 1];
        }
        return city.replaceAll("(市|州|地区|盟)$", "");
    }
}
