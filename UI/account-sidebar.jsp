<%--
  account-sidebar.jsp — menu trái dùng chung cho account / orders / wishlist.
  Cách dùng:
      <c:set var="activeAccount" value="profile"/>
      <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>
  activeAccount: "profile" | "orders" | "wishlist" | "coupons" | "address" | "password"
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<aside style="border-right:1px solid var(--line);padding:22px 0">
  <div style="display:flex;gap:11px;align-items:center;padding:0 20px 18px">
    <span class="av" style="width:42px;height:42px;font-size:15px"><c:out value="${sessionScope.currentUser.initials}"/></span>
    <div>
      <b style="font-size:13.5px"><c:out value="${sessionScope.currentUser.fullName}"/></b>
      <div class="mono" style="font-size:10px;color:var(--ash)">
        THÀNH VIÊN TỪ <fmt:formatDate value="${sessionScope.currentUser.createdAt}" pattern="yyyy"/>
      </div>
    </div>
  </div>

  <a href="${ctx}/account" style="display:flex;gap:10px;padding:10px 20px;font-size:13.5px;
     border-left:2px solid ${activeAccount eq 'profile' ? 'var(--ink)' : 'transparent'};
     ${activeAccount eq 'profile' ? 'background:#F6F7F8;font-weight:600' : 'color:var(--graphite)'}">
    <svg width="17" height="17"><use href="#i-user"/></svg>Hồ sơ
  </a>
  <a href="${ctx}/account/orders" style="display:flex;gap:10px;padding:10px 20px;font-size:13.5px;
     border-left:2px solid ${activeAccount eq 'orders' ? 'var(--ink)' : 'transparent'};
     ${activeAccount eq 'orders' ? 'background:#F6F7F8;font-weight:600' : 'color:var(--graphite)'}">
    <svg width="17" height="17"><use href="#i-box"/></svg>Đơn hàng của tôi
  </a>
  <a href="${ctx}/wishlist" style="display:flex;gap:10px;padding:10px 20px;font-size:13.5px;
     border-left:2px solid ${activeAccount eq 'wishlist' ? 'var(--ink)' : 'transparent'};
     ${activeAccount eq 'wishlist' ? 'background:#F6F7F8;font-weight:600' : 'color:var(--graphite)'}">
    <svg width="17" height="17"><use href="#i-heart"/></svg>Yêu thích
  </a>
  <a href="${ctx}/account/coupons" style="display:flex;gap:10px;padding:10px 20px;font-size:13.5px;
     border-left:2px solid ${activeAccount eq 'coupons' ? 'var(--ink)' : 'transparent'};
     ${activeAccount eq 'coupons' ? 'background:#F6F7F8;font-weight:600' : 'color:var(--graphite)'}">
    <svg width="17" height="17"><use href="#i-tag"/></svg>Mã giảm giá
  </a>
  <a href="${ctx}/account/addresses" style="display:flex;gap:10px;padding:10px 20px;font-size:13.5px;
     border-left:2px solid ${activeAccount eq 'address' ? 'var(--ink)' : 'transparent'};
     ${activeAccount eq 'address' ? 'background:#F6F7F8;font-weight:600' : 'color:var(--graphite)'}">
    <svg width="17" height="17"><use href="#i-truck"/></svg>Sổ địa chỉ
  </a>
  <a href="${ctx}/account/password" style="display:flex;gap:10px;padding:10px 20px;font-size:13.5px;
     border-left:2px solid ${activeAccount eq 'password' ? 'var(--ink)' : 'transparent'};
     ${activeAccount eq 'password' ? 'background:#F6F7F8;font-weight:600' : 'color:var(--graphite)'}">
    <svg width="17" height="17"><use href="#i-lock"/></svg>Đổi mật khẩu
  </a>

  <form method="post" action="${ctx}/logout" style="margin-top:10px">
    <button type="submit" style="display:flex;gap:10px;padding:10px 20px;font-size:13.5px;
      border:0;background:none;color:var(--danger);width:100%;text-align:left;cursor:pointer">Đăng xuất</button>
  </form>
</aside>
