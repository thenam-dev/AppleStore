package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;

@WebFilter(urlPatterns = {"/add-address", "/update-address"})
public class AddressValidationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        request.setCharacterEncoding("UTF-8");

        if ("POST".equalsIgnoreCase(req.getMethod())) {
            String rName = request.getParameter("recipientName");
            String rPhone = request.getParameter("recipientPhone");
            String aDetail = request.getParameter("addressDetail");

            if (rName == null || rName.trim().isEmpty() || rName.length() > 100 ||
                rPhone == null || !rPhone.matches("^[0-9]{9,15}$") ||
                aDetail == null || aDetail.trim().isEmpty() || aDetail.length() > 500) {
                req.getSession().setAttribute("error", "Dữ liệu địa chỉ không hợp lệ. Vui lòng kiểm tra lại họ tên, SĐT và địa chỉ.");
                res.sendRedirect(req.getContextPath() + "/addresses");
                return;
            }
        }
        chain.doFilter(request, response);
    }
}
