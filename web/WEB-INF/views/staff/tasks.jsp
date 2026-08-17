<%--
  delivery/tasks.jsp — danh sách nhiệm vụ giao hàng của Shipper.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Nhiệm vụ giao hàng · Shipper AppleStore"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <div class="adm-main" style="margin-left: 0;">
    <div class="adm-bar">
      <h2>Nhiệm vụ giao hàng của tôi</h2>
      <div class="who"><span class="av"><c:out value="${sessionScope.user.fullName}"/></span></div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="panel">
        <div class="panel-head"><h3>Danh sách đơn cần giao</h3></div>

        <c:choose>
          <c:when test="${empty tasks}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-truck"/></svg></div>
              <h3>Hiện tại bạn không có đơn hàng nào cần giao</h3>
              <p>Các đơn hàng mới được phân công tự động sẽ hiển thị tại đây.</p>
            </div>
          </c:when>
          <c:otherwise>
            <table class="table">
              <thead>
                <tr>
                  <th>Mã đơn</th>
                  <th>Khách hàng</th>
                  <th>Số điện thoại</th>
                  <th>Địa chỉ giao hàng</th>
                  <th>Tổng tiền thu</th>
                  <th style="text-align:right">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                <c:forEach var="t" items="${tasks}">
                  <tr>
                    <td class="num"><b>#${t.orderId}</b></td>
                    <td><c:out value="${t.recipientName}"/></td>
                    <td><c:out value="${t.recipientPhone}"/></td>
                    <td><c:out value="${t.deliveryAddress}"/></td>
                    <td class="num"><fmt:formatNumber value="${t.finalAmount}" type="number" maxFractionDigits="0"/> đ</td>
                    <td class="row-actions">
                      <form method="post" action="${ctx}/delivery/complete">
                        <input type="hidden" name="orderId" value="${t.orderId}">
                        <button type="submit" class="btn sm ok" onclick="return confirm('Xác nhận đã giao thành công đơn hàng #${t.orderId}?');">
                          Xác nhận giao thành công
                        </button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>