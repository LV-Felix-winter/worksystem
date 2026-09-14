package com.qitoffer.dao;

import com.qitoffer.entity.Talk;
import com.qitoffer.entity.TalkMsg;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class TalkDao {

    private static final String TALK_SELECT =
            "SELECT t.*, j.job_name, j.job_salary, j.job_area, c.company_name, a.applicant_name, "
                    + "(SELECT m.content FROM tb_talk_msg m WHERE m.talk_id = t.talk_id ORDER BY m.msg_id DESC LIMIT 1) last_content "
                    + "FROM tb_talk t "
                    + "JOIN tb_job j ON t.job_id = j.job_id "
                    + "JOIN tb_company c ON t.company_id = c.company_id "
                    + "JOIN tb_applicant a ON t.applicant_id = a.applicant_id ";

    public Talk findOrCreate(int jobId, int companyId, int applicantId) throws SQLException {
        Talk exist = findByJobAndApplicant(jobId, applicantId);
        if (exist != null) {
            return exist;
        }
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet keys = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(
                    "INSERT INTO tb_talk (job_id, company_id, applicant_id, last_time) VALUES (?,?,?,NOW())",
                    Statement.RETURN_GENERATED_KEYS);
            ps.setInt(1, jobId);
            ps.setInt(2, companyId);
            ps.setInt(3, applicantId);
            ps.executeUpdate();
            keys = ps.getGeneratedKeys();
            int talkId = keys.next() ? keys.getInt(1) : 0;
            Talk created = findById(talkId);
            if (created != null) {
                seedWelcome(created);
            }
            return created;
        } finally {
            DbUtil.close(keys, ps, conn);
        }
    }

    public Talk findById(int talkId) throws SQLException {
        return one(TALK_SELECT + "WHERE t.talk_id = ?", talkId);
    }

    public Talk findByJobAndApplicant(int jobId, int applicantId) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(TALK_SELECT + "WHERE t.job_id = ? AND t.applicant_id = ?");
            ps.setInt(1, jobId);
            ps.setInt(2, applicantId);
            rs = ps.executeQuery();
            return rs.next() ? mapTalk(rs) : null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public List<Talk> listByApplicant(int applicantId) throws SQLException {
        return list(TALK_SELECT + "WHERE t.applicant_id = ? ORDER BY t.last_time DESC, t.talk_id DESC", applicantId);
    }

    public List<Talk> listByCompany(int companyId) throws SQLException {
        return list(TALK_SELECT + "WHERE t.company_id = ? ORDER BY t.last_time DESC, t.talk_id DESC", companyId);
    }

    public List<TalkMsg> listMessages(int talkId) throws SQLException {
        String sql = "SELECT * FROM tb_talk_msg WHERE talk_id = ? ORDER BY msg_id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<TalkMsg> list = new ArrayList<>();
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, talkId);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapMsg(rs));
            }
            return list;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public void addMessage(int talkId, String senderType, String content) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        PreparedStatement up = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(
                    "INSERT INTO tb_talk_msg (talk_id, sender_type, content, create_time) VALUES (?,?,?,NOW())");
            ps.setInt(1, talkId);
            ps.setString(2, senderType);
            ps.setString(3, content);
            ps.executeUpdate();
            up = conn.prepareStatement("UPDATE tb_talk SET last_time = NOW() WHERE talk_id = ?");
            up.setInt(1, talkId);
            up.executeUpdate();
        } finally {
            DbUtil.close(null, up, null);
            DbUtil.close(null, ps, conn);
        }
    }

    public boolean hasMessages(int talkId) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement("SELECT 1 FROM tb_talk_msg WHERE talk_id = ? LIMIT 1");
            ps.setInt(1, talkId);
            rs = ps.executeQuery();
            return rs.next();
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public void seedWelcome(Talk talk) throws SQLException {
        if (talk == null || hasMessages(talk.getTalkId())) {
            return;
        }
        String company = talk.getCompanyName() == null ? "招聘同事" : talk.getCompanyName();
        String job = talk.getJobName() == null ? "该职位" : talk.getJobName();
        addMessage(talk.getTalkId(), "company",
                "您好，我是" + company + "招聘同事。看到您对「" + job + "」感兴趣，方便简单介绍下近期项目和可到岗时间吗？");
    }

    private Talk one(String sql, int id) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            return rs.next() ? mapTalk(rs) : null;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private List<Talk> list(String sql, int id) throws SQLException {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Talk> list = new ArrayList<>();
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapTalk(rs));
            }
            return list;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    private Talk mapTalk(ResultSet rs) throws SQLException {
        Talk t = new Talk();
        t.setTalkId(rs.getInt("talk_id"));
        t.setJobId(rs.getInt("job_id"));
        t.setCompanyId(rs.getInt("company_id"));
        t.setApplicantId(rs.getInt("applicant_id"));
        t.setLastTime(rs.getTimestamp("last_time"));
        t.setJobName(rs.getString("job_name"));
        t.setJobSalary(rs.getString("job_salary"));
        t.setJobArea(rs.getString("job_area"));
        t.setCompanyName(rs.getString("company_name"));
        t.setApplicantName(rs.getString("applicant_name"));
        t.setLastContent(rs.getString("last_content"));
        return t;
    }

    private TalkMsg mapMsg(ResultSet rs) throws SQLException {
        TalkMsg m = new TalkMsg();
        m.setMsgId(rs.getInt("msg_id"));
        m.setTalkId(rs.getInt("talk_id"));
        m.setSenderType(rs.getString("sender_type"));
        m.setContent(rs.getString("content"));
        m.setCreateTime(rs.getTimestamp("create_time"));
        return m;
    }
}
