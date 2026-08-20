<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
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
        <span class="mono" style="font-size:11px;color:var(--ash)">ID ${promo.promoId}</span>
      </c:if>
      <div class="who">
        <a class="btn ghost sm" href="${appPath}/admin/promotions">Hủy</a>
        <button class="btn sm" type="submit" form="promoForm">${isEdit ? 'Lưu thay đổi' : 'Tạo khuyến mãi'}</button>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />
      
      <c:if test="${not empty errorMessage}">
         <div class="flash err" style="margin-bottom: 20px;">
             <svg width="18" height="18"><use href="#i-alert"/></svg>
             <div><c:out value="${errorMessage}" /></div>
         </div>
      </c:if>

      <form id="promoForm" class="panel" action="${appPath}/admin/promotions/update" method="post">
        <c:if test="${isEdit}">
          <input type="hidden" name="promoId" value="${promo.promoId}">
        </c:if>
        <div class="panel-head"><h3>Thông tin cấu hình mã</h3></div>
        <div class="panel-pad">
          <div class="grid-2">
            
            <div class="field full">
              <label for="code">Mã giảm giá (Code) <span class="req">*</span></label>
              <input id="code" class="input" type="text" name="code" maxlength="20" value="${fn:escapeXml(promo.code)}" placeholder="VD: HALOSALE50" required>
              <div class="help">Viết hoa không dấu, độ dài 4 - 20 ký tự.</div>
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

            <div class="field">
              <label for="benefitTarget">Mục tiêu được giảm <span class="req">*</span></label>
              <select id="benefitTarget" class="select" name="benefitTarget" required>
                <option value="MERCHANDISE" ${promo.benefitTarget eq 'MERCHANDISE' ? 'selected' : ''}>Tiền hàng</option>
                <option value="PRODUCT" ${promo.benefitTarget eq 'PRODUCT' ? 'selected' : ''}>Sản phẩm cụ thể</option>
                <option value="SHIPPING" ${promo.benefitTarget eq 'SHIPPING' ? 'selected' : ''}>Phí vận chuyển (Freeship)</option>
              </select>
            </div>
            
            <div class="field">
              <label>Dùng kèm (Stack)</label>
              <div style="display:flex;align-items:center;gap:10px;height:44px">
                <input id="canStack" type="checkbox" name="canStack" value="1" ${promo.canStack ? 'checked' : ''}>
                <label for="canStack" style="margin:0;font-weight:400;font-size:13.5px">Cho phép dùng chung với mã khác loại</label>
              </div>
            </div>

            <!-- Khối Scope -->
            <div class="field full">
              <label for="scope">Phạm vi áp dụng (Scope) <span class="req">*</span></label>
              <select id="scope" class="select" name="scope" required>
                <option value="ORDER" ${promo.scope eq 'ORDER' ? 'selected' : ''}>Toàn bộ đơn hàng</option>
                <option value="CATEGORY" ${promo.scope eq 'CATEGORY' ? 'selected' : ''}>Theo danh mục</option>
                <option value="PRODUCT" ${promo.scope eq 'PRODUCT' ? 'selected' : ''}>Theo sản phẩm chỉ định</option>
              </select>
            </div>

            <div class="field" id="categoryField" style="display: none;">
              <label for="categoryId">Danh mục áp dụng <span class="req">*</span></label>
              <select id="categoryId" class="select" name="categoryId">
                <option value="">Chọn danh mục</option>
                <c:forEach var="cat" items="${categories}">
                  <option value="${cat.categoryId}" ${promo.categoryId eq cat.categoryId ? 'selected' : ''}>
                    <c:out value="${cat.name}" />
                  </option>
                </c:forEach>
              </select>
            </div>

            <div class="field" id="productField" style="display: none;">
              <label for="productId">Sản phẩm áp dụng <span class="req">*</span></label>
              <select id="productId" class="select" name="productId">
                <option value="">Chọn sản phẩm</option>
                <c:forEach var="prod" items="${products}">
                  <option value="${prod.productId}" ${promo.productId eq prod.productId ? 'selected' : ''}>
                    <c:out value="${prod.name}" />
                  </option>
                </c:forEach>
              </select>
            </div>

            <!-- Tùy chọn -->
            <div class="field full">
              <div style="display:flex;align-items:center;gap:10px;height:44px">
                <input id="isActive" type="checkbox" name="isActive" ${not isEdit or promo.IsActive() ? 'checked' : ''}>
                <label for="isActive" style="margin:0;font-weight:400;font-size:13.5px">Kích hoạt chạy ngay</label>
              </div>
            </div>

          </div>

          <div style="display:flex;gap:9px;justify-content:flex-end">
            <a class="btn ghost" href="${appPath}/admin/promotions">Hủy</a>
            <button class="btn" type="submit">${isEdit ? 'Lưu thay đổi' : 'Tạo khuyến mãi'}</button>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
  document.addEventListener("DOMContentLoaded", function() {
      // 1. Script xử lý ẩn hiện Danh mục / Sản phẩm dựa theo Scope
      const scopeSelect = document.getElementById('scope');
      const catField = document.getElementById('categoryField');
      const prodField = document.getElementById('productField');

      function toggleFields() {
          const val = scopeSelect.value;
          catField.style.display = (val === 'CATEGORY') ? 'block' : 'none';
          prodField.style.display = (val === 'PRODUCT') ? 'block' : 'none';
      }

      scopeSelect.addEventListener('change', toggleFields);
      toggleFields(); // Chạy lần đầu khi load form
      
      // 2. Script giới hạn Max là 100 và điều chỉnh step nếu chọn kiểu giảm Phần trăm
      const discountTypeSelect = document.getElementById('discountType');
      const discountValueInput = document.getElementById('discountValue');

      function updateDiscountValidation() {
          if (discountTypeSelect.value === 'PERCENT') {
              discountValueInput.max = 100;
              discountValueInput.step = 1;
          } else {
              discountValueInput.removeAttribute('max');
              discountValueInput.step = 1000;
          }
      }
      discountTypeSelect.addEventListener('change', updateDiscountValidation);
      updateDiscountValidation(); // Chạy lần đầu khi load form
  });
</script>
</body>
</html>