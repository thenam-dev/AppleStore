package controller.admin.promotion;

import model.entity.promtion.Promotion;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet(name = "PromotionListServlet", urlPatterns = {"/admin/promotions"})
public class PromotionListServlet extends PromotionServletSupport {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        try {
            String keyword = req.getParameter("keyword");
            String status = normalizeStatusFilter(req.getParameter("status"));
            String sort = normalizeSort(req.getParameter("sort"));

            int page = parseIntOrDefault(req.getParameter("page"), 1);
            int pageSize = config.AppConfig.PAGE_SIZE_ADMIN;
            int offset = Math.max(0, (page - 1) * pageSize);

            int totalRecords = promotionService.countAll(keyword, status);
            int totalPages = Math.max(1, (int) Math.ceil((double) totalRecords / pageSize));
            if (page > totalPages) {
                page = totalPages;
                offset = (page - 1) * pageSize;
            }

            List<Promotion> promotions = promotionService.findAllWithPaging(keyword, status, sort, offset, pageSize);
            String listQuery = buildListQueryString(keyword, status, sort);

            // KPIs
            int activeCount = promotionService.countAll(null, "ACTIVE");
            long totalRedeemed = promotionService.getTotalRedeemedCount();
            int expiringSoon = promotionService.getExpiringSoonCount();

            req.setAttribute("dateFormatter", DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm"));
            req.setAttribute("promotions", promotions);
            req.setAttribute("keyword", keyword);
            req.setAttribute("selectedStatus", status);
            req.setAttribute("selectedSort", sort);
            req.setAttribute("sortOptions", buildSortOptions());
            
            req.setAttribute("currentPage", page);
            req.setAttribute("totalPages", totalPages);
            req.setAttribute("listQuery", listQuery);
            req.setAttribute("listQuerySuffix", listQuery.isBlank() ? "" : "&" + listQuery);

            req.setAttribute("totalRecords", totalRecords);
            req.setAttribute("activeCount", activeCount);
            req.setAttribute("totalRedeemed", totalRedeemed);
            req.setAttribute("expiringSoon", expiringSoon);

            moveFlashMessagesToRequest(req);
            req.getRequestDispatcher(LIST_VIEW).forward(req, resp);

        } catch (Exception e) {
            getServletContext().log("Lỗi tại PromotionListServlet", e);
            req.setAttribute(FLASH_ERROR_KEY, "Đã xảy ra lỗi hệ thống: " + e.getMessage());
            req.getRequestDispatcher(LIST_VIEW).forward(req, resp);
        }
    }
}