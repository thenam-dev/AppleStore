<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Nhân sự · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="users" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Nhân sự</h2>
      <span style="font-size:13px;color:var(--ash)">Tổng phù hợp: ${totalUsers}</span>
      <div class="who">
        <span><c:out value="${empty sessionScope.user.fullName ? 'Quản trị' : sessionScope.user.fullName}" /></span>
        <span class="av"><c:out value="${empty sessionScope.user.fullName ? 'AD' : fn:substring(sessionScope.user.fullName, 0, 1)}" /></span>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <div class="panel">
        <div class="panel-head">
          <h3>Danh sách tài khoản nội bộ</h3>
          <div class="r">
            <a class="btn ghost sm" href="${appPath}/admin/users">Đặt lại</a>
          </div>
        </div>

        <form class="toolbar" action="${appPath}/admin/users" method="get" name="adminUserFilterForm">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search" /></svg>
            <label class="sr-only" for="admin-users-search">Tìm nhân sự</label>
            <input id="admin-users-search" class="input" type="search" name="keyword" maxlength="100"
                   value="${fn:escapeXml(keyword)}" placeholder="Tên, email, số điện thoại">
          </div>
          <select class="select" name="role" aria-label="Vai trò">
            <option value="">Tất cả vai trò</option>
            <c:forEach var="role" items="${roles}">
              <option value="${fn:escapeXml(role)}" ${selectedRole eq role ? 'selected' : ''}>
                ${role eq 'ADMIN' ? 'Quản trị viên' : role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : role eq 'DELIVERY' ? 'Nhân viên giao hàng' : role}
              </option>
            </c:forEach>
          </select>
          <select class="select" name="status" aria-label="Trạng thái">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="status" items="${statuses}">
              <option value="${fn:escapeXml(status)}" ${selectedStatus eq status ? 'selected' : ''}>
                ${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status eq 'LOCKED' ? 'Đã khóa' : status eq 'SUSPENDED' ? 'Tạm ngưng' : status}
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
        </form>

        <c:choose>
          <c:when test="${empty users}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-user" /></svg></div>
              <h3>Không tìm thấy tài khoản nội bộ</h3>
              <p>Thử đổi từ khóa, vai trò hoặc trạng thái để xem lại dữ liệu.</p>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-scroll">
              <table class="table">
                <thead>
                  <tr>
                    <th>Nhân sự</th>
                    <th>Liên hệ</th>
                    <th>Vai trò</th>
                    <th>Trạng thái</th>
                    <th>Xác minh</th>
                    <th>Ngày tạo</th>
                    <th style="text-align:right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="user" items="${users}">
                    <c:set var="roleLabel" value="${user.role eq 'ADMIN' ? 'Quản trị viên' : user.role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : user.role eq 'DELIVERY' ? 'Nhân viên giao hàng' : user.role}" />
                    <c:set var="statusLabel" value="${user.status eq 'ACTIVE' ? 'Đang hoạt động' : user.status eq 'INACTIVE' ? 'Không hoạt động' : user.status eq 'LOCKED' ? 'Đã khóa' : user.status eq 'SUSPENDED' ? 'Tạm ngưng' : user.status}" />
                    <c:choose>
                      <c:when test="${user.status eq 'ACTIVE'}"><c:set var="statusClass" value="ok" /></c:when>
                      <c:when test="${user.status eq 'LOCKED' or user.status eq 'SUSPENDED'}"><c:set var="statusClass" value="dan" /></c:when>
                      <c:otherwise><c:set var="statusClass" value="off" /></c:otherwise>
                    </c:choose>
                    <tr>
                      <td>
                        <div style="display:flex;gap:9px;align-items:center">
                          <span class="av" style="width:28px;height:28px;font-size:11px"><c:out value="${userInitialsMap[user.userId]}" /></span>
                          <div>
                            <b><c:out value="${user.fullName}" /></b>
                            <div class="mono" style="font-size:11px;color:var(--ash)">#${user.userId}</div>
                          </div>
                        </div>
                      </td>
                      <td>
                        <b><c:out value="${user.email}" /></b>
                        <div style="font-size:12px;color:var(--ash)"><c:out value="${user.phone}" /></div>
                      </td>
                      <td><span class="tag"><c:out value="${roleLabel}" /></span></td>
                      <td><span class="badge ${statusClass}"><c:out value="${statusLabel}" /></span></td>
                      <td>${user.emailVerified ? 'Có' : 'Không'}</td>
                      <td class="num"><c:out value="${userCreatedAtMap[user.userId]}" /></td>
                      <td>
                        <div class="row-actions">
                          <a class="btn xs quiet" href="${appPath}/admin/users/edit?id=${user.userId}" title="Sửa">
                            <svg width="13" height="13"><use href="#i-edit" /></svg>
                          </a>
                          <c:choose>
                            <c:when test="${user.userId eq currentAdminId}">
                              <span class="tag">Tài khoản hiện tại</span>
                            </c:when>
                            <c:otherwise>
                              <form class="inline-form" action="${appPath}/admin/users/status" method="post">
                                <input type="hidden" name="userId" value="${user.userId}">
                                <c:choose>
                                  <c:when test="${user.status eq 'ACTIVE'}">
                                    <input type="hidden" name="status" value="LOCKED">
                                    <button class="btn xs danger" type="submit">Khóa</button>
                                  </c:when>
                                  <c:otherwise>
                                    <input type="hidden" name="status" value="ACTIVE">
                                    <button class="btn xs" type="submit">Kích hoạt</button>
                                  </c:otherwise>
                                </c:choose>
                              </form>
                            </c:otherwise>
                          </c:choose>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
            <c:set var="pageUrl" value="${appPath}/admin/users" />
            <c:set var="itemLabel" value="tài khoản nội bộ" />
            <c:set var="totalItems" value="${totalUsers}" />
            <jsp:include page="/WEB-INF/views/common/pagination.jsp" />
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>
