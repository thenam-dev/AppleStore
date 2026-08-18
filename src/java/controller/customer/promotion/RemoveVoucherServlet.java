package controller.customer.promotion;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet(name = "RemoveVoucherServlet", urlPatterns = {"/remove-voucher"})
public class RemoveVoucherServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession();

        // Xóa thông tin mã giảm giá khỏi Session
        session.removeAttribute("appliedPromo");
        session.removeAttribute("discountAmount");
        
        session.setAttribute("successMsg", "Đã gỡ bỏ mã khuyến mãi.");

        // Chuyển hướng về lại trang giỏ hàng
        resp.sendRedirect(req.getContextPath() + "/checkout");
    }
}