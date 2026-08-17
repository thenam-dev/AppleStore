<%--
  admin/product-list.jsp — bảng quản lý sản phẩm.
  Dùng chung cho ADMIN và STAFF: cùng một file, khác nhau ở cờ quyền
  do servlet đặt sẵn (rule 9). Không có scriptlet.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx"     value="${pageContext.request.contextPath}"/>
<c:set var="canEdit" value="${sessionScope.currentUser.role eq 'ADMIN'}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Sản phẩm · Quản trị HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <c:set var="activeAdmin" value="products"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Sản phẩm</h2>
      <span style="font-size:13px;color:var(--ash)">${totalItems} sản phẩm</span>
      <c:if test="${not canEdit}">
        <span class="badge info">Bạn đang xem với quyền nhân viên</span>
      </c:if>
      <div class="who">
        <span><c:out value="${sessionScope.currentUser.fullName}"/></span>
        <span class="av"><c:out value="${sessionScope.currentUser.initials}"/></span>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="panel">
        <div class="panel-head">
          <h3>Danh sách sản phẩm</h3>
          <div class="r">
            <c:if test="${canEdit}">
              <a class="btn sm" href="${ctx}/admin/product/edit">
                <svg width="15" height="15"><use href="#i-plus"/></svg>Thêm sản phẩm
              </a>
            </c:if>
          </div>
        </div>

        <form class="toolbar" method="get" action="${ctx}/admin/products">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search"/></svg>
            <label class="sr-only" for="kw">Tìm sản phẩm</label>
            <input id="kw" class="input" type="text" name="keyword" maxlength="100"
                   value="<c:out value='${keyword}'/>" placeholder="Tìm theo tên hoặc mã sản phẩm">
          </div>
          <label class="sr-only" for="cat">Danh mục</label>
          <select id="cat" class="select" name="categoryId">
            <option value="">Tất cả danh mục</option>
            <c:forEach var="cat" items="${categories}">
              <option value="${cat.id}" ${categoryId == cat.id ? 'selected' : ''}><c:out value="${cat.name}"/></option>
            </c:forEach>
          </select>
          <label class="sr-only" for="st">Trạng thái</label>
          <select id="st" class="select" name="status">
            <option value="">Tất cả trạng thái</option>
            <option value="ACTIVE"   ${status eq 'ACTIVE'   ? 'selected' : ''}>Đang bán</option>
            <option value="INACTIVE" ${status eq 'INACTIVE' ? 'selected' : ''}>Ngừng bán</option>
          </select>
          <input type="hidden" name="page" value="1">
          <button type="submit" class="btn sm">Áp dụng</button>
          <a class="btn quiet sm" href="${ctx}/admin/products">Xoá lọc</a>
        </form>

        <c:choose>
          <c:when test="${empty products}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-box"/></svg></div>
              <h3>Chưa có sản phẩm nào khớp bộ lọc</h3>
              <p>Thử xoá bộ lọc, hoặc thêm sản phẩm mới vào danh mục này.</p>
              <c:if test="${canEdit}">
                <a class="btn" href="${ctx}/admin/product/edit">Thêm sản phẩm</a>
              </c:if>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-scroll">
            <table class="table">
              <thead>
                <tr>
                  <th>Ảnh</th>
                  <%-- sắp xếp bằng link GET, servlet đọc tham số sort --%>
                  <th>
                    <a class="${sort eq 'name_asc' or sort eq 'name_desc' ? 'sorted' : ''} ${sort eq 'name_desc' ? 'desc' : ''}"
                       href="${ctx}/admin/products?sort=${sort eq 'name_asc' ? 'name_desc' : 'name_asc'}${filterQuery}">Tên sản phẩm</a>
                  </th>
                  <th>Danh mục</th>
                  <th>
                    <a class="${sort eq 'price_asc' or sort eq 'price_desc' ? 'sorted' : ''} ${sort eq 'price_desc' ? 'desc' : ''}"
                       href="${ctx}/admin/products?sort=${sort eq 'price_asc' ? 'price_desc' : 'price_asc'}${filterQuery}">Giá bán</a>
                  </th>
                  <th>Tồn kho</th>
                  <th>Trạng thái</th>
                  <th style="text-align:right">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="p" items="${products}">
                  <tr>
                    <td>
                      <div class="shot thumb">
                        <c:choose>
                          <c:when test="${not empty p.imageUrl}">
                            <img src="${ctx}/uploads/${p.imageUrl}" alt="">
                          </c:when>
                          <c:otherwise>
                            <svg style="color:#5B6472"><use href="#${empty p.iconKey ? 'd-acc' : p.iconKey}"/></svg>
                          </c:otherwise>
                        </c:choose>
                      </div>
                    </td>
                    <td>
                      <b><c:out value="${p.name}"/></b>
                      <div class="mono" style="font-size:11px;color:var(--ash)"><c:out value="${p.sku}"/></div>
                    </td>
                    <td><span class="tag"><c:out value="${p.categoryName}"/></span></td>
                    <td class="num"><fmt:formatNumber value="${p.price}" type="number" maxFractionDigits="0"/> ₫</td>
                    <td class="num"
                        style="${p.stock == 0 ? 'color:var(--danger);font-weight:600' : (p.stock le 3 ? 'color:var(--warn);font-weight:600' : '')}">
                      ${p.stock}
                    </td>
                    <td>
                      <c:choose>
                        <c:when test="${p.status eq 'ACTIVE'}"><span class="badge ok">Đang bán</span></c:when>
                        <c:otherwise><span class="badge off">Ngừng bán</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td class="row-actions">
                      <a class="btn xs quiet" href="${ctx}/admin/product/detail?id=${p.id}" title="Xem">
                        <svg width="13" height="13"><use href="#i-eye"/></svg>
                      </a>
                      <c:if test="${canEdit}">
                        <a class="btn xs quiet" href="${ctx}/admin/product/edit?id=${p.id}" title="Sửa">
                          <svg width="13" height="13"><use href="#i-edit"/></svg>
                        </a>
                        <%-- đổi trạng thái phải là POST (rule 7) --%>
                        <form class="inline-form" method="post" action="${ctx}/admin/product/status">
                          <input type="hidden" name="id" value="${p.id}">
                          <input type="hidden" name="status" value="${p.status eq 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                          <input type="hidden" name="returnUrl" value="${ctx}/admin/products?page=${page}${filterQuery}">
                          <button type="submit" class="btn xs ${p.status eq 'ACTIVE' ? 'danger' : ''}">
                            ${p.status eq 'ACTIVE' ? 'Ngừng bán' : 'Mở bán'}
                          </button>
                        </form>
                      </c:if>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
            </div>

            <div style="border-top:1px solid var(--line)">
              <c:set var="pageUrl"      value="${ctx}/admin/products"/>
              <c:set var="itemLabel"    value="sản phẩm"/>
              <c:set var="showPageSize" value="${true}"/>
              <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>
