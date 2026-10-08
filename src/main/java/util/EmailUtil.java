package util;

import jakarta.mail.*;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

public class EmailUtil {
    private static final Logger LOGGER = Logger.getLogger(EmailUtil.class.getName());

    // =========================================================================
    // TODO: USER CONFIGURATION REQUIRED HERE
    // You must provide your own Gmail Address and a 16-digit App Password here.
    // 1. Go to your Google Account -> Security
    // 2. Enable 2-Step Verification
    // 3. Search for "App Passwords" and generate a new one.
    // =========================================================================
    private static final String SMTP_EMAIL = "YOUR_EMAIL_HERE@gmail.com"; 
    private static final String SMTP_APP_PASSWORD = "YOUR_16_DIGIT_APP_PASSWORD_HERE"; 

    public static boolean sendEmail(String toAddress, String subject, String messageContent) {
        // Configure SMTP Properties for Gmail
        Properties props = new Properties();
        props.put("mail.smtp.host", "smtp.gmail.com");
        props.put("mail.smtp.port", "587");
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        
        // Prevent hanging
        props.put("mail.smtp.connectiontimeout", "5000");
        props.put("mail.smtp.timeout", "5000");

        // Authenticate
        Session session = Session.getInstance(props, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SMTP_EMAIL, SMTP_APP_PASSWORD);
            }
        });

        try {
            // Build Message
            Message message = new MimeMessage(session);
            message.setFrom(new InternetAddress(SMTP_EMAIL, "Secure Voting System"));
            message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(toAddress));
            message.setSubject(subject);
            
            // Set HTML Content
            message.setContent(messageContent, "text/html; charset=utf-8");

            // Send Email
            Transport.send(message);
            LOGGER.info("Email successfully sent to: " + toAddress);
            return true;

        } catch (AuthenticationFailedException e) {
            LOGGER.log(Level.SEVERE, "SMTP Authentication Failed. Check your App Password!", e);
            return false;
        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to send email to: " + toAddress, e);
            return false;
        }
    }
}
