<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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

        <jsp:include page="/common/header.jsp"/>

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
                        <label for="deliveryTimeSlot">Khung giờ nhận hàng (tuỳ chọn)</label>
                        <input type="text" id="deliveryTimeSlot" name="deliveryTimeSlot"
                               value="${param.deliveryTimeSlot}" placeholder="Vd: 8h - 12h">
                    </div>

                    <div class="form-group">
                        <label for="notes">Ghi chú (tuỳ chọn)</label>
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

                    <!-- KHỐI NHẬP VÀ CHỌN MÃ KHUYẾN MÃI (CHUYỂN TỪ CART SANG) -->
                    <form class="voucher-box" action="${pageContext.request.contextPath}/apply-voucher" method="post" style="margin-top: 20px; margin-bottom: 15px;">
                        <label class="form-label" for="voucher-code" style="font-weight: 600; display: block; margin-bottom: 5px;">Mã khuyến mãi</label>

                        <div class="voucher-inline" style="display: flex; gap: 8px;">
                            <input id="voucher-code" class="form-control" type="text" name="voucherCode" 
                                   value="${not empty sessionScope.appliedPromo ? sessionScope.appliedPromo.code : ''}" 
                                   placeholder="Nhập mã...">
                            <button class="btn btn-app-outline" type="submit">Áp dụng</button>
                        </div>

                        <div class="mt-2 d-flex justify-content-between align-items-center" style="display: flex; justify-content: space-between; margin-top: 8px; font-size: 0.9rem;">
                            <!-- Nút dẫn sang trang chọn mã có sẵn -->
                            <a href="${pageContext.request.contextPath}/vouchers" style="text-decoration: none; color: #0d6efd;">
                                Chọn mã có sẵn
                            </a>

                            <!-- Nút gỡ bỏ mã nếu đã áp dụng -->
                            <c:if test="${not empty sessionScope.appliedPromo}">
                                <a href="${pageContext.request.contextPath}/remove-voucher" class="text-danger" style="text-decoration: none; color: #dc3545;">Gỡ bỏ mã</a>
                            </c:if>
                        </div>
                    </form>

                    <!-- HIỂN THỊ TIỀN GIẢM -->
                    <c:if test="${not empty sessionScope.appliedPromo}">
                        <div class="summary-total text-success" style="font-size: 1rem; border-top: none; padding-top: 0; padding-bottom: 10px;">
                            Giảm giá (${sessionScope.appliedPromo.code}):
                            <strong>- <fmt:formatNumber value="${sessionScope.discountAmount}" type="number" groupingUsed="true"/> đ</strong>
                        </div>
                    </c:if>

                    <div class="summary-total">
                        Tổng cộng:
                        <c:set var="finalCheckoutTotal" value="${cartTotal - (not empty sessionScope.discountAmount ? sessionScope.discountAmount : 0)}" />
                        <strong><fmt:formatNumber value="${finalCheckoutTotal < 0 ? 0 : finalCheckoutTotal}" type="number" groupingUsed="true"/> đ</strong>
                    </div>
                </div>
            </div>
        </div>

        <jsp:include page="/common/footer.jsp"/>

    </body>
</html>
