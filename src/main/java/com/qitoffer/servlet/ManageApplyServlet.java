package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.common.Labels;
import com.qitoffer.dao.ApplyDao;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/manage/apply")
public class ManageApplyServlet extends HttpServlet {
    private final ApplyDao applyDao = new ApplyDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        User backend = AuthSupport.backendUser(req);
        if (backend == null || backend.getUserRole() != Dict.ROLE_ADMIN) {
            AuthSupport.redirectLogin(req, resp, "admin", null, "auth");
            return;
        }
        int applyId = parseInt(req.getParameter("id"), 0);
        int state = parseInt(req.getParameter("state"), -1);
        String kw = AuthSupport.trim(req.getParameter("kw"));
        String stateQ = AuthSupport.trim(req.getParameter("qstate"));
        try {
            if (applyId > 0 && state >= 0) {
                boolean ok = applyDao.updateStateAdmin(applyId, state);
                if (ok) {
                    int applicantId = applyDao.applicantOfApply(applyId);
                    if (applicantId > 0) {
                        applyDao.notifyApplicant(applicantId, "投递状态更新",
                                "管理员将您对「" + applyDao.jobNameOf(applyId) + "」的投递状态更新为："
                                        + Labels.applyStateLabel(state) + "。");
                    }
                    req.getSession().setAttribute("manageMsg", "申请状态已更新。");
                } else {
                    req.getSession().setAttribute("manageMsg", "更新失败。");
                }
            }
        } catch (Exception e) {
            req.getSession().setAttribute("manageMsg", "操作失败。");
        }
        String q = "kw=" + java.net.URLEncoder.encode(kw, java.nio.charset.StandardCharsets.UTF_8)
                + "&state=" + (stateQ.isEmpty() ? "all" : stateQ);
        resp.sendRedirect(req.getContextPath() + "/manage/apply.jsp?" + q);
    }

    private static int parseInt(String value, int def) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return def;
        }
    }
}
