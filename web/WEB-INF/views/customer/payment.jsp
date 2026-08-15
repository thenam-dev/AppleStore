<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore | Thanh toán chuyển khoản</title>
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
                    <li class="breadcrumb-item active" aria-current="page">Thanh toán chuyển khoản</li>
                </ol>
            </nav>
            <div class="store-page-heading">
                <div>
                    <span class="eyebrow">Đơn hàng #${order.orderId}</span>
                    <h1>Quét mã QR để thanh toán</h1>
                    <p>Mở app ngân hàng, quét mã bên dưới và chuyển khoản đúng số tiền, đúng nội dung.</p>
                </div>
            </div>
        </div>
    </section>

    <section class="section-block section-soft">
        <div class="container" style="max-width: 640px;">
            <div class="cart-list-card text-center">
                <c:choose>
                    <c:when test="${not empty qrCodeUrl}">
                        <img src="${qrCodeUrl}" alt="Mã QR thanh toán" style="max-width: 320px; width: 100%; margin: 0 auto 24px;">

                        <div class="summary-lines text-start">
                            <div class="summary-row">
                                <span>Số tiền cần chuyển</span>
                                <strong><fmt:formatNumber value="${order.finalAmount}" pattern="#,##0"/> đ</strong>
                            </div>
                            <div class="summary-row">
                                <span>Nội dung chuyển khoản</span>
                                <strong>DH${order.orderId}</strong>
                            </div>
                            <div class="summary-row">
                                <span>Trạng thái</span>
                                <strong>Đang chờ thanh toán</strong>
                            </div>
                        </div>

                        <div class="alert alert-warning mt-3 text-start">
                            Vui lòng nhập <strong>đúng nội dung chuyển khoản</strong> ở trên để cửa hàng đối soát đơn hàng chính xác.
                            Mã QR có hiệu lực trong 15 phút kể từ lúc tạo đơn.
                        </div>

                        <%--
                            DEMO-ONLY: đồ án dùng QR tĩnh, không có webhook SePay thật để
                            tự động xác nhận giao dịch. Nút dưới đây cho khách TỰ xác nhận
                            đã chuyển khoản để có thể demo trọn luồng - hệ thống thật KHÔNG
                            được xác nhận thanh toán theo cách này (bắt buộc phải qua webhook
                            có chữ ký xác thực từ cổng thanh toán).
                        --%>
                        <form action="${ctx}/payment" method="post" class="mt-4">
                            <input type="hidden" name="orderId" value="${order.orderId}">
                            <button type="submit" class="btn btn-app-primary w-100 btn-lg">Tôi đã chuyển khoản, xác nhận</button>
                        </form>
                        <a class="btn btn-app-outline w-100 mt-2" href="${ctx}/products">Tiếp tục mua sắm</a>
                    </c:when>
                    <c:otherwise>
                        <div class="empty-cart-panel">
                            <h2>Không tìm thấy thông tin thanh toán</h2>
                            <p>Đơn hàng có thể đã được xử lý hoặc chưa tạo được mã QR. Vui lòng kiểm tra lại giỏ hàng.</p>
                            <a class="btn btn-app-primary" href="${ctx}/cart">Quay lại giỏ hàng</a>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${ctx}/assets/js/main.js"></script>
</body>
</html>
