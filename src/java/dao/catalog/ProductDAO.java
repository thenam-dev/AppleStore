package dao.catalog;

import model.entity.catalog.Product;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public class ProductDAO {

    private static final String PRODUCT_COLUMNS = """
            p.product_id, p.created_by, p.category_id, c.name AS category_name,
            p.name, p.description, p.brand, p.model_code, p.release_year, p.product_condition,
            p.import_type, p.origin_country, p.warranty_months, p.warranty_provider,
            p.status, p.view_count, p.rating, p.sold_quantity, p.is_featured,
            p.created_at, p.updated_at, vs.min_price, COALESCE(vs.total_stock, 0) AS total_stock,
            COALESCE(vs.variant_count, 0) AS variant_count,
            pi.file_path AS primary_image_url
            """;

    private static final String PRODUCT_FROM = """
            FROM products p
            JOIN categories c ON c.category_id = p.category_id
            LEFT JOIN (
                SELECT
                    product_id,
                    MIN(CASE WHEN is_active = 1 THEN price END) AS min_price,
                    SUM(CASE WHEN is_active = 1 THEN stock_quantity ELSE 0 END) AS total_stock,
                    COUNT(*) AS variant_count
                FROM product_variants
                GROUP BY product_id
            ) vs ON vs.product_id = p.product_id
            LEFT JOIN product_images pi ON pi.product_id = p.product_id AND pi.is_primary = 1
            WHERE 1 = 1
            """;

    public List<Product> findAll(String keyword, Integer categoryId, String status, String sort, int page, int pageSize)
            throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT ")
                .append(PRODUCT_COLUMNS)
                .append(' ')
                .append(PRODUCT_FROM);
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, keyword, categoryId, status);
        sql.append(" ORDER BY ").append(resolveOrderBy(sort)).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet resultSet = statement.executeQuery()) {
                List<Product> products = new ArrayList<>();
                while (resultSet.next()) {
                    products.add(mapProduct(resultSet));
                }
                return products;
            }
        }
    }

    public int countAll(String keyword, Integer categoryId, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM products p WHERE 1 = 1");
        List<Object> params = new ArrayList<>();
        appendBaseFilters(sql, params, keyword, categoryId, status);

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
                return 0;
            }
        }
    }

    public Optional<Product> findById(int productId) throws SQLException {
        String sql = "SELECT " + PRODUCT_COLUMNS + ' ' + PRODUCT_FROM + " AND p.product_id = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapProduct(resultSet));
                }
                return Optional.empty();
            }
        }
    }

    public int insert(Product product) throws SQLException {
        String sql = """
                INSERT INTO products (
                    created_by, category_id, name, description, brand, model_code, release_year,
                    product_condition, import_type, origin_country, warranty_months, warranty_provider,
                    status, is_featured
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setProductMutationParams(statement, product);
            statement.executeUpdate();

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated product id.");
            }
        }
    }

    public boolean update(Product product) throws SQLException {
        String sql = """
                UPDATE products
                SET category_id = ?, name = ?, description = ?, brand = ?, model_code = ?, release_year = ?,
                    product_condition = ?, import_type = ?, origin_country = ?, warranty_months = ?,
                    warranty_provider = ?, status = ?, is_featured = ?
                WHERE product_id = ?
                """;

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, product.getCategoryId());
            statement.setString(2, product.getName());
            statement.setString(3, product.getDescription());
            statement.setString(4, product.getBrand());
            setNullableString(statement, 5, product.getModelCode());
            setNullableInteger(statement, 6, product.getReleaseYear());
            statement.setString(7, product.getProductCondition());
            statement.setString(8, product.getImportType());
            setNullableString(statement, 9, product.getOriginCountry());
            statement.setInt(10, product.getWarrantyMonths());
            setNullableString(statement, 11, product.getWarrantyProvider());
            statement.setString(12, product.getStatus());
            statement.setBoolean(13, product.isFeatured());
            statement.setInt(14, product.getProductId());
            return statement.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int productId, String status) throws SQLException {
        String sql = "UPDATE products SET status = ? WHERE product_id = ?";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, status);
            statement.setInt(2, productId);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean existsByName(String name) throws SQLException {
        String sql = "SELECT 1 FROM products WHERE name = ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, name);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public boolean existsByNameForOtherProduct(String name, int productId) throws SQLException {
        String sql = "SELECT 1 FROM products WHERE name = ? AND product_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, name);
            statement.setInt(2, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public boolean existsByModelCode(String modelCode) throws SQLException {
        if (modelCode == null || modelCode.isBlank()) {
            return false;
        }

        String sql = "SELECT 1 FROM products WHERE model_code = ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, modelCode);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public boolean existsByModelCodeForOtherProduct(String modelCode, int productId) throws SQLException {
        if (modelCode == null || modelCode.isBlank()) {
            return false;
        }

        String sql = "SELECT 1 FROM products WHERE model_code = ? AND product_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, modelCode);
            statement.setInt(2, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    private void appendFilters(StringBuilder sql, List<Object> params, String keyword, Integer categoryId, String status) {
        appendBaseFilters(sql, params, keyword, categoryId, status);
    }

    private void appendBaseFilters(StringBuilder sql, List<Object> params, String keyword, Integer categoryId, String status) {
        if (keyword != null && !keyword.isBlank()) {
            sql.append(" AND (LOWER(p.name) LIKE ? OR LOWER(COALESCE(p.model_code, '')) LIKE ?)");
            String likeKeyword = "%" + keyword.trim().toLowerCase() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
        }

        if (categoryId != null && categoryId > 0) {
            sql.append(" AND p.category_id = ?");
            params.add(categoryId);
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND p.status = ?");
            params.add(status.trim().toUpperCase());
        }
    }

    private String resolveOrderBy(String sort) {
        if ("oldest".equals(sort)) {
            return "p.product_id ASC";
        }
        if ("name_asc".equals(sort)) {
            return "p.name ASC, p.product_id ASC";
        }
        if ("name_desc".equals(sort)) {
            return "p.name DESC, p.product_id DESC";
        }
        if ("price_asc".equals(sort)) {
            return "COALESCE(vs.min_price, 0) ASC, p.product_id ASC";
        }
        if ("price_desc".equals(sort)) {
            return "COALESCE(vs.min_price, 0) DESC, p.product_id DESC";
        }
        if ("stock_asc".equals(sort)) {
            return "COALESCE(vs.total_stock, 0) ASC, p.product_id ASC";
        }
        if ("stock_desc".equals(sort)) {
            return "COALESCE(vs.total_stock, 0) DESC, p.product_id DESC";
        }
        return "p.product_id DESC";
    }

    private void setProductMutationParams(PreparedStatement statement, Product product) throws SQLException {
        setNullableInteger(statement, 1, product.getCreatedBy());
        statement.setInt(2, product.getCategoryId());
        statement.setString(3, product.getName());
        statement.setString(4, product.getDescription());
        statement.setString(5, product.getBrand());
        setNullableString(statement, 6, product.getModelCode());
        setNullableInteger(statement, 7, product.getReleaseYear());
        statement.setString(8, product.getProductCondition());
        statement.setString(9, product.getImportType());
        setNullableString(statement, 10, product.getOriginCountry());
        statement.setInt(11, product.getWarrantyMonths());
        setNullableString(statement, 12, product.getWarrantyProvider());
        statement.setString(13, product.getStatus());
        statement.setBoolean(14, product.isFeatured());
    }

    private Product mapProduct(ResultSet resultSet) throws SQLException {
        Product product = new Product();
        product.setProductId(resultSet.getInt("product_id"));
        int createdBy = resultSet.getInt("created_by");
        product.setCreatedBy(resultSet.wasNull() ? null : createdBy);
        product.setCategoryId(resultSet.getInt("category_id"));
        product.setCategoryName(resultSet.getString("category_name"));
        product.setName(resultSet.getString("name"));
        product.setDescription(resultSet.getString("description"));
        product.setBrand(resultSet.getString("brand"));
        product.setModelCode(resultSet.getString("model_code"));
        int releaseYear = resultSet.getInt("release_year");
        product.setReleaseYear(resultSet.wasNull() ? null : releaseYear);
        product.setProductCondition(resultSet.getString("product_condition"));
        product.setImportType(resultSet.getString("import_type"));
        product.setOriginCountry(resultSet.getString("origin_country"));
        product.setWarrantyMonths(resultSet.getInt("warranty_months"));
        product.setWarrantyProvider(resultSet.getString("warranty_provider"));
        product.setStatus(resultSet.getString("status"));
        product.setViewCount(resultSet.getInt("view_count"));
        product.setRating(resultSet.getBigDecimal("rating"));
        product.setSoldQuantity(resultSet.getInt("sold_quantity"));
        product.setFeatured(resultSet.getBoolean("is_featured"));
        product.setCreatedAt(toLocalDateTime(resultSet.getTimestamp("created_at")));
        product.setUpdatedAt(toLocalDateTime(resultSet.getTimestamp("updated_at")));
        product.setMinPrice(resultSet.getBigDecimal("min_price"));
        product.setTotalStock(resultSet.getInt("total_stock"));
        product.setVariantCount(resultSet.getInt("variant_count"));
        product.setPrimaryImageUrl(resultSet.getString("primary_image_url"));
        return product;
    }

    private void bindParams(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            statement.setObject(i + 1, params.get(i));
        }
    }

    private void setNullableString(PreparedStatement statement, int index, String value) throws SQLException {
        if (value == null || value.isBlank()) {
            statement.setNull(index, java.sql.Types.VARCHAR);
            return;
        }
        statement.setString(index, value);
    }

    private void setNullableInteger(PreparedStatement statement, int index, Integer value) throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.INTEGER);
            return;
        }
        statement.setInt(index, value);
    }

    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toLocalDateTime();
    }

    // 1. Lấy sản phẩm nổi bật
    public List<Product> findFeaturedProducts(int limit) throws SQLException {
        // Nối SQL: Lấy các cột + Từ các bảng + Thêm điều kiện Nổi bật & Đang bán + Giới hạn số lượng
        String sql = "SELECT " + PRODUCT_COLUMNS + " " + PRODUCT_FROM
                + " AND p.is_featured = 1 AND p.status = 'ACTIVE' LIMIT ?";

        List<Product> products = new ArrayList<>();

        // Mở kết nối Database
        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            // Truyền giá trị cho dấu ? (limit)
            statement.setInt(1, limit);

            // Thực thi truy vấn
            try (ResultSet resultSet = statement.executeQuery()) {
                // Duyệt qua từng dòng kết quả
                while (resultSet.next()) {
                    products.add(mapProduct(resultSet)); // mapProduct đã tự động xử lý lấy primary_image_url
                }
            }
        }
        return products;
    }

    // 2. Lấy sản phẩm mới nhất
    public List<Product> findNewProducts(int limit) throws SQLException {
        // Nối SQL: Sắp xếp theo năm phát hành mới nhất, nếu trùng năm thì lấy product_id lớn nhất (mới thêm vào)
        String sql = "SELECT " + PRODUCT_COLUMNS + " " + PRODUCT_FROM
                + " AND p.status = 'ACTIVE' ORDER BY p.release_year DESC, p.product_id DESC LIMIT ?";

        List<Product> products = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, limit);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    products.add(mapProduct(resultSet));
                }
            }
        }
        return products;
    }

    // 3. Lấy sản phẩm bán chạy nhất
    public List<Product> findBestSellerProducts(int limit) throws SQLException {
        // Nối SQL: Sắp xếp theo số lượng đã bán (sold_quantity) giảm dần
        String sql = "SELECT " + PRODUCT_COLUMNS + " " + PRODUCT_FROM
                + " AND p.status = 'ACTIVE' ORDER BY p.sold_quantity DESC, p.product_id DESC LIMIT ?";

        List<Product> products = new ArrayList<>();

        try (Connection connection = DBConnection.getConnection(); PreparedStatement statement = connection.prepareStatement(sql)) {

            statement.setInt(1, limit);

            try (ResultSet resultSet = statement.executeQuery()) {
                while (resultSet.next()) {
                    products.add(mapProduct(resultSet));
                }
            }
        }
        return products;
    }
}
