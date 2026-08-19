package service.review;

import dao.review.ReviewDAO;
import model.entity.review.Review;

public class ReviewService {
    private final ReviewDAO reviewDAO = new ReviewDAO();

    public boolean submitReview(int customerId, int orderId, int orderItemId, int rating, String text) {
        // 1. Kiểm tra xem user đã đánh giá sản phẩm này chưa
        Review existingReview = reviewDAO.getReviewByItemAndCustomer(orderItemId, customerId);
        if (existingReview != null) {
            return false; // Đã đánh giá rồi
        }
        
        // (Tùy chọn) Có thể check thêm DAO order để chắc chắn order_id này thuộc về customerId và trạng thái là DELIVERED
        
        Review review = new Review(orderItemId, orderId, customerId, rating, text);
        return reviewDAO.insertReview(review);
    }
    
    public Review getReview(int orderItemId, int customerId) {
        return reviewDAO.getReviewByItemAndCustomer(orderItemId, customerId);
    }
}