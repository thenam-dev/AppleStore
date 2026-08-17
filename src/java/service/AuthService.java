package service;

import dao.user.UserDAO;
import model.entity.user.User;
import util.PasswordUtil;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.regex.Pattern;


public class AuthService {

    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9]{9,15}$");

    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCK_MINUTES = 15;

    private final UserDAO userDAO;

    public AuthService() {
        this(new UserDAO());
    }

    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

   
    public User register(String fullName, String email, String phone, String password, String confirmPassword)
            throws SQLException {
        String normalizedFullName = trimRequired(fullName, "Vui lòng nhập họ tên.");
        String normalizedEmail = trimRequired(email, "Vui lòng nhập email.").toLowerCase();
        String normalizedPhone = normalizeOptional(phone);

        if (normalizedFullName.length() > 100) {
            throw new IllegalArgumentException("Họ tên không được vượt quá 100 ký tự.");
        }
        if (!EMAIL_PATTERN.matcher(normalizedEmail).matches() || normalizedEmail.length() > 255) {
            throw new IllegalArgumentException("Email không hợp lệ.");
        }
        if (normalizedPhone != null && !PHONE_PATTERN.matcher(normalizedPhone).matches()) {
            throw new IllegalArgumentException("Số điện thoại phải gồm 9 đến 15 chữ số.");
        }
        if (password == null || password.length() < 8) {
            throw new IllegalArgumentException("Mật khẩu phải có ít nhất 8 ký tự.");
        }
        if (!password.equals(confirmPassword)) {
            throw new IllegalArgumentException("Mật khẩu xác nhận không khớp.");
        }
        if (userDAO.existsByEmail(normalizedEmail)) {
            throw new IllegalArgumentException("Email này đã được đăng ký.");
        }
        if (userDAO.existsByPhone(normalizedPhone)) {
            throw new IllegalArgumentException("Số điện thoại này đã được đăng ký.");
        }

        User user = new User();
        user.setFullName(normalizedFullName);
        user.setEmail(normalizedEmail);
        user.setPhone(normalizedPhone);

        String passwordHash = PasswordUtil.hash(password);
        int generatedId = userDAO.insertCustomer(user, passwordHash);

        user.setUserId(generatedId);
        user.setRole("CUSTOMER");
        user.setStatus("ACTIVE");
        return user;
    }

    
    public User login(String email, String password) throws SQLException {
        String normalizedEmail = trimRequired(email, "Vui lòng nhập email.").toLowerCase();
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập mật khẩu.");
        }

        Optional<User> maybeUser = userDAO.findByEmail(normalizedEmail);
        if (maybeUser.isEmpty()) {
            throw new IllegalArgumentException("Email hoặc mật khẩu không đúng.");
        }

        User user = maybeUser.get();

        if (user.getLockedUntil() != null && user.getLockedUntil().isAfter(LocalDateTime.now())) {
            throw new IllegalStateException(
                    "Tài khoản đang tạm khóa do đăng nhập sai quá nhiều lần. Vui lòng thử lại sau.");
        }

        if (!PasswordUtil.matches(password, user.getPasswordHash())) {
            handleFailedAttempt(user);
            throw new IllegalArgumentException("Email hoặc mật khẩu không đúng.");
        }

        if ("LOCKED".equals(user.getStatus()) || "SUSPENDED".equals(user.getStatus())) {
            throw new IllegalStateException("Tài khoản này đang bị khóa hoặc tạm ngưng.");
        }
        if ("INACTIVE".equals(user.getStatus())) {
            throw new IllegalStateException("Tài khoản này chưa được kích hoạt.");
        }

        userDAO.recordLoginSuccess(user.getUserId());
        user.setPasswordHash(null);
        return user;
    }

   
    public void changePassword(int userId, String currentPassword, String newPassword, String confirmNewPassword)
            throws SQLException {
        if (currentPassword == null || currentPassword.isEmpty()) {
            throw new IllegalArgumentException("Vui lòng nhập mật khẩu hiện tại.");
        }
        if (newPassword == null || newPassword.length() < 8) {
            throw new IllegalArgumentException("Mật khẩu mới phải có ít nhất 8 ký tự.");
        }
        if (!newPassword.equals(confirmNewPassword)) {
            throw new IllegalArgumentException("Xác nhận mật khẩu mới không khớp.");
        }

        Optional<String> currentHash = userDAO.findPasswordHashById(userId);
        if (currentHash.isEmpty() || currentHash.get() == null) {
            throw new IllegalStateException("Không tìm thấy tài khoản hoặc tài khoản chưa đặt mật khẩu.");
        }
        if (!PasswordUtil.matches(currentPassword, currentHash.get())) {
            throw new IllegalArgumentException("Mật khẩu hiện tại không đúng.");
        }
        if (PasswordUtil.matches(newPassword, currentHash.get())) {
            throw new IllegalArgumentException("Mật khẩu mới phải khác mật khẩu hiện tại.");
        }

        String newHash = PasswordUtil.hash(newPassword);
        userDAO.updatePasswordHash(userId, newHash);
    }

    private void handleFailedAttempt(User user) throws SQLException {
        int failedCount = user.getFailedLoginCount() + 1;
        LocalDateTime lockedUntil = null;
        if (failedCount >= MAX_FAILED_ATTEMPTS) {
            lockedUntil = LocalDateTime.now().plusMinutes(LOCK_MINUTES);
        }
        userDAO.recordLoginFailure(user.getUserId(), failedCount, lockedUntil);
    }

    private String trimRequired(String value, String errorMessage) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException(errorMessage);
        }
        return value.trim();
    }

    private String normalizeOptional(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
