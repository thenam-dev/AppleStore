<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Product Management" />
<c:set var="adminSidebarDescription" scope="request" value="Product master data, status control, and category assignment." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Catalog module" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Variants, images, and specifications will be plugged in after the product master-data flow is stable." />
<c:set var="adminSidebarActive" scope="request" value="products" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Products</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/products" method="get" name="adminProductsSearchForm">
                    <label class="visually-hidden" for="admin-products-search">Search products</label>
                    <input id="admin-products-search" class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Search by product name or model code">
                    <input type="hidden" name="categoryId" value="${selectedCategoryId}">
                    <input type="hidden" name="status" value="${fn:escapeXml(selectedStatus)}">
                    <input type="hidden" name="sort" value="${fn:escapeXml(selectedSort)}">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/categories">Categories</a>
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Reset</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Products</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Product management</span>
                    <h1>Catalog products</h1>
                    <p>This backend version manages product master data and now links directly into variant-level SKU, stock, and pricing management.</p>
                </div>
                <a class="btn btn-app-primary" href="${appPath}/admin/products/edit">Add Product</a>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" role="alert"><c:out value="${successMsg}" /></div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Total Products</div>
                    <div class="stat-value">${totalProducts}</div>
                    <p>All records in product master data</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Active</div>
                    <div class="stat-value">${activeProducts}</div>
                    <p>Visible for selling</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Inactive</div>
                    <div class="stat-value">${inactiveProducts}</div>
                    <p>Temporarily hidden</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Discontinued</div>
                    <div class="stat-value">${discontinuedProducts}</div>
                    <p>Kept for history and audit</p>
                </article>
            </section>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Product list</h2>
                        <p>List, search, filter, sort, paging, create, update, and status toggle now route through servlet, service, and DAO.</p>
                    </div>
                    <span class="text-muted small">Filtered result: ${filteredProducts}</span>
                </div>
                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="${appPath}/admin/products" method="get" name="adminProductFilterForm">
                        <input class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Search product name or model code">
                        <select class="form-select" name="categoryId">
                            <option value="">All categories</option>
                            <c:forEach var="category" items="${categories}">
                                <c:choose>
                                    <c:when test="${selectedCategoryId eq category.categoryId}">
                                        <option value="${category.categoryId}" selected><c:out value="${category.name}" /></option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${category.categoryId}"><c:out value="${category.name}" /></option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </select>
                        <select class="form-select" name="status">
                            <option value="">All status</option>
                            <c:forEach var="status" items="${productStatusOptions}">
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
                                <th scope="col">Product</th>
                                <th scope="col">Category</th>
                                <th scope="col">Price</th>
                                <th scope="col">Stock</th>
                                <th scope="col">Status</th>
                                <th scope="col" class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty products}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">No products found.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="product" items="${products}">
                                        <c:choose>
                                            <c:when test="${product.status eq 'ACTIVE'}">
                                                <c:set var="productStatusClass" value="status-in-stock" />
                                                <c:set var="nextStatus" value="INACTIVE" />
                                                <c:set var="statusActionLabel" value="Deactivate" />
                                                <c:set var="statusActionClass" value="btn-app-outline" />
                                            </c:when>
                                            <c:when test="${product.status eq 'INACTIVE'}">
                                                <c:set var="productStatusClass" value="status-out-stock" />
                                                <c:set var="nextStatus" value="ACTIVE" />
                                                <c:set var="statusActionLabel" value="Activate" />
                                                <c:set var="statusActionClass" value="btn-app-primary" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="productStatusClass" value="status-cancelled" />
                                                <c:set var="nextStatus" value="ACTIVE" />
                                                <c:set var="statusActionLabel" value="Reactivate" />
                                                <c:set var="statusActionClass" value="btn-app-primary" />
                                            </c:otherwise>
                                        </c:choose>
                                        <tr>
                                            <td>
                                                <strong><c:out value="${product.name}" /></strong>
                                                <small class="d-block text-muted">
                                                    <c:choose>
                                                        <c:when test="${not empty product.modelCode}">
                                                            Model: <c:out value="${product.modelCode}" />
                                                        </c:when>
                                                        <c:otherwise>
                                                            Product ID: #${product.productId}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </small>
                                                <small class="d-block text-muted">Variants: ${product.variantCount}</small>
                                            </td>
                                            <td><c:out value="${product.categoryName}" /></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${product.variantCount gt 0 and not empty product.minPrice}">
                                                        <fmt:formatNumber value="${product.minPrice}" pattern="#,##0.##" /> VND
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">No variant yet</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${product.totalStock}</td>
                                            <td><span class="status-badge ${productStatusClass}"><c:out value="${product.status}" /></span></td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/variants?productId=${product.productId}">Variants</a>
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/edit?id=${product.productId}">Edit</a>
                                                <form class="d-inline" action="${appPath}/admin/products/status" method="post">
                                                    <input type="hidden" name="productId" value="${product.productId}">
                                                    <input type="hidden" name="status" value="${nextStatus}">
                                                    <button class="btn ${statusActionClass} btn-sm" type="submit">${statusActionLabel}</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <nav aria-label="Product pagination" class="mt-3">
                    <ul class="pagination app-pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage le 1}">
                                    <span class="page-link">Prev</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/products?page=${currentPage - 1}${listQuerySuffix}">Prev</a>
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
                                        <a class="page-link" href="${appPath}/admin/products?page=${pageNumber}${listQuerySuffix}">${pageNumber}</a>
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
                                    <a class="page-link" href="${appPath}/admin/products?page=${currentPage + 1}${listQuerySuffix}">Next</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                    </ul>
                </nav>
            </section>

            <p class="admin-footer-note">Variant CRUD is now available. Image and specification CRUD can be layered on next without changing the product master-data flow.</p>
        </section>
    </main>
</body>
</html>
