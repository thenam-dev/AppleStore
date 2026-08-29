<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty product and product.productId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="${formModeLabel} sản phẩm · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="products" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>${formModeLabel} sản phẩm</h2>
      <c:if test="${isEdit}">
        <span class="mono" style="font-size:11px;color:var(--ash)">ID ${product.productId}</span>
      </c:if>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />
      <c:if test="${currentCategoryInactive}">
        <div class="note-box" style="margin-bottom:16px">
          <div>Danh mục hiện tại <b><c:out value="${currentCategoryName}" /></b> đang tạm ẩn. Sản phẩm vẫn giữ danh mục này, nhưng không thể chuyển sang Đang bán cho đến khi danh mục được bật lại.</div>
        </div>
      </c:if>

      <form id="productForm" class="panel" action="${appPath}/admin/products/update" method="post">
        <c:if test="${isEdit}">
          <input type="hidden" name="productId" value="${product.productId}">
        </c:if>
        <div class="panel-head"><h3>Thông tin cơ bản</h3></div>
        <div class="panel-pad">
          <div class="grid-2">
            <div class="field full">
              <label for="name">Tên sản phẩm <span class="req">*</span></label>
              <input id="name" class="input" type="text" name="name" maxlength="200" value="${fn:escapeXml(product.name)}" required>
            </div>
            <div class="field">
              <label for="categoryId">Danh mục <span class="req">*</span></label>
              <select id="categoryId" class="select" name="categoryId" required>
                <option value="">Chọn danh mục</option>
                <c:forEach var="category" items="${categories}">
                  <option value="${category.categoryId}" ${product.categoryId eq category.categoryId ? 'selected' : ''}>
                    <c:out value="${category.name}" />
                    <c:if test="${not category.isActive}"> (đang tạm ẩn)</c:if>
                  </option>
                </c:forEach>
              </select>
            </div>
            <div class="field">
              <label for="status">Trạng thái <span class="req">*</span></label>
              <select id="status" class="select" name="status" required>
                <c:forEach var="status" items="${productStatusOptions}">
                  <option value="${fn:escapeXml(status)}" ${product.status eq status ? 'selected' : ''}>
                    ${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : status}
                  </option>
                </c:forEach>
              </select>
            </div>
            <div class="field">
              <label for="modelCode">Mã model</label>
              <input id="modelCode" class="input" type="text" name="modelCode" maxlength="50" value="${fn:escapeXml(product.modelCode)}">
            </div>
            <div class="field">
              <label for="releaseYear">Năm ra mắt</label>
              <input id="releaseYear" class="input" type="number" name="releaseYear" min="1998" max="2100" value="${product.releaseYear}">
            </div>
            <div class="field">
              <label for="productCondition">Tình trạng <span class="req">*</span></label>
              <select id="productCondition" class="select" name="productCondition" required>
                <c:forEach var="condition" items="${productConditionOptions}">
                  <option value="${fn:escapeXml(condition)}" ${product.productCondition eq condition ? 'selected' : ''}>
                    ${condition eq 'NEW' ? 'Mới' : condition eq 'LIKE_NEW' ? 'Như mới' : condition eq 'REFURBISHED' ? 'Tân trang' : condition}
                  </option>
                </c:forEach>
              </select>
            </div>
            <div class="field">
              <label for="importType">Mã thị trường <span class="req">*</span></label>
              <select id="importType" class="select" name="importType" required>
                <c:forEach var="importType" items="${productImportTypeOptions}">
                  <option value="${fn:escapeXml(importType)}" ${product.importType eq importType ? 'selected' : ''}>
                    <c:out value="${importType}" />
                  </option>
                </c:forEach>
              </select>
            </div>
            <div class="field">
              <label for="originCountry">Quốc gia xuất xứ</label>
              <input id="originCountry" class="input" type="text" name="originCountry" maxlength="100" value="${fn:escapeXml(product.originCountry)}">
            </div>
            <div class="field">
              <label for="warrantyMonths">Thời hạn bảo hành <span class="req">*</span></label>
              <input id="warrantyMonths" class="input" type="number" name="warrantyMonths" min="0" value="${product.warrantyMonths}" required>
            </div>
            <div class="field">
              <label>Hiển thị nổi bật</label>
              <div style="display:flex;align-items:center;gap:10px;height:44px">
                <input id="isFeatured" type="checkbox" name="isFeatured" ${product.featured ? 'checked' : ''}>
                <label for="isFeatured" style="margin:0;font-weight:400;font-size:13.5px">Nổi bật ở cửa hàng</label>
              </div>
            </div>
            <div class="field full">
              <label for="description">Mô tả</label>
              <textarea id="description" class="textarea" name="description" rows="5" maxlength="2000"><c:out value="${product.description}" /></textarea>
            </div>
          </div>

          <div style="display:flex;gap:9px;justify-content:flex-end">
            <a class="btn ghost" href="${appPath}/admin/products">Hủy</a>
            <button class="btn" type="submit">${isEdit ? 'Lưu thay đổi' : 'Tạo sản phẩm'}</button>
          </div>
        </div>
      </form>

    </div>
  </div>
</div>
</body>
</html>
