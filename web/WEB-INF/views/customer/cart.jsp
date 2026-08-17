<%--
  cart.jsp — giỏ hàng.
  Servlet (CartServlet) set:
    cartItems       : List<CartItem> {cartItemId,productName,variantLabel,unitPrice,
                       stockQuantity,addonLabel,addonPrice,imageUrl,quantity,lineTotal,overStock}
    cartTotal       : BigDecimal tổng tạm tính
    cartItemCount   : int tổng số lượng sản phẩm
    hasOverStockItem: boolean có dòng nào vượt tồn kho không
    successMsg / errorMsg : flash message (rule 10)
  POST /cart action=add|update|remove theo PRG, luôn redirect lại GET /cart.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Giỏ hàng · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<c:set var="activeStep" value="1" scope="request"/>
<jsp:include page="/WEB-INF/views/common/checkout-steps.jsp"/>

<div style="padding:22px 26px">
  <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

  <c:if test="${hasOverStockItem}">
    <div class="flash err" style="margin-bottom:16px">
      <svg width="18" height="18"><use href="#i-alert"/></svg>
      <div>Một số sản phẩm trong giỏ đã vượt quá số lượng tồn kho hiện tại, vui lòng cập nhật lại trước khi thanh toán.</div>
    </div>
  </c:if>

  <c:choose>
    <%-- ================= GIỎ HÀNG CÓ SẢN PHẨM ================= --%>
    <c:when test="${not empty cartItems}">
      <div class="split">
        <div class="panel">
          <div class="panel-head">
            <h3>Sản phẩm trong giỏ</h3>
            <span class="r mono" style="font-size:11px;color:var(--ash)">${cartItemCount} món</span>
          </div>
          <div class="panel-pad">
            <c:forEach var="item" items="${cartItems}">
              <div class="line-item">
                <div class="shot thumb-lg">
                  <c:choose>
                    <c:when test="${not empty item.imageUrl}">
                      <img src="${ctx}${item.imageUrl}" alt="<c:out value='${item.productName}'/>">
                    </c:when>
                    <c:otherwise><svg style="color:#5B6472"><use href="#d-acc"/></svg></c:otherwise>
                  </c:choose>
                </div>

                <div style="flex:1;min-width:0">
                  <b style="font-size:13.5px"><c:out value="${item.productName}"/></b><br>
                  <span style="font-size:12px;color:var(--ash)">
                    <c:out value="${item.variantLabel}"/>
                    <c:if test="${not empty item.addonLabel}"> &middot; Dịch vụ thêm: <c:out value="${item.addonLabel}"/></c:if>
                  </span><br>
                  <span class="mono" style="font-size:12px">
                    <fmt:formatNumber value="${item.unitPrice}" type="number" maxFractionDigits="0"/> ₫
                    <c:if test="${not empty item.addonPrice and item.addonPrice > 0}">
                      (+ <fmt:formatNumber value="${item.addonPrice}" type="number" maxFractionDigits="0"/> ₫ dịch vụ thêm)
                    </c:if>
                  </span>
                  <c:if test="${item.overStock}">
                    <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg>Chỉ còn ${item.stockQuantity} sản phẩm trong kho</div>
                  </c:if>
                  <c:if test="${item.stockQuantity <= 0}">
                    <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg>Sản phẩm đã hết hàng, vui lòng xoá khỏi giỏ</div>
                  </c:if>
                </div>

                <form method="post" action="${ctx}/cart" style="display:flex;align-items:center;gap:8px">
                  <input type="hidden" name="action" value="update">
                  <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                  <input class="input mono" type="number" name="quantity" value="${item.quantity}"
                         min="1" max="${item.stockQuantity}" style="width:64px;height:34px;padding:0 8px;text-align:center">
                  <button type="submit" class="btn quiet xs">Cập nhật</button>
                </form>

                <div style="width:110px;text-align:right;font-family:var(--display);font-stretch:112%;font-weight:700;font-size:14.5px">
                  <fmt:formatNumber value="${item.lineTotal}" type="number" maxFractionDigits="0"/> ₫
                </div>

                <form method="post" action="${ctx}/cart" onsubmit="return confirm('Xóa sản phẩm này khỏi giỏ hàng?');">
                  <input type="hidden" name="action" value="remove">
                  <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                  <button type="submit" class="icon-btn" title="Xoá">
                    <svg width="15" height="15"><use href="#i-trash"/></svg>
                  </button>
                </form>
              </div>
            </c:forEach>
          </div>
        </div>

        <div class="panel" style="position:sticky;top:16px">
          <div class="panel-head"><h3>Tóm tắt đơn hàng</h3></div>
          <div class="panel-pad">
            <div class="sum-row"><span>Số sản phẩm</span><span>${cartItemCount}</span></div>
            <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${cartTotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
            <div class="sum-row"><span>Phí vận chuyển</span><span style="color:var(--ash)">Tính khi thanh toán</span></div>
            <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${cartTotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
            <a class="btn titan block" style="margin-top:16px" href="${ctx}/checkout">Tiến hành thanh toán</a>
            <a class="btn ghost block" style="margin-top:10px" href="${ctx}/products">Tiếp tục mua sắm</a>
          </div>
        </div>
      </div>
    </c:when>

    <%-- ================= GIỎ HÀNG TRỐNG ================= --%>
    <c:otherwise>
      <div class="empty">
        <div class="ring"><svg width="28" height="28"><use href="#i-cart"/></svg></div>
        <h3>Giỏ hàng của bạn hiện đang trống</h3>
        <p>Chọn sản phẩm bạn thích và thêm vào giỏ hàng để bắt đầu mua sắm.</p>
        <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap">
          <a class="btn titan" href="${ctx}/products">Xem sản phẩm</a>
          <a class="btn ghost" href="${ctx}/home">Về trang chủ</a>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
