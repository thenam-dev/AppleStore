<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore | Đặt hàng thành công</title>
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
                    <li class="breadcrumb-item active" aria-current="page">Đặt hàng thành công</li>
                </ol>
            </nav>
            <div class="store-page-heading">
                <div>
                    <span class="eyebrow">Cảm ơn bạn</span>
                    <h1>Đơn hàng #${order.orderId} đã được ghi nhận</h1>
                    <p>Cửa hàng sẽ liên hệ xác nhận và giao hàng trong thời gian sớm nhất.</p>
                </div>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success">${successMsg}</div>
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
                                <h2>Sản phẩm đã đặt</h2>
                                <p>Chi tiết các sản phẩm trong đơn hàng của bạn.</p>
                            </div>
                        </div>

                        <c:forEach var="item" items="${orderItems}">
                            <article class="cart-item">
                                <div class="cart-item-body">
                                    <div class="cart-item-main">
                                        <div>
                                            <h3>${item.productNameSnapshot}</h3>
                                            <p>
                                                ${item.variantLabelSnapshot}
                                                <c:if test="${not empty item.addonLabelSnapshot}">
                                                    &middot; Dịch vụ thêm: ${item.addonLabelSnapshot}
                                                </c:if>
                                            </p>
                                        </div>
                                    </div>
                                    <div class="cart-item-meta">
                                        <span>
                                            Đơn giá:
                                            <strong><fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/> đ</strong>
                                            &times; ${item.quantity}
                                        </span>
                                        <span>
                                            Thành tiền:
                                            <strong><fmt:formatNumber value="${item.subtotal}" pattern="#,##0"/> đ</strong>
                                        </span>
                                    </div>
                                </div>
                            </article>
                        </c:forEach>
                    </div>

                    <div class="cart-list-card mt-4">
                        <div class="cart-list-head">
                            <div>
                                <h2>Thông tin giao hàng</h2>
                            </div>
                        </div>
                        <div class="summary-lines">
                            <div class="summary-row">
                                <span>Người nhận</span>
                                <strong>${order.recipientName} &ndash; ${order.recipientPhone}</strong>
                            </div>
                            <div class="summary-row">
                                <span>Địa chỉ</span>
                                <strong>${order.deliveryAddress}</strong>
                            </div>
                            <c:if test="${not empty order.deliveryTimeSlot}">
                                <div class="summary-row">
                                    <span>Khung giờ nhận hàng</span>
                                    <strong>${order.deliveryTimeSlot}</strong>
                                </div>
                            </c:if>
                            <c:if test="${not empty order.notes}">
                                <div class="summary-row">
                                    <span>Ghi chú</span>
                                    <strong>${order.notes}</strong>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>

                <aside class="cart-summary-card">
                    <div class="summary-card-head">
                        <h2>Tóm tắt đơn hàng</h2>
                    </div>

                    <div class="summary-lines">
                        <div class="summary-row">
                            <span>Tạm tính</span>
                            <strong><fmt:formatNumber value="${order.totalAmount}" pattern="#,##0"/> đ</strong>
                        </div>
                        <c:if test="${order.discountAmount > 0}">
                            <div class="summary-row text-success">
                                <span>Giảm giá</span>
                                <strong>- <fmt:formatNumber value="${order.discountAmount}" pattern="#,##0"/> đ</strong>
                            </div>
                        </c:if>
                        <div class="summary-row">
                            <span>Phí vận chuyển</span>
                            <strong><fmt:formatNumber value="${order.deliveryFee}" pattern="#,##0"/> đ</strong>
                        </div>
                        <div class="summary-row">
                            <span>Phương thức thanh toán</span>
                            <strong>${order.paymentMethod == 'COD' ? 'Thanh toán khi nhận hàng' : 'Chuyển khoản (SePay)'}</strong>
                        </div>
                        <div class="summary-row">
                            <span>Trạng thái đơn</span>
                            <strong>${order.status}</strong>
                        </div>
                    </div>

                    <div class="summary-total">
                        <span>Tổng cộng</span>
                        <strong><fmt:formatNumber value="${order.finalAmount}" pattern="#,##0"/> đ</strong>
                    </div>

                    <div class="summary-actions">
                        <a class="btn btn-app-primary w-100" href="${ctx}/products">Tiếp tục mua sắm</a>
                        <a class="btn btn-app-outline w-100" href="${ctx}/index.jsp">Về trang chủ</a>
                    </div>
                </aside>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${ctx}/assets/js/main.js"></script>
</body>
</html>
