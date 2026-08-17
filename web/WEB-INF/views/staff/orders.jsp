<%--
  admin/order-list.jsp — danh sách đơn + panel chi tiết + cập nhật trạng thái.
  Dùng chung cho ADMIN và SALE_STAFF.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="canManage" value="${sessionScope.user.role eq 'ADMIN' or sessionScope.user.role eq 'SALE_STAFF'}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Đơn hàng · Quản trị AppleStore"/>
  <jsp:include page="/WEB-INF/views/common/header.jsp"/>
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
      <div class="who"><span class="av"><c:out value="${sessionScope.user.fullName}"/></span></div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="panel">
        <div class="panel-head"><h3>Danh sách đơn hàng</h3></div>
        <form class="toolbar" method="get" action="${ctx}/admin/orders">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search"/></svg>
            <label class="sr-only" for="kw">Tìm đơn hàng</label>
            <input id="kw" class="input" type="text" name="keyword" maxlength="100"
                   value="<c:out value='${keyword}'/>" placeholder="Tìm theo mã đơn, tên hoặc số điện thoại">
          </div>
          <select class="select" name="status">
            <option value="">Tất cả trạng thái</option>
            <option value="CONFIRMED"  ${statusFilter eq 'CONFIRMED'  ? 'selected' : ''}>Chờ đóng gói</option>
            <option value="PREPARING"  ${statusFilter eq 'PREPARING'  ? 'selected' : ''}>Đang chuẩn bị</option>
            <option value="DISPATCHED" ${statusFilter eq 'DISPATCHED' ? 'selected' : ''}>Giao vận chuyển</option>
            <option value="DELIVERED"  ${statusFilter eq 'DELIVERED'  ? 'selected' : ''}>Đã giao</option>
            <option value="CANCELLED"  ${statusFilter eq 'CANCELLED'  ? 'selected' : ''}>Đã huỷ</option>
          </select>
          <input type="hidden" name="page" value="1">
          <button type="submit" class="btn sm">Áp dụng</button>
          <a class="btn quiet sm" href="${ctx}/admin/orders">Xoá lọc</a>
        </form>

        <c:choose>
          <c:when test="${empty orders}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-truck"/></svg></div>
              <h3>Không có đơn nào khớp bộ lọc</h3>
              <p>Thử thay đổi từ khóa hoặc xoá bộ lọc.</p>
            </div>
          </c:when>
          <c:otherwise>
            <table class="table">
              <thead>
                <tr>
                  <th>Mã đơn</th>
                  <th>Khách hàng</th>
                  <th>Sản phẩm</th>
                  <th>Tổng tiền</th>
                  <th>Thanh toán</th>
                  <th>Trạng thái</th>
                  <th>Đặt lúc</th>
                  <th style="text-align:right">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="o" items="${orders}">
                  <tr style="${o.orderId == selectedOrder.orderId ? 'background:#FCFBF8' : ''}">
                    <td class="num"><a href="${ctx}/admin/orders?code=${o.orderId}"><b>#${o.orderId}</b></a></td>
                    <td><c:out value="${o.recipientName}"/><div style="font-size:12px;color:var(--ash)"><c:out value="${o.recipientPhone}"/></div></td>
                    <td class="num">${o.notes}</td>
                    <td class="num"><fmt:formatNumber value="${o.finalAmount}" type="number" maxFractionDigits="0"/> đ</td>
                    <td><span class="tag"><c:out value="${o.paymentMethod}"/></span></td>
                    <td>
                      <c:choose>
                        <c:when test="${o.status eq 'CONFIRMED'}"><span class="badge warn">Chờ đóng gói</span></c:when>
                        <c:when test="${o.status eq 'PREPARING'}"><span class="badge info">Đang chuẩn bị</span></c:when>
                        <c:when test="${o.status eq 'DISPATCHED'}"><span class="badge info">Đang giao</span></c:when>
                        <c:when test="${o.status eq 'DELIVERED'}"><span class="badge ok">Đã giao</span></c:when>
                        <c:otherwise><span class="badge dan">Đã huỷ</span></c:otherwise>
                      </c:choose>
                    </td>
                    <td class="num">
                      <c:if test="${not empty o.createdAt}">
                        ${o.createdAt}
                      </c:if>
                    </td>
                    <td class="row-actions">
                      <c:if test="${canManage and o.status eq 'CONFIRMED'}">
                        <form class="inline-form" method="post" action="${ctx}/admin/order/status">
                          <input type="hidden" name="code" value="${o.orderId}">
                          <input type="hidden" name="status" value="PREPARING">
                          <input type="hidden" name="returnUrl" value="${ctx}/admin/orders">
                          <button type="submit" class="btn xs">Đóng gói</button>
                        </form>
                      </c:if>
                      <a class="btn xs quiet" href="${ctx}/admin/orders?code=${o.orderId}">Xem</a>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </c:otherwise>
        </c:choose>
      </div>

      <c:if test="${not empty selectedOrder}">
        <div class="split">
          <div class="panel">
            <div class="panel-head">
              <h3>Chi tiết đơn #${selectedOrder.orderId}</h3>
              <span class="r badge info"><c:out value="${selectedOrder.status}"/></span>
            </div>
            <div class="panel-pad">
              <div class="grid-2" style="margin-bottom:16px">
                <dl class="kv"><dt>Khách hàng</dt><dd><c:out value="${selectedOrder.recipientName}"/><br><c:out value="${selectedOrder.recipientPhone}"/></dd></dl>
                <dl class="kv"><dt>Giao đến</dt><dd><c:out value="${selectedOrder.deliveryAddress}"/><br>Phương thức: <c:out value="${selectedOrder.paymentMethod}"/></dd></dl>
              </div>
              <div style="max-width:280px;margin-left:auto;padding-top:10px">
                <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${selectedOrder.totalAmount}" type="number" maxFractionDigits="0"/> đ</span></div>
                <c:if test="${selectedOrder.discountAmount > 0}">
                  <div class="sum-row"><span>Giảm giá</span><span style="color:var(--ok)">− <fmt:formatNumber value="${selectedOrder.discountAmount}" type="number" maxFractionDigits="0"/> đ</span></div>
                </c:if>
                <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${selectedOrder.finalAmount}" type="number" maxFractionDigits="0"/> đ</span></div>
              </div>
            </div>
          </div>

          <div style="display:flex;flex-direction:column;gap:18px">
            <c:if test="${canManage}">
              <div class="panel"><div class="panel-head"><h3>Cập nhật trạng thái</h3></div><div class="panel-pad">
                <form method="post" action="${ctx}/admin/order/status">
                  <input type="hidden" name="code" value="${selectedOrder.orderId}">
                  <input type="hidden" name="returnUrl" value="${ctx}/admin/orders?code=${selectedOrder.orderId}">
                  <div class="field">
                    <label>Trạng thái mới</label>
                    <select class="select" name="status">
                      <option value="CONFIRMED" ${selectedOrder.status eq 'CONFIRMED' ? 'selected' : ''}>Chờ đóng gói</option>
                      <option value="PREPARING" ${selectedOrder.status eq 'PREPARING' ? 'selected' : ''}>Đang chuẩn bị hàng</option>
                      <option value="DISPATCHED" ${selectedOrder.status eq 'DISPATCHED' ? 'selected' : ''}>Giao vận chuyển (Tự gán Shipper)</option>
                      <option value="DELIVERED" ${selectedOrder.status eq 'DELIVERED' ? 'selected' : ''}>Đã giao thành công</option>
                      <option value="CANCELLED" ${selectedOrder.status eq 'CANCELLED' ? 'selected' : ''}>Đã huỷ</option>
                    </select>
                  </div>
                  <div class="field">
                    <label>Ghi chú nội bộ</label>
                    <textarea class="textarea" name="note" maxlength="300" placeholder="Ví dụ: Đã đóng gói xong, chờ shipper lấy hàng"></textarea>
                  </div>
                  <button type="submit" class="btn block">Cập nhật đơn</button>
                </form>
              </div></div>
            </c:if>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</div>
</body>
</html>