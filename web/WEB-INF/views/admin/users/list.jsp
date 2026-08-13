<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Quản lý người dùng" />
<c:set var="adminSidebarDescription" scope="request" value="Quản lý tài khoản, vai trò và trạng thái người dùng." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Module người dùng" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Dữ liệu được xử lý qua Servlet, Service và DAO." />
<c:set var="adminSidebarActive" scope="request" value="users" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore Quản trị | Người dùng</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/users" method="get" name="adminUsersSearchForm">
                    <label class="visually-hidden" for="admin-users-search">Tìm kiếm người dùng</label>
                    <input id="admin-users-search" class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Tìm theo tên, email, số điện thoại">
                    <input type="hidden" name="role" value="${fn:escapeXml(selectedRole)}">
                    <input type="hidden" name="status" value="${fn:escapeXml(selectedStatus)}">
                    <input type="hidden" name="sort" value="${fn:escapeXml(selectedSort)}">
                    <button class="btn btn-app-primary" type="submit">Tìm</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/users">Đặt lại</a>
                    <div class="admin-user-pill">
                        <div class="account-avatar admin-user-pill-avatar">AD</div>
                        <div>
                            <strong>Quản trị</strong>
                            <small>Vận hành người dùng</small>
                        </div>
                    </div>
                </div>
            </div>

            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Quản trị</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Người dùng</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Quản lý người dùng</span>
                    <h1>Danh sách người dùng</h1>
                    <p>Theo dõi tài khoản, thông tin liên hệ, vai trò và trạng thái hoạt động.</p>
                </div>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" role="alert"><c:out value="${successMsg}" /></div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Người dùng</h2>
                        <p>Danh sách được lọc, sắp xếp và phân trang từ bảng users.</p>
                    </div>
                    <span class="text-muted small">Tổng người dùng phù hợp: ${totalUsers}</span>
                </div>
                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="${appPath}/admin/users" method="get" name="adminUserFilterForm">
                        <input class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Tìm theo tên, email, số điện thoại">
                        <select class="form-select" name="role">
                            <option value="">Tất cả vai trò</option>
                            <c:forEach var="role" items="${roles}">
                                <c:choose>
                                    <c:when test="${selectedRole eq role}">
                                        <option value="${fn:escapeXml(role)}" selected>${role eq 'CUSTOMER' ? 'Khách hàng' : role eq 'ADMIN' ? 'Quản trị viên' : role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : role eq 'DELIVERY' ? 'Nhân viên giao hàng' : role}</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(role)}">${role eq 'CUSTOMER' ? 'Khách hàng' : role eq 'ADMIN' ? 'Quản trị viên' : role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : role eq 'DELIVERY' ? 'Nhân viên giao hàng' : role}</option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </select>
                        <select class="form-select" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <c:forEach var="status" items="${statuses}">
                                <c:choose>
                                    <c:when test="${selectedStatus eq status}">
                                        <option value="${fn:escapeXml(status)}" selected>${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status eq 'LOCKED' ? 'Đã khóa' : status eq 'SUSPENDED' ? 'Tạm ngưng' : status}</option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(status)}">${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status eq 'LOCKED' ? 'Đã khóa' : status eq 'SUSPENDED' ? 'Tạm ngưng' : status}</option>
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
                                <th scope="col">Người dùng</th>
                                <th scope="col">Liên hệ</th>
                                <th scope="col">Vai trò</th>
                                <th scope="col">Trạng thái</th>
                                <th scope="col">Xác minh</th>
                                <th scope="col">Ngày tạo</th>
                                <th scope="col" class="text-end">Thao tác</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty users}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">Không tìm thấy người dùng.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="user" items="${users}">
                                        <c:choose>
                                            <c:when test="${user.status eq 'ACTIVE'}">
                                                <c:set var="userStatusClass" value="status-in-stock" />
                                            </c:when>
                                            <c:when test="${user.status eq 'INACTIVE'}">
                                                <c:set var="userStatusClass" value="status-out-stock" />
                                            </c:when>
                                            <c:when test="${user.status eq 'LOCKED' or user.status eq 'SUSPENDED'}">
                                                <c:set var="userStatusClass" value="status-cancelled" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="userStatusClass" value="status-pending" />
                                            </c:otherwise>
                                        </c:choose>
                                        <tr>
                                            <td>
                                                <div class="admin-user-pill">
                                                    <div class="account-avatar admin-user-pill-avatar"><c:out value="${userInitialsMap[user.userId]}" /></div>
                                                    <div>
                                                        <strong><c:out value="${user.fullName}" /></strong>
                                                        <small>#${user.userId}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <strong><c:out value="${user.email}" /></strong>
                                                <small class="d-block text-muted"><c:out value="${user.phone}" /></small>
                                            </td>
                                            <td><span class="status-badge status-processing">${user.role eq 'CUSTOMER' ? 'Khách hàng' : user.role eq 'ADMIN' ? 'Quản trị viên' : user.role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : user.role eq 'DELIVERY' ? 'Nhân viên giao hàng' : user.role}</span></td>
                                            <td><span class="status-badge ${userStatusClass}">${user.status eq 'ACTIVE' ? 'Đang hoạt động' : user.status eq 'INACTIVE' ? 'Không hoạt động' : user.status eq 'LOCKED' ? 'Đã khóa' : user.status eq 'SUSPENDED' ? 'Tạm ngưng' : user.status}</span></td>
                                            <td>${user.emailVerified ? 'Có' : 'Không'}</td>
                                            <td><c:out value="${userCreatedAtMap[user.userId]}" /></td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/users/edit?id=${user.userId}">Sửa</a>
                                                <form class="d-inline" action="${appPath}/admin/users/status" method="post">
                                                    <input type="hidden" name="userId" value="${user.userId}">
                                                    <c:choose>
                                                        <c:when test="${user.status eq 'ACTIVE'}">
                                                            <input type="hidden" name="status" value="LOCKED">
                                                            <button class="btn btn-app-outline btn-sm" type="submit">Khóa</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <input type="hidden" name="status" value="ACTIVE">
                                                            <button class="btn btn-app-primary btn-sm" type="submit">Kích hoạt</button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <nav aria-label="Phân trang người dùng" class="mt-3">
                    <ul class="pagination app-pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage le 1}">
                                    <span class="page-link">Trước</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/users?page=${currentPage - 1}${listQuerySuffix}">Trước</a>
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
                                        <a class="page-link" href="${appPath}/admin/users?page=${pageNumber}${listQuerySuffix}">${pageNumber}</a>
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
                                    <a class="page-link" href="${appPath}/admin/users?page=${currentPage + 1}${listQuerySuffix}">Sau</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                    </ul>
                </nav>
            </section>

            <p class="admin-footer-note">Luồng chính: xem danh sách, chỉnh sửa thông tin và cập nhật trạng thái người dùng.</p>
        </section>
    </main>
</body>
</html>
