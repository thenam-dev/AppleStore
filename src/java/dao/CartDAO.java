/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.CartItem;
import model.CartItemView;
import util.DBConnection;
 
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.sql.Types;
import java.util.ArrayList;
import java.util.List;
/**
 *
 * @author ACER
 */
public class CartDAO {
 
    // ---------- CART ----------
 
    /** Lấy cart_id hiện có của khách hàng, null nếu khách chưa có giỏ hàng. */
    public Integer findCartIdByCustomer(Connection conn, int customerId) throws SQLException {
        String sql = "SELECT cart_id FROM cart WHERE customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("cart_id") : null;
            }
        }
    }
 
    /** Tạo giỏ hàng mới cho khách hàng, trả về cart_id vừa tạo. */
    public int createCart(Connection conn, int customerId) throws SQLException {
        String sql = "INSERT INTO cart (customer_id) VALUES (?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, customerId);
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Không thể tạo giỏ hàng cho khách hàng #" + customerId);
    }
 
    // ---------- PRODUCT VARIANT / ADDON (chỉ đọc, phục vụ kiểm tra tồn kho) ----------
 
    /**
     * Khoá dòng biến thể sản phẩm (SELECT ... FOR UPDATE) để tránh 2 request cùng lúc
     * vượt quá tồn kho khi thêm vào giỏ hàng.
     */
    public VariantSnapshot findVariantForUpdate(Connection conn, int variantId) throws SQLException {
        String sql = "SELECT pv.variant_id, pv.product_id, pv.price, pv.discount_price, "
                + "pv.stock_quantity, pv.is_active, p.status AS product_status "
                + "FROM product_variants pv "
                + "JOIN products p ON p.product_id = pv.product_id "
                + "WHERE pv.variant_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, variantId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                VariantSnapshot v = new VariantSnapshot();
                v.variantId = rs.getInt("variant_id");
                v.productId = rs.getInt("product_id");
                v.price = rs.getBigDecimal("price");
                v.discountPrice = rs.getBigDecimal("discount_price");
                v.stockQuantity = rs.getInt("stock_quantity");
                v.active = rs.getBoolean("is_active");
                v.productStatus = rs.getString("product_status");
                return v;
            }
        }
    }
 
    /** Lấy thông tin dịch vụ/phụ kiện đi kèm sản phẩm. */
    public AddonSnapshot findAddon(Connection conn, int addonId) throws SQLException {
        String sql = "SELECT addon_id, product_id, price_add, is_active "
                + "FROM product_addon_services WHERE addon_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, addonId);
            try (ResultSet rs = ps.executeQuery()) {
                if (!rs.next()) {
                    return null;
                }
                AddonSnapshot a = new AddonSnapshot();
                a.addonId = rs.getInt("addon_id");
                a.productId = rs.getInt("product_id");
                a.priceAdd = rs.getBigDecimal("price_add");
                a.active = rs.getBoolean("is_active");
                return a;
            }
        }
    }
 
    // ---------- VIEW CART (đọc, phục vụ hiển thị cart.jsp) ----------
 
    /**
     * Lấy toàn bộ dòng giỏ hàng của khách hàng, join sẵn tên sản phẩm, biến thể,
     * ảnh đại diện và dịch vụ đi kèm để JSP hiển thị trực tiếp, không cần query thêm.
     */
    public List<CartItemView> findCartItemsWithDetails(int customerId) throws SQLException {
        String sql = "SELECT ci.cart_item_id, ci.variant_id, ci.quantity, ci.addon_id, "
                + "p.name AS product_name, pv.variant_label, pv.price, pv.discount_price, pv.stock_quantity, "
                + "pi.file_path AS image_path, pas.name AS addon_name, pas.price_add "
                + "FROM cart c "
                + "JOIN cart_items ci ON ci.cart_id = c.cart_id "
                + "JOIN product_variants pv ON pv.variant_id = ci.variant_id "
                + "JOIN products p ON p.product_id = pv.product_id "
                + "LEFT JOIN product_images pi ON pi.product_id = p.product_id AND pi.is_primary = 1 "
                + "LEFT JOIN product_addon_services pas ON pas.addon_id = ci.addon_id "
                + "WHERE c.customer_id = ? "
                + "ORDER BY ci.added_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                List<CartItemView> items = new ArrayList<>();
                while (rs.next()) {
                    CartItemView v = new CartItemView();
                    v.setCartItemId(rs.getInt("cart_item_id"));
                    v.setVariantId(rs.getInt("variant_id"));
                    v.setProductName(rs.getString("product_name"));
                    v.setVariantLabel(rs.getString("variant_label"));
                    v.setImageUrl(rs.getString("image_path"));
                    v.setUnitPrice(rs.getBigDecimal("price"));
                    v.setDiscountPrice(rs.getBigDecimal("discount_price"));
                    v.setQuantity(rs.getInt("quantity"));
                    v.setStockQuantity(rs.getInt("stock_quantity"));
                    v.setAddonId((Integer) rs.getObject("addon_id"));
                    v.setAddonName(rs.getString("addon_name"));
                    v.setAddonPrice(rs.getBigDecimal("price_add"));
                    items.add(v);
                }
                return items;
            }
        }
    }
 
    /**
     * Tìm 1 dòng giỏ hàng theo cartItemId, đồng thời kiểm tra dòng đó thuộc về
     * đúng customerId (chống việc khách A sửa/xoá giỏ hàng của khách B).
     * Khoá dòng (FOR UPDATE) để dùng chung transaction khi cập nhật số lượng.
     */
    public CartItem findCartItemOwned(Connection conn, int cartItemId, int customerId) throws SQLException {
        String sql = "SELECT ci.cart_item_id, ci.cart_id, ci.variant_id, ci.quantity, ci.addon_id, ci.added_at "
                + "FROM cart_items ci "
                + "JOIN cart c ON c.cart_id = ci.cart_id "
                + "WHERE ci.cart_item_id = ? AND c.customer_id = ? FOR UPDATE";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartItemId);
            ps.setInt(2, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCartItem(rs) : null;
            }
        }
    }
 
    /**
     * Xoá 1 dòng giỏ hàng, chỉ xoá nếu đúng là của customerId truyền vào.
     * Trả về true nếu có dòng bị xoá.
     */
    public boolean removeCartItem(Connection conn, int cartItemId, int customerId) throws SQLException {
        String sql = "DELETE ci FROM cart_items ci "
                + "JOIN cart c ON c.cart_id = ci.cart_id "
                + "WHERE ci.cart_item_id = ? AND c.customer_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartItemId);
            ps.setInt(2, customerId);
            return ps.executeUpdate() > 0;
        }
    }
 
    // ---------- CART ITEMS ----------
 
    /**
     * Tìm dòng giỏ hàng hiện có theo (cartId, variantId, addonId).
     * Dùng cột sinh addon_id_norm (IFNULL(addon_id,0)) để so khớp NULL-safe,
     * đúng với UNIQUE KEY UX_cart_items_cart_variant_addon trong schema.
     */
    public CartItem findCartItem(Connection conn, int cartId, int variantId, Integer addonId) throws SQLException {
        String sql = "SELECT cart_item_id, cart_id, variant_id, quantity, addon_id, added_at "
                + "FROM cart_items "
                + "WHERE cart_id = ? AND variant_id = ? AND addon_id_norm = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, cartId);
            ps.setInt(2, variantId);
            ps.setInt(3, addonId == null ? 0 : addonId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? mapCartItem(rs) : null;
            }
        }
    }
 
    /** Thêm mới 1 dòng giỏ hàng, trả về cart_item_id vừa tạo. */
    public int insertCartItem(Connection conn, int cartId, int variantId, int quantity, Integer addonId)
            throws SQLException {
        String sql = "INSERT INTO cart_items (cart_id, variant_id, quantity, addon_id) VALUES (?,?,?,?)";
        try (PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setInt(1, cartId);
            ps.setInt(2, variantId);
            ps.setInt(3, quantity);
            if (addonId == null) {
                ps.setNull(4, Types.INTEGER);
            } else {
                ps.setInt(4, addonId);
            }
            ps.executeUpdate();
            try (ResultSet keys = ps.getGeneratedKeys()) {
                if (keys.next()) {
                    return keys.getInt(1);
                }
            }
        }
        throw new SQLException("Không thể thêm sản phẩm vào giỏ hàng");
    }
 
    /** Cập nhật số lượng cho 1 dòng giỏ hàng đã tồn tại. */
    public void updateCartItemQuantity(Connection conn, int cartItemId, int newQuantity) throws SQLException {
        String sql = "UPDATE cart_items SET quantity = ? WHERE cart_item_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, newQuantity);
            ps.setInt(2, cartItemId);
            ps.executeUpdate();
        }
    }
 
    /** Đếm tổng số lượng sản phẩm trong giỏ (dùng để hiển thị badge trên header). */
    public int countItemsInCart(int customerId) throws SQLException {
        String sql = "SELECT COALESCE(SUM(ci.quantity), 0) AS total_qty "
                + "FROM cart c JOIN cart_items ci ON ci.cart_id = c.cart_id "
                + "WHERE c.customer_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, customerId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next() ? rs.getInt("total_qty") : 0;
            }
        }
    }
 
    private CartItem mapCartItem(ResultSet rs) throws SQLException {
        Timestamp addedAt = rs.getTimestamp("added_at");
        Integer addonId = (Integer) rs.getObject("addon_id");
        return new CartItem(
                rs.getInt("cart_item_id"),
                rs.getInt("cart_id"),
                rs.getInt("variant_id"),
                rs.getInt("quantity"),
                addonId,
                addedAt != null ? addedAt.toLocalDateTime() : null
        );
    }
 
    // ---------- Snapshot nội bộ, chỉ để truyền dữ liệu đọc-được cho Service ----------
 
    public static class VariantSnapshot {
        public int variantId;
        public int productId;
        public int stockQuantity;
        public BigDecimal price;
        public BigDecimal discountPrice;
        public boolean active;
        public String productStatus;
 
        public BigDecimal effectivePrice() {
            return discountPrice != null ? discountPrice : price;
        }
    }
 
    public static class AddonSnapshot {
        public int addonId;
        public int productId;
        public BigDecimal priceAdd;
        public boolean active;
    }
}
