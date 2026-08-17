<%--
  product-detail.jsp — chi tiết sản phẩm.
  Servlet cần set:
    product       : Product (id,name,sku,price,oldPrice,stock,shortDesc,specs=Map,iconKey,images=List<String>)
    colors        : List<String> mã màu hex, selectedColor
    variants      : List<Variant>{label, extraPrice, inStock}
    reviews       : List<Review>{avatarInitials,name,rating,date,content}
    ratingAvg, ratingCount
    relatedProducts : List<Product>
    errors, form  : nếu vừa submit thêm giỏ lỗi (ví dụ chưa chọn màu)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="${product.name} · HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<c:set var="activeMenu" value="${product.categorySlug}"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<nav class="crumb">
  <a href="${ctx}/home">Trang chủ</a><span>/</span>
  <a href="${ctx}/products?categoryId=${product.categoryId}"><c:out value="${product.categoryName}"/></a><span>/</span>
  <span style="color:var(--ink)"><c:out value="${product.name}"/></span>
</nav>

<jsp:include page="/WEB-INF/views/common/flash.jsp"/>

<div style="padding:20px 26px 30px;display:grid;grid-template-columns:1.05fr .95fr;gap:34px">

  <div>
    <div class="shot dark" style="aspect-ratio:4/3">
      <c:choose>
        <c:when test="${not empty product.images}">
          <img src="${ctx}/uploads/${product.images[0]}" alt="<c:out value='${product.name}'/>">
        </c:when>
        <c:otherwise><svg style="color:var(--titan);width:34%"><use href="#${empty product.iconKey ? 'd-phone' : product.iconKey}"/></svg></c:otherwise>
      </c:choose>
    </div>
    <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:10px;margin-top:10px">
      <c:forEach var="img" items="${product.images}" varStatus="st" begin="0" end="3">
        <div class="shot" style="${st.first ? 'border:1px solid var(--ink)' : ''}">
          <img src="${ctx}/uploads/${img}" alt="">
        </div>
      </c:forEach>
    </div>
  </div>

  <div>
    <div style="display:flex;gap:8px;align-items:center;margin-bottom:12px">
      <c:choose>
        <c:when test="${product.stock > 0}"><span class="badge ok">Còn ${product.stock} máy</span></c:when>
        <c:otherwise><span class="badge off">Hết hàng</span></c:otherwise>
      </c:choose>
      <span class="mono" style="font-size:10.5px;letter-spacing:.14em;color:var(--ash)"><c:out value="${product.sku}"/></span>
    </div>

    <h2 style="font-size:32px;text-transform:uppercase"><c:out value="${product.name}"/></h2>

    <div style="display:flex;align-items:baseline;gap:12px;margin:16px 0 4px">
      <span style="font-family:var(--display);font-stretch:114%;font-weight:700;font-size:30px">
        <fmt:formatNumber value="${product.price}" type="number" maxFractionDigits="0"/> ₫
      </span>
      <c:if test="${not empty product.oldPrice and product.oldPrice > product.price}">
        <span style="text-decoration:line-through;color:var(--ash);font-size:15px">
          <fmt:formatNumber value="${product.oldPrice}" type="number" maxFractionDigits="0"/> ₫
        </span>
        <fmt:parseNumber var="pct" integerOnly="true" value="${(product.oldPrice - product.price) * 100 / product.oldPrice}"/>
        <span class="badge dan">Giảm ${pct}%</span>
      </c:if>
    </div>
    <p style="color:var(--graphite);font-size:13.5px;margin:0 0 20px">
      Trả góp từ <fmt:formatNumber value="${product.price / 12}" type="number" maxFractionDigits="0"/> ₫ / tháng trong 12 tháng, lãi suất 0%.
    </p>

    <%-- Thêm giỏ hàng: POST, có kiểm tra chọn màu/dung lượng ở server --%>
    <form method="post" action="${ctx}/cart/add">
      <input type="hidden" name="productId" value="${product.id}">

      <c:if test="${not empty colors}">
        <div style="margin-bottom:18px">
          <div class="t-eyebrow" style="margin-bottom:9px">Màu sắc</div>
          <div style="display:flex;gap:9px">
            <c:forEach var="c" items="${colors}">
              <label>
                <input type="radio" name="color" value="${c}" class="sr-only" ${c eq selectedColor ? 'checked' : ''}>
                <span style="display:inline-block;width:32px;height:32px;border-radius:50%;background:${c};
                  outline:${c eq selectedColor ? '2px solid var(--ink)' : 'none'};outline-offset:2px;cursor:pointer"></span>
              </label>
            </c:forEach>
          </div>
        </div>
      </c:if>

      <c:if test="${not empty variants}">
        <div style="margin-bottom:22px">
          <div class="t-eyebrow" style="margin-bottom:9px">Dung lượng</div>
          <div style="display:flex;gap:9px;flex-wrap:wrap">
            <c:forEach var="v" items="${variants}">
              <label>
                <input type="radio" name="variant" value="${v.id}" class="sr-only" ${v.selected ? 'checked' : ''} ${v.inStock ? '' : 'disabled'}>
                <span class="btn ghost sm" style="${v.selected ? 'border-color:var(--ink);font-weight:600' : ''};${v.inStock ? '' : 'opacity:.5'}">
                  <c:out value="${v.label}"/><c:if test="${v.extraPrice > 0}"> · +<fmt:formatNumber value="${v.extraPrice}" maxFractionDigits="0"/> ₫</c:if>
                  <c:if test="${not v.inStock}"> · hết hàng</c:if>
                </span>
              </label>
            </c:forEach>
          </div>
        </div>
      </c:if>

      <c:if test="${not empty errors.variant}">
        <div class="err-msg" style="margin-bottom:14px"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.variant}"/></div>
      </c:if>

      <div style="display:flex;gap:10px;align-items:center;margin-bottom:20px">
        <div class="qty">
          <button type="button" aria-label="Giảm số lượng">−</button>
          <input type="number" name="quantity" value="1" min="1" max="${product.stock}" inputmode="numeric">
          <button type="button" aria-label="Tăng số lượng">+</button>
        </div>
        <c:choose>
          <c:when test="${product.stock > 0}">
            <button type="submit" name="action" value="add" class="btn" style="flex:1">Thêm vào giỏ</button>
            <button type="submit" name="action" value="buy" class="btn titan" style="flex:1">Mua ngay</button>
          </c:when>
          <c:otherwise>
            <button type="button" class="btn quiet" style="flex:1" disabled>Hết hàng</button>
          </c:otherwise>
        </c:choose>
      </div>
    </form>

    <form method="post" action="${ctx}/wishlist/toggle" style="display:inline">
      <input type="hidden" name="productId" value="${product.id}">
      <button type="submit" class="icon-btn" style="width:42px;height:42px;border-radius:50%;margin-bottom:20px">
        <svg width="17" height="17"><use href="#i-heart"/></svg>
      </button>
    </form>

    <div class="etch" style="border-radius:var(--r-sm);margin-bottom:18px">
      <span>Bảo hành 12 tháng</span><i class="dot"></i><span>Đổi mới 30 ngày</span><i class="dot"></i><span>Giao 2 giờ</span>
    </div>

    <div class="panel">
      <div class="panel-head"><h3>Thông số kỹ thuật</h3></div>
      <div class="panel-pad">
        <dl class="kv">
          <c:forEach var="s" items="${product.specs}">
            <dt><c:out value="${s.key}"/></dt><dd><c:out value="${s.value}"/></dd>
          </c:forEach>
        </dl>
      </div>
    </div>
  </div>
</div>

<section class="sec" style="border-top:1px solid var(--line)">
  <div class="sec-head"><h3>Đánh giá của khách</h3><a href="${ctx}/product/review?id=${product.id}">Viết đánh giá →</a></div>
  <div style="display:grid;grid-template-columns:220px 1fr;gap:28px">
    <div style="text-align:center;border:1px solid var(--line);border-radius:var(--r-md);padding:22px">
      <div style="font-family:var(--display);font-stretch:114%;font-weight:700;font-size:44px"><fmt:formatNumber value="${ratingAvg}" maxFractionDigits="1"/></div>
      <div style="color:var(--titan);font-size:17px;letter-spacing:3px">★★★★★</div>
      <div style="font-size:12.5px;color:var(--ash);margin-top:6px">${ratingCount} đánh giá</div>
    </div>
    <div>
      <c:choose>
        <c:when test="${empty reviews}">
          <p style="color:var(--ash);font-size:13.5px">Chưa có đánh giá nào. Hãy là người đầu tiên chia sẻ trải nghiệm.</p>
        </c:when>
        <c:otherwise>
          <c:forEach var="rv" items="${reviews}" varStatus="st">
            <div style="${st.last ? '' : 'border-bottom:1px solid var(--line);padding-bottom:14px;margin-bottom:14px'}">
              <div style="display:flex;gap:10px;align-items:center">
                <span class="av"><c:out value="${rv.avatarInitials}"/></span>
                <b style="font-size:13.5px"><c:out value="${rv.name}"/></b>
                <span style="color:var(--titan)">
                  <c:forEach begin="1" end="5" var="i">${i le rv.rating ? '★' : '☆'}</c:forEach>
                </span>
                <span class="mono" style="font-size:10.5px;color:var(--ash);margin-left:auto">
                  <fmt:formatDate value="${rv.date}" pattern="dd/MM/yyyy"/>
                </span>
              </div>
              <p style="margin:8px 0 0;font-size:13.5px;color:var(--graphite)"><c:out value="${rv.content}"/></p>
            </div>
          </c:forEach>
        </c:otherwise>
      </c:choose>
    </div>
  </div>
</section>

<c:if test="${not empty relatedProducts}">
  <section class="sec" style="padding-top:0">
    <div class="sec-head"><h3>Mua kèm phụ kiện</h3></div>
    <div class="p-grid">
      <c:forEach var="p" items="${relatedProducts}">
        <c:set var="card" value="${p}" scope="request"/>
        <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
      </c:forEach>
    </div>
  </section>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
