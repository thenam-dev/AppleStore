package controller.admin.user;

import model.entity.user.User;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.Collections;
import java.util.List;

@WebServlet(name = "UserListServlet", urlPatterns = {"/admin/users"})
public class UserListServlet extends UserServletSupport {
    /** Mở danh sách người dùng và chuyển sang fallback nếu filter hoặc DB lỗi. */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            showUserList(request, response);
        } catch (SQLException | IllegalArgumentException ex) {
            showUserListFallback(request, response, ex.getMessage());
        }
    }

    /** Lấy filter, phân trang và dữ liệu hiển thị rồi forward sang list.jsp của user. */
    private void showUserList(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        String keyword = request.getParameter("keyword");
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        String sort = normalizeUserSort(request.getParameter("sort"));
        int currentPage = parsePage(request.getParameter("page"));
        int pageSize = config.AppConfig.PAGE_SIZE_ADMIN;
        int totalUsers = userService.countUsers(keyword, role, status);
        int totalPages = calculateTotalPages(totalUsers, pageSize);
        if (currentPage > totalPages) {
            currentPage = totalPages;
        }

        List<User> users = userService.getUsers(keyword, role, status, sort, currentPage, pageSize);
        String listQuery = buildUserListQueryString(keyword, role, status, sort);

        request.setAttribute("users", users);
        setUserReferenceData(request);
        setUserListViewData(request, users);
        request.setAttribute("keyword", keyword);
        request.setAttribute("selectedRole", role);
        request.setAttribute("selectedStatus", status);
        request.setAttribute("selectedSort", sort);
        request.setAttribute("currentPage", currentPage);
        request.setAttribute("totalPages", totalPages);
        request.setAttribute("totalUsers", totalUsers);
        request.setAttribute("listQuery", listQuery);
        request.setAttribute("listQuerySuffix", listQuery.isBlank() ? "" : "&" + listQuery);
        moveFlashMessagesToRequest(request);

        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }

    /** Chuẩn bị dữ liệu rỗng để màn user list vẫn render được khi truy vấn thất bại. */
    private void showUserListFallback(HttpServletRequest request, HttpServletResponse response, String message)
            throws ServletException, IOException {
        request.setAttribute("users", Collections.emptyList());
        request.setAttribute(FLASH_ERROR_KEY, message);
        setUserReferenceData(request);
        setUserListViewData(request, Collections.emptyList());
        request.setAttribute("selectedSort", "created_desc");
        request.setAttribute("currentPage", 1);
        request.setAttribute("totalPages", 1);
        request.setAttribute("totalUsers", 0);
        request.setAttribute("listQuery", "");
        request.setAttribute("listQuerySuffix", "");
        request.getRequestDispatcher(LIST_VIEW).forward(request, response);
    }
}
