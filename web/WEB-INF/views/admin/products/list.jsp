<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Quản lý sản phẩm" />
<c:set var="adminSidebarDescription" scope="request" value="Quản lý dữ liệu sản phẩm, trạng thái và danh mục." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Module sản phẩm" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Sản phẩm liên kết trực tiếp với biến thể, tồn kho và giá bán." />
<c:set var="adminSidebarActive" scope="request" value="products" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore Quản trị | Sản phẩm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Đặt lại</a>
                </div>
            </div>

            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Quản trị</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Sản phẩm</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Quản lý sản phẩm</span>
                    <h1>Danh sách sản phẩm</h1>
                    <p>Quản lý thông tin sản phẩm và mở nhanh sang biến thể để cập nhật SKU, giá bán và tồn kho.</p>
                </div>
                <a class="btn btn-app-primary" href="${appPath}/admin/products/edit">Thêm sản phẩm</a>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" role="alert"><c:out value="${successMsg}" /></div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Tổng sản phẩm</div>
                    <div class="stat-value">${totalProducts}</div>
                    <p>Tất cả bản ghi sản phẩm</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Đang bán</div>
                    <div class="stat-value">${activeProducts}</div>
                    <p>Hiển thị trong luồng bán hàng</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Tạm ẩn</div>
                    <div class="stat-value">${inactiveProducts}</div>
                    <p>Không hiển thị tạm thời</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Ngừng kinh doanh</div>
                    <div class="stat-value">${discontinuedProducts}</div>
                    <p>Giữ lại cho lịch sử và đối soát</p>
                </article>
            </section>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Bảng sản phẩm</h2>
                        <p>Danh sách hỗ trợ tìm kiếm, lọc, sắp xếp, phân trang, tạo mới, cập nhật và đổi trạng thái.</p>
                    </div>
                    <span class="text-muted small">Kết quả lọc: ${filteredProducts}</span>
                </div>
                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="${appPath}/admin/products" method="get" name="adminProductFilterForm">
                        <input class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Tìm tên sản phẩm hoặc mã model">
                        <select class="form-select" name="categoryId">
                            <option value="">Tất cả danh mục</option>
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
                            <option value="">Tất cả trạng thái</option>
                            <c:forEach var="status" items="${productStatusOptions}">
                                <c:choose>
                                    <c:when test="${selectedStatus eq status}">
                                        <option value="${fn:escapeXml(status)}" selected>${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : status}</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(status)}">${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : status}</option>
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
                        <button class="btn btn-app-primary" type="submit">Lọc</button>
                    </form>
                </div>
                <div class="table-responsive">
                    <table class="table app-table">
                        <thead>
                            <tr>
                                <th scope="col">Sản phẩm</th>
                                <th scope="col">Danh mục</th>
                                <th scope="col">Giá</th>
                                <th scope="col">Tồn kho</th>
                                <th scope="col">Trạng thái</th>
                                <th scope="col" class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty products}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">Không tìm thấy sản phẩm.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="product" items="${products}">
                                        <c:choose>
                                            <c:when test="${product.status eq 'ACTIVE'}">
                                                <c:set var="productStatusClass" value="status-in-stock" />
                                                <c:set var="nextStatus" value="INACTIVE" />
                                                <c:set var="statusActionLabel" value="Tạm ẩn" />
                                                <c:set var="statusActionClass" value="btn-app-outline" />
                                            </c:when>
                                            <c:when test="${product.status eq 'INACTIVE'}">
                                                <c:set var="productStatusClass" value="status-out-stock" />
                                                <c:set var="nextStatus" value="ACTIVE" />
                                                <c:set var="statusActionLabel" value="Kích hoạt" />
                                                <c:set var="statusActionClass" value="btn-app-primary" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="productStatusClass" value="status-cancelled" />
                                                <c:set var="nextStatus" value="ACTIVE" />
                                                <c:set var="statusActionLabel" value="Bán lại" />
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
                                                            Mã sản phẩm: #${product.productId}
                                                        </c:otherwise>
                                                    </c:choose>
                                                </small>
                                                <small class="d-block text-muted">Biến thể: ${product.variantCount}</small>
                                            </td>
                                            <td><c:out value="${product.categoryName}" /></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${product.variantCount gt 0 and not empty product.minPrice}">
                                                        <fmt:formatNumber value="${product.minPrice}" pattern="#,##0.##" /> VND
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="text-muted">Chưa có biến thể</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>${product.totalStock}</td>
                                            <td><span class="status-badge ${productStatusClass}">${product.status eq 'ACTIVE' ? 'Đang bán' : product.status eq 'INACTIVE' ? 'Tạm ẩn' : product.status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : product.status}</span></td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/variants?productId=${product.productId}">Biến thể</a>
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/edit?id=${product.productId}">Sửa</a>
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
                <nav aria-label="Phân trang sản phẩm" class="mt-3">
                    <ul class="pagination app-pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage le 1}">
                                    <span class="page-link">Trước</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/products?page=${currentPage - 1}${listQuerySuffix}">Trước</a>
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
                                    <span class="page-link">Sau</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/products?page=${currentPage + 1}${listQuerySuffix}">Sau</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                    </ul>
                </nav>
            </section>

            <p class="admin-footer-note">CRUD biến thể đã sẵn sàng để quản lý SKU, giá và tồn kho theo từng sản phẩm.</p>
        </section>
    </main>
</body>
</html>
