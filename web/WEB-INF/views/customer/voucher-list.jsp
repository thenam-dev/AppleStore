<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Mã ưu đãi | AppleStore</title>
    <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    <style>
        /* CSS native theo chuẩn AOS */
        .v-card {
            background: #fff;
            border: 1px solid var(--line);
            border-radius: var(--r-md);
            padding: 24px;
            display: flex;
            gap: 20px;
            align-items: center;
            transition: box-shadow 0.2s ease, transform 0.2s;
        }
        .v-card:hover {
            box-shadow: 0 4px 14px rgba(0,0,0,0.06);
        }
        .v-icon {
            width: 52px; height: 52px;
            background: #F0F5FF; color: #0066CC;
            border-radius: 50%;
            display: flex; align-items: center; justify-content: center;
            flex-shrink: 0;
        }
        .v-body { flex: 1; }
        .v-code { font-family: var(--display); font-weight: 700; font-size: 20px; display: flex; align-items: center; gap: 10px; margin-bottom: 4px; }
        .v-desc { color: var(--graphite); font-size: 14.5px; margin-bottom: 12px; }
        .v-meta { display: flex; gap: 16px; font-size: 12.5px; color: var(--ash); flex-wrap: wrap; }
        .v-meta span { display: inline-flex; align-items: center; gap: 6px; }
        .v-action { width: 140px; text-align: right; flex-shrink: 0; }
        @media (max-width: 640px) {
            .v-card { flex-direction: column; align-items: stretch; gap: 16px; }
            .v-action { width: 100%; text-align: left; }
            .v-action .btn { width: 100%; }
        }
    </style>
</head>
<body class="site-body">
    <c:set var="activeMenu" value="voucher" scope="request"/>
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <main style="max-width: 860px; margin: 30px auto; padding: 0 24px; min-height: 550px;">

        <div class="store-page-heading" style="margin-bottom: 30px; display: flex; justify-content: space-between; align-items: flex-end; flex-wrap: wrap; gap: 16px;">
            <div>
                <span class="eyebrow" style="font-size: 12px; color: var(--ash); text-transform: uppercase; letter-spacing: 1px;">Khuyến mãi</span>
                <h1 style="font-size: 28px; font-weight: 700; margin-top: 4px; margin-bottom: 6px;">Mã ưu đãi của bạn</h1>
                <p style="color: var(--ash); font-size: 14px; margin: 0;">Chọn một mã giảm giá phù hợp nhất với đơn hàng hiện tại.</p>
            </div>
            <a class="btn ghost" href="${ctx}/checkout">Quay lại thanh toán</a>
        </div>

        <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

        <c:choose>
            <c:when test="${empty vouchers}">
                <div class="empty" style="padding: 60px 20px; background: #fff; border: 1px solid var(--line); border-radius: var(--r-md);">
                    <div class="ring"><svg width="28" height="28"><use href="#i-tag"/></svg></div>
                    <h3>Không có mã khả dụng</h3>
                    <p>Hiện tại không có chương trình khuyến mãi nào áp dụng được cho giỏ hàng của bạn.</p>
                    <div style="display:flex; gap:10px; justify-content:center; margin-top: 16px;">
                        <a class="btn titan" href="${ctx}/checkout">Trở lại thanh toán</a>
                        <a class="btn ghost" href="${ctx}/products">Tiếp tục mua sắm</a>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <div style="display: flex; flex-direction: column; gap: 16px;">
                    <c:forEach var="promo" items="${vouchers}">
                        <div class="v-card">
                            <div class="v-icon">
                                <svg width="24" height="24"><use href="#i-tag"/></svg>
                            </div>
                            <div class="v-body">
                                <div class="v-code">
                                    ${promo.code}
                                    <span class="badge ok" style="font-size: 11px; padding: 2px 6px;">Sẵn sàng</span>
                                </div>
                                <div class="v-desc">
                                    Giảm mạnh 
                                    <strong style="color: var(--danger);">
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
                                </div>
                                <div class="v-meta">
                                    <span><svg width="14" height="14"><use href="#i-check"/></svg> HSD: ${promo.validUntil.format(dateFormatter)}</span>
                                    <span><svg width="14" height="14"><use href="#i-alert"/></svg> Đơn tối thiểu: <strong><fmt:formatNumber value="${promo.minOrderValue}" pattern="#,##0"/>đ</strong></span>
                                </div>
                            </div>
                            <div class="v-action">
                                <form action="${ctx}/apply-voucher" method="post" style="margin: 0;">
                                    <input type="hidden" name="voucherCode" value="${promo.code}">
                                    <button type="submit" class="btn titan" style="width: 100%;">Dùng ngay</button>
                                </form>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>