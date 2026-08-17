<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="sidebarTitle" value="${empty requestScope.adminSidebarTitle ? 'Quản trị' : requestScope.adminSidebarTitle}" />
<c:set var="sidebarDescription" value="${empty requestScope.adminSidebarDescription ? 'Không gian quản trị.' : requestScope.adminSidebarDescription}" />
<c:set var="sidebarFooterTitle" value="${empty requestScope.adminSidebarFooterTitle ? 'Khu vực quản trị' : requestScope.adminSidebarFooterTitle}" />
<c:set var="sidebarFooterDescription" value="${empty requestScope.adminSidebarFooterDescription ? 'Các trang được bảo vệ và xử lý qua Servlet.' : requestScope.adminSidebarFooterDescription}" />
<c:set var="activeItem" value="${requestScope.adminSidebarActive}" />
<aside class="admin-sidebar">
    <div class="admin-sidebar-brand">
        <img src="${appPath}/assets/images/logo-mark.svg" alt="Biểu tượng AOS">
        <div>
            <strong>Quản trị AOS</strong>
            <small>AppleStore</small>
        </div>
    </div>
    <div class="admin-sidebar-meta">
        <strong><c:out value="${sidebarTitle}" /></strong>
        <small><c:out value="${sidebarDescription}" /></small>
        <div class="mt-3">
            <a class="btn btn-app-outline btn-sm w-100 admin-storefront-link" href="${appPath}/index.jsp">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                Về trang chủ
            </a>
        </div>
    </div>
    <div>
        <p class="admin-sidebar-label">Quản trị</p>
        <nav class="admin-nav">
            <a class="${activeItem eq 'dashboard' ? 'active' : ''}" href="${appPath}/admin/dashboard">Tổng quan</a>

            <a class="${activeItem eq 'products' ? 'active' : ''}" href="${appPath}/admin/products">Sản phẩm</a>
            <a class="${activeItem eq 'categories' ? 'active' : ''}" href="${appPath}/admin/categories">Danh mục</a>
            <a class="${activeItem eq 'users' ? 'active' : ''}" href="${appPath}/admin/users">Người dùng</a>
            <a class="${activeItem eq 'vouchers' ? 'active' : ''}" href="${appPath}/admin/promotions">Mã giảm giá</a>
            <a class="${activeItem eq 'vouchers' ? 'active' : ''}" href="${appPath}/staff/orders">Mã giảm giá</a>
        </nav>
    </div>
    <div class="admin-sidebar-footer">
        <strong><c:out value="${sidebarFooterTitle}" /></strong>
        <small><c:out value="${sidebarFooterDescription}" /></small>
    </div>
</aside>
