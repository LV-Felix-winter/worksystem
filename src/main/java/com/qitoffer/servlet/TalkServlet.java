package com.qitoffer.servlet;

import com.qitoffer.dao.CompanyDao;
import com.qitoffer.dao.JobDao;
import com.qitoffer.dao.TalkDao;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Company;
import com.qitoffer.entity.Job;
import com.qitoffer.entity.Talk;
import com.qitoffer.entity.TalkMsg;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.Collections;
import java.util.List;

/** 职位沟通：求职者与企业就某一职位互发消息，类似电商买卖双方会话。 */
@WebServlet("/talk")
public class TalkServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = AuthSupport.applicant(req);
        User backend = AuthSupport.backendUser(req);
        Company company = null;
        if (backend != null) {
            try {
                company = new CompanyDao().findByUserId(backend.getUserId());
            } catch (Exception ignored) {
            }
        }
        if (applicant == null && company == null) {
            AuthSupport.redirectLogin(req, resp, "applicant", "sms", "auth");
            return;
        }

        TalkDao talkDao = new TalkDao();
        int talkId = parseId(req.getParameter("talkId"));
        int jobId = parseId(req.getParameter("jobId"));
        Talk current = null;
        List<Talk> inbox = Collections.emptyList();
        List<TalkMsg> messages = Collections.emptyList();
        try {
            if (applicant != null && jobId > 0) {
                Job job = new JobDao().findById(jobId, false);
                if (job != null) {
                    current = talkDao.findOrCreate(job.getJobId(), job.getCompanyId(), applicant.getApplicantId());
                    talkId = current == null ? 0 : current.getTalkId();
                }
            }
            if (applicant != null) {
                inbox = talkDao.listByApplicant(applicant.getApplicantId());
            } else if (company != null) {
                inbox = talkDao.listByCompany(company.getCompanyId());
            }
            if (current == null && talkId > 0) {
                current = talkDao.findById(talkId);
            }
            if (current != null && !canSee(current, applicant, company)) {
                current = null;
            }
            if (current == null && !inbox.isEmpty()) {
                current = inbox.get(0);
            }
            if (current != null) {
                messages = talkDao.listMessages(current.getTalkId());
                req.setAttribute("talkJob", new JobDao().findById(current.getJobId(), false));
            }
        } catch (Exception ignored) {
        }

        req.setAttribute("talkInbox", inbox);
        req.setAttribute("talk", current);
        req.setAttribute("talkMessages", messages);
        req.setAttribute("talkMine", applicant != null ? "applicant" : "company");
        req.setAttribute("navKey", "talk");
        req.setAttribute("pageTitle", "去谈谈 · 锐聘");
        req.setAttribute("hideBrand", Boolean.TRUE);
        req.setAttribute("hideFooter", Boolean.TRUE);
        req.setAttribute("bodyClass", "talk-body");
        req.getRequestDispatcher("/talk/room.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        Applicant applicant = AuthSupport.applicant(req);
        User backend = AuthSupport.backendUser(req);
        Company company = null;
        if (backend != null) {
            try {
                company = new CompanyDao().findByUserId(backend.getUserId());
            } catch (Exception ignored) {
            }
        }
        if (applicant == null && company == null) {
            AuthSupport.redirectLogin(req, resp, "applicant", "sms", "auth");
            return;
        }
        int talkId = parseId(req.getParameter("talkId"));
        String content = AuthSupport.trim(req.getParameter("content"));
        if (talkId <= 0 || content.isEmpty()) {
            AuthSupport.redirectTo(req, resp, "/talk?talkId=" + talkId);
            return;
        }
        if (content.length() > 800) {
            content = content.substring(0, 800);
        }
        try {
            TalkDao talkDao = new TalkDao();
            Talk talk = talkDao.findById(talkId);
            if (talk != null && canSee(talk, applicant, company)) {
                talkDao.addMessage(talkId, applicant != null ? "applicant" : "company", content);
            }
        } catch (Exception ignored) {
        }
        AuthSupport.redirectTo(req, resp, "/talk?talkId=" + talkId);
    }

    private static boolean canSee(Talk talk, Applicant applicant, Company company) {
        if (talk == null) {
            return false;
        }
        if (applicant != null) {
            return talk.getApplicantId() == applicant.getApplicantId();
        }
        return company != null && talk.getCompanyId() == company.getCompanyId();
    }

    private static int parseId(String raw) {
        if (raw == null || raw.trim().isEmpty()) {
            return 0;
        }
        try {
            return Integer.parseInt(raw.trim());
        } catch (NumberFormatException e) {
            return 0;
        }
    }
}
