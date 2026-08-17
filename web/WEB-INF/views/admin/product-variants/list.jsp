<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Biến thể sản phẩm · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="products" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Biến thể</h2>
      <span style="font-size:13px;color:var(--ash)"><c:out value="${managedProduct.name}" /></span>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <section class="stats">
        <article class="stat">
          <div class="lab">Tổng biến thể</div>
          <div class="val">${totalVariants}</div>
          <div class="delta">SKU thuộc sản phẩm</div>
        </article>
        <article class="stat">
          <div class="lab">Đang bán</div>
          <div class="val">${activeVariants}</div>
          <div class="delta">Có thể bán</div>
        </article>
        <article class="stat">
          <div class="lab">Tạm ẩn</div>
          <div class="val">${inactiveVariants}</div>
          <div class="delta down">Không hiển thị</div>
        </article>
        <article class="stat">
          <div class="lab">Kết quả lọc</div>
          <div class="val">${filteredVariants}</div>
          <div class="delta">Theo bộ lọc hiện tại</div>
        </article>
      </section>

      <div class="panel">
        <div class="panel-head">
          <h3>Bảng biến thể</h3>
          <div class="r">
            <a class="btn ghost sm" href="${appPath}/admin/products/edit?id=${managedProduct.productId}">Sửa sản phẩm</a>
            <a class="btn ghost sm" href="${appPath}/admin/products">Sản phẩm</a>
            <a class="btn sm" href="${appPath}/admin/products/variants/edit?productId=${managedProduct.productId}"><svg width="15" height="15"><use href="#i-plus" /></svg>Thêm biến thể</a>
          </div>
        </div>

        <form class="toolbar" action="${appPath}/admin/products/variants" method="get" name="adminVariantFilterForm">
          <input type="hidden" name="productId" value="${managedProduct.productId}">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search" /></svg>
            <label class="sr-only" for="admin-variant-search">Tìm biến thể</label>
            <input id="admin-variant-search" class="input" type="search" name="keyword" maxlength="100"
                   value="${fn:escapeXml(keyword)}" placeholder="SKU, nhãn, màu, chip">
          </div>
          <select class="select" name="status" aria-label="Trạng thái">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="status" items="${variantStatusOptions}">
              <option value="${fn:escapeXml(status)}" ${selectedStatus eq status ? 'selected' : ''}>
                ${status eq 'ACTIVE' ? 'Đang bán' : status eq 'INACTIVE' ? 'Tạm ẩn' : status}
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
          <a class="btn ghost sm" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}">Đặt lại</a>
        </form>

        <c:choose>
          <c:when test="${empty variants}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-box" /></svg></div>
              <h3>Không tìm thấy biến thể</h3>
              <p>Thử đổi bộ lọc hoặc tạo SKU đầu tiên cho sản phẩm này.</p>
              <a class="btn" href="${appPath}/admin/products/variants/edit?productId=${managedProduct.productId}">Thêm biến thể</a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-scroll">
              <table class="table">
                <thead>
                  <tr>
                    <th>SKU / Nhãn</th>
                    <th>Thông số</th>
                    <th>Giá</th>
                    <th>Tồn kho</th>
                    <th>Trạng thái</th>
                    <th style="text-align:right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="variant" items="${variants}">
                    <c:choose>
                      <c:when test="${variant.active}">
                        <c:set var="variantStatusClass" value="ok" />
                        <c:set var="nextStatus" value="INACTIVE" />
                        <c:set var="statusActionLabel" value="Tạm ẩn" />
                        <c:set var="statusActionClass" value="danger" />
                      </c:when>
                      <c:otherwise>
                        <c:set var="variantStatusClass" value="off" />
                        <c:set var="nextStatus" value="ACTIVE" />
                        <c:set var="statusActionLabel" value="Kích hoạt" />
                        <c:set var="statusActionClass" value="" />
                      </c:otherwise>
                    </c:choose>
                    <tr>
                      <td>
                        <b><c:out value="${variant.sku}" /></b>
                        <div style="font-size:12px;color:var(--ash)"><c:out value="${variant.variantLabel}" /></div>
                      </td>
                      <td>
                        <c:if test="${not empty variant.colorName}">
                          <div style="font-size:12px;color:var(--graphite)">Màu: <c:out value="${variant.colorName}" /></div>
                        </c:if>
                        <c:if test="${variant.storageCapacityGb ne null}">
                          <div style="font-size:12px;color:var(--ash)">Dung lượng: ${variant.storageCapacityGb} GB</div>
                        </c:if>
                        <c:if test="${variant.ramGb ne null}">
                          <div style="font-size:12px;color:var(--ash)">RAM: ${variant.ramGb} GB</div>
                        </c:if>
                        <c:if test="${not empty variant.connectivity}">
                          <div style="font-size:12px;color:var(--ash)">Kết nối: ${variant.connectivity eq 'WIFI_CELLULAR' ? 'WiFi + di động' : variant.connectivity eq 'WIFI' ? 'WiFi' : variant.connectivity}</div>
                        </c:if>
                      </td>
                      <td class="num">
                        <b><fmt:formatNumber value="${variant.price}" pattern="#,##0.##" /> VND</b>
                        <c:if test="${not empty variant.discountPrice}">
                          <div style="font-size:12px;color:var(--ash)">Giảm: <fmt:formatNumber value="${variant.discountPrice}" pattern="#,##0.##" /> VND</div>
                        </c:if>
                      </td>
                      <td class="num">${variant.stockQuantity}</td>
                      <td><span class="badge ${variantStatusClass}">${variant.active ? 'Đang bán' : 'Tạm ẩn'}</span></td>
                      <td>
                        <div class="row-actions">
                          <a class="btn xs quiet" href="${appPath}/admin/products/variants/edit?id=${variant.variantId}" title="Sửa">
                            <svg width="13" height="13"><use href="#i-edit" /></svg>
                          </a>
                          <form class="inline-form" action="${appPath}/admin/products/variants/status" method="post">
                            <input type="hidden" name="variantId" value="${variant.variantId}">
                            <input type="hidden" name="productId" value="${managedProduct.productId}">
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
            <c:set var="pageUrl" value="${appPath}/admin/products/variants?productId=${managedProduct.productId}" />
            <c:set var="itemLabel" value="biến thể" />
            <c:set var="totalItems" value="${filteredVariants}" />
            <jsp:include page="/WEB-INF/views/common/pagination.jsp" />
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>
