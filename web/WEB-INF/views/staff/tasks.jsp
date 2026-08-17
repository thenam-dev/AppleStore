<%--
  delivery/tasks.jsp — danh sách nhiệm vụ giao hàng của Shipper (Có hiển thị thông báo flash).
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

<div style="min-height: 100vh; background-color: var(--bg, #f8f9fa); padding: 20px;">
  <div style="max-width: 1200px; margin: 0 auto;">
    
    <div class="adm-bar" style="background: #fff; padding: 15px 25px; border-radius: 8px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; box-shadow: 0 1px 3px rgba(0,0,0,0.05);">
      <h2 style="margin: 0; font-size: 20px;">📦 Nhiệm vụ giao hàng của tôi</h2>
      <div class="who"><span class="av" style="font-weight: 600;"><c:out value="${sessionScope.user.fullName}"/></span></div>
    </div>

    <!-- KHUNG HIỂN THỊ THÔNG BÁO (FLASH MESSAGE) -->
    <div style="margin-bottom: 20px;">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
    </div>

    <div class="adm-body" style="padding: 0;">
      <div class="panel" style="background: #fff; border-radius: 8px; box-shadow: 0 1px 3px rgba(0,0,0,0.05); overflow: hidden;">
        <div class="panel-head" style="padding: 15px 20px; border-bottom: 1px solid var(--line, #eee);">
          <h3 style="margin: 0; font-size: 16px;">Danh sách đơn cần giao</h3>
        </div>

        <div style="padding: 20px;">
          <c:choose>
            <c:when test="${empty tasks}">
              <div class="empty" style="text-align: center; padding: 40px; color: var(--ash);">
                <div class="ring" style="margin: 0 auto 12px;"><svg width="26" height="26"><use href="#i-truck"/></svg></div>
                <h3>Hiện tại bạn không có đơn hàng nào cần giao</h3>
                <p style="font-size: 13px;">Các đơn hàng mới được phân công tự động từ hệ thống sẽ hiển thị tại đây.</p>
              </div>
            </c:when>
            <c:otherwise>
              <table class="table" style="width: 100%; border-collapse: collapse;">
                <thead>
                  <tr style="text-align: left; border-bottom: 2px solid var(--line, #eee);">
                    <th style="padding: 10px;">Mã đơn</th>
                    <th style="padding: 10px;">Khách hàng</th>
                    <th style="padding: 10px;">Số điện thoại</th>
                    <th style="padding: 10px;">Địa chỉ giao hàng</th>
                    <th style="padding: 10px; text-align: right;">Tổng tiền thu</th>
                    <th style="padding: 10px; text-align: right;">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="t" items="${tasks}">
                    <tr style="border-bottom: 1px solid var(--line, #eee);">
                      <td style="padding: 12px 10px;" class="num"><b>#${t.orderId}</b></td>
                      <td style="padding: 12px 10px;"><c:out value="${t.recipientName}"/></td>
                      <td style="padding: 12px 10px;"><c:out value="${t.recipientPhone}"/></td>
                      <td style="padding: 12px 10px;"><c:out value="${t.deliveryAddress}"/></td>
                      <td style="padding: 12px 10px; text-align: right;" class="num"><fmt:formatNumber value="${t.finalAmount}" type="number" maxFractionDigits="0"/> đ</td>
                      <td style="padding: 12px 10px; text-align: right;" class="row-actions">
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
            </c:otherwise>
          </c:choose>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>