package com.qitoffer.common;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/** 简历多条记录编解码（存 TEXT 列）。 */
public final class ResumeBlocks {

    public static final class Edu {
        public String school = "";
        public String major = "";
        public String degree = "";
        public String years = "";
        public String gpa = "";
        public String courses = "";
    }

    public static final class Proj {
        public String name = "";
        public String role = "";
        public String period = "";
        public String desc = "";
    }

    public static final class Work {
        public String company = "";
        public String title = "";
        public String period = "";
        public String duties = "";
    }

    public static final class Skills {
        public String language = "";
        public String computer = "";
        public String team = "";
        public List<Bar> bars = new ArrayList<>();
    }

    public static final class Bar {
        public String name = "";
        public String level = "";
    }

    private ResumeBlocks() {
    }

    public static List<Edu> parseEdu(String raw) {
        List<Edu> list = new ArrayList<>();
        for (String line : splitRecords(raw)) {
            String[] p = splitFields(line, 6);
            Edu e = new Edu();
            e.school = p[0];
            e.major = p[1];
            e.degree = p[2];
            e.years = p[3];
            e.gpa = p[4];
            e.courses = p[5];
            if (!e.school.isEmpty() || !e.major.isEmpty()) {
                list.add(e);
            }
        }
        return list;
    }

    public static List<Proj> parseProj(String raw) {
        List<Proj> list = new ArrayList<>();
        for (String line : splitRecords(raw)) {
            String[] p = splitFields(line, 4);
            Proj e = new Proj();
            e.name = p[0];
            e.role = p[1];
            e.period = p[2];
            e.desc = p[3];
            if (!e.name.isEmpty() || !e.desc.isEmpty()) {
                list.add(e);
            }
        }
        return list;
    }

    public static List<Work> parseWork(String raw) {
        List<Work> list = new ArrayList<>();
        for (String line : splitRecords(raw)) {
            String[] p = splitFields(line, 4);
            Work w = new Work();
            w.company = p[0];
            w.title = p[1];
            w.period = p[2];
            w.duties = p[3];
            if (!w.company.isEmpty() || !w.title.isEmpty() || !w.duties.isEmpty()) {
                list.add(w);
            }
        }
        return list;
    }

    public static List<Work> worksOrFallback(String workExp, String jobExperience) {
        List<Work> list = parseWork(workExp);
        if (!list.isEmpty()) {
            return list;
        }
        if (jobExperience != null && !jobExperience.isBlank()) {
            Work w = new Work();
            w.company = "工作经历";
            w.duties = jobExperience.trim();
            list.add(w);
        }
        return list;
    }

    public static Skills parseSkills(String raw) {
        Skills s = new Skills();
        if (raw == null || raw.isBlank()) {
            return s;
        }
        String[] p = splitFields(raw.trim(), 4);
        s.language = p[0];
        s.computer = p[1];
        s.team = p[2];
        if (!p[3].isEmpty()) {
            for (String item : p[3].split(";;")) {
                String[] kv = item.split("::", 2);
                Bar bar = new Bar();
                bar.name = kv[0].trim();
                bar.level = kv.length > 1 ? kv[1].trim() : "";
                if (!bar.name.isEmpty()) {
                    s.bars.add(bar);
                }
            }
        }
        return s;
    }

    public static List<String> parseHonors(String raw) {
        List<String> list = new ArrayList<>();
        for (String line : splitRecords(raw)) {
            if (!line.isBlank()) {
                list.add(line.trim());
            }
        }
        return list;
    }

    public static List<String> dutiesOf(Work work) {
        List<String> out = new ArrayList<>();
        if (work == null || work.duties == null || work.duties.isBlank()) {
            return out;
        }
        for (String item : work.duties.split(";;")) {
            if (!item.isBlank()) {
                out.add(item.trim());
            }
        }
        return out;
    }

    public static String dutiesFromLines(String raw) {
        if (raw == null) {
            return "";
        }
        StringBuilder out = new StringBuilder();
        for (String line : raw.replace("\r", "").split("\n")) {
            String item = line.replace(";", "；").trim();
            if (item.isEmpty()) {
                continue;
            }
            if (out.length() > 0) {
                out.append(";;");
            }
            out.append(item);
        }
        return out.toString();
    }

    public static String dutiesToLines(String duties) {
        return dutiesOf(dutyWork(duties)).isEmpty() ? "" : String.join("\n", dutiesOf(dutyWork(duties)));
    }

    private static Work dutyWork(String duties) {
        Work w = new Work();
        w.duties = duties == null ? "" : duties;
        return w;
    }

    public static String encodeEdu(List<Edu> list) {
        StringBuilder out = new StringBuilder();
        if (list == null) {
            return "";
        }
        for (Edu e : list) {
            if (e == null) {
                continue;
            }
            if (out.length() > 0) {
                out.append('\n');
            }
            out.append(field(e.school)).append("||")
                    .append(field(e.major)).append("||")
                    .append(field(e.degree)).append("||")
                    .append(field(e.years)).append("||")
                    .append(field(e.gpa)).append("||")
                    .append(field(e.courses));
        }
        return out.toString();
    }

    public static String encodeProj(List<Proj> list) {
        StringBuilder out = new StringBuilder();
        if (list == null) {
            return "";
        }
        for (Proj e : list) {
            if (e == null) {
                continue;
            }
            if (out.length() > 0) {
                out.append('\n');
            }
            out.append(field(e.name)).append("||")
                    .append(field(e.role)).append("||")
                    .append(field(e.period)).append("||")
                    .append(field(e.desc));
        }
        return out.toString();
    }

    public static String encodeWork(List<Work> list) {
        StringBuilder out = new StringBuilder();
        if (list == null) {
            return "";
        }
        for (Work w : list) {
            if (w == null) {
                continue;
            }
            if (out.length() > 0) {
                out.append('\n');
            }
            out.append(field(w.company)).append("||")
                    .append(field(w.title)).append("||")
                    .append(field(w.period)).append("||")
                    .append(field(w.duties).replace(" ", " ").replace(";;", ";;"));
        }
        return out.toString();
    }

    public static String encodeSkills(Skills skills) {
        Skills s = skills == null ? new Skills() : skills;
        StringBuilder bars = new StringBuilder();
        if (s.bars != null) {
            for (Bar bar : s.bars) {
                if (bar == null || bar.name == null || bar.name.isBlank()) {
                    continue;
                }
                if (bars.length() > 0) {
                    bars.append(";;");
                }
                bars.append(field(bar.name)).append("::").append(field(bar.level));
            }
        }
        return field(s.language) + "||" + field(s.computer) + "||" + field(s.team) + "||" + bars;
    }

    public static String encodeHonors(List<String> list) {
        StringBuilder out = new StringBuilder();
        if (list == null) {
            return "";
        }
        for (String item : list) {
            if (item == null || item.isBlank()) {
                continue;
            }
            if (out.length() > 0) {
                out.append('\n');
            }
            out.append(field(item));
        }
        return out.toString();
    }

    public static String summarizeWork(List<Work> list) {
        if (list == null || list.isEmpty()) {
            return "";
        }
        StringBuilder out = new StringBuilder();
        for (Work w : list) {
            if (out.length() > 0) {
                out.append("；");
            }
            out.append(join(" ", w.company, w.title, w.period));
        }
        String text = out.toString();
        return text.length() > 480 ? text.substring(0, 480) : text;
    }

    public static List<Edu> upsertEdu(List<Edu> list, int index, Edu item) {
        return upsert(list, index, item);
    }

    public static List<Proj> upsertProj(List<Proj> list, int index, Proj item) {
        return upsert(list, index, item);
    }

    public static List<Work> upsertWork(List<Work> list, int index, Work item) {
        return upsert(list, index, item);
    }

    public static List<String> upsertHonor(List<String> list, int index, String item) {
        return upsert(list, index, item);
    }

    public static <T> List<T> removeAt(List<T> list, int index) {
        List<T> copy = new ArrayList<>(list == null ? List.of() : list);
        if (index >= 0 && index < copy.size()) {
            copy.remove(index);
        }
        return copy;
    }

    public static int barPercent(String level) {
        if ("精通".equals(level)) {
            return 95;
        }
        if ("熟练".equals(level)) {
            return 80;
        }
        if ("良好".equals(level)) {
            return 65;
        }
        if ("一般".equals(level)) {
            return 45;
        }
        return 50;
    }

    public static boolean skillsFilled(Skills skills) {
        if (skills == null) {
            return false;
        }
        return !skills.language.isBlank() || !skills.computer.isBlank() || !skills.team.isBlank()
                || (skills.bars != null && !skills.bars.isEmpty());
    }

    private static <T> List<T> upsert(List<T> list, int index, T item) {
        List<T> copy = new ArrayList<>(list == null ? List.of() : list);
        if (index >= 0 && index < copy.size()) {
            copy.set(index, item);
        } else {
            copy.add(item);
        }
        return copy;
    }

    private static String field(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("\r", "").replace("\n", " ").replace("|", "/").trim();
    }

    private static String join(String sep, String... parts) {
        StringBuilder out = new StringBuilder();
        for (String part : parts) {
            if (part == null || part.isBlank()) {
                continue;
            }
            if (out.length() > 0) {
                out.append(sep);
            }
            out.append(part.trim());
        }
        return out.toString();
    }

    public static Edu highestEdu(String raw) {
        List<Edu> list = parseEdu(raw);
        Edu best = null;
        int bestScore = -1;
        for (Edu e : list) {
            int score = degreeScore(e.degree);
            if (best == null || score > bestScore) {
                best = e;
                bestScore = score;
            }
        }
        return best;
    }

    public static String highestEduLabel(String raw) {
        Edu e = highestEdu(raw);
        if (e == null) {
            return "";
        }
        StringBuilder out = new StringBuilder();
        appendPart(out, e.degree);
        appendPart(out, e.school);
        appendPart(out, e.major);
        return out.toString();
    }

    public static int ageOf(Date birthday) {
        if (birthday == null) {
            return 0;
        }
        Calendar born = Calendar.getInstance();
        born.setTime(birthday);
        Calendar now = Calendar.getInstance();
        int age = now.get(Calendar.YEAR) - born.get(Calendar.YEAR);
        if (now.get(Calendar.DAY_OF_YEAR) < born.get(Calendar.DAY_OF_YEAR)) {
            age--;
        }
        return Math.max(0, age);
    }

    private static int degreeScore(String degree) {
        if (degree == null) {
            return 0;
        }
        if (degree.contains("博士")) {
            return 5;
        }
        if (degree.contains("硕士") || degree.contains("研究生")) {
            return 4;
        }
        if (degree.contains("本科")) {
            return 3;
        }
        if (degree.contains("大专") || degree.contains("专科") || degree.contains("高职")) {
            return 2;
        }
        if (degree.contains("高中") || degree.contains("中专")) {
            return 1;
        }
        return 0;
    }

    private static void appendPart(StringBuilder out, String value) {
        if (value == null || value.isEmpty()) {
            return;
        }
        if (out.length() > 0) {
            out.append(" · ");
        }
        out.append(value);
    }

    private static List<String> splitRecords(String raw) {
        List<String> out = new ArrayList<>();
        if (raw == null || raw.isBlank()) {
            return out;
        }
        for (String line : raw.split("\\n")) {
            if (!line.isBlank()) {
                out.add(line.trim());
            }
        }
        return out;
    }

    private static String[] splitFields(String line, int n) {
        String[] parts = line.split("\\|\\|", -1);
        String[] out = new String[n];
        for (int i = 0; i < n; i++) {
            out[i] = i < parts.length ? parts[i].trim() : "";
        }
        return out;
    }
}
