package com.qitoffer.common;

import com.lowagie.text.Document;
import com.lowagie.text.Element;
import com.lowagie.text.Font;
import com.lowagie.text.Image;
import com.lowagie.text.PageSize;
import com.lowagie.text.Paragraph;
import com.lowagie.text.Phrase;
import com.lowagie.text.pdf.BaseFont;
import com.lowagie.text.pdf.PdfPCell;
import com.lowagie.text.pdf.PdfPTable;
import com.lowagie.text.pdf.PdfWriter;
import com.qitoffer.entity.Applicant;
import com.qitoffer.entity.Resume;

import java.awt.Color;
import java.io.OutputStream;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.text.SimpleDateFormat;
import java.util.List;

/** 按简历模板生成可预览 / 下载的中文 PDF。 */
public final class ResumePdf {
    private static final Color BANNER = new Color(75, 85, 96);
    private static final Color FG = new Color(32, 36, 40);
    private static final Color MUTED = new Color(90, 101, 109);
    private static final Color BAR = new Color(138, 143, 150);
    private static final Color TRACK = new Color(230, 232, 234);
    private static final Color ACCENT = new Color(15, 159, 110);

    private ResumePdf() {
    }

    public static void write(Resume resume, Applicant applicant, String photoFile, OutputStream out) throws Exception {
        BaseFont cjk = cjkFont();
        Font nameFont = new Font(cjk, 18, Font.BOLD, FG);
        Font intentFont = new Font(cjk, 11, Font.NORMAL, ACCENT);
        Font bannerFont = new Font(cjk, 12, Font.BOLD, Color.WHITE);
        Font body = new Font(cjk, 10.5f, Font.NORMAL, FG);
        Font bold = new Font(cjk, 10.5f, Font.BOLD, FG);
        Font small = new Font(cjk, 9, Font.NORMAL, MUTED);

        Document doc = new Document(PageSize.A4, 42, 42, 36, 36);
        PdfWriter.getInstance(doc, out);
        doc.open();

        String name = text(resume == null ? null : resume.getRealname(),
                applicant == null ? null : applicant.getApplicantName(), "未填写姓名");
        String intent = text(resume == null ? null : resume.getJobIntension(), null, "求职意向未填写");
        String phone = text(resume == null ? null : resume.getTelephone(),
                applicant == null ? null : applicant.getApplicantPhone(), "—");
        String email = text(resume == null ? null : resume.getEmail(),
                applicant == null ? null : applicant.getApplicantEmail(), "—");
        String current = text(resume == null ? null : resume.getCurrentLoc(), null, "—");
        String resident = text(resume == null ? null : resume.getResidentLoc(), null, "—");
        String gender = text(resume == null ? null : resume.getGender(), null, "—");
        String birthday = "—";
        if (resume != null && resume.getBirthday() != null) {
            birthday = new SimpleDateFormat("yyyy-MM-dd").format(resume.getBirthday());
        }

        PdfPTable head = new PdfPTable(new float[]{4f, 1.1f});
        head.setWidthPercentage(100);
        PdfPCell left = bare();
        left.addElement(new Paragraph(name, nameFont));
        left.addElement(new Paragraph(intent, intentFont));
        left.addElement(new Paragraph(phone + "  ·  " + email + "  ·  " + gender + "  ·  " + birthday, small));
        left.addElement(new Paragraph(current + "  ·  户口 " + resident, small));
        head.addCell(left);
        PdfPCell photoCell = bare();
        photoCell.setHorizontalAlignment(Element.ALIGN_RIGHT);
        Image photo = loadPhoto(photoFile);
        if (photo != null) {
            photo.scaleToFit(88, 112);
            photoCell.addElement(photo);
        }
        head.addCell(photoCell);
        head.setSpacingAfter(10);
        doc.add(head);

        banner(doc, "教育背景", bannerFont);
        List<ResumeBlocks.Edu> eduList = ResumeBlocks.parseEdu(resume == null ? "" : resume.getEducation());
        if (eduList.isEmpty()) {
            doc.add(para("暂未填写教育背景。", small, 8));
        } else {
            for (ResumeBlocks.Edu edu : eduList) {
                doc.add(triple(edu.years, edu.school, join("", edu.major, edu.degree.isEmpty() ? "" : "（" + edu.degree + "）"), body, bold));
                if (!blank(edu.gpa).equals("—")) {
                    doc.add(para("专业成绩：" + edu.gpa, body, 2));
                }
                if (!blank(edu.courses).equals("—")) {
                    doc.add(para("主修课程：" + edu.courses, body, 8));
                }
            }
        }

        banner(doc, "工作经历", bannerFont);
        List<ResumeBlocks.Work> workList = ResumeBlocks.worksOrFallback(
                resume == null ? "" : resume.getWorkExp(),
                resume == null ? "" : resume.getJobExperience());
        if (workList.isEmpty()) {
            doc.add(para("暂未填写工作经历。", small, 8));
        } else {
            for (ResumeBlocks.Work work : workList) {
                doc.add(triple(work.period, work.company, work.title, body, bold));
                for (String duty : ResumeBlocks.dutiesOf(work)) {
                    doc.add(para("•  " + duty, body, 1));
                }
                doc.add(para(" ", small, 4));
            }
        }

        banner(doc, "技能特长", bannerFont);
        ResumeBlocks.Skills skills = ResumeBlocks.parseSkills(resume == null ? "" : resume.getSkills());
        if (!ResumeBlocks.skillsFilled(skills)) {
            doc.add(para("暂未填写技能特长。", small, 8));
        } else {
            if (!skills.language.isBlank()) {
                doc.add(para("语言能力：" + skills.language, body, 3));
            }
            if (!skills.computer.isBlank()) {
                doc.add(para("计算机：" + skills.computer, body, 3));
            }
            if (!skills.team.isBlank()) {
                doc.add(para("团队能力：" + skills.team, body, 6));
            }
            if (!skills.bars.isEmpty()) {
                doc.add(meters(skills.bars, body, small));
            }
        }

        banner(doc, "荣誉证书", bannerFont);
        List<String> honors = ResumeBlocks.parseHonors(resume == null ? "" : resume.getHonors());
        if (honors.isEmpty()) {
            doc.add(para("暂未填写荣誉证书。", small, 8));
        } else {
            for (String honor : honors) {
                doc.add(para("•  " + honor, body, 2));
            }
            doc.add(para(" ", small, 4));
        }

        banner(doc, "自我评价", bannerFont);
        String eval = resume == null || resume.getSelfEval() == null ? "" : resume.getSelfEval().trim();
        doc.add(para(eval.isEmpty() ? "暂未填写自我评价。" : eval, eval.isEmpty() ? small : body, 10));

        List<ResumeBlocks.Proj> projList = ResumeBlocks.parseProj(resume == null ? "" : resume.getProjectExp());
        if (!projList.isEmpty()) {
            banner(doc, "项目经验", bannerFont);
            for (ResumeBlocks.Proj proj : projList) {
                doc.add(triple(proj.period, proj.name, proj.role, body, bold));
                if (proj.desc != null && !proj.desc.isBlank()) {
                    doc.add(para(proj.desc, body, 8));
                }
            }
        }

        Paragraph foot = new Paragraph("由锐聘招聘平台根据在线简历生成", small);
        foot.setAlignment(Element.ALIGN_CENTER);
        foot.setSpacingBefore(12);
        doc.add(foot);
        doc.close();
    }

    public static String fileName(Resume resume, Applicant applicant) {
        String name = text(resume == null ? null : resume.getRealname(),
                applicant == null ? null : applicant.getApplicantName(), "简历");
        name = name.replaceAll("[\\\\/:*?\"<>|]", "").trim();
        if (name.isEmpty()) {
            name = "简历";
        }
        return name + "-锐聘简历.pdf";
    }

    private static void banner(Document doc, String title, Font font) throws Exception {
        PdfPTable table = new PdfPTable(1);
        table.setWidthPercentage(100);
        table.setSpacingBefore(8);
        table.setSpacingAfter(8);
        PdfPCell cell = new PdfPCell(new Phrase(title, font));
        cell.setBackgroundColor(BANNER);
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setPadding(7);
        cell.setPaddingLeft(10);
        table.addCell(cell);
        doc.add(table);
    }

    private static PdfPTable triple(String date, String org, String role, Font body, Font bold) {
        PdfPTable row = new PdfPTable(new float[]{2.2f, 3.4f, 2.2f});
        row.setWidthPercentage(100);
        row.setSpacingAfter(3);
        row.addCell(textCell(blank(date), body, Element.ALIGN_LEFT));
        row.addCell(textCell(blank(org), bold, Element.ALIGN_CENTER));
        row.addCell(textCell(blank(role), body, Element.ALIGN_RIGHT));
        return row;
    }

    private static PdfPTable meters(List<ResumeBlocks.Bar> bars, Font body, Font small) {
        PdfPTable wrap = new PdfPTable(1);
        wrap.setWidthPercentage(100);
        wrap.setSpacingBefore(6);
        wrap.setSpacingAfter(8);
        for (ResumeBlocks.Bar bar : bars) {
            PdfPTable row = new PdfPTable(new float[]{1.4f, 5.2f, 1.2f});
            row.setWidthPercentage(100);
            row.addCell(textCell(bar.name, body, Element.ALIGN_LEFT));
            int pct = Math.max(8, Math.min(100, ResumeBlocks.barPercent(bar.level)));
            PdfPTable track = new PdfPTable(new float[]{pct, 100 - pct});
            track.setWidthPercentage(100);
            PdfPCell fill = new PdfPCell();
            fill.setBackgroundColor(BAR);
            fill.setFixedHeight(6);
            fill.setBorder(PdfPCell.NO_BORDER);
            PdfPCell rest = new PdfPCell();
            rest.setBackgroundColor(TRACK);
            rest.setFixedHeight(6);
            rest.setBorder(PdfPCell.NO_BORDER);
            track.addCell(fill);
            track.addCell(rest);
            PdfPCell trackCell = bare();
            trackCell.setPaddingTop(6);
            trackCell.addElement(track);
            row.addCell(trackCell);
            row.addCell(textCell(bar.level, small, Element.ALIGN_RIGHT));
            PdfPCell outer = bare();
            outer.addElement(row);
            wrap.addCell(outer);
        }
        return wrap;
    }

    private static PdfPCell textCell(String text, Font font, int align) {
        PdfPCell cell = new PdfPCell(new Phrase(text, font));
        cell.setBorder(PdfPCell.NO_BORDER);
        cell.setHorizontalAlignment(align);
        cell.setPadding(2);
        return cell;
    }

    private static PdfPCell bare() {
        PdfPCell cell = new PdfPCell();
        cell.setBorder(PdfPCell.NO_BORDER);
        return cell;
    }

    private static Paragraph para(String text, Font font, float after) {
        Paragraph p = new Paragraph(text, font);
        p.setLeading(16);
        p.setSpacingAfter(after);
        return p;
    }

    private static String text(String first, String second, String fallback) {
        if (first != null && !first.isBlank()) {
            return first.trim();
        }
        if (second != null && !second.isBlank()) {
            return second.trim();
        }
        return fallback;
    }

    private static String blank(String value) {
        return value == null || value.isBlank() ? "—" : value.trim();
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
        return out.length() == 0 ? "—" : out.toString();
    }

    private static Image loadPhoto(String photoFile) {
        if (photoFile == null || photoFile.isBlank()) {
            return null;
        }
        Path path = Paths.get(photoFile);
        if (!Files.isRegularFile(path)) {
            return null;
        }
        String name = path.getFileName().toString().toLowerCase();
        if (!(name.endsWith(".jpg") || name.endsWith(".jpeg") || name.endsWith(".png"))) {
            return null;
        }
        try {
            return Image.getInstance(path.toAbsolutePath().toString());
        } catch (Exception e) {
            return null;
        }
    }

    private static BaseFont cjkFont() throws Exception {
        String[] candidates = {
                "C:/Windows/Fonts/simhei.ttf",
                "C:/Windows/Fonts/msyh.ttc,0",
                "C:/Windows/Fonts/simsun.ttc,0",
                "C:/Windows/Fonts/msyh.ttf",
                "/usr/share/fonts/truetype/noto/NotoSansCJK-Regular.ttc,0"
        };
        for (String path : candidates) {
            String file = path.contains(",") ? path.substring(0, path.indexOf(',')) : path;
            if (Files.isRegularFile(Paths.get(file))) {
                BaseFont font = BaseFont.createFont(path, BaseFont.IDENTITY_H, BaseFont.EMBEDDED);
                font.setSubset(true);
                return font;
            }
        }
        return BaseFont.createFont(BaseFont.HELVETICA, BaseFont.WINANSI, BaseFont.NOT_EMBEDDED);
    }
}
