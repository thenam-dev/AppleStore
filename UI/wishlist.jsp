<%--
  wishlist.jsp — sản phẩm yêu thích.
  Servlet cần set: wishItems : List<Product> (dùng chung bean với product-card.jsp)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Yêu thích · HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<c:set var="activeMenu" value="home"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div style="padding:22px 26px">
  <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

  <div style="display:flex;align-items:flex-end;gap:14px;margin-bottom:18px">
    <h2 style="font-size:24px;text-transform:uppercase">Yêu thích</h2>
    <span style="color:var(--ash);font-size:13px">${fn:length(wishItems)} sản phẩm</span>
    <c:if test="${not empty wishItems}">
      <form method="post" action="${ctx}/wishlist/clear" style="margin-left:auto">
        <button type="submit" class="btn quiet sm">Xoá tất cả</button>
      </form>
    </c:if>
  </div>

  <c:choose>
    <c:when test="${empty wishItems}">
      <div class="empty">
        <div class="ring"><svg width="26" height="26"><use href="#i-heart"/></svg></div>
        <h3>Chưa có sản phẩm yêu thích</h3>
        <p>Bấm biểu tượng trái tim trên sản phẩm bạn thích để lưu lại đây.</p>
        <a class="btn" href="${ctx}/products">Khám phá sản phẩm</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="p-grid">
        <c:forEach var="p" items="${wishItems}">
          <c:set var="card" value="${p}" scope="request"/>
          <c:set var="showAddToCart" value="${true}" scope="request"/>
          <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
