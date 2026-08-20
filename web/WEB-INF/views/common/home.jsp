<%--
  home.jsp — trang chủ.
  Servlet (HomeServlet) set:
    featuredList, newList, bestSellerList : List<Product>
    {productId,name,description,categoryId,categoryName,minPrice,primaryImageUrl,totalStock,featured,soldQuantity}
  Mọi liên kết sang trang khác đều trỏ qua servlet:
    Danh sách sản phẩm : ${ctx}/products?categoryId=... (không phải /products?category=...)
    Chi tiết sản phẩm  : ${ctx}/product?id={productId}
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>AppleStore · Cửa hàng Apple trực tuyến</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
</head>
<body>

<c:set var="activeMenu" value="home" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<%-- ================= HERO ================= --%>
<section class="hero">
  <div class="container inner">
    <div>
      <span class="kicker">Cửa hàng Apple chính hãng</span>
      <h2>Thiết bị Apple<em>chọn đúng máy, mua trong vài phút</em></h2>
      <div class="rule"></div>
      <p>iPhone, Mac, iPad, Apple Watch và phụ kiện chính hãng — giỏ hàng, mã khuyến mãi
         và thanh toán ngay trên web, không cần gọi điện đặt hàng.</p>

      <form class="hero-search" action="${ctx}/products" method="get" role="search"
            style="display:flex;gap:10px;max-width:420px;margin-bottom:20px">
        <label class="sr-only" for="heroSearch">Tìm sản phẩm</label>
        <input id="heroSearch" class="input" type="text" name="keyword"
               placeholder="Tìm iPhone, Mac, iPad…" style="background:#151A21;border-color:#2A313B;color:#fff">
        <button class="btn titan" type="submit" style="flex-shrink:0">Tìm</button>
      </form>

      <div class="cta">
        <a class="btn titan" href="${ctx}/products">Mua sắm ngay</a>
        <a class="btn ghost" href="${ctx}/vouchers" style="border-color:#2A313B;color:#fff">Xem khuyến mãi</a>
      </div>
    </div>

    <div class="spec-col">
      <dl>
        <dt>Vận chuyển</dt><dd>Miễn phí toàn quốc</dd>
        <dt>Bảo hành</dt><dd>Chính hãng Apple</dd>
        <dt>Đổi trả</dt><dd>Trong 7 ngày</dd>
        <dt>Thanh toán</dt><dd>COD hoặc chuyển khoản</dd>
      </dl>
    </div>
  </div>
</section>

<div class="strip">
  <div><b>Miễn phí vận chuyển</b><span>Cho mọi đơn hàng, toàn quốc</span></div>
  <div><b>Bảo hành chính hãng</b><span>Theo tiêu chuẩn Apple</span></div>
  <div><b>Đổi trả 7 ngày</b><span>Nếu sản phẩm lỗi kỹ thuật</span></div>
  <div><b>Hỗ trợ trả góp 0%</b><span>Qua thẻ tín dụng liên kết</span></div>
</div>

<%-- ================= DANH MỤC ================= --%>
<section class="sec">
  <div class="sec-head"><h3>Khám phá theo danh mục</h3><a href="${ctx}/products">Xem tất cả</a></div>
  <div class="cat-rail">
    <a class="cat" href="${ctx}/products?categoryId=1"><svg width="34" height="34"><use href="#d-phone"/></svg><b>iPhone</b><span>Xem ngay</span></a>
    <a class="cat" href="${ctx}/products?categoryId=2"><svg width="34" height="34"><use href="#d-pad"/></svg><b>iPad</b><span>Xem ngay</span></a>
    <a class="cat" href="${ctx}/products?categoryId=3"><svg width="34" height="34"><use href="#d-mac"/></svg><b>Mac</b><span>Xem ngay</span></a>
    <a class="cat" href="${ctx}/products?categoryId=4"><svg width="34" height="34"><use href="#d-watch"/></svg><b>Apple Watch</b><span>Xem ngay</span></a>
    <a class="cat" href="${ctx}/products?categoryId=5"><svg width="34" height="34"><use href="#d-pods"/></svg><b>AirPods</b><span>Xem ngay</span></a>
    <a class="cat" href="${ctx}/products?categoryId=7"><svg width="34" height="34"><use href="#d-acc"/></svg><b>Phụ kiện</b><span>Xem ngay</span></a>
  </div>
</section>

<%-- ================= SẢN PHẨM NỔI BẬT ================= --%>
<section class="sec" style="background:#FAFBFC">
  <div class="sec-head"><h3>Sản phẩm nổi bật</h3><a href="${ctx}/products">Xem tất cả sản phẩm</a></div>
  <c:choose>
    <c:when test="${empty featuredList}">
      <div class="empty">
        <div class="ring"><svg width="26" height="26"><use href="#i-box"/></svg></div>
        <h3>Chưa có sản phẩm nổi bật</h3>
        <p>Ghé lại sau hoặc xem toàn bộ sản phẩm đang bán.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div class="p-grid-pager" data-page-size="4">
        <div class="p-grid">
          <c:forEach var="p" items="${featuredList}">
            <c:set var="card" value="${p}" scope="request"/>
            <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
          </c:forEach>
        </div>
        <nav class="pages home-pager" aria-label="Phân trang sản phẩm nổi bật"
             style="display:flex;justify-content:center;gap:5px;margin-top:18px"></nav>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<%-- ================= SẢN PHẨM MỚI ================= --%>
<section class="sec">
  <div class="sec-head"><h3>Hàng mới về</h3><a href="${ctx}/products?sort=newest">Xem thêm</a></div>
  <c:choose>
    <c:when test="${empty newList}">
      <div class="empty">
        <div class="ring"><svg width="26" height="26"><use href="#i-box"/></svg></div>
        <h3>Chưa có sản phẩm mới</h3>
      </div>
    </c:when>
    <c:otherwise>
      <div class="p-grid-pager" data-page-size="4">
        <div class="p-grid">
          <c:forEach var="p" items="${newList}">
            <c:set var="card" value="${p}" scope="request"/>
            <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
          </c:forEach>
        </div>
        <nav class="pages home-pager" aria-label="Phân trang hàng mới về"
             style="display:flex;justify-content:center;gap:5px;margin-top:18px"></nav>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<%-- ================= BÁN CHẠY NHẤT ================= --%>
<section class="sec" style="background:#FAFBFC">
  <div class="sec-head"><h3>Bán chạy nhất</h3><a href="${ctx}/products?sort=best-selling">Xem thêm</a></div>
  <c:choose>
    <c:when test="${empty bestSellerList}">
      <div class="empty">
        <div class="ring"><svg width="26" height="26"><use href="#i-box"/></svg></div>
        <h3>Chưa có dữ liệu bán chạy</h3>
      </div>
    </c:when>
    <c:otherwise>
      <div class="p-grid-pager" data-page-size="4">
        <div class="p-grid">
          <c:forEach var="p" items="${bestSellerList}" varStatus="st">
            <c:set var="card" value="${p}" scope="request"/>
            <c:set var="cardBadge" value="#${st.count} bán chạy" scope="request"/>
            <c:set var="cardMeta" value="Đã bán ${p.soldQuantity} máy" scope="request"/>
            <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
          </c:forEach>
        </div>
        <nav class="pages home-pager" aria-label="Phân trang bán chạy nhất"
             style="display:flex;justify-content:center;gap:5px;margin-top:18px"></nav>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<%-- ================= DỊCH VỤ ================= --%>
<section class="sec">
  <div class="sec-head"><h3>Vì sao chọn AppleStore</h3></div>
  <div class="strip" style="border-radius:var(--r-md);border:1px solid var(--line)">
    <div><svg width="20" height="20" style="color:var(--titan);margin-bottom:8px"><use href="#i-truck"/></svg><b>Giao hàng nhanh</b><span>Miễn phí vận chuyển toàn quốc</span></div>
    <div><svg width="20" height="20" style="color:var(--titan);margin-bottom:8px"><use href="#i-lock"/></svg><b>Bảo hành chính hãng</b><span>Theo tiêu chuẩn Apple</span></div>
    <div><svg width="20" height="20" style="color:var(--titan);margin-bottom:8px"><use href="#i-tag"/></svg><b>Giá minh bạch</b><span>Không phụ phí ẩn</span></div>
    <div><svg width="20" height="20" style="color:var(--titan);margin-bottom:8px"><use href="#i-check"/></svg><b>Đổi trả dễ dàng</b><span>Trong vòng 7 ngày</span></div>
  </div>
</section>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<%-- Phân trang phía client cho các khối sản phẩm ở trang chủ (nổi bật/mới/bán
     chạy): mỗi khối .p-grid-pager chia .p-grid con của nó thành các trang
     data-page-size sản phẩm/trang (mặc định 4, đúng số cột của .p-grid),
     dựng nút trang vào .home-pager, tái dùng class .pg/.pg.on/.pg.disabled
     có sẵn (cùng giao diện với phân trang ở /products) - không cần tải lại
     trang, không cần thêm tham số server. Chỉ 1 trang thì ẩn thanh phân trang. --%>
<script>
(function () {
  function buildPager(root) {
    var grid = root.querySelector('.p-grid');
    var nav = root.querySelector('.home-pager');
    if (!grid || !nav) { return; }

    var cards = Array.prototype.slice.call(grid.children);
    var pageSize = parseInt(root.getAttribute('data-page-size'), 10) || 4;
    var totalPages = Math.ceil(cards.length / pageSize);
    if (totalPages <= 1) { return; }

    var current = 1;

    function render() {
      cards.forEach(function (card, idx) {
        var page = Math.floor(idx / pageSize) + 1;
        card.style.display = (page === current) ? '' : 'none';
      });

      nav.innerHTML = '';

      var prev = document.createElement('a');
      prev.href = '#';
      prev.className = 'pg' + (current <= 1 ? ' disabled' : '');
      prev.setAttribute('aria-label', 'Trang trước');
      prev.textContent = '‹';
      prev.addEventListener('click', function (e) {
        e.preventDefault();
        if (current > 1) { current--; render(); }
      });
      nav.appendChild(prev);

      for (var i = 1; i <= totalPages; i++) {
        (function (pageNum) {
          var btn = document.createElement('a');
          btn.href = '#';
          btn.className = 'pg' + (pageNum === current ? ' on' : '');
          btn.textContent = pageNum;
          btn.addEventListener('click', function (e) {
            e.preventDefault();
            current = pageNum;
            render();
          });
          nav.appendChild(btn);
        })(i);
      }

      var next = document.createElement('a');
      next.href = '#';
      next.className = 'pg' + (current >= totalPages ? ' disabled' : '');
      next.setAttribute('aria-label', 'Trang sau');
      next.textContent = '›';
      next.addEventListener('click', function (e) {
        e.preventDefault();
        if (current < totalPages) { current++; render(); }
      });
      nav.appendChild(next);
    }

    render();
  }

  Array.prototype.forEach.call(document.querySelectorAll('.p-grid-pager'), buildPager);
})();
</script>
</body>
</html>
