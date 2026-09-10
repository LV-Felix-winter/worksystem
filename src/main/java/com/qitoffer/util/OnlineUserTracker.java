package com.qitoffer.util;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.User;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Comparator;
import java.util.Date;
import java.util.List;
import java.util.concurrent.ConcurrentHashMap;

/** 当前在线会话，按 Session 跟踪，供管理员列表页使用。 */
public final class OnlineUserTracker {
    private static final ConcurrentHashMap<String, Record> ONLINE = new ConcurrentHashMap<>();

    private OnlineUserTracker() {
    }

    public static void bindUser(String sessionId, User user) {
        if (sessionId == null || user == null) {
            return;
        }
        String name = firstNonBlank(user.getUserRealname(), user.getUserLogname());
        String role = user.getUserRole() == Dict.ROLE_ADMIN ? "管理员" : "企业";
        ONLINE.put(sessionId, new Record(sessionId, name, role, user.getUserLogname(), new Date()));
    }

    public static void bindApplicant(String sessionId, Applicant applicant) {
        if (sessionId == null || applicant == null) {
            return;
        }
        String name = firstNonBlank(applicant.getApplicantName(), applicant.getApplicantPhone());
        ONLINE.put(sessionId, new Record(sessionId, name, "求职者", applicant.getApplicantPhone(), new Date()));
    }

    public static void removeSession(String sessionId) {
        if (sessionId != null) {
            ONLINE.remove(sessionId);
        }
    }

    public static List<Record> list() {
        List<Record> rows = new ArrayList<>(ONLINE.values());
        rows.sort(Comparator.comparing(Record::getLoginAt).reversed());
        return rows;
    }

    public static String format(Date date) {
        if (date == null) {
            return "";
        }
        return new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(date);
    }

    private static String firstNonBlank(String preferred, String fallback) {
        if (preferred != null && !preferred.trim().isEmpty()) {
            return preferred;
        }
        return fallback == null ? "" : fallback;
    }

    public static final class Record {
        private final String sessionId;
        private final String displayName;
        private final String roleLabel;
        private final String account;
        private final Date loginAt;

        private Record(String sessionId, String displayName, String roleLabel, String account, Date loginAt) {
            this.sessionId = sessionId;
            this.displayName = displayName;
            this.roleLabel = roleLabel;
            this.account = account;
            this.loginAt = loginAt;
        }

        public String getSessionId() {
            return sessionId;
        }

        public String getDisplayName() {
            return displayName;
        }

        public String getRoleLabel() {
            return roleLabel;
        }

        public String getAccount() {
            return account;
        }

        public Date getLoginAt() {
            return loginAt;
        }
    }
}
