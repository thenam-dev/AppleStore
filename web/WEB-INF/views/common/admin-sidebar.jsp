<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<c:set var="activeItem" value="${not empty activeAdmin ? activeAdmin : requestScope.adminSidebarActive}" />
<c:set var="viewer" value="${not empty sessionScope.user ? sessionScope.user : (not empty sessionScope.currentUser ? sessionScope.currentUser : sessionScope.loggedInUser)}" />

<%-- Khai báo phân quyền --%>
<c:set var="isAdmin" value="${viewer.role eq 'ADMIN'}" />
<c:set var="isSaleStaff" value="${viewer.role eq 'SALE_STAFF'}" />
<c:set var="isDelivery" value="${viewer.role eq 'DELIVERY'}" />

<aside class="adm-side">
  <div class="brand">
    <svg width="24" height="24" style="color:var(--titan)"><use href="#logo-halo" /></svg>
    <div>
      <div class="wm">HALO</div>
      <small>${isAdmin ? 'TRANG QUẢN TRỊ' : isSaleStaff ? 'TRANG NHÂN VIÊN' : isDelivery ? 'ĐIỀU PHỐI GIAO HÀNG' : 'KHU VỰC'}</small>
    </div>
  </div>
  
  <div class="home-action">
    <a class="home-link" href="${ctx}/home">
      <svg width="17" height="17"><use href="#i-home" /></svg>Về trang chủ
    </a>
  </div>

  <%-- Menu của Admin --%>
  <c:if test="${isAdmin}">
    <div class="grp">Tổng quan</div>
    <a class="${activeItem eq 'dashboard' ? 'on' : ''}" href="${ctx}/admin/dashboard">
      <svg width="17" height="17"><use href="#i-chart" /></svg>Tổng quan
    </a>
    
    <div class="grp">Danh mục &amp; sản phẩm</div>
    <a class="${activeItem eq 'products' ? 'on' : ''}" href="${ctx}/admin/products">
      <svg width="17" height="17"><use href="#i-box" /></svg>Sản phẩm
    </a>
    <a class="${activeItem eq 'categories' ? 'on' : ''}" href="${ctx}/admin/categories">
      <svg width="17" height="17"><use href="#i-grid" /></svg>Danh mục
    </a>
    
    <div class="grp">Quản trị hệ thống</div>
    <a class="${activeItem eq 'users' ? 'on' : ''}" href="${ctx}/admin/users">
      <svg width="17" height="17"><use href="#i-user" /></svg>Người dùng
    </a>
    <a class="${activeItem eq 'promotions' ? 'on' : ''}" href="${ctx}/admin/promotions">
      <svg width="17" height="17"><use href="#i-tag" /></svg>Khuyến mãi
    </a>
  </c:if>

  <%-- Menu của Sale Staff --%>
  <c:if test="${isSaleStaff}">
    <div class="grp">Tổng quan</div>
    <a class="${activeItem eq 'dashboard' ? 'on' : ''}" href="${ctx}/staff/dashboard">
      <svg width="17" height="17"><use href="#i-chart" /></svg>Báo cáo cá nhân
    </a>
  </c:if>

  <%-- Menu của Admin VÀ Sale Staff --%>
  <c:if test="${isAdmin or isSaleStaff}">
    <div class="grp">Kinh doanh</div>
    <a class="${activeItem eq 'orders' ? 'on' : ''}" href="${ctx}/staff/orders">
      <svg width="17" height="17"><use href="#i-box" /></svg>Quản lý Đơn hàng
    </a>
  </c:if>

  <%-- Menu của Delivery (Shipper) --%>
  <c:if test="${isDelivery}">
    <div class="grp">Vận chuyển</div>
    <a class="${activeItem eq 'tasks' ? 'on' : ''}" href="${ctx}/staff/tasks">
      <svg width="17" height="17"><use href="#i-truck" /></svg>Nhiệm vụ giao hàng
    </a>
  </c:if>

  <div class="grp">Tài khoản</div>
  <a href="${ctx}/logout">
    <svg width="17" height="17"><use href="#i-logout" /></svg>Đăng xuất
  </a>
</aside>