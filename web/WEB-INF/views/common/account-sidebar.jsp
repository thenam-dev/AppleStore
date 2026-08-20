<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<style>
    /* Bổ sung một số CSS Layout riêng cho trang Profile */
    .profile-container {
        display: flex;
        flex-direction: column;
        gap: 32px;
        margin-top: 32px;
        margin-bottom: 64px;
    }
    @media (min-width: 992px) {
        .profile-container {
            flex-direction: row;
            align-items: flex-start;
        }
    }
    .profile-sidebar {
        flex: 0 0 280px;
        background: #FAFBFC;
        padding: 24px;
        border-radius: var(--r-md);
        border: 1px solid var(--line);
        width: 100%;
    }
    .profile-content {
        flex: 1;
        background: #ffffff;
        padding: 32px;
        border-radius: var(--r-md);
        border: 1px solid var(--line);
        box-shadow: 0 4px 12px rgba(0,0,0,0.02);
        width: 100%;
    }
    .sidebar-user {
        display: flex;
        align-items: center;
        gap: 16px;
        padding-bottom: 24px;
        margin-bottom: 24px;
        border-bottom: 1px solid var(--line);
    }
    .sidebar-avatar {
        width: 60px;
        height: 60px;
        border-radius: 50%;
        overflow: hidden;
        background: var(--titan);
        display: flex;
        align-items: center;
        justify-content: center;
        color: #fff;
        font-weight: bold;
        font-size: 24px;
        flex-shrink: 0;
    }
    .sidebar-avatar img {
        width: 100%;
        height: 100%;
        object-fit: cover;
    }
    .sidebar-user-info h3 {
        margin: 0;
        font-size: 16px;
        font-weight: 600;
        color: var(--txt);
        white-space: nowrap;
        overflow: hidden;
        text-overflow: ellipsis;
    }
    .sidebar-user-info p {
        margin: 0;
        font-size: 13px;
        color: var(--txt-2);
    }
    .sidebar-role-badge {
        display: inline-block;
        margin-top: 4px;
        padding: 2px 8px;
        font-size: 10px;
        background: #E5E7EB;
        color: var(--txt);
        border-radius: 12px;
        font-weight: bold;
        text-transform: uppercase;
    }
    .sidebar-nav {
        display: flex;
        flex-direction: column;
        gap: 8px;
    }
    .sidebar-nav a {
        display: block;
        padding: 10px 16px;
        border-radius: 8px;
        color: var(--txt-2);
        text-decoration: none;
        font-weight: 500;
        transition: all 0.2s;
    }
    .sidebar-nav a:hover {
        background: #F3F4F6;
        color: var(--txt);
    }
    .sidebar-nav a.active {
        background: var(--titan);
        color: #fff;
    }
    .sidebar-nav a.danger {
        color: #d32f2f;
    }
    .sidebar-nav a.danger:hover {
        background: #ffebee;
    }
    .form-grid {
        display: grid;
        grid-template-columns: 1fr;
        gap: 24px;
        margin-bottom: 24px;
    }
    @media (min-width: 768px) {
        .form-grid {
            grid-template-columns: 1fr 1fr;
        }
    }
    .form-group {
        grid-column: span 1;
    }
    .form-group.full {
        grid-column: span 1;
    }
    @media (min-width: 768px) {
        .form-group.full {
            grid-column: span 2;
        }
    }
    .form-group label {
        display: block;
        margin-bottom: 8px;
        font-size: 14px;
        font-weight: 600;
        color: var(--txt);
    }
    .form-group input {
        width: 100%;
        background: transparent;
    }
    .form-group input[readonly] {
        background-color: #f9fafb;
        color: var(--txt-3);
        cursor: not-allowed;
    }
    .alert-msg {
        margin-bottom: 20px;
        padding: 16px;
        border-radius: 8px;
        font-size: 14px;
        font-weight: 500;
    }
    .alert-msg.success {
        background: #e8f5e9;
        color: #2e7d32;
        border: 1px solid #c8e6c9;
    }
    .alert-msg.error {
        background: #ffebee;
        color: #c62828;
        border: 1px solid #ffcdd2;
    }
</style>

<aside class="profile-sidebar">
    <div class="sidebar-user">
        <div class="sidebar-avatar">
            <c:choose>
                <c:when test="${not empty sessionScope.user.avatarUrl}">
                    <img src="${sessionScope.user.avatarUrl}" alt="Avatar">
                </c:when>
                <c:otherwise>
                    ${sessionScope.user.fullName.substring(0,1)}
                </c:otherwise>
            </c:choose>
        </div>
        <div class="sidebar-user-info">
            <h3>${sessionScope.user.fullName != null ? sessionScope.user.fullName : 'Khách'}</h3>
            <p>${sessionScope.user.email}</p>
            <span class="sidebar-role-badge">${sessionScope.user.role}</span>
        </div>
    </div>
    
    <nav class="sidebar-nav">
        <a href="${ctx}/profile" class="${activeMenu == 'profile' ? 'active' : ''}">Hồ sơ cá nhân</a>
        <c:if test="${sessionScope.user.role == 'CUSTOMER'}">
            <a href="${ctx}/addresses" class="${activeMenu == 'addresses' ? 'active' : ''}">Sổ địa chỉ</a>
            <a href="${ctx}/account/orders" class="${activeMenu == 'orders' ? 'active' : ''}">Đơn hàng của tôi</a>
            <a href="${ctx}/wishlist" class="${activeMenu == 'wishlist' ? 'active' : ''}">Yêu thích</a>
        </c:if>
        <c:if test="${sessionScope.user.role != 'CUSTOMER'}">
            <a href="${ctx}/dashboard" class="${activeMenu == 'dashboard' ? 'active' : ''}">Quản trị hệ thống</a>
        </c:if>
        <a href="${ctx}/change-password" class="${activeMenu == 'change-password' ? 'active' : ''}">Đổi mật khẩu</a>
        <a href="${ctx}/logout" class="danger">Đăng xuất</a>
    </nav>
</aside>
