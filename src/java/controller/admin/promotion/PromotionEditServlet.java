package controller.admin.promotion;

import model.Promotion;
//import model.Category;
//import model.Product;
import service.promotion.PromotionService;
import util.DBConnection; // Hoặc cách kết nối DB của nhóm bạn
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "PromotionEditServlet", urlPatterns = {"/admin/promotions/edit"})
public class PromotionEditServlet extends HttpServlet {

    private final PromotionService promotionService = new PromotionService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            // === PHẦN NÀY ĐỒNG ĐỘI LÀM XONG SERVICE/DAO THÌ BẠN BỎ COMMENT RA ===
            /*
            List<Category> categories = new ArrayList<>();
            List<Product> products = new ArrayList<>();
            
            try (Connection conn = DBConnection.getConnection()) {
                // Lấy danh sách Categories từ bảng categories
                try (PreparedStatement ps = conn.prepareStatement("SELECT category_id, name FROM categories WHERE is_active = 1")) {
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        Category c = new Category();
                        c.setCategoryId(rs.getInt("category_id"));
                        c.setName(rs.getString("name"));
                        categories.add(c);
                    }
                }
                
                // Lấy danh sách Products từ bảng products
                try (PreparedStatement ps = conn.prepareStatement("SELECT product_id, name FROM products WHERE status = 'ACTIVE'")) {
                    ResultSet rs = ps.executeQuery();
                    while (rs.next()) {
                        Product pr = new Product();
                        pr.setProductId(rs.getInt("product_id"));
                        pr.setName(rs.getString("name"));
                        products.add(pr);
                    }
                }
            }
            
            req.setAttribute("categories", categories);
            req.setAttribute("products", products);
            */
            // ===================================================================

            String editId = req.getParameter("id");
            if (editId != null && !editId.trim().isEmpty()) {
                Promotion p = promotionService.getPromotionById(Integer.parseInt(editId));
                req.setAttribute("promo", p);
            }
            
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Lỗi tải dữ liệu: " + e.getMessage());
            req.getRequestDispatcher("/WEB-INF/views/admin/promotions/form.jsp").forward(req, resp);
        }
    }
}