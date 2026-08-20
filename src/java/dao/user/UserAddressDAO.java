/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao.user;
import java.sql.*;
import java.util.*;
import model.entity.user.UserAddress;
import util.DBConnection;

/**
 *
 * @author admin
 */
public class UserAddressDAO {
    
    // 1. Lấy danh sách địa chỉ của 1 User (Chưa bị xóa, mặc định lên đầu)
    public List<UserAddress> getAddressesByUserId(int userId) {
        List<UserAddress> list = new ArrayList<>();
        String sql = "SELECT * FROM user_addresses WHERE user_id = ? AND is_deleted = 0 ORDER BY is_default DESC, created_at DESC";
        try {
            Connection conn = DBConnection.getConnection();
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setInt(1, userId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                UserAddress address = new UserAddress();
                address.setAddressId(rs.getInt("address_id"));
                address.setUserId(rs.getInt("user_id"));
                address.setRecipientName(rs.getString("recipient_name"));
                address.setRecipientPhone(rs.getString("recipient_phone"));
                address.setProvince(rs.getString("province"));
                address.setDistrict(rs.getString("district"));
                address.setWard(rs.getString("ward"));
                address.setAddressDetail(rs.getString("address_detail"));
                address.setIsDefault(rs.getInt("is_default"));
                address.setIsDeleted(rs.getInt("is_deleted"));
                address.setCreatedAt(rs.getTimestamp("created_at"));
                address.setUpdatedAt(rs.getTimestamp("updated_at"));
                list.add(address);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
    
        // 2. Thêm địa chỉ mới
    public boolean addAddress(UserAddress address) {
        String sql = "INSERT INTO user_addresses (user_id, recipient_name, recipient_phone, province, district, ward, address_detail, is_default) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection connection = DBConnection.getConnection(); 
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, address.getUserId());
            ps.setString(2, address.getRecipientName());
            ps.setString(3, address.getRecipientPhone());
            ps.setString(4, address.getProvince());
            ps.setString(5, address.getDistrict());
            ps.setString(6, address.getWard());
            ps.setString(7, address.getAddressDetail());
            ps.setInt(8, address.getIsDefault());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    // 3. Cập nhật địa chỉ
    public boolean updateAddress(UserAddress address) {
        String sql = "UPDATE user_addresses SET recipient_name=?, recipient_phone=?, province=?, district=?, ward=?, address_detail=? WHERE address_id=? AND user_id=?";
        try (Connection connection = DBConnection.getConnection(); 
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setString(1, address.getRecipientName());
            ps.setString(2, address.getRecipientPhone());
            ps.setString(3, address.getProvince());
            ps.setString(4, address.getDistrict());
            ps.setString(5, address.getWard());
            ps.setString(6, address.getAddressDetail());
            ps.setInt(7, address.getAddressId());
            ps.setInt(8, address.getUserId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    // 4. Thiết lập địa chỉ mặc định
    public boolean setDefaultAddress(int addressId, int userId) {
        String sql1 = "UPDATE user_addresses SET is_default = 0 WHERE user_id = ?";
        String sql2 = "UPDATE user_addresses SET is_default = 1 WHERE address_id = ? AND user_id = ?";
        try (Connection connection = DBConnection.getConnection()) {
            // Tắt auto commit để chạy 2 lệnh cùng lúc (Transaction)
            connection.setAutoCommit(false);
            
            try (PreparedStatement ps1 = connection.prepareStatement(sql1)) {
                ps1.setInt(1, userId);
                ps1.executeUpdate();
            }
            
            try (PreparedStatement ps2 = connection.prepareStatement(sql2)) {
                ps2.setInt(1, addressId);
                ps2.setInt(2, userId);
                ps2.executeUpdate();
            }
            
            connection.commit(); // Hoàn tất
            connection.setAutoCommit(true);
            return true;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
    // 5. Xóa địa chỉ (Soft delete)
    public boolean deleteAddress(int addressId, int userId) {
        String sql = "UPDATE user_addresses SET is_deleted = 1, is_default = 0 WHERE address_id = ? AND user_id = ?";
        try (Connection connection = DBConnection.getConnection(); 
             PreparedStatement ps = connection.prepareStatement(sql)) {
            ps.setInt(1, addressId);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<UserAddress> getFilteredAddresses(int userId, String keyword, String filter, String sort) {
        List<UserAddress> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM user_addresses WHERE user_id = ? AND is_deleted = 0");
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append(" AND (recipient_name LIKE ? OR recipient_phone LIKE ? OR address_detail LIKE ?)");
        }
        if ("default".equals(filter)) {
            sql.append(" AND is_default = 1");
        } else if ("normal".equals(filter)) {
            sql.append(" AND is_default = 0");
        }
        if ("oldest".equals(sort)) {
            sql.append(" ORDER BY created_at ASC");
        } else if ("newest".equals(sort)) {
            sql.append(" ORDER BY created_at DESC");
        } else {
            sql.append(" ORDER BY is_default DESC, created_at DESC");
        }
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            ps.setInt(paramIndex++, userId);
            if (keyword != null && !keyword.trim().isEmpty()) {
                String kw = "%" + keyword.trim() + "%";
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
                ps.setString(paramIndex++, kw);
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    UserAddress address = new UserAddress();
                    address.setAddressId(rs.getInt("address_id"));
                    address.setUserId(rs.getInt("user_id"));
                    address.setRecipientName(rs.getString("recipient_name"));
                    address.setRecipientPhone(rs.getString("recipient_phone"));
                    address.setProvince(rs.getString("province"));
                    address.setDistrict(rs.getString("district"));
                    address.setWard(rs.getString("ward"));
                    address.setAddressDetail(rs.getString("address_detail"));
                    address.setIsDefault(rs.getInt("is_default"));
                    address.setIsDeleted(rs.getInt("is_deleted"));
                    address.setCreatedAt(rs.getTimestamp("created_at"));
                    address.setUpdatedAt(rs.getTimestamp("updated_at"));
                    list.add(address);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return list;
    }
}
