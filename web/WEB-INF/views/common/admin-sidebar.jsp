<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activeItem" value="${not empty activeAdmin ? activeAdmin : requestScope.adminSidebarActive}" />
<c:set var="viewer" value="${not empty sessionScope.user ? sessionScope.user : (not empty sessionScope.currentUser ? sessionScope.currentUser : sessionScope.loggedInUser)}" />
<c:set var="isAdmin" value="${viewer.role eq 'ADMIN'}" />
<c:set var="isSaleStaff" value="${viewer.role eq 'SALE_STAFF'}" />

<aside class="adm-side">
  <div class="brand">
    <svg width="24" height="24" style="color:var(--titan)"><use href="#logo-halo" /></svg>
    <div>
      <div class="wm">HALO</div>
      <small>${isAdmin ? 'TRANG QUẢN TRỊ' : isSaleStaff ? 'TRANG NHÂN VIÊN' : 'KHU VỰC NỘI BỘ'}</small>
    </div>
  </div>

  <div class="home-action">
    <a class="home-link" href="${ctx}/home">
      <svg width="17" height="17"><use href="#i-home" /></svg>Về trang chủ
    </a>
  </div>

  <div class="grp">Tổng quan</div>
  <a class="${activeItem eq 'dashboard' ? 'on' : ''}" href="${ctx}/admin/dashboard">
    <svg width="17" height="17"><use href="#i-chart" /></svg>Tổng quan
  </a>

  <c:if test="${isAdmin}">
    <div class="grp">Danh mục &amp; sản phẩm</div>
    <a class="${activeItem eq 'products' ? 'on' : ''}" href="${ctx}/admin/products">
      <svg width="17" height="17"><use href="#i-box" /></svg>Sản phẩm
    </a>
    <a class="${activeItem eq 'categories' ? 'on' : ''}" href="${ctx}/admin/categories">
      <svg width="17" height="17"><use href="#i-grid" /></svg>Danh mục
    </a>

    <div class="grp">Quản trị</div>
    <a class="${activeItem eq 'users' ? 'on' : ''}" href="${ctx}/admin/users">
      <svg width="17" height="17"><use href="#i-user" /></svg>Người dùng
    </a>
    <a class="${activeItem eq 'promotions' ? 'on' : ''}" href="${ctx}/admin/promotions">
      <svg width="17" height="17"><use href="#i-tag" /></svg>Khuyến mãi
    </a>
  </c:if>

  <div class="grp">Tài khoản</div>
  <a href="${ctx}/logout">
    <svg width="17" height="17"><use href="#i-logout" /></svg>Đăng xuất
  </a>
</aside>
