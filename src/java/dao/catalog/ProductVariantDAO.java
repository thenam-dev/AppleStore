package dao.catalog;

import model.entity.catalog.ProductVariant;
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

public class ProductVariantDAO {
    private static final String VARIANT_COLUMNS = """
            pv.variant_id, pv.product_id, p.name AS product_name, p.status AS product_status,
            pv.sku, pv.variant_label, pv.color_name, pv.color_hex, pv.storage_capacity_gb,
            pv.ram_gb, pv.connectivity, pv.chip_option, pv.screen_size_inch, pv.price,
            pv.stock_quantity, pv.weight_kg, pv.discount_price, pv.discount_start,
            pv.discount_end, pv.is_active, pv.created_at, pv.updated_at
            """;

    private static final String VARIANT_FROM = """
            FROM product_variants pv
            JOIN products p ON p.product_id = pv.product_id
            WHERE 1 = 1
            """;

    public List<ProductVariant> findByProduct(int productId, String keyword, String status, String sort, int page, int pageSize)
            throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT ")
                .append(VARIANT_COLUMNS)
                .append(' ')
                .append(VARIANT_FROM);
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, productId, keyword, status);
        sql.append(" ORDER BY ").append(resolveOrderBy(sort)).append(" LIMIT ? OFFSET ?");
        params.add(pageSize);
        params.add(Math.max(0, (page - 1) * pageSize));

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql.toString())) {
            bindParams(statement, params);
            try (ResultSet resultSet = statement.executeQuery()) {
                List<ProductVariant> variants = new ArrayList<>();
                while (resultSet.next()) {
                    variants.add(mapVariant(resultSet));
                }
                return variants;
            }
        }
    }
    
    public Optional<Integer> findStockQuantity(int variantId) throws SQLException {
        String sql = "SELECT stock_quantity FROM product_variants WHERE variant_id = ? AND is_active = 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(resultSet.getInt("stock_quantity"));
                }
                return Optional.empty();
            }
        }
    }
    
    /**
     * Trừ tồn kho khi tạo đơn hàng, chỉ thành công nếu tồn kho hiện tại còn
     * đủ - điều kiện này nằm ngay trong WHERE nên atomic ở mức 1 câu lệnh SQL
     * mà không cần SELECT ... FOR UPDATE riêng.
     * Trả về false nếu không đủ hàng (0 dòng bị ảnh hưởng) - Service phải
     * kiểm tra giá trị trả về để rollback nghiệp vụ (hoàn lại các bước trước
     * đó) vì không còn transaction tự động.
     */
    public boolean decreaseStockIfAvailable(int variantId, int quantity) throws SQLException {
        String sql = """
                UPDATE product_variants
                SET stock_quantity = stock_quantity - ?
                WHERE variant_id = ? AND is_active = 1 AND stock_quantity >= ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, quantity);
            statement.setInt(2, variantId);
            statement.setInt(3, quantity);
            return statement.executeUpdate() > 0;
        }
    }

    /** Hoàn tồn kho khi huỷ đơn / hết hạn thanh toán / cần rollback thủ công 1 bước checkout đã trừ kho. */
    public void increaseStock(int variantId, int quantity) throws SQLException {
        String sql = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE variant_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, quantity);
            statement.setInt(2, variantId);
            statement.executeUpdate();
        }
    }


    public int countByProduct(int productId, String keyword, String status) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM product_variants pv JOIN products p ON p.product_id = pv.product_id WHERE 1 = 1");
        List<Object> params = new ArrayList<>();
        appendFilters(sql, params, productId, keyword, status);

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

    public Optional<ProductVariant> findById(int variantId) throws SQLException {
        String sql = "SELECT " + VARIANT_COLUMNS + ' ' + VARIANT_FROM + " AND pv.variant_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapVariant(resultSet));
                }
                return Optional.empty();
            }
        }
    }

    public int insert(ProductVariant variant) throws SQLException {
        String sql = """
                INSERT INTO product_variants (
                    product_id, sku, variant_label, color_name, color_hex, storage_capacity_gb,
                    ram_gb, connectivity, chip_option, screen_size_inch, price, stock_quantity,
                    weight_kg, discount_price, discount_start, discount_end, is_active
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setMutationParams(statement, variant);
            statement.executeUpdate();
            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated variant id.");
            }
        }
    }

    public boolean update(ProductVariant variant) throws SQLException {
        String sql = """
                UPDATE product_variants
                SET product_id = ?, sku = ?, variant_label = ?, color_name = ?, color_hex = ?,
                    storage_capacity_gb = ?, ram_gb = ?, connectivity = ?, chip_option = ?,
                    screen_size_inch = ?, price = ?, stock_quantity = ?, weight_kg = ?,
                    discount_price = ?, discount_start = ?, discount_end = ?, is_active = ?
                WHERE variant_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            setMutationParams(statement, variant);
            statement.setInt(18, variant.getVariantId());
            return statement.executeUpdate() > 0;
        }
    }

    public boolean updateStatus(int variantId, boolean isActive) throws SQLException {
        String sql = "UPDATE product_variants SET is_active = ? WHERE variant_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setBoolean(1, isActive);
            statement.setInt(2, variantId);
            return statement.executeUpdate() > 0;
        }
    }

    public boolean existsBySku(String sku) throws SQLException {
        String sql = "SELECT 1 FROM product_variants WHERE sku = ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, sku);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public boolean existsBySkuForOtherVariant(int variantId, String sku) throws SQLException {
        String sql = "SELECT 1 FROM product_variants WHERE sku = ? AND variant_id <> ? LIMIT 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setString(1, sku);
            statement.setInt(2, variantId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }
    
    public Optional<Integer> findStockQuantity(int variantId) throws SQLException {
        String sql = "SELECT stock_quantity FROM product_variants WHERE variant_id = ? AND is_active = 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, variantId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(resultSet.getInt("stock_quantity"));
                }
                return Optional.empty();
            }
        }
    }

    /**
     * Trừ tồn kho khi tạo đơn hàng, chỉ thành công nếu tồn kho hiện tại còn
     * đủ - điều kiện này nằm ngay trong WHERE nên atomic ở mức 1 câu lệnh SQL
     * mà không cần SELECT ... FOR UPDATE riêng.
     * Trả về false nếu không đủ hàng (0 dòng bị ảnh hưởng) - Service phải
     * kiểm tra giá trị trả về để rollback nghiệp vụ (hoàn lại các bước trước
     * đó) vì không còn transaction tự động.
     */
    public boolean decreaseStockIfAvailable(int variantId, int quantity) throws SQLException {
        String sql = """
                UPDATE product_variants
                SET stock_quantity = stock_quantity - ?
                WHERE variant_id = ? AND is_active = 1 AND stock_quantity >= ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, quantity);
            statement.setInt(2, variantId);
            statement.setInt(3, quantity);
            return statement.executeUpdate() > 0;
        }
    }

    /** Hoàn tồn kho khi huỷ đơn / hết hạn thanh toán / cần rollback thủ công 1 bước checkout đã trừ kho. */
    public void increaseStock(int variantId, int quantity) throws SQLException {
        String sql = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE variant_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, quantity);
            statement.setInt(2, variantId);
            statement.executeUpdate();
        }
    }

    private void appendFilters(StringBuilder sql, List<Object> params, int productId, String keyword, String status) {
        sql.append(" AND pv.product_id = ?");
        params.add(productId);

        if (keyword != null && !keyword.isBlank()) {
            sql.append("""
                     AND (
                        LOWER(pv.sku) LIKE ?
                        OR LOWER(pv.variant_label) LIKE ?
                        OR LOWER(COALESCE(pv.color_name, '')) LIKE ?
                        OR LOWER(COALESCE(pv.chip_option, '')) LIKE ?
                    )
                    """);
            String likeKeyword = "%" + keyword.trim().toLowerCase() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND pv.is_active = ?");
            params.add("ACTIVE".equalsIgnoreCase(status));
        }
    }

    private String resolveOrderBy(String sort) {
        if ("oldest".equals(sort)) {
            return "pv.variant_id ASC";
        }
        if ("sku_asc".equals(sort)) {
            return "pv.sku ASC, pv.variant_id ASC";
        }
        if ("sku_desc".equals(sort)) {
            return "pv.sku DESC, pv.variant_id DESC";
        }
        if ("label_asc".equals(sort)) {
            return "pv.variant_label ASC, pv.variant_id ASC";
        }
        if ("label_desc".equals(sort)) {
            return "pv.variant_label DESC, pv.variant_id DESC";
        }
        if ("price_asc".equals(sort)) {
            return "pv.price ASC, pv.variant_id ASC";
        }
        if ("price_desc".equals(sort)) {
            return "pv.price DESC, pv.variant_id DESC";
        }
        if ("stock_asc".equals(sort)) {
            return "pv.stock_quantity ASC, pv.variant_id ASC";
        }
        if ("stock_desc".equals(sort)) {
            return "pv.stock_quantity DESC, pv.variant_id DESC";
        }
        return "pv.variant_id DESC";
    }

    private void setMutationParams(PreparedStatement statement, ProductVariant variant) throws SQLException {
        statement.setInt(1, variant.getProductId());
        statement.setString(2, variant.getSku());
        statement.setString(3, variant.getVariantLabel());
        setNullableString(statement, 4, variant.getColorName());
        setNullableString(statement, 5, variant.getColorHex());
        setNullableInteger(statement, 6, variant.getStorageCapacityGb());
        setNullableInteger(statement, 7, variant.getRamGb());
        setNullableString(statement, 8, variant.getConnectivity());
        setNullableString(statement, 9, variant.getChipOption());
        setNullableBigDecimal(statement, 10, variant.getScreenSizeInch());
        statement.setBigDecimal(11, variant.getPrice());
        statement.setInt(12, variant.getStockQuantity());
        statement.setBigDecimal(13, variant.getWeightKg());
        setNullableBigDecimal(statement, 14, variant.getDiscountPrice());
        setNullableLocalDateTime(statement, 15, variant.getDiscountStart());
        setNullableLocalDateTime(statement, 16, variant.getDiscountEnd());
        statement.setBoolean(17, variant.isActive());
    }

    private ProductVariant mapVariant(ResultSet resultSet) throws SQLException {
        ProductVariant variant = new ProductVariant();
        variant.setVariantId(resultSet.getInt("variant_id"));
        variant.setProductId(resultSet.getInt("product_id"));
        variant.setProductName(resultSet.getString("product_name"));
        variant.setProductStatus(resultSet.getString("product_status"));
        variant.setSku(resultSet.getString("sku"));
        variant.setVariantLabel(resultSet.getString("variant_label"));
        variant.setColorName(resultSet.getString("color_name"));
        variant.setColorHex(resultSet.getString("color_hex"));

        int storageCapacityGb = resultSet.getInt("storage_capacity_gb");
        variant.setStorageCapacityGb(resultSet.wasNull() ? null : storageCapacityGb);
        int ramGb = resultSet.getInt("ram_gb");
        variant.setRamGb(resultSet.wasNull() ? null : ramGb);

        variant.setConnectivity(resultSet.getString("connectivity"));
        variant.setChipOption(resultSet.getString("chip_option"));
        variant.setScreenSizeInch(resultSet.getBigDecimal("screen_size_inch"));
        variant.setPrice(resultSet.getBigDecimal("price"));
        variant.setStockQuantity(resultSet.getInt("stock_quantity"));
        variant.setWeightKg(resultSet.getBigDecimal("weight_kg"));
        variant.setDiscountPrice(resultSet.getBigDecimal("discount_price"));
        variant.setDiscountStart(toLocalDateTime(resultSet.getTimestamp("discount_start")));
        variant.setDiscountEnd(toLocalDateTime(resultSet.getTimestamp("discount_end")));
        variant.setActive(resultSet.getBoolean("is_active"));
        variant.setCreatedAt(toLocalDateTime(resultSet.getTimestamp("created_at")));
        variant.setUpdatedAt(toLocalDateTime(resultSet.getTimestamp("updated_at")));
        return variant;
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

    private void setNullableBigDecimal(PreparedStatement statement, int index, BigDecimal value) throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.DECIMAL);
            return;
        }
        statement.setBigDecimal(index, value);
    }

    private void setNullableLocalDateTime(PreparedStatement statement, int index, java.time.LocalDateTime value)
            throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.TIMESTAMP);
            return;
        }
        statement.setTimestamp(index, Timestamp.valueOf(value));
    }

    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toLocalDateTime();
    }
}
