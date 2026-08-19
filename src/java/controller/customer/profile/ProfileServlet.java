/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer.profile;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.entity.user.User;
import service.user.UserService;

/**
 *
 * @author admin
 */
@WebServlet(name = "ProfileServlet", urlPatterns = {"/profile", "/update-profile"})
public class ProfileServlet extends HttpServlet {

    /**
     * Processes requests for both HTTP <code>GET</code> and <code>POST</code>
     * methods.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    protected void processRequest(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        response.setContentType("text/html;charset=UTF-8");
        try (PrintWriter out = response.getWriter()) {
            /* TODO output your page here. You may use following sample code. */
            out.println("<!DOCTYPE html>");
            out.println("<html>");
            out.println("<head>");
            out.println("<title>Servlet ProfileServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ProfileServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        // Nếu chưa đăng nhập, đá về trang login
        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Chuyển hướng tới file JSP tôi đã tạo cho bạn
        request.getRequestDispatcher("/WEB-INF/views/common/profile.jsp").forward(request, response);
    }

    /**
     * Handles the HTTP <code>POST</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        User currentUser = (User) session.getAttribute("user");

        if (currentUser == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // 1. Lấy dữ liệu từ Form (đã khai báo trong profile.jsp)
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        String avatarUrl = request.getParameter("avatarUrl");
        // 2. Cập nhật vào Object
        currentUser.setFullName(fullName);
        currentUser.setPhone(phone);
        currentUser.setAvatarUrl(avatarUrl);
        // 3. Gọi Service để update Database
        boolean isSuccess = userService.updateProfile(currentUser);
        if (isSuccess) {
            // Update lại session để giao diện cập nhật tên và ảnh ngay lập tức
            session.setAttribute("user", currentUser);
            request.setAttribute("message", "Profile updated successfully!");
        } else {
            request.setAttribute("error", "Failed to update profile. Please try again.");
        }
        // 4. Trả về lại trang profile kèm thông báo
        request.getRequestDispatcher("/WEB-INF/views/common/profile.jsp").forward(request, response);
    }
}
