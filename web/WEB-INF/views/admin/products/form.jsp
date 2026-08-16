<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty product and product.productId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}" />
<c:set var="adminSidebarTitle" scope="request" value="${isEdit ? 'Chỉnh sửa sản phẩm' : 'Tạo sản phẩm'}" />
<c:set var="adminSidebarDescription" scope="request" value="Kiểm tra dữ liệu và lưu sản phẩm qua Service, DAO." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Biểu mẫu sản phẩm" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Biểu mẫu này tập trung vào dữ liệu chính của sản phẩm." />
<c:set var="adminSidebarActive" scope="request" value="products" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore Quản trị | ${formModeLabel} sản phẩm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/products" method="get" name="adminProductSearchForm">
                    <label class="visually-hidden" for="admin-product-search">Tìm kiếm sản phẩm</label>
                    <input id="admin-product-search" class="form-control" type="search" name="keyword" placeholder="Tìm theo tên sản phẩm hoặc mã model">
                    <button class="btn btn-app-primary" type="submit">Tìm</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Về danh sách sản phẩm</a>
                </div>
            </div>

            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Quản trị</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/products">Sản phẩm</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${formModeLabel}</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Quản lý sản phẩm</span>
                    <h1>${formModeLabel} sản phẩm</h1>
                    <p>Thông tin sản phẩm được quản lý tại đây; giá bán và tồn kho nằm trong module biến thể.</p>
                </div>
                <c:if test="${isEdit}">
                    <a class="btn btn-app-outline" href="${appPath}/admin/products/variants?productId=${product.productId}">Quản lý biến thể</a>
                </c:if>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Thông tin cơ bản</h2>
                        <p>Các trường này tương ứng với dữ liệu chính trong bảng products.</p>
                    </div>
                </div>

                <form class="admin-form-stack" action="${appPath}/admin/products/update" method="post">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="productId" value="${product.productId}">
                    </c:if>

                    <div class="admin-form-grid">
                        <div class="field-span-full">
                            <label class="form-label" for="name">Tên sản phẩm</label>
                            <input id="name" class="form-control" type="text" name="name" maxlength="200" value="${fn:escapeXml(product.name)}" required>
                        </div>
                        <div>
                            <label class="form-label" for="categoryId">Danh mục</label>
                            <select id="categoryId" class="form-select" name="categoryId" required>
                                <option value="">Chọn danh mục</option>
                                <c:forEach var="category" items="${categories}">
                                    <c:choose>
                                        <c:when test="${product.categoryId eq category.categoryId}">
                                            <option value="${category.categoryId}" selected><c:out value="${category.name}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${category.categoryId}"><c:out value="${category.name}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="status">Trạng thái</label>
                            <select id="status" class="form-select" name="status" required>
                                <c:forEach var="status" items="${productStatusOptions}">
                                    <c:choose>
                                        <c:when test="${product.status eq status}">
                                            <option value="${fn:escapeXml(status)}" selected>${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : status}</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(status)}">${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : status}</option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="modelCode">Mã model</label>
                            <input id="modelCode" class="form-control" type="text" name="modelCode" maxlength="50" value="${fn:escapeXml(product.modelCode)}">
                        </div>
                        <div>
                            <label class="form-label" for="releaseYear">Năm ra mắt</label>
                            <input id="releaseYear" class="form-control" type="number" name="releaseYear" min="1998" max="2100" value="${product.releaseYear}">
                        </div>
                        <div>
                            <label class="form-label" for="productCondition">Tình trạng</label>
                            <select id="productCondition" class="form-select" name="productCondition" required>
                                <c:forEach var="condition" items="${productConditionOptions}">
                                    <c:choose>
                                        <c:when test="${product.productCondition eq condition}">
                                            <option value="${fn:escapeXml(condition)}" selected>${condition eq 'NEW' ? 'Mới' : condition eq 'LIKE_NEW' ? 'Như mới' : condition eq 'REFURBISHED' ? 'Tân trang' : condition}</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(condition)}">${condition eq 'NEW' ? 'Mới' : condition eq 'LIKE_NEW' ? 'Như mới' : condition eq 'REFURBISHED' ? 'Tân trang' : condition}</option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="importType">Mã thị trường</label>
                            <select id="importType" class="form-select" name="importType" required>
                                <c:forEach var="importType" items="${productImportTypeOptions}">
                                    <c:choose>
                                        <c:when test="${product.importType eq importType}">
                                            <option value="${fn:escapeXml(importType)}" selected><c:out value="${importType}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(importType)}"><c:out value="${importType}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="originCountry">Quốc gia xuất xứ</label>
                            <input id="originCountry" class="form-control" type="text" name="originCountry" maxlength="100" value="${fn:escapeXml(product.originCountry)}">
                        </div>
                        <div>
                            <label class="form-label" for="warrantyMonths">Thời hạn bảo hành</label>
                            <input id="warrantyMonths" class="form-control" type="number" name="warrantyMonths" min="0" value="${product.warrantyMonths}" required>
                        </div>
                        <div class="form-check align-self-end mt-3">
                            <c:choose>
                                <c:when test="${product.featured}">
                                    <input id="isFeatured" class="form-check-input" type="checkbox" name="isFeatured" checked>
                                </c:when>
                                <c:otherwise>
                                    <input id="isFeatured" class="form-check-input" type="checkbox" name="isFeatured">
                                </c:otherwise>
                            </c:choose>
                            <label class="form-check-label" for="isFeatured">Hiển thị nổi bật ở cửa hàng</label>
                        </div>
                        <div class="field-span-full">
                            <label class="form-label" for="description">Mô tả</label>
                            <textarea id="description" class="form-control" name="description" rows="5" maxlength="2000">${fn:escapeXml(product.description)}</textarea>
                        </div>
                    </div>

<!--                    <div class="admin-summary-card">
                        <span>Ghi chú</span>
                        <strong>Biến thể, hình ảnh và thông số được quản lý riêng</strong>
                        <small class="admin-note">Biến thể đã có module CRUD riêng để biểu mẫu sản phẩm tập trung vào dữ liệu chính.</small>
                    </div>-->

                    <div class="admin-form-actions mt-4">
                        <a class="btn btn-app-outline" href="${appPath}/admin/products">Hủy</a>
                        <c:choose>
                            <c:when test="${isEdit}">
                                <button class="btn btn-app-primary" type="submit">Lưu thay đổi</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-app-primary" type="submit">Tạo sản phẩm</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </section>
        </section>
    </main>
</body>
</html>
