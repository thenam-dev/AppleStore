<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Quản lý biến thể" />
<c:set var="adminSidebarDescription" scope="request" value="Quản lý SKU, giá bán, tồn kho và trạng thái của từng sản phẩm." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Biến thể sản phẩm" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Biến thể cung cấp dữ liệu tồn kho và giá cho giỏ hàng, thanh toán." />
<c:set var="adminSidebarActive" scope="request" value="products" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore Quản trị | Biến thể</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/edit?id=${managedProduct.productId}">Sửa sản phẩm</a>
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Về danh sách sản phẩm</a>
                </div>
            </div>

            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Quản trị</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/products">Sản phẩm</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Biến thể</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Quản lý biến thể</span>
                    <h1><c:out value="${managedProduct.name}" /></h1>
                    <p>Trạng thái sản phẩm: <strong>${managedProduct.status eq 'ACTIVE' ? 'Đang bán' : managedProduct.status eq 'INACTIVE' ? 'Tạm ẩn' : managedProduct.status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : managedProduct.status}</strong>. Biến thể cung cấp SKU, tồn kho và giá cho giỏ hàng, thanh toán.</p>
                </div>
                <a class="btn btn-app-primary" href="${appPath}/admin/products/variants/edit?productId=${managedProduct.productId}">Thêm biến thể</a>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" role="alert"><c:out value="${successMsg}" /></div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Tổng biến thể</div>
                    <div class="stat-value">${totalVariants}</div>
                    <p>Tất cả SKU thuộc sản phẩm này</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Đang bán</div>
                    <div class="stat-value">${activeVariants}</div>
                    <p>Biến thể có thể bán</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Tạm ẩn</div>
                    <div class="stat-value">${inactiveVariants}</div>
                    <p>Không hiển thị trong luồng bán</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Kết quả lọc</div>
                    <div class="stat-value">${filteredVariants}</div>
                    <p>Số biến thể khớp điều kiện hiện tại</p>
                </article>
            </section>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Bảng biến thể</h2>
                        <p>Tìm kiếm, lọc, sắp xếp, phân trang, tạo mới, cập nhật và đổi trạng thái theo sản phẩm hiện tại.</p>
                    </div>
                    <span class="text-muted small">Mã sản phẩm: #${managedProduct.productId}</span>
                </div>

                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="${appPath}/admin/products/variants" method="get" name="adminVariantFilterForm">
                        <input type="hidden" name="productId" value="${managedProduct.productId}">
                        <input class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Tìm SKU, nhãn, màu, chip">
                        <select class="form-select" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <c:forEach var="status" items="${variantStatusOptions}">
                                <c:choose>
                                    <c:when test="${selectedStatus eq status}">
                                        <option value="${fn:escapeXml(status)}" selected>${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status}</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(status)}">${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status}</option>
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
                                <th scope="col">SKU / Nhãn</th>
                                <th scope="col">Thông số</th>
                                <th scope="col">Giá</th>
                                <th scope="col">Tồn kho</th>
                                <th scope="col">Trạng thái</th>
                                <th scope="col" class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty variants}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">Không tìm thấy biến thể cho sản phẩm này.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="variant" items="${variants}">
                                        <c:choose>
                                            <c:when test="${variant.active}">
                                                <c:set var="variantStatusClass" value="status-in-stock" />
                                                <c:set var="nextStatus" value="INACTIVE" />
                                                <c:set var="statusActionLabel" value="Tạm ẩn" />
                                                <c:set var="statusActionClass" value="btn-app-outline" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="variantStatusClass" value="status-out-stock" />
                                                <c:set var="nextStatus" value="ACTIVE" />
                                                <c:set var="statusActionLabel" value="Kích hoạt" />
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
                                                    <small class="d-block text-muted">Màu: <c:out value="${variant.colorName}" /></small>
                                                </c:if>
                                                <c:if test="${variant.storageCapacityGb ne null}">
                                                    <small class="d-block text-muted">Dung lượng: ${variant.storageCapacityGb} GB</small>
                                                </c:if>
                                                <c:if test="${variant.ramGb ne null}">
                                                    <small class="d-block text-muted">RAM: ${variant.ramGb} GB</small>
                                                </c:if>
                                                <c:if test="${not empty variant.connectivity}">
                                                    <small class="d-block text-muted">Kết nối: ${variant.connectivity eq 'WIFI_CELLULAR' ? 'WiFi + di động' : variant.connectivity eq 'WIFI' ? 'WiFi' : variant.connectivity}</small>
                                                </c:if>
                                            </td>
                                            <td>
                                                <strong><fmt:formatNumber value="${variant.price}" pattern="#,##0.##" /> VND</strong>
                                                <c:if test="${not empty variant.discountPrice}">
                                                    <small class="d-block text-muted">Giá giảm: <fmt:formatNumber value="${variant.discountPrice}" pattern="#,##0.##" /> VND</small>
                                                </c:if>
                                            </td>
                                            <td>${variant.stockQuantity}</td>
                                            <td>
                                                <span class="status-badge ${variantStatusClass}">
                                                    ${variant.active ? 'Đang bán' : 'Tạm ẩn'}
                                                </span>
                                            </td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/variants/edit?id=${variant.variantId}">Sửa</a>
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

                <nav aria-label="Phân trang biến thể" class="mt-3">
                    <ul class="pagination app-pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage le 1}">
                                    <span class="page-link">Trước</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}&page=${currentPage - 1}${listQuerySuffix}">Trước</a>
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
                                    <span class="page-link">Sau</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}&page=${currentPage + 1}${listQuerySuffix}">Sau</a>
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
