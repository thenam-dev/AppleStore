<%--
  admin/user-list.jsp — quản lý người dùng. Chỉ ADMIN truy cập (chặn ở AuthFilter).
  Servlet cần set:
    users : List<User>{id,fullName,initials,email,phone,roleLabel,roleClass,status,createdAt}
    keyword, roleFilter, statusFilter, sort
    + Paging.export(request, "tài khoản")
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Người dùng · Quản trị HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <c:set var="activeAdmin" value="users"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Người dùng</h2>
      <span style="font-size:13px;color:var(--ash)">${totalItems} tài khoản</span>
      <div class="who"><span><c:out value="${sessionScope.currentUser.fullName}"/></span><span class="av"><c:out value="${sessionScope.currentUser.initials}"/></span></div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="panel">
        <div class="panel-head"><h3>Danh sách người dùng</h3>
          <div class="r"><a class="btn sm" href="${ctx}/admin/user/edit"><svg width="15" height="15"><use href="#i-plus"/></svg>Thêm người dùng</a></div>
        </div>

        <form class="toolbar" method="get" action="${ctx}/admin/users">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search"/></svg>
            <label class="sr-only" for="kw">Tìm người dùng</label>
            <input id="kw" class="input" type="text" name="keyword" maxlength="100"
                   value="<c:out value='${keyword}'/>" placeholder="Tìm theo tên, email hoặc số điện thoại">
          </div>
          <select class="select" name="role">
            <option value="">Tất cả vai trò</option>
            <option value="ADMIN"    ${roleFilter eq 'ADMIN'    ? 'selected' : ''}>Quản trị viên</option>
            <option value="STAFF"    ${roleFilter eq 'STAFF'    ? 'selected' : ''}>Nhân viên</option>
            <option value="CUSTOMER" ${roleFilter eq 'CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
          </select>
          <select class="select" name="status">
            <option value="">Tất cả trạng thái</option>
            <option value="ACTIVE"   ${statusFilter eq 'ACTIVE'   ? 'selected' : ''}>Đang hoạt động</option>
            <option value="INACTIVE" ${statusFilter eq 'INACTIVE' ? 'selected' : ''}>Đã khoá</option>
          </select>
          <input type="hidden" name="page" value="1">
          <button type="submit" class="btn sm">Áp dụng</button>
          <a class="btn quiet sm" href="${ctx}/admin/users">Xoá lọc</a>
        </form>

        <c:choose>
          <c:when test="${empty users}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-user"/></svg></div>
              <h3>Không có người dùng nào khớp bộ lọc</h3>
              <p>Thử xoá bộ lọc hoặc tìm bằng từ khoá khác.</p>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-scroll">
            <table class="table">
              <thead><tr><th>#</th><th>Họ tên</th><th>Email</th><th>Điện thoại</th><th>Vai trò</th><th>Trạng thái</th><th>Ngày tạo</th><th style="text-align:right">Thao tác</th></tr></thead>
              <tbody>
                <c:forEach var="u" items="${users}" varStatus="st">
                  <tr>
                    <td class="num">${st.index + 1 + (page-1)*pageSize}</td>
                    <td><div style="display:flex;gap:9px;align-items:center">
                      <span class="av" style="width:28px;height:28px;font-size:11px"><c:out value="${u.initials}"/></span>
                      <b><c:out value="${u.fullName}"/></b></div></td>
                    <td><c:out value="${u.email}"/></td>
                    <td class="num"><c:out value="${u.phone}"/></td>
                    <td><span class="tag"><c:out value="${u.roleLabel}"/></span></td>
                    <td><c:choose>
                      <c:when test="${u.status eq 'ACTIVE'}"><span class="badge ok">Đang hoạt động</span></c:when>
                      <c:otherwise><span class="badge off">Đã khoá</span></c:otherwise>
                    </c:choose></td>
                    <td class="num"><fmt:formatDate value="${u.createdAt}" pattern="dd/MM/yyyy"/></td>
                    <td class="row-actions">
                      <a class="btn xs quiet" href="${ctx}/admin/user/detail?id=${u.id}"><svg width="13" height="13"><use href="#i-eye"/></svg></a>
                      <a class="btn xs quiet" href="${ctx}/admin/user/edit?id=${u.id}"><svg width="13" height="13"><use href="#i-edit"/></svg></a>
                      <c:if test="${u.id ne sessionScope.currentUser.id}">
                        <form class="inline-form" method="post" action="${ctx}/admin/user/status">
                          <input type="hidden" name="id" value="${u.id}">
                          <input type="hidden" name="status" value="${u.status eq 'ACTIVE' ? 'INACTIVE' : 'ACTIVE'}">
                          <input type="hidden" name="returnUrl" value="${ctx}/admin/users?page=${page}${filterQuery}">
                          <button type="submit" class="btn xs ${u.status eq 'ACTIVE' ? 'danger' : ''}">${u.status eq 'ACTIVE' ? 'Khoá' : 'Mở khoá'}</button>
                        </form>
                      </c:if>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
            </div>
            <c:set var="pageUrl"      value="${ctx}/admin/users"/>
            <c:set var="itemLabel"    value="tài khoản"/>
            <c:set var="showPageSize" value="${true}"/>
            <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>
