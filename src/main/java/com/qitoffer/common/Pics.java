package com.qitoffer.common;

import java.util.ArrayList;
import java.util.List;

/** 本地演示图：办公实拍 JPG，不依赖外网。 */
public final class Pics {
    public static final String PORTRAIT = "/images/portrait.svg";

    private Pics() {
    }

    public static String banner(int companyId, String ctx) {
        return ctx + "/images/banner-" + (1 + Math.floorMod(companyId - 1, 9)) + ".jpg";
    }

    public static String logo(int companyId, String ctx) {
        return ctx + "/images/logo-" + (1 + Math.floorMod(companyId - 1, 9)) + ".jpg";
    }

    public static String companyPic(String stored, int companyId, String ctx) {
        if (usablePath(stored)) {
            String path = toJpg(stored);
            return path.startsWith(ctx) ? path : ctx + path;
        }
        return logo(companyId, ctx);
    }

    /** 企业宣传横幅：有上传图用上传图，否则回退默认 banner。 */
    public static String companyPromo(String stored, int companyId, String ctx) {
        if (usablePath(stored)) {
            String path = toJpg(stored);
            return path.startsWith(ctx) ? path : ctx + path;
        }
        return banner(companyId, ctx);
    }

    public static boolean hasStoredPic(String stored) {
        return usablePath(stored);
    }

    public static String jobCover(String stored, int companyId, String ctx) {
        if (usablePath(stored)) {
            String path = toJpg(stored);
            return path.startsWith(ctx) ? path : ctx + path;
        }
        return banner(companyId, ctx);
    }

    public static String jobThumb(String stored, int jobId, String ctx) {
        if (usablePath(stored)) {
            String path = toJpg(stored);
            return path.startsWith(ctx) ? path : ctx + path;
        }
        return ctx + "/images/job-thumb-" + (1 + Math.floorMod(jobId - 1, 9)) + ".jpg";
    }

    public static String photo(String stored, String ctx) {
        if (stored != null && !stored.isEmpty()) {
            if (looksRemote(stored)) {
                return ctx + PORTRAIT;
            }
            return stored.startsWith(ctx) ? stored : ctx + stored;
        }
        return ctx + PORTRAIT;
    }

    public static String slogan(String companyName, String companyType) {
        if (companyType != null && !companyType.isBlank()) {
            return companyType + (companyName == null || companyName.isBlank() ? "" : " · " + companyName);
        }
        return companyName == null || companyName.isBlank() ? "提供岗前培训的 IT 职位" : companyName;
    }

    public static List<String> highlights(String brief, String area, String size, String type) {
        List<String> out = new ArrayList<>();
        if (brief != null && !brief.trim().isEmpty()) {
            String[] parts = brief.split("[。！!；;\\n]+");
            for (String part : parts) {
                String text = part.trim();
                if (text.length() < 4) {
                    continue;
                }
                if (text.length() > 36) {
                    text = text.substring(0, 36) + "…";
                }
                out.add(text);
                if (out.size() >= 4) {
                    break;
                }
            }
        }
        String[] extras = {
                type == null || type.isBlank() ? "国家规划布局内重点软件企业" : "企业性质：" + type,
                size == null || size.isBlank() ? "提供岗前培训的 IT 职位" : "团队规模：" + size,
                area == null || area.isBlank() ? "面向全国重点城市招聘" : "所在地区：" + area,
                "软件研发、外包与人才输送"
        };
        for (String extra : extras) {
            if (out.size() >= 4) {
                break;
            }
            boolean dup = false;
            for (String exist : out) {
                if (exist.equals(extra)) {
                    dup = true;
                    break;
                }
            }
            if (!dup) {
                out.add(extra);
            }
        }
        return out;
    }

    private static boolean usablePath(String stored) {
        return stored != null && !stored.isEmpty()
                && (stored.startsWith("/upload") || stored.startsWith("/images"));
    }

    /** 旧种子数据里的 .svg 占位图统一映射到同名 .jpg 实拍图。 */
    private static String toJpg(String path) {
        if (path == null) {
            return null;
        }
        if (path.endsWith(".svg") && (path.contains("/banner-")
                || path.contains("/job-thumb-")
                || path.contains("/logo-"))) {
            return path.substring(0, path.length() - 4) + ".jpg";
        }
        return path;
    }

    private static boolean looksRemote(String stored) {
        String value = stored.toLowerCase();
        return value.startsWith("http://") || value.startsWith("https://") || value.startsWith("data:");
    }
}
