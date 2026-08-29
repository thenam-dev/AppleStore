<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty user and user.userId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Chỉnh sửa' : 'Tạo mới'}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="${formModeLabel} nhân sự · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="users" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>${formModeLabel} nhân sự</h2>
      <c:if test="${isEdit}">
        <span class="mono" style="font-size:11px;color:var(--ash)">ID ${user.userId}</span>
      </c:if>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <form id="userForm" class="panel" action="${appPath}/admin/users/update" method="post">
        <c:if test="${isEdit}">
          <input type="hidden" name="userId" value="${user.userId}">
        </c:if>
        <div class="panel-head"><h3>Thông tin tài khoản nội bộ</h3></div>
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
              <input id="phone" class="input" type="tel" name="phone" maxlength="10" pattern="0[0-9]{9}" title="Số điện thoại phải bắt đầu bằng số 0 và gồm đúng 10 chữ số." value="${fn:escapeXml(user.phone)}">
              <div class="help">Bắt đầu bằng số 0 và gồm đúng 10 chữ số.</div>
            </div>
            <div class="field">
              <label for="role">Vai trò <span class="req">*</span></label>
              <select id="role" class="select" name="role" required>
                <c:forEach var="role" items="${roles}">
                  <option value="${fn:escapeXml(role)}" ${user.role eq role ? 'selected' : ''}>
                    ${role eq 'ADMIN' ? 'Quản trị viên' : role eq 'SALE_STAFF' ? 'Nhân viên bán hàng' : role eq 'DELIVERY' ? 'Nhân viên giao hàng' : role}
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
              <input class="input" type="text" value="${isEdit ? (user.emailVerified ? 'Có' : 'Không') : 'Có — xác nhận bởi quản trị viên'}" readonly>
              <div class="help">${isEdit ? 'Nếu đổi email, hệ thống tự chuyển về chưa xác minh.' : 'Tài khoản nội bộ do quản trị viên tạo được xác nhận email ngay.'}</div>
            </div>
            <c:if test="${not isEdit}">
              <div class="field">
                <label for="password">Mật khẩu ban đầu <span class="req">*</span></label>
                <input id="password" class="input" type="password" name="password" minlength="8" maxlength="100"
                       pattern="(?=.*[A-Za-z])(?=.*[0-9]).{8,100}" autocomplete="new-password" required>
                <div class="help">Từ 8 đến 100 ký tự, có ít nhất một chữ và một số.</div>
              </div>
              <div class="field">
                <label for="confirmPassword">Xác nhận mật khẩu <span class="req">*</span></label>
                <input id="confirmPassword" class="input" type="password" name="confirmPassword" minlength="8" maxlength="100"
                       autocomplete="new-password" required>
              </div>
            </c:if>
          </div>
          <div style="display:flex;gap:9px;justify-content:flex-end">
            <a class="btn ghost" href="${appPath}/admin/users">Hủy</a>
            <button class="btn" type="submit">${isEdit ? 'Lưu thay đổi' : 'Tạo nhân viên'}</button>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>
</body>
</html>
