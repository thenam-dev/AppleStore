package dao.catalog;

import model.entity.catalog.Category;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class CategoryDAO {

    private static final String CATEGORY_COLUMNS = """
            category_id, name, slug, display_order, is_active
            """;

    public List<Category> findAll() throws SQLException {
        String sql = "SELECT " + CATEGORY_COLUMNS + " FROM categories ORDER BY display_order ASC, category_id ASC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            List<Category> categories = new ArrayList<>();
            while (resultSet.next()) {
                categories.add(mapCategory(resultSet));
            }
            return categories;
        }
    }

    public List<Category> findAll(int page, int pageSize) throws SQLException {
        String sql = """
                SELECT
                    """ + CATEGORY_COLUMNS + """
                FROM categories
                ORDER BY display_order ASC, category_id ASC
                LIMIT ? OFFSET ?
                """;

        int offset = Math.max(0, (page - 1) * pageSize);

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, pageSize);
            statement.setInt(2, offset);

            try (ResultSet resultSet = statement.executeQuery()) {
                List<Category> categories = new ArrayList<>();
                while (resultSet.next()) {
                    categories.add(mapCategory(resultSet));
                }
                return categories;
            }
        }
    }

    public int countAll() throws SQLException {
        String sql = "SELECT COUNT(*) FROM categories";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            if (resultSet.next()) {
                return resultSet.getInt(1);
            }
            return 0;
        }
    }

    public List<Category> findAllActive() throws SQLException {
        String sql = """
                SELECT
                    """ + CATEGORY_COLUMNS + """
                FROM categories
                WHERE is_active = 1
                ORDER BY display_order ASC, category_id ASC
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql);
             ResultSet resultSet = statement.executeQuery()) {
            List<Category> categories = new ArrayList<>();
            while (resultSet.next()) {
                categories.add(mapCategory(resultSet));
            }
            return categories;
        }
    }

    public Optional<Category> findById(int categoryId) throws SQLException {
        String sql = "SELECT " + CATEGORY_COLUMNS + " FROM categories WHERE category_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, categoryId);

            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapCategory(resultSet));
                }
                return Optional.empty();
            }
        }
    }

    public int insert(Category category) throws SQLException {
        String sql = """
                INSERT INTO categories (name, slug, display_order, is_active)
                VALUES (?, ?, ?, ?)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setString(1, category.getName());
            statement.setString(2, category.getSlug());
            statement.setInt(3, category.getDisplayOrder());
            statement.setBoolean(4, category.getIsActive());
            statement.executeUpdate();

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated category id.");
            }
        }
    }

    public boolean update(Category category) throws SQLException {
        String sql = """
                UPDATE categories
                SET name = ?, slug = ?, display_order = ?, is_active = ?
                WHERE category_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, category.getName());
            statement.setString(2, category.getSlug());
            statement.setInt(3, category.getDisplayOrder());
            statement.setBoolean(4, category.getIsActive());
            statement.setInt(5, category.getCategoryId());
            return statement.executeUpdate() > 0;
        }
    }

    public boolean existsByName(String name) throws SQLException {
        String sql = "SELECT 1 FROM categories WHERE name = ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, name);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public boolean existsBySlug(String slug) throws SQLException {
        String sql = "SELECT 1 FROM categories WHERE slug = ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, slug);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public boolean existsByNameForOtherCategory(String name, int categoryId) throws SQLException {
        String sql = "SELECT 1 FROM categories WHERE name = ? AND category_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, name);
            statement.setInt(2, categoryId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public boolean existsBySlugForOtherCategory(String slug, int categoryId) throws SQLException {
        String sql = "SELECT 1 FROM categories WHERE slug = ? AND category_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, slug);
            statement.setInt(2, categoryId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private Category mapCategory(ResultSet resultSet) throws SQLException {
        Category category = new Category();
        category.setCategoryId(resultSet.getInt("category_id"));
        category.setName(resultSet.getString("name"));
        category.setSlug(resultSet.getString("slug"));
        category.setDisplayOrder(resultSet.getInt("display_order"));
        category.setIsActive(resultSet.getBoolean("is_active"));
        return category;
    }
}
