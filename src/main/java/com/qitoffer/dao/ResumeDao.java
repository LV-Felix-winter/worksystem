package com.qitoffer.dao;

import com.qitoffer.entity.Resume;
import com.qitoffer.util.DbUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * 简历 DAO - 支持分页、完整度计算
 * 处理人：佟乐 | 任务：#71098792/#71099536
 */
public class ResumeDao {

    static {
        ensureExtraColumns();
    }

    private static void ensureExtraColumns() {
        Connection conn = null;
        Statement st = null;
        try {
            conn = DbUtil.getConnection();
            st = conn.createStatement();
            try {
                st.executeUpdate("ALTER TABLE tb_resume ADD COLUMN education TEXT");
            } catch (SQLException ignored) {
            }
            try {
                st.executeUpdate("ALTER TABLE tb_resume ADD COLUMN project_exp TEXT");
            } catch (SQLException ignored) {
            }
            for (String col : new String[] {"work_exp", "skills", "honors", "self_eval"}) {
                try {
                    st.executeUpdate("ALTER TABLE tb_resume ADD COLUMN " + col + " TEXT");
                } catch (SQLException ignored) {
                }
            }
            seedTemplateDemo(conn);
        } catch (SQLException ignored) {
        } finally {
            DbUtil.close(null, st, conn);
        }
    }

    /**
     * 分页查询简历列表
     */
    public List<Resume> findByApplicantId(int applicantId, int page, int pageSize) throws SQLException {
        String sql = "SELECT r.*, a.applicant_name, a.applicant_email "
                + "FROM tb_resume r LEFT JOIN tb_applicant a ON r.applicant_id = a.applicant_id "
                + "WHERE r.applicant_id = ? ORDER BY r.resume_id DESC LIMIT ? OFFSET ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            ps.setInt(2, pageSize);
            ps.setInt(3, (page - 1) * pageSize);
            rs = ps.executeQuery();
            return mapResumes(rs);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /**
     * 计算简历完整度 (#71099536 核心算法)
     * 5大模块：基本信息15%、教育经历20%、工作实习25%、项目经历25%、技能证书15%
     */
    public void recalculateCompleteness(int resumeId) throws SQLException {
        String sql = "SELECT * FROM tb_resume WHERE resume_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, resumeId);
            rs = ps.executeQuery();
            if (!rs.next()) return;

            int score = calcScore(rs);
            String updateSql = "UPDATE tb_resume SET completeness = ? WHERE resume_id = ?";
            ps = conn.prepareStatement(updateSql);
            ps.setInt(1, score);
            ps.setInt(2, resumeId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /**
     * 简历完整度加权计算 (#71099536 Task)
     * 模块化评分：各模块根据字段填写情况独立评分
     */
    private int calcScore(ResultSet rs) throws SQLException {
        // 模块1: 基本信息 (权重15%) - 姓名、电话、邮箱
        int basicScore = 0;
        if (rs.getString("realname") != null && !rs.getString("realname").isEmpty()) basicScore += 40;
        if (rs.getString("telephone") != null && !rs.getString("telephone").isEmpty()) basicScore += 30;
        if (rs.getString("email") != null && !rs.getString("email").isEmpty()) basicScore += 30;
        basicScore = Math.min(basicScore, 100);

        // 模块2: 教育经历 (权重20%)
        int eduScore = 0;
        try {
            String edu = rs.getString("education");
            if (edu != null && !edu.trim().isEmpty()) {
                eduScore = 100;
            }
        } catch (SQLException ignored) {
        }

        // 模块3: 工作/实习经历 (权重25%)
        int expScore = 0;
        String work = col(rs, "work_exp");
        String exp = rs.getString("job_experience");
        if (work != null && !work.isEmpty()) {
            expScore = 100;
        } else if (exp != null && !exp.isEmpty()) {
            if (exp.length() > 100) expScore = 100;
            else if (exp.length() > 50) expScore = 70;
            else expScore = 40;
        }

        // 模块4: 项目经历 (权重25%)
        int projScore = 0;
        try {
            String proj = rs.getString("project_exp");
            if (proj != null && !proj.trim().isEmpty()) {
                projScore = 100;
            } else if (rs.getString("job_intension") != null && !rs.getString("job_intension").isEmpty()) {
                projScore = 40;
            }
        } catch (SQLException ignored) {
            projScore = rs.getString("job_intension") != null && !rs.getString("job_intension").isEmpty() ? 80 : 20;
        }

        // 模块5: 技能证书 (权重15%)
        int skillScore = 0;
        if (filled(col(rs, "skills"))) skillScore += 40;
        if (filled(col(rs, "honors"))) skillScore += 20;
        if (filled(col(rs, "self_eval"))) skillScore += 20;
        if (rs.getString("head_shot") != null && !rs.getString("head_shot").isEmpty()) skillScore += 20;
        skillScore = Math.min(skillScore, 100);

        // 加权平均 (Task #71099536)
        return (int) Math.round(
                basicScore * 0.15 + eduScore * 0.20 + expScore * 0.25
                        + projScore * 0.25 + skillScore * 0.15
        );
    }

    public Resume findById(int resumeId) throws SQLException {
        String sql = "SELECT r.*, a.applicant_name, a.applicant_email FROM tb_resume r LEFT JOIN tb_applicant a ON r.applicant_id = a.applicant_id WHERE r.resume_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, resumeId);
            rs = ps.executeQuery();
            if (rs.next()) return mapResume(rs);
            return null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public Resume findByApplicantId(int applicantId) throws SQLException {
        String sql = "SELECT r.*, a.applicant_name, a.applicant_email FROM tb_resume r LEFT JOIN tb_applicant a ON r.applicant_id = a.applicant_id WHERE r.applicant_id = ? ORDER BY r.resume_id DESC LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            if (rs.next()) return mapResume(rs);
            return null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private List<Resume> mapResumes(ResultSet rs) throws SQLException {
        List<Resume> list = new ArrayList<>();
        while (rs.next()) list.add(mapResume(rs));
        return list;
    }

    private Resume mapResume(ResultSet rs) throws SQLException {
        Resume r = new Resume();
        r.setResumeId(rs.getInt("resume_id"));
        r.setApplicantId(rs.getInt("applicant_id"));
        r.setRealname(rs.getString("realname"));
        r.setGender(rs.getString("gender"));
        r.setBirthday(rs.getDate("birthday"));
        r.setCurrentLoc(rs.getString("current_loc"));
        r.setResidentLoc(rs.getString("resident_loc"));
        r.setTelephone(rs.getString("telephone"));
        r.setEmail(rs.getString("email"));
        r.setJobIntension(rs.getString("job_intension"));
        r.setJobExperience(rs.getString("job_experience"));
        try {
            r.setEducation(rs.getString("education"));
            r.setProjectExp(rs.getString("project_exp"));
            r.setWorkExp(col(rs, "work_exp"));
            r.setSkills(col(rs, "skills"));
            r.setHonors(col(rs, "honors"));
            r.setSelfEval(col(rs, "self_eval"));
        } catch (SQLException ignored) {
        }
        r.setHeadShot(rs.getString("head_shot"));
        r.setAttachment(rs.getString("attachment"));
        r.setCompleteness(rs.getInt("completeness"));
        r.setApplicantName(rs.getString("applicant_name"));
        r.setApplicantEmail(rs.getString("applicant_email"));
        return r;
    }
/**
     * 后台简历分页列表 (#71098792 实现)：全库简历，关键词匹配姓名/手机号/意向岗位
     */
    public List<Resume> listPage(String keyword, int page, int pageSize) throws SQLException {
        StringBuilder where = new StringBuilder();
        List<String> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(" WHERE r.realname LIKE ? OR a.applicant_name LIKE ? OR a.applicant_phone LIKE ?"
                    + " OR r.telephone LIKE ? OR r.job_intension LIKE ?");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        String sql = "SELECT r.*, a.applicant_name, a.applicant_email FROM tb_resume r "
                + "LEFT JOIN tb_applicant a ON r.applicant_id = a.applicant_id"
                + where
                + " ORDER BY r.resume_id DESC LIMIT " + pageSize
                + " OFFSET " + Math.max(0, (page - 1) * pageSize);
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            return mapResumes(rs);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 后台简历总数，配合 listPage 分页 */
    public int countPage(String keyword) throws SQLException {
        StringBuilder where = new StringBuilder();
        List<String> params = new ArrayList<>();
        if (keyword != null && !keyword.trim().isEmpty()) {
            where.append(" WHERE r.realname LIKE ? OR a.applicant_name LIKE ? OR a.applicant_phone LIKE ?"
                    + " OR r.telephone LIKE ? OR r.job_intension LIKE ?");
            String like = "%" + keyword.trim() + "%";
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
            params.add(like);
        }
        String sql = "SELECT COUNT(*) FROM tb_resume r LEFT JOIN tb_applicant a "
                + "ON r.applicant_id = a.applicant_id" + where;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            for (int i = 0; i < params.size(); i++) {
                ps.setString(i + 1, params.get(i));
            }
            rs = ps.executeQuery();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    /** 求职者保存简历字段 (#71099535：缺字段完整度下降，保存后重算) */
    public void updateFields(int resumeId, String realname, String gender, String birthday, String currentLoc,
                            String residentLoc, String telephone, String email,
                            String jobIntension, String jobExperience) throws SQLException {
        String sql = "UPDATE tb_resume SET realname = ?, gender = ?, birthday = ?, current_loc = ?, resident_loc = ?, "
                + "telephone = ?, email = ?, job_intension = ?, job_experience = ? WHERE resume_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            setStr(ps, 1, realname);
            setStr(ps, 2, gender);
            if (birthday == null || birthday.trim().isEmpty()) {
                ps.setNull(3, Types.DATE);
            } else {
                ps.setString(3, birthday.trim());
            }
            setStr(ps, 4, currentLoc);
            setStr(ps, 5, residentLoc);
            setStr(ps, 6, telephone);
            setStr(ps, 7, email);
            setStr(ps, 8, jobIntension);
            setStr(ps, 9, jobExperience);
            ps.setInt(10, resumeId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** 附件路径落库 (#71099536 attachment 字段) */
    public void saveAttachment(int resumeId, String path) throws SQLException {
        updatePath(resumeId, "attachment", path);
    }

    public void saveHeadShot(int resumeId, String path) throws SQLException {
        updatePath(resumeId, "head_shot", path);
    }

    public void saveEducation(int resumeId, String education) throws SQLException {
        updatePath(resumeId, "education", education);
    }

    public void saveProjectExp(int resumeId, String projectExp) throws SQLException {
        updatePath(resumeId, "project_exp", projectExp);
    }

    public void saveWorkExp(int resumeId, String workExp) throws SQLException {
        updatePath(resumeId, "work_exp", workExp);
    }

    public void saveJobExperience(int resumeId, String jobExperience) throws SQLException {
        updatePath(resumeId, "job_experience", jobExperience);
    }

    public void saveSkills(int resumeId, String skills) throws SQLException {
        updatePath(resumeId, "skills", skills);
    }

    public void saveHonors(int resumeId, String honors) throws SQLException {
        updatePath(resumeId, "honors", honors);
    }

    public void saveSelfEval(int resumeId, String selfEval) throws SQLException {
        updatePath(resumeId, "self_eval", selfEval);
    }

    private void updatePath(int resumeId, String column, String path) throws SQLException {
        String sql = "UPDATE tb_resume SET " + column + " = ? WHERE resume_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, path);
            ps.setInt(2, resumeId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    /** 与 calcScore 相同的五模块分数，供简历页展示 */
    public int[] moduleScores(Resume resume) {
        if (resume == null) {
            return new int[] {0, 0, 0, 0, 30};
        }
        int basicScore = 0;
        if (filled(resume.getRealname())) {
            basicScore += 40;
        }
        if (filled(resume.getTelephone())) {
            basicScore += 30;
        }
        if (filled(resume.getEmail())) {
            basicScore += 30;
        }
        int eduScore = filled(resume.getEducation()) ? 100 : 0;
        int expScore = 0;
        if (filled(resume.getWorkExp())) {
            expScore = 100;
        } else {
            String exp = resume.getJobExperience();
            if (exp != null && !exp.isEmpty()) {
                if (exp.length() > 100) {
                    expScore = 100;
                } else if (exp.length() > 50) {
                    expScore = 70;
                } else {
                    expScore = 40;
                }
            }
        }
        int projScore = filled(resume.getProjectExp()) ? 100 : (filled(resume.getJobIntension()) ? 40 : 0);
        int skillScore = 0;
        if (filled(resume.getSkills())) {
            skillScore += 40;
        }
        if (filled(resume.getHonors())) {
            skillScore += 20;
        }
        if (filled(resume.getSelfEval())) {
            skillScore += 20;
        }
        if (filled(resume.getHeadShot())) {
            skillScore += 20;
        }
        return new int[] {Math.min(basicScore, 100), eduScore, expScore, projScore, Math.min(skillScore, 100)};
    }

    /** 求职者没有简历则建一条空白简历，返回 id */
    public int ensureForApplicant(int applicantId) throws SQLException {
        String check = "SELECT resume_id FROM tb_resume WHERE applicant_id = ? ORDER BY resume_id LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(check);
            ps.setInt(1, applicantId);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
            rs.close();
            ps.close();
            ps = conn.prepareStatement(
                    "INSERT INTO tb_resume (applicant_id, completeness) VALUES (?, 0)",
                    Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, applicantId);
            ps.executeUpdate();
            rs = ps.getGeneratedKeys();
            return rs.next() ? rs.getInt(1) : 0;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private static void seedTemplateDemo(Connection conn) {
        PreparedStatement check = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            check = conn.prepareStatement("SELECT resume_id, work_exp FROM tb_resume WHERE resume_id = 1");
            rs = check.executeQuery();
            if (!rs.next() || (rs.getString("work_exp") != null && !rs.getString("work_exp").isBlank())) {
                return;
            }
            ps = conn.prepareStatement(
                    "UPDATE tb_resume SET education = ?, work_exp = ?, skills = ?, honors = ?, self_eval = ? WHERE resume_id = 1");
            ps.setString(1, "青岛大学||软件工程||本科||2020.09-2024.06||GPA 3.66/4（专业前5%）||Java程序设计、数据结构、数据库原理、计算机网络、软件工程、Web开发、操作系统、编译原理"
                    + "\n四川大学||软件工程||硕士||2024.09-2027.06||||高级软件工程、分布式系统、机器学习基础");
            ps.setString(2, "青软实训||Java Web 实习生||2025.03-至今||参与锐聘招聘网站开发，负责职位检索与投递模块;;使用 JSP/Servlet/JDBC 完成业务接口与页面联调;;配合企业端完成应聘状态流转与消息通知"
                    + "\n校园工作室||后端开发||2024.03-2024.12||负责课程设计后台接口与数据库表设计;;协助联调登录、简历与收藏功能");
            ps.setString(3, "大学英语六级，能阅读英文技术文档并进行日常交流。||计算机二级，熟悉 Windows / IDEA，掌握 Java、MySQL、JSP/Servlet。||有课程设计与项目协作经验，能配合前后端联调。||Java::熟练;;MySQL::良好;;英语::良好");
            ps.setString(4, "通过大学英语四级，能阅读英文技术文档\n通过全国计算机二级考试，熟练使用办公与开发工具");
            ps.setString(5, "学习主动、做事认真，能独立完成课程项目并配合团队联调。遇到问题愿意拆解排查，也愿意补齐短板。希望在实习中把工程实践做扎实。");
            ps.executeUpdate();
        } catch (SQLException ignored) {
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException ignored) {}
            try { if (ps != null) ps.close(); } catch (SQLException ignored) {}
            try { if (check != null) check.close(); } catch (SQLException ignored) {}
        }
    }

    private static String col(ResultSet rs, String name) {
        try {
            return rs.getString(name);
        } catch (SQLException e) {
            return null;
        }
    }

    private static boolean filled(String value) {
        return value != null && !value.isEmpty();
    }

    private void setStr(PreparedStatement ps, int idx, String value) throws SQLException {
        if (value == null || value.trim().isEmpty()) {
            ps.setNull(idx, Types.VARCHAR);
        } else {
            ps.setString(idx, value.trim());
        }
    }
}
