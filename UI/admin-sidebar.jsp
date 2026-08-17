<%--
  admin-sidebar.jsp — menu trái dùng chung cho cả quản trị viên và nhân viên.
  Một source duy nhất, khác nhau ở chỗ ẩn hiện mục theo vai trò (rule 9).

  Cách dùng:
      <c:set var="activeAdmin" value="products"/>
      <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  Biến cần có:
      activeAdmin : "dashboard" | "users" | "categories" | "products"
                    | "promotions" | "orders" | "reports"
      sessionScope.currentUser.role : "ADMIN" | "STAFF"
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx"     value="${pageContext.request.contextPath}"/>
<c:set var="isAdmin" value="${sessionScope.currentUser.role eq 'ADMIN'}"/>

<aside class="adm-side">
  <div class="brand">
    <svg width="24" height="24" style="color:var(--titan)"><use href="#logo-halo"/></svg>
    <div>
      <div class="wm">HALO</div>
      <small>${isAdmin ? 'TRANG QUẢN TRỊ' : 'TRANG NHÂN VIÊN'}</small>
    </div>
  </div>

  <div class="grp">Tổng quan</div>
  <a class="${activeAdmin eq 'dashboard' ? 'on' : ''}" href="${ctx}/admin/dashboard">
    <svg width="17" height="17"><use href="#i-chart"/></svg>Dashboard
  </a>

  <%-- chỉ quản trị viên mới sửa được dữ liệu nền --%>
  <c:if test="${isAdmin}">
    <div class="grp">Dữ liệu nền</div>
    <a class="${activeAdmin eq 'users' ? 'on' : ''}" href="${ctx}/admin/users">
      <svg width="17" height="17"><use href="#i-user"/></svg>Người dùng
    </a>
    <a class="${activeAdmin eq 'categories' ? 'on' : ''}" href="${ctx}/admin/categories">
      <svg width="17" height="17"><use href="#i-grid"/></svg>Danh mục
    </a>
  </c:if>

  <c:if test="${not isAdmin}"><div class="grp">Tra cứu</div></c:if>
  <a class="${activeAdmin eq 'products' ? 'on' : ''}" href="${ctx}/admin/products">
    <svg width="17" height="17"><use href="#i-box"/></svg>Sản phẩm
  </a>
  <c:if test="${isAdmin}">
    <a class="${activeAdmin eq 'promotions' ? 'on' : ''}" href="${ctx}/admin/promotions">
      <svg width="17" height="17"><use href="#i-tag"/></svg>Khuyến mãi
    </a>
  </c:if>

  <div class="grp">Bán hàng</div>
  <a class="${activeAdmin eq 'orders' ? 'on' : ''}" href="${ctx}/admin/orders">
    <svg width="17" height="17"><use href="#i-truck"/></svg>Đơn hàng
  </a>
  <c:if test="${isAdmin}">
    <a class="${activeAdmin eq 'reports' ? 'on' : ''}" href="${ctx}/admin/reports">
      <svg width="17" height="17"><use href="#i-chart"/></svg>Báo cáo doanh thu
    </a>
  </c:if>
</aside>
