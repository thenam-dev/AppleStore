<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!-- Nếu chạy báo lỗi taglib, đổi uri thành: "http://java.sun.com/jsp/jstl/core" -->

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
            
            <!-- Truyền tham số cho Sidebar bằng EL -->
            <c:set var="adminSidebarTitle" value="${isEdit ? 'Chỉnh sửa mã giảm giá' : 'Tạo mã giảm giá'}" scope="request" />
            <c:set var="adminSidebarDescription" value="Quản lý thông tin và điều kiện áp dụng mã giảm giá." scope="request" />
            <c:set var="adminSidebarFooterTitle" value="Phạm vi mã giảm giá" scope="request" />
            <c:set var="adminSidebarFooterDescription" value="Quy tắc được kiểm tra bằng PromotionService." scope="request" />
            
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

            <section class="admin-main">
                <div class="admin-topbar">
                    <div class="admin-topbar-actions ms-auto">
                        <a class="btn btn-app-outline btn-sm" href="${pageContext.request.contextPath}/admin/promotions">Về danh sách mã giảm giá</a>
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
                        <h1>${isEdit ? 'Chỉnh sửa mã: ' : 'Tạo mã giảm giá mới'} <c:out value="${promo.code}" /></h1>
                        <p>Nhập thông tin chi tiết cho chiến dịch giảm giá.</p>
                    </div>
                </div>

                <!-- Hiển thị lỗi nếu có -->
                <c:if test="${not empty errorMessage}">
                    <div class="alert alert-danger" role="alert"><c:out value="${errorMessage}" /></div>
                </c:if>

                <section class="admin-panel">
                    <form action="${pageContext.request.contextPath}/admin/promotions/update" method="post" name="adminVoucherForm" class="admin-form-stack">
                        
                        <c:if test="${isEdit}">
                            <input type="hidden" name="promoId" value="${promo.promoId}">
                        </c:if>

                        <div class="admin-form-grid">
                            <div>
                                <label class="form-label" for="voucher-code">Mã giảm giá</label>
                                <input id="voucher-code" class="form-control" type="text" name="code" value="<c:out value='${promo.code}'/>" placeholder="APPLE40" maxlength="50" required>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-type">Loại giảm giá</label>
                                <select id="voucher-type" class="form-select" name="discountType">
                                    <option value="FIXED" ${promo.discountType == 'FIXED' ? 'selected' : ''}>Số tiền cố định</option>
                                    <option value="PERCENT" ${promo.discountType == 'PERCENT' ? 'selected' : ''}>Phần trăm</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-value">Giá trị giảm</label>
                                <input id="voucher-value" class="form-control" type="number" step="0.01" name="discountValue" value="${promo.discountValue}" min="0" max="99999999" required>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-discount-max">Mức giảm tối đa (nếu giảm theo %)</label>
                                <input id="voucher-discount-max" class="form-control" type="number" step="0.01" name="discountMax" value="${promo.discountMax}" placeholder="Không bắt buộc">
                            </div>
                            
                            <div>
                                <label class="form-label" for="voucher-scope">Phạm vi áp dụng</label>
                                <select id="voucher-scope" class="form-select" name="scope">
                                    <option value="ORDER" ${promo.scope == 'ORDER' ? 'selected' : ''}>Tổng đơn hàng</option>
                                    <option value="CATEGORY" ${promo.scope == 'CATEGORY' ? 'selected' : ''}>Danh mục sản phẩm</option>
                                    <option value="PRODUCT" ${promo.scope == 'PRODUCT' ? 'selected' : ''}>Sản phẩm cụ thể</option>
                                </select>
                            </div>

                            <!-- Khối danh mục -->
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
                                <small class="text-muted d-block mt-1">Bắt buộc khi phạm vi là danh mục.</small>
                            </div>
                            
                            <!-- Khối sản phẩm -->
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
                                <small class="text-muted d-block mt-1">Bắt buộc khi phạm vi là sản phẩm.</small>
                            </div>
                            
                            <div>
                                <label class="form-label" for="voucher-target">Đối tượng được giảm</label>
                                <select id="voucher-target" class="form-select" name="benefitTarget">
                                    <option value="MERCHANDISE" ${promo.benefitTarget == 'MERCHANDISE' ? 'selected' : ''}>Tiền hàng</option>
                                    <option value="SHIPPING" ${promo.benefitTarget == 'SHIPPING' ? 'selected' : ''}>Phí vận chuyển</option>
                                    <option value="PRODUCT" ${promo.benefitTarget == 'PRODUCT' ? 'selected' : ''}>Sản phẩm</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-min-order">Giá trị đơn hàng tối thiểu</label>
                                <input id="voucher-min-order" class="form-control" type="number" step="0.01" name="minOrderValue" value="${not empty promo.minOrderValue ? promo.minOrderValue : '0'}" placeholder="2500">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-usage-limit">Giới hạn lượt dùng</label>
                                <input id="voucher-usage-limit" class="form-control" type="number" name="maxUses" value="${promo.maxUses}" placeholder="Để trống nếu không giới hạn">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-start-date">Ngày bắt đầu</label>
                                <!-- Đã dùng biến String validFromStr truyền từ Servlet -->
                                <input id="voucher-start-date" class="form-control" type="datetime-local" name="validFrom" value="${validFromStr}" required>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-end-date">Ngày kết thúc</label>
                                <input id="voucher-end-date" class="form-control" type="datetime-local" name="validUntil" value="${validUntilStr}" required>
                            </div>

                            <div class="form-check align-self-end mt-3">
                                <input id="canStack" class="form-check-input" type="checkbox" name="canStack" ${isEdit and promo.canStack ? 'checked' : ''}>
                                <label class="form-check-label" for="canStack">Cho phép cộng dồn</label>
                            </div>
                            <div class="form-check align-self-end mt-3">
                                <!-- Hỗ trợ trực tiếp gọi hàm () trong EL của Tomcat 10 -->
                                <input id="isActive" class="form-check-input" type="checkbox" name="isActive" ${not isEdit or promo.IsActive() ? 'checked' : ''}>
                                <label class="form-check-label" for="isActive">Kích hoạt</label>
                            </div>
                        </div>

                        <div class="mt-3">
                            <label class="form-label" for="voucher-note">Ghi chú nội bộ (tùy chọn)</label>
                            <textarea id="voucher-note" class="form-control" name="note" rows="4" placeholder="Ghi chú chiến dịch, sản phẩm loại trừ hoặc lưu ý duyệt nội bộ."></textarea>
                        </div>

                        <div class="admin-form-actions mt-4">
                            <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/admin/promotions">Hủy</a>
                            <button class="btn btn-app-primary" type="submit">${isEdit ? 'Cập nhật mã giảm giá' : 'Phát hành mã giảm giá'}</button>
                        </div>
                    </form>
                </section>

                <jsp:include page="/WEB-INF/views/admin/promotions/setup-notes.jsp" />
            </section>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
        
        <!-- Script xử lý form mã giảm giá -->
        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const discountTypeSelect = document.getElementById('voucher-type');
                const discountMaxInput = document.getElementById('voucher-discount-max');
                
                const scopeSelect = document.getElementById('voucher-scope');
                const productGroup = document.getElementById('product-selection-group');
                const productInput = document.getElementById('voucher-product');
                const categoryGroup = document.getElementById('category-selection-group');
                const categoryInput = document.getElementById('voucher-category');
                const targetSelect = document.getElementById('voucher-target');

                function toggleDiscountMax() {
                    if (discountTypeSelect.value === 'FIXED') {
                        discountMaxInput.disabled = true;  
                        discountMaxInput.value = '';       
                    } else {
                        discountMaxInput.disabled = false; 
                    }
                }

                function toggleScopeSelection() {
                    productGroup.style.display = 'none';
                    categoryGroup.style.display = 'none';
                    targetSelect.style.pointerEvents = 'auto';
                    targetSelect.style.opacity = '1';
                    
                    if (scopeSelect.value === 'PRODUCT') {
                        productGroup.style.display = 'block'; 
                        categoryInput.value = '';
                        targetSelect.value = 'PRODUCT';
                        targetSelect.style.pointerEvents = 'none'; 
                        targetSelect.style.opacity = '0.6';
                    } else if (scopeSelect.value === 'CATEGORY') {
                        categoryGroup.style.display = 'block';
                        productInput.value = '';
                        if(targetSelect.value === 'PRODUCT') targetSelect.value = 'MERCHANDISE';
                    } else { 
                        productInput.value = '';
                        categoryInput.value = '';
                        if(targetSelect.value === 'PRODUCT') targetSelect.value = 'MERCHANDISE';
                    }
                }

                toggleDiscountMax();
                discountTypeSelect.addEventListener('change', toggleDiscountMax);
                toggleScopeSelection();
                scopeSelect.addEventListener('change', toggleScopeSelection);

                document.forms['adminVoucherForm'].addEventListener('submit', function (event) {
                    const discountType = discountTypeSelect.value;
                    const discountValue = parseFloat(document.getElementById('voucher-value').value);
                    const validFrom = document.getElementById('voucher-start-date').value;
                    const validUntil = document.getElementById('voucher-end-date').value;

                    if (discountType === 'PERCENT' && (discountValue <= 0 || discountValue > 100)) {
                        alert('Lỗi: Giá trị giảm theo Phần trăm (%) phải lớn hơn 0 và tối đa là 100.');
                        event.preventDefault(); return;
                    } else if (discountType === 'FIXED' && discountValue <= 0) {
                        alert('Lỗi: Số tiền giảm cố định phải lớn hơn 0.');
                        event.preventDefault(); return;
                    }

                    if (scopeSelect.value === 'PRODUCT' && productInput.value === '') {
                        alert('Lỗi: Bạn phải chọn sản phẩm áp dụng khi phạm vi là sản phẩm.');
                        event.preventDefault(); return;
                    }
                    if (scopeSelect.value === 'CATEGORY' && categoryInput.value === '') {
                        alert('Lỗi: Bạn phải chọn danh mục áp dụng khi phạm vi là danh mục.');
                        event.preventDefault(); return;
                    }
                    if (validFrom && validUntil) {
                        if (new Date(validUntil) <= new Date(validFrom)) {
                            alert('Lỗi: Thời gian kết thúc phải diễn ra SAU thời gian bắt đầu.');
                            event.preventDefault(); return;
                        }
                    }
                });
            });
        </script>
    </body>
</html>
