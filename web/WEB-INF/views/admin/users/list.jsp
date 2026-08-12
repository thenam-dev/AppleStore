<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
<%@ page import="model.UserStats" %>
<%!
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");

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

    private String selected(Object current, String option) {
        if (current == null) {
            return "";
        }
        return option.equalsIgnoreCase(String.valueOf(current)) ? "selected" : "";
    }

    private String statusClass(String status) {
        if ("ACTIVE".equals(status)) {
            return "status-in-stock";
        }
        if ("INACTIVE".equals(status)) {
            return "status-out-stock";
        }
        if ("LOCKED".equals(status) || "SUSPENDED".equals(status)) {
            return "status-cancelled";
        }
        return "status-pending";
    }

    private String formatDate(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return DATE_FORMATTER.format(value);
    }

    private String initials(String fullName) {
        if (fullName == null || fullName.isBlank()) {
            return "US";
        }
        String[] parts = fullName.trim().split("\\s+");
        if (parts.length == 1) {
            return parts[0].substring(0, Math.min(2, parts[0].length())).toUpperCase();
        }
        return (parts[0].substring(0, 1) + parts[parts.length - 1].substring(0, 1)).toUpperCase();
    }
%>
<%
    List<User> users = (List<User>) request.getAttribute("users");
    if (users == null) {
        users = Collections.emptyList();
    }

    UserStats stats = (UserStats) request.getAttribute("stats");
    if (stats == null) {
        stats = new UserStats();
    }

    List<String> roles = (List<String>) request.getAttribute("roles");
    if (roles == null) {
        roles = List.of("CUSTOMER", "ADMIN", "SALE_STAFF", "DELIVERY");
    }

    List<String> statuses = (List<String>) request.getAttribute("statuses");
    if (statuses == null) {
        statuses = List.of("ACTIVE", "INACTIVE", "LOCKED", "SUSPENDED");
    }

    String keyword = (String) request.getAttribute("keyword");
    String selectedRole = (String) request.getAttribute("selectedRole");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String appPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Users</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <%
            request.setAttribute("adminSidebarTitle", "User Management");
            request.setAttribute("adminSidebarDescription", "Servlet, service, DAO and JDBC sample flow.");
            request.setAttribute("adminSidebarFooterTitle", "Backend sample");
            request.setAttribute("adminSidebarFooterDescription", "Use this page as the pattern for product, order and category modules.");
            request.setAttribute("adminSidebarShowUserQuickLinks", Boolean.TRUE);
        %>
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="<%= appPath %>/admin/users" method="get" name="adminUsersSearchForm">
                    <label class="visually-hidden" for="admin-users-search">Search users</label>
                    <input id="admin-users-search" class="form-control" type="search" name="keyword" value="<%= h(keyword) %>" placeholder="Search name, email, phone">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/users">Reset</a>
                    <div class="admin-user-pill">
                        <div class="account-avatar admin-user-pill-avatar">AD</div>
                        <div>
                            <strong>Admin</strong>
                            <small>User operations</small>
                        </div>
                    </div>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Users</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">User management</span>
                    <h1>User list</h1>
                    <p>Sample backend flow from JSP to servlet, service, DAO and MySQL.</p>
                </div>
            </div>

            <% if (successMessage != null && !successMessage.isBlank()) { %>
                <div class="alert alert-success" role="alert"><%= h(successMessage) %></div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="alert alert-danger" role="alert"><%= h(errorMessage) %></div>
            <% } %>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Users</div>
                    <div class="stat-value"><%= stats.getTotalUsers() %></div>
                    <p>Current filtered result</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Active</div>
                    <div class="stat-value"><%= stats.getActiveUsers() %></div>
                    <p>Can access the system</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Inactive</div>
                    <div class="stat-value"><%= stats.getInactiveUsers() %></div>
                    <p>Need activation or verification</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Staff</div>
                    <div class="stat-value"><%= stats.getStaffUsers() %></div>
                    <p>Admin, sale and delivery roles</p>
                </article>
            </section>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Users</h2>
                        <p>DAO reads from the users table and the servlet forwards this collection to JSP.</p>
                    </div>
                </div>
                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="<%= appPath %>/admin/users" method="get" name="adminUserFilterForm">
                        <input class="form-control" type="search" name="keyword" value="<%= h(keyword) %>" placeholder="Search name, email, phone">
                        <select class="form-select" name="role">
                            <option value="">All roles</option>
                            <% for (String role : roles) { %>
                                <option value="<%= h(role) %>" <%= selected(selectedRole, role) %>><%= h(role) %></option>
                            <% } %>
                        </select>
                        <select class="form-select" name="status">
                            <option value="">All status</option>
                            <% for (String status : statuses) { %>
                                <option value="<%= h(status) %>" <%= selected(selectedStatus, status) %>><%= h(status) %></option>
                            <% } %>
                        </select>
                        <button class="btn btn-app-primary" type="submit">Filter</button>
                    </form>
                </div>
                <div class="table-responsive">
                    <table class="table app-table">
                        <thead>
                            <tr>
                                <th scope="col">User</th>
                                <th scope="col">Contact</th>
                                <th scope="col">Role</th>
                                <th scope="col">Status</th>
                                <th scope="col">Verified</th>
                                <th scope="col">Created</th>
                                <th scope="col" class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users.isEmpty()) { %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">No users found.</td>
                                </tr>
                            <% } %>
                            <% for (User user : users) { %>
                                <tr>
                                    <td>
                                        <div class="admin-user-pill">
                                            <div class="account-avatar admin-user-pill-avatar"><%= h(initials(user.getFullName())) %></div>
                                            <div>
                                                <strong><%= h(user.getFullName()) %></strong>
                                                <small>#<%= user.getUserId() %></small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <strong><%= h(user.getEmail()) %></strong>
                                        <small class="d-block text-muted"><%= h(user.getPhone()) %></small>
                                    </td>
                                    <td><span class="status-badge status-processing"><%= h(user.getRole()) %></span></td>
                                    <td><span class="status-badge <%= statusClass(user.getStatus()) %>"><%= h(user.getStatus()) %></span></td>
                                    <td><%= user.isEmailVerified() ? "Yes" : "No" %></td>
                                    <td><%= h(formatDate(user.getCreatedAt())) %></td>
                                    <td class="text-end table-actions">
                                        <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/users/edit?id=<%= user.getUserId() %>">Edit</a>
                                        <form class="d-inline" action="<%= appPath %>/admin/users/status" method="post">
                                            <input type="hidden" name="userId" value="<%= user.getUserId() %>">
                                            <% if ("ACTIVE".equals(user.getStatus())) { %>
                                                <input type="hidden" name="status" value="LOCKED">
                                                <button class="btn btn-app-outline btn-sm" type="submit">Lock</button>
                                            <% } else { %>
                                                <input type="hidden" name="status" value="ACTIVE">
                                                <button class="btn btn-app-primary btn-sm" type="submit">Activate</button>
                                            <% } %>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>

            <p class="admin-footer-note">Route sample: GET /admin/users, GET /admin/users/edit?id=1, POST /admin/users/update, POST /admin/users/status.</p>
        </section>
    </main>
</body>
</html>
