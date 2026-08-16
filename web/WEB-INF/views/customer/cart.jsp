<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AppleStore | Giỏ hàng</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="site-body">

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main>
    <section class="section-block">
        <div class="container">
            <nav aria-label="Đường dẫn">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${pageContext.request.contextPath}/index.jsp">Trang chủ</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Giỏ hàng</li>
                </ol>
            </nav>
            <div class="store-page-heading">
                <div>
                    <span class="eyebrow">Giỏ hàng</span>
                    <h1>Giỏ hàng của bạn</h1>
                    <p>Phí vận chuyển và mã giảm giá sẽ được tính ở bước thanh toán.</p>
                </div>
                <div class="store-heading-meta">
                    <strong>${cartItemCount}</strong>
                    <span>sản phẩm trong giỏ</span>
                </div>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success">${successMsg}</div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger">${errorMsg}</div>
            </c:if>
            <c:if test="${hasOverStockItem}">
                <div class="alert alert-warning">
                    Một số sản phẩm trong giỏ đã vượt quá số lượng tồn kho hiện tại, vui lòng cập nhật lại trước khi thanh toán.
                </div>
            </c:if>
        </div>
    </section>

    <section class="section-block section-soft">
        <div class="container">
            <c:choose>
                <%-- ================= GIỎ HÀNG CÓ SẢN PHẨM ================= --%>
                <c:when test="${not empty cartItems}">
                    <div class="cart-layout">
                        <div class="cart-filled">
                            <div class="cart-list-card">
                                <div class="cart-list-head">
                                    <div>
                                        <h2>Sản phẩm trong giỏ</h2>
                                        <p>Thay đổi số lượng hoặc xóa sản phẩm bạn không muốn mua nữa.</p>
                                    </div>
                                    <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/products">Tiếp tục mua sắm</a>
                                </div>

                                <c:forEach var="item" items="${cartItems}">
                                    <article class="cart-item ${item.overStock ? 'cart-item-warning' : ''}">
                                        <div class="cart-item-media">
                                            <img src="${pageContext.request.contextPath}${not empty item.imageUrl ? item.imageUrl : '/assets/images/iphone-card.svg'}"
                                                 alt="${item.productName}">
                                        </div>
                                        <div class="cart-item-body">
                                            <div class="cart-item-main">
                                                <div>
                                                    <h3>${item.productName}</h3>
                                                    <p>
                                                        ${item.variantLabel}
                                                        <c:if test="${not empty item.addonLabel}">
                                                            &middot; Dịch vụ thêm: ${item.addonLabel}
                                                        </c:if>
                                                    </p>
                                                    <c:if test="${item.overStock}">
                                                        <p class="text-danger">Chỉ còn ${item.stockQuantity} sản phẩm trong kho, vui lòng cập nhật lại số lượng.</p>
                                                    </c:if>
                                                    <c:if test="${item.stockQuantity <= 0}">
                                                        <p class="text-danger">Sản phẩm đã hết hàng, vui lòng xóa khỏi giỏ hàng.</p>
                                                    </c:if>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/cart" method="post"
                                                      onsubmit="return confirm('Xóa sản phẩm này khỏi giỏ hàng?');">
                                                    <input type="hidden" name="action" value="remove">
                                                    <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                                    <button class="btn btn-app-ghost btn-sm" type="submit">Xóa</button>
                                                </form>
                                            </div>
                                            <div class="cart-item-meta">
                                                <span>
                                                    Đơn giá:
                                                    <strong><fmt:formatNumber value="${item.unitPrice}" pattern="#,##0"/> đ</strong>
                                                    <c:if test="${not empty item.addonPrice and item.addonPrice > 0}">
                                                        (+ <fmt:formatNumber value="${item.addonPrice}" pattern="#,##0"/> đ dịch vụ thêm)
                                                    </c:if>
                                                </span>

                                                <form class="quantity-control" action="${pageContext.request.contextPath}/cart" method="post">
                                                    <input type="hidden" name="action" value="update">
                                                    <input type="hidden" name="cartItemId" value="${item.cartItemId}">
                                                    <input type="number" name="quantity" value="${item.quantity}"
                                                           min="1" max="${item.stockQuantity}">
                                                    <button type="submit" class="btn btn-app-outline btn-sm" style="font-size: small">Cập nhật</button>
                                                </form>

                                                <span>
                                                    Thành tiền:
                                                    <strong><fmt:formatNumber value="${item.lineTotal}" pattern="#,##0"/> đ</strong>
                                                </span>
                                            </div>
                                        </div>
                                    </article>
                                </c:forEach>
                            </div>
                        </div>

                        <aside class="cart-summary-card">
                            <div class="summary-card-head">
                                <h2>Tóm tắt đơn hàng</h2>
                                <p>Mã giảm giá sẽ được áp dụng ở bước thanh toán.</p>
                            </div>

                            <div class="summary-lines">
                                <div class="summary-row">
                                    <span>Số sản phẩm</span>
                                    <strong>${cartItemCount}</strong>
                                </div>
                                <div class="summary-row">
                                    <span>Tạm tính</span>
                                    <strong><fmt:formatNumber value="${cartTotal}" pattern="#,##0"/> đ</strong>
                                </div>
                                <div class="summary-row">
                                    <span>Phí vận chuyển</span>
                                    <strong>Tính khi thanh toán</strong>
                                </div>
                            </div>

                            <div class="summary-total">
                                <span>Tổng cộng</span>
                                <strong><fmt:formatNumber value="${cartTotal}" pattern="#,##0"/> đ</strong>
                            </div>

                            <div class="summary-actions">
                                <a class="btn btn-app-primary w-100" href="${pageContext.request.contextPath}/checkout">Tiến hành thanh toán</a>
                                <a class="btn btn-app-secondary w-100" href="${pageContext.request.contextPath}/products">Tiếp tục mua sắm</a>
                            </div>
                        </aside>
                    </div>
                </c:when>

                <%-- ================= GIỎ HÀNG TRỐNG ================= --%>
                <c:otherwise>
                    <div class="empty-cart-panel">
                        <span class="eyebrow">Giỏ hàng trống</span>
                        <h2>Giỏ hàng của bạn hiện đang trống</h2>
                        <p>Chọn sản phẩm bạn thích và thêm vào giỏ hàng.</p>
                        <div class="hero-actions">
                            <a class="btn btn-app-primary" href="${pageContext.request.contextPath}/products">Xem sản phẩm</a>
                            <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/index.jsp">Về trang chủ</a>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
</body>
</html>