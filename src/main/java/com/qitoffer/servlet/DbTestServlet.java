package com.qitoffer.servlet;

import com.qitoffer.util.DbUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.io.PrintWriter;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

@WebServlet("/dbtest")
public class DbTestServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        resp.setContentType("text/html;charset=UTF-8");
        PrintWriter out = resp.getWriter();
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            conn = DbUtil.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(
                    "SELECT DATABASE() AS db_name, VERSION() AS db_version");
            rs.next();
            out.println("<h2>数据库连接成功</h2>");
            out.println("<p>库名：" + rs.getString("db_name") + "</p>");
            out.println("<p>版本：" + rs.getString("db_version") + "</p>");
            rs.close();
            rs = stmt.executeQuery(
                    "SELECT TABLE_NAME FROM information_schema.TABLES "
                            + "WHERE TABLE_SCHEMA = 'q_itoffer' ORDER BY TABLE_NAME");
            out.println("<p>数据表：</p><ul>");
            while (rs.next()) {
                out.println("<li>" + rs.getString(1) + "</li>");
            }
            out.println("</ul>");
            rs.close();
            rs = stmt.executeQuery(
                    "SELECT COLUMN_NAME FROM information_schema.COLUMNS "
                            + "WHERE TABLE_SCHEMA='q_itoffer' AND TABLE_NAME='tb_resume' "
                            + "AND COLUMN_NAME IN ('attachment','completeness')");
            out.println("<p>简历扩展列：");
            boolean hasResumeExt = false;
            while (rs.next()) {
                hasResumeExt = true;
                out.print(rs.getString(1) + " ");
            }
            out.println(hasResumeExt ? "</p>" : "尚未执行扩展脚本</p>");
            rs.close();
            rs = stmt.executeQuery(
                    "SELECT COUNT(*) FROM information_schema.COLUMNS "
                            + "WHERE TABLE_SCHEMA='q_itoffer' AND TABLE_NAME='tb_job' "
                            + "AND COLUMN_NAME='job_viewnum'");
            rs.next();
            out.println("<p>职位浏览量列 job_viewnum："
                    + (rs.getInt(1) > 0 ? "已存在" : "缺失") + "</p>");
        } catch (Exception e) {
            out.println("<h2>数据库连接失败</h2>");
            out.println("<pre>" + e.getMessage() + "</pre>");
        } finally {
            DbUtil.close(rs, stmt, conn);
        }
    }
}
