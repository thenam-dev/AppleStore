<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Sản phẩm · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="products" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Sản phẩm</h2>
      <span style="font-size:13px;color:var(--ash)">Kết quả lọc: ${filteredProducts}</span>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <section class="stats">
        <article class="stat">
          <div class="lab">Tổng sản phẩm</div>
          <div class="val">${totalProducts}</div>
          <div class="delta">Toàn bộ catalog</div>
        </article>
        <article class="stat">
          <div class="lab">Đang bán</div>
          <div class="val">${activeProducts}</div>
          <div class="delta">Hiển thị bán hàng</div>
        </article>
        <article class="stat">
          <div class="lab">Tạm ẩn</div>
          <div class="val">${inactiveProducts}</div>
          <div class="delta down">Không hiển thị</div>
        </article>
        <article class="stat">
          <div class="lab">Ngừng kinh doanh</div>
          <div class="val">${discontinuedProducts}</div>
          <div class="delta down">Giữ cho lịch sử</div>
        </article>
      </section>

      <div class="panel">
        <div class="panel-head">
          <h3>Bảng sản phẩm</h3>
          <div class="r">
            <a class="btn sm" href="${appPath}/admin/products/edit"><svg width="15" height="15"><use href="#i-plus" /></svg>Thêm sản phẩm</a>
          </div>
        </div>

        <form class="toolbar" action="${appPath}/admin/products" method="get" name="adminProductFilterForm">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search" /></svg>
            <label class="sr-only" for="admin-product-search">Tìm sản phẩm</label>
            <input id="admin-product-search" class="input" type="search" name="keyword" maxlength="100"
                   value="${fn:escapeXml(keyword)}" placeholder="Tên sản phẩm hoặc mã model">
          </div>
          <select class="select" name="categoryId" aria-label="Danh mục">
            <option value="">Tất cả danh mục</option>
            <c:forEach var="category" items="${categories}">
              <option value="${category.categoryId}" ${selectedCategoryId eq category.categoryId ? 'selected' : ''}>
                <c:out value="${category.name}" />
              </option>
            </c:forEach>
          </select>
          <select class="select" name="status" aria-label="Trạng thái">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="status" items="${productStatusOptions}">
              <option value="${fn:escapeXml(status)}" ${selectedStatus eq status ? 'selected' : ''}>
                ${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : status}
              </option>
            </c:forEach>
          </select>
          <select class="select" name="sort" aria-label="Sắp xếp">
            <c:forEach var="sortOption" items="${sortOptions}">
              <option value="${fn:escapeXml(sortOption.value)}" ${selectedSort eq sortOption.value ? 'selected' : ''}>
                <c:out value="${sortOption.label}" />
              </option>
            </c:forEach>
          </select>
          <input type="hidden" name="page" value="1">
          <button class="btn sm" type="submit">Áp dụng</button>
          <a class="btn ghost sm" href="${appPath}/admin/products">Đặt lại</a>
        </form>

        <c:choose>
          <c:when test="${empty products}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-box" /></svg></div>
              <h3>Không tìm thấy sản phẩm</h3>
              <p>Thử xoá bộ lọc hoặc thêm sản phẩm mới vào catalog.</p>
              <a class="btn" href="${appPath}/admin/products/edit">Thêm sản phẩm</a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-scroll">
              <table class="table">
                <thead>
                  <tr>
                    <th>Sản phẩm</th>
                    <th>Danh mục</th>
                    <th>Giá từ</th>
                    <th>Tồn kho</th>
                    <th>Trạng thái</th>
                    <th style="text-align:right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="product" items="${products}">
                    <c:choose>
                      <c:when test="${product.status eq 'ACTIVE'}">
                        <c:set var="productStatusClass" value="ok" />
                        <c:set var="nextStatus" value="INACTIVE" />
                        <c:set var="statusActionLabel" value="Tạm ẩn" />
                        <c:set var="statusActionClass" value="danger" />
                      </c:when>
                      <c:when test="${product.status eq 'INACTIVE'}">
                        <c:set var="productStatusClass" value="off" />
                        <c:set var="nextStatus" value="ACTIVE" />
                        <c:set var="statusActionLabel" value="Kích hoạt" />
                        <c:set var="statusActionClass" value="" />
                      </c:when>
                      <c:otherwise>
                        <c:set var="productStatusClass" value="warn" />
                        <c:set var="nextStatus" value="ACTIVE" />
                        <c:set var="statusActionLabel" value="Bán lại" />
                        <c:set var="statusActionClass" value="" />
                      </c:otherwise>
                    </c:choose>
                    <tr>
                      <td>
                        <b><c:out value="${product.name}" /></b>
                        <div class="mono" style="font-size:11px;color:var(--ash)">
                          <c:choose>
                            <c:when test="${not empty product.modelCode}">Model: <c:out value="${product.modelCode}" /></c:when>
                            <c:otherwise>#${product.productId}</c:otherwise>
                          </c:choose>
                        </div>
                        <div style="font-size:12px;color:var(--ash)">Biến thể: ${product.variantCount}</div>
                      </td>
                      <td><span class="tag"><c:out value="${product.categoryName}" /></span></td>
                      <td class="num">
                        <c:choose>
                          <c:when test="${product.variantCount gt 0 and not empty product.minPrice}">
                            <fmt:formatNumber value="${product.minPrice}" pattern="#,##0.##" /> VND
                          </c:when>
                          <c:otherwise><span style="color:var(--ash)">Chưa có biến thể</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="num">${product.totalStock}</td>
                      <td>
                        <span class="badge ${productStatusClass}">
                          ${product.status eq 'ACTIVE' ? 'Đang bán' : product.status eq 'INACTIVE' ? 'Tạm ẩn' : product.status eq 'DISCONTINUED' ? 'Ngừng kinh doanh' : product.status}
                        </span>
                      </td>
                      <td>
                        <div class="row-actions">
                          <a class="btn xs quiet" href="${appPath}/admin/products/variants?productId=${product.productId}">Biến thể</a>
                          <a class="btn xs quiet" href="${appPath}/admin/products/specifications?productId=${product.productId}">Thông số</a>
                          <a class="btn xs quiet" href="${appPath}/admin/products/images?productId=${product.productId}">Ảnh</a>
                          <a class="btn xs quiet" href="${appPath}/admin/products/edit?id=${product.productId}" title="Sửa">
                            <svg width="13" height="13"><use href="#i-edit" /></svg>
                          </a>
                          <form class="inline-form" action="${appPath}/admin/products/status" method="post">
                            <input type="hidden" name="productId" value="${product.productId}">
                            <input type="hidden" name="status" value="${nextStatus}">
                            <button class="btn xs ${statusActionClass}" type="submit">${statusActionLabel}</button>
                          </form>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
            <c:set var="pageUrl" value="${appPath}/admin/products" />
            <c:set var="itemLabel" value="sản phẩm" />
            <c:set var="totalItems" value="${filteredProducts}" />
            <jsp:include page="/WEB-INF/views/common/pagination.jsp" />
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>
