package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.MessageDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Message;
import com.qitoffer.entity.User;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/message/bell")
public class MessageBellServlet extends HttpServlet {
    private final MessageDao messageDao = new MessageDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        resp.setCharacterEncoding("UTF-8");
        User user = (User) req.getSession().getAttribute(Dict.SESSION_ADMIN);
        Applicant applicant = (Applicant) req.getSession().getAttribute(Dict.SESSION_APPLICANT);
        boolean json = "json".equalsIgnoreCase(req.getParameter("format"))
                || (req.getHeader("Accept") != null && req.getHeader("Accept").contains("application/json"));

        String receiverType = null;
        int receiverId = 0;
        if (user != null) {
            receiverType = Dict.RECEIVER_USER;
            receiverId = user.getUserId();
        } else if (applicant != null) {
            receiverType = Dict.RECEIVER_APPLICANT;
            receiverId = applicant.getApplicantId();
        }

        int unread = 0;
        List<Message> messages = null;
        try {
            if (receiverType != null) {
                unread = messageDao.countUnread(receiverType, receiverId);
                if (json) {
                    messages = messageDao.listByReceiver(receiverType, receiverId, 20);
                }
            }
        } catch (Exception ignored) {
        }

        if (!json) {
            resp.setContentType("text/plain;charset=UTF-8");
            resp.getWriter().write(String.valueOf(unread));
            return;
        }

        resp.setContentType("application/json;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        out.write("{\"unread\":");
        out.write(String.valueOf(unread));
        out.write(",\"items\":[");
        if (messages != null) {
            boolean first = true;
            for (Message m : messages) {
                if (!first) {
                    out.write(',');
                }
                first = false;
                String time = m.getCreateTime() == null ? "" : String.valueOf(m.getCreateTime());
                if (time.length() > 19) {
                    time = time.substring(0, 19);
                }
                out.write("{\"id\":");
                out.write(String.valueOf(m.getMessageId()));
                out.write(",\"unread\":");
                out.write(m.getIsRead() == Dict.MSG_UNREAD ? "true" : "false");
                out.write(",\"title\":");
                writeJsonString(out, m.getTitle());
                out.write(",\"content\":");
                writeJsonString(out, m.getContent());
                out.write(",\"time\":");
                writeJsonString(out, time);
                out.write('}');
            }
        }
        out.write("]}");
    }

    private static void writeJsonString(PrintWriter out, String value) {
        out.write('"');
        if (value != null) {
            for (int i = 0; i < value.length(); i++) {
                char c = value.charAt(i);
                switch (c) {
                    case '\\':
                    case '"':
                        out.write('\\');
                        out.write(c);
                        break;
                    case '\n':
                        out.write("\\n");
                        break;
                    case '\r':
                        out.write("\\r");
                        break;
                    case '\t':
                        out.write("\\t");
                        break;
                    default:
                        if (c < 0x20) {
                            out.write(String.format("\\u%04x", (int) c));
                        } else {
                            out.write(c);
                        }
                }
            }
        }
        out.write('"');
    }
}
