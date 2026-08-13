<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty category and category.categoryId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}" />
<c:choose>
    <c:when test="${isEdit}">
        <c:set var="adminSidebarTitle" scope="request" value="Chỉnh sửa danh mục" />
    </c:when>
    <c:otherwise>
        <c:set var="adminSidebarTitle" scope="request" value="Tạo danh mục" />
    </c:otherwise>
</c:choose>
<c:set var="adminSidebarDescription" scope="request" value="Kiểm tra dữ liệu và lưu danh mục qua Service, DAO." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Biểu mẫu danh mục" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Giữ dữ liệu danh mục gọn, dễ quản lý và dễ gán cho sản phẩm." />
<c:set var="adminSidebarActive" scope="request" value="categories" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore Quản trị | ${formModeLabel} danh mục</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/categories" method="get" name="adminCategoriesSearchForm">
                    <label class="visually-hidden" for="admin-categories-search">Tìm kiếm danh mục</label>
                    <input id="admin-categories-search" class="form-control" type="search" name="keyword" placeholder="Tìm theo tên danh mục hoặc slug">
                    <button class="btn btn-app-primary" type="submit">Tìm</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/categories">Về danh sách danh mục</a>
                </div>
            </div>

            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Quản trị</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/categories">Danh mục</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${formModeLabel}</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Quản lý danh mục</span>
                    <h1>${formModeLabel} danh mục</h1>
                    <p>Dữ liệu được kiểm tra và lưu vào bảng categories.</p>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Thông tin danh mục</h2>
                        <p>Giữ cấu trúc danh mục đơn giản để dễ gán sản phẩm và lọc ở cửa hàng.</p>
                    </div>
                </div>

                <form class="admin-form-stack" action="${appPath}/admin/categories/update" method="post">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="categoryId" value="${category.categoryId}">
                    </c:if>

                    <div class="admin-form-grid">
                        <div>
                            <label class="form-label" for="name">Tên danh mục</label>
                            <input id="name" class="form-control" type="text" name="name" maxlength="100" value="${fn:escapeXml(category.name)}" required>
                        </div>
                        <div>
                            <label class="form-label" for="slug">Slug</label>
                            <input id="slug" class="form-control" type="text" name="slug" maxlength="100" pattern="[a-z0-9]+(?:-[a-z0-9]+)*" title="Chỉ dùng chữ thường, số và dấu gạch ngang." value="${fn:escapeXml(category.slug)}" placeholder="iphone" required>
                        </div>
                        <div>
                            <label class="form-label" for="displayOrder">Thứ tự hiển thị</label>
                            <input id="displayOrder" class="form-control" type="number" name="displayOrder" min="0" value="${category.displayOrder}" required>
                        </div>
                        <div>
                            <label class="form-label" for="status">Trạng thái</label>
                            <select id="status" class="form-select" name="status" required>
                                <c:forEach var="status" items="${categoryStatusOptions}">
                                    <c:choose>
                                        <c:when test="${(category.isActive and status eq 'ACTIVE') or (not category.isActive and status eq 'INACTIVE')}">
                                            <option value="${fn:escapeXml(status)}" selected>${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status}</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(status)}">${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status}</option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="admin-form-actions mt-4">
                        <a class="btn btn-app-outline" href="${appPath}/admin/categories">Hủy</a>
                        <c:choose>
                            <c:when test="${isEdit}">
                                <button class="btn btn-app-primary" type="submit">Lưu thay đổi</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-app-primary" type="submit">Tạo danh mục</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </section>
        </section>
    </main>
</body>
</html>
