<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Variant Management" />
<c:set var="adminSidebarDescription" scope="request" value="SKU, stock, pricing, and activation state for one product." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Product variants" />
<c:set var="adminSidebarFooterDescription" scope="request" value="This module feeds cart and checkout data through variant-level stock and price." />
<c:set var="adminSidebarActive" scope="request" value="products" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Variants</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/products/variants" method="get" name="adminVariantSearchForm">
                    <label class="visually-hidden" for="admin-variant-search">Search variants</label>
                    <input type="hidden" name="productId" value="${managedProduct.productId}">
                    <input type="hidden" name="status" value="${fn:escapeXml(selectedStatus)}">
                    <input type="hidden" name="sort" value="${fn:escapeXml(selectedSort)}">
                    <input id="admin-variant-search" class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Search by SKU, label, color, or chip">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/edit?id=${managedProduct.productId}">Edit Product</a>
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Back to Products</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/products">Products</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Variants</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Variant management</span>
                    <h1><c:out value="${managedProduct.name}" /></h1>
                    <p>Product status: <strong><c:out value="${managedProduct.status}" /></strong>. Variants here provide SKU, stock, and price for cart and checkout tests.</p>
                </div>
                <a class="btn btn-app-primary" href="${appPath}/admin/products/variants/edit?productId=${managedProduct.productId}">Add Variant</a>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" role="alert"><c:out value="${successMsg}" /></div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Total Variants</div>
                    <div class="stat-value">${totalVariants}</div>
                    <p>All SKUs under this product</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Active</div>
                    <div class="stat-value">${activeVariants}</div>
                    <p>Sellable variants</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Inactive</div>
                    <div class="stat-value">${inactiveVariants}</div>
                    <p>Hidden from selling flow</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Filtered</div>
                    <div class="stat-value">${filteredVariants}</div>
                    <p>Current result set</p>
                </article>
            </section>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Variant list</h2>
                        <p>Search, filter, sort, paging, create, update, and status toggle are scoped to the current product.</p>
                    </div>
                    <span class="text-muted small">Product ID: #${managedProduct.productId}</span>
                </div>

                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="${appPath}/admin/products/variants" method="get" name="adminVariantFilterForm">
                        <input type="hidden" name="productId" value="${managedProduct.productId}">
                        <input class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Search SKU, label, color, chip">
                        <select class="form-select" name="status">
                            <option value="">All status</option>
                            <c:forEach var="status" items="${variantStatusOptions}">
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
                                <th scope="col">SKU / Label</th>
                                <th scope="col">Specs</th>
                                <th scope="col">Price</th>
                                <th scope="col">Stock</th>
                                <th scope="col">Status</th>
                                <th scope="col" class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty variants}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">No variants found for this product.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="variant" items="${variants}">
                                        <c:choose>
                                            <c:when test="${variant.active}">
                                                <c:set var="variantStatusClass" value="status-in-stock" />
                                                <c:set var="nextStatus" value="INACTIVE" />
                                                <c:set var="statusActionLabel" value="Deactivate" />
                                                <c:set var="statusActionClass" value="btn-app-outline" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="variantStatusClass" value="status-out-stock" />
                                                <c:set var="nextStatus" value="ACTIVE" />
                                                <c:set var="statusActionLabel" value="Activate" />
                                                <c:set var="statusActionClass" value="btn-app-primary" />
                                            </c:otherwise>
                                        </c:choose>
                                        <tr>
                                            <td>
                                                <strong><c:out value="${variant.sku}" /></strong>
                                                <small class="d-block text-muted"><c:out value="${variant.variantLabel}" /></small>
                                            </td>
                                            <td>
                                                <c:if test="${not empty variant.colorName}">
                                                    <small class="d-block text-muted">Color: <c:out value="${variant.colorName}" /></small>
                                                </c:if>
                                                <c:if test="${variant.storageCapacityGb ne null}">
                                                    <small class="d-block text-muted">Storage: ${variant.storageCapacityGb} GB</small>
                                                </c:if>
                                                <c:if test="${variant.ramGb ne null}">
                                                    <small class="d-block text-muted">RAM: ${variant.ramGb} GB</small>
                                                </c:if>
                                                <c:if test="${not empty variant.connectivity}">
                                                    <small class="d-block text-muted">Connectivity: <c:out value="${variant.connectivity}" /></small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <strong><fmt:formatNumber value="${variant.price}" pattern="#,##0.##" /> VND</strong>
                                                <c:if test="${not empty variant.discountPrice}">
                                                    <small class="d-block text-muted">Discount: <fmt:formatNumber value="${variant.discountPrice}" pattern="#,##0.##" /> VND</small>
                                                </c:if>
                                            </td>
                                            <td>${variant.stockQuantity}</td>
                                            <td>
                                                <span class="status-badge ${variantStatusClass}">
                                                    <c:out value="${variant.active ? 'ACTIVE' : 'INACTIVE'}" />
                                                </span>
                                            </td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/variants/edit?id=${variant.variantId}">Edit</a>
                                                <form class="d-inline" action="${appPath}/admin/products/variants/status" method="post">
                                                    <input type="hidden" name="variantId" value="${variant.variantId}">
                                                    <input type="hidden" name="productId" value="${managedProduct.productId}">
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

                <nav aria-label="Variant pagination" class="mt-3">
                    <ul class="pagination app-pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage le 1}">
                                    <span class="page-link">Prev</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}&page=${currentPage - 1}${listQuerySuffix}">Prev</a>
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
                                        <a class="page-link" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}&page=${pageNumber}${listQuerySuffix}">${pageNumber}</a>
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
                                    <a class="page-link" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}&page=${currentPage + 1}${listQuerySuffix}">Next</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                    </ul>
                </nav>
            </section>
        </section>
    </main>
</body>
</html>
