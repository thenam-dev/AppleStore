/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.auth;

import dao.user.UserDAO;
import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

/**
 *
 * @author admin
 */
@WebServlet(name = "ForgotPasswordServlet", urlPatterns = {"/forgot-password"})
public class ForgotPasswordServlet extends HttpServlet {

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
            out.println("<title>Servlet ForgotPasswordServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet ForgotPasswordServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    // <editor-fold defaultstate="collapsed" desc="HttpServlet methods. Click on the + sign on the left to edit the code.">
    /**
     * Handles the HTTP <code>GET</code> method.
     *
     * @param request servlet request
     * @param response servlet response
     * @throws ServletException if a servlet-specific error occurs
     * @throws IOException if an I/O error occurs
     */
    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String step = request.getParameter("step");
        if ("verify".equals(step)) {
            request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
        } else if ("reset".equals(step)) {
            request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
        } else {
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
        }
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
        String action = request.getParameter("action");
        HttpSession session = request.getSession();
        UserDAO dao = new UserDAO();
        try {
            if ("sendEmail".equals(action)) {
                String email = request.getParameter("email");
                if (dao.findByEmail(email).isPresent()) { // Kiểm tra email có trong DB không
                    // 1. Tạo mã 6 số ngẫu nhiên
                    String otp = String.format("%06d", new java.util.Random().nextInt(999999));
                    // 2. Lưu vào Session
                    session.setAttribute("resetOtp", otp);
                    session.setAttribute("resetEmail", email);
                    // 3. Gửi Email
                    try {
                        util.EmailUtil.sendOtpEmail(email, otp);
                    } catch (Exception ex) {
                        ex.printStackTrace();
                        request.setAttribute("errorMsg", "Không thể gửi email. Vui lòng thử lại sau.");
                        request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                        return;
                    }

                    response.sendRedirect(request.getContextPath() + "/forgot-password?step=verify");
                } else {
                    request.setAttribute("errorMsg", "Email không tồn tại trong hệ thống!");
                    request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
                }
            } else if ("verifyOtp".equals(action)) {
                String userOtp = request.getParameter("otp");
                String sessionOtp = (String) session.getAttribute("resetOtp");

                if (sessionOtp != null && sessionOtp.equals(userOtp)) { // Khớp OTP
                    response.sendRedirect(request.getContextPath() + "/forgot-password?step=reset");
                } else {
                    request.setAttribute("errorMsg", "Mã OTP không đúng hoặc đã hết hạn!");
                    request.getRequestDispatcher("/WEB-INF/views/auth/verify-otp.jsp").forward(request, response);
                }
            } else if ("resetPassword".equals(action)) {
                String newPass = request.getParameter("newPassword");
                String confPass = request.getParameter("confirmPassword");

                if (newPass.equals(confPass)) {
                    String email = (String) session.getAttribute("resetEmail");
                    // Gọi hàm Hash Password và UPDATE vào Database
                    String hashedPass = util.PasswordUtil.hash(newPass);
                    dao.updatePasswordByEmail(email, hashedPass);

                    // Dọn dẹp Session
                    session.removeAttribute("resetOtp");
                    session.removeAttribute("resetEmail");

                    request.getSession().setAttribute("successMsg", "Đổi mật khẩu thành công!");
                    response.sendRedirect(request.getContextPath() + "/login");
                } else {
                    request.setAttribute("errorMsg", "Mật khẩu xác nhận không khớp!");
                    request.getRequestDispatcher("/WEB-INF/views/auth/reset-password.jsp").forward(request, response);
                }
            }
        } catch (Exception e) {
            request.setAttribute("errorMsg", "Có lỗi xảy ra, vui lòng thử lại!");
            request.getRequestDispatcher("/WEB-INF/views/auth/forgot-password.jsp").forward(request, response);
        }
    }

}
