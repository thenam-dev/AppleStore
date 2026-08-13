package dao.promtion;

import java.math.BigDecimal;
import model.entity.promtion.Promotion;
import util.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PromotionDAO {

    public List<Promotion> findAll() throws SQLException {
        List<Promotion> list = new ArrayList<>();
        String sql = "SELECT * FROM promotions WHERE is_deleted = 0 ORDER BY promo_id DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }

    public Promotion findById(int id) throws SQLException {
        String sql = "SELECT * FROM promotions WHERE promo_id = ? AND is_deleted = 0";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public Promotion findByCode(String code) throws SQLException {
        String sql = "SELECT * FROM promotions WHERE code = ? AND is_deleted = 0";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, code);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        }
        return null;
    }

    public void insert(Promotion p) throws SQLException {
        String sql = "INSERT INTO promotions (code, discount_type, discount_max, discount_value, min_order_value, "
                + "scope, benefit_target, product_id, max_uses, can_stack, valid_from, valid_until, created_by, is_active) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            setPromotionParams(ps, p);
            ps.setTimestamp(11, Timestamp.valueOf(p.getValidFrom()));
            ps.setTimestamp(12, Timestamp.valueOf(p.getValidUntil()));
            ps.setInt(13, p.getCreatedBy());
            ps.setBoolean(14, p.IsActive());
            ps.executeUpdate();
        }
    }

    public void update(Promotion p) throws SQLException {
        String sql = "UPDATE promotions SET code=?, discount_type=?, discount_max=?, discount_value=?, min_order_value=?, "
                + "scope=?, benefit_target=?, product_id=?, max_uses=?, can_stack=?, valid_from=?, valid_until=?, is_active=? "
                + "WHERE promo_id=?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            setPromotionParams(ps, p);
            ps.setTimestamp(11, Timestamp.valueOf(p.getValidFrom()));
            ps.setTimestamp(12, Timestamp.valueOf(p.getValidUntil()));
            ps.setBoolean(13, p.IsActive());
            ps.setInt(14, p.getPromoId());
            ps.executeUpdate();
        }
    }

    public void softDelete(int id) throws SQLException {
        String sql = "UPDATE promotions SET is_deleted = 1, is_active = 0 WHERE promo_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, id);
            ps.executeUpdate();
        }
    }

    public void toggleStatus(int id, boolean newStatus) throws SQLException {
        String sql = "UPDATE promotions SET is_active = ? WHERE promo_id = ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setBoolean(1, newStatus);
            ps.setInt(2, id);
            ps.executeUpdate();
        }
    }

    private void setPromotionParams(PreparedStatement ps, Promotion p) throws SQLException {
        ps.setString(1, p.getCode());
        ps.setString(2, p.getDiscountType());
        ps.setBigDecimal(3, p.getDiscountMax());
        ps.setBigDecimal(4, p.getDiscountValue());
        ps.setBigDecimal(5, p.getMinOrderValue());
        ps.setString(6, p.getScope());
        ps.setString(7, p.getBenefitTarget());

        if (p.getProductId() != null) {
            ps.setInt(8, p.getProductId());
        } else {
            ps.setNull(8, Types.INTEGER);
        }

        if (p.getMaxUses() != null) {
            ps.setInt(9, p.getMaxUses());
        } else {
            ps.setNull(9, Types.INTEGER);
        }

        ps.setBoolean(10, p.isCanStack());
    }

    private Promotion mapRow(ResultSet rs) throws SQLException {
        Promotion p = new Promotion();
        p.setPromoId(rs.getInt("promo_id"));
        p.setCode(rs.getString("code"));
        p.setDiscountType(rs.getString("discount_type"));
        p.setDiscountMax(rs.getBigDecimal("discount_max"));
        p.setDiscountValue(rs.getBigDecimal("discount_value"));
        p.setMinOrderValue(rs.getBigDecimal("min_order_value"));
        p.setScope(rs.getString("scope"));
        p.setBenefitTarget(rs.getString("benefit_target"));

        int pId = rs.getInt("product_id");
        p.setProductId(rs.wasNull() ? null : pId);

        int cId = rs.getInt("category_id");
        p.setCategoryId(rs.wasNull() ? null : cId);

        int mUses = rs.getInt("max_uses");
        p.setMaxUses(rs.wasNull() ? null : mUses);

        p.setUsedCount(rs.getInt("used_count"));
        p.setCanStack(rs.getBoolean("can_stack"));
        p.setValidFrom(rs.getTimestamp("valid_from").toLocalDateTime());
        p.setValidUntil(rs.getTimestamp("valid_until").toLocalDateTime());
        p.setCreatedBy(rs.getInt("created_by"));
        p.setIsDeleted(rs.getBoolean("is_deleted"));
        p.setIsActive(rs.getBoolean("is_active"));
        return p;
    }

    // Tính tổng số lượt đã sử dụng của tất cả các mã (Redeemed)
    public long sumTotalRedeemed() throws SQLException {
        String sql = "SELECT SUM(used_count) FROM promotions WHERE is_deleted = 0";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getLong(1);
            }
        }
        return 0;
    }

    // Đếm số lượng mã đang bật và sẽ hết hạn trong 7 ngày tới (Expiring)
    public int countExpiringSoon() throws SQLException {
        String sql = "SELECT COUNT(*) FROM promotions "
                + "WHERE is_deleted = 0 AND is_active = 1 "
                + "AND valid_until BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                return rs.getInt(1);
            }
        }
        return 0;
    }

    // Đếm tổng số bản ghi thỏa mãn điều kiện search/filter
    public int countAll(String keyword, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM promotions WHERE is_deleted = 0 ");

        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND code LIKE ? ");
        }
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append("AND is_active = ? ");
        }

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
            }
            if (statusFilter != null && !statusFilter.isEmpty()) {
                ps.setBoolean(paramIndex++, "1".equals(statusFilter));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        }
        return 0;
    }

// Lấy danh sách có phân trang và sắp xếp
    public List<Promotion> findAllWithPaging(String keyword, String statusFilter, String sortCol, String sortDir, int offset, int limit) throws SQLException {
        List<Promotion> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM promotions WHERE is_deleted = 0 ");

        // 1. FILTER & SEARCH
        if (keyword != null && !keyword.trim().isEmpty()) {
            sql.append("AND code LIKE ? ");
        }
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append("AND is_active = ? ");
        }

        // 2. SORT (Chống SQL Injection bằng cách chỉ cho phép các cột an toàn)
        String safeCol = "promo_id"; // Mặc định
        if ("code".equals(sortCol)) {
            safeCol = "code";
        } else if ("valid_until".equals(sortCol)) {
            safeCol = "valid_until";
        }

        String safeDir = "ASC".equalsIgnoreCase(sortDir) ? "ASC" : "DESC"; // Mặc định DESC
        sql.append("ORDER BY ").append(safeCol).append(" ").append(safeDir).append(" ");

        // 3. PAGING (LIMIT, OFFSET)
        sql.append("LIMIT ? OFFSET ?");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) {
                ps.setString(paramIndex++, "%" + keyword.trim() + "%");
            }
            if (statusFilter != null && !statusFilter.isEmpty()) {
                ps.setBoolean(paramIndex++, "1".equals(statusFilter));
            }
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }
        return list;
    }
    
    public void insertOrderPromotion(Connection conn, int orderId, int promoId, int customerId, BigDecimal discountApplied, String couponCode, String benefitTarget) throws SQLException {
        String sql = "INSERT INTO order_promotions (order_id, promo_id, customer_id, discount_applied, coupon_code, benefit_target) VALUES (?, ?, ?, ?, ?, ?)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, orderId);
            ps.setInt(2, promoId);
            ps.setInt(3, customerId);
            ps.setBigDecimal(4, discountApplied);
            ps.setString(5, couponCode);
            ps.setString(6, benefitTarget);
            ps.executeUpdate();
        }
    }

    public void incrementUsedCount(Connection conn, int promoId) throws SQLException {
        String sql = "UPDATE promotions SET used_count = used_count + 1 WHERE promo_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, promoId);
            ps.executeUpdate();
        }
    }
    
    // Lấy danh sách mã giảm giá khả dụng cho Giỏ hàng
    public List<Promotion> findAvailableVouchersForCart() throws SQLException {
        List<Promotion> list = new ArrayList<>();
        String sql = "SELECT * FROM promotions WHERE is_deleted = 0 AND is_active = 1 "
                   + "AND valid_from <= NOW() AND valid_until >= NOW() "
                   + "AND scope = 'ORDER' AND benefit_target = 'MERCHANDISE' "
                   + "AND (max_uses IS NULL OR used_count < max_uses) "
                   + "ORDER BY discount_value DESC"; // Ưu tiên mã giảm giá trị cao lên đầu
                   
        try (Connection conn = DBConnection.getConnection(); 
             PreparedStatement ps = conn.prepareStatement(sql); 
             ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }
        return list;
    }
}
