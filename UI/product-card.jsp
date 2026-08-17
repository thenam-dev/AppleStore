<%--
  product-card.jsp — thẻ sản phẩm dùng chung cho trang chủ, danh sách,
  sản phẩm liên quan và trang yêu thích (rule 9: cùng UI thì dùng chung source).

  Cách dùng:
      <div class="p-grid">
        <c:forEach var="p" items="${products}">
          <c:set var="card" value="${p}" scope="request"/>
          <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
        </c:forEach>
      </div>

  Bean Product cần có getter:
      id, name, subtitle, price, oldPrice, imageUrl, stock, status, iconKey
      - subtitle : dòng phụ, ví dụ "Titan sa mạc"
      - oldPrice : giá gạch ngang, để null nếu không giảm
      - status   : "ACTIVE" | "INACTIVE"
      - iconKey  : "d-phone" | "d-mac" | "d-pad" | "d-watch" | "d-pods" | "d-acc"
                   dùng khi chưa có ảnh thật trong CSDL
  Biến phụ (không bắt buộc):
      showAddToCart : true thì hiện nút thêm giỏ ở cuối thẻ (dùng cho trang yêu thích)
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="soldOut" value="${card.stock le 0 or card.status eq 'INACTIVE'}"/>

<div class="p-card ${soldOut ? 'sold-out' : ''}">

  <%-- nhãn góc trái: hết hàng hoặc phần trăm giảm --%>
  <c:choose>
    <c:when test="${soldOut}">
      <span class="flag badge off">Hết hàng</span>
    </c:when>
    <c:when test="${not empty card.oldPrice and card.oldPrice > card.price}">
      <fmt:parseNumber var="pct" integerOnly="true"
                       value="${(card.oldPrice - card.price) * 100 / card.oldPrice}"/>
      <span class="flag badge dan">-${pct}%</span>
    </c:when>
  </c:choose>

  <%-- yêu thích: POST vì có thay đổi dữ liệu (rule 7) --%>
  <form class="inline-form" method="post" action="${ctx}/wishlist/toggle">
    <input type="hidden" name="productId" value="${card.id}">
    <button type="submit" class="fav" title="Lưu vào yêu thích">
      <svg width="15" height="15"><use href="#i-heart"/></svg>
    </button>
  </form>

  <a href="${ctx}/product?id=${card.id}">
    <div class="shot">
      <c:choose>
        <c:when test="${not empty card.imageUrl}">
          <img src="${ctx}/uploads/${card.imageUrl}" alt="<c:out value='${card.name}'/>" loading="lazy">
        </c:when>
        <c:otherwise>
          <svg style="color:#5B6472"><use href="#${empty card.iconKey ? 'd-acc' : card.iconKey}"/></svg>
        </c:otherwise>
      </c:choose>
    </div>

    <div class="name"><c:out value="${card.name}"/></div>
    <div class="meta">
      <c:out value="${card.subtitle}"/>
      <c:if test="${not soldOut and card.stock le 5}"> · Còn ${card.stock} máy</c:if>
    </div>

    <div class="price">
      <fmt:formatNumber value="${card.price}" type="number" maxFractionDigits="0"/> ₫
      <c:if test="${not empty card.oldPrice and card.oldPrice > card.price}">
        <span class="was"><fmt:formatNumber value="${card.oldPrice}" type="number" maxFractionDigits="0"/> ₫</span>
      </c:if>
    </div>
  </a>

  <c:if test="${showAddToCart}">
    <c:choose>
      <c:when test="${soldOut}">
        <button class="btn sm block quiet" disabled>Hết hàng</button>
      </c:when>
      <c:otherwise>
        <form method="post" action="${ctx}/cart/add">
          <input type="hidden" name="productId" value="${card.id}">
          <input type="hidden" name="quantity" value="1">
          <button type="submit" class="btn sm block" style="margin-top:12px">Thêm vào giỏ</button>
        </form>
      </c:otherwise>
    </c:choose>
  </c:if>
</div>
