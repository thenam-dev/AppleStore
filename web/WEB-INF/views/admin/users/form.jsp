<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Chỉnh sửa người dùng" />
<c:set var="adminSidebarDescription" scope="request" value="Cập nhật hồ sơ, vai trò và trạng thái tài khoản." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Biểu mẫu người dùng" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Đổi mật khẩu được xử lý riêng trong luồng xác thực." />
<c:set var="adminSidebarActive" scope="request" value="users" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore Quản trị | Chỉnh sửa người dùng</title>
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
                    <input id="admin-users-search" class="form-control" type="search" name="keyword" placeholder="Tìm theo tên, email, số điện thoại">
                    <button class="btn btn-app-primary" type="submit">Tìm</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/users">Về danh sách người dùng</a>
                </div>
            </div>

            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Quản trị</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/users">Người dùng</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Chỉnh sửa</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Quản lý người dùng</span>
                    <h1>Chỉnh sửa người dùng</h1>
                    <p>Cập nhật thông tin tài khoản và lưu thay đổi vào bảng users.</p>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <c:choose>
                <c:when test="${empty user}">
                    <section class="admin-panel">
                        <p class="mb-0">Không tìm thấy người dùng.</p>
                    </section>
                </c:when>
                <c:otherwise>
                    <section class="admin-panel">
                        <div class="admin-panel-head">
                            <div>
                                <h2>Thông tin tài khoản</h2>
                                <p>Biểu mẫu này cho phép chỉnh sửa hồ sơ, vai trò và trạng thái.</p>
                            </div>
                        </div>

                        <form class="admin-form-stack" action="${appPath}/admin/users/update" method="post">
                            <input type="hidden" name="userId" value="${user.userId}">

                            <div class="admin-form-grid">
                                <div>
                                    <label class="form-label" for="fullName">Họ và tên</label>
                                    <input id="fullName" class="form-control" type="text" name="fullName" maxlength="100" value="${fn:escapeXml(user.fullName)}" required>
                                </div>
                                <div>
                                    <label class="form-label" for="email">Email</label>
                                    <input id="email" class="form-control" type="email" name="email" maxlength="255" value="${fn:escapeXml(user.email)}" required>
                                </div>
                                <div>
                                    <label class="form-label" for="phone">Số điện thoại</label>
                                    <input id="phone" class="form-control" type="tel" name="phone" maxlength="15" pattern="[0-9]{9,15}" title="Số điện thoại phải gồm 9 đến 15 chữ số." value="${fn:escapeXml(user.phone)}">
                                </div>
                                <div>
                                    <label class="form-label" for="role">Vai trò</label>
                                    <select id="role" class="form-select" name="role" required>
                                        <c:forEach var="role" items="${roles}">
                                            <c:choose>
                                                <c:when test="${user.role eq role}">
                                                    <option value="${fn:escapeXml(role)}" selected>${role eq 'CUSTOMER' ? 'Khách hàng' : role eq 'ADMIN' ? 'Quản trị viên' : role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : role eq 'DELIVERY' ? 'Nhân viên giao hàng' : role}</option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="${fn:escapeXml(role)}">${role eq 'CUSTOMER' ? 'Khách hàng' : role eq 'ADMIN' ? 'Quản trị viên' : role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : role eq 'DELIVERY' ? 'Nhân viên giao hàng' : role}</option>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div>
                                    <label class="form-label" for="status">Trạng thái</label>
                                    <select id="status" class="form-select" name="status" required>
                                        <c:forEach var="status" items="${statuses}">
                                            <c:choose>
                                                <c:when test="${user.status eq status}">
                                                    <option value="${fn:escapeXml(status)}" selected>${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status eq 'LOCKED' ? 'Đã khóa' : status eq 'SUSPENDED' ? 'Tạm ngưng' : status}</option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="${fn:escapeXml(status)}">${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status eq 'LOCKED' ? 'Đã khóa' : status eq 'SUSPENDED' ? 'Tạm ngưng' : status}</option>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="form-check align-self-end">
                                    <c:choose>
                                        <c:when test="${user.emailVerified}">
                                            <input id="emailVerified" class="form-check-input" type="checkbox" name="emailVerified" checked>
                                        </c:when>
                                        <c:otherwise>
                                            <input id="emailVerified" class="form-check-input" type="checkbox" name="emailVerified">
                                        </c:otherwise>
                                    </c:choose>
                                    <label class="form-check-label" for="emailVerified">Email đã xác minh</label>
                                </div>
                            </div>

                            <div class="admin-form-actions">
                                <a class="btn btn-app-outline" href="${appPath}/admin/users">Hủy</a>
                                <button class="btn btn-app-primary" type="submit">Lưu thay đổi</button>
                            </div>
                        </form>
                    </section>
                </c:otherwise>
            </c:choose>

            <p class="admin-footer-note">Mật khẩu và phiên đăng nhập được xử lý riêng trong module xác thực.</p>
        </section>
    </main>
</body>
</html>
