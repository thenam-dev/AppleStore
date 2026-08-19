<%--
  orders.jsp — danh sách tất cả đơn (trái) + chi tiết, shipper & workflow tự động (phải).
  Dùng chung cho ADMIN và SALE_STAFF.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="currUser" value="${not empty sessionScope.currentUser ? sessionScope.currentUser : sessionScope.user}"/>
<c:set var="canManage" value="${currUser.role eq 'ADMIN' or currUser.role eq 'SALE_STAFF'}"/>

<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Đơn hàng · Quản trị AppleStore"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <c:set var="activeAdmin" value="orders"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Đơn hàng</h2>
      <span class="badge warn">${pendingCount} đơn chờ xử lý</span>
      <div class="who"><span class="av"><c:out value="${currUser.fullName}"/></span></div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <!-- KHUNG .SPLIT CHIA 2 CỘT CHUẨN XÁC -->
      <div class="split">
        
        <!-- ================= CỘT TRÁI: DANH SÁCH TẤT CẢ ĐƠN HÀNG ================= -->
        <div class="panel">
          <div class="panel-head"><h3>Danh sách tất cả đơn hàng</h3></div>
          
          <form class="toolbar" method="get" action="${ctx}/staff/orders">
            <div class="search">
              <svg width="17" height="17"><use href="#i-search"/></svg>
              <label class="sr-only" for="kw">Tìm đơn hàng</label>
              <input id="kw" class="input" type="text" name="keyword" maxlength="100"
                     value="<c:out value='${keyword}'/>" placeholder="Mã đơn, tên, sđt...">
            </div>
            <select class="select" name="status" style="max-width: 140px;">
              <option value="">Tất cả</option>
              <option value="CONFIRMED"  ${statusFilter eq 'CONFIRMED'  ? 'selected' : ''}>Chờ đóng gói</option>
              <option value="PREPARING"  ${statusFilter eq 'PREPARING'  ? 'selected' : ''}>Đang chuẩn bị</option>
              <option value="DISPATCHED" ${statusFilter eq 'DISPATCHED' ? 'selected' : ''}>Giao vận</option>
              <option value="DELIVERED"  ${statusFilter eq 'DELIVERED'  ? 'selected' : ''}>Đã giao</option>
              <option value="CANCELLED"  ${statusFilter eq 'CANCELLED'  ? 'selected' : ''}>Đã huỷ</option>
            </select>
            <input type="hidden" name="page" value="1">
            <button type="submit" class="btn sm">Lọc</button>
            <a class="btn quiet sm" href="${ctx}/staff/orders">Xoá</a>
          </form>

          <c:choose>
            <c:when test="${empty orders}">
              <div class="empty">
                <div class="ring"><svg width="26" height="26"><use href="#i-truck"/></svg></div>
                <h3>Không tìm thấy đơn hàng</h3>
                <p>Thử thay đổi bộ lọc tìm kiếm.</p>
              </div>
            </c:when>
            <c:otherwise>
              <table class="table">
                <thead>
                  <tr>
                    <th>Mã</th>
                    <th>Khách hàng</th>
                    <th>Tổng tiền</th>
                    <th>Trạng thái</th>
                    <th style="text-align:right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="o" items="${orders}">
                    <tr style="${o.orderId == selectedOrder.orderId ? 'background:#FCFBF8' : ''}">
                      <td class="num">
                        <a href="${ctx}/staff/orders?code=${o.orderId}&status=${statusFilter}&keyword=${keyword}"><b>#<c:out value="${o.orderId}"/></b></a>
                      </td>
                      <td>
                        <c:out value="${o.recipientName}"/>
                        <div style="font-size:11px;color:var(--ash)"><c:out value="${o.recipientPhone}"/></div>
                      </td>
                      <td class="num">
                        <fmt:formatNumber value="${not empty o.finalAmount ? o.finalAmount : 0}" type="number" maxFractionDigits="0"/> ₫
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${o.status eq 'CONFIRMED'}"><span class="badge warn">Chờ đóng gói</span></c:when>
                          <c:when test="${o.status eq 'PREPARING'}"><span class="badge info">Đang chuẩn bị</span></c:when>
                          <c:when test="${o.status eq 'DISPATCHED'}"><span class="badge info">Đang giao</span></c:when>
                          <c:when test="${o.status eq 'DELIVERED'}"><span class="badge ok">Đã giao</span></c:when>
                          <c:otherwise><span class="badge dan">Đã huỷ</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="row-actions">
                        <a class="btn xs quiet" href="${ctx}/staff/orders?code=${o.orderId}&status=${statusFilter}&keyword=${keyword}">Xem</a>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
              
              <c:set var="pageUrl"   value="${ctx}/staff/orders"/>
              <c:set var="itemLabel" value="đơn"/>
              <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- ================= CỘT PHẢI: CHI TIẾT & NÚT BẤM WORKFLOW TỰ ĐỘNG ================= -->
        <div style="display:flex;flex-direction:column;gap:18px">
          
          <c:choose>
            <c:when test="${not empty selectedOrder}">
              
              <!-- 1. PANEL THÔNG TIN CHI TIẾT ĐƠN & SẢN PHẨM -->
              <div class="panel">
                <div class="panel-head">
                  <h3>Chi tiết đơn #${selectedOrder.orderId}</h3>
                  <c:choose>
                    <c:when test="${selectedOrder.status eq 'CONFIRMED'}"><span class="r badge warn">Chờ đóng gói</span></c:when>
                    <c:when test="${selectedOrder.status eq 'PREPARING'}"><span class="r badge info">Đang chuẩn bị</span></c:when>
                    <c:when test="${selectedOrder.status eq 'DISPATCHED'}"><span class="r badge info">Đang giao</span></c:when>
                    <c:when test="${selectedOrder.status eq 'DELIVERED'}"><span class="r badge ok">Đã giao</span></c:when>
                    <c:otherwise><span class="r badge dan">Đã huỷ</span></c:otherwise>
                  </c:choose>
                </div>
                <div class="panel-pad">
                  <div style="margin-bottom:12px;font-size:13px">
                    <b>Người nhận:</b> <c:out value="${selectedOrder.recipientName}"/> (${selectedOrder.recipientPhone})<br>
                    <b>Địa chỉ:</b> <c:out value="${selectedOrder.deliveryAddress}"/><br>
                    <b>Thanh toán:</b> <c:out value="${selectedOrder.paymentMethod}"/>
                  </div>

                  <!-- Hiển thị Shipper phụ trách nếu đơn đã giao vận -->
                  <c:if test="${not empty selectedOrder.shipperName}">
                    <div style="margin-bottom:12px; padding:8px 12px; background:#f0f7ff; border:1px solid #cce5ff; border-radius:4px; font-size:13px;">
                      <b>🚀 Shipper phụ trách:</b> <c:out value="${selectedOrder.shipperName}"/>
                    </div>
                  </c:if>

                  <!-- BẢNG SẢN PHẨM TRONG ĐƠN -->
                  <table class="table" style="border-top:1px solid var(--line); font-size: 13px;">
                    <thead>
                      <tr>
                        <th>Sản phẩm</th>
                        <th>Đơn giá</th>
                        <th>SL</th>
                        <th style="text-align:right">Thành tiền</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach var="it" items="${selectedOrder.items}">
                        <tr>
                          <td>
                            <b><c:out value="${it.productNameSnapshot}"/></b>
                            <c:if test="${not empty it.variantLabelSnapshot}">
                              <div style="font-size:11px;color:var(--ash)"><c:out value="${it.variantLabelSnapshot}"/></div>
                            </c:if>
                            <c:if test="${not empty it.addonLabelSnapshot}">
                              <div style="font-size:11px;color:var(--ok)">+ <c:out value="${it.addonLabelSnapshot}"/> (<fmt:formatNumber value="${it.addonPriceSnapshot}" type="number" maxFractionDigits="0"/> ₫)</div>
                            </c:if>
                          </td>
                          <td class="num"><fmt:formatNumber value="${not empty it.unitPrice ? it.unitPrice : 0}" type="number" maxFractionDigits="0"/> ₫</td>
                          <td class="num">${not empty it.quantity ? it.quantity : 0}</td>
                          <td class="num" style="text-align:right"><fmt:formatNumber value="${not empty it.subtotal ? it.subtotal : 0}" type="number" maxFractionDigits="0"/> ₫</td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>

                  <!-- TỔNG KẾT TIỀN -->
                  <div style="max-width:260px;margin-left:auto;padding-top:10px">
                    <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${not empty selectedOrder.totalAmount ? selectedOrder.totalAmount : 0}" type="number" maxFractionDigits="0"/> ₫</span></div>
                    <c:if test="${selectedOrder.discountAmount > 0}">
                      <div class="sum-row"><span>Giảm giá</span><span style="color:var(--ok)">− <fmt:formatNumber value="${selectedOrder.discountAmount}" type="number" maxFractionDigits="0"/> ₫</span></div>
                    </c:if>
                    <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${not empty selectedOrder.finalAmount ? selectedOrder.finalAmount : 0}" type="number" maxFractionDigits="0"/> ₫</span></div>
                  </div>
                </div>
              </div>

              <!-- 2. PANEL XỬ LÝ QUY TRÌNH TỰ ĐỘNG (THEO ĐÚNG WORKFLOW) -->
              <c:if test="${canManage}">
                <div class="panel">
                  <div class="panel-head"><h3>Xử lý đơn hàng</h3></div>
                  <div class="panel-pad">
                    <form method="post" action="${ctx}/staff/orders/status">
                      <input type="hidden" name="code" value="${selectedOrder.orderId}">
                      <input type="hidden" name="returnUrl" value="${ctx}/staff/orders?code=${selectedOrder.orderId}">
                      
                      <div class="field" style="margin-bottom:12px;">
                        <label>Ghi chú nội bộ (tuỳ chọn)</label>
                        <textarea class="textarea" name="note" maxlength="300" placeholder="Ví dụ: Đã đóng gói xong, chuẩn bị bàn giao shipper..."></textarea>
                      </div>

                      <div style="display:flex; flex-direction:column; gap:10px;">
                        <c:choose>
                          <%-- Bước 1: Đang chờ đóng gói -> Chuyển sang Đang chuẩn bị --%>
                          <c:when test="${selectedOrder.status eq 'CONFIRMED'}">
                            <input type="hidden" name="status" value="PREPARING">
                            <button type="submit" class="btn block">📦 Đóng gói (Chuyển sang Đang chuẩn bị)</button>
                          </c:when>
                          
                          <%-- Bước 2: Đang chuẩn bị -> Chuyển sang Giao vận (Giao cho Shipper) --%>
                          <c:when test="${selectedOrder.status eq 'PREPARING'}">
                            <input type="hidden" name="status" value="DISPATCHED">
                            <button type="submit" class="btn block">🚀 Giao vận chuyển (Tự động gán Shipper)</button>
                          </c:when>
                          
                          <%-- 
                            ĐÃ XÓA BƯỚC XÁC NHẬN DELIVERED Ở ĐÂY. 
                            Khi đơn hàng ở trạng thái 'DISPATCHED' (Đang giao), Sale Staff sẽ KHÔNG còn nút bấm nào nữa, 
                            trách nhiệm xác nhận giao thành công sẽ do Shipper thao tác trong trang nhiệm vụ của họ. 
                          --%>
                          <c:when test="${selectedOrder.status eq 'DISPATCHED'}">
                            <div style="font-size:13px; color:var(--ash); text-align:center; padding: 6px;">
                              Đơn hàng đang được Shipper giao vận.
                            </div>
                          </c:when>

                          <c:otherwise>
                            <div style="font-size:13px; color:var(--ash); text-align:center; padding: 6px;">
                              Đơn hàng đã hoàn tất hoặc đã huỷ.
                            </div>
                          </c:otherwise>
                        </c:choose>
                        
                        <!-- Nút Huỷ đơn hàng chung -->
                        <c:if test="${selectedOrder.status ne 'DELIVERED' and selectedOrder.status ne 'CANCELLED' and selectedOrder.status ne 'DISPATCHED'}">
                          <button type="submit" name="status" value="CANCELLED" class="btn block danger">❌ Huỷ đơn hàng</button>
                        </c:if>
                      </div>
                    </form>
                  </div>
                </div>
              </c:if>

            </c:when>
            <c:otherwise>
              <!-- TRƯỜNG HỢP CHƯA CHỌN ĐƠN NÀO -->
              <div class="panel" style="text-align: center; padding: 40px; color: var(--ash);">
                <div class="ring" style="margin: 0 auto 12px;"><svg width="24" height="24"><use href="#i-box"/></svg></div>
                <h4>Chưa chọn đơn hàng</h4>
                <p style="font-size: 13px;">Bấm nút <b>Xem</b> ở bảng bên trái để hiển thị chi tiết sản phẩm và các nút xử lý quy trình.</p>
              </div>
            </c:otherwise>
          </c:choose>

        </div>

      </div>
    </div>
  </div>
</div>
</body>
</html>