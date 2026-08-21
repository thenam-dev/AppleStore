/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller.customer.profile;

import java.io.IOException;
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

    UserAddressService addressService=new UserAddressService();
    

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession();
        User user = (User) session.getAttribute("user");
        String keyword = request.getParameter("keyword");
        String filter = request.getParameter("filter");
        String sort = request.getParameter("sort");

        List<UserAddress> addressList = addressService.getFilteredAddresses(user.getUserId(), keyword, filter, sort);
        request.setAttribute("addressList", addressList);
        request.setAttribute("keyword", keyword);
        request.setAttribute("filter", filter);
        request.setAttribute("sort", sort);

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
        
        try {
            switch (path) {
                case "/add-address": {
                    String rName = request.getParameter("recipientName");
                    String rPhone = request.getParameter("recipientPhone");
                    String aDetail = request.getParameter("addressDetail");

                    UserAddress newAddress = new UserAddress();
                    newAddress.setUserId(user.getUserId());
                    newAddress.setRecipientName(rName);
                    newAddress.setRecipientPhone(rPhone);
                    newAddress.setAddressDetail(aDetail);

                    if (addressService.addAddress(newAddress)) {
                        request.getSession().setAttribute("successMsg", "Thêm địa chỉ thành công!");
                    } else {
                        request.getSession().setAttribute("errorMsg", "Thêm địa chỉ thất bại!");
                    }
                    break;
                }
                case "/update-address": {
                    String rName = request.getParameter("recipientName");
                    String rPhone = request.getParameter("recipientPhone");
                    String aDetail = request.getParameter("addressDetail");

                    UserAddress updatedAddress = new UserAddress();
                    updatedAddress.setAddressId(Integer.parseInt(request.getParameter("addressId")));
                    updatedAddress.setUserId(user.getUserId());
                    updatedAddress.setRecipientName(rName);
                    updatedAddress.setRecipientPhone(rPhone);
                    // Không lưu province, district, ward theo yêu cầu
                    updatedAddress.setAddressDetail(aDetail);

                    if (addressService.updateAddress(updatedAddress)) {
                        request.getSession().setAttribute("successMsg", "Cập nhật địa chỉ thành công!");
                    } else {
                        request.getSession().setAttribute("errorMsg", "Cập nhật thất bại!");
                    }
                    break;
                }
                case "/delete-address": {
                    int addressId = Integer.parseInt(request.getParameter("addressId"));
                    if (addressService.deleteAddress(addressId, user.getUserId())) {
                        request.getSession().setAttribute("successMsg", "Đã xóa địa chỉ!");
                    }
                    break;
                }
                case "/set-default-address": {
                    int addressId = Integer.parseInt(request.getParameter("addressId"));
                    if (addressService.setDefaultAddress(addressId, user.getUserId())) {
                        request.getSession().setAttribute("successMsg", "Đã thiết lập địa chỉ mặc định!");
                    }
                    break;
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("errorMsg", "Có lỗi xảy ra: " + e.getMessage());
        }

        // Dùng sendRedirect để tránh lỗi resubmit form khi F5
        response.sendRedirect(request.getContextPath() + "/addresses");
    }

}
