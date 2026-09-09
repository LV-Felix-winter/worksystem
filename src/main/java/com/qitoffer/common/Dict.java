package com.qitoffer.common;

/**
 * 状态码与会话键，AI Coding 和手写代码必须用这里的常量，不要自己再定义一套数字。
 */
public final class Dict {

    private Dict() {
    }

    /** 管理员 */
    public static final int ROLE_ADMIN = 1;
    /** 企业用户 */
    public static final int ROLE_COMPANY = 2;

    public static final int STATE_ENABLED = 1;
    public static final int STATE_DISABLED = 0;

    /** 职位招聘中 / 上架 */
    public static final int JOB_ONLINE = 1;
    /** 职位已下架 */
    public static final int JOB_OFFLINE = 0;

    /** 投递已拒绝 */
    public static final int APPLY_REJECTED = 0;
    /** 投递待处理 */
    public static final int APPLY_PENDING = 1;
    /** 投递已查看 */
    public static final int APPLY_VIEWED = 2;
    /** 投递已面试 */
    public static final int APPLY_INTERVIEW = 3;

    public static final int MSG_UNREAD = 0;
    public static final int MSG_READ = 1;

    public static final String RECEIVER_APPLICANT = "applicant";
    public static final String RECEIVER_USER = "user";

    public static final String SESSION_ADMIN = "SESSION_USER";
    public static final String SESSION_APPLICANT = "SESSION_APPLICANT";
}
