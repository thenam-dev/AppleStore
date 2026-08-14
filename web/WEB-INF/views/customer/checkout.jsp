<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore | Thanh toán</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="site-body">

<c:set var="ctx" value="${pageContext.request.contextPath}" />

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main>
    <section class="section-block">
        <div class="container">
            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${ctx}/index.jsp">Trang chủ</a></li>
                    <li class="breadcrumb-item"><a href="${ctx}/cart">Giỏ hàng</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Thanh toán</li>
                </ol>
            </nav>
            <div class="store-page-heading">
                <div>
                    <span class="eyebrow">Bước cuối cùng</span>
                    <h1>Thanh toán đơn hàng</h1>
                    <p>Kiểm tra lại thông tin giao hàng và chọn phương thức thanh toán phù hợp với bạn.</p>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger">${errorMsg}</div>
            </c:if>
        </div>
    </section>

    <section class="section-block section-soft">
        <div class="container">
            <div class="cart-layout">
                <div class="cart-filled">
                    <div class="cart-list-card">
                        <div class="cart-list-head">
                            <div>
                                <h2>Thông tin giao hàng</h2>
                                <p>Điền đầy đủ thông tin để cửa hàng liên hệ và giao hàng chính xác.</p>
                            </div>
                        </div>

                        <form method="post" action="${ctx}/checkout" class="filter-panel" id="checkout-form">
                            <div class="row g-3">
                                <div class="col-md-6 filter-group">
                                    <label class="form-label" for="recipientName">Tên người nhận</label>
                                    <input type="text" id="recipientName" name="recipientName"
                                           class="form-control ${not empty fieldErrors.recipientName ? 'is-invalid' : ''}"
                                           value="${param.recipientName}" maxlength="100" required>
                                    <c:if test="${not empty fieldErrors.recipientName}">
                                        <div class="invalid-feedback d-block">${fieldErrors.recipientName}</div>
                                    </c:if>
                                </div>

                                <div class="col-md-6 filter-group">
                                    <label class="form-label" for="recipientPhone">Số điện thoại</label>
                                    <input type="text" id="recipientPhone" name="recipientPhone"
                                           class="form-control ${not empty fieldErrors.recipientPhone ? 'is-invalid' : ''}"
                                           value="${param.recipientPhone}" maxlength="15" required>
                                    <c:if test="${not empty fieldErrors.recipientPhone}">
                                        <div class="invalid-feedback d-block">${fieldErrors.recipientPhone}</div>
                                    </c:if>
                                </div>

                                <div class="col-12 filter-group">
                                    <label class="form-label" for="deliveryAddress">Địa chỉ giao hàng</label>
                                    <textarea id="deliveryAddress" name="deliveryAddress" rows="3" maxlength="500"
                                              class="form-control ${not empty fieldErrors.deliveryAddress ? 'is-invalid' : ''}"
                                              required>${param.deliveryAddress}</textarea>
                                    <c:if test="${not empty fieldErrors.deliveryAddress}">
                                        <div class="invalid-feedback d-block">${fieldErrors.deliveryAddress}</div>
                                    </c:if>
                                </div>

                                <div class="col-md-6 filter-group">
                                    <label class="form-label" for="deliveryTimeSlot">Khung giờ nhận hàng (tuỳ chọn)</label>
                                    <input type="text" id="deliveryTimeSlot" name="deliveryTimeSlot"
                                           class="form-control" value="${param.deliveryTimeSlot}"
                                           placeholder="Ví dụ: 8h - 12h">
                                </div>

                                <div class="col-md-6 filter-group">
                                    <label class="form-label" for="notes">Ghi chú (tuỳ chọn)</label>
                                    <input type="text" id="notes" name="notes" maxlength="300"
                                           class="form-control" value="${param.notes}"
                                           placeholder="Ví dụ: gọi trước khi giao">
                                </div>
                            </div>

                            <div class="detail-selector-group mt-4">
                                <div class="selector-head">
                                    <strong>Phương thức thanh toán</strong>
                                </div>
                                <div class="d-flex flex-column gap-2 mt-2">
                                    <label class="option-chip payment-option ${empty param.paymentMethod or param.paymentMethod == 'CK' ? 'active' : ''}">
                                        <input class="form-check-input me-2" type="radio" name="paymentMethod" value="CK"
                                               ${empty param.paymentMethod or param.paymentMethod == 'CK' ? 'checked' : ''}>
                                        Chuyển khoản qua SePay (quét mã QR)
                                    </label>
                                    <label class="option-chip payment-option ${param.paymentMethod == 'COD' ? 'active' : ''}">
                                        <input class="form-check-input me-2" type="radio" name="paymentMethod" value="COD"
                                               ${param.paymentMethod == 'COD' ? 'checked' : ''}>
                                        Thanh toán khi nhận hàng (COD)
                                    </label>
                                </div>
                                <c:if test="${not empty fieldErrors.paymentMethod}">
                                    <div class="text-danger small mt-2">${fieldErrors.paymentMethod}</div>
                                </c:if>
                            </div>
                        </form>
                    </div>
                </div>

                <aside class="cart-summary-card">
                    <div class="summary-card-head">
                        <h2>Đơn hàng của bạn</h2>
                        <p>Kiểm tra lại sản phẩm trước khi xác nhận đặt hàng.</p>
                    </div>

                    <div class="summary-lines">
                        <c:forEach var="item" items="${cartItems}">
                            <div class="summary-row">
                                <span>${item.productName} (${item.variantLabel}) &times; ${item.quantity}</span>
                                <strong><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0"/> đ</strong>
                            </div>
                        </c:forEach>
                    </div>

                    <form action="${ctx}/apply-voucher" method="post" class="voucher-box">
                        <label class="form-label" for="voucher-code">Mã khuyến mãi</label>
                        <div class="d-flex gap-2">
                            <input id="voucher-code" class="form-control" type="text" name="voucherCode"
                                   value="${not empty sessionScope.appliedPromo ? sessionScope.appliedPromo.code : ''}"
                                   placeholder="Nhập mã...">
                            <button class="btn btn-app-outline" type="submit">Áp dụng</button>
                        </div>
                        <div class="d-flex justify-content-between align-items-center mt-2 small">
                            <a href="${ctx}/vouchers">Chọn mã có sẵn</a>
                            <c:if test="${not empty sessionScope.appliedPromo}">
                                <a href="${ctx}/remove-voucher" class="text-danger">Gỡ bỏ mã</a>
                            </c:if>
                        </div>
                    </form>

                    <c:if test="${not empty sessionScope.appliedPromo}">
                        <div class="summary-row text-success">
                            <span>Giảm giá (${sessionScope.appliedPromo.code})</span>
                            <strong>- <fmt:formatNumber value="${sessionScope.discountAmount}" pattern="#,##0"/> đ</strong>
                        </div>
                    </c:if>

                    <c:set var="finalCheckoutTotal"
                           value="${cartTotal - (not empty sessionScope.discountAmount ? sessionScope.discountAmount : 0)}" />
                    <div class="summary-total">
                        <span>Tổng cộng</span>
                        <strong><fmt:formatNumber value="${finalCheckoutTotal < 0 ? 0 : finalCheckoutTotal}" pattern="#,##0"/> đ</strong>
                    </div>

                    <div class="summary-actions">
                        <button type="submit" form="checkout-form" class="btn btn-app-primary w-100 btn-lg">Xác nhận đặt hàng</button>
                        <a class="btn btn-app-outline w-100" href="${ctx}/cart">Quay lại giỏ hàng</a>
                    </div>
                </aside>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${ctx}/assets/js/main.js"></script>
<script>
    // Chỉ đổi style active của 2 ô radio khi bấm chọn, không có business logic
    document.querySelectorAll('.payment-option').forEach(function (label) {
        label.addEventListener('click', function () {
            document.querySelectorAll('.payment-option').forEach(function (l) {
                l.classList.remove('active');
            });
            label.classList.add('active');
        });
    });
</script>
</body>
</html>
