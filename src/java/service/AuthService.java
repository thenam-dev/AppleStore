package service;

import dao.user.UserDAO;
import model.entity.user.User;
import util.PasswordUtil;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Pattern;

/**
 * Xử lý nghiệp vụ cho luồng authenticate: đăng ký, đăng nhập, đổi mật khẩu.
 * Theo cùng pattern Result object với {@link service.cart.CheckoutService}
 * (success/message/fieldErrors) để các JSP hiển thị lỗi theo từng ô.
 */
public class AuthService {
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^0\\d{9}$");
    private static final int MAX_FAILED_ATTEMPTS = 5;
    private static final int LOCK_MINUTES = 15;

    private final UserDAO userDAO;

    public AuthService() {
        this(new UserDAO());
    }

    public AuthService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public static class RegisterResult {
        public boolean success;
        public String message;
        public Map<String, String> fieldErrors = new HashMap<>();
    }

    public static class LoginResult {
        public boolean success;
        public String message;
        public Integer attemptsLeft;
        public User user;
    }

    public static class ChangePasswordResult {
        public boolean success;
        public String message;
        public Map<String, String> fieldErrors = new HashMap<>();
    }

    /** Validate + kiểm tra trùng email/SĐT. */
    private Map<String, String> validateRegistration(String fullName, String email, String phone,
                                                       String password, String confirmPassword) throws SQLException {
        Map<String, String> errors = new HashMap<>();

        String normalizedFullName = fullName == null ? "" : fullName.trim();
        if (normalizedFullName.isEmpty()) {
            errors.put("fullName", "Vui lòng nhập họ và tên.");
        } else if (normalizedFullName.length() > 100) {
            errors.put("fullName", "Họ và tên tối đa 100 ký tự.");
        }

        String normalizedPhone = phone == null ? "" : phone.trim();
        if (normalizedPhone.isEmpty()) {
            errors.put("phone", "Vui lòng nhập số điện thoại.");
        } else if (!PHONE_PATTERN.matcher(normalizedPhone).matches()) {
            errors.put("phone", "Số điện thoại không đúng định dạng (10 số, bắt đầu bằng 0).");
        } else if (userDAO.existsByPhone(normalizedPhone)) {
            errors.put("phone", "Số điện thoại này đã được sử dụng.");
        }

        String normalizedEmail = email == null ? "" : email.trim().toLowerCase();
        if (normalizedEmail.isEmpty()) {
            errors.put("email", "Vui lòng nhập email.");
        } else if (!EMAIL_PATTERN.matcher(normalizedEmail).matches() || normalizedEmail.length() > 100) {
            errors.put("email", "Email không đúng định dạng.");
        } else if (userDAO.existsByEmail(normalizedEmail)) {
            errors.put("email", "Email này đã được đăng ký.");
        }

        if (password == null || password.length() < 8) {
            errors.put("password", "Mật khẩu phải có ít nhất 8 ký tự.");
        } else if (!password.matches(".*[A-Za-z].*") || !password.matches(".*\\d.*")) {
            errors.put("password", "Mật khẩu phải có cả chữ và số.");
        }

        if (confirmPassword == null || !confirmPassword.equals(password)) {
            errors.put("confirmPassword", "Xác nhận mật khẩu không khớp.");
        }

        return errors;
    }

    public RegisterResult register(String fullName, String email, String phone, String password, String confirmPassword)
            throws SQLException {
        RegisterResult result = new RegisterResult();
        result.fieldErrors = validateRegistration(fullName, email, phone, password, confirmPassword);

        if (!result.fieldErrors.isEmpty()) {
            result.success = false;
            result.message = "Vui lòng kiểm tra lại thông tin.";
            return result;
        }

        User user = new User();
        user.setFullName(fullName.trim());
        user.setEmail(email.trim().toLowerCase());
        user.setPhone(phone.trim());

        String passwordHash = PasswordUtil.hash(password);
        userDAO.insertCustomer(user, passwordHash);

        result.success = true;
        result.message = "Tạo tài khoản thành công.";
        return result;
    }

    public LoginResult login(String email, String password) throws SQLException {
        LoginResult result = new LoginResult();
        String normalizedEmail = email == null ? "" : email.trim().toLowerCase();

        if (normalizedEmail.isEmpty() || password == null || password.isEmpty()) {
            result.success = false;
            result.message = "Vui lòng nhập email và mật khẩu.";
            return result;
        }

        Optional<User> userOptional = userDAO.findByEmail(normalizedEmail);
        if (userOptional.isEmpty()) {
            result.success = false;
            result.message = "Email hoặc mật khẩu không đúng.";
            return result;
        }

        User user = userOptional.get();

        if (user.getLockedUntil() != null && user.getLockedUntil().isAfter(LocalDateTime.now())) {
            result.success = false;
            result.message = "Tài khoản đang bị khóa tạm thời, vui lòng thử lại sau.";
            return result;
        }

        if (user.getPasswordHash() == null || !PasswordUtil.matches(password, user.getPasswordHash())) {
            int failedCount = user.getFailedLoginCount() + 1;
            LocalDateTime lockedUntil = null;
            if (failedCount >= MAX_FAILED_ATTEMPTS) {
                lockedUntil = LocalDateTime.now().plusMinutes(LOCK_MINUTES);
                failedCount = 0;
            }
            userDAO.recordLoginFailure(user.getUserId(), failedCount, lockedUntil);

            result.success = false;
            result.message = "Email hoặc mật khẩu không đúng.";
            result.attemptsLeft = (lockedUntil == null) ? Math.max(0, MAX_FAILED_ATTEMPTS - failedCount) : null;
            return result;
        }

        if (!"ACTIVE".equalsIgnoreCase(user.getStatus())) {
            result.success = false;
            result.message = "Tài khoản chưa được kích hoạt hoặc đã bị khóa. Vui lòng liên hệ hỗ trợ.";
            return result;
        }

        userDAO.recordLoginSuccess(user.getUserId());
        user.setFailedLoginCount(0);
        user.setLockedUntil(null);
        user.setPasswordHash(null);

        result.success = true;
        result.user = user;
        return result;
    }

    public ChangePasswordResult changePassword(int userId, String currentPassword, String newPassword,
                                                String confirmNewPassword) throws SQLException {
        ChangePasswordResult result = new ChangePasswordResult();
        Map<String, String> errors = new HashMap<>();

        Optional<String> currentHashOptional = userDAO.findPasswordHashById(userId);
        String currentHash = currentHashOptional.orElse(null);

        if (currentPassword == null || currentPassword.isEmpty()) {
            errors.put("currentPassword", "Vui lòng nhập mật khẩu hiện tại.");
        } else if (currentHash == null || !PasswordUtil.matches(currentPassword, currentHash)) {
            errors.put("currentPassword", "Mật khẩu hiện tại không đúng.");
        }

        if (newPassword == null || newPassword.length() < 8) {
            errors.put("newPassword", "Mật khẩu mới phải có ít nhất 8 ký tự.");
        } else if (currentHash != null && PasswordUtil.matches(newPassword, currentHash)) {
            errors.put("newPassword", "Mật khẩu mới phải khác mật khẩu hiện tại.");
        }

        if (confirmNewPassword == null || !confirmNewPassword.equals(newPassword)) {
            errors.put("confirmNewPassword", "Xác nhận mật khẩu mới không khớp.");
        }

        if (!errors.isEmpty()) {
            result.success = false;
            result.message = "Vui lòng kiểm tra lại thông tin.";
            result.fieldErrors = errors;
            return result;
        }

        userDAO.updatePasswordHash(userId, PasswordUtil.hash(newPassword));
        result.success = true;
        result.message = "Đổi mật khẩu thành công.";
        return result;
    }
}