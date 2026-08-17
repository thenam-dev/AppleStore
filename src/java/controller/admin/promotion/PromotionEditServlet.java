package controller.admin.promotion;

import model.entity.promtion.Promotion;
import model.entity.catalog.Category;
import model.entity.catalog.Product;
import service.promotion.PromotionService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.SQLException;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PromotionEditServlet", urlPatterns = {"/admin/promotions/edit"})
public class PromotionEditServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // 1. Tải dữ liệu bảng bên trái (Danh sách & KPI)
            String keyword = req.getParameter("keyword");
            String statusFilter = req.getParameter("status");
            String sortCol = req.getParameter("sortCol");
            String sortDir = req.getParameter("sortDir");

            int page = 1;
            int pageSize = 10;
            if (req.getParameter("page") != null) {
                try { page = Integer.parseInt(req.getParameter("page")); } catch (NumberFormatException ignored) {}
            }
            int offset = (page - 1) * pageSize;

            int totalRecords = promotionService.countAll(keyword, statusFilter);
            int totalPages = (int) Math.ceil((double) totalRecords / pageSize);
            List<Promotion> promotions = promotionService.findAllWithPaging(keyword, statusFilter, sortCol, sortDir, offset, pageSize);

            req.setAttribute("promotions", promotions);
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("keyword", keyword);
            req.setAttribute("statusFilter", statusFilter);
            req.setAttribute("sortCol", sortCol);
            req.setAttribute("sortDir", sortDir);
            req.setAttribute("activeCount", promotionService.countAll(null, "1"));
            req.setAttribute("totalRedeemed", promotionService.getTotalRedeemedCount());
            req.setAttribute("expiringSoon", promotionService.getExpiringSoonCount());
            req.setAttribute("dateFormatter", DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));

            // 2. Dropdown danh mục và sản phẩm
            List<Category> categories = new ArrayList<>();
            List<Product> products = new ArrayList<>();
            req.setAttribute("categories", categories);
            req.setAttribute("products", products);

            // 3. Tải thông tin mã cần sửa vào form bên phải
            String editId = req.getParameter("id");
            boolean isEdit = false;
            Promotion p = new Promotion();

            if (editId != null && !editId.trim().isEmpty()) {
                Promotion existingPromo = promotionService.getPromotionById(Integer.parseInt(editId));
                if (existingPromo != null) {
                    p = existingPromo;
                    isEdit = true;
                    
                    DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
                    if (p.getValidFrom() != null) {
                        req.setAttribute("validFromStr", p.getValidFrom().format(formatter));
                    }
                    if (p.getValidUntil() != null) {
                        req.setAttribute("validUntilStr", p.getValidUntil().format(formatter));
                    }
                } else {
                    req.setAttribute("errorMessage", "[BE] Không tìm thấy mã khuyến mãi yêu cầu.");
                }
            }
            
            req.setAttribute("promo", p);
            req.setAttribute("isEdit", isEdit);
            
            // Forward sang list.jsp thay vì form.jsp cũ
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);

        } catch (NumberFormatException numEx) {
            req.setAttribute("errorMessage", "[BE] Định dạng ID mã khuyến mãi không hợp lệ.");
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        } catch (SQLException sqlEx) {
            getServletContext().log("Lỗi DB tại PromotionEditServlet", sqlEx);
            req.setAttribute("errorMessage", "[BE] Lỗi kết nối cơ sở dữ liệu: " + sqlEx.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/list.jsp").forward(req, resp);
        }
    }
}