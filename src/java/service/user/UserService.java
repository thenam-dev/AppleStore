package service.user;

import config.AppConfig;
import dao.user.UserDAO;
import model.entity.user.User;

import java.sql.SQLException;
import java.util.List;
import java.util.regex.Pattern;

public class UserService {

    private static final int DEFAULT_PAGE = 1;
    private static final int DEFAULT_PAGE_SIZE = AppConfig.PAGE_SIZE_ADMIN;
    private static final int MAX_PAGE_SIZE = 100;
    private static final List<String> CUSTOMER_ROLES = List.of(AppConfig.ROLE_CUSTOMER);
    private static final List<String> INTERNAL_ROLES = List.of(
            AppConfig.ROLE_ADMIN,
            AppConfig.ROLE_SALE_STAFF,
            AppConfig.ROLE_DELIVERY
    );
    private static final List<String> ALLOWED_ROLES = List.of(
            AppConfig.ROLE_CUSTOMER,
            AppConfig.ROLE_ADMIN,
            AppConfig.ROLE_SALE_STAFF,
            AppConfig.ROLE_DELIVERY
    );
    private static final List<String> ALLOWED_STATUSES = List.of("ACTIVE", "INACTIVE", "LOCKED", "SUSPENDED");
    private static final List<String> ALLOWED_SORTS = List.of(
            "created_desc",
            "created_asc",
            "name_asc",
            "email_asc",
            "role_asc",
            "status_asc"
    );
    private static final Pattern EMAIL_PATTERN = Pattern.compile("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$");
    private static final Pattern PHONE_PATTERN = Pattern.compile("^[0-9]{9,15}$");

    private final UserDAO userDAO;

    /**
     * Khởi tạo service user với UserDAO mặc định.
     */
    public UserService() {
        this(new UserDAO());
    }

    /**
     * Cho phép inject UserDAO để dễ kiểm thử hoặc thay đổi nguồn dữ liệu.
     */
    public UserService(UserDAO userDAO) {
        this.userDAO = userDAO;
    }

    /**
     * Lấy danh sách người dùng theo keyword, role, status, sort và phân trang.
     */
    public List<User> getUsers(String keyword, String role, String status, String sort, int page, int pageSize)
            throws SQLException {
        String normalizedRole = normalizeOptional(role);
        String normalizedStatus = normalizeOptional(status);
        String normalizedSort = normalizeSort(sort);

        if (normalizedRole != null && !ALLOWED_ROLES.contains(normalizedRole)) {
            throw new IllegalArgumentException("Bộ lọc vai trò không hợp lệ.");
        }
        if (normalizedStatus != null && !ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Bộ lọc trạng thái không hợp lệ.");
        }

        return userDAO.findAll(
                keyword,
                normalizedRole,
                normalizedStatus,
                normalizedSort,
                normalizePage(page),
                normalizePageSize(pageSize)
        );
    }

    /**
     * Lấy danh sách customer. Server luôn ép role CUSTOMER, không nhận role từ
     * request.
     */
    public List<User> getCustomers(String keyword, String status, String sort, int page, int pageSize)
            throws SQLException {
        String normalizedStatus = normalizeOptional(status);
        String normalizedSort = normalizeSort(sort);

        if (normalizedStatus != null && !ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Bộ lọc trạng thái không hợp lệ.");
        }

        return userDAO.findAllByRoleGroup(
                keyword,
                CUSTOMER_ROLES,
                AppConfig.ROLE_CUSTOMER,
                normalizedStatus,
                normalizedSort,
                normalizePage(page),
                normalizePageSize(pageSize)
        );
    }

    /**
     * Lấy danh sách tài khoản nội bộ, không bao gồm CUSTOMER.
     */
    public List<User> getStaffUsers(String keyword, String role, String status, String sort, int page, int pageSize)
            throws SQLException {
        String normalizedRole = normalizeOptional(role);
        String normalizedStatus = normalizeOptional(status);
        String normalizedSort = normalizeSort(sort);

        if (normalizedRole != null && !INTERNAL_ROLES.contains(normalizedRole)) {
            throw new IllegalArgumentException("Bộ lọc vai trò không hợp lệ.");
        }
        if (normalizedStatus != null && !ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Bộ lọc trạng thái không hợp lệ.");
        }

        return userDAO.findAllByRoleGroup(
                keyword,
                INTERNAL_ROLES,
                normalizedRole,
                normalizedStatus,
                normalizedSort,
                normalizePage(page),
                normalizePageSize(pageSize)
        );
    }

    /**
     * Đếm người dùng sau khi áp dụng bộ lọc trên màn danh sách.
     */
    public int countUsers(String keyword, String role, String status) throws SQLException {
        String normalizedRole = normalizeOptional(role);
        String normalizedStatus = normalizeOptional(status);

        if (normalizedRole != null && !ALLOWED_ROLES.contains(normalizedRole)) {
            throw new IllegalArgumentException("Bộ lọc vai trò không hợp lệ.");
        }
        if (normalizedStatus != null && !ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Bộ lọc trạng thái không hợp lệ.");
        }

        return userDAO.countAll(keyword, normalizedRole, normalizedStatus);
    }

    /**
     * Đếm customer. Server luôn ép role CUSTOMER.
     */
    public int countCustomers(String keyword, String status) throws SQLException {
        String normalizedStatus = normalizeOptional(status);

        if (normalizedStatus != null && !ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Bộ lọc trạng thái không hợp lệ.");
        }

        return userDAO.countAllByRoleGroup(keyword, CUSTOMER_ROLES, AppConfig.ROLE_CUSTOMER, normalizedStatus);
    }

    /**
     * Đếm tài khoản nội bộ sau khi lọc.
     */
    public int countStaffUsers(String keyword, String role, String status) throws SQLException {
        String normalizedRole = normalizeOptional(role);
        String normalizedStatus = normalizeOptional(status);

        if (normalizedRole != null && !INTERNAL_ROLES.contains(normalizedRole)) {
            throw new IllegalArgumentException("Bộ lọc vai trò không hợp lệ.");
        }
        if (normalizedStatus != null && !ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Bộ lọc trạng thái không hợp lệ.");
        }

        return userDAO.countAllByRoleGroup(keyword, INTERNAL_ROLES, normalizedRole, normalizedStatus);
    }

    /**
     * Lấy user theo ID và báo lỗi nghiệp vụ nếu không tồn tại.
     */
    public User getUserById(int userId) throws SQLException {
        return userDAO.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Người dùng không tồn tại."));
    }

    /**
     * Lấy customer theo ID và chặn nếu target không phải CUSTOMER.
     */
    public User getCustomerById(int userId) throws SQLException {
        User user = getUserById(userId);
        ensureCustomer(user);
        return user;
    }

    /**
     * Lấy tài khoản nội bộ theo ID và chặn CUSTOMER.
     */
    public User getStaffUserById(int userId) throws SQLException {
        User user = getUserById(userId);
        ensureInternalUser(user);
        return user;
    }

    /**
     * Cập nhật thông tin user sau khi validate và chống trùng email/số điện
     * thoại với user khác.
     */
    public void updateUser(User user) throws SQLException {
        normalizeUser(user);
        validateUser(user);

        if (userDAO.existsByEmailForOtherUser(user.getEmail(), user.getUserId())) {
            throw new IllegalArgumentException("Email đã được tài khoản khác sử dụng.");
        }

        if (userDAO.existsByPhoneForOtherUser(user.getPhone(), user.getUserId())) {
            throw new IllegalArgumentException("Số điện thoại đã được tài khoản khác sử dụng.");
        }

        if (!userDAO.update(user)) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }
    }

    /**
     * Đổi trạng thái tài khoản người dùng như ACTIVE, INACTIVE hoặc LOCKED.
     */
    public void changeStatus(int userId, String status) throws SQLException {
        String normalizedStatus = normalizeRequired(status);
        if (!ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        }

        if (!userDAO.updateStatus(userId, normalizedStatus)) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }
    }

    /**
     * Cập nhật tài khoản nội bộ. Không dùng cho CUSTOMER.
     */
    public void updateStaffUser(User user, int actorUserId) throws SQLException {
        User existing = getStaffUserById(user.getUserId());
        normalizeUser(user);
        validateInternalUser(user);
        validateSelfInternalUpdate(existing, user, actorUserId);
        validateLastActiveAdmin(existing, user.getRole(), user.getStatus());

        if (userDAO.existsByEmailForOtherUser(user.getEmail(), user.getUserId())) {
            throw new IllegalArgumentException("Email đã được tài khoản khác sử dụng.");
        }

        if (userDAO.existsByPhoneForOtherUser(user.getPhone(), user.getUserId())) {
            throw new IllegalArgumentException("Số điện thoại đã được tài khoản khác sử dụng.");
        }

        if (!existing.getEmail().equalsIgnoreCase(user.getEmail())) {
            user.setEmailVerified(false);
        } else {
            user.setEmailVerified(existing.isEmailVerified());
        }

        if (!userDAO.update(user)) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }
    }

    /**
     * Đổi trạng thái customer, không cập nhật thông tin cá nhân/role.
     */
    public void changeCustomerStatus(int userId, String status) throws SQLException {
        User customer = getCustomerById(userId);
        String normalizedStatus = normalizeRequired(status);
        if (!ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        }

        boolean locking = !isActiveStatus(normalizedStatus);
        if (locking && userDAO.countUnfinishedCustomerOrders(customer.getUserId()) > 0) {
            throw new IllegalArgumentException(
                    "Không thể khóa tài khoản vì khách hàng còn đơn hàng chưa giao, hủy hoặc hoàn tiền xong.");
        }

        if (!userDAO.updateStatus(customer.getUserId(), normalizedStatus)) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }
    }

    /**
     * Đổi trạng thái tài khoản nội bộ với rule chống tự khóa/mất admin cuối.
     */
    public void changeStaffStatus(int userId, String status, int actorUserId) throws SQLException {
        User existing = getStaffUserById(userId);
        String normalizedStatus = normalizeRequired(status);
        if (!ALLOWED_STATUSES.contains(normalizedStatus)) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        }

        if (existing.getUserId() == actorUserId && !isActiveStatus(normalizedStatus)) {
            throw new IllegalArgumentException("Bạn không thể tự khóa hoặc vô hiệu hóa tài khoản của chính mình.");
        }

        validateLastActiveAdmin(existing, existing.getRole(), normalizedStatus);

        if (!userDAO.updateStatus(existing.getUserId(), normalizedStatus)) {
            throw new IllegalArgumentException("Người dùng không tồn tại.");
        }
    }

    /**
     * Trả về danh sách role hợp lệ cho UI và validate.
     */
    public List<String> getAllowedRoles() {
        return ALLOWED_ROLES;
    }

    /**
     * Trả về role nội bộ hợp lệ cho màn staff/admin.
     */
    public List<String> getAllowedInternalRoles() {
        return INTERNAL_ROLES;
    }

    /**
     * Trả về danh sách trạng thái user hợp lệ cho UI và validate.
     */
    public List<String> getAllowedStatuses() {
        return ALLOWED_STATUSES;
    }

    /**
     * Trả về danh sách sort hợp lệ cho màn quản lý người dùng.
     */
    public List<String> getAllowedSorts() {
        return ALLOWED_SORTS;
    }

    /**
     * Chuẩn hóa dữ liệu user trước khi validate và lưu DB.
     */
    private void normalizeUser(User user) {
        user.setFullName(trimRequired(user.getFullName()));
        user.setEmail(trimRequired(user.getEmail()).toLowerCase());
        user.setPhone(normalizeOptional(user.getPhone()));
        user.setRole(normalizeRequired(user.getRole()));
        user.setStatus(normalizeRequired(user.getStatus()));
    }

    /**
     * Kiểm tra các ràng buộc nghiệp vụ của user.
     */
    private void validateUser(User user) {
        if (user.getUserId() <= 0) {
            throw new IllegalArgumentException("ID người dùng không hợp lệ.");
        }
        if (user.getFullName().length() > 100) {
            throw new IllegalArgumentException("Họ tên không được vượt quá 100 ký tự.");
        }
        if (!EMAIL_PATTERN.matcher(user.getEmail()).matches() || user.getEmail().length() > 255) {
            throw new IllegalArgumentException("Email không hợp lệ.");
        }
        if (user.getPhone() != null && !PHONE_PATTERN.matcher(user.getPhone()).matches()) {
            throw new IllegalArgumentException("Số điện thoại phải gồm 9 đến 15 chữ số.");
        }
        if (!ALLOWED_ROLES.contains(user.getRole())) {
            throw new IllegalArgumentException("Vai trò không hợp lệ.");
        }
        if (!ALLOWED_STATUSES.contains(user.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        }
    }

    /**
     * Kiểm tra ràng buộc của tài khoản nội bộ.
     */
    private void validateInternalUser(User user) {
        if (user.getUserId() <= 0) {
            throw new IllegalArgumentException("ID người dùng không hợp lệ.");
        }
        if (user.getFullName().length() > 100) {
            throw new IllegalArgumentException("Họ tên không được vượt quá 100 ký tự.");
        }
        if (!EMAIL_PATTERN.matcher(user.getEmail()).matches() || user.getEmail().length() > 255) {
            throw new IllegalArgumentException("Email không hợp lệ.");
        }
        if (user.getPhone() != null && !PHONE_PATTERN.matcher(user.getPhone()).matches()) {
            throw new IllegalArgumentException("Số điện thoại phải gồm 9 đến 15 chữ số.");
        }
        if (!INTERNAL_ROLES.contains(user.getRole())) {
            throw new IllegalArgumentException("Vai trò nội bộ không hợp lệ.");
        }
        if (!ALLOWED_STATUSES.contains(user.getStatus())) {
            throw new IllegalArgumentException("Trạng thái không hợp lệ.");
        }
    }

    private void validateSelfInternalUpdate(User existing, User updated, int actorUserId) {
        if (existing.getUserId() != actorUserId) {
            return;
        }

        if (!AppConfig.ROLE_ADMIN.equals(updated.getRole())) {
            throw new IllegalArgumentException("Bạn không thể tự hạ quyền quản trị của chính mình.");
        }

        if (!isActiveStatus(updated.getStatus())) {
            throw new IllegalArgumentException("Bạn không thể tự khóa hoặc vô hiệu hóa tài khoản của chính mình.");
        }
    }

    private void validateLastActiveAdmin(User existing, String newRole, String newStatus) throws SQLException {
        boolean wasActiveAdmin = AppConfig.ROLE_ADMIN.equals(existing.getRole()) && isActiveStatus(existing.getStatus());
        boolean remainsActiveAdmin = AppConfig.ROLE_ADMIN.equals(newRole) && isActiveStatus(newStatus);

        if (wasActiveAdmin && !remainsActiveAdmin && userDAO.countActiveAdmins() <= 1) {
            throw new IllegalArgumentException("Không thể làm mất quản trị viên đang hoạt động cuối cùng.");
        }
    }

    private void ensureCustomer(User user) {
        if (!AppConfig.ROLE_CUSTOMER.equals(user.getRole())) {
            throw new IllegalArgumentException("Tài khoản này không phải khách hàng.");
        }
    }

    private void ensureInternalUser(User user) {
        if (!INTERNAL_ROLES.contains(user.getRole())) {
            throw new IllegalArgumentException("Tài khoản này không thuộc nhóm nội bộ.");
        }
    }

    private boolean isActiveStatus(String status) {
        return "ACTIVE".equalsIgnoreCase(status);
    }

    /**
     * Chuẩn hóa chuỗi bắt buộc thành chữ hoa sau khi kiểm tra không rỗng.
     */
    private String normalizeRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        }
        return value.trim().toUpperCase();
    }

    /**
     * Cắt khoảng trắng và bắt buộc chuỗi phải có nội dung.
     */
    private String trimRequired(String value) {
        if (value == null || value.isBlank()) {
            throw new IllegalArgumentException("Vui lòng nhập đầy đủ thông tin bắt buộc.");
        }
        return value.trim();
    }

    /**
     * Cắt khoảng trắng cho chuỗi tùy chọn và chuyển chuỗi rỗng thành null.
     */
    private String normalizeOptional(String value) {
        if (value == null || value.isBlank()) {
            return null;
        }
        return value.trim().toUpperCase();
    }

    /**
     * Chuẩn hóa sort và chặn sort key không được hỗ trợ.
     */
    private String normalizeSort(String value) {
        if (value == null || value.isBlank()) {
            return "created_desc";
        }
        String normalized = value.trim().toLowerCase();
        if (!ALLOWED_SORTS.contains(normalized)) {
            throw new IllegalArgumentException("Tùy chọn sắp xếp không hợp lệ.");
        }
        return normalized;
    }

    /**
     * Chuẩn hóa số trang, mặc định về trang đầu nếu không hợp lệ.
     */
    private int normalizePage(int page) {
        return page <= 0 ? DEFAULT_PAGE : page;
    }

    /**
     * Chuẩn hóa kích thước trang và giới hạn tối đa để tránh truy vấn quá lớn.
     */
    private int normalizePageSize(int pageSize) {
        if (pageSize <= 0) {
            return DEFAULT_PAGE_SIZE;
        }
        return Math.min(pageSize, MAX_PAGE_SIZE);
    }

    public String updateProfile(User user) {
        try {
            // Kiểm tra trùng lặp Số điện thoại (Nghiệp vụ)
            if (user.getPhone() != null && !user.getPhone().trim().isEmpty()) {
                if (userDAO.existsByPhoneForOtherUser(user.getPhone(), user.getUserId())) {
                    return "Số điện thoại này đã được đăng ký bởi một tài khoản khác!";
                }
            }
            
            // Xử lý làm sạch (Sanitize) dữ liệu
            user.setFullName(user.getFullName().trim());
            user.setPhone(user.getPhone() == null ? null : user.getPhone().trim());

            boolean isSuccess = userDAO.updateProfile(user);
            return isSuccess ? "SUCCESS" : "Đã xảy ra lỗi khi cập nhật vào cơ sở dữ liệu.";
        } catch (SQLException e) {
            e.printStackTrace();
            return "Lỗi hệ thống. Vui lòng thử lại sau.";
        }
    }
}
