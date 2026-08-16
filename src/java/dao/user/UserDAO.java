package dao.user;

import model.entity.user.User;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class UserDAO {

    private static final String USER_COLUMNS = """
            user_id, full_name, email, phone, role, status, avatar_url, auth_provider,
            google_id, is_email_verified, failed_login_count, locked_until, created_at, updated_at
            """;

    /** Lấy danh sách user theo keyword, role, status, sort và phân trang. */
    public List<User> findAll(String keyword, String role, String status, String sort, int page, int pageSize)
            throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT ")
                .append(USER_COLUMNS)
                .append(" FROM users WHERE 1 = 1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, role, status);
        sql.append(" ORDER BY ").append(resolveOrderBy(sort)).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet resultSet = statement.executeQuery()) {
                List<User> users = new ArrayList<>();
                while (resultSet.next()) {
                    users.add(mapUser(resultSet));
                }
                return users;
            }
        }
    }

    /** Đếm user sau khi áp dụng bộ lọc keyword, role và status. */
    public int countAll(String keyword, String role, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users WHERE 1 = 1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, role, status);

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
                return 0;
            }
        }
    }

    /** Tìm user theo ID, trả về Optional.empty nếu không tồn tại. */
    public Optional<User> findById(int userId) throws SQLException {
        String sql = "SELECT " + USER_COLUMNS + " FROM users WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapUser(resultSet));
                }
                return Optional.empty();
            }
        }
    }

    /** Cập nhật thông tin quản trị của user theo user_id. */
    public boolean update(User user) throws SQLException {
        String sql = """
                UPDATE users
                SET full_name = ?, email = ?, phone = ?, role = ?, status = ?, is_email_verified = ?
                WHERE user_id = ?
                """;

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, user.getFullName());
            statement.setString(2, user.getEmail());
            statement.setString(3, emptyToNull(user.getPhone()));
            statement.setString(4, user.getRole());
            statement.setString(5, user.getStatus());
            statement.setBoolean(6, user.isEmailVerified());
            statement.setInt(7, user.getUserId());
            return statement.executeUpdate() > 0;
        }
    }

    /** Cập nhật riêng trạng thái tài khoản user. */
    public boolean updateStatus(int userId, String status) throws SQLException {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setInt(2, userId);
            return statement.executeUpdate() > 0;
        }
    }

    /** Tìm user theo email, dùng cho đăng nhập và kiểm tra trùng email. */
    public Optional<User> findByEmail(String email) throws SQLException {
        String sql = "SELECT " + USER_COLUMNS + ", password_hash FROM users WHERE email = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    User user = mapUser(resultSet);
                    user.setPasswordHash(resultSet.getString("password_hash"));
                    return Optional.of(user);
                }
                return Optional.empty();
            }
        }
    }

    /** Kiểm tra email đã tồn tại hay chưa. */
    public boolean existsByEmail(String email) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Kiểm tra số điện thoại đã tồn tại hay chưa. */
    public boolean existsByPhone(String phone) throws SQLException {
        if (phone == null || phone.isBlank()) {
            return false;
        }

        String sql = "SELECT 1 FROM users WHERE phone = ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, phone.trim());
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Tạo tài khoản customer mới và trả về user_id được sinh ra. */
    public int insertCustomer(User user, String passwordHash) throws SQLException {
        String sql = """
                INSERT INTO users (full_name, email, password_hash, phone, role, status, is_email_verified)
                VALUES (?, ?, ?, ?, 'CUSTOMER', 'ACTIVE', 0)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, user.getFullName());
            statement.setString(2, user.getEmail());
            statement.setString(3, passwordHash);
            statement.setString(4, emptyToNull(user.getPhone()));
            statement.executeUpdate();

            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated user id.");
            }
        }
    }

    /** Ghi nhận đăng nhập thành công và reset số lần đăng nhập sai. */
    public void recordLoginSuccess(int userId) throws SQLException {
        String sql = "UPDATE users SET failed_login_count = 0, locked_until = NULL WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            statement.executeUpdate();
        }
    }

    /** Ghi nhận đăng nhập thất bại, tăng số lần sai và khóa tạm nếu cần. */
    public void recordLoginFailure(int userId, int failedLoginCount, LocalDateTime lockedUntil) throws SQLException {
        String sql = "UPDATE users SET failed_login_count = ?, locked_until = ? WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, failedLoginCount);
            statement.setTimestamp(2, lockedUntil == null ? null : Timestamp.valueOf(lockedUntil));
            statement.setInt(3, userId);
            statement.executeUpdate();
        }
    }

    /** Kiểm tra email có trùng với user khác khi cập nhật hay không. */
    public boolean existsByEmailForOtherUser(String email, int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ? AND user_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Kiểm tra số điện thoại có trùng với user khác khi cập nhật hay không. */
    public boolean existsByPhoneForOtherUser(String phone, int userId) throws SQLException {
        if (phone == null || phone.isBlank()) {
            return false;
        }

        String sql = "SELECT 1 FROM users WHERE phone = ? AND user_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, phone.trim());
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    /** Bind danh sách tham số vào PreparedStatement theo đúng thứ tự đã build SQL. */
    private void bindParams(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            statement.setObject(i + 1, params.get(i));
        }
    }

    /** Gắn điều kiện keyword, role và status vào SQL động. */
    private void appendFilters(StringBuilder sql, List<Object> params, String keyword, String role, String status) {
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(full_name) LIKE ? OR LOWER(email) LIKE ? OR phone LIKE ?)");
            String normalizedKeyword = keyword.trim();
            String likeKeyword = "%" + normalizedKeyword.toLowerCase() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add("%" + normalizedKeyword + "%");
        }

        if (role != null && !role.isBlank()) {
            sql.append(" AND role = ?");
            params.add(role.trim().toUpperCase());
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND status = ?");
            params.add(status.trim().toUpperCase());
        }
    }

    /** Chuyển sort key thành ORDER BY cố định để tránh SQL động không kiểm soát. */
    private String resolveOrderBy(String sort) {
        if ("name_asc".equals(sort)) {
            return "full_name ASC, user_id ASC";
        }
        if ("email_asc".equals(sort)) {
            return "email ASC, user_id ASC";
        }
        if ("role_asc".equals(sort)) {
            return "role ASC, full_name ASC";
        }
        if ("status_asc".equals(sort)) {
            return "status ASC, full_name ASC";
        }
        if ("created_asc".equals(sort)) {
            return "created_at ASC, user_id ASC";
        }
        return "created_at DESC, user_id DESC";
    }

    /** Map một dòng ResultSet thành entity User. */
    private User mapUser(ResultSet resultSet) throws SQLException {
        User user = new User();
        user.setUserId(resultSet.getInt("user_id"));
        user.setFullName(resultSet.getString("full_name"));
        user.setEmail(resultSet.getString("email"));
        user.setPhone(resultSet.getString("phone"));
        user.setRole(resultSet.getString("role"));
        user.setStatus(resultSet.getString("status"));
        user.setAvatarUrl(resultSet.getString("avatar_url"));
        user.setAuthProvider(resultSet.getString("auth_provider"));
        user.setGoogleId(resultSet.getString("google_id"));
        user.setEmailVerified(resultSet.getBoolean("is_email_verified"));
        user.setFailedLoginCount(resultSet.getInt("failed_login_count"));
        user.setLockedUntil(toLocalDateTime(resultSet.getTimestamp("locked_until")));
        user.setCreatedAt(toLocalDateTime(resultSet.getTimestamp("created_at")));
        user.setUpdatedAt(toLocalDateTime(resultSet.getTimestamp("updated_at")));
        return user;
    }

    /** Chuyển Timestamp từ JDBC sang LocalDateTime cho entity. */
    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toLocalDateTime();
    }

    /** Chuyển chuỗi rỗng thành null trước khi bind vào database. */
    private String emptyToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
