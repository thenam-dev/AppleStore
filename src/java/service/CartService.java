/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service;

import dao.CartDAO;
import dao.CartDAO.AddonSnapshot;
import dao.CartDAO.VariantSnapshot;
import model.CartItem;
import model.CartItemView;
import util.DBConnection;
 
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.List;
/**
 *
 * @author ACER
 */
public class CartService {
    /** Giới hạn hợp lý cho mỗi lần bấm "Thêm vào giỏ hàng". */
    private static final int MAX_QUANTITY_PER_ADD = 10;
 
    private final CartDAO cartDAO;
 
    public CartService() {
        this(new CartDAO());
    }
 
    public CartService(CartDAO cartDAO) {
        this.cartDAO = cartDAO;
    }
    public CartItem addToCart(int customerId, int variantId, Integer addonId, int quantity) throws SQLException {
        validateQuantity(quantity);
 
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
 
            VariantSnapshot variant = loadAndValidateVariant(conn, variantId);
            validateAddon(conn, addonId, variant.productId);
 
            int cartId = findOrCreateCart(conn, customerId);
 
            CartItem existing = cartDAO.findCartItem(conn, cartId, variantId, addonId);
            int newQuantity = (existing != null) ? existing.getQuantity() + quantity : quantity;
 
            if (newQuantity > variant.stockQuantity) {
                throw new IllegalArgumentException(
                        "Số lượng vượt quá tồn kho. Hiện chỉ còn " + variant.stockQuantity + " sản phẩm.");
            }
 
            int cartItemId;
            if (existing != null) {
                cartDAO.updateCartItemQuantity(conn, existing.getCartItemId(), newQuantity);
                cartItemId = existing.getCartItemId();
            } else {
                cartItemId = cartDAO.insertCartItem(conn, cartId, variantId, quantity, addonId);
            }
 
            conn.commit();
 
            CartItem result = new CartItem();
            result.setCartItemId(cartItemId);
            result.setCartId(cartId);
            result.setVariantId(variantId);
            result.setQuantity(newQuantity);
            result.setAddonId(addonId);
            return result;
 
        } catch (SQLException | IllegalArgumentException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            closeQuietly(conn);
        }
    }
 
    /** Đếm tổng số lượng sản phẩm trong giỏ hàng, dùng để hiển thị badge trên header. */
    public int countItemsInCart(int customerId) throws SQLException {
        return cartDAO.countItemsInCart(customerId);
    }
 
    /** Lấy danh sách chi tiết giỏ hàng (đã join tên sản phẩm/biến thể/addon) để hiển thị cart.jsp. */
    public List<CartItemView> getCartItems(int customerId) throws SQLException {
        return cartDAO.findCartItemsWithDetails(customerId);
    }
 
    /** Tính tổng tiền hàng (chưa gồm phí ship/giảm giá, các khoản đó tính ở bước checkout). */
    public BigDecimal getCartSubtotal(List<CartItemView> items) {
        BigDecimal total = BigDecimal.ZERO;
        for (CartItemView item : items) {
            total = total.add(item.getSubtotal());
        }
        return total;
    }
 
    /** Đếm tổng số lượng sản phẩm từ danh sách đã lấy sẵn, tránh phải query DB thêm lần nữa. */
    public int countItemsInCart(List<CartItemView> items) {
        int total = 0;
        for (CartItemView item : items) {
            total += item.getQuantity();
        }
        return total;
    }
 
    /**
     * Cập nhật số lượng cho 1 dòng giỏ hàng của khách hàng (khi bấm +/- rồi "Cập nhật" trên cart.jsp).
     * Kiểm tra dòng đó đúng thuộc về customerId và số lượng mới không vượt tồn kho hiện tại.
     */
    public void updateQuantity(int customerId, int cartItemId, int quantity) throws SQLException {
        validateQuantity(quantity);
 
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);
 
            CartItem owned = cartDAO.findCartItemOwned(conn, cartItemId, customerId);
            if (owned == null) {
                throw new IllegalArgumentException("Sản phẩm không tồn tại trong giỏ hàng của bạn.");
            }
 
            VariantSnapshot variant = cartDAO.findVariantForUpdate(conn, owned.getVariantId());
            if (variant == null || !variant.active) {
                throw new IllegalArgumentException("Sản phẩm không còn tồn tại hoặc đã ngừng kinh doanh.");
            }
            if (quantity > variant.stockQuantity) {
                throw new IllegalArgumentException(
                        "Số lượng vượt quá tồn kho. Hiện chỉ còn " + variant.stockQuantity + " sản phẩm.");
            }
 
            cartDAO.updateCartItemQuantity(conn, cartItemId, quantity);
            conn.commit();
 
        } catch (SQLException | IllegalArgumentException ex) {
            rollbackQuietly(conn);
            throw ex;
        } finally {
            closeQuietly(conn);
        }
    }
 
    /** Xoá 1 dòng giỏ hàng của khách hàng (khi bấm "Remove" trên cart.jsp). */
    public void removeItem(int customerId, int cartItemId) throws SQLException {
        try (Connection conn = DBConnection.getConnection()) {
            boolean removed = cartDAO.removeCartItem(conn, cartItemId, customerId);
            if (!removed) {
                throw new IllegalArgumentException("Sản phẩm không tồn tại trong giỏ hàng của bạn.");
            }
        }
    }
 
    // ---------- Helpers ----------
 
    private void validateQuantity(int quantity) {
        if (quantity < 1) {
            throw new IllegalArgumentException("Số lượng phải lớn hơn 0.");
        }
        if (quantity > MAX_QUANTITY_PER_ADD) {
            throw new IllegalArgumentException("Chỉ được thêm tối đa " + MAX_QUANTITY_PER_ADD + " sản phẩm mỗi lần.");
        }
    }
 
    private VariantSnapshot loadAndValidateVariant(Connection conn, int variantId) throws SQLException {
        VariantSnapshot variant = cartDAO.findVariantForUpdate(conn, variantId);
        if (variant == null || !variant.active) {
            throw new IllegalArgumentException("Sản phẩm không tồn tại hoặc đã ngừng kinh doanh.");
        }
        if (!"ACTIVE".equals(variant.productStatus)) {
            throw new IllegalArgumentException("Sản phẩm hiện không còn được bán.");
        }
        if (variant.stockQuantity <= 0) {
            throw new IllegalArgumentException("Sản phẩm hiện đã hết hàng.");
        }
        return variant;
    }
 
    private void validateAddon(Connection conn, Integer addonId, int productId) throws SQLException {
        if (addonId == null) {
            return;
        }
        AddonSnapshot addon = cartDAO.findAddon(conn, addonId);
        if (addon == null || !addon.active || addon.productId != productId) {
            throw new IllegalArgumentException("Dịch vụ/phụ kiện đi kèm không hợp lệ.");
        }
    }
 
    private int findOrCreateCart(Connection conn, int customerId) throws SQLException {
        Integer cartId = cartDAO.findCartIdByCustomer(conn, customerId);
        if (cartId == null) {
            cartId = cartDAO.createCart(conn, customerId);
        }
        return cartId;
    }
 
    private void rollbackQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.rollback();
            } catch (SQLException ignore) {
                // đã đang xử lý lỗi chính, bỏ qua lỗi rollback phụ
            }
        }
    }
 
    private void closeQuietly(Connection conn) {
        if (conn != null) {
            try {
                conn.setAutoCommit(true);
                conn.close();
            } catch (SQLException ignore) {
                // ignore
            }
        }
    }
}
