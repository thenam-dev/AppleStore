<%--
  header.jsp — thanh điều hướng dùng chung cho toàn bộ site (khách + khách hàng đã đăng nhập).
  Cách dùng:
      <c:set var="activeMenu" value="iphone" scope="request"/>  <%-- tuỳ chọn, tô sáng menu đang đứng --%>
      <jsp:include page="/WEB-INF/views/common/header.jsp"/>
  LƯU Ý: c:set phải kèm scope="request" thì jsp:include mới thấy được - mặc định c:set là
  page scope, không lọt qua ranh giới jsp:include (đây từng là bug thực tế, xem lịch sử sửa).
  Biến servlet có thể chuẩn bị trước, không bắt buộc:
      activeMenu           : "home" | "iphone" | "mac" | "ipad" | "watch" | "accessory"
      keyword               : từ khoá đang tìm, để đổ lại vào ô tìm kiếm (đã có sẵn khi ở /products)
      requestScope.cartItemCount : số badge giỏ hàng (CartServlet set khi ở trang /cart)
      sessionScope.user     : User đang đăng nhập (key AppConfig.SESSION_USER), null nếu là khách
  File này tự include icons.jsp nên mọi trang include header.jsp đều dùng được sprite icon.
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<header class="sf-top">
  <div class="etch">
    <span>Giao hàng toàn quốc</span><i class="dot"></i>
    <span>Trả góp 0%</span><i class="dot"></i>
    <span>Bảo hành chính hãng</span>
  </div>

  <nav class="sf-nav">
    <a class="sf-logo" href="${ctx}/home">
      <svg width="26" height="26" style="color:var(--titan)"><use href="#logo-mark"/></svg>
      <span class="wm">AOS · APPLESTORE</span>
    </a>

    <div class="links">
      <a class="${activeMenu eq 'home' ? 'on' : ''}" href="${ctx}/home">Trang chủ</a>
      <a class="${activeMenu eq 'iphone' ? 'on' : ''}" href="${ctx}/products?categoryId=1">iPhone</a>
      <a class="${activeMenu eq 'ipad' ? 'on' : ''}" href="${ctx}/products?categoryId=2">iPad</a>
      <a class="${activeMenu eq 'mac' ? 'on' : ''}" href="${ctx}/products?categoryId=3">Mac</a>
      <a class="${activeMenu eq 'watch' ? 'on' : ''}" href="${ctx}/products?categoryId=4">Apple Watch</a>
      <a class="${activeMenu eq 'accessory' ? 'on' : ''}" href="${ctx}/products?categoryId=7">Phụ kiện</a>
      <a class="${activeMenu eq 'voucher' ? 'on' : ''}" href="${ctx}/vouchers">Khuyến mãi</a>
    </div>

    <div class="tools">
      <form class="sf-search" method="get" action="${ctx}/products" role="search">
        <label class="sr-only" for="hdSearch">Tìm sản phẩm</label>
        <svg width="15" height="15"><use href="#i-search"/></svg>
        <input id="hdSearch" type="text" name="keyword" value="<c:out value='${keyword}'/>"
               placeholder="Tìm iPhone, Mac, iPad…" maxlength="100">
      </form>

      <%-- Nhân viên bán hàng / quản trị: lối tắt vào trang quản trị ngay trên header khách --%>
      <c:if test="${not empty sessionScope.user and (sessionScope.user.role eq 'ADMIN' or sessionScope.user.role eq 'SALE_STAFF')}">
        <a class="btn titan xs" href="${ctx}/admin/dashboard">Vào quản trị</a>
      </c:if>

      <a class="ic" href="${ctx}/cart" title="Giỏ hàng">
        <svg width="17" height="17"><use href="#i-cart"/></svg>
        <c:if test="${not empty requestScope.cartItemCount and requestScope.cartItemCount > 0}">
          <span class="dot-n">${requestScope.cartItemCount}</span>
        </c:if>
      </a>

      <c:choose>
        <c:when test="${not empty sessionScope.user}">
          <c:set var="avatarLetter" value="U"/>
          <c:if test="${not empty sessionScope.user.fullName}">
            <c:set var="avatarLetter" value="${fn:toUpperCase(fn:substring(sessionScope.user.fullName, 0, 1))}"/>
          </c:if>
          <a class="av" href="${ctx}/change-password" title="<c:out value='${sessionScope.user.fullName}'/> · Đổi mật khẩu">
            <c:out value="${avatarLetter}"/>
          </a>
          <a class="ic" href="${ctx}/logout" title="Đăng xuất">
            <svg width="17" height="17"><use href="#i-logout"/></svg>
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
