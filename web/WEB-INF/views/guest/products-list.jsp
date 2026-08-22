<%--
  products-list.jsp — danh sách sản phẩm phía khách hàng.
  Servlet (ProductListServlet, /products) forward tới đây với:
    productList : List<Product>{productId,name,categoryId,categoryName,minPrice,
                                 primaryImageUrl,totalStock,featured,variantCount}
    categories  : List<Category>{categoryId,name}
    keyword, categoryId, sort, currentPage, totalPages, totalItems, lowStockThreshold
    errorMsg    : nếu có lỗi khi tải danh sách (fallback vẫn render trang, danh sách rỗng)
  KHÔNG có nút "Thêm vào giỏ" nhanh ở đây vì sản phẩm bắt buộc phải chọn variant
  (màu/dung lượng) trước khi thêm giỏ — việc đó xử lý ở product-detail.jsp.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"  uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><c:out value="${empty keyword ? 'Sản phẩm' : keyword}"/> · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=3">
</head>
<body>

<c:set var="activeMenu" value="${categoryId == 1 ? 'iphone' : categoryId == 2 ? 'ipad' : categoryId == 3 ? 'mac' : categoryId == 4 ? 'watch' : categoryId == 7 ? 'accessory' : ''}" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<nav class="crumb" style="max-width:1280px;margin:0 auto">
  <a href="${ctx}/home">Trang chủ</a><span>/</span>
  <c:choose>
    <c:when test="${not empty keyword}">
      <a href="${ctx}/products">Sản phẩm</a><span>/</span>
      <span style="color:var(--ink)">Kết quả cho "<c:out value="${keyword}"/>"</span>
    </c:when>
    <c:otherwise>
      <span style="color:var(--ink)">Tất cả sản phẩm</span>
    </c:otherwise>
  </c:choose>
</nav>

<div style="padding:14px 26px 0;max-width:1280px;margin:0 auto">
  <h2 style="font-size:26px;text-transform:uppercase">Danh mục thiết bị Apple</h2>
  <p style="color:var(--ash);font-size:13.5px;margin:6px 0 0">${totalItems} sản phẩm</p>
</div>

<div style="max-width:1280px;margin:0 auto;padding:0 26px">
  <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
</div>

<%-- Bộ lọc: dùng GET để giữ được đường dẫn khi chia sẻ và khi bấm quay lại.
     .toolbar giữ nguyên full-bleed (nền + viền) - nội dung bọc trong 1 div con
     canh giữa max-width, không đặt max-width thẳng lên <form> (form vẫn giữ
     display:flex của .toolbar, nhưng giờ chỉ còn đúng 1 div con nên vô hại). --%>
<form class="toolbar" method="get" action="${ctx}/products" style="margin-top:14px;border-top:1px solid var(--line)">
  <div style="display:flex;gap:10px;align-items:center;flex-wrap:wrap;max-width:1280px;margin:0 auto;width:100%">
    <div class="search">
      <svg width="17" height="17"><use href="#i-search"/></svg>
      <label class="sr-only" for="kw">Tìm sản phẩm</label>
      <input id="kw" class="input" type="text" name="keyword" maxlength="100"
             value="<c:out value='${keyword}'/>" placeholder="Tìm theo tên sản phẩm">
    </div>

    <label class="sr-only" for="cat">Danh mục</label>
    <select id="cat" class="select" name="categoryId">
      <option value="">Tất cả danh mục</option>
      <c:forEach var="cat" items="${categories}">
        <option value="${cat.categoryId}" ${categoryId == cat.categoryId ? 'selected' : ''}><c:out value="${cat.name}"/></option>
      </c:forEach>
    </select>

    <label class="sr-only" for="srt">Sắp xếp</label>
    <select id="srt" class="select" name="sort">
      <option value="featured"     ${sort eq 'featured'     ? 'selected' : ''}>Nổi bật</option>
      <option value="newest"       ${sort eq 'newest'       ? 'selected' : ''}>Mới nhất</option>
      <option value="best-selling" ${sort eq 'best-selling' ? 'selected' : ''}>Bán chạy</option>
      <option value="price-asc"    ${sort eq 'price-asc'    ? 'selected' : ''}>Giá thấp đến cao</option>
      <option value="price-desc"   ${sort eq 'price-desc'   ? 'selected' : ''}>Giá cao đến thấp</option>
    </select>

    <input type="hidden" name="page" value="1">
    <button type="submit" class="btn sm">Áp dụng</button>
    <a class="btn quiet sm" href="${ctx}/products">Xoá lọc</a>
  </div>
</form>

<div style="padding:20px;max-width:1280px;margin:0 auto">
  <c:choose>
    <c:when test="${empty productList}">
      <div class="empty">
        <div class="ring"><svg width="26" height="26"><use href="#i-search"/></svg></div>
        <h3>Không có sản phẩm nào khớp</h3>
        <p>
          <c:if test="${not empty keyword}">Từ khoá "<c:out value="${keyword}"/>" không có kết quả. </c:if>
          Thử bỏ bớt bộ lọc hoặc tìm bằng tên ngắn hơn.
        </p>
        <a class="btn ghost" href="${ctx}/products">Xoá bộ lọc</a>
      </div>
    </c:when>
    <c:otherwise>
      <div class="p-grid">
        <c:forEach var="p" items="${productList}">
          <c:set var="card" value="${p}" scope="request"/>
          <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<%-- phân trang: giữ nguyên bộ lọc đang áp dụng trên mỗi liên kết trang --%>
<c:if test="${not empty productList}">
  <c:url var="filterQueryUrl" value="">
    <c:param name="keyword" value="${keyword}"/>
    <c:param name="categoryId" value="${categoryId}"/>
    <c:param name="sort" value="${sort}"/>
  </c:url>
  <c:set var="filterQuery" value="&${fn:substringAfter(filterQueryUrl, '?')}"/>
  <c:set var="pageUrl" value="${ctx}/products"/>
  <c:set var="itemLabel" value="sản phẩm"/>
  <div style="max-width:1280px;margin:0 auto">
    <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
  </div>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
