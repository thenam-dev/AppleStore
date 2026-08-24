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
        req.setCharacterEncoding("UTF-8"); // BẮT BUỘC THEO RULE 3
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AppConfig.SESSION_USER) : null;

        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        int orderId = 0;
        try {
            orderId = Integer.parseInt(req.getParameter("orderId"));
            int orderItemId = Integer.parseInt(req.getParameter("orderItemId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String text = req.getParameter("reviewText");

            boolean success = reviewService.submitReview(user.getUserId(), orderId, orderItemId, rating, text);

            if (success) {
                session.setAttribute("successMsg", "Cảm ơn bạn đã gửi đánh giá sản phẩm thành công!");
            } else {
                session.setAttribute("errorMsg", "Gửi đánh giá thất bại. Bạn đã đánh giá sản phẩm này hoặc đơn hàng không hợp lệ.");
            }
        } catch (Exception e) {
            getServletContext().log("Lỗi tại SubmitReviewServlet", e);
            session.setAttribute("errorMsg", "Dữ liệu đánh giá không hợp lệ.");
        }
        
        // Điều hướng PRG Pattern về lại trang chi tiết đơn hàng (Rule 10)
        resp.sendRedirect(req.getContextPath() + "/account/order-detail?id=" + orderId);
    }
}