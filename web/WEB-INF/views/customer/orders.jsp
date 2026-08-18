<%--
  orders.jsp — đơn hàng của tôi, chia 2 tab và hiển thị chi tiết thời gian tiến độ.
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
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<c:set var="activeMenu" value="home"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div style="max-width: 1100px; margin: 30px auto; padding: 0 20px; min-height: 520px;">
  <div style="background: var(--porcelain, #f8f9fa); padding: 24px; border-radius: 8px;">
    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
    <h2 style="font-size: 22px; text-transform: uppercase; margin-bottom: 20px; font-weight: 700;">Đơn hàng của tôi</h2>

    <!-- TAB CHUYỂN ĐỔI: ĐANG XỬ LÝ / ĐÃ HOÀN THÀNH -->
    <div style="display:flex;gap:12px;margin-bottom:20px;border-bottom:1px solid var(--line, #eee);padding-bottom:12px">
      <a class="btn ${empty tab or tab eq 'active' ? '' : 'quiet'} sm" href="${ctx}/account/orders?tab=active">
        📦 Đang xử lý (${not empty activeCount ? activeCount : 0})
      </a>
      <a class="btn ${tab eq 'completed' ? '' : 'quiet'} sm" href="${ctx}/account/orders?tab=completed">
        ✅ Đã hoàn thành / Huỷ (${not empty completedCount ? completedCount : 0})
      </a>
    </div>

    <c:choose>
      <c:when test="${empty orders}">
        <div class="empty" style="text-align: center; padding: 40px;">
          <div class="ring" style="margin: 0 auto 12px;"><svg width="26" height="26"><use href="#i-box"/></svg></div>
          <h3>Không có đơn hàng nào trong mục này</h3>
          <p>Khám phá ngay các thiết bị Apple chính hãng với nhiều ưu đãi hấp dẫn.</p>
          <a class="btn titan" href="${ctx}/products" style="margin-top:12px; display: inline-block;">Bắt đầu mua sắm</a>
        </div>
      </c:when>
      <c:otherwise>
        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
          <!-- CỘT TRÁI: DANH SÁCH ĐƠN HÀNG -->
          <div style="display:flex;flex-direction:column;gap:14px">
            <c:forEach var="o" items="${orders}">
              <div class="panel" style="background:#fff; border:1px solid var(--line,#eee); border-radius:8px; padding:15px; ${o.code eq selectedOrder.code ? 'border-color:var(--titan)' : 'opacity:.9'}">
                <div class="panel-head" style="display:flex; justify-content:space-between; margin-bottom:10px;">
                  <span class="mono" style="font-size:11.5px"><b>Mã: <c:out value="${o.code}"/></b></span>
                  <c:choose>
                    <c:when test="${o.status eq 'PENDING'}"><span class="badge warn"><c:out value="${o.statusLabel}"/></span></c:when>
                    <c:when test="${o.status eq 'SHIPPING'}"><span class="badge info"><c:out value="${o.statusLabel}"/></span></c:when>
                    <c:when test="${o.status eq 'DELIVERED'}"><span class="badge ok"><c:out value="${o.statusLabel}"/></span></c:when>
                    <c:otherwise><span class="badge dan"><c:out value="${o.statusLabel}"/></span></c:otherwise>
                  </c:choose>
                </div>
                <div style="display:flex;gap:12px;align-items:center;margin-bottom:12px">
                  <div class="shot" style="width:54px;height:54px;aspect-ratio:auto;border-radius:var(--r-sm); background:#f0f0f0; display:flex; align-items:center; justify-content:center;">
                    <svg width="24" height="24" style="color:#5B6472"><use href="#${empty o.firstItemIconKey ? 'd-acc' : o.firstItemIconKey}"/></svg>
                  </div>
                  <div style="flex:1;font-size:13.5px"><c:out value="${o.itemsSummary}"/></div>
                  <div style="text-align:right">
                    <div style="font-family:var(--display);font-weight:700;font-size:15px">
                      <fmt:formatNumber value="${o.total}" type="number" maxFractionDigits="0"/> ₫</div>
                    <div style="font-size:11.5px;color:var(--ash)"><c:out value="${o.paymentMethodLabel}"/></div>
                  </div>
                </div>
                <div style="display:flex;gap:8px; justify-content: flex-end;">
                  <a class="btn sm" href="${ctx}/account/orders?tab=${not empty param.tab ? param.tab : 'active'}&code=${o.code}">Xem tiến độ</a>
                  <c:if test="${o.status eq 'PENDING'}">
                    <form method="post" action="${ctx}/order/cancel" style="margin:0;">
                      <input type="hidden" name="code" value="${o.code}">
                      <button type="submit" class="btn ghost sm danger">Huỷ đơn</button>
                    </form>
                  </c:if>
                </div>
              </div>
            </c:forEach>
          </div>

          <!-- CỘT PHẢI: CHI TIẾT TIẾN ĐỘ & MỐC THỜI GIAN CẬP NHẬT -->
          <div>
            <c:if test="${not empty selectedOrder}">
              <div class="panel" style="background:#fff; border:1px solid var(--line,#eee); border-radius:8px; padding:20px;">
                <div class="panel-head" style="margin-bottom:15px;"><h3 style="margin:0; font-size:16px;">Tiến độ đơn <c:out value="${selectedOrder.code}"/></h3></div>
                <div class="panel-pad">
                  <div class="timeline" style="display:flex; flex-direction:column; gap:12px;">
                    <c:forEach var="ev" items="${selectedOrder.timeline}">
                      <div class="ev ${ev.done ? 'done' : ''}" style="display:flex; justify-content:space-between; font-size:13px; padding-bottom:8px; border-bottom:1px dashed #eee;">
                        <b><c:out value="${ev.label}"/></b>
                        <span style="color:var(--ash);">
                          <c:choose>
                            <c:when test="${not empty ev.time}">
                              <fmt:formatDate value="${ev.time}" pattern="dd/MM/yyyy 'lúc' HH:mm"/>
                            </c:when>
                            <c:otherwise>
                              Đang chờ...
                            </c:otherwise>
                          </c:choose>
                        </span>
                      </div>
                    </c:forEach>
                  </div>
                  <div style="border-top:1px solid var(--line, #eee);margin-top:16px;padding-top:14px; font-size:13px;">
                    <div style="margin-bottom:6px;"><b>Người nhận:</b> <c:out value="${selectedOrder.receiverName}"/> (<c:out value="${selectedOrder.phone}"/>)</div>
                    <div style="margin-bottom:6px;"><b>Địa chỉ:</b> <c:out value="${selectedOrder.fullAddress}"/></div>
                    <div style="margin-bottom:12px;"><b>Thanh toán:</b> <c:out value="${selectedOrder.paymentMethodLabel}"/></div>
                    
                    <div class="sum-row" style="display:flex; justify-content:space-between; margin-bottom:4px;"><span>Tạm tính</span><span><fmt:formatNumber value="${selectedOrder.subtotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
                    <c:if test="${selectedOrder.discount > 0}">
                      <div class="sum-row" style="display:flex; justify-content:space-between; margin-bottom:4px; color:var(--ok)"><span>Giảm giá</span><span>− <fmt:formatNumber value="${selectedOrder.discount}" type="number" maxFractionDigits="0"/> ₫</span></div>
                    </c:if>
                    <div class="sum-row total" style="display:flex; justify-content:space-between; font-weight:bold; font-size:15px; margin-top:8px; border-top:1px solid #eee; padding-top:8px;"><span>Tổng cộng</span><span><fmt:formatNumber value="${selectedOrder.total}" type="number" maxFractionDigits="0"/> ₫</span></div>
                  </div>
                </div>
              </div>
            </c:if>
          </div>
        </div>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>