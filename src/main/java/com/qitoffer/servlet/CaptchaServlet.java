package com.qitoffer.servlet;

import com.qitoffer.common.Dict;
import com.qitoffer.util.CaptchaUtil;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.IOException;

/** 生成图形验证码并写入 SESSION_CAPTCHA，供企业/密码登录校验。 */
@WebServlet("/captcha")
public class CaptchaServlet extends HttpServlet {
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        String code = CaptchaUtil.randomCode();
        req.getSession(true).setAttribute(Dict.SESSION_CAPTCHA, code);

        resp.setHeader("Pragma", "no-cache");
        resp.setHeader("Cache-Control", "no-cache, no-store");
        resp.setDateHeader("Expires", 0);
        resp.setContentType("image/jpeg");

        BufferedImage image = CaptchaUtil.draw(code);
        ImageIO.write(image, "jpeg", resp.getOutputStream());
    }
}
