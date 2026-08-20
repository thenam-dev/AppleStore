<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <title>Chi tiết đơn hàng · HALO</title>
    <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    <style>
        /* Style cho đánh giá sao tương tác */
        .star-rating {
            display: flex;
            flex-direction: row-reverse;
            justify-content: flex-end;
            gap: 4px;
        }
        .star-rating input[type="radio"] {
            display: none;
        }
        .star-rating label {
            cursor: pointer;
            font-size: 24px;
            color: #cbd5e1;
            transition: color 0.2s ease-in-out;
        }
        .star-rating input[type="radio"]:checked ~ label,
        .star-rating label:hover,
        .star-rating label:hover ~ label {
            color: #f59e0b;
        }
    </style>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<c:set var="activeMenu" value="order"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div style="max-width: 900px; margin: 30px auto; padding: 0 20px; min-height: 520px;">
    <div style="margin-bottom: 20px;">
        <a href="${ctx}/account/orders" style="color: var(--ash); font-size: 14px; text-decoration: none;">&larr; Quay lại danh sách đơn hàng</a>
    </div>

    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

    <div class="panel" style="background:#fff; border:1px solid var(--line,#eee); border-radius:8px; padding:24px;">
        <div class="panel-head" style="display:flex; justify-content:space-between; align-items: center; margin-bottom:20px;">
            <div>
                <h3 style="margin:0; font-size:18px;">Chi tiết đơn hàng <c:out value="${order.code}"/></h3>
            </div>
            <div style="display: flex; gap: 10px; align-items: center;">
                <%-- Nút thanh toán QR ở header --%>
                <c:if test="${order.rawStatus eq 'PENDING_PAYMENT' and order.paymentMethod eq 'CK'}">
                    <a class="btn titan sm" href="${ctx}/payment?orderId=${order.rawId}">Tiếp tục thanh toán QR</a>
                </c:if>

                <span class="badge ${order.status eq 'DELIVERED' ? 'ok' : (order.status eq 'CANCELLED' ? 'dan' : 'info')}"><c:out value="${order.statusLabel}"/></span>
            </div>
        </div>

        <!-- TIMELINE TRẠNG THÁI -->
        <div style="background: var(--porcelain, #f8f9fa); padding: 16px; border-radius: 6px; margin-bottom: 24px;">
            <h4 style="font-size: 14px; margin-bottom: 12px; font-weight: 600;">Tiến độ</h4>
            <div class="timeline" style="display:flex; flex-direction:column; gap:12px;">
                <c:forEach var="ev" items="${order.timeline}">
                    <div class="ev ${ev.done ? 'done' : ''}" style="display:flex; justify-content:space-between; font-size:13px; padding-bottom:8px; border-bottom:1px dashed #e2e8f0;">
                        <b><c:out value="${ev.label}"/></b>
                        <span style="color:var(--ash);">
                            <c:choose>
                                <c:when test="${ev.done and not empty ev.time}">
                                    <fmt:formatDate value="${ev.time}" pattern="dd/MM/yyyy 'lúc' HH:mm"/>
                                </c:when>
                                <c:otherwise>Đang chờ...</c:otherwise>
                            </c:choose>
                        </span>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- DANH SÁCH SẢN PHẨM & ĐÁNH GIÁ (FEEDBACK) -->
        <div style="margin-bottom: 24px;">
            <h4 style="font-size: 14px; margin-bottom: 12px; font-weight: 600;">Sản phẩm đã đặt</h4>
            <div style="display: flex; flex-direction: column; gap: 12px;">
                <c:forEach var="item" items="${order.items}">
                    <div style="border: 1px solid var(--line, #eee); border-radius: 6px; padding: 16px;">
                        <div style="display:flex; justify-content:space-between; align-items: flex-start;">
                            <div>
                                <b style="font-size: 15px;"><c:out value="${item.productNameSnapshot}"/></b> <br>
                                <span style="color:var(--ash); font-size:13px;"><c:out value="${item.variantLabelSnapshot}"/></span>
                            </div>
                            <div style="text-align: right;">
                                <span style="font-weight:700; font-family: var(--display);"><fmt:formatNumber value="${item.subtotal}" type="number" maxFractionDigits="0"/> ₫</span><br>
                                <span style="font-size: 12px; color:var(--ash);">SL: ${item.quantity}</span>
                            </div>
                        </div>

                        <!-- XỬ LÝ NÚT FEEDBACK CHO TỪNG SẢN PHẨM NẾU ĐƠN HÀNG ĐÃ GIAO -->
                        <c:if test="${order.status eq 'DELIVERED'}">
                            <div style="margin-top: 16px; border-top: 1px dashed #e2e8f0; padding-top: 16px;">
                                <c:choose>
                                    <%-- NẾU ĐÃ ĐÁNH GIÁ --%>
                                    <c:when test="${not empty item.review}">
                                        <div style="background: #f8f9fa; padding: 12px; border-radius: 6px; font-size: 13.5px;">
                                            <div style="color: #f59e0b; font-weight: bold; margin-bottom: 4px;">
                                                <c:forEach begin="1" end="${item.review.rating}">⭐</c:forEach> (${item.review.rating}/5)
                                            </div>
                                            <p style="margin: 0; color: var(--graphite);"><c:out value="${item.review.reviewText}"/></p>
                                        </div>
                                    </c:when>

                                    <%-- NẾU CHƯA ĐÁNH GIÁ -> HIỂN THỊ FORM --%>
                                    <c:otherwise>
                                        <form action="${ctx}/account/order/review" method="post" style="margin: 0; background: #fff; padding: 12px; border: 1px solid #e2e8f0; border-radius: 6px;">
                                            <input type="hidden" name="orderId" value="${order.rawId}">
                                            <input type="hidden" name="orderItemId" value="${item.orderItemId}">

                                            <div style="display:flex; gap: 16px; align-items: center; margin-bottom: 12px;">
                                                <label style="font-size: 13.5px; font-weight: 600; margin: 0;">Đánh giá của bạn:</label>

                                                <div class="star-rating">
                                                    <input type="radio" id="star5-${item.orderItemId}" name="rating" value="5" required/>
                                                    <label for="star5-${item.orderItemId}" title="5 sao - Tuyệt vời">★</label>

                                                    <input type="radio" id="star4-${item.orderItemId}" name="rating" value="4"/>
                                                    <label for="star4-${item.orderItemId}" title="4 sao - Tốt">★</label>

                                                    <input type="radio" id="star3-${item.orderItemId}" name="rating" value="3"/>
                                                    <label for="star3-${item.orderItemId}" title="3 sao - Bình thường">★</label>

                                                    <input type="radio" id="star2-${item.orderItemId}" name="rating" value="2"/>
                                                    <label for="star2-${item.orderItemId}" title="2 sao - Tệ">★</label>

                                                    <input type="radio" id="star1-${item.orderItemId}" name="rating" value="1"/>
                                                    <label for="star1-${item.orderItemId}" title="1 sao - Rất tệ">★</label>
                                                </div>
                                            </div>

                                            <textarea name="reviewText" class="input" rows="2" style="width:100%; font-size:13.5px; padding: 10px;" placeholder="Hãy chia sẻ nhận xét của bạn về chất lượng sản phẩm..." required></textarea>
                                            <div style="text-align: right; margin-top: 10px;">
                                                <button type="submit" class="btn titan sm">Gửi đánh giá</button>
                                            </div>
                                        </form>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </c:if>
                    </div>
                </c:forEach>
            </div>
        </div>

        <!-- THÔNG TIN TỔNG QUAN ĐƠN HÀNG -->
        <div style="border-top:1px solid var(--line, #eee); padding-top:20px; font-size:14px;">
            <div class="grid-2" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px; margin-bottom: 20px;">
                <div>
                    <h4 style="font-size: 14px; margin-bottom: 8px; font-weight: 600;">Thông tin người nhận</h4>
                    <p style="margin:0; color:var(--graphite);">
                        <b><c:out value="${order.receiverName}"/></b> (<c:out value="${order.phone}"/>)<br>
                        <c:out value="${order.fullAddress}"/>
                    </p>
                </div>
                <div>
                    <h4 style="font-size: 14px; margin-bottom: 8px; font-weight: 600;">Thanh toán</h4>
                    <p style="margin:0; color:var(--graphite);"><c:out value="${order.paymentMethodLabel}"/></p>
                    
                    <%-- Dùng rawStatus thay vì status để khớp chính xác với PENDING_PAYMENT --%>
                    <c:if test="${order.rawStatus eq 'PENDING_PAYMENT' and order.paymentMethod eq 'CK'}">
                        <div style="margin-top: 12px;">
                            <p style="font-size: 12px; color: var(--danger); margin-bottom: 8px;">Đơn hàng sẽ tự động hủy nếu không thanh toán trong 15 phút.</p>
                            <a href="${ctx}/payment?orderId=${order.rawId}" class="btn titan sm">Thanh toán ngay</a>
                        </div>
                    </c:if>
                </div>
            </div>

            <div style="background: var(--porcelain, #f8f9fa); padding: 16px; border-radius: 6px; max-width: 400px; margin-left: auto;">
                <div class="sum-row" style="display:flex; justify-content:space-between; margin-bottom:8px;">
                    <span style="color:var(--ash);">Tạm tính</span>
                    <span style="font-weight: 500;"><fmt:formatNumber value="${order.subtotal}" type="number" maxFractionDigits="0"/> ₫</span>
                </div>
                <c:if test="${order.discount > 0}">
                    <div class="sum-row" style="display:flex; justify-content:space-between; margin-bottom:8px; color:var(--ok)">
                        <span>Giảm giá khuyến mãi</span>
                        <span style="font-weight: 500;">− <fmt:formatNumber value="${order.discount}" type="number" maxFractionDigits="0"/> ₫</span>
                    </div>
                </c:if>
                <div class="sum-row total" style="display:flex; justify-content:space-between; font-weight:bold; font-size:16px; margin-top:12px; border-top:1px solid #e2e8f0; padding-top:12px;">
                    <span>Tổng cộng</span>
                    <span style="color: var(--titan);"><fmt:formatNumber value="${order.total}" type="number" maxFractionDigits="0"/> ₫</span>
                </div>
            </div>
        </div>

    </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>