package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.common.Labels;
import com.qitoffer.dao.ApplyDao;
import com.qitoffer.dao.CompanyDao;
import com.qitoffer.dao.JobDao;
import com.qitoffer.dao.ResumeDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Apply;
import com.qitoffer.entity.Job;
import com.qitoffer.entity.Resume;
import com.qitoffer.entity.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/**
 * 投递状态流转 (#71099538/#71099539)：
 *  /apply/add     求职者投递（写 tb_apply，状态=待处理）
 *  /apply/mine    我的申请（中文状态展示）
 *  /apply/company 企业应聘信息（本企业职位收到的投递）
 *  /apply/detail  企业查看简历摘要（待处理自动流转已查看）
 *  /apply/state   企业更新状态（校验职位归属 + 站内消息通知）
 * 处理人：佟乐
 */
@WebServlet("/apply/*")
public class ApplyServlet extends HttpServlet {
    private final ApplyDao applyDao = new ApplyDao();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo() == null ? "" : req.getPathInfo();
        switch (path) {
            case "/mine":
                handleMine(req, resp);
                break;
            case "/company":
            case "/detail":
                handleCompany(req, resp, path);
                break;
            default:
                resp.sendError(404);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        String path = req.getPathInfo() == null ? "" : req.getPathInfo();
        switch (path) {
            case "/add":
                handleAdd(req, resp);
                break;
            case "/state":
                handleState(req, resp);
                break;
            default:
                resp.sendError(404);
        }
    }

    /** 我的申请（#71099538：状态中文展示） */
    private void handleMine(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Applicant applicant = applicant(req);
        if (applicant == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        List<Apply> list;
        try {
            list = applyDao.listByApplicant(applicant.getApplicantId());
        } catch (Exception e) {
            list = Collections.emptyList();
        }
        req.setAttribute("applyList", list);
        req.setAttribute("navKey", "apply");
        req.setAttribute("pageTitle", "我的投递 · 锐聘");
        req.getRequestDispatcher("/user/apply.jsp").forward(req, resp);
    }

    /** 企业应聘信息 + 简历摘要（#71099539 归属校验） */
    private void handleCompany(HttpServletRequest req, HttpServletResponse resp, String path)
            throws ServletException, IOException {
        User backend = backend(req);
        if (backend == null) {
            resp.sendRedirect(req.getContextPath() + "/login?view=company");
            return;
        }
        int companyId = findCompanyId(req, backend);
        req.setAttribute("companyId", companyId);
        if ("/detail".equals(path)) {
            int applyId = parseInt(req.getParameter("id"));
            boolean owned = false;
            try {
                owned = companyId > 0 && applyDao.ownedByCompany(applyId, companyId);
            } catch (Exception ignored) {
            }
            if (!owned) {
                setMsg(req, "该投递不存在或不属于本企业职位。");
                forwardCompany(req, resp);
                return;
            }
            try {
                // 状态流转：待处理自动变为已查看（#71099538）
                applyDao.markViewedOwned(applyId, companyId);
            } catch (Exception ignored) {
            }
            setMsg(req, "已记录查看。");
            req.setAttribute("detailId", applyId);
        }
        forwardCompany(req, resp);
    }

    private void forwardCompany(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User backend = backend(req);
        int companyId = findCompanyId(req, backend);
        List<Apply> list;
        try {
            list = applyDao.listByCompany(companyId);
        } catch (Exception e) {
            list = Collections.emptyList();
        }
        req.setAttribute("applyList", list);
        req.setAttribute("navKey", "applies");
        req.setAttribute("pageTitle", "应聘信息 · 锐聘");
        req.getRequestDispatcher("/company/apply.jsp").forward(req, resp);
    }

    /** 求职者投递（#71099538 状态起点：待处理） */
    private void handleAdd(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        Applicant applicant = applicant(req);
        if (applicant == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        int jobId = parseInt(req.getParameter("jobId"));
        int resumeId;
        try {
            Resume resume = new ResumeDao().findByApplicantId(applicant.getApplicantId());
            if (resume == null) {
                resumeId = new ResumeDao().ensureForApplicant(applicant.getApplicantId());
            } else {
                resumeId = resume.getResumeId();
            }
        } catch (Exception e) {
            setMsg(req, "简历初始化失败，请稍后再试。");
            resp.sendRedirect(req.getContextPath() + "/user/apply.jsp");
            return;
        }
        if (jobId <= 0 || resumeId <= 0) {
            setMsg(req, "投递失败：请先完善简历。");
            resp.sendRedirect(req.getContextPath() + "/resume/");
            return;
        }
        try {
            Job job = new JobDao().findById(jobId, false);
            if (job == null || job.getJobState() != Dict.JOB_ONLINE) {
                setMsg(req, "该职位已下架，无法投递。");
                resp.sendRedirect(req.getContextPath() + "/job/search");
                return;
            }
            if (applyDao.exists(jobId, resumeId)) {
                setMsg(req, "您已投递过「" + job.getJobName() + "」，请查看我的投递。");
            } else {
                applyDao.add(jobId, resumeId);
                setMsg(req, "投递成功，初始状态：待处理。");
            }
        } catch (Exception e) {
            setMsg(req, "投递失败，请稍后再试。");
        }
        resp.sendRedirect(req.getContextPath() + "/user/apply.jsp");
    }

    /** 企业更新投递状态（#71099539：校验归属职位 + 通知求职者） */
    private void handleState(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        User backend = backend(req);
        if (backend == null) {
            resp.sendRedirect(req.getContextPath() + "/login?view=company");
            return;
        }
        int applyId = parseInt(req.getParameter("applyId"));
        int newState = parseInt(req.getParameter("newState"));
        if (!isLegalState(newState)) {
            setMsg(req, "状态值不合法。");
            resp.sendRedirect(req.getContextPath() + "/apply/company");
            return;
        }
        int companyId = findCompanyId(req, backend);
        if (companyId <= 0) {
            setMsg(req, "当前账号未关联企业信息，无法操作投递。");
            resp.sendRedirect(req.getContextPath() + "/apply/company");
            return;
        }
        boolean ok;
        try {
            ok = applyDao.updateStateOwned(applyId, newState, companyId);
        } catch (Exception e) {
            ok = false;
        }
        if (!ok) {
            setMsg(req, "更新失败：投递不存在或不属于本企业职位。");
        } else {
            try {
                int applicantId = applyDao.applicantOfApply(applyId);
                if (applicantId > 0) {
                    String content = "您对「" + jobNameOf(applyId) + "」的投递状态更新为："
                            + Labels.applyStateLabel(newState) + "。";
                    applyDao.notifyApplicant(applicantId, "投递状态更新", content);
                }
            } catch (Exception ignored) {
            }
            setMsg(req, "状态已更新为「" + Labels.applyStateLabel(newState) + "」。");
        }
        resp.sendRedirect(req.getContextPath() + "/apply/company");
    }

    // ---------- helpers ----------

    private String jobNameOf(int applyId) {
        try {
            return applyDao.jobNameOf(applyId);
        } catch (Exception e) {
            return "未知职位";
        }
    }

    private static boolean isLegalState(int state) {
        return state == Dict.APPLY_REJECTED || state == Dict.APPLY_PENDING
                || state == Dict.APPLY_VIEWED || state == Dict.APPLY_INTERVIEW;
    }

    private int findCompanyId(HttpServletRequest req, User backend) {
        try {
            User u = backend;
            com.qitoffer.entity.Company company = new CompanyDao().findByUserId(u.getUserId());
            return company == null ? 0 : company.getCompanyId();
        } catch (Exception e) {
            return 0;
        }
    }


    private static void setMsg(HttpServletRequest req, String text) {
        HttpSession session = req.getSession();
        session.setAttribute("applyMsg", text);
    }

    private static Applicant applicant(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(Dict.SESSION_APPLICANT);
        return value instanceof Applicant ? (Applicant) value : null;
    }

    private static User backend(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session == null) {
            return null;
        }
        Object value = session.getAttribute(Dict.SESSION_ADMIN);
        return value instanceof User ? (User) value : null;
    }

    private static int parseInt(String value) {
        if (value == null || value.trim().isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(value.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
