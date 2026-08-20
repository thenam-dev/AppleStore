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
        String type = req.getParameter("type"); // Lấy tham số type từ URL

        if ("shipping".equals(type)) {
            session.removeAttribute("shippingPromo");
            session.removeAttribute("shippingDiscount");
            session.setAttribute("successMsg", "Đã gỡ bỏ mã miễn phí vận chuyển.");
        } else if ("merchandise".equals(type)) {
            session.removeAttribute("merchandisePromo");
            session.removeAttribute("merchandiseDiscount");
            session.setAttribute("successMsg", "Đã gỡ bỏ mã giảm giá hàng hóa.");
        } else {
            // Đề phòng trường hợp type trống, xóa sạch cho an toàn
            session.removeAttribute("shippingPromo");
            session.removeAttribute("shippingDiscount");
            session.removeAttribute("merchandisePromo");
            session.removeAttribute("merchandiseDiscount");
            session.setAttribute("successMsg", "Đã gỡ bỏ mã khuyến mãi.");
        }

        resp.sendRedirect(req.getContextPath() + "/checkout");
    }
}