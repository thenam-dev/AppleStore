/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service.cart;

import dao.cart.CartDAO;
import dao.catalog.ProductVariantDAO;
import model.entity.cart.CartItem;

import java.sql.SQLException;
import java.util.List;
import java.util.Optional;
/**
 * Business rule + validation cho giỏ hàng (rule 2). Service chỉ gọi DAO,
 * không tự mở Connection hay viết SQL - mỗi hàm DAO tự quản Connection riêng
 * (theo form CategoryDAO).
 * @author ACER
 */
public class CartService {

    private final CartDAO cartDAO;
    private final ProductVariantDAO productVariantDAO;

    public CartService() {
        this(new CartDAO(), new ProductVariantDAO());
    }

    public CartService(CartDAO cartDAO, ProductVariantDAO productVariantDAO) {
        this.cartDAO = cartDAO;
        this.productVariantDAO = productVariantDAO;
    }

    public static class Result {
        private final boolean success;
        private final String message;

        public Result(boolean success, String message) {
            this.success = success;
            this.message = message;
        }

        public boolean isSuccess() {
            return success;
        }

        public String getMessage() {
            return message;
        }
    }

    /**
     * Thêm sản phẩm vào giỏ hàng.
     * Validate: quantity phải > 0, sản phẩm phải đang bán, không vượt tồn kho.
     * Lưu ý: giữa bước kiểm tra tồn kho và bước insert không còn nằm trong
     * cùng 1 transaction, nên vẫn có khả năng (hiếm) 2 request chạy đúng lúc
     * cùng vượt qua kiểm tra - chấp nhận theo lựa chọn pattern DAO của team.
     */
    public Result addToCart(int customerId, int variantId, int quantity, Integer addonId) {
        if (quantity <= 0) {
            return new Result(false, "Số lượng phải lớn hơn 0");
        }
        if (quantity > 10) {
            return new Result(false, "Mỗi lần chỉ được thêm tối đa 10 sản phẩm");
        }

        try {
            int cartId = cartDAO.getOrCreateCartId(customerId);
            int existingQty = cartDAO.findExistingQuantity(cartId, variantId, addonId);

            Optional<Integer> stock = productVariantDAO.findStockQuantity(variantId);
            if (stock.isEmpty()) {
                return new Result(false, "Sản phẩm không tồn tại hoặc đã ngừng bán");
            }
            if (existingQty + quantity > stock.get()) {
                return new Result(false, "Chỉ còn " + stock.get() + " sản phẩm trong kho (giỏ hàng hiện có " + existingQty + ")");
            }

            cartDAO.upsertCartItem(cartId, variantId, quantity, addonId);
            return new Result(true, "Đã thêm vào giỏ hàng");
        } catch (SQLException e) {
            return new Result(false, "Lỗi hệ thống: " + e.getMessage());
        }
    }

    public Result updateQuantity(int customerId, int cartItemId, int quantity) {
        if (quantity <= 0) {
            return new Result(false, "Số lượng phải lớn hơn 0");
        }

        try {
            int cartId = cartDAO.getOrCreateCartId(customerId);
            CartItem target = cartDAO.findById(cartItemId, cartId)
                    .orElse(null);

            if (target == null) {
                return new Result(false, "Không tìm thấy sản phẩm trong giỏ hàng");
            }
            if (quantity > target.getStockQuantity()) {
                return new Result(false, "Chỉ còn " + target.getStockQuantity() + " sản phẩm trong kho");
            }

            cartDAO.updateQuantity(cartItemId, cartId, quantity);
            return new Result(true, "Đã cập nhật số lượng");
        } catch (SQLException e) {
            return new Result(false, "Lỗi hệ thống: " + e.getMessage());
        }
    }

    public Result removeItem(int customerId, int cartItemId) {
        try {
            int cartId = cartDAO.getOrCreateCartId(customerId);
            boolean removed = cartDAO.deleteCartItem(cartItemId, cartId);
            if (!removed) {
                return new Result(false, "Không tìm thấy sản phẩm trong giỏ hàng");
            }
            return new Result(true, "Đã xoá sản phẩm khỏi giỏ hàng");
        } catch (SQLException e) {
            return new Result(false, "Lỗi hệ thống: " + e.getMessage());
        }
    }

    /** Lấy danh sách giỏ hàng để hiển thị cart.jsp. */
    public List<CartItem> getCartItems(int customerId) {
        try {
            return cartDAO.findByCustomerId(customerId);
        } catch (SQLException e) {
            throw new RuntimeException("Không lấy được giỏ hàng: " + e.getMessage(), e);
        }
    }
}
