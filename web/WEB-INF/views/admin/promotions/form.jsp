<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty promo and promo.promoId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <c:set var="pageTitle" value="${formModeLabel} khuyến mãi · Quản trị HALO" />
        <jsp:include page="/WEB-INF/views/common/head.jsp" />
    </head>
    <body class="admin">
        <jsp:include page="/WEB-INF/views/common/icons.jsp" />

        <div class="adm">
            <c:set var="activeAdmin" value="promotions" />
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

            <div class="adm-main">
                <div class="adm-bar">
                    <h2>${formModeLabel} khuyến mãi</h2>
                    <c:if test="${isEdit}">
                        <span class="mono" style="font-size:11px;color:var(--ash)">ID #${promo.promoId}</span>
                    </c:if>
                </div>

                <div class="adm-body">
                    <!-- Rule 10: Chỉ dùng 1 flash include chung, bỏ đoạn if errorMessage dư thừa -->
                    <jsp:include page="/WEB-INF/views/common/flash.jsp" />

                    <form id="promoForm" class="panel" action="${appPath}/admin/promotions/update" method="post">
                        <c:if test="${isEdit}">
                            <input type="hidden" name="promoId" value="${promo.promoId}">
                        </c:if>

                        <input type="hidden" name="benefitTarget" value="MERCHANDISE">

                        <div class="panel-head"><h3>Thông tin cấu hình mã</h3></div>
                        <div class="panel-pad">
                            <div class="grid-2">

                                <div class="field full">
                                    <label for="code">Mã giảm giá (Code) <span class="req">*</span></label>
                                    <input id="code" class="input" type="text" name="code" maxlength="50" value="${fn:escapeXml(promo.code)}" placeholder="VD: HALOSALE50" required>
                                    <div class="help">Viết hoa không dấu, độ dài 4 - 50 ký tự.</div>
                                </div>

                                <div class="field">
                                    <label for="discountType">Kiểu giảm <span class="req">*</span></label>
                                    <select id="discountType" class="select" name="discountType" required>
                                        <option value="FIXED" ${promo.discountType eq 'FIXED' ? 'selected' : ''}>Số tiền cố định (đ)</option>
                                        <option value="PERCENT" ${promo.discountType eq 'PERCENT' ? 'selected' : ''}>Phần trăm (%)</option>
                                    </select>
                                </div>

                                <div class="field">
                                    <label for="discountValue">Giá trị giảm <span class="req">*</span></label>
                                    <input id="discountValue" class="input" type="number" step="1" min="1" name="discountValue" value="${promo.discountValue}" placeholder="Ví dụ: 50000 hoặc 10" required>
                                </div>

                                <div class="field">
                                    <label for="discountMax">Giảm tối đa (đ)</label>
                                    <input id="discountMax" class="input" type="number" step="1000" min="0" name="discountMax" value="${promo.discountMax}" placeholder="Chỉ dùng khi giảm theo %">
                                </div>

                                <div class="field">
                                    <label for="minOrderValue">Đơn tối thiểu (đ)</label>
                                    <input id="minOrderValue" class="input" type="number" step="1000" min="0" name="minOrderValue" value="${not empty promo.minOrderValue ? promo.minOrderValue : '0'}">
                                </div>

                                <div class="field">
                                    <label for="validFrom">Bắt đầu <span class="req">*</span></label>
                                    <input id="validFrom" class="input" type="datetime-local" name="validFrom" value="${validFromStr}" required>
                                </div>

                                <div class="field">
                                    <label for="validUntil">Kết thúc <span class="req">*</span></label>
                                    <input id="validUntil" class="input" type="datetime-local" name="validUntil" value="${validUntilStr}" required>
                                </div>

                                <div class="field">
                                    <label for="maxUses">Giới hạn số lượt dùng</label>
                                    <input id="maxUses" class="input" type="number" min="1" name="maxUses" value="${promo.maxUses}" placeholder="Để trống nếu không giới hạn">
                                </div>

                                <div class="field full">
                                    <label for="scope">Phạm vi áp dụng (Scope) <span class="req">*</span></label>
                                    <select id="scope" class="select" name="scope" required>
                                        <option value="ORDER" ${promo.scope eq 'ORDER' ? 'selected' : ''}>Toàn bộ đơn hàng</option>
                                        <option value="CATEGORY" ${promo.scope eq 'CATEGORY' ? 'selected' : ''}>Theo danh mục</option>
                                        <option value="PRODUCT" ${promo.scope eq 'PRODUCT' ? 'selected' : ''}>Theo sản phẩm chỉ định</option>
                                    </select>
                                </div>

                                <div class="field full" id="categoryField" style="display: none;">
                                    <label>Danh mục áp dụng (Chọn nhiều) <span class="req">*</span></label>
                                    <div style="border: 1px solid var(--line, #ddd); border-radius: 6px; background: #fff; max-height: 180px; overflow-y: auto; padding: 10px 15px;">
                                        <c:forEach var="cat" items="${categories}">
                                            <div style="display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px solid #f2f2f2;">
                                                <input type="checkbox" name="categoryIds" value="${cat.categoryId}" id="cat_${cat.categoryId}" 
                                                       ${promo.categoryIds != null && promo.categoryIds.contains(cat.categoryId) ? 'checked' : ''}
                                                       style="width: 16px; height: 16px; cursor: pointer;">
                                                <label for="cat_${cat.categoryId}" style="margin: 0; font-weight: normal; cursor: pointer; flex: 1; font-size: 13.5px;">
                                                    <c:out value="${cat.name}" />
                                                </label>
                                            </div>
                                        </c:forEach>
                                    </div>
                                    <div class="help" style="margin-top: 5px;">Tick chọn các danh mục muốn áp dụng mã giảm giá.</div>
                                </div>

                                <div class="field full" id="productField" style="display: none;">
                                    <label>Sản phẩm áp dụng (Chọn nhiều) <span class="req">*</span></label>
                                    <div style="border: 1px solid var(--line, #ddd); border-radius: 6px; background: #fff; max-height: 200px; overflow-y: auto; padding: 10px 15px;">
                                        <c:forEach var="prod" items="${products}">
                                            <div style="display: flex; align-items: center; gap: 8px; padding: 6px 0; border-bottom: 1px solid #f2f2f2;">
                                                <input type="checkbox" name="productIds" value="${prod.productId}" id="prod_${prod.productId}" 
                                                       ${promo.productIds != null && promo.productIds.contains(prod.productId) ? 'checked' : ''}
                                                       style="width: 16px; height: 16px; cursor: pointer;">
                                                <label for="prod_${prod.productId}" style="margin: 0; font-weight: normal; cursor: pointer; flex: 1; font-size: 13.5px;">
                                                    <c:out value="${prod.name}" />
                                                </label>
                                            </div>
                                        </c:forEach>
                                    </div>
                                    <div class="help" style="margin-top: 5px;">Tick chọn các sản phẩm cụ thể muốn áp dụng mã giảm giá.</div>
                                </div>

                                <div class="field full" style="margin-top: 5px;">
                                    <label>Tùy chọn hệ thống</label>
                                    <div style="display: flex; align-items: center; height: 48px; background: #f8f9fa; padding: 0 16px; border-radius: 6px; border: 1px solid var(--line, #eee);">
                                        <div style="display:flex; align-items:center; gap:8px;">
                                            <input id="isActive" type="checkbox" name="status" value="ACTIVE" ${not isEdit or promo.isActive ? 'checked' : ''}>
                                            <label for="isActive" style="margin:0; font-weight:500; font-size:13.5px; cursor: pointer; color: var(--titan);">Kích hoạt chạy ngay</label>
                                        </div>
                                    </div>
                                </div>

                            </div>

                            <div style="display:flex;gap:9px;justify-content:flex-end;margin-top:20px;">
                                <a class="btn ghost" href="${appPath}/admin/promotions">Hủy</a>
                                <button class="btn" type="submit">${isEdit ? 'Lưu thay đổi' : 'Tạo khuyến mãi'}</button>
                            </div>
                        </div>
                    </form>
                </div>
            </div>
        </div>

        <script>
            document.addEventListener("DOMContentLoaded", function () {
                const scopeSelect = document.getElementById('scope');
                const catField = document.getElementById('categoryField');
                const prodField = document.getElementById('productField');

                function toggleFields() {
                    const val = scopeSelect.value;
                    catField.style.display = (val === 'CATEGORY') ? 'block' : 'none';
                    prodField.style.display = (val === 'PRODUCT') ? 'block' : 'none';
                }

                scopeSelect.addEventListener('change', toggleFields);
                toggleFields();

                const discountTypeSelect = document.getElementById('discountType');
                const discountValueInput = document.getElementById('discountValue');
                const discountMaxInput = document.getElementById('discountMax');

                function updateDiscountValidation() {
                    if (discountTypeSelect.value === 'PERCENT') {
                        discountValueInput.max = 100;
                        discountValueInput.step = 1;
                        discountMaxInput.disabled = false;
                        discountMaxInput.placeholder = "Chỉ dùng khi giảm theo %";
                    } else {
                        discountValueInput.removeAttribute('max');
                        discountValueInput.step = 1000;
                        discountMaxInput.disabled = true;
                        discountMaxInput.value = '';
                        discountMaxInput.placeholder = "Không áp dụng";
                    }
                }

                discountTypeSelect.addEventListener('change', updateDiscountValidation);
                updateDiscountValidation();
            });
        </script>
    </body>
</html>
