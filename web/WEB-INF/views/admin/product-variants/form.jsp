<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty variant and variant.variantId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}" />
<c:set var="adminSidebarTitle" scope="request" value="${isEdit ? 'Chỉnh sửa biến thể' : 'Tạo biến thể'}" />
<c:set var="adminSidebarDescription" scope="request" value="Quản lý giá, tồn kho và dữ liệu SKU có thể bán." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Biểu mẫu biến thể" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Dữ liệu biến thể dùng cho giỏ hàng và thanh toán." />
<c:set var="adminSidebarActive" scope="request" value="products" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore Quản trị | ${formModeLabel} biến thể</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/products/variants" method="get" name="adminVariantSearchForm">
                    <label class="visually-hidden" for="admin-variant-search">Tìm kiếm biến thể</label>
                    <input type="hidden" name="productId" value="${managedProduct.productId}">
                    <input id="admin-variant-search" class="form-control" type="search" name="keyword" placeholder="Tìm trong danh sách biến thể">
                    <button class="btn btn-app-primary" type="submit">Tìm</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}">Về danh sách biến thể</a>
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Về danh sách sản phẩm</a>
                </div>
            </div>

            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Quản trị</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/products">Sản phẩm</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/products/variants?productId=${managedProduct.productId}">Biến thể</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${formModeLabel}</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Quản lý biến thể</span>
                    <h1>${formModeLabel} biến thể</h1>
                    <p>Sản phẩm: <strong><c:out value="${managedProduct.name}" /></strong> (${managedProduct.status eq 'ACTIVE' ? 'Đang bán' : managedProduct.status eq 'INACTIVE' ? 'Tạm ẩn' : managedProduct.status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : managedProduct.status})</p>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Thông tin biến thể</h2>
                        <p>Các trường này tương ứng với bảng product_variants và dữ liệu SKU có thể bán.</p>
                    </div>
                </div>

                <form class="admin-form-stack" action="${appPath}/admin/products/variants/update" method="post">
                    <input type="hidden" name="productId" value="${managedProduct.productId}">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="variantId" value="${variant.variantId}">
                    </c:if>

                    <div class="admin-form-grid">
                        <div>
                            <label class="form-label" for="sku">SKU</label>
                            <input id="sku" class="form-control" type="text" name="sku" maxlength="50" value="${fn:escapeXml(variant.sku)}" required>
                        </div>
                        <div>
                            <label class="form-label" for="status">Trạng thái</label>
                            <select id="status" class="form-select" name="status" required>
                                <c:forEach var="status" items="${variantStatusOptions}">
                                    <c:choose>
                                        <c:when test="${(variant.active and status eq 'ACTIVE') or (not variant.active and status eq 'INACTIVE')}">
                                            <option value="${fn:escapeXml(status)}" selected>${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status}</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(status)}">${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status}</option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="field-span-full">
                            <label class="form-label" for="variantLabel">Nhãn biến thể</label>
                            <input id="variantLabel" class="form-control" type="text" name="variantLabel" maxlength="150" value="${fn:escapeXml(variant.variantLabel)}" required>
                        </div>
                        <div>
                            <label class="form-label" for="colorName">Tên màu</label>
                            <input id="colorName" class="form-control" type="text" name="colorName" maxlength="50" value="${fn:escapeXml(variant.colorName)}">
                        </div>
                        <div>
                            <label class="form-label" for="colorHex">Mã màu hex</label>
                            <input id="colorHex" class="form-control" type="text" name="colorHex" maxlength="7" placeholder="#1D1D1F" value="${fn:escapeXml(variant.colorHex)}">
                        </div>
                        <div>
                            <label class="form-label" for="storageCapacityGb">Dung lượng (GB)</label>
                            <input id="storageCapacityGb" class="form-control" type="number" name="storageCapacityGb" min="0" value="${variant.storageCapacityGb}">
                        </div>
                        <div>
                            <label class="form-label" for="ramGb">RAM (GB)</label>
                            <input id="ramGb" class="form-control" type="number" name="ramGb" min="0" value="${variant.ramGb}">
                        </div>
                        <div>
                            <label class="form-label" for="connectivity">Kết nối</label>
                            <select id="connectivity" class="form-select" name="connectivity">
                                <option value="">Chọn kết nối</option>
                                <c:forEach var="connectivity" items="${variantConnectivityOptions}">
                                    <c:choose>
                                        <c:when test="${variant.connectivity eq connectivity}">
                                            <option value="${fn:escapeXml(connectivity)}" selected>${connectivity eq 'WIFI_CELLULAR' ? 'WiFi + di động' : connectivity eq 'WIFI' ? 'WiFi' : connectivity}</option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(connectivity)}">${connectivity eq 'WIFI_CELLULAR' ? 'WiFi + di động' : connectivity eq 'WIFI' ? 'WiFi' : connectivity}</option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="chipOption">Tùy chọn chip</label>
                            <input id="chipOption" class="form-control" type="text" name="chipOption" maxlength="50" value="${fn:escapeXml(variant.chipOption)}">
                        </div>
                        <div>
                            <label class="form-label" for="screenSizeInch">Kích thước màn hình (inch)</label>
                            <input id="screenSizeInch" class="form-control" type="number" step="0.1" min="0.1" name="screenSizeInch" value="${variant.screenSizeInch}">
                        </div>
                        <div>
                            <label class="form-label" for="price">Giá bán</label>
                            <input id="price" class="form-control" type="number" step="0.01" min="0" name="price" value="${variant.price}" required>
                        </div>
                        <div>
                            <label class="form-label" for="stockQuantity">Số lượng tồn kho</label>
                            <input id="stockQuantity" class="form-control" type="number" min="0" name="stockQuantity" value="${variant.stockQuantity}" required>
                        </div>
                        <div>
                            <label class="form-label" for="weightKg">Khối lượng (kg)</label>
                            <input id="weightKg" class="form-control" type="number" step="0.001" min="0.001" name="weightKg" value="${variant.weightKg}" required>
                        </div>
                        <div>
                            <label class="form-label" for="discountPrice">Giá khuyến mãi</label>
                            <input id="discountPrice" class="form-control" type="number" step="0.01" min="0" name="discountPrice" value="${variant.discountPrice}">
                        </div>
                        <div>
                            <label class="form-label" for="discountStart">Bắt đầu khuyến mãi</label>
                            <input id="discountStart" class="form-control" type="datetime-local" name="discountStart" value="${discountStartValue}">
                        </div>
                        <div>
                            <label class="form-label" for="discountEnd">Kết thúc khuyến mãi</label>
                            <input id="discountEnd" class="form-control" type="datetime-local" name="discountEnd" value="${discountEndValue}">
                        </div>
                    </div>

                    <div class="admin-summary-card">
                        <span>Điều kiện hợp lệ</span>
                        <strong>Biến thể hợp lệ có thể dùng cho giỏ hàng và thanh toán</strong>
                        <small class="admin-note">Biến thể nên đang bán, có SKU duy nhất, khối lượng lớn hơn 0, giá không âm và tồn kho lớn hơn 0 cho các test case mua hàng.</small>
                    </div>

                    <div class="admin-form-actions mt-4">
                        <a class="btn btn-app-outline" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}">Hủy</a>
                        <c:choose>
                            <c:when test="${isEdit}">
                                <button class="btn btn-app-primary" type="submit">Lưu thay đổi</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-app-primary" type="submit">Tạo biến thể</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </section>
        </section>
    </main>
</body>
</html>
