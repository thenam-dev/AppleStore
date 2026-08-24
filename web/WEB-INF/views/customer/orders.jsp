<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <title>Đơn hàng của tôi · HALO</title>
        <c:set var="pageTitle" value="Đơn hàng của tôi · HALO"/>
        <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    </head>
    <body>
        <jsp:include page="/WEB-INF/views/common/icons.jsp"/>
        <jsp:include page="/WEB-INF/views/common/header.jsp"/>

        <div class="profile-container" style="max-width: 1200px; margin: 30px auto; padding: 0 20px; min-height: 520px;">
            <!-- Sidebar tài khoản -->
            <c:set var="activeMenu" value="orders"/>
            <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>

            <!-- Nội dung chính -->
            <div class="profile-content">
                <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
                <h2 style="font-size: 22px; text-transform: uppercase; margin-bottom: 20px; font-weight: 700;">Đơn hàng của tôi</h2>

                <div style="display:flex;gap:12px;margin-bottom:20px;border-bottom:1px solid var(--line, #eee);padding-bottom:12px; overflow-x:auto;">
                    <a class="btn ${empty tab or tab eq 'all' ? '' : 'quiet'} sm" href="${ctx}/account/orders?tab=all">
                        📋 Tất cả (${not empty allCount ? allCount : 0})
                    </a>
                    <a class="btn ${tab eq 'active' ? '' : 'quiet'} sm" href="${ctx}/account/orders?tab=active">
                        📦 Đang xử lý (${not empty activeCount ? activeCount : 0})
                    </a>
                    <a class="btn ${tab eq 'completed' ? '' : 'quiet'} sm" href="${ctx}/account/orders?tab=completed">
                        ✅ Đã hoàn thành / Huỷ (${not empty completedCount ? completedCount : 0})
                    </a>
                </div>

                <c:choose>
                    <c:when test="${empty orders}">
                        <div class="empty" style="text-align: center; padding: 40px;">
                            <div class="ring" style="margin: 0 auto 12px;"><svg width="26" height="26"><use href="#i-box"/></svg></div>
                            <h3>Không có đơn hàng nào trong mục này</h3>
                            <p>Khám phá ngay các thiết bị Apple chính hãng với nhiều ưu đãi hấp dẫn.</p>
                            <a class="btn titan" href="${ctx}/products" style="margin-top:12px; display: inline-block;">Bắt đầu mua sắm</a>
                        </div>
                    </c:when>
                    <c:otherwise>
                        <div style="display: flex; flex-direction: column; gap: 16px;">
                            <c:forEach var="o" items="${orders}">
                                <div class="panel" style="background:#fff; border:1px solid var(--line,#eee); border-radius:8px; padding:18px;">
                                    <div class="panel-head" style="display:flex; justify-content:space-between; margin-bottom:12px;">
                                        <span class="mono" style="font-size:13px"><b>Mã đơn: <c:out value="${o.code}"/></b></span>
                                        <c:choose>
                                            <c:when test="${o.status eq 'PENDING_PAYMENT' or o.status eq 'PENDING'}"><span class="badge warn"><c:out value="${o.statusLabel}"/></span></c:when>
                                            <c:when test="${o.status eq 'SHIPPING' or o.status eq 'DISPATCHED' or o.status eq 'PREPARING'}"><span class="badge info"><c:out value="${o.statusLabel}"/></span></c:when>
                                            <c:when test="${o.status eq 'DELIVERED'}"><span class="badge ok"><c:out value="${o.statusLabel}"/></span></c:when>
                                            <c:otherwise><span class="badge dan"><c:out value="${o.statusLabel}"/></span></c:otherwise>
                                        </c:choose>
                                    </div>
                                    <div style="display:flex;gap:16px;align-items:center;margin-bottom:16px">
                                        <div class="shot" style="width:64px;height:64px;aspect-ratio:auto;border-radius:var(--r-sm); background:#f0f0f0; display:flex; align-items:center; justify-content:center;">
                                            <svg width="28" height="28" style="color:#5B6472"><use href="#${empty o.firstItemIconKey ? 'd-acc' : o.firstItemIconKey}"/></svg>
                                        </div>
                                        <div style="flex:1;font-size:14px"><c:out value="${o.itemsSummary}"/></div>
                                        <div style="text-align:right">
                                            <div style="font-family:var(--display);font-weight:700;font-size:16px">
                                                <fmt:formatNumber value="${o.total}" type="number" maxFractionDigits="0"/> ₫</div>
                                            <div style="font-size:12px;color:var(--ash)"><c:out value="${o.paymentMethodLabel}"/></div>
                                        </div>
                                    </div>
                                    <div style="display:flex;gap:10px; justify-content: flex-end; border-top: 1px dashed #eee; padding-top: 14px;">
                                        <c:if test="${o.status eq 'PENDING_PAYMENT'}">
                                            <a class="btn titan sm" href="${ctx}/payment?orderId=${o.rawId}">Thanh toán ngay</a>
                                        </c:if>

                                        <a class="btn sm" href="${ctx}/account/order-detail?id=${o.rawId}">Xem chi tiết & Đánh giá</a>

                                        <c:if test="${o.rawStatus eq 'PENDING_PAYMENT' or o.rawStatus eq 'CONFIRMED'}">
                                            <form method="post" action="${ctx}/order/cancel" style="margin:0;">
                                                <input type="hidden" name="code" value="${o.code}">
                                                <input type="hidden" name="tab" value="${not empty param.tab ? param.tab : 'all'}">
                                                <button type="submit" class="btn ghost sm danger">Hủy đơn</button>
                                            </form>
                                        </c:if>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
    </body>
</html>