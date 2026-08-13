<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Quản lý danh mục" />
<c:set var="adminSidebarDescription" scope="request" value="Quản lý cấu trúc danh mục, hiển thị và thứ tự sắp xếp." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Module danh mục" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Danh sách, tạo mới, chỉnh sửa và bật/tắt trạng thái." />
<c:set var="adminSidebarActive" scope="request" value="categories" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore Quản trị | Danh mục</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/categories">Đặt lại</a>
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Danh sách sản phẩm</a>
                </div>
            </div>

            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Quản trị</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Danh mục</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Quản lý danh mục</span>
                    <h1>Danh mục sản phẩm</h1>
                    <p>Quản lý danh mục dùng để phân loại sản phẩm và hỗ trợ bộ lọc ngoài cửa hàng.</p>
                </div>
                <a class="btn btn-app-primary" href="${appPath}/admin/categories/edit">Tạo danh mục</a>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" role="alert"><c:out value="${successMsg}" /></div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Danh mục</div>
                    <div class="stat-value">${totalCategories}</div>
                    <p>Tổng số danh mục trong hệ thống</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Đang hoạt động</div>
                    <div class="stat-value">${activeCategories}</div>
                    <p>Có thể gán cho sản phẩm</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Không hoạt động</div>
                    <div class="stat-value">${inactiveCategories}</div>
                    <p>Đang ẩn hoặc tạm ngưng</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Kết quả lọc</div>
                    <div class="stat-value">${filteredCategories}</div>
                    <p>Số danh mục khớp điều kiện hiện tại</p>
                </article>
            </section>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Bảng danh mục</h2>
                        <p>Dữ liệu được lọc, sắp xếp và phân trang từ bảng categories.</p>
                    </div>
                    <span class="text-muted small">Kết quả lọc: ${filteredCategories}</span>
                </div>
                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="${appPath}/admin/categories" method="get" name="adminCategoryFilterForm">
                        <input class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Tìm theo tên danh mục hoặc slug">
                        <select class="form-select" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <c:forEach var="status" items="${categoryStatusOptions}">
                                <c:choose>
                                    <c:when test="${selectedStatus eq status}">
                                        <option value="${fn:escapeXml(status)}" selected>${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status}</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(status)}">${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status}</option>
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
                                <th scope="col">ID</th>
                                <th scope="col">Tên danh mục</th>
                                <th scope="col">Slug</th>
                                <th scope="col">Thứ tự hiển thị</th>
                                <th scope="col">Trạng thái</th>
                                <th scope="col" class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty categories}">
                                    <tr>
                                        <td colspan="6" class="text-center text-muted py-4">Không tìm thấy danh mục.</td>
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
                                                    ${category.isActive ? 'Đang hoạt động' : 'Không hoạt động'}
                                                </span>
                                            </td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/categories/edit?id=${category.categoryId}">Sửa</a>
                                                <form class="d-inline" action="${appPath}/admin/categories/status" method="post">
                                                    <input type="hidden" name="categoryId" value="${category.categoryId}">
                                                    <input type="hidden" name="status" value="${category.isActive ? 'INACTIVE' : 'ACTIVE'}">
                                                    <button class="btn ${category.isActive ? 'btn-app-outline' : 'btn-app-primary'} btn-sm" type="submit">
                                                        ${category.isActive ? 'Tắt' : 'Kích hoạt'}
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
                <nav aria-label="Phân trang danh mục" class="mt-3">
                    <ul class="pagination app-pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage le 1}">
                                    <span class="page-link">Trước</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/categories?page=${currentPage - 1}${listQuerySuffix}">Trước</a>
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
                                    <span class="page-link">Sau</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/categories?page=${currentPage + 1}${listQuerySuffix}">Sau</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                    </ul>
                </nav>
            </section>

            <p class="admin-footer-note">Các thao tác tạo, sửa, kích hoạt và tắt danh mục đều đi qua Servlet thật.</p>
        </section>
    </main>
</body>
</html>
