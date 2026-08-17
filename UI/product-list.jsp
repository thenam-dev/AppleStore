<%--
  product-list.jsp — trang danh sách sản phẩm phía khách hàng.
  Đây là bản mẫu để copy sang các trang list khác: đủ tìm kiếm, lọc,
  sắp xếp, phân trang và trạng thái rỗng (rule 8). Không có scriptlet.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn"  uri="http://java.sun.com/jsp/jstl/functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="${empty categoryName ? 'Sản phẩm' : categoryName} · HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<nav class="crumb">
  <a href="${ctx}/home">Trang chủ</a><span>/</span>
  <c:choose>
    <c:when test="${not empty keyword}">
      <a href="${ctx}/products">Sản phẩm</a><span>/</span>
      <span style="color:var(--ink)">Kết quả cho “<c:out value="${keyword}"/>”</span>
    </c:when>
    <c:otherwise>
      <span style="color:var(--ink)"><c:out value="${empty categoryName ? 'Tất cả sản phẩm' : categoryName}"/></span>
    </c:otherwise>
  </c:choose>
</nav>

<div style="padding:14px 26px 0">
  <h2 style="font-size:28px;text-transform:uppercase">
    <c:out value="${empty categoryName ? 'Tất cả sản phẩm' : categoryName}"/>
  </h2>
  <p style="color:var(--ash);font-size:13.5px;margin:6px 0 0">${totalItems} sản phẩm</p>
</div>

<%-- Bộ lọc: dùng GET để giữ được đường dẫn khi chia sẻ và khi bấm quay lại --%>
<form class="toolbar" method="get" action="${ctx}/products" style="margin-top:18px;border-top:1px solid var(--line)">
  <div class="search">
    <svg width="17" height="17"><use href="#i-search"/></svg>
    <label class="sr-only" for="kw">Tìm sản phẩm</label>
    <input id="kw" class="input" type="text" name="keyword" maxlength="100"
           value="<c:out value='${keyword}'/>" placeholder="Tìm theo tên sản phẩm">
  </div>

  <label class="sr-only" for="cat">Danh mục</label>
  <select id="cat" class="select" name="categoryId">
    <option value="">Tất cả dòng máy</option>
    <c:forEach var="cat" items="${categories}">
      <option value="${cat.id}" ${categoryId == cat.id ? 'selected' : ''}><c:out value="${cat.name}"/></option>
    </c:forEach>
  </select>

  <label class="sr-only" for="prc">Khoảng giá</label>
  <select id="prc" class="select" name="priceRange">
    <option value="">Mọi mức giá</option>
    <option value="0-10"  ${priceRange eq '0-10'  ? 'selected' : ''}>Dưới 10 triệu</option>
    <option value="10-20" ${priceRange eq '10-20' ? 'selected' : ''}>10 – 20 triệu</option>
    <option value="20-40" ${priceRange eq '20-40' ? 'selected' : ''}>20 – 40 triệu</option>
    <option value="40-"   ${priceRange eq '40-'   ? 'selected' : ''}>Trên 40 triệu</option>
  </select>

  <label class="sr-only" for="srt">Sắp xếp</label>
  <select id="srt" class="select" name="sort">
    <option value="newest"     ${sort eq 'newest'     ? 'selected' : ''}>Mới nhất</option>
    <option value="price_asc"  ${sort eq 'price_asc'  ? 'selected' : ''}>Giá thấp đến cao</option>
    <option value="price_desc" ${sort eq 'price_desc' ? 'selected' : ''}>Giá cao đến thấp</option>
    <option value="best_sell"  ${sort eq 'best_sell'  ? 'selected' : ''}>Bán chạy</option>
  </select>

  <%-- luôn về trang 1 khi đổi bộ lọc --%>
  <input type="hidden" name="page" value="1">
  <button type="submit" class="btn sm">Áp dụng</button>
  <a class="btn quiet sm" href="${ctx}/products">Xoá lọc</a>
</form>

<div style="padding:20px">
  <c:choose>
    <c:when test="${empty products}">
      <%-- trạng thái rỗng: nói rõ bước tiếp theo (rule 8) --%>
      <div class="empty">
        <div class="ring"><svg width="26" height="26"><use href="#i-search"/></svg></div>
        <h3>Không có sản phẩm nào khớp</h3>
        <p>
          <c:if test="${not empty keyword}">Từ khoá “<c:out value="${keyword}"/>” không có kết quả. </c:if>
          Thử bỏ bớt bộ lọc hoặc tìm bằng tên ngắn hơn.
        </p>
        <a class="btn ghost" href="${ctx}/products">Xoá bộ lọc</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="p-grid">
        <c:forEach var="p" items="${products}">
          <c:set var="card" value="${p}" scope="request"/>
          <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<c:if test="${not empty products}">
  <div style="border-top:1px solid var(--line)">
    <c:set var="pageUrl"   value="${ctx}/products"/>
    <c:set var="itemLabel" value="sản phẩm"/>
    <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
  </div>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
