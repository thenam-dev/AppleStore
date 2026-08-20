/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package service.user;

import dao.user.UserAddressDAO;
import java.util.List;
import model.entity.user.UserAddress;

/**
 *
 * @author admin
 */
public class UserAddressService {
        private UserAddressDAO addressDAO;
    public UserAddressService() {
        this.addressDAO = new UserAddressDAO();
    }
    public List<UserAddress> getAddressesByUserId(int userId) {
        return addressDAO.getAddressesByUserId(userId);
    }
    public boolean addAddress(UserAddress address) {
        // Nếu user chưa có địa chỉ nào, gán địa chỉ đầu tiên làm mặc định
        List<UserAddress> currentList = addressDAO.getAddressesByUserId(address.getUserId());
        if (currentList.isEmpty()) {
            address.setIsDefault(1);
        } else {
            address.setIsDefault(0);
        }
        return addressDAO.addAddress(address);
    }
    public boolean updateAddress(UserAddress address) {
        return addressDAO.updateAddress(address);
    }
    public boolean setDefaultAddress(int addressId, int userId) {
        return addressDAO.setDefaultAddress(addressId, userId);
    }
    public boolean deleteAddress(int addressId, int userId) {
        return addressDAO.deleteAddress(addressId, userId);
    }
    public List<UserAddress> getFilteredAddresses(int userId, String keyword, String filter, String sort) {
        return addressDAO.getFilteredAddresses(userId, keyword, filter, sort);
    }
}
