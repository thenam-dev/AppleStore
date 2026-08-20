package controller.customer.product;

import dao.catalog.CategoryDAO;
import dao.catalog.ProductDAO;
import model.entity.catalog.Category;
import model.entity.catalog.Product;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

/**
 * Trang danh sách sản phẩm cho khách hàng (guest).
 * URL: /products?keyword=&categoryId=&sort=&page=
 *
 * Dùng lại nguyên các hàm đã có trong DAO, KHÔNG thêm hàm mới:
 *   - CategoryDAO.findAllActive()                     -> chỉ lấy danh mục đang bật
 *   - ProductDAO.countAll(keyword, categoryId, status) -> luôn truyền cứng status = "ACTIVE"
 *   - ProductDAO.findAll(keyword, categoryId, status, sort, page, pageSize)
 *
 * LƯU Ý VỀ SORT: ProductDAO.resolveOrderBy() hỗ trợ các khoá:
 *   oldest, name_asc, name_desc, price_asc, price_desc, stock_asc, stock_desc,
 *   featured_desc (is_featured DESC), sold_desc (sold_quantity DESC)
 *   (mặc định khi không khớp/"newest": p.product_id DESC = mới nhất trước).
 * mapToDaoSort() map "featured" -> featured_desc, "best-selling" -> sold_desc.
 */
@WebServlet(name = "GuestProductListServlet", urlPatterns = {"/products"})
public class ProductListServlet extends ProductServletSupport {

    private static final String ACTIVE_STATUS = "ACTIVE";

    private final ProductDAO productDAO = new ProductDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            showProductList(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            showProductListFallback(request, response, ex.getMessage());
        }
    }

    private void showProductList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {

        String keyword = trimToNull(request.getParameter("keyword"));
        Integer categoryId = parseOptionalPositiveInt(
                request.getParameter("categoryId"), "Danh mục không hợp lệ");
        String uiSort = normalizeProductSort(request.getParameter("sort"));
        String daoSort = mapToDaoSort(uiSort);
        int pageSize = DEFAULT_PAGE_SIZE;

        int totalItems = productDAO.countAll(keyword, categoryId, ACTIVE_STATUS);
        int totalPages = calculateTotalPages(totalItems, pageSize);

        int currentPage = parsePage(request.getParameter("page"));
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        List<Product> productList =
                productDAO.findAll(keyword, categoryId, ACTIVE_STATUS, daoSort, currentPage, pageSize);
        List<Category> categories = categoryDAO.findAllActive();

        request.setAttribute("productList", productList);
        request.setAttribute("categories", categories);
        request.setAttribute("keyword", keyword);
        request.setAttribute("categoryId", categoryId);
        request.setAttribute("sort", uiSort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalItems", totalItems);
        request.setAttribute("lowStockThreshold", LOW_STOCK_THRESHOLD);

        request.getRequestDispatcher("/WEB-INF/views/guest/products-list.jsp").forward(request, response);
    }

    /** Map giá trị sort ở UI (dùng dấu gạch ngang) sang đúng key mà ProductDAO.resolveOrderBy() hiểu (dùng gạch dưới). */
    private String mapToDaoSort(String uiSort) {
        switch (uiSort) {
            case "price-asc":
                return "price_asc";
            case "price-desc":
                return "price_desc";
            case "best-selling":
                return "sold_desc";
            case "featured":
                return "featured_desc";
            case "newest":
            default:
                return null; // không khớp key nào trong DAO -> rơi về mặc định product_id DESC, đúng là "mới nhất"
        }
    }

    /** Fallback khi có lỗi tham số/SQL: vẫn render trang với danh sách rỗng + thông báo lỗi. */
    private void showProductListFallback(HttpServletRequest request, HttpServletResponse response,
                                          String message) throws ServletException, IOException {
        request.setAttribute("errorMsg", "Không tải được danh sách sản phẩm: " + message);
        request.setAttribute("productList", Collections.emptyList());
        request.setAttribute("categories", Collections.emptyList());
        request.setAttribute("keyword", null);
        request.setAttribute("categoryId", null);
        request.setAttribute("sort", "featured");
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalPages", 1);
        request.setAttribute("totalItems", 0);
        request.setAttribute("lowStockThreshold", LOW_STOCK_THRESHOLD);
        request.getRequestDispatcher("/WEB-INF/views/guest/products-list.jsp").forward(request, response);
    }
}