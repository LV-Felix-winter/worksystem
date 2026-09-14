package com.qitoffer.dao;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.Message;
import com.qitoffer.util.DbUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class MessageDao {

    public void insert(Message msg) throws SQLException {
        String sql = "INSERT INTO tb_message (receiver_type, receiver_id, title, content, is_read, create_time) VALUES (?,?,?,?,?,?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, msg.getReceiverType());
            ps.setInt(2, msg.getReceiverId());
            ps.setString(3, msg.getTitle());
            ps.setString(4, msg.getContent());
            ps.setInt(5, Dict.MSG_UNREAD);
            ps.setTimestamp(6, new Timestamp(System.currentTimeMillis()));
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    public List<Message> listByReceiver(String receiverType, int receiverId) throws SQLException {
        return listByReceiver(receiverType, receiverId, 200);
    }

    public List<Message> listByReceiver(String receiverType, int receiverId, int limit) throws SQLException {
        String sql = "SELECT * FROM tb_message WHERE receiver_type = ? AND receiver_id = ? ORDER BY create_time DESC LIMIT ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        List<Message> list = new ArrayList<>();
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, receiverType);
            ps.setInt(2, receiverId);
            ps.setInt(3, Math.max(1, limit));
            rs = ps.executeQuery();
            while (rs.next()) { list.add(map(rs)); }
            return list;
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public int countUnread(String receiverType, int receiverId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM tb_message WHERE receiver_type = ? AND receiver_id = ? AND is_read = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, receiverType);
            ps.setInt(2, receiverId);
            ps.setInt(3, Dict.MSG_UNREAD);
            rs = ps.executeQuery();
            rs.next();
            return rs.getInt(1);
        } finally {
            DbUtil.close(rs, ps, conn);
        }
    }

    public void markRead(int messageId) throws SQLException {
        String sql = "UPDATE tb_message SET is_read = ? WHERE message_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Dict.MSG_READ);
            ps.setInt(2, messageId);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    public void markAllRead(String receiverType, int receiverId) throws SQLException {
        String sql = "UPDATE tb_message SET is_read = ? WHERE receiver_type = ? AND receiver_id = ? AND is_read = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DbUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, Dict.MSG_READ);
            ps.setString(2, receiverType);
            ps.setInt(3, receiverId);
            ps.setInt(4, Dict.MSG_UNREAD);
            ps.executeUpdate();
        } finally {
            DbUtil.close(null, ps, conn);
        }
    }

    private Message map(ResultSet rs) throws SQLException {
        Message m = new Message();
        m.setMessageId(rs.getInt("message_id"));
        m.setReceiverType(rs.getString("receiver_type"));
        m.setReceiverId(rs.getInt("receiver_id"));
        m.setTitle(rs.getString("title"));
        m.setContent(rs.getString("content"));
        m.setIsRead(rs.getInt("is_read"));
        m.setCreateTime(rs.getTimestamp("create_time"));
        return m;
    }
}