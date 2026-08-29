<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty variant and variant.variantId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}" />
<c:choose>
  <c:when test="${isEdit and not variant.active}"><c:set var="selectedVariantStatus" value="INACTIVE" /></c:when>
  <c:otherwise><c:set var="selectedVariantStatus" value="ACTIVE" /></c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="${formModeLabel} biến thể · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="products" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>${formModeLabel} biến thể</h2>
      <span style="font-size:13px;color:var(--ash)"><c:out value="${managedProduct.name}" /></span>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <form id="variantForm" class="panel" action="${appPath}/admin/products/variants/update" method="post">
        <input type="hidden" name="productId" value="${managedProduct.productId}">
        <c:if test="${isEdit}">
          <input type="hidden" name="variantId" value="${variant.variantId}">
        </c:if>
        <div class="panel-head">
          <h3>Thông tin SKU</h3>
          <span class="r badge info">Sản phẩm #${managedProduct.productId}</span>
        </div>
        <div class="panel-pad">
          <div class="grid-3">
            <div class="field">
              <label for="sku">SKU <span class="req">*</span></label>
              <input id="sku" class="input" type="text" name="sku" maxlength="50" value="${fn:escapeXml(variant.sku)}" required>
            </div>
            <div class="field">
              <label for="status">Trạng thái <span class="req">*</span></label>
              <select id="status" class="select" name="status" required>
                <c:forEach var="status" items="${variantStatusOptions}">
                  <option value="${fn:escapeXml(status)}" ${selectedVariantStatus eq status ? 'selected' : ''}>
                    ${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status}
                  </option>
                </c:forEach>
              </select>
            </div>
            <div class="field full">
              <label for="variantLabel">Nhãn biến thể <span class="req">*</span></label>
              <input id="variantLabel" class="input" type="text" name="variantLabel" maxlength="150" value="${fn:escapeXml(variant.variantLabel)}" required>
            </div>
            <c:forEach var="definition" items="${variantAttributeDefinitions}">
              <c:choose>
                <c:when test="${definition.key eq 'color'}">
                  <div class="field">
                    <label for="colorName">Màu sắc <span class="req">*</span></label>
                    <input id="colorName" class="input" type="text" name="colorName" maxlength="50" value="${fn:escapeXml(variant.colorName)}" required>
                  </div>
                </c:when>
                <c:when test="${definition.key eq 'storage'}">
                  <div class="field">
                    <label for="storageCapacityGb">Dung lượng (GB) <span class="req">*</span></label>
                    <input id="storageCapacityGb" class="input" type="number" name="storageCapacityGb" min="0" value="${variant.storageCapacityGb}" required>
                  </div>
                </c:when>
                <c:when test="${definition.key eq 'ram'}">
                  <div class="field">
                    <label for="ramGb">RAM (GB) <span class="req">*</span></label>
                    <input id="ramGb" class="input" type="number" name="ramGb" min="0" value="${variant.ramGb}" required>
                  </div>
                </c:when>
                <c:when test="${definition.key eq 'connectivity'}">
                  <div class="field">
                    <label for="connectivity">Kết nối <span class="req">*</span></label>
                    <select id="connectivity" class="select" name="connectivity" required>
                      <option value="">Chọn kết nối</option>
                      <c:forEach var="connectivity" items="${variantConnectivityOptions}">
                        <option value="${fn:escapeXml(connectivity)}" ${variant.connectivity eq connectivity ? 'selected' : ''}>
                          ${connectivity eq 'WIFI_CELLULAR' ? 'WiFi + di động' : connectivity eq 'WIFI' ? 'WiFi' : connectivity}
                        </option>
                      </c:forEach>
                    </select>
                  </div>
                </c:when>
                <c:when test="${definition.key eq 'caseSize'}">
                  <div class="field">
                    <label for="caseSizeMm">Kích thước vỏ (mm) <span class="req">*</span></label>
                    <input id="caseSizeMm" class="input" type="number" name="caseSizeMm" min="1" value="${variant.caseSizeMm}" required>
                  </div>
                </c:when>
              </c:choose>
            </c:forEach>
            <div class="field">
              <label for="price">Giá bán <span class="req">*</span></label>
              <input id="price" class="input" type="number" step="0.01" min="0" name="price" value="${variant.price}" required>
            </div>
            <div class="field">
              <label for="stockQuantity">Số lượng tồn kho <span class="req">*</span></label>
              <input id="stockQuantity" class="input" type="number" min="0" name="stockQuantity" value="${variant.stockQuantity}" required>
            </div>
            <div class="field">
              <label for="weightKg">Khối lượng (kg) <span class="req">*</span></label>
              <input id="weightKg" class="input" type="number" step="0.001" min="0.001" name="weightKg" value="${variant.weightKg}" required>
            </div>
            <div class="field">
              <label for="discountPrice">Giá khuyến mãi</label>
              <input id="discountPrice" class="input" type="number" step="0.01" min="0" name="discountPrice" value="${variant.discountPrice}">
            </div>
            <div class="field">
              <label for="discountStart">Bắt đầu khuyến mãi</label>
              <input id="discountStart" class="input" type="datetime-local" name="discountStart" value="${discountStartValue}">
            </div>
            <div class="field">
              <label for="discountEnd">Kết thúc khuyến mãi</label>
              <input id="discountEnd" class="input" type="datetime-local" name="discountEnd" value="${discountEndValue}">
            </div>
          </div>

          <div class="note-box" style="margin-bottom:16px">
            <b>Điều kiện hợp lệ:</b> SKU duy nhất, giá không âm, tồn kho không âm và khối lượng lớn hơn 0 để dùng được trong giỏ hàng, thanh toán.
          </div>

          <div style="display:flex;gap:9px;justify-content:flex-end">
            <a class="btn ghost" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}">Hủy</a>
            <button class="btn" type="submit">${isEdit ? 'Lưu thay đổi' : 'Tạo biến thể'}</button>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>
</body>
</html>
