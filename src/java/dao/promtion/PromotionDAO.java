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
                Promotion p = mapRow(rs);
                loadRelations(conn, p); // Đọc mảng ID từ bảng phụ
                list.add(p);
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
                    Promotion p = mapRow(rs);
                    loadRelations(conn, p);
                    return p;
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
                    Promotion p = mapRow(rs);
                    loadRelations(conn, p);
                    return p;
                }
            }
        }
        return null;
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

    // ĐÃ SỬA: Loại bỏ Category và Product ID (Do đã sang bảng phụ)
    private void setPromotionParams(PreparedStatement ps, Promotion p) throws SQLException {
        ps.setString(1, p.getCode());
        ps.setString(2, p.getDiscountType());
        ps.setBigDecimal(3, p.getDiscountMax());
        ps.setBigDecimal(4, p.getDiscountValue());
        ps.setBigDecimal(5, p.getMinOrderValue());
        ps.setString(6, p.getScope());
        ps.setString(7, p.getBenefitTarget());

        if (p.getMaxUses() != null) {
            ps.setInt(8, p.getMaxUses());
        } else {
            ps.setNull(8, Types.INTEGER);
        }
        ps.setBoolean(9, p.isCanStack());
    }

    // ĐÃ SỬA: Dùng RETURN_GENERATED_KEYS và Insert bảng phụ
    public void insert(Promotion p) throws SQLException {
        String sql = "INSERT INTO promotions (code, discount_type, discount_max, discount_value, min_order_value, "
                + "scope, benefit_target, max_uses, can_stack, valid_from, valid_until, created_by, is_active) "
                + "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            setPromotionParams(ps, p); // Từ 1 đến 9
            ps.setTimestamp(10, Timestamp.valueOf(p.getValidFrom()));
            ps.setTimestamp(11, Timestamp.valueOf(p.getValidUntil()));
            ps.setInt(12, p.getCreatedBy());
            ps.setBoolean(13, p.IsActive());
            ps.executeUpdate();

            // Lấy ID tự sinh
            try (ResultSet rs = ps.getGeneratedKeys()) {
                if (rs.next()) {
                    int newPromoId = rs.getInt(1);
                    p.setPromoId(newPromoId);
                    // Lưu dữ liệu vào 2 bảng phụ
                    saveRelations(conn, p);
                }
            }
        }
    }

    // ĐÃ SỬA: Xóa dữ liệu cũ ở bảng phụ, ghi đè dữ liệu mới
    public void update(Promotion p) throws SQLException {
        String sql = "UPDATE promotions SET code=?, discount_type=?, discount_max=?, discount_value=?, min_order_value=?, "
                + "scope=?, benefit_target=?, max_uses=?, can_stack=?, valid_from=?, valid_until=?, is_active=? "
                + "WHERE promo_id=?";
        try (Connection conn = DBConnection.getConnection()) {
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                setPromotionParams(ps, p); // Từ 1 đến 9
                ps.setTimestamp(10, Timestamp.valueOf(p.getValidFrom()));
                ps.setTimestamp(11, Timestamp.valueOf(p.getValidUntil()));
                ps.setBoolean(12, p.IsActive());
                ps.setInt(13, p.getPromoId());
                ps.executeUpdate();
            }
            
            // Xóa rác và cập nhật lại bảng phụ
            deleteRelations(conn, p.getPromoId());
            saveRelations(conn, p);
        }
    }

    // ĐÃ SỬA: Bỏ ánh xạ ID sản phẩm/danh mục (Do đã nằm ở bảng phụ)
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

    // HÀM MỚI: Lôi dữ liệu mảng từ bảng phụ
    private void loadRelations(Connection conn, Promotion p) throws SQLException {
        p.setCategoryIds(new ArrayList<>());
        p.setProductIds(new ArrayList<>());

        String sqlCat = "SELECT category_id FROM promotion_categories WHERE promo_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlCat)) {
            ps.setInt(1, p.getPromoId());
            try (ResultSet rs = ps.executeQuery()) {
                while(rs.next()) p.getCategoryIds().add(rs.getInt(1));
            }
        }

        String sqlProd = "SELECT product_id FROM promotion_products WHERE promo_id = ?";
        try (PreparedStatement ps = conn.prepareStatement(sqlProd)) {
            ps.setInt(1, p.getPromoId());
            try (ResultSet rs = ps.executeQuery()) {
                while(rs.next()) p.getProductIds().add(rs.getInt(1));
            }
        }
    }

    // HÀM MỚI: Lưu mảng vào bảng phụ
    private void saveRelations(Connection conn, Promotion p) throws SQLException {
        if (p.getCategoryIds() != null && !p.getCategoryIds().isEmpty()) {
            String sqlCat = "INSERT INTO promotion_categories (promo_id, category_id) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlCat)) {
                for (Integer cId : p.getCategoryIds()) {
                    ps.setInt(1, p.getPromoId());
                    ps.setInt(2, cId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        }

        if (p.getProductIds() != null && !p.getProductIds().isEmpty()) {
            String sqlProd = "INSERT INTO promotion_products (promo_id, product_id) VALUES (?, ?)";
            try (PreparedStatement ps = conn.prepareStatement(sqlProd)) {
                for (Integer pId : p.getProductIds()) {
                    ps.setInt(1, p.getPromoId());
                    ps.setInt(2, pId);
                    ps.addBatch();
                }
                ps.executeBatch();
            }
        }
    }

    // HÀM MỚI: Xóa dữ liệu cũ ở bảng phụ trước khi Update
    private void deleteRelations(Connection conn, int promoId) throws SQLException {
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM promotion_categories WHERE promo_id = ?")) {
            ps.setInt(1, promoId);
            ps.executeUpdate();
        }
        try (PreparedStatement ps = conn.prepareStatement("DELETE FROM promotion_products WHERE promo_id = ?")) {
            ps.setInt(1, promoId);
            ps.executeUpdate();
        }
    }

    public long sumTotalRedeemed() throws SQLException {
        String sql = "SELECT SUM(used_count) FROM promotions WHERE is_deleted = 0";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getLong(1);
        }
        return 0;
    }

    public int countExpiringSoon() throws SQLException {
        String sql = "SELECT COUNT(*) FROM promotions WHERE is_deleted = 0 AND is_active = 1 AND valid_until BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 7 DAY)";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            if (rs.next()) return rs.getInt(1);
        }
        return 0;
    }

    public int countAll(String keyword, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM promotions WHERE is_deleted = 0 ");
        if (keyword != null && !keyword.trim().isEmpty()) sql.append("AND code LIKE ? ");
        if (statusFilter != null && !statusFilter.isEmpty()) sql.append("AND is_active = ? ");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) ps.setString(paramIndex++, "%" + keyword.trim() + "%");
            if (statusFilter != null && !statusFilter.isEmpty()) ps.setBoolean(paramIndex++, "1".equals(statusFilter));
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) return rs.getInt(1);
            }
        }
        return 0;
    }

    public List<Promotion> findAllWithPaging(String keyword, String statusFilter, String sortCol, String sortDir, int offset, int limit) throws SQLException {
        List<Promotion> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder("SELECT * FROM promotions WHERE is_deleted = 0 ");

        if (keyword != null && !keyword.trim().isEmpty()) sql.append("AND code LIKE ? ");
        if (statusFilter != null && !statusFilter.isEmpty()) sql.append("AND is_active = ? ");

        String safeCol = "promo_id"; 
        if ("code".equals(sortCol)) safeCol = "code";
        else if ("valid_until".equals(sortCol)) safeCol = "valid_until";

        String safeDir = "ASC".equalsIgnoreCase(sortDir) ? "ASC" : "DESC"; 
        sql.append("ORDER BY ").append(safeCol).append(" ").append(safeDir).append(" LIMIT ? OFFSET ?");

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            int paramIndex = 1;
            if (keyword != null && !keyword.trim().isEmpty()) ps.setString(paramIndex++, "%" + keyword.trim() + "%");
            if (statusFilter != null && !statusFilter.isEmpty()) ps.setBoolean(paramIndex++, "1".equals(statusFilter));
            ps.setInt(paramIndex++, limit);
            ps.setInt(paramIndex++, offset);

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Promotion p = mapRow(rs);
                    loadRelations(conn, p);
                    list.add(p);
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

    public boolean incrementUsedCount(Connection conn, int promoId) throws SQLException {
        String sql = "UPDATE promotions SET used_count = used_count + 1 WHERE promo_id = ? AND (max_uses IS NULL OR used_count < max_uses)";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, promoId);
            return ps.executeUpdate() > 0;
        }
    }

    /**
     * Hoàn lại used_count đã tăng nhầm khi checkout phải huỷ ngang giữa chừng
     * (best-effort, không có transaction xuyên suốt - theo đúng pattern
     * "rollback nghiệp vụ" của CheckoutService).
     */
    public void decrementUsedCount(Connection conn, int promoId) throws SQLException {
        String sql = "UPDATE promotions SET used_count = used_count - 1 WHERE promo_id = ? AND used_count > 0";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, promoId);
            ps.executeUpdate();
        }
    }

    public List<Promotion> findAvailableVouchersForCart() throws SQLException {
        List<Promotion> list = new ArrayList<>();
        // Bỏ điều kiện lọc cứng scope = 'ORDER' để hiển thị tất cả các mã đang hoạt động và còn hạn
        String sql = "SELECT * FROM promotions WHERE is_deleted = 0 AND is_active = 1 "
                + "AND valid_from <= NOW() AND valid_until >= NOW() "
                + "AND (max_uses IS NULL OR used_count < max_uses) "
                + "ORDER BY discount_value DESC";

        try (Connection conn = DBConnection.getConnection(); PreparedStatement ps = conn.prepareStatement(sql); ResultSet rs = ps.executeQuery()) {
            while (rs.next()) {
                Promotion p = mapRow(rs);
                loadRelations(conn, p);
                list.add(p);
            }
        }
        return list;
    }
}