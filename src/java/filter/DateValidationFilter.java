package filter;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDate;
import java.time.format.DateTimeParseException;

@WebFilter(urlPatterns = {"/admin/dashboard"})
public class DateValidationFilter implements Filter {

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String startDateStr = req.getParameter("startDate");
        String endDateStr = req.getParameter("endDate");

        if (startDateStr != null && !startDateStr.isEmpty() && endDateStr != null && !endDateStr.isEmpty()) {
            try {
                LocalDate startDate = LocalDate.parse(startDateStr);
                LocalDate endDate = LocalDate.parse(endDateStr);

                if (startDate.isAfter(endDate)) {
                    HttpSession session = req.getSession();
                    session.setAttribute("errorMessage", "Ngày bắt đầu không được lớn hơn ngày kết thúc.");
                    res.sendRedirect(req.getContextPath() + "/admin/dashboard");
                    return; 
                }
            } catch (DateTimeParseException e) {
                // Bỏ qua lỗi parse
            }
        }
        
        chain.doFilter(request, response);
    }
}
