/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.user.profile;

import java.io.IOException;
import java.io.PrintWriter;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import java.util.List;
import model.entity.user.User;
import model.entity.user.UserAddress;
import service.user.UserAddressService;

/**
 *
 * @author admin
 */
@WebServlet(name = "AddressServlet", urlPatterns = {"/addresses",
    "/add-address",
    "/update-address",
    "/delete-address",
    "/set-default-address"})
public class AddressServlet extends HttpServlet {

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
            out.println("<title>Servlet AddressServlet</title>");
            out.println("</head>");
            out.println("<body>");
            out.println("<h1>Servlet AddressServlet at " + request.getContextPath() + "</h1>");
            out.println("</body>");
            out.println("</html>");
        }
    }

    private UserAddressService addressService;

    @Override
    public void init() throws ServletException {
        addressService = new UserAddressService();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");

        // Kiểm tra đăng nhập
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        // Lấy danh sách địa chỉ và truyền vào JSP
        List<UserAddress> addressList = addressService.getAddressesByUserId(user.getUserId());
        request.setAttribute("addressList", addressList);

        request.getRequestDispatcher("/WEB-INF/views/common/addresses.jsp").forward(request, response);
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
        request.setCharacterEncoding("UTF-8");
        String path = request.getServletPath();

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }
        try {
            switch (path) {
                case "/add-address": {
                    UserAddress newAddress = new UserAddress();
                    newAddress.setUserId(user.getUserId());
                    newAddress.setRecipientName(request.getParameter("recipientName"));
                    newAddress.setRecipientPhone(request.getParameter("recipientPhone"));
                    newAddress.setProvince(request.getParameter("province"));
                    newAddress.setDistrict(request.getParameter("district"));
                    newAddress.setWard(request.getParameter("ward"));
                    newAddress.setAddressDetail(request.getParameter("addressDetail"));

                    if (addressService.addAddress(newAddress)) {
                        request.getSession().setAttribute("message", "Thêm địa chỉ thành công!");
                    } else {
                        request.getSession().setAttribute("error", "Thêm địa chỉ thất bại!");
                    }
                    break;
                }
                case "/update-address": {
                    UserAddress updatedAddress = new UserAddress();
                    updatedAddress.setAddressId(Integer.parseInt(request.getParameter("addressId")));
                    updatedAddress.setUserId(user.getUserId());
                    updatedAddress.setRecipientName(request.getParameter("recipientName"));
                    updatedAddress.setRecipientPhone(request.getParameter("recipientPhone"));
                    updatedAddress.setProvince(request.getParameter("province"));
                    updatedAddress.setDistrict(request.getParameter("district"));
                    updatedAddress.setWard(request.getParameter("ward"));
                    updatedAddress.setAddressDetail(request.getParameter("addressDetail"));

                    if (addressService.updateAddress(updatedAddress)) {
                        request.getSession().setAttribute("message", "Cập nhật địa chỉ thành công!");
                    } else {
                        request.getSession().setAttribute("error", "Cập nhật thất bại!");
                    }
                    break;
                }
                case "/delete-address": {
                    int addressId = Integer.parseInt(request.getParameter("addressId"));
                    if (addressService.deleteAddress(addressId, user.getUserId())) {
                        request.getSession().setAttribute("message", "Đã xóa địa chỉ!");
                    }
                    break;
                }
                case "/set-default-address": {
                    int addressId = Integer.parseInt(request.getParameter("addressId"));
                    if (addressService.setDefaultAddress(addressId, user.getUserId())) {
                        request.getSession().setAttribute("message", "Đã thiết lập địa chỉ mặc định!");
                    }
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("error", "Có lỗi xảy ra: " + e.getMessage());
        }

        // Dùng sendRedirect để tránh lỗi resubmit form khi F5
        response.sendRedirect(request.getContextPath() + "/addresses");
    }

    /**
     * Returns a short description of the servlet.
     *
     * @return a String containing servlet description
     */
    @Override
    public String getServletInfo() {
        return "Short description";
    }// </editor-fold>

}
