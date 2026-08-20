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
            pv.sku, pv.variant_label, pv.color_name, pv.case_size_mm, pv.storage_capacity_gb,
            pv.ram_gb, pv.connectivity, pv.price,
            pv.stock_quantity, pv.weight_kg, pv.discount_price, pv.discount_start,
            pv.discount_end, pv.is_active, pv.created_at, pv.updated_at
            """;

    private static final String VARIANT_FROM = """
            FROM product_variants pv
            JOIN products p ON p.product_id = pv.product_id
            WHERE 1 = 1
            """;

    /** Lấy danh sách biến thể của một sản phẩm theo keyword, trạng thái, sort và phân trang. */
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
    
    /** Đếm biến thể của một sản phẩm sau khi áp dụng keyword và trạng thái. */
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

    public int countActiveByProduct(int productId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM product_variants WHERE product_id = ? AND is_active = 1";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, productId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return resultSet.getInt(1);
                }
                return 0;
            }
        }
    }

    /** Tìm biến thể theo ID, trả về Optional.empty nếu k   hông có bản ghi. */
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

    /** Thêm biến thể mới vào bảng product_variants và trả về variant_id được sinh ra. */
    public int insert(ProductVariant variant) throws SQLException {
        String sql = """
                INSERT INTO product_variants (
                    product_id, sku, variant_label, color_name, case_size_mm, storage_capacity_gb,
                    ram_gb, connectivity, price, stock_quantity,
                    weight_kg, discount_price, discount_start, discount_end, is_active
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
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

    /** Cập nhật toàn bộ thông tin chính của biến thể theo variant_id. */
    public boolean update(ProductVariant variant) throws SQLException {
        String sql = """
                UPDATE product_variants
                SET sku = ?, variant_label = ?, color_name = ?, case_size_mm = ?,
                    storage_capacity_gb = ?, ram_gb = ?, connectivity = ?, price = ?, stock_quantity = ?, weight_kg = ?,
                    discount_price = ?, discount_start = ?, discount_end = ?, is_active = ?
                WHERE variant_id = ? AND product_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            setVariantFields(statement, variant, 1);
            statement.setInt(15, variant.getVariantId());
            statement.setInt(16, variant.getProductId());
            return statement.executeUpdate() > 0;
        }
    }

    /** Cập nhật trạng thái, đồng thời khóa theo product cha để tránh update nhầm ownership. */
    public boolean updateStatus(int productId, int variantId, boolean isActive) throws SQLException {
        String sql = "UPDATE product_variants SET is_active = ? WHERE variant_id = ? AND product_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setBoolean(1, isActive);
            statement.setInt(2, variantId);
            statement.setInt(3, productId);
            return statement.executeUpdate() > 0;
        }
    }

    /** Kiểm tra SKU đã tồn tại hay chưa khi tạo biến thể mới. */
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

    /** Kiểm tra SKU có trùng với biến thể khác khi cập nhật hay không. */
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
    
    /**
     * Lấy tồn kho hiện tại của biến thể đang active để validate giỏ hàng/checkout.
     * Join thêm bảng products và bắt buộc status = 'ACTIVE' để chặn thanh toán
     * khi admin đã tạm khóa/ngừng kinh doanh sản phẩm (INACTIVE/DISCONTINUED),
     * kể cả khi variant vẫn còn is_active = 1.
     */
    public Optional<Integer> findStockQuantity(int variantId) throws SQLException {
        String sql = """
                SELECT pv.stock_quantity
                FROM product_variants pv
                JOIN products p ON p.product_id = pv.product_id
                WHERE pv.variant_id = ? AND pv.is_active = 1 AND p.status = 'ACTIVE'
                """;

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
    /**
     * Trừ tồn kho một cách an toàn, chỉ thành công khi biến thể còn đủ hàng.
     * Join thêm bảng products và bắt buộc p.status = 'ACTIVE' để chặn trừ kho
     * (và do đó chặn đặt hàng) khi sản phẩm đã bị admin tạm khóa/ngừng kinh
     * doanh, đồng bộ với điều kiện ở findStockQuantity.
     */
    public boolean decreaseStockIfAvailable(int variantId, int quantity) throws SQLException {
        String sql = """
                UPDATE product_variants pv
                JOIN products p ON p.product_id = pv.product_id
                SET pv.stock_quantity = pv.stock_quantity - ?
                WHERE pv.variant_id = ? AND pv.is_active = 1 AND p.status = 'ACTIVE' AND pv.stock_quantity >= ?
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
    /** Hoàn lại tồn kho khi cần rollback hoặc hủy phần giữ hàng. */
    public void increaseStock(int variantId, int quantity) throws SQLException {
        String sql = "UPDATE product_variants SET stock_quantity = stock_quantity + ? WHERE variant_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, quantity);
            statement.setInt(2, variantId);
            statement.executeUpdate();
        }
    }

    /** Gắn điều kiện productId, keyword và trạng thái vào SQL danh sách biến thể. */
    private void appendFilters(StringBuilder sql, List<Object> params, int productId, String keyword, String status) {
        sql.append(" AND pv.product_id = ?");
        params.add(productId);

        if (keyword != null && !keyword.isBlank()) {
            sql.append("""
                     AND (
                        LOWER(pv.sku) LIKE ?
                        OR LOWER(pv.variant_label) LIKE ?
                        OR LOWER(COALESCE(pv.color_name, '')) LIKE ?
                    )
                    """);
            String likeKeyword = "%" + keyword.trim().toLowerCase() + "%";
            params.add(likeKeyword);
            params.add(likeKeyword);
            params.add(likeKeyword);
        }

        if (status != null && !status.isBlank()) {
            sql.append(" AND pv.is_active = ?");
            params.add("ACTIVE".equalsIgnoreCase(status));
        }
    }

    /** Chuyển sort key thành ORDER BY cố định để tránh SQL động không kiểm soát. */
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

    /** Bind dữ liệu biến thể vào PreparedStatement dùng chung cho insert/update. */
    private void setMutationParams(PreparedStatement statement, ProductVariant variant) throws SQLException {
        statement.setInt(1, variant.getProductId());
        setVariantFields(statement, variant, 2);
    }

    /** Bind các field được phép thay đổi, không bao gồm product_id. */
    private void setVariantFields(PreparedStatement statement, ProductVariant variant, int startIndex)
            throws SQLException {
        int index = startIndex;
        statement.setString(index++, variant.getSku());
        statement.setString(index++, variant.getVariantLabel());
        setNullableString(statement, index++, variant.getColorName());
        setNullableInteger(statement, index++, variant.getCaseSizeMm());
        setNullableInteger(statement, index++, variant.getStorageCapacityGb());
        setNullableInteger(statement, index++, variant.getRamGb());
        setNullableString(statement, index++, variant.getConnectivity());
        statement.setBigDecimal(index++, variant.getPrice());
        statement.setInt(index++, variant.getStockQuantity());
        statement.setBigDecimal(index++, variant.getWeightKg());
        setNullableBigDecimal(statement, index++, variant.getDiscountPrice());
        setNullableLocalDateTime(statement, index++, variant.getDiscountStart());
        setNullableLocalDateTime(statement, index++, variant.getDiscountEnd());
        statement.setBoolean(index, variant.isActive());
    }

    /** Map một dòng ResultSet thành entity ProductVariant. */
    private ProductVariant mapVariant(ResultSet resultSet) throws SQLException {
        ProductVariant variant = new ProductVariant();
        variant.setVariantId(resultSet.getInt("variant_id"));
        variant.setProductId(resultSet.getInt("product_id"));
        variant.setProductName(resultSet.getString("product_name"));
        variant.setProductStatus(resultSet.getString("product_status"));
        variant.setSku(resultSet.getString("sku"));
        variant.setVariantLabel(resultSet.getString("variant_label"));
        variant.setColorName(resultSet.getString("color_name"));
        int caseSizeMm = resultSet.getInt("case_size_mm");
        variant.setCaseSizeMm(resultSet.wasNull() ? null : caseSizeMm);
        int storageCapacityGb = resultSet.getInt("storage_capacity_gb");
        variant.setStorageCapacityGb(resultSet.wasNull() ? null : storageCapacityGb);
        int ramGb = resultSet.getInt("ram_gb");
        variant.setRamGb(resultSet.wasNull() ? null : ramGb);

        variant.setConnectivity(resultSet.getString("connectivity"));
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

    /** Bind danh sách tham số vào PreparedStatement theo thứ tự đã build SQL. */
    private void bindParams(PreparedStatement statement, List<Object> params) throws SQLException {
        for (int i = 0; i < params.size(); i++) {
            statement.setObject(i + 1, params.get(i));
        }
    }

    /** Bind chuỗi nullable vào PreparedStatement. */
    private void setNullableString(PreparedStatement statement, int index, String value) throws SQLException {
        if (value == null || value.isBlank()) {
            statement.setNull(index, java.sql.Types.VARCHAR);
            return;
        }
        statement.setString(index, value);
    }

    /** Bind số nguyên nullable vào PreparedStatement. */
    private void setNullableInteger(PreparedStatement statement, int index, Integer value) throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.INTEGER);
            return;
        }
        statement.setInt(index, value);
    }

    /** Bind BigDecimal nullable vào PreparedStatement. */
    private void setNullableBigDecimal(PreparedStatement statement, int index, BigDecimal value) throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.DECIMAL);
            return;
        }
        statement.setBigDecimal(index, value);
    }

    /** Bind LocalDateTime nullable vào PreparedStatement dưới dạng Timestamp. */
    private void setNullableLocalDateTime(PreparedStatement statement, int index, java.time.LocalDateTime value)
            throws SQLException {
        if (value == null) {
            statement.setNull(index, java.sql.Types.TIMESTAMP);
            return;
        }
        statement.setTimestamp(index, Timestamp.valueOf(value));
    }

    /** Chuyển Timestamp từ JDBC sang LocalDateTime cho entity. */
    private java.time.LocalDateTime toLocalDateTime(Timestamp timestamp) {
        if (timestamp == null) {
            return null;
        }
        return timestamp.toLocalDateTime();
    }
}
