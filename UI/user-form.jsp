<%--
  admin/user-form.jsp — dùng chung cho thêm mới và chỉnh sửa người dùng.
  Servlet cần set:
    form   : User{id,fullName,email,phone,birthDate,role,status,address}
             id rỗng/null => đang thêm mới
    errors : Map<String,String>
    stats  : {createdAtLabel,lastLoginLabel,orderCount,orderTotal} — chỉ có khi sửa
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="isNew" value="${empty form.id}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="${isNew ? 'Thêm' : 'Sửa'} người dùng · Quản trị HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <c:set var="activeAdmin" value="users"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>${isNew ? 'Thêm người dùng' : 'Sửa người dùng'}</h2>
      <c:if test="${not isNew}"><span class="mono" style="font-size:11px;color:var(--ash)">ID ${form.id}</span></c:if>
      <div class="who">
        <a class="btn ghost sm" href="${ctx}/admin/users">Huỷ</a>
        <button type="submit" form="userForm" class="btn sm">${isNew ? 'Tạo tài khoản' : 'Lưu thay đổi'}</button>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <form id="userForm" method="post" action="${ctx}/admin/user/save">
        <input type="hidden" name="id" value="${form.id}">
        <div class="split">
          <div class="panel"><div class="panel-head"><h3>Thông tin tài khoản</h3></div><div class="panel-pad">
            <div class="grid-2">
              <div class="field ${not empty errors.fullName ? 'err' : ''}">
                <label>Họ và tên <span class="req">*</span></label>
                <input class="input" type="text" name="fullName" maxlength="100" value="<c:out value='${form.fullName}'/>">
                <c:choose>
                  <c:when test="${not empty errors.fullName}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.fullName}"/></div></c:when>
                  <c:otherwise><div class="help">Tối đa 100 ký tự</div></c:otherwise>
                </c:choose>
              </div>
              <div class="field ${not empty errors.email ? 'err' : ''}">
                <label>Email <span class="req">*</span></label>
                <input class="input" type="email" name="email" maxlength="100" value="<c:out value='${form.email}'/>">
                <c:if test="${not empty errors.email}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.email}"/></div></c:if>
              </div>
              <div class="field ${not empty errors.phone ? 'err' : ''}">
                <label>Số điện thoại <span class="req">*</span></label>
                <input class="input" type="tel" name="phone" maxlength="10" value="<c:out value='${form.phone}'/>">
                <c:if test="${not empty errors.phone}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.phone}"/></div></c:if>
              </div>
              <div class="field">
                <label>Ngày sinh</label>
                <input class="input" type="date" name="birthDate" value="<fmt:formatDate value='${form.birthDate}' pattern='yyyy-MM-dd'/>">
              </div>
              <div class="field">
                <label>Vai trò <span class="req">*</span></label>
                <select class="select" name="role">
                  <option value="CUSTOMER" ${form.role eq 'CUSTOMER' ? 'selected' : ''}>Khách hàng</option>
                  <option value="STAFF"    ${form.role eq 'STAFF'    ? 'selected' : ''}>Nhân viên</option>
                  <option value="ADMIN"    ${form.role eq 'ADMIN'    ? 'selected' : ''}>Quản trị viên</option>
                </select>
              </div>
              <div class="field">
                <label>Trạng thái</label>
                <div style="display:flex;align-items:center;gap:10px;height:44px">
                  <input type="checkbox" name="active" id="stActive" value="1" ${form.status eq 'ACTIVE' ? 'checked' : ''}>
                  <label for="stActive" style="margin:0;font-weight:400;font-size:13.5px">Đang hoạt động</label>
                </div>
                <div class="help">Tài khoản khoá vẫn giữ lại toàn bộ đơn hàng cũ</div>
              </div>
            </div>
            <div class="field" style="margin-bottom:0">
              <label>Địa chỉ</label>
              <textarea class="textarea" name="address" maxlength="200"><c:out value="${form.address}"/></textarea>
            </div>
          </div></div>

          <div style="display:flex;flex-direction:column;gap:18px">
            <div class="panel"><div class="panel-head"><h3>Mật khẩu</h3></div><div class="panel-pad">
              <p style="font-size:13px;color:var(--graphite);margin:0 0 12px">
                ${isNew ? 'Đặt mật khẩu ban đầu cho tài khoản.' : 'Để trống nếu bạn không muốn đổi mật khẩu của người dùng này.'}
              </p>
              <div class="field ${not empty errors.password ? 'err' : ''}">
                <label>
                  <c:choose>
                    <c:when test="${isNew}">Mật khẩu <span class="req">*</span></c:when>
                    <c:otherwise>Mật khẩu mới</c:otherwise>
                  </c:choose>
                </label>
                <input class="input" type="password" name="password" placeholder="Từ 8 ký tự">
                <c:if test="${not empty errors.password}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.password}"/></div></c:if>
              </div>
              <div class="field" style="margin-bottom:0">
                <label>Nhập lại mật khẩu</label>
                <input class="input" type="password" name="confirmPassword">
              </div>
            </div></div>

            <c:if test="${not isNew}">
              <div class="panel"><div class="panel-head"><h3>Lịch sử</h3></div><div class="panel-pad">
                <dl class="kv">
                  <dt>Ngày tạo</dt><dd><c:out value="${stats.createdAtLabel}"/></dd>
                  <dt>Đăng nhập gần nhất</dt><dd><c:out value="${stats.lastLoginLabel}"/></dd>
                  <dt>Số đơn đã mua</dt><dd>${stats.orderCount} đơn ·
                    <fmt:formatNumber value="${stats.orderTotal}" type="number" maxFractionDigits="0"/> ₫</dd>
                </dl>
              </div></div>
            </c:if>

            <div class="note-box"><b>Quy tắc dùng chung:</b> nhân viên mở đúng màn hình này nhưng ô Vai trò và
              Trạng thái bị ẩn — phân quyền quyết định hiển thị, không tạo màn hình riêng.</div>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>
</body>
</html>
