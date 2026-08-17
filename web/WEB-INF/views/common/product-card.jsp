<%--
  product-card.jsp — thẻ sản phẩm dùng chung cho trang chủ, danh sách sản phẩm
  và sản phẩm liên quan (rule 9: cùng UI thì dùng chung source).

  Cách dùng:
      <div class="p-grid">
        <c:forEach var="p" items="${productList}">
          <c:set var="card" value="${p}" scope="request"/>
          <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
        </c:forEach>
      </div>

  Bean model.entity.catalog.Product cần có getter:
      productId, name, categoryId, categoryName, minPrice, primaryImageUrl,
      totalStock, featured, variantCount, soldQuantity
  Biến phụ (không bắt buộc, PHẢI set scope="request" như "card" ở trên thì include mới thấy):
      cardBadge : chữ hiện ở nhãn góc trái (mặc định: "Nổi bật" nếu card.featured)
      cardMeta  : dòng phụ dưới tên sản phẩm (mặc định: categoryName)
      File này tự xoá 2 biến trên khỏi request sau khi dùng nên forEach lặp lại không bị dính giá trị cũ.
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="soldOut" value="${card.totalStock <= 0}"/>
<c:set var="pIcon" value="${card.categoryId == 1 ? 'd-phone' : card.categoryId == 2 ? 'd-pad' : card.categoryId == 3 ? 'd-mac' : card.categoryId == 4 ? 'd-watch' : card.categoryId == 5 ? 'd-pods' : 'd-acc'}"/>

<a class="p-card ${soldOut ? 'sold-out' : ''}" href="${ctx}/product?id=${card.productId}">
  <c:choose>
    <c:when test="${soldOut}"><span class="flag badge off">Hết hàng</span></c:when>
    <c:when test="${not empty cardBadge}"><span class="flag badge info"><c:out value="${cardBadge}"/></span></c:when>
    <c:when test="${card.featured}"><span class="flag badge dan">Nổi bật</span></c:when>
  </c:choose>

  <div class="shot">
    <c:choose>
      <c:when test="${not empty card.primaryImageUrl}">
        <img src="${ctx}/${card.primaryImageUrl}" alt="<c:out value='${card.name}'/>" loading="lazy">
      </c:when>
      <c:otherwise><svg style="color:#5B6472"><use href="#${pIcon}"/></svg></c:otherwise>
    </c:choose>
  </div>

  <div class="name"><c:out value="${card.name}"/></div>
  <div class="meta">
    <c:choose>
      <c:when test="${not empty cardMeta}"><c:out value="${cardMeta}"/></c:when>
      <c:otherwise><c:out value="${card.categoryName}"/></c:otherwise>
    </c:choose>
    <c:if test="${not soldOut and card.totalStock <= 5}"> · Còn ${card.totalStock} máy</c:if>
  </div>

  <div class="price">
    <c:if test="${card.variantCount > 1}">Từ </c:if>
    <fmt:formatNumber value="${card.minPrice}" type="number" maxFractionDigits="0"/> ₫
  </div>
</a>

<c:remove var="cardBadge" scope="request"/>
<c:remove var="cardMeta" scope="request"/>
