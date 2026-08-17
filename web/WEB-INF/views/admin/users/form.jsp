<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Chỉnh sửa người dùng · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="users" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Chỉnh sửa người dùng</h2>
      <c:if test="${not empty user}">
        <span class="mono" style="font-size:11px;color:var(--ash)">ID ${user.userId}</span>
      </c:if>
      <div class="who">
        <a class="btn ghost sm" href="${appPath}/admin/users">Hủy</a>
        <c:if test="${not empty user}">
          <button class="btn sm" type="submit" form="userForm">Lưu thay đổi</button>
        </c:if>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <c:choose>
        <c:when test="${empty user}">
          <div class="panel">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-user" /></svg></div>
              <h3>Không tìm thấy người dùng</h3>
              <p>Quay lại danh sách để chọn một tài khoản khác.</p>
              <a class="btn" href="${appPath}/admin/users">Về danh sách</a>
            </div>
          </div>
        </c:when>
        <c:otherwise>
          <form id="userForm" class="panel" action="${appPath}/admin/users/update" method="post">
            <input type="hidden" name="userId" value="${user.userId}">
            <div class="panel-head"><h3>Thông tin tài khoản</h3></div>
            <div class="panel-pad">
              <div class="grid-2">
                <div class="field">
                  <label for="fullName">Họ và tên <span class="req">*</span></label>
                  <input id="fullName" class="input" type="text" name="fullName" maxlength="100" value="${fn:escapeXml(user.fullName)}" required>
                </div>
                <div class="field">
                  <label for="email">Email <span class="req">*</span></label>
                  <input id="email" class="input" type="email" name="email" maxlength="255" value="${fn:escapeXml(user.email)}" required>
                </div>
                <div class="field">
                  <label for="phone">Số điện thoại</label>
                  <input id="phone" class="input" type="tel" name="phone" maxlength="15" pattern="[0-9]{9,15}" title="Số điện thoại phải gồm 9 đến 15 chữ số." value="${fn:escapeXml(user.phone)}">
                  <div class="help">Chỉ nhập chữ số, từ 9 đến 15 ký tự.</div>
                </div>
                <div class="field">
                  <label for="role">Vai trò <span class="req">*</span></label>
                  <select id="role" class="select" name="role" required>
                    <c:forEach var="role" items="${roles}">
                      <option value="${fn:escapeXml(role)}" ${user.role eq role ? 'selected' : ''}>
                        ${role eq 'CUSTOMER' ? 'Khách hàng' : role eq 'ADMIN' ? 'Quản trị viên' : role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : role eq 'DELIVERY' ? 'Nhân viên giao hàng' : role}
                      </option>
                    </c:forEach>
                  </select>
                </div>
                <div class="field">
                  <label for="status">Trạng thái <span class="req">*</span></label>
                  <select id="status" class="select" name="status" required>
                    <c:forEach var="status" items="${statuses}">
                      <option value="${fn:escapeXml(status)}" ${user.status eq status ? 'selected' : ''}>
                        ${status eq 'ACTIVE' ? 'Đang hoạt động' : status eq 'INACTIVE' ? 'Không hoạt động' : status eq 'LOCKED' ? 'Đã khóa' : status eq 'SUSPENDED' ? 'Tạm ngưng' : status}
                      </option>
                    </c:forEach>
                  </select>
                </div>
                <div class="field">
                  <label>Email xác minh</label>
                  <div style="display:flex;align-items:center;gap:10px;height:44px">
                    <input id="emailVerified" type="checkbox" name="emailVerified" ${user.emailVerified ? 'checked' : ''}>
                    <label for="emailVerified" style="margin:0;font-weight:400;font-size:13.5px">Email đã xác minh</label>
                  </div>
                </div>
              </div>
              <div style="display:flex;gap:9px;justify-content:flex-end">
                <a class="btn ghost" href="${appPath}/admin/users">Hủy</a>
                <button class="btn" type="submit">Lưu thay đổi</button>
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
