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
    </div>
    <div>
        <p class="admin-sidebar-label">Overview</p>
        <nav class="admin-nav">
            <a href="<%= appPath %>/admin/dashboard.html">Dashboard</a>
            <a href="<%= appPath %>/admin/products.html">Products</a>
            <a href="<%= appPath %>/admin/categories.html">Categories</a>
            <a href="<%= appPath %>/admin/orders.html">Orders</a>
            <a href="<%= appPath %>/admin/inventory.html">Inventory</a>
            <a class="active" href="<%= appPath %>/admin/users">Users</a>
            <a href="<%= appPath %>/admin/promotions">Promotions</a>
            <a href="<%= appPath %>/admin/feedback.html">Feedback</a>
        </nav>
    </div>
    <% if (showUserQuickLinks) { %>
        <div>
            <p class="admin-sidebar-label">Quick actions</p>
            <nav class="admin-nav">
                <a href="<%= appPath %>/admin/users?role=CUSTOMER">Customers</a>
                <a href="<%= appPath %>/admin/users?role=ADMIN">Admins</a>
                <a href="<%= appPath %>/index.html">Open Storefront</a>
            </nav>
        </div>
    <% } %>
    <div class="admin-sidebar-footer">
        <strong><%= h(sidebarFooterTitle) %></strong>
        <small><%= h(sidebarFooterDescription) %></small>
    </div>
</aside>
