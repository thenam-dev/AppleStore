<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty category and category.categoryId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}" />
<c:choose>
  <c:when test="${isEdit and not category.isActive}"><c:set var="selectedCategoryStatus" value="INACTIVE" /></c:when>
  <c:otherwise><c:set var="selectedCategoryStatus" value="ACTIVE" /></c:otherwise>
</c:choose>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="${formModeLabel} danh mục · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="categories" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>${formModeLabel} danh mục</h2>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <form id="categoryForm" class="panel" action="${appPath}/admin/categories/update" method="post">
        <c:if test="${isEdit}">
          <input type="hidden" name="categoryId" value="${category.categoryId}">
        </c:if>
        <div class="panel-head">
          <h3>Thông tin danh mục</h3>
          <c:if test="${isEdit}">
            <span class="r badge info">#${category.categoryId}</span>
          </c:if>
        </div>
        <div class="panel-pad">
          <div class="grid-2">
            <div class="field">
              <label for="name">Tên danh mục <span class="req">*</span></label>
              <input id="name" class="input" type="text" name="name" maxlength="100" value="${fn:escapeXml(category.name)}" required>
            </div>
            <div class="field">
              <label for="slug">Slug <span class="req">*</span></label>
              <input id="slug" class="input" type="text" name="slug" maxlength="100" pattern="[a-z0-9]+(?:-[a-z0-9]+)*" title="Chỉ dùng chữ thường, số và dấu gạch ngang." value="${fn:escapeXml(category.slug)}" placeholder="iphone" required>
              <div class="help">Chỉ dùng chữ thường, số và dấu gạch ngang.</div>
            </div>
            <div class="field">
              <label for="displayOrder">Thứ tự hiển thị <span class="req">*</span></label>
              <input id="displayOrder" class="input" type="number" name="displayOrder" min="0" value="${empty category.displayOrder ? 0 : category.displayOrder}" required>
            </div>
            <div class="field">
              <label for="status">Trạng thái <span class="req">*</span></label>
              <select id="status" class="select" name="status" required>
                <c:forEach var="status" items="${categoryStatusOptions}">
                  <option value="${fn:escapeXml(status)}" ${selectedCategoryStatus eq status ? 'selected' : ''}>
                    ${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status}
                  </option>
                </c:forEach>
              </select>
            </div>
          </div>

          <div style="display:flex;gap:9px;justify-content:flex-end">
            <a class="btn ghost" href="${appPath}/admin/categories">Hủy</a>
            <button class="btn" type="submit">${isEdit ? 'Lưu thay đổi' : 'Tạo danh mục'}</button>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>
</body>
</html>
