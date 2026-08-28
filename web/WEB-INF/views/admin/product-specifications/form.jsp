<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Thông số kỹ thuật · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="products" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Thông số kỹ thuật</h2>
      <span style="font-size:13px;color:var(--ash)"><c:out value="${product.name}" /></span>
    </div>

    <div class="adm-body">
      <c:set var="breadcrumbSection" value="Thông số" scope="request" />
      <jsp:include page="/WEB-INF/views/common/product-breadcrumb.jsp" />

      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <form id="specificationForm" class="panel" action="${appPath}/admin/products/specifications/update" method="post">
        <input type="hidden" name="productId" value="${product.productId}">
        <div class="panel-head">
          <div>
            <h3>Danh sách thông số</h3>
            <p style="margin:5px 0 0;color:var(--ash);font-size:12px">Các dòng này được hiển thị theo nhóm trên trang chi tiết sản phẩm.</p>
          </div>
          <button id="add-specification-row" class="btn sm" type="button">+ Thêm dòng</button>
        </div>
        <div class="panel-pad">
          <div id="specification-rows" style="display:flex;flex-direction:column;gap:10px">
            <c:forEach var="row" items="${specificationRows}">
              <div class="specification-row" style="display:grid;grid-template-columns:minmax(130px,.8fr) minmax(160px,1fr) minmax(220px,1.5fr) 100px auto;gap:10px;align-items:end">
                <div class="field">
                  <label>Nhóm</label>
                  <input class="input" type="text" name="specGroup" maxlength="50" value="${fn:escapeXml(row.specGroup)}" placeholder="Màn hình">
                </div>
                <div class="field">
                  <label>Tên thông số</label>
                  <input class="input" type="text" name="specName" maxlength="100" value="${fn:escapeXml(row.specName)}" placeholder="Kích thước">
                </div>
                <div class="field">
                  <label>Giá trị</label>
                  <input class="input" type="text" name="specValue" maxlength="300" value="${fn:escapeXml(row.specValue)}" placeholder="6.1 inch">
                </div>
                <div class="field">
                  <label>Thứ tự</label>
                  <input class="input" type="number" name="displayOrder" min="0" step="1" value="${fn:escapeXml(row.displayOrder)}" placeholder="Tự động">
                </div>
                <button class="btn xs quiet remove-specification-row" type="button" title="Xóa dòng">Xóa</button>
              </div>
            </c:forEach>
          </div>
          <div id="specification-empty" class="empty" style="display:none;margin-top:14px;padding:28px 12px">
            <h3>Chưa có thông số</h3>
            <p>Thêm dòng đầu tiên để mô tả sản phẩm.</p>
          </div>
          <div style="display:flex;gap:9px;justify-content:flex-end;margin-top:16px">
            <a class="btn ghost" href="${appPath}/admin/products">Hủy</a>
            <button class="btn" type="submit">Lưu thông số</button>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<template id="specification-row-template">
  <div class="specification-row" style="display:grid;grid-template-columns:minmax(130px,.8fr) minmax(160px,1fr) minmax(220px,1.5fr) 100px auto;gap:10px;align-items:end">
    <div class="field">
      <label>Nhóm</label>
      <input class="input" type="text" name="specGroup" maxlength="50" placeholder="Màn hình">
    </div>
    <div class="field">
      <label>Tên thông số</label>
      <input class="input" type="text" name="specName" maxlength="100" placeholder="Kích thước">
    </div>
    <div class="field">
      <label>Giá trị</label>
      <input class="input" type="text" name="specValue" maxlength="300" placeholder="6.1 inch">
    </div>
    <div class="field">
      <label>Thứ tự</label>
      <input class="input" type="number" name="displayOrder" min="0" step="1" placeholder="Tự động">
    </div>
    <button class="btn xs quiet remove-specification-row" type="button" title="Xóa dòng">Xóa</button>
  </div>
</template>

<script>
  (function () {
    var rows = document.getElementById('specification-rows');
    var template = document.getElementById('specification-row-template');
    var emptyState = document.getElementById('specification-empty');

    function updateEmptyState() {
      emptyState.style.display = rows.children.length === 0 ? '' : 'none';
    }

    function addRow() {
      rows.insertAdjacentHTML('beforeend', template.innerHTML);
      updateEmptyState();
    }

    document.getElementById('add-specification-row').addEventListener('click', addRow);
    rows.addEventListener('click', function (event) {
      if (event.target.classList.contains('remove-specification-row')) {
        event.target.closest('.specification-row').remove();
        updateEmptyState();
      }
    });
    updateEmptyState();
  })();
</script>
</body>
</html>
