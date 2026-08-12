package service.user;

import config.AppConfig;
import dao.user.UserDAO;
import model.entity.user.User;

import java.sql.SQLException;
import java.util.List;
import java.util.regex.Pattern;

public class UserService {

    private static final List<String> ALLOWED_ROLES = List.of(
            AppConfig.ROLE_CUSTOMER,
            AppConfig.ROLE_ADMIN,
            AppConfig.ROLE_SALE_STAFF,
            AppConfig.ROLE_DELIVERY
    );
    private static final List<String> ALLOWED_STATUSES = List.of("ACTIVE", "INACTIVE", "LOCKED", "SUSPENDED");
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9]{9,15}$");

    private final UserDAO userDAO;

    public UserService() {
        this(new UserDAO());
    }

    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    public List<User> getUsers(String keyword, String role, String status) throws SQLException {
        String normalizedRole = normalizeOptional(role);
        String normalizedStatus = normalizeOptional(status);

        if (normalizedRole != null && !ALLOWED_ROLES.contains(normalizedRole)) {
            throw new IllegalArgumentException("Role filter is invalid.");
        }
        if (normalizedStatus != null && !ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Status filter is invalid.");
        }

        return userDAO.findAll(keyword, normalizedRole, normalizedStatus);
    }

    public User getUserById(int userId) throws SQLException {
        return userDAO.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("User does not exist."));
    }

    public void updateUser(User user) throws SQLException {
        normalizeUser(user);
        validateUser(user);

        if (userDAO.existsByEmailForOtherUser(user.getEmail(), user.getUserId())) {
            throw new IllegalArgumentException("Email is already used by another account.");
        }

        if (userDAO.existsByPhoneForOtherUser(user.getPhone(), user.getUserId())) {
            throw new IllegalArgumentException("Phone is already used by another account.");
        }

        if (!userDAO.update(user)) {
            throw new IllegalArgumentException("User does not exist.");
        }
    }

    public void changeStatus(int userId, String status) throws SQLException {
        String normalizedStatus = normalizeRequired(status);
        if (!ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Status is invalid.");
        }

        if (!userDAO.updateStatus(userId, normalizedStatus)) {
            throw new IllegalArgumentException("User does not exist.");
        }
    }

    public List<String> getAllowedRoles() {
        return ALLOWED_ROLES;
    }

    public List<String> getAllowedStatuses() {
        return ALLOWED_STATUSES;
    }

    private void normalizeUser(User user) {
        user.setFullName(trimRequired(user.getFullName()));
        user.setEmail(trimRequired(user.getEmail()).toLowerCase());
        user.setPhone(normalizeOptional(user.getPhone()));
        user.setRole(normalizeRequired(user.getRole()));
        user.setStatus(normalizeRequired(user.getStatus()));
    }

    private void validateUser(User user) {
        if (user.getUserId() <= 0) {
            throw new IllegalArgumentException("User id is invalid.");
        }
        if (user.getFullName().length() > 100) {
            throw new IllegalArgumentException("Full name must be 100 characters or less.");
        }
        if (!EMAIL_PATTERN.matcher(user.getEmail()).matches() || user.getEmail().length() > 255) {
            throw new IllegalArgumentException("Email is invalid.");
        }
        if (user.getPhone() != null && !PHONE_PATTERN.matcher(user.getPhone()).matches()) {
            throw new IllegalArgumentException("Phone must contain 9 to 15 digits.");
        }
        if (!ALLOWED_ROLES.contains(user.getRole())) {
            throw new IllegalArgumentException("Role is invalid.");
        }
        if (!ALLOWED_STATUSES.contains(user.getStatus())) {
            throw new IllegalArgumentException("Status is invalid.");
        }
    }

    private String normalizeRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Required value is missing.");
        }
        return value.trim().toUpperCase();
    }

    private String trimRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Required value is missing.");
        }
        return value.trim();
    }

    private String normalizeOptional(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim().toUpperCase();
    }
}
