<%--
  orders.jsp — đơn hàng của tôi.
  Servlet cần set:
    orders        : List<Order>{code,status,statusLabel,createdAt,itemsSummary,total,
                                 firstItemIconKey,firstItemImageUrl,paymentMethodLabel}
    statusFilter  : trạng thái đang lọc ("" nếu tất cả)
    statusCounts  : Map<String,Integer> đếm theo trạng thái để hiện số trên nút lọc
    selectedOrder : Order đang xem chi tiết (đơn đầu tiên hoặc theo ?code=)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <title>Đơn hàng của tôi · HALO</title>
  <c:set var="pageTitle" value="Đơn hàng của tôi · HALO"/>
  <!-- Đã xóa lệnh gọi header sai vị trí ở đây để tránh lỗi trắng màn hình -->
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<c:set var="activeMenu" value="home"/>

<!-- Đây mới là vị trí chuẩn xác của thẻ header -->
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div style="display:grid;grid-template-columns:240px 1fr;min-height:520px">
  <c:set var="activeAccount" value="orders"/>
  <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>

  <div style="padding:24px;background:var(--porcelain)">
    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
    <h2 style="font-size:24px;text-transform:uppercase;margin-bottom:16px">Đơn hàng của tôi</h2>

    <div style="display:flex;gap:8px;flex-wrap:wrap;margin-bottom:18px">
      <a class="btn ${empty statusFilter ? '' : 'quiet'} sm" href="${ctx}/account/orders">Tất cả (${statusCounts.ALL})</a>
      <a class="btn ${statusFilter eq 'PENDING' ? '' : 'quiet'} sm" href="${ctx}/account/orders?status=PENDING">Chờ xác nhận (${statusCounts.PENDING})</a>
      <a class="btn ${statusFilter eq 'SHIPPING' ? '' : 'quiet'} sm" href="${ctx}/account/orders?status=SHIPPING">Đang giao (${statusCounts.SHIPPING})</a>
      <a class="btn ${statusFilter eq 'DELIVERED' ? '' : 'quiet'} sm" href="${ctx}/account/orders?status=DELIVERED">Đã giao (${statusCounts.DELIVERED})</a>
      <a class="btn ${statusFilter eq 'CANCELLED' ? '' : 'quiet'} sm" href="${ctx}/account/orders?status=CANCELLED">Đã huỷ (${statusCounts.CANCELLED})</a>
    </div>

    <c:choose>
      <c:when test="${empty orders}">
        <div class="empty">
          <div class="ring"><svg width="26" height="26"><use href="#i-box"/></svg></div>
          <h3>Bạn chưa có đơn hàng nào</h3>
          <p>Đơn đầu tiên được giảm 500.000 ₫ với mã HALO500.</p>
          <a class="btn titan" href="${ctx}/products">Bắt đầu mua sắm</a>
        </div>
      </c:when>
      <c:otherwise>
        <div class="split">
          <div style="display:flex;flex-direction:column;gap:14px">
            <c:forEach var="o" items="${orders}">
              <div class="panel" style="${o.code eq selectedOrder.code ? '' : 'opacity:.9'}">
                <div class="panel-head">
                  <span class="mono" style="font-size:11.5px"><c:out value="${o.code}"/></span>
                  <c:choose>
                    <c:when test="${o.status eq 'PENDING'}"><span class="badge warn"><c:out value="${o.statusLabel}"/></span></c:when>
                    <c:when test="${o.status eq 'SHIPPING'}"><span class="badge info"><c:out value="${o.statusLabel}"/></span></c:when>
                    <c:when test="${o.status eq 'DELIVERED'}"><span class="badge ok"><c:out value="${o.statusLabel}"/></span></c:when>
                    <c:otherwise><span class="badge dan"><c:out value="${o.statusLabel}"/></span></c:otherwise>
                  </c:choose>
                  <div class="r"><span style="font-size:12.5px;color:var(--ash)"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM/yyyy"/></span></div>
                </div>
                <div class="panel-pad">
                  <div style="display:flex;gap:12px;align-items:center;margin-bottom:12px">
                    <div class="shot" style="width:54px;height:54px;aspect-ratio:auto;border-radius:var(--r-sm)">
                      <svg style="color:#5B6472"><use href="#${empty o.firstItemIconKey ? 'd-acc' : o.firstItemIconKey}"/></svg>
                    </div>
                    <div style="flex:1;font-size:13.5px"><c:out value="${o.itemsSummary}"/></div>
                    <div style="text-align:right">
                      <div style="font-family:var(--display);font-stretch:112%;font-weight:700;font-size:16px">
                        <fmt:formatNumber value="${o.total}" type="number" maxFractionDigits="0"/> ₫</div>
                      <div style="font-size:12px;color:var(--ash)"><c:out value="${o.paymentMethodLabel}"/></div>
                    </div>
                  </div>
                  <div style="display:flex;gap:8px">
                    <a class="btn sm" href="${ctx}/account/orders?code=${o.code}">Xem chi tiết</a>
                    <c:if test="${o.status eq 'PENDING'}">
                      <form method="post" action="${ctx}/order/cancel">
                        <input type="hidden" name="code" value="${o.code}">
                        <button type="submit" class="btn ghost sm">Huỷ đơn</button>
                      </form>
                    </c:if>
                    <c:if test="${o.status eq 'DELIVERED'}">
                      <a class="btn ghost sm" href="${ctx}/product/review?orderCode=${o.code}">Viết đánh giá</a>
                    </c:if>
                  </div>
                </div>
              </div>
            </c:forEach>
          </div>

          <c:if test="${not empty selectedOrder}">
            <div class="panel">
              <div class="panel-head"><h3>Chi tiết đơn <c:out value="${selectedOrder.code}"/></h3></div>
              <div class="panel-pad">
                <div class="timeline">
                  <c:forEach var="ev" items="${selectedOrder.timeline}">
                    <div class="ev ${ev.done ? 'done' : ''}">
                      <b><c:out value="${ev.label}"/></b>
                      <span><c:if test="${not empty ev.time}"><fmt:formatDate value="${ev.time}" pattern="dd/MM/yyyy · HH:mm"/></c:if></span>
                    </div>
                  </c:forEach>
                </div>
                <div style="border-top:1px solid var(--line);margin-top:8px;padding-top:14px">
                  <dl class="kv">
                    <dt>Người nhận</dt><dd><c:out value="${selectedOrder.receiverName}"/><br><c:out value="${selectedOrder.phone}"/></dd>
                    <dt>Địa chỉ</dt><dd><c:out value="${selectedOrder.fullAddress}"/></dd>
                    <dt>Thanh toán</dt><dd><c:out value="${selectedOrder.paymentMethodLabel}"/></dd>
                  </dl>
                  <div class="sum-row" style="margin-top:12px"><span>Tạm tính</span><span><fmt:formatNumber value="${selectedOrder.subtotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
                  <c:if test="${selectedOrder.discount > 0}">
                    <div class="sum-row"><span>Giảm giá</span><span style="color:var(--ok)">− <fmt:formatNumber value="${selectedOrder.discount}" type="number" maxFractionDigits="0"/> ₫</span></div>
                  </c:if>
                  <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${selectedOrder.total}" type="number" maxFractionDigits="0"/> ₫</span></div>
                </div>
              </div>
            </div>
          </c:if>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>