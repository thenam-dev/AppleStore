<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <c:set var="pageTitle" value="Mã giảm giá · Quản trị AppleStore"/>
    <!-- Sử dụng header chung của dự án -->
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>
    <style>
        /* Tinh chỉnh nhỏ cho sort link theo UI mới */
        .sort-link { color: var(--graphite); text-decoration: none; display: inline-flex; align-items: center; gap: 4px; }
        .sort-link:hover { color: var(--titan); }
    </style>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
    <c:set var="activeAdmin" value="promotions"/>
    <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

    <div class="adm-main">
        <div class="adm-bar">
            <h2>Chiến dịch mã giảm giá</h2>
            <!-- Chuyển phần KPI Grid cũ lên top bar cho tinh gọn -->
            <span style="font-size:13px;color:var(--ash)">
                <strong>${activeCount}</strong> đang kích hoạt · <strong>${expiringSoon}</strong> sắp hết hạn · <strong>${totalRedeemed}</strong> lượt đã dùng
            </span>
            <div class="who"><span class="av"><c:out value="${sessionScope.currentUser.initials}"/></span></div>
        </div>

        <div class="adm-body">
            <!-- Hiển thị lỗi chung -->
            <c:if test="${not empty errorMessage}">
                <div id="error-banner" class="flash err">
                    <svg width="18" height="18"><use href="#i-alert"/></svg>
                    <c:out value="${errorMessage}"/>
                </div>
            </c:if>
            <div id="js-error-banner" class="flash err" style="display: none;">
                <svg width="18" height="18"><use href="#i-alert"/></svg>
                <span id="js-error-text"></span>
            </div>

            <div class="split">
                <!-- PANEL BÊN TRÁI: DANH SÁCH -->
                <div class="panel">
                    <div class="panel-head"><h3>Dữ liệu khuyến mãi</h3></div>

                    <!-- FORM TÌM KIẾM & LỌC -->
                    <form class="toolbar" method="get" action="${ctx}/admin/promotions">
                        <div class="search">
                            <svg width="17" height="17"><use href="#i-search"/></svg>
                            <label class="sr-only" for="kw">Tìm mã giảm giá</label>
                            <input id="kw" class="input" type="text" name="keyword" maxlength="50" value="<c:out value='${keyword}'/>" placeholder="Tìm theo mã giảm giá...">
                        </div>
                        <select class="select" name="status">
                            <option value="">Tất cả trạng thái</option>
                            <option value="1" ${statusFilter == '1' ? 'selected' : ''}>Đang kích hoạt</option>
                            <option value="0" ${statusFilter == '0' ? 'selected' : ''}>Đã vô hiệu hóa</option>
                        </select>
                        <input type="hidden" name="sortCol" value="${sortCol}">
                        <input type="hidden" name="sortDir" value="${sortDir}">
                        <button type="submit" class="btn sm">Lọc</button>
                    </form>

                    <!-- BẢNG DỮ LIỆU -->
                    <c:choose>
                        <c:when test="${empty promotions}">
                            <div class="empty">
                                <div class="ring"><svg width="26" height="26"><use href="#i-tag"/></svg></div>
                                <h3>Không tìm thấy mã khuyến mãi nào</h3>
                                <p>Tạo chương trình mới ở khung bên phải.</p>
                            </div>
                        </c:when>
                        <c:otherwise>
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th>
                                            <a href="?keyword=${keyword}&status=${statusFilter}&sortCol=code&sortDir=${sortCol == 'code' && sortDir == 'ASC' ? 'DESC' : 'ASC'}" class="sort-link">
                                                Mã ${sortCol == 'code' ? (sortDir == 'ASC' ? '↑' : '↓') : ''}
                                            </a>
                                        </th>
                                        <th>Mức giảm</th>
                                        <th>Phạm vi</th>
                                        <th>
                                            <a href="?keyword=${keyword}&status=${statusFilter}&sortCol=valid_until&sortDir=${sortCol == 'valid_until' && sortDir == 'ASC' ? 'DESC' : 'ASC'}" class="sort-link">
                                                Hết hạn ${sortCol == 'valid_until' ? (sortDir == 'ASC' ? '↑' : '↓') : ''}
                                            </a>
                                        </th>
                                        <th>Trạng thái</th>
                                        <th style="text-align:right">Thao tác</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <c:forEach items="${promotions}" var="promo">
                                        <tr>
                                            <td class="num">
                                                <b><c:out value="${promo.code}"/></b>
                                                <div style="font-size:11px;color:var(--ash)">ID: ${promo.promoId}</div>
                                            </td>
                                            <td class="num">
                                                <c:choose>
                                                    <c:when test="${promo.discountType == 'PERCENT'}">
                                                        <span style="color:var(--ok)">${promo.discountValue}%</span>
                                                        <c:if test="${not empty promo.discountMax && promo.discountMax > 0}">
                                                            <div style="font-size:11px;color:var(--ash)">Tối đa: ${promo.discountMax}</div>
                                                        </c:if>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span>${promo.discountValue} VND</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${promo.scope eq 'ORDER'}">Tổng đơn</c:when>
                                                    <c:when test="${promo.scope eq 'CATEGORY'}">Danh mục</c:when>
                                                    <c:when test="${promo.scope eq 'PRODUCT'}">Sản phẩm</c:when>
                                                    <c:otherwise><c:out value="${promo.scope}"/></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="num">
                                                <c:if test="${not empty promo.validUntil}">
                                                    ${promo.validUntil.format(dateFormatter)}
                                                </c:if>
                                            </td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${promo.IsActive()}"><span class="badge ok">Đang chạy</span></c:when>
                                                    <c:otherwise><span class="badge off">Đã dừng</span></c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="row-actions">
                                                <!-- Nút Sửa load thẳng dữ liệu sang panel bên phải -->
                                                <a class="btn xs quiet" href="${ctx}/admin/promotions/edit?id=${promo.promoId}"><svg width="13" height="13"><use href="#i-edit"/></svg></a>
                                                
                                                <!-- Form đổi trạng thái inline -->
                                                <form class="inline-form" action="${ctx}/admin/promotions/status" method="post" onsubmit="return confirm('Bạn có chắc chắn muốn ${promo.IsActive() ? 'NGỪNG' : 'BẬT LẠI'} mã này không?');">
                                                    <input type="hidden" name="promoId" value="${promo.promoId}">
                                                    <input type="hidden" name="isActive" value="${!promo.IsActive()}">
                                                    <button type="submit" class="btn xs ${promo.IsActive() ? 'danger' : ''}">${promo.IsActive() ? 'Dừng' : 'Bật'}</button>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </tbody>
                            </table>

                            <!-- Include Phân trang -->
                            <c:if test="${totalPages > 1}">
                                <div style="padding: 16px; border-top: 1px solid var(--line); display: flex; justify-content: flex-end; gap: 8px;">
                                    <c:if test="${currentPage > 1}">
                                        <a class="btn sm quiet" href="?page=${currentPage - 1}&keyword=${keyword}&status=${statusFilter}&sortCol=${sortCol}&sortDir=${sortDir}">Trước</a>
                                    </c:if>
                                    <c:forEach begin="1" end="${totalPages}" var="i">
                                        <a class="btn sm ${currentPage == i ? '' : 'quiet'}" href="?page=${i}&keyword=${keyword}&status=${statusFilter}&sortCol=${sortCol}&sortDir=${sortDir}">${i}</a>
                                    </c:forEach>
                                    <c:if test="${currentPage < totalPages}">
                                        <a class="btn sm quiet" href="?page=${currentPage + 1}&keyword=${keyword}&status=${statusFilter}&sortCol=${sortCol}&sortDir=${sortDir}">Sau</a>
                                    </c:if>
                                </div>
                            </c:if>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- PANEL BÊN PHẢI: FORM TẠO/SỬA -->
                <div class="panel">
                    <div class="panel-head">
                        <h3>${isEdit ? 'Chỉnh sửa mã' : 'Tạo mã giảm giá mới'} ${isEdit ? promo.code : ''}</h3>
                        <c:if test="${isEdit}">
                            <a href="${ctx}/admin/promotions" class="btn xs quiet" style="margin-left: auto;">+ Tạo mới</a>
                        </c:if>
                    </div>
                    
                    <form id="promoForm" method="post" action="${ctx}/admin/promotions/update">
                        <c:if test="${isEdit}">
                            <input type="hidden" name="promoId" value="${promo.promoId}">
                        </c:if>

                        <div class="panel-pad">
                            <div class="field">
                                <label for="voucher-code">Mã giảm giá <span class="req">*</span></label>
                                <input id="voucher-code" class="input" type="text" name="code" value="<c:out value='${promo.code}'/>" placeholder="VD: APPLE40" maxlength="20">
                            </div>

                            <div class="grid-2">
                                <div class="field">
                                    <label for="voucher-type">Loại giảm <span class="req">*</span></label>
                                    <select id="voucher-type" class="select" name="discountType">
                                        <option value="FIXED" ${promo.discountType == 'FIXED' ? 'selected' : ''}>Số tiền cố định</option>
                                        <option value="PERCENT" ${promo.discountType == 'PERCENT' ? 'selected' : ''}>Phần trăm (%)</option>
                                    </select>
                                </div>
                                <div class="field">
                                    <label for="voucher-value">Mức giảm <span class="req">*</span></label>
                                    <input id="voucher-value" class="input" type="number" step="0.01" name="discountValue" value="${promo.discountValue}">
                                </div>
                            </div>

                            <div class="field" id="max-discount-group" style="${promo.discountType == 'PERCENT' ? '' : 'display:none;'}">
                                <label for="voucher-discount-max">Mức giảm tối đa</label>
                                <input id="voucher-discount-max" class="input" type="number" step="0.01" name="discountMax" value="${promo.discountMax}" placeholder="Bỏ trống nếu không giới hạn">
                            </div>

                            <div class="grid-2">
                                <div class="field">
                                    <label for="voucher-start-date">Ngày bắt đầu <span class="req">*</span></label>
                                    <input id="voucher-start-date" class="input" type="datetime-local" name="validFrom" value="${validFromStr}">
                                </div>
                                <div class="field">
                                    <label for="voucher-end-date">Ngày kết thúc <span class="req">*</span></label>
                                    <input id="voucher-end-date" class="input" type="datetime-local" name="validUntil" value="${validUntilStr}">
                                </div>
                            </div>

                            <div class="grid-2">
                                <div class="field">
                                    <label for="voucher-min-order">Đơn tối thiểu</label>
                                    <input id="voucher-min-order" class="input" type="number" step="0.01" name="minOrderValue" value="${not empty promo.minOrderValue ? promo.minOrderValue : '0'}">
                                </div>
                                <div class="field">
                                    <label for="voucher-usage-limit">Giới hạn số lượt dùng</label>
                                    <input id="voucher-usage-limit" class="input" type="number" name="maxUses" value="${promo.maxUses}" placeholder="Bỏ trống nếu vô hạn">
                                </div>
                            </div>

                            <div class="field">
                                <label for="voucher-scope">Phạm vi áp dụng</label>
                                <select id="voucher-scope" class="select" name="scope">
                                    <option value="ORDER" ${promo.scope == 'ORDER' ? 'selected' : ''}>Toàn bộ đơn hàng</option>
                                    <option value="CATEGORY" ${promo.scope == 'CATEGORY' ? 'selected' : ''}>Danh mục sản phẩm</option>
                                    <option value="PRODUCT" ${promo.scope == 'PRODUCT' ? 'selected' : ''}>Sản phẩm cụ thể</option>
                                </select>
                            </div>

                            <div class="field" id="category-selection-group" style="display: none;">
                                <label for="voucher-category">Danh mục áp dụng <span class="req">*</span></label>
                                <select id="voucher-category" class="select" name="categoryId">
                                    <option value="">-- Chọn danh mục --</option>
                                    <c:forEach items="${categories}" var="cat">
                                        <option value="${cat.categoryId}" ${promo.categoryId == cat.categoryId ? 'selected' : ''}>
                                            <c:out value="${cat.name}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="field" id="product-selection-group" style="display: none;">
                                <label for="voucher-product">Sản phẩm áp dụng <span class="req">*</span></label>
                                <select id="voucher-product" class="select" name="productId">
                                    <option value="">-- Chọn sản phẩm --</option>
                                    <c:forEach items="${products}" var="prod">
                                        <option value="${prod.productId}" ${promo.productId == prod.productId ? 'selected' : ''}>
                                            <c:out value="${prod.name}"/>
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>

                            <div class="field">
                                <label for="voucher-target">Mục tiêu được giảm</label>
                                <select id="voucher-target" class="select" name="benefitTarget">
                                    <option value="MERCHANDISE" ${promo.benefitTarget == 'MERCHANDISE' ? 'selected' : ''}>Tiền hàng</option>
                                    <option value="PRODUCT" ${promo.benefitTarget == 'PRODUCT' ? 'selected' : ''}>Sản phẩm</option>
                                </select>
                            </div>

                            <div style="margin-top:20px; display:flex; flex-direction:column; gap:12px;">
                                <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
                                    <input type="checkbox" name="canStack" ${isEdit and promo.canStack ? 'checked' : ''}>
                                    <span>Cho phép cộng dồn mã này với mã khác</span>
                                </label>
                                <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
                                    <input type="checkbox" name="isActive" ${not isEdit or promo.IsActive() ? 'checked' : ''}>
                                    <span>Kích hoạt mã chạy ngay lập tức</span>
                                </label>
                            </div>

                            <button type="submit" class="btn block" style="margin-top:24px;">${isEdit ? 'Cập nhật khuyến mãi' : 'Phát hành mã'}</button>
                            
                            <!-- Tích hợp Setup Notes gọn gàng vào dưới form -->
                            <div style="margin-top:32px; padding-top:16px; border-top:1px dashed var(--line);">
                                <h4 style="font-size:13px; color:var(--titan); margin-bottom:8px;">💡 Mẹo cấu hình:</h4>
                                <ul style="font-size:12px; color:var(--graphite); padding-left:16px; line-height:1.6;">
                                    <li><b>Loại giảm:</b> Đặt % tối đa để tránh lỗi giảm quá sâu.</li>
                                    <li><b>Phạm vi:</b> Chọn chính xác để không áp dụng sai đối tượng.</li>
                                    <li><b>Thời gian:</b> Mã sẽ tự động "Đã dừng" khi qua ngày kết thúc.</li>
                                </ul>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function () {
        const scopeSelect = document.getElementById('voucher-scope');
        const productGroup = document.getElementById('product-selection-group');
        const categoryGroup = document.getElementById('category-selection-group');
        const typeSelect = document.getElementById('voucher-type');
        const maxDiscountGroup = document.getElementById('max-discount-group');
        
        const errorBanner = document.getElementById('js-error-banner');
        const errorText = document.getElementById('js-error-text');
        const isEdit = ${isEdit != null ? isEdit : false};

        // Handle Scope UI
        function toggleScopeSelection() {
            productGroup.style.display = 'none';
            categoryGroup.style.display = 'none';
            if (scopeSelect.value === 'PRODUCT') productGroup.style.display = 'block';
            else if (scopeSelect.value === 'CATEGORY') categoryGroup.style.display = 'block';
        }
        
        // Handle Discount Type UI
        function toggleMaxDiscount() {
            maxDiscountGroup.style.display = typeSelect.value === 'PERCENT' ? 'block' : 'none';
        }

        toggleScopeSelection();
        toggleMaxDiscount();
        
        scopeSelect.addEventListener('change', toggleScopeSelection);
        typeSelect.addEventListener('change', toggleMaxDiscount);

        function showError(msg) {
            errorText.textContent = msg;
            errorBanner.style.display = 'flex';
            window.scrollTo({ top: 0, behavior: 'smooth' });
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

            if (!code) errorMsg = 'Mã giảm giá không được để trống.';
            else if (isNaN(discountValue) || discountValue <= 0) errorMsg = 'Giá trị giảm phải lớn hơn 0.';
            else if (discountType === 'PERCENT' && discountValue > 100) errorMsg = 'Mức giảm phần trăm (%) tối đa là 100.';
            else if (discountType === 'PERCENT' && !isNaN(discountMax) && discountMax < 0) errorMsg = 'Mức giảm tối đa không được là số âm.';
            else if (!isNaN(minOrderValue) && minOrderValue < 0) errorMsg = 'Đơn tối thiểu không được là số âm.';
            else if (scope === 'PRODUCT' && !productId) errorMsg = 'Vui lòng chọn 1 Sản phẩm.';
            else if (scope === 'CATEGORY' && !categoryId) errorMsg = 'Vui lòng chọn 1 Danh mục.';
            else if (!validFrom || !validUntil) errorMsg = 'Vui lòng chọn đầy đủ thời gian bắt đầu và kết thúc.';
            else {
                const fromDate = new Date(validFrom);
                const untilDate = new Date(validUntil);
                const now = new Date();
                const nowBuffer = new Date(now.getTime() - 60000); // 1 phút độ trễ

                if (untilDate <= fromDate) {
                    errorMsg = 'Thời gian kết thúc bắt buộc phải SAU thời gian bắt đầu.';
                } else if (untilDate < now) {
                    errorMsg = 'Thời gian kết thúc không được nằm ở quá khứ.';
                } else if (!isEdit && fromDate < nowBuffer) {
                    errorMsg = 'Thời gian bắt đầu không được nằm ở quá khứ.';
                }
            }

            if (errorMsg !== '') {
                showError(errorMsg);
                event.preventDefault();
            }
        });
    });
</script>
</body>
</html>