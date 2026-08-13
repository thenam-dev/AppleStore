package service;

import dao.user.UserDAO;
import model.entity.user.User;
import util.PasswordUtil;

import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.Optional;
import java.util.regex.Pattern;

/**
 * Business rules for the customer register/login flow. Keeps the same
 * validate-then-persist convention as {@link UserService}.
 */
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

    /**
     * Creates a new customer account.
     *
     * @return the created user (without the password hash populated)
     */
    public User register(String fullName, String email, String phone, String password, String confirmPassword)
            throws SQLException {
        String normalizedFullName = trimRequired(fullName, "Full name is required.");
        String normalizedEmail = trimRequired(email, "Email is required.").toLowerCase();
        String normalizedPhone = normalizeOptional(phone);

        if (normalizedFullName.length() > 100) {
            throw new IllegalArgumentException("Full name must be 100 characters or less.");
        }
        if (!EMAIL_PATTERN.matcher(normalizedEmail).matches() || normalizedEmail.length() > 255) {
            throw new IllegalArgumentException("Email is invalid.");
        }
        if (normalizedPhone != null && !PHONE_PATTERN.matcher(normalizedPhone).matches()) {
            throw new IllegalArgumentException("Phone must contain 9 to 15 digits.");
        }
        if (password == null || password.length() < 8) {
            throw new IllegalArgumentException("Password must be at least 8 characters.");
        }
        if (!password.equals(confirmPassword)) {
            throw new IllegalArgumentException("Password confirmation does not match.");
        }
        if (userDAO.existsByEmail(normalizedEmail)) {
            throw new IllegalArgumentException("This email is already registered.");
        }
        if (userDAO.existsByPhone(normalizedPhone)) {
            throw new IllegalArgumentException("This phone number is already registered.");
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

    /**
     * Authenticates a customer/staff login attempt.
     *
     * @return the authenticated user (without the password hash populated)
     */
    public User login(String email, String password) throws SQLException {
        String normalizedEmail = trimRequired(email, "Email is required.").toLowerCase();
        if (password == null || password.isEmpty()) {
            throw new IllegalArgumentException("Password is required.");
        }

        Optional<User> maybeUser = userDAO.findByEmail(normalizedEmail);
        if (maybeUser.isEmpty()) {
            throw new IllegalArgumentException("Email or password is incorrect.");
        }

        User user = maybeUser.get();

        if (user.getLockedUntil() != null && user.getLockedUntil().isAfter(LocalDateTime.now())) {
            throw new IllegalStateException(
                    "This account is temporarily locked due to too many failed login attempts. Please try again later.");
        }

        if (!PasswordUtil.matches(password, user.getPasswordHash())) {
            handleFailedAttempt(user);
            throw new IllegalArgumentException("Email or password is incorrect.");
        }

        if ("LOCKED".equals(user.getStatus()) || "SUSPENDED".equals(user.getStatus())) {
            throw new IllegalStateException("This account has been " + user.getStatus().toLowerCase() + ".");
        }
        if ("INACTIVE".equals(user.getStatus())) {
            throw new IllegalStateException("This account is not active yet.");
        }

        userDAO.recordLoginSuccess(user.getUserId());
        user.setPasswordHash(null);
        return user;
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
