package controller.admin.customer;

import config.AppConfig;
import model.entity.user.User;
import service.user.UserService;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "CustomerListServlet", urlPatterns = {"/admin/customers"})
public class CustomerListServlet extends HttpServlet {
    private static final String VIEW = "/WEB-INF/views/admin/customers/list.jsp";
    private final UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String status = request.getParameter("status");
        String sort = normalizeSort(request.getParameter("sort"));
        int currentPage = parsePage(request.getParameter("page"));
        int pageSize = AppConfig.PAGE_SIZE_ADMIN;

        try {
            int totalCustomers = userService.countCustomers(keyword, status);
            int totalPages = Math.max(1, (int) Math.ceil((double) totalCustomers / pageSize));
            if (currentPage > totalPages) {
                currentPage = totalPages;
            }

            List<User> customers = userService.getCustomers(keyword, status, sort, currentPage, pageSize);
            String listQuery = buildListQuery(keyword, status, sort);
            request.setAttribute("customers", customers);
            request.setAttribute("totalCustomers", totalCustomers);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("listQuery", listQuery);
            request.setAttribute("listQuerySuffix", listQuery.isBlank() ? "" : "&" + listQuery);
        } catch (SQLException | IllegalArgumentException ex) {
            request.setAttribute("customers", Collections.emptyList());
            request.setAttribute("totalCustomers", 0);
            request.setAttribute("totalPages", 1);
            request.setAttribute("listQuery", "");
            request.setAttribute("listQuerySuffix", "");
            request.setAttribute("errorMsg", ex.getMessage());
        }

        request.setAttribute("statuses", userService.getAllowedStatuses());
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("currentPage", currentPage);
        request.getRequestDispatcher(VIEW).forward(request, response);
    }

    private String buildListQuery(String keyword, String status, String sort) {
        StringBuilder query = new StringBuilder();
        appendQueryParam(query, "keyword", keyword);
        appendQueryParam(query, "status", status);
        appendQueryParam(query, "sort", sort);
        return query.toString();
    }

    private void appendQueryParam(StringBuilder query, String key, String value) {
        if (value == null || value.isBlank()) {
            return;
        }
        if (!query.isEmpty()) {
            query.append('&');
        }
        query.append(key)
                .append('=')
                .append(URLEncoder.encode(value, StandardCharsets.UTF_8));
    }

    private int parsePage(String value) {
        try {
            int parsed = Integer.parseInt(value);
            return parsed > 0 ? parsed : 1;
        } catch (NumberFormatException ex) {
            return 1;
        }
    }

    private String normalizeSort(String sort) {
        if (sort == null || sort.isBlank()) {
            return "created_desc";
        }
        return sort.trim().toLowerCase();
    }
}
