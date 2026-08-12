<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%!
    private String h(Object value) {
        if (value == null) {
            return "";
        }
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    String appPath = request.getContextPath();
    String sidebarTitle = (String) request.getAttribute("adminSidebarTitle");
    String sidebarDescription = (String) request.getAttribute("adminSidebarDescription");
    String sidebarFooterTitle = (String) request.getAttribute("adminSidebarFooterTitle");
    String sidebarFooterDescription = (String) request.getAttribute("adminSidebarFooterDescription");
    boolean showUserQuickLinks = Boolean.TRUE.equals(request.getAttribute("adminSidebarShowUserQuickLinks"));

    if (sidebarTitle == null || sidebarTitle.isBlank()) {
        sidebarTitle = "Admin";
    }
    if (sidebarDescription == null || sidebarDescription.isBlank()) {
        sidebarDescription = "Admin workspace.";
    }
    if (sidebarFooterTitle == null || sidebarFooterTitle.isBlank()) {
        sidebarFooterTitle = "Admin module";
    }
    if (sidebarFooterDescription == null || sidebarFooterDescription.isBlank()) {
        sidebarFooterDescription = "Protected pages should be rendered through servlets.";
    }
%>
<aside class="admin-sidebar">
    <div class="admin-sidebar-brand">
        <img src="<%= appPath %>/assets/images/logo-mark.svg" alt="AOS mark">
        <div>
            <strong>AOS Admin</strong>
            <small>Apple Online Shop</small>
        </div>
    </div>
    <div class="admin-sidebar-meta">
        <strong><%= h(sidebarTitle) %></strong>
        <small><%= h(sidebarDescription) %></small>
        
        <div class="mt-3">
            <a class="btn btn-app-outline btn-sm w-100" href="<%= appPath %>/" style="display: flex; justify-content: center; align-items: center; gap: 8px;">
                <svg xmlns="http://www.w3.org/2000/svg" width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                Mở Storefront
            </a>
        </div>
    </div>
    <div>
        <p class="admin-sidebar-label">Overview</p>
        <nav class="admin-nav">
            <a class="active" href="<%= appPath %>/admin/dashboard">Dashboard</a>
            <a href="<%= appPath %>/admin/products.html">Products</a>
            <a href="<%= appPath %>/admin/categories.html">Categories</a>
            <a href="<%= appPath %>/admin/orders.html">Orders</a>
            <a href="<%= appPath %>/admin/inventory.html">Inventory</a>
            <a href="<%= appPath %>/admin/users">Users</a>
            <a href="<%= appPath %>/admin/vouchers.html">Vouchers</a>
            <a href="<%= appPath %>/admin/feedback.html">Feedback</a>
        </nav>
    </div>
    <% if (showUserQuickLinks) { %>
        <div>
            <p class="admin-sidebar-label">Quick actions</p>
            <nav class="admin-nav">
                <a href="<%= appPath %>/admin/users?role=CUSTOMER">Customers</a>
                <a href="<%= appPath %>/admin/users?role=ADMIN">Admins</a>
                <a href="<%= appPath %>/index.jsp">Open Storefront</a>
            </nav>
        </div>
    <% } %>
    <div class="admin-sidebar-footer">
        <strong><%= h(sidebarFooterTitle) %></strong>
        <small><%= h(sidebarFooterDescription) %></small>
    </div>
</aside>
