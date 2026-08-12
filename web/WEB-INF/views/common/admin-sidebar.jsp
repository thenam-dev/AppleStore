<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="sidebarTitle" value="${empty requestScope.adminSidebarTitle ? 'Admin' : requestScope.adminSidebarTitle}" />
<c:set var="sidebarDescription" value="${empty requestScope.adminSidebarDescription ? 'Admin workspace.' : requestScope.adminSidebarDescription}" />
<c:set var="sidebarFooterTitle" value="${empty requestScope.adminSidebarFooterTitle ? 'Admin module' : requestScope.adminSidebarFooterTitle}" />
<c:set var="sidebarFooterDescription" value="${empty requestScope.adminSidebarFooterDescription ? 'Protected pages should be rendered through servlets.' : requestScope.adminSidebarFooterDescription}" />
<c:set var="activeItem" value="${requestScope.adminSidebarActive}" />
<c:set var="showUserQuickLinks" value="${requestScope.adminSidebarShowUserQuickLinks eq true}" />
<aside class="admin-sidebar">
    <div class="admin-sidebar-brand">
        <img src="${appPath}/assets/images/logo-mark.svg" alt="AOS mark">
        <div>
            <strong>AOS Admin</strong>
            <small>Apple Online Shop</small>
        </div>
    </div>
    <div class="admin-sidebar-meta">
        <strong><c:out value="${sidebarTitle}" /></strong>
        <small><c:out value="${sidebarDescription}" /></small>
        <div class="mt-3">
            <a class="btn btn-app-outline btn-sm w-100" href="${appPath}/index.jsp" style="display: flex; justify-content: center; align-items: center; gap: 8px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                Open Storefront
            </a>
        </div>
    </div>
    <div>
        <p class="admin-sidebar-label">Overview</p>
        <nav class="admin-nav">
            <a class="${activeItem eq 'dashboard' ? 'active' : ''}" href="${appPath}/admin/dashboard">Dashboard</a>
            <a class="${activeItem eq 'products' ? 'active' : ''}" href="${appPath}/admin/products">Products</a>
            <a class="${activeItem eq 'categories' ? 'active' : ''}" href="${appPath}/admin/categories">Categories</a>
            <a class="${activeItem eq 'orders' ? 'active' : ''}" href="${appPath}/admin/orders.html">Orders</a>
            <a class="${activeItem eq 'inventory' ? 'active' : ''}" href="${appPath}/admin/inventory.html">Inventory</a>
            <a class="${activeItem eq 'users' ? 'active' : ''}" href="${appPath}/admin/users">Users</a>
            <a class="${activeItem eq 'vouchers' ? 'active' : ''}" href="${appPath}/admin/promotions">Vouchers</a>
            <a class="${activeItem eq 'feedback' ? 'active' : ''}" href="${appPath}/admin/feedback.html">Feedback</a>
        </nav>
    </div>
    <c:if test="${showUserQuickLinks}">
        <div>
            <p class="admin-sidebar-label">Quick actions</p>
            <nav class="admin-nav">
                <a href="${appPath}/admin/users?role=CUSTOMER">Customers</a>
                <a href="${appPath}/admin/users?role=ADMIN">Admins</a>
                <a href="${appPath}/index.jsp">Open Storefront</a>
            </nav>
        </div>
    </c:if>
    <div class="admin-sidebar-footer">
        <strong><c:out value="${sidebarFooterTitle}" /></strong>
        <small><c:out value="${sidebarFooterDescription}" /></small>
    </div>
</aside>
