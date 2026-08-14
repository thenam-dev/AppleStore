<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore | Chọn mã khuyến mãi</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="site-body">

    <c:set var="ctx" value="${pageContext.request.contextPath}" />

    <!-- Header (Tái sử dụng chung của Customer) -->
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <main>
        <!-- Tiêu đề trang -->
        <section class="section-block">
            <div class="container">
                <nav aria-label="Breadcrumb">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="${ctx}/index.jsp">Trang chủ</a></li>
                        <li class="breadcrumb-item"><a href="${ctx}/cart">Giỏ hàng</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Khuyến mãi</li>
                    </ol>
                </nav>
                <div class="store-page-heading">
                    <div>
                        <span class="eyebrow">Khuyến mãi</span>
                        <h1>Mã ưu đãi dành cho bạn</h1>
                        <p>Chọn một mã giảm giá phù hợp nhất với đơn hàng hiện tại của bạn.</p>
                    </div>
                    <div class="store-heading-actions mt-3 mt-md-0">
                        <a class="btn btn-app-outline" href="${ctx}/checkout">Quay lại Thanh toán</a>
                    </div>
                </div>

                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger">${errorMsg}</div>
                </c:if>
            </div>
        </section>

        <!-- Danh sách Voucher -->
        <section class="section-block section-soft">
            <div class="container" style="max-width: 800px;">
                <c:choose>
                    <c:when test="${empty vouchers}">
                        <!-- Trạng thái trống sử dụng UI chuẩn của empty-cart-panel -->
                        <div class="empty-cart-panel">
                            <span class="eyebrow">Rất tiếc</span>
                            <h2>Không có mã giảm giá nào khả dụng</h2>
                            <p>Hiện tại không có chương trình khuyến mãi nào có thể áp dụng, hoặc bạn đã sử dụng hết các mã.</p>
                            <div class="hero-actions">
                                <a class="btn btn-app-primary" href="${ctx}/checkout">Trở lại Thanh toán</a>
                                <a class="btn btn-app-outline" href="${ctx}/products">Tiếp tục mua sắm</a>
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="d-flex flex-column gap-4">
                            <c:forEach var="promo" items="${vouchers}">
                                <!-- Dùng checkout-card để tạo khung viền chuẩn AppleStore -->
                                <section class="checkout-card d-flex flex-column flex-md-row justify-content-between align-items-md-center gap-3">
                                    <div>
                                        <div class="d-flex align-items-center gap-2 mb-2">
                                            <h2 class="mb-0" style="font-size: 1.25rem;">${promo.code}</h2>
                                            <span class="status-badge status-in-stock">Có sẵn</span>
                                        </div>
                                        <p class="mb-2" style="font-size: 0.95rem;">
                                            Giảm
                                            <strong>
                                                <c:choose>
                                                    <c:when test="${promo.discountType == 'PERCENT'}">${promo.discountValue}%</c:when>
                                                    <c:otherwise><fmt:formatNumber value="${promo.discountValue}" pattern="#,##0"/> đ</c:otherwise>
                                                </c:choose>
                                            </strong>
                                            trên tổng giá trị đơn hàng.
                                        </p>
                                        <div class="text-muted small d-flex flex-column gap-1">
                                            <span>Đơn tối thiểu: <strong><fmt:formatNumber value="${promo.minOrderValue}" pattern="#,##0"/> đ</strong></span>
                                            <span>HSD: ${promo.validUntil.format(dateFormatter)}</span>
                                        </div>
                                    </div>
                                    <div class="mt-2 mt-md-0">
                                        <!-- SỬA: phải POST tới /apply-voucher (servlet xử lý mã), không phải /checkout -->
                                        <form action="${ctx}/apply-voucher" method="post">
                                            <input type="hidden" name="voucherCode" value="${promo.code}">
                                            <button type="submit" class="btn btn-app-primary w-100">Dùng ngay</button>
                                        </form>
                                    </div>
                                </section>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${ctx}/assets/js/main.js"></script>
</body>
</html>
