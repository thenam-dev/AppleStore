<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="model.entity.catalog.Category" %>
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

    private String statusClass(boolean isActive) {
        return isActive ? "status-in-stock" : "status-out-stock";
    }
%>
<%
    List<Category> categories = (List<Category>) request.getAttribute("categories");
    if (categories == null) {
        categories = Collections.emptyList();
    }

    String keyword = (String) request.getAttribute("keyword");
    String selectedStatus = (String) request.getAttribute("selectedStatus");
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    Object totalCategories = request.getAttribute("totalCategories");
    Object activeCategories = request.getAttribute("activeCategories");
    Object inactiveCategories = request.getAttribute("inactiveCategories");
    Object filteredCategories = request.getAttribute("filteredCategories");
    String appPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Categories</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <%
            request.setAttribute("adminSidebarTitle", "Category Management");
            request.setAttribute("adminSidebarDescription", "Category taxonomy, visibility, and search organization.");
            request.setAttribute("adminSidebarFooterTitle", "Catalog module");
            request.setAttribute("adminSidebarFooterDescription", "List flow is ready; create, edit, and toggle actions come next.");
            request.setAttribute("adminSidebarActive", "categories");
        %>
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="<%= appPath %>/admin/categories" method="get" name="adminCategoriesSearchForm">
                    <label class="visually-hidden" for="admin-categories-search">Search categories</label>
                    <input id="admin-categories-search" class="form-control" type="search" name="keyword" value="<%= h(keyword) %>" placeholder="Search category name or slug">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/categories">Reset</a>
                    <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/products.html">Product List</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard.html">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Categories</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Category management</span>
                    <h1>Catalog categories</h1>
                    <p>First backend route for the catalog module. This page already reads real category data from MySQL.</p>
                </div>
                <a class="btn btn-app-primary" href="<%= appPath %>/admin/categories/edit">Create Category</a>
            </div>

            <% if (successMessage != null && !successMessage.isBlank()) { %>
                <div class="alert alert-success" role="alert"><%= h(successMessage) %></div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="alert alert-danger" role="alert"><%= h(errorMessage) %></div>
            <% } %>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Categories</div>
                    <div class="stat-value"><%= h(totalCategories) %></div>
                    <p>Total categories in database</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Active</div>
                    <div class="stat-value"><%= h(activeCategories) %></div>
                    <p>Visible to product assignment</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Inactive</div>
                    <div class="stat-value"><%= h(inactiveCategories) %></div>
                    <p>Hidden or reserved categories</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Filtered</div>
                    <div class="stat-value"><%= h(filteredCategories) %></div>
                    <p>Current result after search/filter</p>
                </article>
            </section>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Category table</h2>
                        <p>DAO reads from the categories table and the servlet forwards the filtered collection to JSP.</p>
                    </div>
                </div>
                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="<%= appPath %>/admin/categories" method="get" name="adminCategoryFilterForm">
                        <input class="form-control" type="search" name="keyword" value="<%= h(keyword) %>" placeholder="Search by category name or slug">
                        <select class="form-select" name="status">
                            <option value="">All status</option>
                            <option value="ACTIVE" <%= selected(selectedStatus, "ACTIVE") %>>Active</option>
                            <option value="INACTIVE" <%= selected(selectedStatus, "INACTIVE") %>>Inactive</option>
                        </select>
                        <button class="btn btn-app-primary" type="submit">Filter</button>
                    </form>
                </div>
                <div class="table-responsive">
                    <table class="table app-table">
                        <thead>
                            <tr>
                                <th scope="col">ID</th>
                                <th scope="col">Category name</th>
                                <th scope="col">Slug</th>
                                <th scope="col">Display order</th>
                                <th scope="col">Status</th>
                                <th scope="col" class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (categories.isEmpty()) { %>
                                <tr>
                                    <td colspan="6" class="text-center text-muted py-4">No categories found.</td>
                                </tr>
                            <% } %>
                            <% for (Category category : categories) { %>
                                <tr>
                                    <td><strong>#<%= category.getCategoryId() %></strong></td>
                                    <td><strong><%= h(category.getName()) %></strong></td>
                                    <td><code><%= h(category.getSlug()) %></code></td>
                                    <td><%= category.getDisplayOrder() %></td>
                                    <td>
                                        <span class="status-badge <%= statusClass(category.getIsActive()) %>">
                                            <%= category.getIsActive() ? "ACTIVE" : "INACTIVE" %>
                                        </span>
                                    </td>
                                    <td class="text-end table-actions">
                                        <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/categories/edit?id=<%= category.getCategoryId() %>">Edit</a>
                                        <form class="d-inline" action="<%= appPath %>/admin/categories/status" method="post">
                                            <input type="hidden" name="categoryId" value="<%= category.getCategoryId() %>">
                                            <button class="btn <%= category.getIsActive() ? "btn-app-outline" : "btn-app-primary" %> btn-sm" type="submit">
                                                <%= category.getIsActive() ? "Deactivate" : "Activate" %>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>

            <p class="admin-footer-note">Create, edit, activate, and deactivate actions now route through real category servlets.</p>
        </section>
    </main>
</body>
</html>
