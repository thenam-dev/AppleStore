<%--
  account.jsp — hồ sơ của tôi.
  Servlet cần set: user{fullName,phone,email,birthDate,gender,avatarUrl}
                    defaultAddress{label,fullAddress,receiverName,phone}
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Hồ sơ của tôi · HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<c:set var="activeMenu" value="home"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div style="display:grid;grid-template-columns:240px 1fr;min-height:520px">
  <c:set var="activeAccount" value="profile"/>
  <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>

  <div style="padding:24px;display:flex;flex-direction:column;gap:18px;background:var(--porcelain)">
    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

    <div class="panel">
      <div class="panel-head"><h3>Thông tin cá nhân</h3></div>
      <form method="post" action="${ctx}/account/profile">
        <div class="panel-pad">
          <div class="grid-2">
            <div class="field ${not empty errors.fullName ? 'err' : ''}">
              <label>Họ và tên <span class="req">*</span></label>
              <input class="input" type="text" name="fullName" maxlength="100" value="<c:out value='${user.fullName}'/>">
              <c:if test="${not empty errors.fullName}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.fullName}"/></div></c:if>
            </div>
            <div class="field ${not empty errors.phone ? 'err' : ''}">
              <label>Số điện thoại <span class="req">*</span></label>
              <input class="input" type="tel" name="phone" maxlength="10" value="<c:out value='${user.phone}'/>">
              <c:if test="${not empty errors.phone}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.phone}"/></div></c:if>
            </div>
            <div class="field">
              <label>Email</label>
              <input class="input" type="email" value="<c:out value='${user.email}'/>" disabled style="background:#F6F7F8;color:var(--ash)">
              <div class="help">Email dùng để đăng nhập nên không sửa được</div>
            </div>
            <div class="field">
              <label>Ngày sinh</label>
              <input class="input" type="date" name="birthDate" value="<fmt:formatDate value='${user.birthDate}' pattern='yyyy-MM-dd'/>">
            </div>
            <div class="field">
              <label>Giới tính</label>
              <select class="select" name="gender">
                <option value="MALE"   ${user.gender eq 'MALE'   ? 'selected' : ''}>Nam</option>
                <option value="FEMALE" ${user.gender eq 'FEMALE' ? 'selected' : ''}>Nữ</option>
                <option value="OTHER"  ${user.gender eq 'OTHER'  ? 'selected' : ''}>Không muốn nêu</option>
              </select>
            </div>
            <div class="field">
              <label>Ảnh đại diện</label>
              <div style="display:flex;gap:10px;align-items:center">
                <span class="av" style="width:44px;height:44px"><c:out value="${sessionScope.currentUser.initials}"/></span>
                <input type="file" name="avatar" accept="image/png,image/jpeg" class="sr-only" id="avt">
                <label for="avt" class="btn ghost sm" style="cursor:pointer">Chọn ảnh</label>
              </div>
              <div class="help">JPG hoặc PNG, tối đa 2MB</div>
            </div>
          </div>
        </div>
        <div class="panel-pad" style="border-top:1px solid var(--line);padding-top:16px">
          <button type="submit" class="btn sm">Lưu thay đổi</button>
        </div>
      </form>
    </div>

    <div class="panel">
      <div class="panel-head"><h3>Địa chỉ mặc định</h3><div class="r"><a class="btn ghost sm" href="${ctx}/account/addresses/new">Thêm địa chỉ</a></div></div>
      <div class="panel-pad">
        <c:choose>
          <c:when test="${empty defaultAddress}">
            <p style="color:var(--ash);font-size:13.5px">Bạn chưa lưu địa chỉ nào.</p>
          </c:when>
          <c:otherwise>
            <div style="display:flex;gap:14px;align-items:flex-start;border:1px solid var(--ink);border-radius:var(--r-sm);padding:14px">
              <svg width="18" height="18" style="margin-top:2px"><use href="#i-truck"/></svg>
              <div style="flex:1;font-size:13.5px">
                <b><c:out value="${defaultAddress.label}"/></b> <span class="badge ok" style="margin-left:6px">Mặc định</span>
                <div style="color:var(--graphite);margin-top:4px">
                  <c:out value="${defaultAddress.fullAddress}"/><br>
                  <c:out value="${defaultAddress.receiverName}"/> · <c:out value="${defaultAddress.phone}"/>
                </div>
              </div>
              <a class="btn xs quiet" href="${ctx}/account/addresses/edit?id=${defaultAddress.id}">Sửa</a>
            </div>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
