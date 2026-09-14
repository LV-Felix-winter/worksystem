package com.qitoffer.dao;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.Apply;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

/**
 * 投递 DAO - 我的申请列表 / 企业应聘信息 / 状态流转（校验职位归属）
 * 处理人：佟乐 | 任务：#71099538/#71099539
 */
public class ApplyDao {

    /** 求职者发起投递：待处理（Dict.APPLY_PENDING） */
    public void add(int jobId, int resumeId) throws SQLException {
        String sql = "INSERT INTO tb_apply (job_id, resume_id, apply_date, apply_state) VALUES (?, ?, NOW(), ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            ps.setInt(2, resumeId);
            ps.setInt(3, Dict.APPLY_PENDING);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** 同一简历对同一职位不重复投递 */
    public boolean exists(int jobId, int resumeId) throws SQLException {
        String sql = "SELECT 1 FROM tb_apply WHERE job_id = ? AND resume_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, jobId);
            ps.setInt(2, resumeId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 求职者「我的申请」：按投递时间倒序，带职位/企业信息 */
    public List<Apply> listByApplicant(int applicantId) throws SQLException {
        String sql = "SELECT a.*, j.job_name, j.job_salary, j.job_area, c.company_name "
                + "FROM tb_apply a "
                + "JOIN tb_job j ON a.job_id = j.job_id "
                + "JOIN tb_company c ON j.company_id = c.company_id "
                + "JOIN tb_resume r ON a.resume_id = r.resume_id "
                + "WHERE r.applicant_id = ? ORDER BY a.apply_date DESC, a.apply_id DESC";
        return queryList(sql, new Object[]{applicantId});
    }

    /** 企业「应聘信息」：只出本企业职位收到的投递，附简历摘要 */
    public List<Apply> listByCompany(int companyId) throws SQLException {
        new ResumeDao();
        DemoSeed.ensure();
        String sql = "SELECT a.*, j.job_name, j.job_salary, j.job_area, c.company_name, "
                + "r.realname AS resume_realname, r.gender AS resume_gender, "
                + "r.telephone AS resume_telephone, r.email AS resume_email, "
                + "r.job_intension AS resume_job_intension, r.job_experience AS resume_job_experience, "
                + "r.attachment AS resume_attachment, r.completeness AS resume_completeness, "
                + "r.head_shot AS resume_head_shot, r.birthday AS resume_birthday, "
                + "r.education AS resume_education, r.current_loc AS resume_current_loc "
                + "FROM tb_apply a "
                + "JOIN tb_job j ON a.job_id = j.job_id "
                + "JOIN tb_company c ON j.company_id = c.company_id "
                + "JOIN tb_resume r ON a.resume_id = r.resume_id "
                + "WHERE c.company_id = ? ORDER BY a.apply_date DESC, a.apply_id DESC";
        return queryList(sql, new Object[]{companyId});
    }

    /**
     * 企业更新投递状态（#71099539 核心接口）：
     * 同语句 JOIN 校验职位归属，改 0 行说明不是本企业的投递，越权失败。
     */
    public boolean updateStateOwned(int applyId, int newState, int companyId) throws SQLException {
        String sql = "UPDATE tb_apply a JOIN tb_job j ON a.job_id = j.job_id "
                + "SET a.apply_state = ? WHERE a.apply_id = ? AND j.company_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, newState);
            ps.setInt(2, applyId);
            ps.setInt(3, companyId);
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** 企业打开详情：待处理自动流转成已查看（仅 1 → 2，不覆盖其它状态） */
    public boolean markViewedOwned(int applyId, int companyId) throws SQLException {
        String sql = "UPDATE tb_apply a JOIN tb_job j ON a.job_id = j.job_id "
                + "SET a.apply_state = ? WHERE a.apply_id = ? AND a.apply_state = ? AND j.company_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Dict.APPLY_VIEWED);
            ps.setInt(2, applyId);
            ps.setInt(3, Dict.APPLY_PENDING);
            ps.setInt(4, companyId);
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** 校验简历归求职者本人（投递前检查） */
    public boolean ownsResume(int resumeId, int applicantId) throws SQLException {
        String sql = "SELECT 1 FROM tb_resume WHERE resume_id = ? AND applicant_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, resumeId);
            ps.setInt(2, applicantId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 该投递是否属于指定企业（/apply/detail 越权校验用） */
    public boolean ownedByCompany(int applyId, int companyId) throws SQLException {
        String sql = "SELECT 1 FROM tb_apply a JOIN tb_job j ON a.job_id = j.job_id "
                + "WHERE a.apply_id = ? AND j.company_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applyId);
            ps.setInt(2, companyId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 投递对应的职位名（站内消息文案用） */
    public String jobNameOf(int applyId) throws SQLException {
        String sql = "SELECT j.job_name FROM tb_apply a JOIN tb_job j ON a.job_id = j.job_id WHERE a.apply_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applyId);
            rs = ps.executeQuery();
            return rs.next() ? rs.getString(1) : "未知职位";
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 该投递对应的求职者 id（状态更新后写站内消息用） */
    public int applicantOfApply(int applyId) throws SQLException {
        String sql = "SELECT r.applicant_id FROM tb_apply a JOIN tb_resume r ON a.resume_id = r.resume_id WHERE a.apply_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applyId);
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 给求职者发站内消息（tb_message，未读） */
    public void notifyApplicant(int applicantId, String title, String content) throws SQLException {
        String sql = "INSERT INTO tb_message (receiver_type, receiver_id, title, content, is_read, create_time) "
                + "VALUES (?, ?, ?, ?, ?, NOW())";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, Dict.RECEIVER_APPLICANT);
            ps.setInt(2, applicantId);
            ps.setString(3, title);
            ps.setString(4, content);
            ps.setInt(5, Dict.MSG_UNREAD);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    public List<Apply> listPageAdmin(String keyword, Integer state, int page, int pageSize) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT a.*, j.job_name, j.job_salary, j.job_area, c.company_name, "
                        + "r.realname AS resume_realname, r.gender AS resume_gender, "
                        + "r.telephone AS resume_telephone, r.email AS resume_email, "
                        + "r.job_intension AS resume_job_intension, r.job_experience AS resume_job_experience, "
                        + "r.attachment AS resume_attachment, r.completeness AS resume_completeness, "
                        + "r.head_shot AS resume_head_shot, r.birthday AS resume_birthday, "
                        + "r.education AS resume_education, r.current_loc AS resume_current_loc "
                        + "FROM tb_apply a "
                        + "JOIN tb_job j ON a.job_id = j.job_id "
                        + "JOIN tb_company c ON j.company_id = c.company_id "
                        + "JOIN tb_resume r ON a.resume_id = r.resume_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendAdminWhere(sql, params, keyword, state);
        sql.append(" ORDER BY a.apply_date DESC, a.apply_id DESC LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));
        return queryList(sql.toString(), params.toArray());
    }

    public int countPageAdmin(String keyword, Integer state) throws SQLException {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM tb_apply a "
                        + "JOIN tb_job j ON a.job_id = j.job_id "
                        + "JOIN tb_company c ON j.company_id = c.company_id "
                        + "JOIN tb_resume r ON a.resume_id = r.resume_id WHERE 1=1");
        List<Object> params = new ArrayList<>();
        appendAdminWhere(sql, params, keyword, state);
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

    public boolean updateStateAdmin(int applyId, int newState) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement("UPDATE tb_apply SET apply_state = ? WHERE apply_id = ?");
            ps.setInt(1, newState);
            ps.setInt(2, applyId);
            return ps.executeUpdate() > 0;
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    private static void appendAdminWhere(StringBuilder sql, List<Object> params, String keyword, Integer state) {
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (j.job_name LIKE ? OR c.company_name LIKE ? OR IFNULL(r.realname,'') LIKE ?)");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
        }
        if (state != null) {
            sql.append(" AND a.apply_state = ?");
            params.add(state);
        }
    }

    private List<Apply> queryList(String sql, Object[] params) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.length; i++) {
                ps.setObject(i + 1, params[i]);
            }
            rs = ps.executeQuery();
            List<Apply> list = new ArrayList<>();
            while (rs.next()) {
                Apply a = new Apply();
                a.setApplyId(rs.getInt("apply_id"));
                a.setJobId(rs.getInt("job_id"));
                a.setResumeId(rs.getInt("resume_id"));
                java.sql.Timestamp ts = rs.getTimestamp("apply_date");
                a.setApplyDate(ts == null ? null : new java.util.Date(ts.getTime()));
                a.setApplyState(rs.getInt("apply_state"));
                a.setJobName(rs.getString("job_name"));
                a.setCompanyName(rs.getString("company_name"));
                a.setJobSalary(rs.getString("job_salary"));
                a.setJobArea(rs.getString("job_area"));
                if (hasColumn(rs, "resume_realname")) {
                    a.setResumeRealname(rs.getString("resume_realname"));
                    a.setResumeGender(rs.getString("resume_gender"));
                    a.setResumeTelephone(rs.getString("resume_telephone"));
                    a.setResumeEmail(rs.getString("resume_email"));
                    a.setResumeJobIntension(rs.getString("resume_job_intension"));
                    a.setResumeJobExperience(rs.getString("resume_job_experience"));
                    a.setResumeAttachment(rs.getString("resume_attachment"));
                    a.setResumeCompleteness(rs.getInt("resume_completeness"));
                    a.setResumeHeadShot(rs.getString("resume_head_shot"));
                    java.sql.Date birthday = rs.getDate("resume_birthday");
                    a.setResumeBirthday(birthday);
                    a.setResumeEducation(rs.getString("resume_education"));
                    a.setResumeCurrentLoc(rs.getString("resume_current_loc"));
                }
                list.add(a);
            }
            return list;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private static boolean hasColumn(ResultSet rs, String name) throws SQLException {
        java.sql.ResultSetMetaData md = rs.getMetaData();
        for (int i = 1; i <= md.getColumnCount(); i++) {
            if (name.equalsIgnoreCase(md.getColumnLabel(i))) {
                return true;
            }
        }
        return false;
    }
}
