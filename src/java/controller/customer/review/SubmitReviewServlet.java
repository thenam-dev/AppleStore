package controller.customer.review;

import config.AppConfig;
import model.entity.user.User;
import service.review.ReviewService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "SubmitReviewServlet", urlPatterns = {"/account/order/review"})
public class SubmitReviewServlet extends HttpServlet {

    private final ReviewService reviewService = new ReviewService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AppConfig.SESSION_USER) : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int orderId = Integer.parseInt(req.getParameter("orderId"));
        try {
            int orderItemId = Integer.parseInt(req.getParameter("orderItemId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String text = req.getParameter("reviewText");

            boolean success = reviewService.submitReview(user.getUserId(), orderId, orderItemId, rating, text);

            if (success) {
                session.setAttribute("successMsg", "Cảm ơn bạn đã gửi đánh giá!");
            } else {
                session.setAttribute("errorMsg", "Bạn đã đánh giá sản phẩm này rồi.");
            }
        } catch (Exception e) {
            session.setAttribute("errorMsg", "Dữ liệu đánh giá không hợp lệ.");
        }
        
        // Quay lại đúng trang chi tiết đơn hàng (PRG Pattern)
        resp.sendRedirect(req.getContextPath() + "/account/order-detail?id=" + orderId);
    }
}