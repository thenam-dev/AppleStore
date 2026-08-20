package dao.catalog;

import model.entity.catalog.ProductImage;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ProductImageDAO {
    private static final String COLUMNS = "pi.image_id, pi.product_id, pi.file_path, pi.display_order, pi.is_primary, pi.uploaded_at";

    public List<ProductImage> findByProductId(int productId) throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM product_images pi "
                + "WHERE pi.product_id = ? ORDER BY pi.display_order, pi.image_id";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                List<ProductImage> images = new ArrayList<>();
                while (resultSet.next()) images.add(mapRow(resultSet));
                return images;
            }
        }
    }

    public int countByProductId(int productId) throws SQLException {
        return count("SELECT COUNT(*) FROM product_images WHERE product_id = ?", productId);
    }

    public int countByFilePath(String filePath) throws SQLException {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "SELECT COUNT(*) FROM product_images WHERE file_path = ?")) {
            statement.setString(1, filePath);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt(1);
            }
        }
    }

    public Optional<ProductImage> findById(int imageId) throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM product_images pi WHERE pi.image_id = ?";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, imageId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? Optional.of(mapRow(resultSet)) : Optional.empty();
            }
        }
    }

    public Optional<ProductImage> findFirstByProductId(int productId) throws SQLException {
        String sql = "SELECT " + COLUMNS + " FROM product_images pi "
                + "WHERE pi.product_id = ? ORDER BY pi.display_order, pi.image_id LIMIT 1";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? Optional.of(mapRow(resultSet)) : Optional.empty();
            }
        }
    }

    public int insert(ProductImage image) throws SQLException {
        String sql = "INSERT INTO product_images (product_id, file_path, display_order, is_primary) VALUES (?, ?, ?, ?)";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, image.getProductId());
            statement.setString(2, image.getFilePath());
            statement.setInt(3, image.getDisplayOrder());
            statement.setBoolean(4, image.isPrimary());
            statement.executeUpdate();
            try (ResultSet keys = statement.getGeneratedKeys()) {
                if (keys.next()) return keys.getInt(1);
            }
        }
        throw new SQLException("Không lấy được ID ảnh sản phẩm.");
    }

    public void insertBatch(List<ProductImage> images) throws SQLException {
        if (images == null || images.isEmpty()) {
            return;
        }

        String sql = "INSERT INTO product_images (product_id, file_path, display_order, is_primary) "
                + "VALUES (?, ?, ?, ?)";
        try (Connection connection = DBConnection.getConnection()) {
            boolean originalAutoCommit = connection.getAutoCommit();
            try {
                connection.setAutoCommit(false);
                try (PreparedStatement statement = connection.prepareStatement(sql)) {
                    for (ProductImage image : images) {
                        statement.setInt(1, image.getProductId());
                        statement.setString(2, image.getFilePath());
                        statement.setInt(3, image.getDisplayOrder());
                        statement.setBoolean(4, image.isPrimary());
                        statement.addBatch();
                    }
                    statement.executeBatch();
                }
                connection.commit();
            } catch (SQLException ex) {
                try {
                    connection.rollback();
                } catch (SQLException rollbackEx) {
                    ex.addSuppressed(rollbackEx);
                }
                throw ex;
            } finally {
                connection.setAutoCommit(originalAutoCommit);
            }
        }
    }

    public boolean delete(int imageId) throws SQLException {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(
                     "DELETE FROM product_images WHERE image_id = ?")) {
            statement.setInt(1, imageId);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean setPrimary(int productId, int imageId) throws SQLException {
        try (Connection connection = DBConnection.getConnection()) {
            boolean autoCommit = connection.getAutoCommit();
            connection.setAutoCommit(false);
            try (PreparedStatement reset = connection.prepareStatement(
                    "UPDATE product_images SET is_primary = 0 WHERE product_id = ?");
                 PreparedStatement set = connection.prepareStatement(
                    "UPDATE product_images SET is_primary = 1 WHERE product_id = ? AND image_id = ?")) {
                reset.setInt(1, productId);
                reset.executeUpdate();
                set.setInt(1, productId);
                set.setInt(2, imageId);
                boolean updated = set.executeUpdate() > 0;
                connection.commit();
                return updated;
            } catch (SQLException ex) {
                connection.rollback();
                throw ex;
            } finally {
                connection.setAutoCommit(autoCommit);
            }
        }
    }

    private int count(String sql, int productId) throws SQLException {
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt(1);
            }
        }
    }

    private ProductImage mapRow(ResultSet resultSet) throws SQLException {
        ProductImage image = new ProductImage();
        image.setImageId(resultSet.getInt("image_id"));
        image.setProductId(resultSet.getInt("product_id"));
        image.setFilePath(resultSet.getString("file_path"));
        image.setDisplayOrder(resultSet.getInt("display_order"));
        image.setPrimary(resultSet.getBoolean("is_primary"));
        Timestamp uploadedAt = resultSet.getTimestamp("uploaded_at");
        image.setUploadedAt(uploadedAt == null ? null : uploadedAt.toLocalDateTime());
        return image;
    }
}
