package dao.cart;

import model.entity.cart.CartItem;
import util.DBConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

/**
 * DAO chỉ xử lý SQL và mapping dữ liệu (rule 2). Mỗi hàm tự mở/đóng
 * Connection riêng qua DBConnection.getConnection() (theo đúng form
 * CategoryDAO) - Service không truyền Connection xuống DAO nữa.
 *
 * Lưu ý: vì không còn 1 Connection/transaction xuyên suốt, các thao tác
 * nhiều bước (vd. checkout) không còn atomic - đây là lựa chọn được team
 * chốt, chấp nhận đánh đổi để đồng nhất pattern DAO toàn hệ thống.
 */
public class CartDAO {

    private static final String CART_ITEM_COLUMNS = """
            ci.cart_item_id, ci.cart_id, ci.variant_id, ci.quantity, ci.addon_id, ci.added_at,
            p.name AS product_name, pv.variant_label, pv.stock_quantity, pv.is_active,
            CASE WHEN pv.discount_price IS NOT NULL
                 AND NOW() BETWEEN pv.discount_start AND pv.discount_end
                 THEN pv.discount_price ELSE pv.price END AS unit_price,
            pa.name AS addon_label, pa.price_add AS addon_price,
            pi.file_path AS image_path
            """;

    private static final String CART_ITEM_JOIN = """
            FROM cart_items ci
            JOIN cart c ON c.cart_id = ci.cart_id
            JOIN product_variants pv ON pv.variant_id = ci.variant_id
            JOIN products p ON p.product_id = pv.product_id
            LEFT JOIN product_addon_services pa ON pa.addon_id = ci.addon_id
            LEFT JOIN product_images pi ON pi.product_id = p.product_id AND pi.is_primary = 1
            """;

    /** Lấy cart_id của khách; tự tạo mới nếu khách chưa có giỏ hàng (1 customer - 1 cart). */
    public int getOrCreateCartId(int customerId) throws SQLException {
        Optional<Integer> existing = findCartIdByCustomerId(customerId);
        if (existing.isPresent()) {
            return existing.get();
        }

        String sql = "INSERT INTO cart (customer_id) VALUES (?)";
        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            statement.setInt(1, customerId);
            statement.executeUpdate();

            try (ResultSet generatedKeys = statement.getGeneratedKeys()) {
                if (generatedKeys.next()) {
                    return generatedKeys.getInt(1);
                }
                throw new SQLException("Failed to retrieve the generated cart id.");
            }
        }
    }

    public Optional<Integer> findCartIdByCustomerId(int customerId) throws SQLException {
        String sql = "SELECT cart_id FROM cart WHERE customer_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(resultSet.getInt("cart_id"));
                }
                return Optional.empty();
            }
        }
    }

    public boolean existsByCartVariantAddon(int cartId, int variantId, Integer addonId) throws SQLException {
        String sql = """
                SELECT 1 FROM cart_items
                WHERE cart_id = ? AND variant_id = ? AND IFNULL(addon_id, 0) = IFNULL(?, 0)
                LIMIT 1
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, cartId);
            statement.setInt(2, variantId);
            if (addonId == null) statement.setNull(3, Types.INTEGER); else statement.setInt(3, addonId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next();
            }
        }
    }

    public int findExistingQuantity(int cartId, int variantId, Integer addonId) throws SQLException {
        String sql = """
                SELECT quantity FROM cart_items
                WHERE cart_id = ? AND variant_id = ? AND IFNULL(addon_id, 0) = IFNULL(?, 0)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, cartId);
            statement.setInt(2, variantId);
            if (addonId == null) statement.setNull(3, Types.INTEGER); else statement.setInt(3, addonId);
            try (ResultSet resultSet = statement.executeQuery()) {
                return resultSet.next() ? resultSet.getInt("quantity") : 0;
            }
        }
    }

    /**
     * Thêm vào giỏ: cộng dồn số lượng nếu (variant, addon) đã có trong giỏ nhờ
     * UNIQUE KEY UX_cart_items_cart_variant_addon, ngược lại insert dòng mới.
     */
    public void upsertCartItem(int cartId, int variantId, int quantity, Integer addonId) throws SQLException {
        String sql = """
                INSERT INTO cart_items (cart_id, variant_id, quantity, addon_id)
                VALUES (?, ?, ?, ?)
                ON DUPLICATE KEY UPDATE quantity = quantity + VALUES(quantity)
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, cartId);
            statement.setInt(2, variantId);
            statement.setInt(3, quantity);
            if (addonId == null) statement.setNull(4, Types.INTEGER); else statement.setInt(4, addonId);
            statement.executeUpdate();
        }
    }

    /** Cập nhật số lượng tuyệt đối cho 1 dòng cart_item. */
    public boolean updateQuantity(int cartItemId, int cartId, int quantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ? AND cart_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, quantity);
            statement.setInt(2, cartItemId);
            statement.setInt(3, cartId);
            return statement.executeUpdate() > 0;
        }
    }

    /** Xoá 1 dòng khỏi giỏ, kèm điều kiện cart_id để tránh khách A xoá được dòng của khách B. */
    public boolean deleteCartItem(int cartItemId, int cartId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_item_id = ? AND cart_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, cartItemId);
            statement.setInt(2, cartId);
            return statement.executeUpdate() > 0;
        }
    }

    public void clearCart(int cartId) throws SQLException {
        String sql = "DELETE FROM cart_items WHERE cart_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, cartId);
            statement.executeUpdate();
        }
    }

    /** Đếm tổng số lượng sản phẩm trong giỏ - dùng hiển thị badge số lượng trên header. */
    public int countCartItems(int customerId) throws SQLException {
        String sql = """
                SELECT COALESCE(SUM(ci.quantity), 0) AS total_qty
                FROM cart_items ci JOIN cart c ON c.cart_id = ci.cart_id
                WHERE c.customer_id = ?
                """;

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            try (ResultSet resultSet = statement.executeQuery()) {
                resultSet.next();
                return resultSet.getInt("total_qty");
            }
        }
    }

    public Optional<CartItem> findById(int cartItemId, int cartId) throws SQLException {
        String sql = "SELECT " + CART_ITEM_COLUMNS + CART_ITEM_JOIN +
                " WHERE ci.cart_item_id = ? AND ci.cart_id = ?";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, cartItemId);
            statement.setInt(2, cartId);
            try (ResultSet resultSet = statement.executeQuery()) {
                if (resultSet.next()) {
                    return Optional.of(mapCartItem(resultSet));
                }
                return Optional.empty();
            }
        }
    }

    /** Lấy toàn bộ giỏ hàng kèm thông tin sản phẩm/giá hiện tại để hiển thị cart.jsp hoặc để checkout. */
    public List<CartItem> findByCustomerId(int customerId) throws SQLException {
        String sql = "SELECT " + CART_ITEM_COLUMNS + CART_ITEM_JOIN +
                " WHERE c.customer_id = ? ORDER BY ci.added_at DESC";

        try (Connection connection = DBConnection.getConnection();
             PreparedStatement statement = connection.prepareStatement(sql)) {
            statement.setInt(1, customerId);
            try (ResultSet resultSet = statement.executeQuery()) {
                List<CartItem> items = new ArrayList<>();
                while (resultSet.next()) {
                    items.add(mapCartItem(resultSet));
                }
                return items;
            }
        }
    }

    private CartItem mapCartItem(ResultSet resultSet) throws SQLException {
        CartItem item = new CartItem();
        item.setCartItemId(resultSet.getInt("cart_item_id"));
        item.setCartId(resultSet.getInt("cart_id"));
        item.setVariantId(resultSet.getInt("variant_id"));
        item.setQuantity(resultSet.getInt("quantity"));
        int addonId = resultSet.getInt("addon_id");
        item.setAddonId(resultSet.wasNull() ? null : addonId);
        Timestamp addedAt = resultSet.getTimestamp("added_at");
        if (addedAt != null) {
            item.setAddedAt(addedAt.toLocalDateTime());
        }
        item.setProductName(resultSet.getString("product_name"));
        item.setVariantLabel(resultSet.getString("variant_label"));
        item.setStockQuantity(resultSet.getInt("stock_quantity"));
        item.setActive(resultSet.getBoolean("is_active"));
        BigDecimal unitPrice = resultSet.getBigDecimal("unit_price");
        item.setUnitPrice(unitPrice != null ? unitPrice : BigDecimal.ZERO);
        item.setAddonLabel(resultSet.getString("addon_label"));
        item.setAddonPrice(resultSet.getBigDecimal("addon_price"));
        item.setImageUrl(resultSet.getString("image_path"));
        return item;
    }
}
