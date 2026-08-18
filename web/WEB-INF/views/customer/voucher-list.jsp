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
    <style>
        /* CSS bổ sung để tạo độ mượt cho Card chuẩn Apple */
        .voucher-card {
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            border: 1px solid #e5e5e5;
            background: #fff;
        }
        .voucher-card:hover {
            box-shadow: 0 4px 12px rgba(0,0,0,0.05);
        }
        .icon-ticket {
            color: #0066cc; /* Apple Blue */
            background: #f5f5f7;
            padding: 8px;
            border-radius: 50%;
            display: inline-flex;
        }
        .btn-apple {
            background-color: #0071e3;
            color: white;
            border-radius: 20px; /* Bo góc tròn */
            padding: 8px 20px;
            font-weight: 500;
        }
        .btn-apple:hover {
            background-color: #0077ed;
            color: white;
        }
        .status-badge {
            font-size: 0.75rem;
            padding: 4px 10px;
            border-radius: 12px;
            background-color: #e3f2fd;
            color: #0066cc;
            font-weight: 600;
        }
    </style>
</head>
<body class="site-body bg-light">

    <c:set var="ctx" value="${pageContext.request.contextPath}" />

    <!-- Header -->
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <main class="py-4 py-md-5">
        <!-- Tiêu đề & Breadcrumb -->
        <section class="section-block mb-4">
            <div class="container" style="max-width: 800px;">
                <nav aria-label="Breadcrumb">
                    <ol class="breadcrumb app-breadcrumb text-muted small">
                        <li class="breadcrumb-item"><a href="${ctx}/index.jsp" class="text-decoration-none text-muted">Trang chủ</a></li>
                        <li class="breadcrumb-item"><a href="${ctx}/cart" class="text-decoration-none text-muted">Giỏ hàng</a></li>
                        <li class="breadcrumb-item active text-dark fw-medium" aria-current="page">Khuyến mãi</li>
                    </ol>
                </nav>

                <div class="d-flex flex-column flex-md-row justify-content-between align-items-md-end mt-4 mb-2">
                    <div>
                        <span class="text-uppercase fw-bold text-muted" style="font-size: 12px; letter-spacing: 1px;">Khuyến mãi</span>
                        <h1 class="fw-bold mt-1 mb-2" style="font-size: 2rem;">Mã ưu đãi của bạn</h1>
                        <p class="text-secondary mb-0">Chọn một mã giảm giá phù hợp nhất với đơn hàng hiện tại.</p>
                    </div>
                    <div class="mt-3 mt-md-0">
                        <a class="btn btn-outline-dark rounded-pill px-4" href="${ctx}/checkout">Quay lại Thanh toán</a>
                    </div>
                </div>

                <!-- Cảnh báo lỗi -->
                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger d-flex align-items-center mt-3 rounded-4 border-0" role="alert">
                        <svg width="20" height="20" fill="currentColor" class="bi bi-exclamation-circle me-2" viewBox="0 0 16 16"><path d="M8 15A7 7 0 1 1 8 1a7 7 0 0 1 0 14m0 1A8 8 0 1 0 8 0a8 8 0 0 0 0 16"/><path d="M7.002 11a1 1 0 1 1 2 0 1 1 0 0 1-2 0zM7.1 4.995a.905.905 0 1 1 1.8 0l-.35 3.507a.552.552 0 0 1-1.1 0z"/></svg>
                        ${errorMsg}
                    </div>
                </c:if>
            </div>
        </section>

        <!-- Danh sách Voucher -->
        <section class="section-block">
            <div class="container" style="max-width: 800px;">
                <c:choose>
                    <c:when test="${empty vouchers}">
                        <!-- Trạng thái trống (Empty State) -->
                        <div class="empty-cart-panel text-center py-5 bg-white rounded-4 border">
                            <svg width="64" height="64" fill="var(--bs-gray-400)" class="mb-3" viewBox="0 0 16 16">
                                <path d="M2.5 1A1.5 1.5 0 0 0 1 2.5v11A1.5 1.5 0 0 0 2.5 15h11a1.5 1.5 0 0 0 1.5-1.5v-11A1.5 1.5 0 0 0 13.5 1zM2 2.5a.5.5 0 0 1 .5-.5h11a.5.5 0 0 1 .5.5v11a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5z"/>
                                <path d="M5.5 4a.5.5 0 0 0-.5.5v7a.5.5 0 0 0 1 0v-7a.5.5 0 0 0-.5-.5M8 4a.5.5 0 0 0-.5.5v7a.5.5 0 0 0 1 0v-7A.5.5 0 0 0 8 4m2.5 0a.5.5 0 0 0-.5.5v7a.5.5 0 0 0 1 0v-7a.5.5 0 0 0-.5-.5"/>
                            </svg>
                            <h3 class="fw-bold fs-4">Không có mã khả dụng</h3>
                            <p class="text-secondary mb-4">Hiện tại không có chương trình khuyến mãi nào áp dụng được cho giỏ hàng của bạn.</p>
                            <div class="d-flex justify-content-center gap-2">
                                <a class="btn btn-dark rounded-pill px-4" href="${ctx}/checkout">Trở lại Thanh toán</a>
                                <a class="btn btn-outline-dark rounded-pill px-4" href="${ctx}/products">Tiếp tục mua sắm</a>
                            </div>
                        </div>
                    </c:when>

                    <c:otherwise>
                        <div class="d-flex flex-column gap-3">
                            <c:forEach var="promo" items="${vouchers}">
                                <!-- Voucher Card Item -->
                                <div class="voucher-card p-4 rounded-4">
                                    <div class="row align-items-center">
                                        
                                        <!-- Cột thông tin mã -->
                                        <div class="col-md-9 col-12 mb-3 mb-md-0">
                                            <div class="d-flex align-items-center gap-3 mb-2">
                                                <div class="icon-ticket">
                                                    <svg width="20" height="20" fill="currentColor" viewBox="0 0 16 16">
                                                        <path d="M2 4.5a.5.5 0 0 1 .5-.5h11a.5.5 0 0 1 .5.5v1a.5.5 0 0 0 0 1v1a.5.5 0 0 0 0 1v1a.5.5 0 0 1-.5.5h-11a.5.5 0 0 1-.5-.5v-1a.5.5 0 0 0 0-1v-1a.5.5 0 0 0 0-1v-1Z"/>
                                                    </svg>
                                                </div>
                                                <h2 class="mb-0 fw-bold" style="font-size: 1.25rem;">${promo.code}</h2>
                                                <span class="status-badge">Sẵn sàng</span>
                                            </div>
                                            
                                            <p class="mb-2 text-dark fs-6">
                                                Giảm mạnh 
                                                <strong class="text-danger">
                                                    <c:choose>
                                                        <c:when test="${promo.discountType == 'PERCENT'}">
                                                            ${promo.discountValue}%
                                                            <c:if test="${not empty promo.discountMax && promo.discountMax > 0}">
                                                                (Tối đa <fmt:formatNumber value="${promo.discountMax}" pattern="#,##0"/>đ)
                                                            </c:if>
                                                        </c:when>
                                                        <c:otherwise><fmt:formatNumber value="${promo.discountValue}" pattern="#,##0"/>đ</c:otherwise>
                                                    </c:choose>
                                                </strong>
                                                cho đơn hàng.
                                            </p>
                                            
                                            <!-- Điều kiện -->
                                            <div class="text-secondary small d-flex flex-wrap gap-3">
                                                <span class="d-flex align-items-center gap-1">
                                                    <svg width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M8 15A7 7 0 1 0 8 1a7 7 0 0 0 0 14zm0 1A8 8 0 1 1 8 0a8 8 0 0 1 0 16z"/><path d="M8 4a.5.5 0 0 1 .5.5v3h3a.5.5 0 0 1 0 1h-3.5a.5.5 0 0 1-.5-.5v-3.5A.5.5 0 0 1 8 4z"/></svg>
                                                    HSD: ${promo.validUntil.format(dateFormatter)}
                                                </span>
                                                <span class="d-flex align-items-center gap-1">
                                                    <svg width="12" height="12" fill="currentColor" viewBox="0 0 16 16"><path d="M8 1a2.5 2.5 0 0 1 2.5 2.5V4h-5v-.5A2.5 2.5 0 0 1 8 1zm3.5 3v-.5a3.5 3.5 0 1 0-7 0V4H1v10a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2V4h-3.5z"/></svg>
                                                    Đơn tối thiểu: <strong><fmt:formatNumber value="${promo.minOrderValue}" pattern="#,##0"/>đ</strong>
                                                </span>
                                            </div>
                                        </div>

                                        <!-- Cột nút thao tác -->
                                        <div class="col-md-3 col-12 text-md-end">
                                            <form action="${ctx}/apply-voucher" method="post">
                                                <input type="hidden" name="voucherCode" value="${promo.code}">
                                                <button type="submit" class="btn btn-apple w-100">Dùng ngay</button>
                                            </form>
                                        </div>

                                    </div>
                                </div>
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