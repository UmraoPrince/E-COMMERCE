package com.ecommerce.util;

import java.io.InputStream;
import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.InternetAddress;
import javax.mail.internet.MimeMessage;

public class EmailService {
    private static String emailUser;
    private static String emailPass;

    static {
        Properties prop = new Properties();
        try (InputStream input = EmailService.class.getClassLoader().getResourceAsStream("db.properties")) {
            if (input != null) {
                prop.load(input);
            }
        } catch (Exception e) {
            System.err.println("❌ Error loading db.properties: " + e.getMessage());
        }

        // Check environment variables, fallback to db.properties
        emailUser = System.getenv("EMAIL_USERNAME");
        if (emailUser == null || emailUser.trim().isEmpty()) {
            emailUser = System.getenv("MAIL_USERNAME");
        }
        if (emailUser == null || emailUser.trim().isEmpty()) {
            emailUser = System.getenv("SPRING_MAIL_USERNAME");
        }
        if (emailUser == null || emailUser.trim().isEmpty()) {
            emailUser = prop.getProperty("email.username");
        }

        emailPass = System.getenv("EMAIL_PASSWORD");
        if (emailPass == null || emailPass.trim().isEmpty()) {
            emailPass = System.getenv("MAIL_PASSWORD");
        }
        if (emailPass == null || emailPass.trim().isEmpty()) {
            emailPass = System.getenv("SPRING_MAIL_PASSWORD");
        }
        if (emailPass == null || emailPass.trim().isEmpty()) {
            emailPass = prop.getProperty("email.password");
        }
    }

    /**
     * Send 6-digit verification code using real Gmail SMTP
     */
    public static boolean sendOTP(String recipientEmail, String recipientName, String otp) {
        // Dynamic SMTP Host and Port config
        String mailHost = System.getenv("MAIL_HOST");
        if (mailHost == null || mailHost.trim().isEmpty()) {
            mailHost = System.getenv("SPRING_MAIL_HOST");
        }
        if (mailHost == null || mailHost.trim().isEmpty()) {
            mailHost = "smtp.gmail.com";
        }

        String mailPort = System.getenv("MAIL_PORT");
        if (mailPort == null || mailPort.trim().isEmpty()) {
            mailPort = System.getenv("SPRING_MAIL_PORT");
        }
        if (mailPort == null || mailPort.trim().isEmpty()) {
            mailPort = "587";
        }

        String mailAuth = System.getenv("MAIL_SMTP_AUTH");
        if (mailAuth == null || mailAuth.trim().isEmpty()) {
            mailAuth = "true";
        }

        String mailStarttls = System.getenv("MAIL_SMTP_STARTTLS_ENABLE");
        if (mailStarttls == null || mailStarttls.trim().isEmpty()) {
            mailStarttls = "true";
        }

        // Diagnostic logging (masking password)
        System.out.println("\n----------------- SMTP DIAGNOSTIC INFO -----------------");
        System.out.println("Host: " + mailHost);
        System.out.println("Port: " + mailPort);
        System.out.println("Auth Enabled: " + mailAuth);
        System.out.println("StartTLS Enabled: " + mailStarttls);
        System.out.println("SMTP Username: " + (emailUser != null ? emailUser : "NOT CONFIGURED"));
        System.out.println("SMTP Password Set: " + (emailPass != null && !emailPass.trim().isEmpty() ? "YES (" + emailPass.length() + " chars)" : "NO"));
        
        if (emailUser == null || emailPass == null || emailUser.trim().isEmpty() || emailPass.trim().isEmpty() ||
            "YOUR_SMTP_EMAIL_ADDRESS".equalsIgnoreCase(emailUser) || "YOUR_SMTP_APPLICATION_PASSWORD".equalsIgnoreCase(emailPass)) {
            System.err.println("❌ [SMTP CONFIG ERROR] Invalid or default placeholder credentials detected!");
            System.err.println("Please set the EMAIL_USERNAME and EMAIL_PASSWORD environment variables in your hosting environment (e.g. Render Dashboard).");
            System.err.println("--------------------------------------------------------\n");
            return false;
        }
        System.out.println("--------------------------------------------------------\n");

        // Configure SMTP Properties
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", mailAuth);
        properties.put("mail.smtp.starttls.enable", mailStarttls);
        properties.put("mail.smtp.host", mailHost);
        properties.put("mail.smtp.port", mailPort);
        properties.put("mail.smtp.ssl.protocols", "TLSv1.2");

        // Establish session authentication
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(emailUser, emailPass);
            }
        });

        try {
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(emailUser, "ShopEasy Security"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail));
            message.setSubject("Verify Your ShopEasy Account");

            // Construct professional HTML email template
            String emailContent = 
                "<!DOCTYPE html>" +
                "<html>" +
                "<head>" +
                "    <meta charset='utf-8'>" +
                "</head>" +
                "<body style=\"font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background-color: #f4f5f7; margin: 0; padding: 0;\">" +
                "    <table border='0' cellpadding='0' cellspacing='0' width='100%' style='background-color: #f4f5f7; padding: 20px 0;'>" +
                "        <tr>" +
                "            <td align='center'>" +
                "                <table border='0' cellpadding='0' cellspacing='0' width='600' style='background-color: #ffffff; border-radius: 12px; box-shadow: 0 4px 12px rgba(0,0,0,0.05); border: 1px solid #e1e4e8; overflow: hidden;'>" +
                "                    <!-- Header -->" +
                "                    <tr>" +
                "                        <td align='center' style='background: linear-gradient(135deg, #6366f1 0%, #4f46e5 100%); padding: 30px 20px;'>" +
                "                            <h1 style='color: #ffffff; margin: 0; font-size: 28px; font-weight: 800; letter-spacing: -0.5px;'>ShopEasy</h1>" +
                "                        </td>" +
                "                    </tr>" +
                "                    <!-- Content -->" +
                "                    <tr>" +
                "                        <td style='padding: 40px 30px;'>" +
                "                            <h2 style='color: #1a202c; font-size: 20px; font-weight: 700; margin-top: 0; margin-bottom: 15px;'>Welcome to ShopEasy, " + recipientName + "!</h2>" +
                "                            <p style='font-size: 16px; line-height: 1.6; color: #4a5568; margin: 0 0 25px 0;'>Thank you for registering. Use the secure verification code below to verify your email and activate your account:</p>" +
                "                            " +
                "                            <!-- OTP Box -->" +
                "                            <table border='0' cellpadding='0' cellspacing='0' width='100%' style='margin-bottom: 25px;'>" +
                "                                <tr>" +
                "                                    <td align='center'>" +
                "                                        <div style=\"font-family: 'Courier New', Courier, monospace; font-size: 36px; font-weight: 800; background-color: #f7fafc; border: 1px dashed #cbd5e0; border-radius: 8px; padding: 18px 30px; letter-spacing: 8px; color: #4f46e5; display: inline-block;\">" +
                                                            otp +
                "                                        </div>" +
                "                                    </td>" +
                "                                </tr>" +
                "                            </table>" +
                "                            " +
                "                            <p style='font-size: 14px; line-height: 1.6; color: #718096; margin: 0 0 25px 0; text-align: center; font-style: italic;'>This OTP is valid for <strong>5 minutes</strong>. For security reasons, please do not share this code with anyone.</p>" +
                "                            " +
                "                            <div style='background-color: #fffaf0; border-left: 4px solid #dd6b20; padding: 15px; border-radius: 4px; margin-bottom: 25px;'>" +
                "                                <p style='font-size: 13px; line-height: 1.5; color: #dd6b20; margin: 0; font-weight: 600;'>⚠️ Security Warning</p>" +
                "                                <p style='font-size: 13px; line-height: 1.5; color: #7b341e; margin: 5px 0 0 0;'>ShopEasy representatives will never ask for your verification code or password. If you did not request this email, please ignore it.</p>" +
                "                            </div>" +
                "                        </td>" +
                "                    </tr>" +
                "                    <!-- Footer -->" +
                "                    <tr>" +
                "                        <td style='background-color: #f7fafc; padding: 20px 30px; border-top: 1px solid #edf2f7; text-align: center;'>" +
                "                            <p style='font-size: 13px; line-height: 1.5; color: #a0aec0; margin: 0;'>&copy; 2026 ShopEasy Inc. All rights reserved.</p>" +
                "                            <p style='font-size: 12px; line-height: 1.5; color: #cbd5e0; margin: 5px 0 0 0;'>This is an automated system email. Please do not reply.</p>" +
                "                        </td>" +
                "                    </tr>" +
                "                </table>" +
                "            </td>" +
                "        </tr>" +
                "    </table>" +
                "</body>" +
                "</html>";

            message.setContent(emailContent, "text/html; charset=utf-8");

            // Trigger SMTP Delivery
            Transport.send(message);
            System.out.println("✅ [SMTP SUCCESS] Real verification email sent to " + recipientEmail);
            return true;
        } catch (Exception e) {
            System.err.println("❌ [SMTP ERROR] Failed to send email to " + recipientEmail + ": " + e.getMessage());
            e.printStackTrace();
            return false;
        }
    }
}