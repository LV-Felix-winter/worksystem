package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.JobDao;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/manage/job")
public class ManageJobServlet extends HttpServlet {
    private final JobDao jobDao = new JobDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        User backend = AuthSupport.backendUser(req);
        if (backend == null || backend.getUserRole() != Dict.ROLE_ADMIN) {
            AuthSupport.redirectLogin(req, resp, "admin", null, "auth");
            return;
        }
        int jobId = parseInt(req.getParameter("id"), 0);
        int state = parseInt(req.getParameter("state"), -1);
        try {
            if (jobId > 0 && (state == Dict.JOB_ONLINE || state == Dict.JOB_OFFLINE)) {
                boolean ok = jobDao.updateStateAdmin(jobId, state);
                req.getSession().setAttribute("manageMsg", ok ? "职位状态已更新。" : "更新失败。");
            }
        } catch (Exception e) {
            req.getSession().setAttribute("manageMsg", "操作失败。");
        }
        resp.sendRedirect(req.getContextPath() + "/manage/job.jsp");
    }

    private static int parseInt(String value, int def) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return def;
        }
    }
}
