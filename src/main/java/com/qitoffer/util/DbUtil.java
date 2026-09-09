package com.qitoffer.util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;

public final class DbUtil {
    private static final String DRIVER;
    private static final String URL;
    private static final String USER;
    private static final String PASSWORD;

    static {
        Properties props = new Properties();
        try (InputStream in = DbUtil.class.getClassLoader().getResourceAsStream("jdbc.properties")) {
            if (in == null) {
                throw new IllegalStateException("找不到 jdbc.properties");
            }
            props.load(in);
            DRIVER = props.getProperty("jdbc.driver");
            URL = props.getProperty("jdbc.url");
            USER = props.getProperty("jdbc.user");
            PASSWORD = props.getProperty("jdbc.password");
            Class.forName(DRIVER);
        } catch (Exception e) {
            throw new ExceptionInInitializerError(e);
        }
    }

    private DbUtil() {
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASSWORD);
    }

    public static void close(Connection conn) {
        close(null, null, conn);
    }

    public static void close(ResultSet rs, Statement stmt, Connection conn) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException ignored) {
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException ignored) {
            }
        }
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException ignored) {
            }
        }
    }
}
