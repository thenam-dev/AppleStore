<%--
  admin/order-list.jsp — danh sách đơn + panel chi tiết + cập nhật trạng thái.
  Dùng chung cho ADMIN và STAFF (rule 9), khác nhau ở cờ canManage do servlet đặt sẵn.
  Servlet cần set:
    orders : List<Order>{code,receiverName,phone,itemCount,total,paymentMethodLabel,
                          status,statusLabel,createdAt}
    keyword, statusFilter, fromDate, toDate
    selectedOrder : Order đang xem chi tiết {items=List<{name,price,qty,lineTotal}>,
                                              receiverName,phone,email,fullAddress,
                                              deliveryMethodLabel,subtotal,discount,
                                              couponCode,total,timeline}
    + Paging.export(request, "đơn")
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx"       value="${pageContext.request.contextPath}"/>
<c:set var="canManage" value="${sessionScope.currentUser.role eq 'ADMIN' or sessionScope.currentUser.role eq 'STAFF'}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Đơn hàng · Quản trị HALO"/>
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
      <span class="badge warn">${pendingCount} đơn chờ xác nhận</span>
      <div class="who"><span class="av"><c:out value="${sessionScope.currentUser.initials}"/></span></div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="panel">
        <div class="panel-head"><h3>Danh sách đơn</h3></div>
        <form class="toolbar" method="get" action="${ctx}/admin/orders">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search"/></svg>
            <label class="sr-only" for="kw">Tìm đơn hàng</label>
            <input id="kw" class="input" type="text" name="keyword" maxlength="100"
                   value="<c:out value='${keyword}'/>" placeholder="Tìm theo mã đơn, tên hoặc số điện thoại">
          </div>
          <select class="select" name="status">
            <option value="">Tất cả trạng thái</option>
            <option value="PENDING"   ${statusFilter eq 'PENDING'   ? 'selected' : ''}>Chờ xác nhận</option>
            <option value="SHIPPING"  ${statusFilter eq 'SHIPPING'  ? 'selected' : ''}>Đang giao</option>
            <option value="DELIVERED" ${statusFilter eq 'DELIVERED' ? 'selected' : ''}>Đã giao</option>
            <option value="CANCELLED" ${statusFilter eq 'CANCELLED' ? 'selected' : ''}>Đã huỷ</option>
          </select>
          <input class="input" type="date" name="fromDate" value="${fromDate}" style="width:auto">
          <span style="color:var(--ash);font-size:13px">đến</span>
          <input class="input" type="date" name="toDate" value="${toDate}" style="width:auto">
          <input type="hidden" name="page" value="1">
          <button type="submit" class="btn sm">Áp dụng</button>
          <a class="btn quiet sm" href="${ctx}/admin/orders">Xoá lọc</a>
        </form>

        <c:choose>
          <c:when test="${empty orders}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-truck"/></svg></div>
              <h3>Không có đơn nào khớp bộ lọc</h3>
              <p>Thử đổi khoảng ngày hoặc xoá bộ lọc.</p>
            </div>
          </c:when>
          <c:otherwise>
            <table class="table">
              <thead><tr><th>Mã đơn</th><th>Khách hàng</th><th>Sản phẩm</th><th>Tổng tiền</th><th>Thanh toán</th><th>Trạng thái</th><th>Đặt lúc</th><th style="text-align:right">Thao tác</th></tr></thead>
              <tbody>
                <c:forEach var="o" items="${orders}">
                  <tr style="${o.code eq selectedOrder.code ? 'background:#FCFBF8' : ''}">
                    <td class="num"><a href="${ctx}/admin/orders?code=${o.code}${filterQuery}"><b><c:out value="${o.code}"/></b></a></td>
                    <td><c:out value="${o.receiverName}"/><div style="font-size:12px;color:var(--ash)"><c:out value="${o.phone}"/></div></td>
                    <td class="num">${o.itemCount}</td>
                    <td class="num"><fmt:formatNumber value="${o.total}" type="number" maxFractionDigits="0"/> ₫</td>
                    <td><span class="tag"><c:out value="${o.paymentMethodLabel}"/></span></td>
                    <td>
                      <c:choose>
                        <c:when test="${o.status eq 'PENDING'}"><span class="badge warn"><c:out value="${o.statusLabel}"/></span></c:when>
                        <c:when test="${o.status eq 'SHIPPING'}"><span class="badge info"><c:out value="${o.statusLabel}"/></span></c:when>
                        <c:when test="${o.status eq 'DELIVERED'}"><span class="badge ok"><c:out value="${o.statusLabel}"/></span></c:when>
                        <c:otherwise><span class="badge dan"><c:out value="${o.statusLabel}"/></span></c:otherwise>
                      </c:choose>
                    </td>
                    <td class="num"><fmt:formatDate value="${o.createdAt}" pattern="dd/MM HH:mm"/></td>
                    <td class="row-actions">
                      <c:if test="${canManage and o.status eq 'PENDING'}">
                        <form class="inline-form" method="post" action="${ctx}/admin/order/status">
                          <input type="hidden" name="code" value="${o.code}"><input type="hidden" name="status" value="CONFIRMED">
                          <input type="hidden" name="returnUrl" value="${ctx}/admin/orders?page=${page}${filterQuery}">
                          <button type="submit" class="btn xs">Xác nhận</button>
                        </form>
                        <form class="inline-form" method="post" action="${ctx}/admin/order/status">
                          <input type="hidden" name="code" value="${o.code}"><input type="hidden" name="status" value="CANCELLED">
                          <input type="hidden" name="returnUrl" value="${ctx}/admin/orders?page=${page}${filterQuery}">
                          <button type="submit" class="btn xs danger">Huỷ</button>
                        </form>
                      </c:if>
                      <a class="btn xs quiet" href="${ctx}/admin/orders?code=${o.code}${filterQuery}">Xem</a>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
            <c:set var="pageUrl"   value="${ctx}/admin/orders"/>
            <c:set var="itemLabel" value="đơn"/>
            <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
          </c:otherwise>
        </c:choose>
      </div>

      <c:if test="${not empty selectedOrder}">
        <div class="split">
          <div class="panel">
            <div class="panel-head"><h3>Chi tiết đơn <c:out value="${selectedOrder.code}"/></h3>
              <c:choose>
                <c:when test="${selectedOrder.status eq 'PENDING'}"><span class="r badge warn"><c:out value="${selectedOrder.statusLabel}"/></span></c:when>
                <c:when test="${selectedOrder.status eq 'SHIPPING'}"><span class="r badge info"><c:out value="${selectedOrder.statusLabel}"/></span></c:when>
                <c:when test="${selectedOrder.status eq 'DELIVERED'}"><span class="r badge ok"><c:out value="${selectedOrder.statusLabel}"/></span></c:when>
                <c:otherwise><span class="r badge dan"><c:out value="${selectedOrder.statusLabel}"/></span></c:otherwise>
              </c:choose>
            </div>
            <div class="panel-pad">
              <div class="grid-2" style="margin-bottom:16px">
                <dl class="kv"><dt>Khách hàng</dt><dd><c:out value="${selectedOrder.receiverName}"/><br><c:out value="${selectedOrder.phone}"/> · <c:out value="${selectedOrder.email}"/></dd></dl>
                <dl class="kv"><dt>Giao đến</dt><dd><c:out value="${selectedOrder.fullAddress}"/><br><c:out value="${selectedOrder.deliveryMethodLabel}"/></dd></dl>
              </div>
              <table class="table" style="border-top:1px solid var(--line)">
                <thead><tr><th>Sản phẩm</th><th>Đơn giá</th><th>SL</th><th style="text-align:right">Thành tiền</th></tr></thead>
                <tbody>
                  <c:forEach var="it" items="${selectedOrder.items}">
                    <tr><td><c:out value="${it.name}"/></td><td class="num"><fmt:formatNumber value="${it.price}" type="number" maxFractionDigits="0"/> ₫</td>
                      <td class="num">${it.qty}</td><td class="num" style="text-align:right"><fmt:formatNumber value="${it.lineTotal}" type="number" maxFractionDigits="0"/> ₫</td></tr>
                  </c:forEach>
                </tbody>
              </table>
              <div style="max-width:280px;margin-left:auto;padding-top:10px">
                <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${selectedOrder.subtotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
                <c:if test="${selectedOrder.discount > 0}">
                  <div class="sum-row"><span>Mã <c:out value="${selectedOrder.couponCode}"/></span><span style="color:var(--ok)">− <fmt:formatNumber value="${selectedOrder.discount}" type="number" maxFractionDigits="0"/> ₫</span></div>
                </c:if>
                <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${selectedOrder.total}" type="number" maxFractionDigits="0"/> ₫</span></div>
              </div>
            </div>
          </div>

          <div style="display:flex;flex-direction:column;gap:18px">
            <c:if test="${canManage}">
              <div class="panel"><div class="panel-head"><h3>Cập nhật trạng thái</h3></div><div class="panel-pad">
                <form method="post" action="${ctx}/admin/order/status">
                  <input type="hidden" name="code" value="${selectedOrder.code}">
                  <input type="hidden" name="returnUrl" value="${ctx}/admin/orders?code=${selectedOrder.code}">
                  <div class="field">
                    <label>Trạng thái mới</label>
                    <select class="select" name="status">
                      <option value="CONFIRMED">Đã xác nhận</option>
                      <option value="SHIPPING">Đang giao</option>
                      <option value="DELIVERED">Đã giao</option>
                      <option value="CANCELLED">Đã huỷ</option>
                    </select>
                  </div>
                  <div class="field">
                    <label>Ghi chú nội bộ</label>
                    <textarea class="textarea" name="note" maxlength="300" placeholder="Ví dụ: khách hẹn giao sau 18h"></textarea>
                  </div>
                  <button type="submit" class="btn block">Cập nhật đơn</button>
                </form>
              </div></div>
            </c:if>
            <div class="panel"><div class="panel-head"><h3>Nhật ký xử lý</h3></div><div class="panel-pad">
              <div class="timeline">
                <c:forEach var="ev" items="${selectedOrder.timeline}">
                  <div class="ev ${ev.done ? 'done' : ''}"><b><c:out value="${ev.label}"/></b>
                    <span><c:if test="${not empty ev.time}"><fmt:formatDate value="${ev.time}" pattern="dd/MM/yyyy · HH:mm"/></c:if></span></div>
                </c:forEach>
              </div>
            </div></div>
          </div>
        </div>
      </c:if>
    </div>
  </div>
</div>
</body>
</html>
