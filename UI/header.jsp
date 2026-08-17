<%--
  header.jsp — thanh điều hướng của phần khách hàng.
  Cách dùng:
      <c:set var="activeMenu" value="iphone"/>
      <jsp:include page="/WEB-INF/views/common/header.jsp"/>
  Biến servlet cần chuẩn bị trước (rule 5 — JSP không tự tính):
      activeMenu   : "home" | "iphone" | "mac" | "ipad" | "watch" | "accessory" | "promotion"
      keyword      : từ khoá đang tìm, để đổ lại vào ô tìm kiếm
      menuCategories : List<Category> đang bán (nếu muốn menu động)
      sessionScope.cartCount / wishCount : số badge
      sessionScope.currentUser : người đang đăng nhập, null nếu là khách
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<header class="sf-top">
  <div class="etch">
    <span>Giao 2 giờ nội thành</span><i class="dot"></i>
    <span>Trả góp 0%</span><i class="dot"></i>
    <span>Đổi mới 30 ngày</span>
  </div>

  <nav class="sf-nav">
    <a class="sf-logo" href="${ctx}/home">
      <svg width="26" height="26" style="color:var(--titan)"><use href="#logo-halo"/></svg>
      <span class="wm">HALO</span>
    </a>

    <div class="links">
      <a class="${activeMenu eq 'home' ? 'on' : ''}" href="${ctx}/home">Trang chủ</a>
      <c:choose>
        <%-- menu động nếu servlet đẩy xuống danh mục đang bán --%>
        <c:when test="${not empty menuCategories}">
          <c:forEach var="cat" items="${menuCategories}">
            <a class="${activeMenu eq cat.slug ? 'on' : ''}"
               href="${ctx}/products?categoryId=${cat.id}"><c:out value="${cat.name}"/></a>
          </c:forEach>
        </c:when>
        <c:otherwise>
          <a class="${activeMenu eq 'iphone' ? 'on' : ''}" href="${ctx}/products?categoryId=1">iPhone</a>
          <a class="${activeMenu eq 'mac' ? 'on' : ''}" href="${ctx}/products?categoryId=2">Mac</a>
          <a class="${activeMenu eq 'ipad' ? 'on' : ''}" href="${ctx}/products?categoryId=3">iPad</a>
          <a class="${activeMenu eq 'watch' ? 'on' : ''}" href="${ctx}/products?categoryId=4">Watch</a>
          <a class="${activeMenu eq 'accessory' ? 'on' : ''}" href="${ctx}/products?categoryId=5">Phụ kiện</a>
        </c:otherwise>
      </c:choose>
      <a class="${activeMenu eq 'promotion' ? 'on' : ''}" href="${ctx}/promotions">Khuyến mãi</a>
    </div>

    <div class="tools">
      <form class="sf-search" method="get" action="${ctx}/products" role="search">
        <label class="sr-only" for="hdSearch">Tìm sản phẩm</label>
        <svg width="15" height="15"><use href="#i-search"/></svg>
        <input id="hdSearch" type="text" name="keyword" value="<c:out value='${keyword}'/>"
               placeholder="Tìm iPhone, Mac, AirPods…" maxlength="100">
      </form>

      <a class="ic" href="${ctx}/wishlist" title="Yêu thích">
        <svg width="17" height="17"><use href="#i-heart"/></svg>
        <c:if test="${not empty sessionScope.wishCount and sessionScope.wishCount > 0}">
          <span class="dot-n">${sessionScope.wishCount}</span>
        </c:if>
      </a>

      <a class="ic" href="${ctx}/cart" title="Giỏ hàng">
        <svg width="17" height="17"><use href="#i-cart"/></svg>
        <c:if test="${not empty sessionScope.cartCount and sessionScope.cartCount > 0}">
          <span class="dot-n">${sessionScope.cartCount}</span>
        </c:if>
      </a>

      <c:choose>
        <c:when test="${not empty sessionScope.currentUser}">
          <a class="av" href="${ctx}/account" title="<c:out value='${sessionScope.currentUser.fullName}'/>">
            <c:out value="${sessionScope.currentUser.initials}"/>
          </a>
        </c:when>
        <c:otherwise>
          <a class="ic" href="${ctx}/login" title="Đăng nhập">
            <svg width="17" height="17"><use href="#i-user"/></svg>
          </a>
        </c:otherwise>
      </c:choose>
    </div>
  </nav>
</header>
