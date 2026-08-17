<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AppleStore Quản trị | ${isEdit ? 'Chỉnh sửa' : 'Tạo'} mã giảm giá</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    </head>
    <body class="site-body admin-app">
        <main class="admin-workspace">
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />
            <section class="admin-main">
                <div class="admin-topbar">
                    <div class="admin-topbar-actions ms-auto">
                        <a class="btn btn-app-outline btn-sm" href="${pageContext.request.contextPath}/admin/promotions">Về danh sách</a>
                    </div>
                </div>
                <nav aria-label="Đường dẫn">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/dashboard">Quản trị</a></li>
                        <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/admin/promotions">Mã giảm giá</a></li>
                        <li class="breadcrumb-item active" aria-current="page">${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}</li>
                    </ol>
                </nav>
                <div class="admin-page-head">
                    <div>
                        <span class="eyebrow">Dữ liệu khuyến mãi</span>
                        <h1>${isEdit ? 'Chỉnh sửa: ' : 'Tạo mã giảm giá mới'} <c:out value="${promo.code}" /></h1>
                    </div>
                </div>

                <!-- KHUNG HIỂN THỊ LỖI CHUNG CHO CẢ FE VÀ BE -->
                <div id="error-banner" class="alert alert-danger" style="${empty errorMessage ? 'display: none;' : ''}" role="alert">
                    <c:out value="${errorMessage}" />
                </div>

                <section class="admin-panel">
                    <form id="promoForm" action="${pageContext.request.contextPath}/admin/promotions/update" method="post" class="admin-form-stack">
                        <c:if test="${isEdit}">
                            <input type="hidden" name="promoId" value="${promo.promoId}">
                        </c:if>

                        <div class="admin-form-grid">
                            <div>
                                <label class="form-label" for="voucher-code">Mã giảm giá</label>
                                <input id="voucher-code" class="form-control" type="text" name="code" value="<c:out value='${promo.code}'/>" placeholder="APPLE40">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-type">Loại giảm giá</label>
                                <select id="voucher-type" class="form-select" name="discountType">
                                    <option value="FIXED" ${promo.discountType == 'FIXED' ? 'selected' : ''}>Số tiền cố định</option>
                                    <option value="PERCENT" ${promo.discountType == 'PERCENT' ? 'selected' : ''}>Phần trăm</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-value">Mức giảm</label>
                                <input id="voucher-value" class="form-control" type="number" step="0.01" name="discountValue" value="${promo.discountValue}">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-discount-max">Mức giảm tối đa (nếu giảm theo %)</label>
                                <input id="voucher-discount-max" class="form-control" type="number" step="0.01" name="discountMax" value="${promo.discountMax}" placeholder="Không bắt buộc">
                            </div>
                            
                            <div>
                                <label class="form-label" for="voucher-scope">Phạm vi áp dụng</label>
                                <select id="voucher-scope" class="form-select" name="scope">
                                    <option value="ORDER" ${promo.scope == 'ORDER' ? 'selected' : ''}>Toàn bộ đơn hàng</option>
                                    <option value="CATEGORY" ${promo.scope == 'CATEGORY' ? 'selected' : ''}>Danh mục sản phẩm</option>
                                    <option value="PRODUCT" ${promo.scope == 'PRODUCT' ? 'selected' : ''}>Sản phẩm cụ thể</option>
                                </select>
                            </div>

                            <div id="category-selection-group" style="display: none;">
                                <label class="form-label" for="voucher-category">Danh mục áp dụng</label>
                                <select id="voucher-category" class="form-select" name="categoryId">
                                    <option value="">-- Chọn danh mục --</option>
                                    <c:forEach items="${categories}" var="cat">
                                        <option value="${cat.categoryId}" ${promo.categoryId == cat.categoryId ? 'selected' : ''}>
                                            <c:out value="${cat.name}" />
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <div id="product-selection-group" style="display: none;">
                                <label class="form-label" for="voucher-product">Sản phẩm áp dụng</label>
                                <select id="voucher-product" class="form-select" name="productId">
                                    <option value="">-- Chọn sản phẩm --</option>
                                    <c:forEach items="${products}" var="prod">
                                        <option value="${prod.productId}" ${promo.productId == prod.productId ? 'selected' : ''}>
                                            <c:out value="${prod.name}" />
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            
                            <div>
                                <label class="form-label" for="voucher-target">Mục tiêu được giảm</label>
                                <select id="voucher-target" class="form-select" name="benefitTarget">
                                    <option value="MERCHANDISE" ${promo.benefitTarget == 'MERCHANDISE' ? 'selected' : ''}>Tiền hàng</option>
                                    <option value="PRODUCT" ${promo.benefitTarget == 'PRODUCT' ? 'selected' : ''}>Sản phẩm</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-min-order">Đơn tối thiểu</label>
                                <input id="voucher-min-order" class="form-control" type="number" step="0.01" name="minOrderValue" value="${not empty promo.minOrderValue ? promo.minOrderValue : '0'}">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-usage-limit">Giới hạn số lượt dùng</label>
                                <input id="voucher-usage-limit" class="form-control" type="number" name="maxUses" value="${promo.maxUses}" placeholder="Bỏ trống nếu vô hạn">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-start-date">Ngày bắt đầu</label>
                                <input id="voucher-start-date" class="form-control" type="datetime-local" name="validFrom" value="${validFromStr}">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-end-date">Ngày kết thúc</label>
                                <input id="voucher-end-date" class="form-control" type="datetime-local" name="validUntil" value="${validUntilStr}">
                            </div>
                            
                            <div class="form-check align-self-end mt-3">
                                <input id="canStack" class="form-check-input" type="checkbox" name="canStack" ${isEdit and promo.canStack ? 'checked' : ''}>
                                <label class="form-check-label" for="canStack">Cho phép cộng dồn</label>
                            </div>
                            <div class="form-check align-self-end mt-3">
                                <input id="isActive" class="form-check-input" type="checkbox" name="isActive" ${not isEdit or promo.IsActive() ? 'checked' : ''}>
                                <label class="form-check-label" for="isActive">Kích hoạt mã ngay</label>
                            </div>
                        </div>

                        <div class="admin-form-actions mt-4">
                            <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/admin/promotions">Hủy</a>
                            <button class="btn btn-app-primary" type="submit">${isEdit ? 'Cập nhật' : 'Phát hành'}</button>
                        </div>
                    </form>
                </section>
            </section>
        </main>
        
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const scopeSelect = document.getElementById('voucher-scope');
                const productGroup = document.getElementById('product-selection-group');
                const categoryGroup = document.getElementById('category-selection-group');
                const errorBanner = document.getElementById('error-banner');
                const isEdit = ${isEdit != null ? isEdit : false};

                function toggleScopeSelection() {
                    productGroup.style.display = 'none';
                    categoryGroup.style.display = 'none';
                    if (scopeSelect.value === 'PRODUCT') productGroup.style.display = 'block';
                    else if (scopeSelect.value === 'CATEGORY') categoryGroup.style.display = 'block';
                }

                toggleScopeSelection();
                scopeSelect.addEventListener('change', toggleScopeSelection);

                function showError(msg) {
                    errorBanner.textContent = msg;
                    errorBanner.style.display = 'block';
                    window.scrollTo(0, 0); 
                }

                document.getElementById('promoForm').addEventListener('submit', function (event) {
                    errorBanner.style.display = 'none';
                    let errorMsg = '';

                    const code = document.getElementById('voucher-code').value.trim();
                    const discountType = document.getElementById('voucher-type').value;
                    const discountValue = parseFloat(document.getElementById('voucher-value').value);
                    const discountMax = parseFloat(document.getElementById('voucher-discount-max').value);
                    const minOrderValue = parseFloat(document.getElementById('voucher-min-order').value);
                    const scope = scopeSelect.value;
                    const productId = document.getElementById('voucher-product').value;
                    const categoryId = document.getElementById('voucher-category').value;
                    const validFrom = document.getElementById('voucher-start-date').value;
                    const validUntil = document.getElementById('voucher-end-date').value;

                    if (!code) errorMsg = '[FE] Mã giảm giá không được để trống.';
                    else if (isNaN(discountValue) || discountValue <= 0) errorMsg = '[FE] Giá trị giảm phải lớn hơn 0.';
                    else if (discountType === 'PERCENT' && discountValue > 100) errorMsg = '[FE] Mức giảm phần trăm (%) tối đa là 100.';
                    else if (discountType === 'PERCENT' && !isNaN(discountMax) && discountMax < 0) errorMsg = '[FE] Mức giảm tối đa không được là số âm.';
                    else if (!isNaN(minOrderValue) && minOrderValue < 0) errorMsg = '[FE] Đơn tối thiểu không được là số âm.';
                    else if (scope === 'PRODUCT' && !productId) errorMsg = '[FE] Vui lòng chọn 1 Sản phẩm.';
                    else if (scope === 'CATEGORY' && !categoryId) errorMsg = '[FE] Vui lòng chọn 1 Danh mục.';
                    else if (!validFrom || !validUntil) errorMsg = '[FE] Vui lòng chọn đầy đủ thời gian bắt đầu và kết thúc.';
                    else {
                        const fromDate = new Date(validFrom);
                        const untilDate = new Date(validUntil);
                        const now = new Date();
                        const nowBuffer = new Date(now.getTime() - 60000); // 1 phút độ trễ thao tác

                        if (untilDate <= fromDate) {
                            errorMsg = '[FE] Thời gian kết thúc bắt buộc phải SAU thời gian bắt đầu.';
                        } else if (untilDate < now) {
                            errorMsg = '[FE] Thời gian kết thúc không được nằm ở quá khứ.';
                        } else if (!isEdit && fromDate < nowBuffer) {
                            errorMsg = '[FE] Thời gian bắt đầu không được nằm ở quá khứ.';
                        }
                    }

                    if (errorMsg !== '') {
                        showError(errorMsg);
                        event.preventDefault(); // Chặn gửi về Backend
                    }
                });
            });
        </script>
    </body>
</html>