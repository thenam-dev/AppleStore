package controller.delivery;

import config.AppConfig;
import model.entity.user.User;
import service.staff.order.StaffOrderService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;
import java.util.Map;

@WebServlet(name = "DeliveryTaskListServlet", urlPatterns = {"/staff/tasks"})
public class DeliveryTaskListServlet extends HttpServlet {

    private final StaffOrderService staffOrderService = new StaffOrderService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute(AppConfig.SESSION_USER) : null;

        if (user == null || !"DELIVERY".equals(user.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Map<String, Object>> tasks = staffOrderService.getShipperTasks(user.getUserId());
            req.setAttribute("tasks", tasks);
            
            // Xử lý chuyển Flash Message từ Session xuống Request theo PRG Pattern
            if (session.getAttribute("successMsg") != null) {
                req.setAttribute("successMsg", session.getAttribute("successMsg"));
                session.removeAttribute("successMsg");
            }
            if (session.getAttribute("errorMsg") != null) {
                req.setAttribute("errorMsg", session.getAttribute("errorMsg"));
                session.removeAttribute("errorMsg");
            }

            req.getRequestDispatcher("/WEB-INF/views/staff/tasks.jsp").forward(req, resp);
        } catch (Exception e) {
            getServletContext().log("Lỗi tại DeliveryTaskListServlet", e);
            req.setAttribute("errorMsg", "Lỗi tải danh sách: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/staff/tasks.jsp").forward(req, resp);
        }
    }
}