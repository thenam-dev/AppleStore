<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Thanh toán - AppleStore</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="container checkout-page">
    <h1>Thanh toán đơn hàng</h1>

    <c:if test="${not empty errorMsg}">
        <div class="alert alert-error">${errorMsg}</div>
    </c:if>

    <div class="checkout-layout">
        <form method="post" action="${pageContext.request.contextPath}/checkout" class="checkout-form">
            <div class="form-group">
                <label for="recipientName">Tên người nhận</label>
                <input type="text" id="recipientName" name="recipientName"
                       value="${param.recipientName}" maxlength="100">
                <c:if test="${not empty fieldErrors.recipientName}">
                    <span class="field-error">${fieldErrors.recipientName}</span>
                </c:if>
            </div>

            <div class="form-group">
                <label for="recipientPhone">Số điện thoại</label>
                <input type="text" id="recipientPhone" name="recipientPhone"
                       value="${param.recipientPhone}" maxlength="15">
                <c:if test="${not empty fieldErrors.recipientPhone}">
                    <span class="field-error">${fieldErrors.recipientPhone}</span>
                </c:if>
            </div>

            <div class="form-group">
                <label for="deliveryAddress">Địa chỉ giao hàng</label>
                <textarea id="deliveryAddress" name="deliveryAddress" maxlength="500">${param.deliveryAddress}</textarea>
                <c:if test="${not empty fieldErrors.deliveryAddress}">
                    <span class="field-error">${fieldErrors.deliveryAddress}</span>
                </c:if>
            </div>

            <div class="form-group">
                <label for="deliveryTimeSlot">Khung giờ nhận hàng (tùy chọn)</label>
                <input type="text" id="deliveryTimeSlot" name="deliveryTimeSlot"
                       value="${param.deliveryTimeSlot}" placeholder="Ví dụ: 8h - 12h">
            </div>

            <div class="form-group">
                <label for="notes">Ghi chú (tùy chọn)</label>
                <textarea id="notes" name="notes" maxlength="300">${param.notes}</textarea>
            </div>

            <div class="form-group">
                <label>Phương thức thanh toán</label>
                <label class="radio-inline">
                    <input type="radio" name="paymentMethod" value="CK"
                           ${empty param.paymentMethod or param.paymentMethod == 'CK' ? 'checked' : ''}>
                    Chuyển khoản qua SePay (quét mã QR)
                </label>
                <label class="radio-inline">
                    <input type="radio" name="paymentMethod" value="COD"
                           ${param.paymentMethod == 'COD' ? 'checked' : ''}>
                    Thanh toán khi nhận hàng (COD)
                </label>
                <c:if test="${not empty fieldErrors.paymentMethod}">
                    <span class="field-error">${fieldErrors.paymentMethod}</span>
                </c:if>
            </div>

            <button type="submit" class="btn btn-primary btn-lg">Xác nhận đặt hàng</button>
        </form>

        <div class="order-summary">
            <h2>Đơn hàng của bạn</h2>
            <table class="summary-table">
                <c:forEach var="item" items="${cartItems}">
                    <tr>
                        <td>${item.productName} (${item.variantLabel}) x${item.quantity}</td>
                        <td><fmt:formatNumber value="${item.lineTotal}" type="number" groupingUsed="true"/> đ</td>
                    </tr>
                </c:forEach>
            </table>
            <div class="summary-total">
                Tổng cộng:
                <strong><fmt:formatNumber value="${cartTotal}" type="number" groupingUsed="true"/> đ</strong>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

</body>
</html>
