package com.qitoffer.util;

import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.util.Random;

public final class CaptchaUtil {
    private static final String POOL = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
    private static final int LENGTH = 4;
    private static final int WIDTH = 100;
    private static final int HEIGHT = 36;

    private CaptchaUtil() {
    }

    public static String randomCode() {
        Random random = new Random();
        StringBuilder sb = new StringBuilder(LENGTH);
        for (int i = 0; i < LENGTH; i++) {
            sb.append(POOL.charAt(random.nextInt(POOL.length())));
        }
        return sb.toString();
    }

    public static BufferedImage draw(String code) {
        BufferedImage image = new BufferedImage(WIDTH, HEIGHT, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = image.createGraphics();
        Random random = new Random();
        g.setColor(new Color(240, 244, 248));
        g.fillRect(0, 0, WIDTH, HEIGHT);
        g.setFont(new Font("Arial", Font.BOLD, 22));
        for (int i = 0; i < 6; i++) {
            g.setColor(new Color(180 + random.nextInt(60), 180 + random.nextInt(60), 180 + random.nextInt(60)));
            g.drawLine(random.nextInt(WIDTH), random.nextInt(HEIGHT),
                    random.nextInt(WIDTH), random.nextInt(HEIGHT));
        }
        for (int i = 0; i < code.length(); i++) {
            g.setColor(new Color(20 + random.nextInt(80), 20 + random.nextInt(80), 80 + random.nextInt(80)));
            g.drawString(String.valueOf(code.charAt(i)), 16 + i * 20, 26);
        }
        g.dispose();
        return image;
    }

    public static boolean matches(String expected, String actual) {
        if (expected == null || actual == null) {
            return false;
        }
        return expected.equalsIgnoreCase(actual.trim());
    }
}
