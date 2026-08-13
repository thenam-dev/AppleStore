<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Category Management" />
<c:set var="adminSidebarDescription" scope="request" value="Category taxonomy, visibility, and search organization." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Catalog module" />
<c:set var="adminSidebarFooterDescription" scope="request" value="List flow is ready; create, edit, and toggle actions come next." />
<c:set var="adminSidebarActive" scope="request" value="categories" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Categories</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/categories" method="get" name="adminCategoriesSearchForm">
                    <label class="visually-hidden" for="admin-categories-search">Search categories</label>
                    <input id="admin-categories-search" class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Search category name or slug">
                    <input type="hidden" name="status" value="${fn:escapeXml(selectedStatus)}">
                    <input type="hidden" name="sort" value="${fn:escapeXml(selectedSort)}">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/categories">Reset</a>
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Product List</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Categories</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Category management</span>
                    <h1>Catalog categories</h1>
                    <p>First backend route for the catalog module. This page already reads real category data from MySQL.</p>
                </div>
                <a class="btn btn-app-primary" href="${appPath}/admin/categories/edit">Create Category</a>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" role="alert"><c:out value="${successMsg}" /></div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Categories</div>
                    <div class="stat-value">${totalCategories}</div>
                    <p>Total categories in database</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Active</div>
                    <div class="stat-value">${activeCategories}</div>
                    <p>Visible to product assignment</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Inactive</div>
                    <div class="stat-value">${inactiveCategories}</div>
                    <p>Hidden or reserved categories</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Filtered</div>
                    <div class="stat-value">${filteredCategories}</div>
                    <p>Current result after search/filter</p>
                </article>
            </section>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Category table</h2>
                        <p>DAO reads from the categories table and the servlet forwards the current filtered page to JSP.</p>
                    </div>
                    <span class="text-muted small">Filtered result: ${filteredCategories}</span>
                </div>
                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="${appPath}/admin/categories" method="get" name="adminCategoryFilterForm">
                        <input class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Search by category name or slug">
                        <select class="form-select" name="status">
                            <option value="">All status</option>
                            <c:forEach var="status" items="${categoryStatusOptions}">
                                <c:choose>
                                    <c:when test="${selectedStatus eq status}">
                                        <option value="${fn:escapeXml(status)}" selected><c:out value="${status}" /></option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(status)}"><c:out value="${status}" /></option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </select>
                        <select class="form-select" name="sort">
                            <c:forEach var="sortOption" items="${sortOptions}">
                                <c:choose>
                                    <c:when test="${selectedSort eq sortOption.value}">
                                        <option value="${fn:escapeXml(sortOption.value)}" selected><c:out value="${sortOption.label}" /></option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(sortOption.value)}"><c:out value="${sortOption.label}" /></option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
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
                            <c:choose>
                                <c:when test="${empty categories}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">No categories found.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="category" items="${categories}">
                                        <tr>
                                            <td><strong>#${category.categoryId}</strong></td>
                                            <td><strong><c:out value="${category.name}" /></strong></td>
                                            <td><code><c:out value="${category.slug}" /></code></td>
                                            <td>${category.displayOrder}</td>
                                            <td>
                                                <span class="status-badge ${category.isActive ? 'status-in-stock' : 'status-out-stock'}">
                                                    ${category.isActive ? 'ACTIVE' : 'INACTIVE'}
                                                </span>
                                            </td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/categories/edit?id=${category.categoryId}">Edit</a>
                                                <form class="d-inline" action="${appPath}/admin/categories/status" method="post">
                                                    <input type="hidden" name="categoryId" value="${category.categoryId}">
                                                    <input type="hidden" name="status" value="${category.isActive ? 'INACTIVE' : 'ACTIVE'}">
                                                    <button class="btn ${category.isActive ? 'btn-app-outline' : 'btn-app-primary'} btn-sm" type="submit">
                                                        ${category.isActive ? 'Deactivate' : 'Activate'}
                                                    </button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <nav aria-label="Category pagination" class="mt-3">
                    <ul class="pagination app-pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage le 1}">
                                    <span class="page-link">Prev</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/categories?page=${currentPage - 1}${listQuerySuffix}">Prev</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                        <c:forEach var="pageNumber" begin="1" end="${totalPages}">
                            <li class="page-item ${pageNumber eq currentPage ? 'active' : ''}">
                                <c:choose>
                                    <c:when test="${pageNumber eq currentPage}">
                                        <span class="page-link">${pageNumber}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="page-link" href="${appPath}/admin/categories?page=${pageNumber}${listQuerySuffix}">${pageNumber}</a>
                                    </c:otherwise>
                                </c:choose>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage ge totalPages ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage ge totalPages}">
                                    <span class="page-link">Next</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/categories?page=${currentPage + 1}${listQuerySuffix}">Next</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                    </ul>
                </nav>
            </section>

            <p class="admin-footer-note">Create, edit, activate, and deactivate actions now route through real category servlets.</p>
        </section>
    </main>
</body>
</html>
