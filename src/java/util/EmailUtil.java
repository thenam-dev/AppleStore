/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;


import java.util.Properties;
import javax.mail.*;
import javax.mail.internet.*;
/**
 *
 * @author admin
 */
public class EmailUtil {
        // Sửa thành email của bạn
    private static final String SENDER_EMAIL = "chubaokhang1611@gmail.com";
    // Mật khẩu ứng dụng 16 số của Google
    private static final String SENDER_PASSWORD = "agsf kegm pnwc huve"; 
    public static void sendOtpEmail(String recipientEmail, String otpCode) throws Exception {
        Properties properties = new Properties();
        properties.put("mail.smtp.auth", "true");
        properties.put("mail.smtp.starttls.enable", "true");
        properties.put("mail.smtp.host", "smtp.gmail.com");
        properties.put("mail.smtp.port", "587");
        Session session = Session.getInstance(properties, new Authenticator() {
            @Override
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(SENDER_EMAIL, SENDER_PASSWORD);
            }
        });
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(SENDER_EMAIL, "AppleStore Security"));
        message.setRecipient(Message.RecipientType.TO, new InternetAddress(recipientEmail));
        message.setSubject("Mã OTP khôi phục mật khẩu");
        message.setText("Xin chào,\n\nMã OTP của bạn là: " + otpCode + "\nMã này chỉ có hiệu lực trong 5 phút. Vui lòng không chia sẻ cho bất kỳ ai.");
        Transport.send(message);
    }
}
