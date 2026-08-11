package dao;

import model.User;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class UserDAO {
    private static final String USER_COLUMNS = """
            user_id, full_name, email, phone, role, status, avatar_url, auth_provider,
            google_id, is_email_verified, failed_login_count, locked_until, created_at, updated_at
            """;

    public List<User> findAll(String keyword, String role, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT ")
                .append(USER_COLUMNS)
                .append(" FROM users WHERE 1 = 1");
        List<Object> params = new ArrayList<>();

        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(full_name) LIKE ? OR LOWER(email) LIKE ? OR phone LIKE ?)");
            String likeKeyword = "%" + keyword.trim().toLowerCase() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add("%" + keyword.trim() + "%");
        }

        if (role != null && !role.isBlank()) {
            sql.append(" AND role = ?");
            params.add(role.trim().toUpperCase());
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND status = ?");
            params.add(status.trim().toUpperCase());
        }

        sql.append(" ORDER BY user_id DESC");

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

    public Optional<User> findById(int userId) throws SQLException {
        String sql = "SELECT " + USER_COLUMNS + " FROM users WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapUser(resultSet));
                }
                return Optional.empty();
            }
        }
    }

    public boolean update(User user) throws SQLException {
        String sql = """
                UPDATE users
                SET full_name = ?, email = ?, phone = ?, role = ?, status = ?, is_email_verified = ?
                WHERE user_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
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

    public boolean updateStatus(int userId, String status) throws SQLException {
        String sql = "UPDATE users SET status = ? WHERE user_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setInt(2, userId);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean existsByEmailForOtherUser(String email, int userId) throws SQLException {
        String sql = "SELECT 1 FROM users WHERE email = ? AND user_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, email);
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public boolean existsByPhoneForOtherUser(String phone, int userId) throws SQLException {
        if (phone == null || phone.isBlank()) {
            return false;
        }

        String sql = "SELECT 1 FROM users WHERE phone = ? AND user_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, phone.trim());
            statement.setInt(2, userId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private void bindParams(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            statement.setObject(i + 1, params.get(i));
        }
    }

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

    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toLocalDateTime();
    }

    private String emptyToNull(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim();
    }
}
