<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="model.User" %>
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

    private String selected(Object current, String option) {
        if (current == null) {
            return "";
        }
        return option.equalsIgnoreCase(String.valueOf(current)) ? "selected" : "";
    }
%>
<%
    User user = (User) request.getAttribute("user");
    List<String> roles = (List<String>) request.getAttribute("roles");
    if (roles == null) {
        roles = List.of("CUSTOMER", "ADMIN", "SALE_STAFF", "DELIVERY");
    }

    List<String> statuses = (List<String>) request.getAttribute("statuses");
    if (statuses == null) {
        statuses = List.of("ACTIVE", "INACTIVE", "LOCKED", "SUSPENDED");
    }

    String errorMessage = (String) request.getAttribute("errorMessage");
    String appPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Edit User</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <%
            request.setAttribute("adminSidebarTitle", "Edit User");
            request.setAttribute("adminSidebarDescription", "Validate in service, persist through DAO.");
            request.setAttribute("adminSidebarFooterTitle", "Form sample");
            request.setAttribute("adminSidebarFooterDescription", "This form intentionally avoids password changes until auth is implemented.");
        %>
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="<%= appPath %>/admin/users" method="get" name="adminUsersSearchForm">
                    <label class="visually-hidden" for="admin-users-search">Search users</label>
                    <input id="admin-users-search" class="form-control" type="search" name="keyword" placeholder="Search name, email, phone">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/users">Back to Users</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard.html">Admin</a></li>
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/users">Users</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Edit</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">User management</span>
                    <h1>Edit user</h1>
                    <p>Servlet receives the form, service validates the request, DAO updates the users table.</p>
                </div>
            </div>

            <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="alert alert-danger" role="alert"><%= h(errorMessage) %></div>
            <% } %>

            <% if (user == null) { %>
                <section class="admin-panel">
                    <p class="mb-0">User not found.</p>
                </section>
            <% } else { %>
                <section class="admin-panel">
                    <div class="admin-panel-head">
                        <div>
                            <h2>Account information</h2>
                            <p>Only profile, role and status are editable in this starter flow.</p>
                        </div>
                    </div>

                    <form class="admin-form-stack" action="<%= appPath %>/admin/users/update" method="post">
                        <input type="hidden" name="userId" value="<%= user.getUserId() %>">

                        <div class="admin-form-grid">
                            <div>
                                <label class="form-label" for="fullName">Full name</label>
                                <input id="fullName" class="form-control" type="text" name="fullName" maxlength="100" value="<%= h(user.getFullName()) %>" required>
                            </div>
                            <div>
                                <label class="form-label" for="email">Email</label>
                                <input id="email" class="form-control" type="email" name="email" maxlength="255" value="<%= h(user.getEmail()) %>" required>
                            </div>
                            <div>
                                <label class="form-label" for="phone">Phone</label>
                                <input id="phone" class="form-control" type="tel" name="phone" maxlength="15" value="<%= h(user.getPhone()) %>">
                            </div>
                            <div>
                                <label class="form-label" for="role">Role</label>
                                <select id="role" class="form-select" name="role" required>
                                    <% for (String role : roles) { %>
                                        <option value="<%= h(role) %>" <%= selected(user.getRole(), role) %>><%= h(role) %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" for="status">Status</label>
                                <select id="status" class="form-select" name="status" required>
                                    <% for (String status : statuses) { %>
                                        <option value="<%= h(status) %>" <%= selected(user.getStatus(), status) %>><%= h(status) %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="form-check align-self-end">
                                <input id="emailVerified" class="form-check-input" type="checkbox" name="emailVerified" <%= user.isEmailVerified() ? "checked" : "" %>>
                                <label class="form-check-label" for="emailVerified">Email verified</label>
                            </div>
                        </div>

                        <div class="admin-form-actions">
                            <a class="btn btn-app-outline" href="<%= appPath %>/admin/users">Cancel</a>
                            <button class="btn btn-app-primary" type="submit">Save Changes</button>
                        </div>
                    </form>
                </section>
            <% } %>

            <p class="admin-footer-note">Password and login session logic are intentionally left for the auth flow owner.</p>
        </section>
    </main>
</body>
</html>
