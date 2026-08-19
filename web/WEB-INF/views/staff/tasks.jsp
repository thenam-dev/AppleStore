<%--
  delivery/tasks.jsp — danh sách nhiệm vụ giao hàng của Shipper kèm sidebar hệ thống.
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
  <%-- Đặt activeAdmin để sidebar nhận diện và highlight đúng mục --%>
  <c:set var="activeAdmin" value="tasks"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>📦 Nhiệm vụ giao hàng của tôi</h2>
      <div class="who">
        <span class="av" style="font-weight: 600;"><c:out value="${sessionScope.user.fullName}"/></span>
      </div>
    </div>

    <div class="adm-body">
      <!-- KHUNG HIỂN THỊ THÔNG BÁO (FLASH MESSAGE) -->
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="panel">
        <div class="panel-head">
          <h3>Danh sách đơn cần giao</h3>
        </div>

        <div class="panel-pad">
          <c:choose>
            <c:when test="${empty tasks}">
              <div class="empty" style="text-align: center; padding: 40px; color: var(--ash);">
                <div class="ring" style="margin: 0 auto 12px;"><svg width="26" height="26"><use href="#i-truck"/></svg></div>
                <h3>Hiện tại bạn không có đơn hàng nào cần giao</h3>
                <p style="font-size: 13px;">Các đơn hàng mới được phân công từ hệ thống sẽ hiển thị tại đây.</p>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-scroll">
                <table class="table" style="width: 100%; border-collapse: collapse;">
                  <thead>
                    <tr>
                      <th>Mã đơn</th>
                      <th>Khách hàng</th>
                      <th>Số điện thoại</th>
                      <th>Địa chỉ giao hàng</th>
                      <th style="text-align: right;">Tổng tiền thu</th>
                      <th style="text-align: right;">Thao tác</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach var="t" items="${tasks}">
                      <tr>
                        <td class="num"><b>#${t.orderId}</b></td>
                        <td><c:out value="${t.recipientName}"/></td>
                        <td><c:out value="${t.recipientPhone}"/></td>
                        <td><c:out value="${t.deliveryAddress}"/></td>
                        <td class="num" style="text-align: right;"><fmt:formatNumber value="${t.finalAmount}" type="number" maxFractionDigits="0"/> đ</td>
                        <td class="row-actions" style="text-align: right;">
                          <form method="post" action="${ctx}/delivery/complete" style="display: inline;">
                            <input type="hidden" name="orderId" value="${t.orderId}">
                            <button type="submit" class="btn sm ok">
                              ✅ Xác nhận giao thành công
                            </button>
                          </form>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
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