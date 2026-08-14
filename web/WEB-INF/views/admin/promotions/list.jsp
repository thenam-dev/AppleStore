<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AppleStore Quản trị | Mã giảm giá</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
        <style>
            .sortable-link {
                color: inherit;
                text-decoration: none;
            }
            .sortable-link:hover {
                color: #0d6efd;
            }
        </style>
    </head>
    <body class="site-body admin-app">
        <main class="admin-workspace">

            <c:set var="adminSidebarTitle" value="Quản lý mã giảm giá" scope="request" />
            <c:set var="adminSidebarDescription" value="Quản lý các chiến dịch khuyến mãi và mã giảm giá." scope="request" />
            <c:set var="adminSidebarFooterTitle" value="Module khuyến mãi" scope="request" />
            <c:set var="adminSidebarFooterDescription" value="Danh sách được bảo vệ trong khu vực quản trị." scope="request" />

            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

            <section class="admin-main">
                <!-- TOPBAR -->
                <div class="admin-topbar">
                    <div class="admin-topbar-actions ms-auto">
                        <a class="btn btn-app-primary btn-sm" href="${pageContext.request.contextPath}/admin/promotions/edit">
                            + Tạo mã giảm giá
                        </a>
                    </div>
                </div>

                <!-- BREADCRUMB & HEADER -->
                <nav aria-label="Đường dẫn">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Quản trị</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Mã giảm giá</li>
                    </ol>
                </nav>

                <div class="admin-page-head">
                    <div>
                        <span class="eyebrow">Dữ liệu khuyến mãi</span>
                        <h1>Chiến dịch mã giảm giá</h1>
                        <p>Theo dõi và quản lý các mã giảm giá trong hệ thống.</p>
                    </div>
                </div>

                <!-- THÔNG BÁO LỖI NẾU CÓ -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger" role="alert"><c:out value="${errorMessage}" /></div>
                </c:if>

                <!-- KPI GRID -->
                <div class="admin-summary-grid mb-4">
                    <article class="admin-summary-card">
                        <span>Mã đang kích hoạt</span>
                        <strong>${activeCount}</strong>
                    </article>
                    <article class="admin-summary-card">
                        <span>Sắp hết hạn</span>
                        <strong>${expiringSoon}</strong>
                    </article>
                    <article class="admin-summary-card">
                        <span>Tổng lượt sử dụng</span>
                        <strong>${totalRedeemed}</strong>
                    </article>
                </div>

                <!-- FORM TÌM KIẾM & LỌC -->
                <form action="${pageContext.request.contextPath}/admin/promotions" method="get" class="mb-4">
                    <div class="row g-2">
                        <div class="col-md-4">
                            <input type="text" name="keyword" class="form-control" placeholder="Tìm theo mã giảm giá..." value="<c:out value='${keyword}'/>" maxlength="50">
                        </div>
                        <div class="col-md-3">
                            <select name="status" class="form-select">
                                <option value="">-- Tất cả trạng thái --</option>
                                <option value="1" ${statusFilter == '1' ? 'selected' : ''}>Đang kích hoạt</option>
                                <option value="0" ${statusFilter == '0' ? 'selected' : ''}>Đã vô hiệu hóa</option>
                            </select>
                        </div>
                        <!-- Giữ lại sắp xếp khi tìm kiếm -->
                        <input type="hidden" name="sortCol" value="${sortCol}">
                        <input type="hidden" name="sortDir" value="${sortDir}">

                        <div class="col-md-2">
                            <button type="submit" class="btn btn-secondary w-100">Lọc dữ liệu</button>
                        </div>
                    </div>
                </form>

                <!-- BẢNG DỮ LIỆU -->
                <section class="admin-panel">
                    <div class="table-responsive">
                        <table class="table admin-table align-middle">
                            <thead>
                                <tr>
                                    <!-- Sort theo mã -->
                                    <th>
                                        <a href="?keyword=${keyword}&status=${statusFilter}&sortCol=code&sortDir=${sortCol == 'code' && sortDir == 'ASC' ? 'DESC' : 'ASC'}" class="sortable-link">
                                            Mã ${sortCol == 'code' ? (sortDir == 'ASC' ? '▲' : '▼') : ''}
                                        </a>
                                    </th>
                                    <th>Giảm giá</th>
                                    <th>Phạm vi</th>
                                    <!-- Sort theo Ngày hết hạn -->
                                    <th>
                                        <a href="?keyword=${keyword}&status=${statusFilter}&sortCol=valid_until&sortDir=${sortCol == 'valid_until' && sortDir == 'ASC' ? 'DESC' : 'ASC'}" class="sortable-link">
                                            Hết hạn ${sortCol == 'valid_until' ? (sortDir == 'ASC' ? '▲' : '▼') : ''}
                                        </a>
                                    </th>
                                    <th>Trạng thái</th>
                                    <th class="text-end">Thao tác</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:choose>
                                    <c:when test="${empty promotions}">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted py-4">Không tìm thấy mã khuyến mãi nào.</td>
                                        </tr>
                                    </c:when>
                                    <c:otherwise>
                                        <c:forEach items="${promotions}" var="promo">
                                            <tr>
                                                <td>
                                                    <strong><c:out value="${promo.code}" /></strong>
                                                    <small class="d-block text-muted">ID: ${promo.promoId}</small>
                                                </td>
                                                <td>
                                                    <c:choose>
                                                        <c:when test="${promo.discountType == 'PERCENT'}">
                                                            <span class="text-success">${promo.discountValue}%</span>
                                                            <c:if test="${not empty promo.discountMax && promo.discountMax > 0}">
                                                                <small class="d-block text-muted">Tối đa: ${promo.discountMax}</small>
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <span class="text-primary">${promo.discountValue} VND</span>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </td>
                                                <td>
                                                    <span class="badge bg-secondary">
                                                        <c:choose>
                                                            <c:when test="${promo.scope eq 'ORDER'}">Tổng đơn hàng</c:when>
                                                            <c:when test="${promo.scope eq 'CATEGORY'}">Danh mục</c:when>
                                                            <c:when test="${promo.scope eq 'PRODUCT'}">Sản phẩm</c:when>
                                                            <c:otherwise><c:out value="${promo.scope}" /></c:otherwise>
                                                        </c:choose>
                                                    </span>
                                                </td>
                                                <td>
                                                    <c:if test="${not empty promo.validUntil}">
                                                        <small class="d-block text-muted">
                                                            ${promo.validUntil.format(dateFormatter)}
                                                        </small>
                                                    </c:if>
                                                </td>
                                                <td>
                                                    <span class="status-badge ${promo.IsActive() ? 'status-in-stock' : 'status-out-stock'}">
                                                        ${promo.IsActive() ? 'Đang kích hoạt' : 'Đã vô hiệu hóa'}
                                                    </span>
                                                </td>
                                                <td class="text-end table-actions">
                                                    <!-- NÚT NGỪNG / BẬT LẠI GIỮA CHỪNG -->
                                                    <form action="${pageContext.request.contextPath}/admin/promotions/status" method="post" class="d-inline" style="margin-right: 4px;">
                                                        <input type="hidden" name="promoId" value="${promo.promoId}">
                                                        <!-- Giá trị gửi lên sẽ đảo ngược với trạng thái hiện tại -->
                                                        <input type="hidden" name="isActive" value="${!promo.IsActive()}">

                                                        <button type="submit" 
                                                                class="btn btn-sm ${promo.IsActive() ? 'btn-outline-danger' : 'btn-outline-success'}" 
                                                                onclick="return confirm('Bạn có chắc chắn muốn ${promo.IsActive() ? 'NGỪNG' : 'BẬT LẠI'} mã khuyến mãi này không?');">
                                                            ${promo.IsActive() ? 'Ngừng ngay' : 'Bật lại'}
                                                        </button>
                                                    </form>

                                                    <!-- NÚT CHỈNH SỬA -->
                                                    <a href="${pageContext.request.contextPath}/admin/promotions/edit?id=${promo.promoId}" class="btn btn-sm btn-outline-secondary">Sửa</a>
                                                </td>
                                            </tr>
                                        </c:forEach>
                                    </c:otherwise>
                                </c:choose>
                            </tbody>
                        </table>
                    </div>

                    <!-- PHÂN TRANG (PAGINATION) -->
                    <c:if test="${totalPages > 1}">
                        <div class="mt-4 d-flex justify-content-end">
                            <ul class="pagination">
                                <li class="page-item ${currentPage == 1 ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${currentPage - 1}&keyword=${keyword}&status=${statusFilter}&sortCol=${sortCol}&sortDir=${sortDir}">Trước</a>
                                </li>

                                <c:forEach begin="1" end="${totalPages}" var="i">
                                    <li class="page-item ${currentPage == i ? 'active' : ''}">
                                        <a class="page-link" href="?page=${i}&keyword=${keyword}&status=${statusFilter}&sortCol=${sortCol}&sortDir=${sortDir}">${i}</a>
                                    </li>
                                </c:forEach>

                                <li class="page-item ${currentPage == totalPages ? 'disabled' : ''}">
                                    <a class="page-link" href="?page=${currentPage + 1}&keyword=${keyword}&status=${statusFilter}&sortCol=${sortCol}&sortDir=${sortDir}">Sau</a>
                                </li>
                            </ul>
                        </div>
                    </c:if>
                </section>

                <jsp:include page="/WEB-INF/views/admin/promotions/setup-notes.jsp" />

            </section>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    </body>
</html>
