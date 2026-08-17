<%--
  promotions.jsp — trang khuyến mãi.
  Servlet cần set:
    banner        : {kicker,title,titleAccent,desc}
    myCoupons     : List<Coupon>{code,statusLabel,statusClass,expiredAtLabel,desc,active}
    saleProducts  : List<Product>
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Khuyến mãi · HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<c:set var="activeMenu" value="promotion"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<section class="hero" style="padding:40px 26px 34px">
  <div style="position:relative;z-index:2">
    <div class="kicker"><c:out value="${banner.kicker}"/></div>
    <h2 style="font-size:44px"><c:out value="${banner.title}"/><em><c:out value="${banner.titleAccent}"/></em></h2>
    <p style="margin-top:14px"><c:out value="${banner.desc}"/></p>
  </div>
</section>

<section class="sec">
  <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
  <div class="sec-head"><h3>Mã giảm giá của bạn</h3></div>
  <c:choose>
    <c:when test="${empty myCoupons}">
      <div class="empty">
        <div class="ring"><svg width="26" height="26"><use href="#i-tag"/></svg></div>
        <h3>Chưa có mã nào cho bạn</h3>
        <p>Đăng nhập hoặc tạo tài khoản để nhận mã giảm giá riêng.</p>
      </div>
    </c:when>
    <c:otherwise>
      <div style="display:grid;grid-template-columns:repeat(3,1fr);gap:14px">
        <c:forEach var="cp" items="${myCoupons}">
          <div class="panel" style="border-left:2px solid ${cp.active ? 'var(--titan)' : 'var(--line)'};${cp.active ? '' : 'opacity:.55'}">
            <div class="panel-pad">
              <div style="display:flex;align-items:center;gap:9px;margin-bottom:8px">
                <span class="badge ${cp.active ? 'ok' : 'off'}"><c:out value="${cp.statusLabel}"/></span>
                <span class="mono" style="font-size:10.5px;color:var(--ash);margin-left:auto">HSD <c:out value="${cp.expiredAtLabel}"/></span>
              </div>
              <div style="font-family:var(--display);font-stretch:116%;font-weight:700;font-size:22px"><c:out value="${cp.code}"/></div>
              <p style="font-size:13px;color:var(--graphite);margin:6px 0 12px"><c:out value="${cp.desc}"/></p>
              <c:choose>
                <c:when test="${cp.active}">
                  <button type="button" class="btn sm block" data-copy="${cp.code}">Sao chép mã</button>
                </c:when>
                <c:otherwise>
                  <button type="button" class="btn sm block quiet" disabled>Đã hết hạn</button>
                </c:otherwise>
              </c:choose>
            </div>
          </div>
        </c:forEach>
      </div>
    </c:otherwise>
  </c:choose>
</section>

<c:if test="${not empty saleProducts}">
  <section class="sec" style="padding-top:0">
    <div class="sec-head"><h3>Sản phẩm đang giảm giá</h3><a href="${ctx}/products?sort=price_asc">Xem tất cả →</a></div>
    <div class="p-grid">
      <c:forEach var="p" items="${saleProducts}">
        <c:set var="card" value="${p}" scope="request"/>
        <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
      </c:forEach>
    </div>
  </section>
</c:if>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
<script>
document.querySelectorAll('[data-copy]').forEach(function(btn){
  btn.addEventListener('click', function(){
    navigator.clipboard.writeText(btn.getAttribute('data-copy'));
    var old = btn.textContent; btn.textContent = 'Đã sao chép';
    setTimeout(function(){ btn.textContent = old; }, 1500);
  });
});
</script>
</body>
</html>
