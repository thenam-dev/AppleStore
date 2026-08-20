<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Chi tiết khách hàng · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="customers" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Chi tiết khách hàng</h2>
      <c:if test="${not empty customer}">
        <span class="mono" style="font-size:11px;color:var(--ash)">ID ${customer.userId}</span>
      </c:if>
      <div class="who">
        <a class="btn ghost sm" href="${appPath}/admin/customers">Về danh sách</a>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <c:choose>
        <c:when test="${empty customer}">
          <div class="panel">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-user" /></svg></div>
              <h3>Không tìm thấy khách hàng</h3>
              <a class="btn" href="${appPath}/admin/customers">Về danh sách</a>
            </div>
          </div>
        </c:when>
        <c:otherwise>
          <div class="panel">
            <div class="panel-head"><h3>Hồ sơ khách hàng</h3></div>
            <div class="panel-pad">
              <div class="grid-2">
                <div class="field">
                  <label>Họ và tên</label>
                  <input class="input" type="text" value="${fn:escapeXml(customer.fullName)}" readonly>
                </div>
                <div class="field">
                  <label>Email</label>
                  <input class="input" type="email" value="${fn:escapeXml(customer.email)}" readonly>
                </div>
                <div class="field">
                  <label>Số điện thoại</label>
                  <input class="input" type="tel" value="${fn:escapeXml(customer.phone)}" readonly>
                </div>
                <div class="field">
                  <label>Vai trò</label>
                  <input class="input" type="text" value="Khách hàng" readonly>
                </div>
                <div class="field">
                  <label>Email xác minh</label>
                  <input class="input" type="text" value="${customer.emailVerified ? 'Có' : 'Không'}" readonly>
                </div>
                <div class="field">
                  <label>Nguồn đăng nhập</label>
                  <input class="input" type="text" value="${fn:escapeXml(customer.authProvider)}" readonly>
                </div>
              </div>
            </div>
          </div>

          <form class="panel" action="${appPath}/admin/customers/status" method="post">
            <input type="hidden" name="userId" value="${customer.userId}">
            <input type="hidden" name="redirectTo" value="/admin/customers/detail?id=${customer.userId}">
            <div class="panel-head"><h3>Trạng thái tài khoản</h3></div>
            <div class="panel-pad">
              <div class="grid-2">
                <div class="field">
                  <label for="customerStatus">Trạng thái</label>
                  <select id="customerStatus" class="select" name="status" required>
                    <c:forEach var="status" items="${statuses}">
                      <option value="${fn:escapeXml(status)}" ${customer.status eq status ? 'selected' : ''}>
                        ${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status eq 'LOCKED' ? 'Đã khóa' : status eq 'SUSPENDED' ? 'Tạm ngưng' : status}
                      </option>
                    </c:forEach>
                  </select>
                </div>
              </div>
              <div style="display:flex;gap:9px;justify-content:flex-end">
                <a class="btn ghost" href="${appPath}/admin/customers">Hủy</a>
                <button class="btn" type="submit">Cập nhật trạng thái</button>
              </div>
            </div>
          </form>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</div>
</body>
</html>
