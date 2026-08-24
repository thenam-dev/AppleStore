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

    private UserService userService = new UserService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
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

        // 1. Lấy dữ liệu từ Form
        String fullName = request.getParameter("fullName");
        String phone = request.getParameter("phone");
        
        // 2. Cập nhật vào Object
        currentUser.setFullName(fullName);
        currentUser.setPhone(phone);
        
        // 3. Gọi Service để update Database
        String resultMessage = userService.updateProfile(currentUser);
        
        if ("SUCCESS".equals(resultMessage)) {
            // Update lại session để giao diện cập nhật tên và ảnh ngay lập tức
            session.setAttribute("user", currentUser);
            request.setAttribute("message", "Cập nhật hồ sơ thành công!");
        } else {
            request.setAttribute("errorMsg", resultMessage);
        }
        
        // 4. Trả về lại trang profile kèm thông báo
        request.getRequestDispatcher("/WEB-INF/views/common/profile.jsp").forward(request, response);
    }
}
