package service.review;

import dao.review.ReviewDAO;
import model.entity.review.Review;
import java.sql.SQLException;
import java.util.List;

public class ReviewService {
    private final ReviewDAO reviewDAO = new ReviewDAO();

    /** Lấy toàn bộ đánh giá (không bị ẩn) của một sản phẩm, dùng cho trang chi tiết sản phẩm. */
    public List<Review> getReviewsByProductId(int productId) throws SQLException {
        return reviewDAO.getReviewsByProductId(productId);
    }

    public boolean submitReview(int customerId, int orderId, int orderItemId, int rating, String text) throws SQLException {
        // 1. Kiểm tra xem user đã đánh giá sản phẩm này trong đơn hàng này chưa
        Review existingReview = reviewDAO.getReviewByItemAndCustomer(orderItemId, customerId);
        if (existingReview != null) {
            return false; // Đã đánh giá rồi
        }
        
        Review review = new Review(orderItemId, orderId, customerId, rating, text);
        // Gọi hàm DAO đã được bảo vệ chống IDOR
        return reviewDAO.insertReviewSecure(review);
    }
    
    public Review getReview(int orderItemId, int customerId) throws SQLException {
        return reviewDAO.getReviewByItemAndCustomer(orderItemId, customerId);
    }
}