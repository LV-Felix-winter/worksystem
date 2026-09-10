package com.qitoffer.filter;

import com.qitoffer.common.Dict;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.User;
import com.qitoffer.util.OnlineUserTracker;
import jakarta.servlet.annotation.WebListener;
import jakarta.servlet.http.HttpSessionAttributeListener;
import jakarta.servlet.http.HttpSessionBindingEvent;
import jakarta.servlet.http.HttpSessionEvent;
import jakarta.servlet.http.HttpSessionListener;

/** 登录写入 Session 时登记在线用户，退出或超时后移除。 */
@WebListener
public class OnlineUserListener implements HttpSessionAttributeListener, HttpSessionListener {
    @Override
    public void attributeAdded(HttpSessionBindingEvent event) {
        bind(event.getSession().getId(), event.getName(), event.getValue());
    }

    @Override
    public void attributeReplaced(HttpSessionBindingEvent event) {
        Object current = event.getSession().getAttribute(event.getName());
        bind(event.getSession().getId(), event.getName(), current);
    }

    @Override
    public void attributeRemoved(HttpSessionBindingEvent event) {
        if (!Dict.SESSION_ADMIN.equals(event.getName()) && !Dict.SESSION_APPLICANT.equals(event.getName())) {
            return;
        }
        Object admin = event.getSession().getAttribute(Dict.SESSION_ADMIN);
        Object applicant = event.getSession().getAttribute(Dict.SESSION_APPLICANT);
        if (admin instanceof User) {
            OnlineUserTracker.bindUser(event.getSession().getId(), (User) admin);
        } else if (applicant instanceof Applicant) {
            OnlineUserTracker.bindApplicant(event.getSession().getId(), (Applicant) applicant);
        } else {
            OnlineUserTracker.removeSession(event.getSession().getId());
        }
    }

    @Override
    public void sessionDestroyed(HttpSessionEvent event) {
        OnlineUserTracker.removeSession(event.getSession().getId());
    }

    private static void bind(String sessionId, String name, Object value) {
        if (Dict.SESSION_ADMIN.equals(name) && value instanceof User) {
            OnlineUserTracker.bindUser(sessionId, (User) value);
        } else if (Dict.SESSION_APPLICANT.equals(name) && value instanceof Applicant) {
            OnlineUserTracker.bindApplicant(sessionId, (Applicant) value);
        }
    }
}
