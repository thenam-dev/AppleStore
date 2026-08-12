<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
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
%>
<%
    Category category = (Category) request.getAttribute("category");
    boolean isEdit = category != null && category.getCategoryId() > 0;
    String errorMsg = (String) request.getAttribute("errorMsg");
    String appPath = request.getContextPath();

    if (category == null) {
        category = new Category();
        category.setDisplayOrder(0);
        category.setIsActive(true);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | <%= isEdit ? "Edit" : "Create" %> Category</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <%
            request.setAttribute("adminSidebarTitle", isEdit ? "Edit Category" : "Create Category");
            request.setAttribute("adminSidebarDescription", "Validate in service, persist through DAO.");
            request.setAttribute("adminSidebarFooterTitle", "Catalog form");
            request.setAttribute("adminSidebarFooterDescription", "This form keeps category data small and easy to maintain.");
            request.setAttribute("adminSidebarActive", "categories");
        %>
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="<%= appPath %>/admin/categories" method="get" name="adminCategoriesSearchForm">
                    <label class="visually-hidden" for="admin-categories-search">Search categories</label>
                    <input id="admin-categories-search" class="form-control" type="search" name="keyword" placeholder="Search category name or slug">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/categories">Back to Categories</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard.html">Admin</a></li>
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/categories">Categories</a></li>
                    <li class="breadcrumb-item active" aria-current="page"><%= isEdit ? "Edit" : "Create" %></li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Category management</span>
                    <h1><%= isEdit ? "Edit category" : "Create category" %></h1>
                    <p>Servlet receives the form, service validates the request, DAO writes to the categories table.</p>
                </div>
            </div>

            <% if (errorMsg != null && !errorMsg.isBlank()) { %>
                <div class="alert alert-danger" role="alert"><%= h(errorMsg) %></div>
            <% } %>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Category information</h2>
                        <p>Keep the taxonomy simple so product assignment and storefront filters remain predictable.</p>
                    </div>
                </div>

                <form class="admin-form-stack" action="<%= appPath %>/admin/categories/update" method="post">
                    <% if (isEdit) { %>
                        <input type="hidden" name="categoryId" value="<%= category.getCategoryId() %>">
                    <% } %>

                    <div class="admin-form-grid">
                        <div>
                            <label class="form-label" for="name">Category name</label>
                            <input id="name" class="form-control" type="text" name="name" maxlength="100" value="<%= h(category.getName()) %>" required>
                        </div>
                        <div>
                            <label class="form-label" for="slug">Slug</label>
                            <input id="slug" class="form-control" type="text" name="slug" maxlength="100" pattern="[a-z0-9]+(?:-[a-z0-9]+)*" title="Use lowercase letters, numbers, and hyphens only." value="<%= h(category.getSlug()) %>" placeholder="iphone" required>
                        </div>
                        <div>
                            <label class="form-label" for="displayOrder">Display order</label>
                            <input id="displayOrder" class="form-control" type="number" name="displayOrder" min="0" value="<%= category.getDisplayOrder() %>" required>
                        </div>
                        <div class="form-check align-self-end mt-3">
                            <input id="isActive" class="form-check-input" type="checkbox" name="isActive" <%= category.getIsActive() ? "checked" : "" %>>
                            <label class="form-check-label" for="isActive">Active</label>
                        </div>
                    </div>

                    <div class="admin-form-actions mt-4">
                        <a class="btn btn-app-outline" href="<%= appPath %>/admin/categories">Cancel</a>
                        <button class="btn btn-app-primary" type="submit"><%= isEdit ? "Save Changes" : "Create Category" %></button>
                    </div>
                </form>
            </section>
        </section>
    </main>
</body>
</html>
