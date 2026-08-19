package dao.review;

import model.entity.review.Review;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

public class ReviewDAO {

    public boolean insertReview(Review review) {
        String insertSql = "INSERT INTO reviews (order_item_id, order_id, customer_id, rating, review_text) VALUES (?, ?, ?, ?, ?)";

        // Câu lệnh cập nhật lại rating trung bình cho sản phẩm tương ứng
        String updateProductRatingSql = """
        UPDATE products p
        SET p.rating = (
            SELECT COALESCE(ROUND(AVG(r.rating), 2), 0)
            FROM reviews r
            JOIN order_items oi ON r.order_item_id = oi.order_item_id
            JOIN product_variants pv ON oi.variant_id = pv.variant_id
            WHERE pv.product_id = ? AND r.is_hidden = 0
        )
        WHERE p.product_id = ?
    """;

        try (Connection conn = DBConnection.getConnection()) {
            conn.setAutoCommit(false); // Dùng giao dịch (Transaction) để đảm bảo an toàn dữ liệu

            int productId = -1;
            // 1. Lấy productId từ order_item_id của review đang gửi
            String getProductSql = "SELECT pv.product_id FROM order_items oi JOIN product_variants pv ON oi.variant_id = pv.variant_id WHERE oi.order_item_id = ?";
            try (PreparedStatement psGet = conn.prepareStatement(getProductSql)) {
                psGet.setInt(1, review.getOrderItemId());
                try (ResultSet rs = psGet.executeQuery()) {
                    if (rs.next()) {
                        productId = rs.getInt("product_id");
                    }
                }
            }

            // 2. Insert review mới vào bảng reviews
            try (PreparedStatement psInsert = conn.prepareStatement(insertSql)) {
                psInsert.setInt(1, review.getOrderItemId());
                psInsert.setInt(2, review.getOrderId());
                psInsert.setInt(3, review.getCustomerId());
                psInsert.setInt(4, review.getRating());
                psInsert.setString(5, review.getReviewText());
                psInsert.executeUpdate();
            }

            // 3. Nếu tìm thấy productId, tiến hành tính lại và cập nhật rating cho sản phẩm đó
            if (productId > 0) {
                try (PreparedStatement psUpdate = conn.prepareStatement(updateProductRatingSql)) {
                    psUpdate.setInt(1, productId);
                    psUpdate.setInt(2, productId);
                    psUpdate.executeUpdate();
                }
            }

            conn.commit();
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Review getReviewByItemAndCustomer(int orderItemId, int customerId) {
        String sql = "SELECT * FROM reviews WHERE order_item_id = ? AND customer_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, orderItemId);
            ps.setInt(2, customerId);

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setOrderItemId(rs.getInt("order_item_id"));
                    r.setOrderId(rs.getInt("order_id"));
                    r.setCustomerId(rs.getInt("customer_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setReviewText(rs.getString("review_text"));
                    r.setReviewImageUrl(rs.getString("review_image_url"));
                    r.setHidden(rs.getBoolean("is_hidden"));

                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        r.setCreatedAt(new Date(ts.getTime()));
                    }
                    return r;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Review> getReviewsByProductId(int productId) throws SQLException {
        List<Review> list = new ArrayList<>();
        // Sử dụng LEFT JOIN và điều kiện linh hoạt để lấy trọn vẹn tất cả đánh giá của sản phẩm này
        String sql = "SELECT DISTINCT r.*, u.full_name, oi.variant_label_snapshot "
                + "FROM reviews r "
                + "JOIN users u ON r.customer_id = u.user_id "
                + "JOIN order_items oi ON r.order_item_id = oi.order_item_id "
                + "LEFT JOIN product_variants pv ON oi.variant_id = pv.variant_id "
                + "WHERE (pv.product_id = ? OR oi.variant_id IN (SELECT variant_id FROM product_variants WHERE product_id = ?)) "
                + "AND r.is_hidden = 0 "
                + "ORDER BY r.created_at DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setInt(1, productId);
            ps.setInt(2, productId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Review r = new Review();
                    r.setReviewId(rs.getInt("review_id"));
                    r.setOrderItemId(rs.getInt("order_item_id"));
                    r.setOrderId(rs.getInt("order_id"));
                    r.setCustomerId(rs.getInt("customer_id"));
                    r.setRating(rs.getInt("rating"));
                    r.setReviewText(rs.getString("review_text"));
                    r.setReviewImageUrl(rs.getString("review_image_url"));
                    r.setHidden(rs.getBoolean("is_hidden"));

                    Timestamp ts = rs.getTimestamp("created_at");
                    if (ts != null) {
                        r.setCreatedAt(new Date(ts.getTime()));
                    }

                    r.setCustomerName(rs.getString("full_name"));
                    r.setVariantLabel(rs.getString("variant_label_snapshot"));

                    list.add(r);
                }
            }
        }
        return list;
    }
}
