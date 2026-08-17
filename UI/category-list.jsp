<%--
  admin/category-list.jsp — danh sách + panel sửa danh mục cùng trang.
  Servlet cần set:
    categories : List<Category>{id,name,slug,desc,productCount,status,displayOrder}
    keyword, statusFilter, sort
    selected   : Category đang mở để sửa (mặc định null = ẩn panel phải, hoặc panel rỗng để thêm mới)
    + Paging.export(request, "danh mục")
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Danh mục · Quản trị HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <c:set var="activeAdmin" value="categories"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Danh mục</h2>
      <span style="font-size:13px;color:var(--ash)">${totalItems} danh mục</span>
      <div class="who"><span class="av"><c:out value="${sessionScope.currentUser.initials}"/></span></div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="split">
        <div class="panel">
          <div class="panel-head"><h3>Danh sách danh mục</h3>
            <div class="r"><a class="btn sm" href="${ctx}/admin/categories?new=1"><svg width="15" height="15"><use href="#i-plus"/></svg>Thêm danh mục</a></div>
          </div>

          <form class="toolbar" method="get" action="${ctx}/admin/categories">
            <div class="search">
              <svg width="17" height="17"><use href="#i-search"/></svg>
              <label class="sr-only" for="kw">Tìm danh mục</label>
              <input id="kw" class="input" type="text" name="keyword" maxlength="50" value="<c:out value='${keyword}'/>" placeholder="Tìm theo tên danh mục">
            </div>
            <select class="select" name="status">
              <option value="">Tất cả trạng thái</option>
              <option value="ACTIVE"   ${statusFilter eq 'ACTIVE'   ? 'selected' : ''}>Đang bán</option>
              <option value="INACTIVE" ${statusFilter eq 'INACTIVE' ? 'selected' : ''}>Ngừng bán</option>
            </select>
            <input type="hidden" name="page" value="1">
            <button type="submit" class="btn sm">Áp dụng</button>
          </form>

          <c:choose>
            <c:when test="${empty categories}">
              <div class="empty">
                <div class="ring"><svg width="26" height="26"><use href="#i-grid"/></svg></div>
                <h3>Chưa có danh mục nào khớp bộ lọc</h3>
                <p>Thử xoá bộ lọc hoặc thêm danh mục mới.</p>
              </div>
            </c:when>
            <c:otherwise>
              <table class="table">
                <thead><tr><th>#</th><th>Tên danh mục</th><th>Đường dẫn</th><th>Số sản phẩm</th><th>Trạng thái</th><th style="text-align:right">Thao tác</th></tr></thead>
                <tbody>
                  <c:forEach var="cat" items="${categories}" varStatus="st">
                    <tr style="${cat.id eq selected.id ? 'background:#FCFBF8' : ''}">
                      <td class="num">${st.index + 1}</td>
                      <td><b><c:out value="${cat.name}"/></b>
                        <c:if test="${not empty cat.desc}"><div style="font-size:12px;color:var(--ash)"><c:out value="${cat.desc}"/></div></c:if></td>
                      <td class="num">/<c:out value="${cat.slug}"/></td>
                      <td class="num">${cat.productCount}</td>
                      <td><c:choose>
                        <c:when test="${cat.status eq 'ACTIVE'}"><span class="badge ok">Đang bán</span></c:when>
                        <c:otherwise><span class="badge off">Ngừng bán</span></c:otherwise>
                      </c:choose></td>
                      <td class="row-actions">
                        <a class="btn xs quiet" href="${ctx}/admin/categories?id=${cat.id}"><svg width="13" height="13"><use href="#i-edit"/></svg></a>
                        <form class="inline-form" method="post" action="${ctx}/admin/category/status">
                          <input type="hidden" name="id" value="${cat.id}">
                          <input type="hidden" name="status" value="${cat.status eq 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                          <input type="hidden" name="returnUrl" value="${ctx}/admin/categories?page=${page}${filterQuery}">
                          <button type="submit" class="btn xs ${cat.status eq 'ACTIVE' ? 'danger' : ''}">${cat.status eq 'ACTIVE' ? 'Ngừng bán' : 'Mở bán'}</button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
              <c:set var="pageUrl"   value="${ctx}/admin/categories"/>
              <c:set var="itemLabel" value="danh mục"/>
              <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
            </c:otherwise>
          </c:choose>
        </div>

        <div class="panel">
          <div class="panel-head"><h3>${empty selected.id ? 'Thêm danh mục' : 'Sửa danh mục'}</h3>
            <c:if test="${not empty selected.id}"><span class="r badge info">Đang mở: <c:out value="${selected.name}"/></span></c:if>
          </div>
          <form method="post" action="${ctx}/admin/category/save">
            <input type="hidden" name="id" value="${selected.id}">
            <div class="panel-pad">
              <div class="field ${not empty errors.name ? 'err' : ''}">
                <label>Tên danh mục <span class="req">*</span></label>
                <input class="input" type="text" name="name" maxlength="50" value="<c:out value='${selected.name}'/>">
                <c:choose>
                  <c:when test="${not empty errors.name}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.name}"/></div></c:when>
                  <c:otherwise><div class="help">Không trùng với danh mục khác, tối đa 50 ký tự</div></c:otherwise>
                </c:choose>
              </div>
              <div class="field ${not empty errors.slug ? 'err' : ''}">
                <label>Đường dẫn <span class="req">*</span></label>
                <input class="input" type="text" name="slug" maxlength="50" value="<c:out value='${selected.slug}'/>">
                <c:choose>
                  <c:when test="${not empty errors.slug}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.slug}"/></div></c:when>
                  <c:otherwise><div class="help">Chỉ dùng chữ thường, số và dấu gạch ngang</div></c:otherwise>
                </c:choose>
              </div>
              <div class="field">
                <label>Mô tả</label>
                <textarea class="textarea" name="desc" maxlength="300"><c:out value="${selected.desc}"/></textarea>
              </div>
              <div class="grid-2">
                <div class="field">
                  <label>Thứ tự hiển thị</label>
                  <input class="input" type="number" name="displayOrder" min="1" value="${empty selected.displayOrder ? 1 : selected.displayOrder}">
                </div>
                <div class="field">
                  <label>Trạng thái</label>
                  <div style="display:flex;align-items:center;gap:10px;height:44px">
                    <input type="checkbox" name="active" id="catActive" value="1" ${empty selected.id or selected.status eq 'ACTIVE' ? 'checked' : ''}>
                    <label for="catActive" style="margin:0;font-weight:400;font-size:13.5px">Đang bán</label>
                  </div>
                </div>
              </div>
              <div style="display:flex;gap:9px">
                <button type="submit" class="btn" style="flex:1">Lưu danh mục</button>
                <a class="btn ghost" href="${ctx}/admin/categories">Huỷ</a>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>
