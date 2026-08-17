<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Danh mục · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="categories" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Danh mục</h2>
      <span style="font-size:13px;color:var(--ash)">Kết quả lọc: ${filteredCategories}</span>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <section class="stats">
        <article class="stat">
          <div class="lab">Tổng danh mục</div>
          <div class="val">${totalCategories}</div>
          <div class="delta">Toàn bộ bản ghi</div>
        </article>
        <article class="stat">
          <div class="lab">Đang hoạt động</div>
          <div class="val">${activeCategories}</div>
          <div class="delta">Có thể gán sản phẩm</div>
        </article>
        <article class="stat">
          <div class="lab">Không hoạt động</div>
          <div class="val">${inactiveCategories}</div>
          <div class="delta down">Đang ẩn</div>
        </article>
        <article class="stat">
          <div class="lab">Kết quả lọc</div>
          <div class="val">${filteredCategories}</div>
          <div class="delta">Theo bộ lọc hiện tại</div>
        </article>
      </section>

      <div class="panel">
        <div class="panel-head">
          <h3>Bảng danh mục</h3>
          <div class="r">
            <a class="btn ghost sm" href="${appPath}/admin/products">Sản phẩm</a>
            <a class="btn sm" href="${appPath}/admin/categories/edit"><svg width="15" height="15"><use href="#i-plus" /></svg>Tạo danh mục</a>
          </div>
        </div>

        <form class="toolbar" action="${appPath}/admin/categories" method="get" name="adminCategoryFilterForm">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search" /></svg>
            <label class="sr-only" for="admin-category-search">Tìm danh mục</label>
            <input id="admin-category-search" class="input" type="search" name="keyword" maxlength="100"
                   value="${fn:escapeXml(keyword)}" placeholder="Tên danh mục hoặc slug">
          </div>
          <select class="select" name="status" aria-label="Trạng thái">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="status" items="${categoryStatusOptions}">
              <option value="${fn:escapeXml(status)}" ${selectedStatus eq status ? 'selected' : ''}>
                ${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status}
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
          <a class="btn ghost sm" href="${appPath}/admin/categories">Đặt lại</a>
        </form>

        <c:choose>
          <c:when test="${empty categories}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-grid" /></svg></div>
              <h3>Không tìm thấy danh mục</h3>
              <p>Thử xoá bộ lọc hoặc tạo danh mục mới cho catalog.</p>
              <a class="btn" href="${appPath}/admin/categories/edit">Tạo danh mục</a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-scroll">
              <table class="table">
                <thead>
                  <tr>
                    <th>ID</th>
                    <th>Tên danh mục</th>
                    <th>Slug</th>
                    <th>Thứ tự</th>
                    <th>Trạng thái</th>
                    <th style="text-align:right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="category" items="${categories}">
                    <tr>
                      <td class="num">#${category.categoryId}</td>
                      <td><b><c:out value="${category.name}" /></b></td>
                      <td class="num">/<c:out value="${category.slug}" /></td>
                      <td class="num">${category.displayOrder}</td>
                      <td>
                        <span class="badge ${category.isActive ? 'ok' : 'off'}">
                          ${category.isActive ? 'Đang hoạt động' : 'Không hoạt động'}
                        </span>
                      </td>
                      <td>
                        <div class="row-actions">
                          <a class="btn xs quiet" href="${appPath}/admin/categories/edit?id=${category.categoryId}" title="Sửa">
                            <svg width="13" height="13"><use href="#i-edit" /></svg>
                          </a>
                          <form class="inline-form" action="${appPath}/admin/categories/status" method="post">
                            <input type="hidden" name="categoryId" value="${category.categoryId}">
                            <input type="hidden" name="status" value="${category.isActive ? 'INACTIVE' : 'ACTIVE'}">
                            <button class="btn xs ${category.isActive ? 'danger' : ''}" type="submit">
                              ${category.isActive ? 'Tắt' : 'Kích hoạt'}
                            </button>
                          </form>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
            <c:set var="pageUrl" value="${appPath}/admin/categories" />
            <c:set var="itemLabel" value="danh mục" />
            <c:set var="totalItems" value="${filteredCategories}" />
            <jsp:include page="/WEB-INF/views/common/pagination.jsp" />
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>
