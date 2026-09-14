package com.qitoffer.common;

/**
 * 状态码 → 中文文案映射，页面统一从这里取，避免各处写死。
 * 数字本身只用 Dict 常量。
 * 处理人：佟乐 | 任务：#71099538
 */
public final class Labels {

    private Labels() {
    }

    public static String applyStateLabel(int state) {
        switch (state) {
            case Dict.APPLY_REJECTED:
                return "已拒绝";
            case Dict.APPLY_PENDING:
                return "待处理";
            case Dict.APPLY_VIEWED:
                return "已查看";
            case Dict.APPLY_INTERVIEW:
                return "已面试";
            default:
                return "未知";
        }
    }

    /** 状态徽章 CSS 类，供我的申请/企业应聘信息页用 */
    public static String applyStateClass(int state) {
        switch (state) {
            case Dict.APPLY_REJECTED:
                return "st-rejected";
            case Dict.APPLY_PENDING:
                return "st-pending";
            case Dict.APPLY_VIEWED:
                return "st-viewed";
            case Dict.APPLY_INTERVIEW:
                return "st-interview";
            default:
                return "st-unknown";
        }
    }

    public static String jobStateLabel(int state) {
        return state == Dict.JOB_ONLINE ? "招聘中" : "已下架";
    }

    public static String userRoleLabel(int role) {
        if (role == Dict.ROLE_ADMIN) {
            return "管理员";
        }
        if (role == Dict.ROLE_COMPANY) {
            return "企业";
        }
        return "未知";
    }

    public static String userStateLabel(int state) {
        return state == Dict.STATE_ENABLED ? "启用" : "禁用";
    }

    public static String companyStateLabel(int state) {
        return state == Dict.STATE_ENABLED ? "招聘中" : "已停用";
    }
}
