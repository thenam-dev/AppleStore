<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Khách hàng · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="customers" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Khách hàng</h2>
      <span style="font-size:13px;color:var(--ash)">Tổng phù hợp: ${totalCustomers}</span>
      <div class="who">
        <span><c:out value="${empty sessionScope.user.fullName ? 'Quản trị' : sessionScope.user.fullName}" /></span>
        <span class="av"><c:out value="${empty sessionScope.user.fullName ? 'AD' : fn:substring(sessionScope.user.fullName, 0, 1)}" /></span>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <div class="panel">
        <div class="panel-head">
          <h3>Danh sách khách hàng</h3>
          <div class="r">
            <a class="btn ghost sm" href="${appPath}/admin/customers">Đặt lại</a>
          </div>
        </div>

        <form class="toolbar" action="${appPath}/admin/customers" method="get">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search" /></svg>
            <label class="sr-only" for="admin-customers-search">Tìm khách hàng</label>
            <input id="admin-customers-search" class="input" type="search" name="keyword" maxlength="100"
                   value="${fn:escapeXml(keyword)}" placeholder="Tên, email, số điện thoại">
          </div>
          <select class="select" name="status" aria-label="Trạng thái">
            <option value="">Tất cả trạng thái</option>
            <c:forEach var="status" items="${statuses}">
              <option value="${fn:escapeXml(status)}" ${selectedStatus eq status ? 'selected' : ''}>
                ${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status eq 'LOCKED' ? 'Đã khóa' : status eq 'SUSPENDED' ? 'Tạm ngưng' : status}
              </option>
            </c:forEach>
          </select>
          <select class="select" name="sort" aria-label="Sắp xếp">
            <option value="created_desc" ${selectedSort eq 'created_desc' ? 'selected' : ''}>Mới nhất</option>
            <option value="created_asc" ${selectedSort eq 'created_asc' ? 'selected' : ''}>Cũ nhất</option>
            <option value="name_asc" ${selectedSort eq 'name_asc' ? 'selected' : ''}>Tên A-Z</option>
            <option value="email_asc" ${selectedSort eq 'email_asc' ? 'selected' : ''}>Email A-Z</option>
            <option value="status_asc" ${selectedSort eq 'status_asc' ? 'selected' : ''}>Trạng thái A-Z</option>
          </select>
          <input type="hidden" name="page" value="1">
          <button class="btn sm" type="submit">Áp dụng</button>
        </form>

        <c:choose>
          <c:when test="${empty customers}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-user" /></svg></div>
              <h3>Không tìm thấy khách hàng</h3>
              <p>Thử đổi từ khóa hoặc trạng thái để xem lại dữ liệu.</p>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-scroll">
              <table class="table">
                <thead>
                  <tr>
                    <th>Khách hàng</th>
                    <th>Liên hệ</th>
                    <th>Trạng thái</th>
                    <th>Xác minh</th>
                    <th style="text-align:right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="customer" items="${customers}">
                    <c:set var="statusLabel" value="${customer.status eq 'ACTIVE' ? 'Đang hoạt động' : customer.status eq 'INACTIVE' ? 'Không hoạt động' : customer.status eq 'LOCKED' ? 'Đã khóa' : customer.status eq 'SUSPENDED' ? 'Tạm ngưng' : customer.status}" />
                    <c:set var="statusClass" value="${customer.status eq 'ACTIVE' ? 'ok' : (customer.status eq 'LOCKED' or customer.status eq 'SUSPENDED' ? 'dan' : 'off')}" />
                    <tr>
                      <td>
                        <b><c:out value="${customer.fullName}" /></b>
                        <div class="mono" style="font-size:11px;color:var(--ash)">#${customer.userId}</div>
                      </td>
                      <td>
                        <b><c:out value="${customer.email}" /></b>
                        <div style="font-size:12px;color:var(--ash)"><c:out value="${customer.phone}" /></div>
                      </td>
                      <td><span class="badge ${statusClass}"><c:out value="${statusLabel}" /></span></td>
                      <td>${customer.emailVerified ? 'Có' : 'Không'}</td>
                      <td>
                        <div class="row-actions">
                          <a class="btn xs quiet" href="${appPath}/admin/customers/detail?id=${customer.userId}" title="Xem chi tiết">
                            <svg width="13" height="13"><use href="#i-eye" /></svg>
                          </a>
                          <form class="inline-form" action="${appPath}/admin/customers/status" method="post">
                            <input type="hidden" name="userId" value="${customer.userId}">
                            <input type="hidden" name="redirectTo" value="/admin/customers">
                            <c:choose>
                              <c:when test="${customer.status eq 'ACTIVE'}">
                                <input type="hidden" name="status" value="LOCKED">
                                <button class="btn xs danger" type="submit">Khóa</button>
                              </c:when>
                              <c:otherwise>
                                <input type="hidden" name="status" value="ACTIVE">
                                <button class="btn xs" type="submit">Kích hoạt</button>
                              </c:otherwise>
                            </c:choose>
                          </form>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
            <c:set var="pageUrl" value="${appPath}/admin/customers" />
            <c:set var="itemLabel" value="khách hàng" />
            <c:set var="totalItems" value="${totalCustomers}" />
            <jsp:include page="/WEB-INF/views/common/pagination.jsp" />
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>
