package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.dao.CompanyDao;
import com.qitoffer.dao.UserDao;
import com.qitoffer.entity.Company;
import com.qitoffer.entity.User;
import com.qitoffer.util.AuthSupport;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/manage/company")
public class ManageCompanyServlet extends HttpServlet {
    private final CompanyDao companyDao = new CompanyDao();
    private final UserDao userDao = new UserDao();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        req.setCharacterEncoding("UTF-8");
        User backend = AuthSupport.backendUser(req);
        if (backend == null || backend.getUserRole() != Dict.ROLE_ADMIN) {
            AuthSupport.redirectLogin(req, resp, "admin", null, "auth");
            return;
        }
        try {
            save(req);
        } catch (Exception e) {
            req.getSession().setAttribute("manageMsg", "保存失败：" + e.getMessage());
        }
        resp.sendRedirect(req.getContextPath() + "/manage/company.jsp");
    }

    private void save(HttpServletRequest req) throws Exception {
        int id = parseInt(req.getParameter("id"), 0);
        String name = AuthSupport.trim(req.getParameter("companyName"));
        String area = AuthSupport.trim(req.getParameter("companyArea"));
        String size = AuthSupport.trim(req.getParameter("companySize"));
        String type = AuthSupport.trim(req.getParameter("companyType"));
        String brief = AuthSupport.trim(req.getParameter("companyBrief"));
        int state = parseInt(req.getParameter("companyState"), Dict.STATE_ENABLED);
        int sort = parseInt(req.getParameter("companySort"), 100);
        int userId = parseInt(req.getParameter("userId"), 0);
        String account = AuthSupport.trim(req.getParameter("account"));
        String password = AuthSupport.trim(req.getParameter("password"));
        if (name.isEmpty()) {
            req.getSession().setAttribute("manageMsg", "请填写企业名称。");
            return;
        }
        if (id <= 0) {
            if (userId <= 0) {
                if (account.isEmpty() || password.length() < 6) {
                    req.getSession().setAttribute("manageMsg", "新增企业需填写登录账号，密码至少 6 位。");
                    return;
                }
                if (userDao.existsLogname(account, 0)) {
                    req.getSession().setAttribute("manageMsg", "登录账号已存在。");
                    return;
                }
                User user = new User();
                user.setUserLogname(account);
                user.setUserPwd(password);
                user.setUserRealname(name);
                user.setUserPhone(account.matches("1\\d{10}") ? account : null);
                user.setUserEmail("");
                user.setUserRole(Dict.ROLE_COMPANY);
                user.setUserState(Dict.STATE_ENABLED);
                userId = userDao.insert(user);
            }
            Company company = new Company();
            company.setUserId(userId);
            company.setCompanyName(name);
            company.setCompanyArea(area);
            company.setCompanySize(size);
            company.setCompanyType(type);
            company.setCompanyBrief(brief);
            company.setCompanyState(state);
            company.setCompanySort(sort);
            companyDao.insert(company);
            req.getSession().setAttribute("manageMsg", "企业已添加。");
            return;
        }
        Company existing = companyDao.findById(id);
        if (existing == null) {
            req.getSession().setAttribute("manageMsg", "企业不存在。");
            return;
        }
        if (userId > 0) {
            existing.setUserId(userId);
        }
        existing.setCompanyName(name);
        existing.setCompanyArea(area);
        existing.setCompanySize(size);
        existing.setCompanyType(type);
        existing.setCompanyBrief(brief);
        existing.setCompanyState(state);
        existing.setCompanySort(sort);
        companyDao.updateAdmin(existing);
        req.getSession().setAttribute("manageMsg", "企业资料已保存。");
    }

    private static int parseInt(String value, int def) {
        try {
            return Integer.parseInt(value);
        } catch (Exception e) {
            return def;
        }
    }
}
