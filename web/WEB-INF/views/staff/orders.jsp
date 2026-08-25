<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="currUser" value="${not empty sessionScope.currentUser ? sessionScope.currentUser : sessionScope.user}"/>
<c:set var="canManage" value="${currUser.role eq 'ADMIN' or currUser.role eq 'SALE_STAFF'}"/>

<!DOCTYPE html>
<html lang="vi">
    <head>
        <c:set var="pageTitle" value="Đơn hàng · Quản trị AppleStore"/>
        <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    </head>
    <body class="admin">
        <jsp:include page="/WEB-INF/views/common/icons.jsp"/>

        <div class="adm">
            <c:set var="activeAdmin" value="orders"/>
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

            <div class="adm-main">
                <div class="adm-bar">
                    <h2>Đơn hàng</h2>
                    <span class="badge warn">${pendingCount} đơn chờ xử lý</span>
                </div>

                <div class="adm-body">
                    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

                    <div class="split">

                        <!-- ================= CỘT TRÁI ================= -->
                        <div class="panel">
                            <div class="panel-head"><h3>Danh sách đơn hàng</h3></div>

                            <form class="toolbar" method="get" action="${ctx}/staff/orders">
                                <div class="search">
                                    <svg width="17" height="17"><use href="#i-search"/></svg>
                                    <label class="sr-only" for="kw">Tìm đơn hàng</label>
                                    <input id="kw" class="input" type="text" name="keyword" maxlength="100"
                                           value="<c:out value='${keyword}'/>" placeholder="Mã đơn, tên, sđt...">
                                </div>

                                <!-- CHỈ ADMIN MỚI ĐƯỢC THẤY DROPDOWN LỌC THEO NHÂN VIÊN -->
                                <c:if test="${currUser.role eq 'ADMIN'}">
                                    <select class="select" name="staffId" style="max-width: 150px;">
                                        <option value="">Tất cả nhân viên</option>
                                        <c:forEach var="st" items="${saleStaffList}">
                                            <option value="${st.userId}" ${staffFilter eq st.userId ? 'selected' : ''}>${st.fullName}</option>
                                        </c:forEach>
                                    </select>
                                </c:if>

                                <select class="select" name="status" style="max-width: 140px;">
                                    <option value="">Tất cả</option>
                                    <option value="CONFIRMED"  ${statusFilter eq 'CONFIRMED'  ? 'selected' : ''}>Chờ đóng gói</option>
                                    <option value="PREPARING"  ${statusFilter eq 'PREPARING'  ? 'selected' : ''}>Đang chuẩn bị</option>
                                    <option value="DISPATCHED" ${statusFilter eq 'DISPATCHED' ? 'selected' : ''}>Giao vận</option>
                                    <option value="DELIVERED"  ${statusFilter eq 'DELIVERED'  ? 'selected' : ''}>Đã giao</option>
                                    <option value="CANCELLED"  ${statusFilter eq 'CANCELLED'  ? 'selected' : ''}>Đã huỷ</option>
                                </select>
                                <input type="hidden" name="page" value="1">
                                <button type="submit" class="btn sm">Lọc</button>
                                <a class="btn quiet sm" href="${ctx}/staff/orders">Xoá</a>
                            </form>

                            <c:choose>
                                <c:when test="${empty orders}">
                                    <div class="empty">
                                        <div class="ring"><svg width="26" height="26"><use href="#i-truck"/></svg></div>
                                        <h3>Không tìm thấy đơn hàng</h3>
                                        <p>Thử thay đổi bộ lọc tìm kiếm.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <table class="table">
                                        <thead>
                                            <tr>
                                                <th>Mã</th>
                                                <th>Khách hàng</th>
                                                <th>Tổng tiền</th>
                                                <th>Trạng thái</th>
                                                <th style="text-align:right">Thao tác</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            <c:forEach var="o" items="${orders}">
                                                <tr style="${o.orderId == selectedOrder.orderId ? 'background:#FCFBF8' : ''}">
                                                    <td class="num">
                                                        <a href="${ctx}/staff/orders?code=${o.orderId}&status=${statusFilter}&keyword=${keyword}&staffId=${staffFilter}"><b>#<c:out value="${o.orderId}"/></b></a>
                                                    </td>
                                                    <td>
                                                        <c:out value="${o.recipientName}"/>
                                                        <div style="font-size:11px;color:var(--ash)"><c:out value="${o.recipientPhone}"/></div>
                                                    </td>
                                                    <td class="num">
                                                        <fmt:formatNumber value="${not empty o.finalAmount ? o.finalAmount : 0}" type="number" maxFractionDigits="0"/> ₫
                                                    </td>
                                                    <td>
                                                        <c:choose>
                                                            <c:when test="${o.status eq 'CONFIRMED'}"><span class="badge warn">Chờ đóng gói</span></c:when>
                                                            <c:when test="${o.status eq 'PREPARING'}"><span class="badge info">Đang chuẩn bị</span></c:when>
                                                            <c:when test="${o.status eq 'DISPATCHED'}"><span class="badge info">Đang giao</span></c:when>
                                                            <c:when test="${o.status eq 'DELIVERED'}"><span class="badge ok">Đã giao</span></c:when>
                                                            <c:otherwise><span class="badge dan">Đã huỷ</span></c:otherwise>
                                                        </c:choose>
                                                    </td>
                                                    <td class="row-actions">
                                                        <a class="btn xs quiet" href="${ctx}/staff/orders?code=${o.orderId}&status=${statusFilter}&keyword=${keyword}&staffId=${staffFilter}">Xem</a>
                                                    </td>
                                                </tr>
                                            </c:forEach>
                                        </tbody>
                                    </table>

                                    <c:set var="pageUrl"   value="${ctx}/staff/orders"/>
                                    <c:set var="itemLabel" value="đơn"/>
                                    <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
                                </c:otherwise>
                            </c:choose>
                        </div>

                        <!-- ================= CỘT PHẢI ================= -->
                        <div style="display:flex;flex-direction:column;gap:18px">

                            <c:choose>
                                <c:when test="${not empty selectedOrder}">

                                    <div class="panel">
                                        <div class="panel-head">
                                            <h3>Chi tiết đơn #${selectedOrder.orderId}</h3>
                                            <c:choose>
                                                <c:when test="${selectedOrder.status eq 'CONFIRMED'}"><span class="r badge warn">Chờ đóng gói</span></c:when>
                                                <c:when test="${selectedOrder.status eq 'PREPARING'}"><span class="r badge info">Đang chuẩn bị</span></c:when>
                                                <c:when test="${selectedOrder.status eq 'DISPATCHED'}"><span class="r badge info">Đang giao</span></c:when>
                                                <c:when test="${selectedOrder.status eq 'DELIVERED'}"><span class="r badge ok">Đã giao</span></c:when>
                                                <c:otherwise><span class="r badge dan">Đã huỷ</span></c:otherwise>
                                            </c:choose>
                                        </div>
                                        <div class="panel-pad">
                                            <div style="margin-bottom:12px;font-size:13px">
                                                <b>Người nhận:</b> <c:out value="${selectedOrder.recipientName}"/> (${selectedOrder.recipientPhone})<br>
                                                <b>Địa chỉ:</b> <c:out value="${selectedOrder.deliveryAddress}"/><br>
                                                <b>Thanh toán:</b> <c:out value="${selectedOrder.paymentMethod}"/>
                                            </div>

                                            <!-- Hiển thị Nhân viên Sale phụ trách -->
                                            <c:if test="${not empty selectedOrder.assignedSaleStaffName}">
                                                <div style="margin-bottom:12px; padding:8px 12px; background:#f4f4f4; border:1px solid #ddd; border-radius:4px; font-size:13px;">
                                                    <b>👤 Nhân viên Sale phụ trách:</b> <c:out value="${selectedOrder.assignedSaleStaffName}"/>
                                                </div>
                                            </c:if>

                                            <c:if test="${not empty selectedOrder.shipperName}">
                                                <div style="margin-bottom:12px; padding:8px 12px; background:#f0f7ff; border:1px solid #cce5ff; border-radius:4px; font-size:13px;">
                                                    <b>🚀 Shipper phụ trách:</b> <c:out value="${selectedOrder.shipperName}"/>
                                                </div>
                                            </c:if>

                                            <table class="table" style="border-top:1px solid var(--line); font-size: 13px;">
                                                <thead>
                                                    <tr>
                                                        <th>Sản phẩm</th>
                                                        <th>Đơn giá</th>
                                                        <th>SL</th>
                                                        <th style="text-align:right">Thành tiền</th>
                                                    </tr>
                                                </thead>
                                                <tbody>
                                                    <c:forEach var="it" items="${selectedOrder.items}">
                                                        <tr>
                                                            <td>
                                                                <b><c:out value="${it.productNameSnapshot}"/></b>
                                                                <c:if test="${not empty it.variantLabelSnapshot}">
                                                                    <div style="font-size:11px;color:var(--ash)"><c:out value="${it.variantLabelSnapshot}"/></div>
                                                                </c:if>
                                                                <c:if test="${not empty it.addonLabelSnapshot}">
                                                                    <div style="font-size:11px;color:var(--ok)">+ <c:out value="${it.addonLabelSnapshot}"/> (<fmt:formatNumber value="${it.addonPriceSnapshot}" type="number" maxFractionDigits="0"/> ₫)</div>
                                                                </c:if>
                                                            </td>
                                                            <td class="num"><fmt:formatNumber value="${not empty it.unitPrice ? it.unitPrice : 0}" type="number" maxFractionDigits="0"/> ₫</td>
                                                            <td class="num">${not empty it.quantity ? it.quantity : 0}</td>
                                                            <td class="num" style="text-align:right"><fmt:formatNumber value="${not empty it.subtotal ? it.subtotal : 0}" type="number" maxFractionDigits="0"/> ₫</td>
                                                        </tr>
                                                    </c:forEach>
                                                </tbody>
                                            </table>

                                            <div style="max-width:260px;margin-left:auto;padding-top:10px">
                                                <div class="sum-row"><span>Tạm tính</span><span><fmt:formatNumber value="${not empty selectedOrder.totalAmount ? selectedOrder.totalAmount : 0}" type="number" maxFractionDigits="0"/> ₫</span></div>
                                                <c:if test="${selectedOrder.discountAmount > 0}">
                                                    <div class="sum-row"><span>Giảm giá</span><span style="color:var(--ok)">− <fmt:formatNumber value="${selectedOrder.discountAmount}" type="number" maxFractionDigits="0"/> ₫</span></div>
                                                </c:if>
                                                <div class="sum-row total"><span>Tổng cộng</span><span><fmt:formatNumber value="${not empty selectedOrder.finalAmount ? selectedOrder.finalAmount : 0}" type="number" maxFractionDigits="0"/> ₫</span></div>
                                            </div>
                                        </div>
                                    </div>

                                    <!-- 2. PANEL LỊCH SỬ VÀ XỬ LÝ WORKFLOW -->
                                    <div class="panel">
                                        <div class="panel-head"><h3>Lịch sử & Xử lý</h3></div>
                                        <div class="panel-pad">

                                            <!-- LỊCH SỬ THAY ĐỔI & GHI CHÚ -->
                                            <div style="margin-bottom: 16px; padding-bottom: 12px; border-bottom: 1px dashed var(--line);">
                                                <label style="font-size: 12px; font-weight: 700; color: var(--ash); text-transform: uppercase; display: block; margin-bottom: 8px;">Tiến trình trạng thái</label>
                                                <div style="display: flex; flex-direction: column; gap: 8px;">
                                                    <c:forEach var="h" items="${orderTimeline}">
                                                        <div style="font-size: 12.5px; background: #f8f9fa; padding: 10px; border-radius: 4px; border-left: 3px solid var(--titan);">
                                                            <div style="display: flex; justify-content: space-between; font-weight: 600; margin-bottom: 4px;">
                                                                <span>Trạng thái: <span style="color:var(--titan)"><c:out value="${h.status}"/></span></span>
                                                                <span style="color: var(--ash); font-size: 11px;">
                                                                    <c:out value="${h.formattedChangedAt}"/>
                                                                </span>
                                                            </div>
                                                            <c:if test="${not empty h.note}">
                                                                <div style="color: var(--graphite); font-style: italic; border-top: 1px solid #eaeaea; padding-top: 6px; margin-top: 4px;">
                                                                    Lời nhắn: <c:out value="${h.note}"/>
                                                                </div>
                                                            </c:if>
                                                        </div>
                                                    </c:forEach>
                                                    <c:if test="${empty orderTimeline}">
                                                        <div style="font-size: 13px; color: var(--ash);">Chưa có ghi nhận lịch sử nào.</div>
                                                    </c:if>
                                                </div>
                                            </div>

                                            <!-- QUẢN LÝ ĐIỀU CHUYỂN NHÂN VIÊN (CHỈ ADMIN MỚI THẤY VÀ ĐƠN PHẢI CONFIRMED) -->
                                            <c:if test="${currUser.role eq 'ADMIN' and selectedOrder.status eq 'CONFIRMED'}">
                                                <div style="margin-bottom: 16px; padding: 12px; background: #fffbe6; border: 1px solid #ffe58f; border-radius: 6px;">
                                                    <label style="font-size: 11.5px; font-weight: 600; color: #b7791f; display: block; margin-bottom: 6px;">QUẢN LÝ ĐIỀU CHUYỂN NHÂN VIÊN</label>
                                                    <form method="post" action="${ctx}/staff/orders/reassign" style="display: flex; gap: 8px; align-items: center;">
                                                        <input type="hidden" name="orderId" value="${selectedOrder.orderId}">
                                                        <select class="select" name="newStaffId" style="flex: 1; height: 36px; font-size: 13px;" required>
                                                            <option value="">-- Chọn nhân viên mới --</option>
                                                            <c:forEach var="st" items="${saleStaffList}">
                                                                <option value="${st.userId}">${st.fullName}</option>
                                                            </c:forEach>
                                                        </select>
                                                        <button type="submit" class="btn sm titan">Chuyển việc</button>
                                                    </form>
                                                </div>
                                            </c:if>

                                            <!-- KHÓA QUYỀN ADMIN / MỞ QUYỀN SALE STAFF -->
                                            <c:choose>
                                                <c:when test="${currUser.role eq 'ADMIN'}">
                                                    <!-- Màn hình dành riêng cho Admin -->
                                                    <div style="font-size:13px; color:var(--ash); text-align:center; padding: 16px; border: 1px dashed var(--line); border-radius: 4px; background: #fafafa;">
                                                        🛡️ <b>Chế độ Quản trị:</b> Quản trị viên chỉ theo dõi và phân công công việc. Vui lòng sử dụng chức năng <b>Điều chuyển nhân viên</b> phía trên để gán Sale Staff xử lý đơn này.
                                                    </div>
                                                </c:when>
                                                <c:otherwise>
                                                    <!-- Màn hình dành riêng cho Nhân viên Sale (Form thực thi) -->
                                                    <form method="post" action="${ctx}/staff/orders/status">
                                                        <input type="hidden" name="code" value="${selectedOrder.orderId}">
                                                        <input type="hidden" name="returnUrl" value="${ctx}/staff/orders?code=${selectedOrder.orderId}&status=${statusFilter}&keyword=${keyword}&staffId=${staffFilter}">

                                                        <!-- Ô GHI CHÚ NỘI BỘ (Chỉ hiện khi chuẩn bị xử lý) -->
                                                        <c:if test="${selectedOrder.status eq 'CONFIRMED' or selectedOrder.status eq 'PREPARING'}">
                                                            <div class="field" style="margin-bottom:12px;">
                                                                <label>Ghi chú nội bộ (tuỳ chọn)</label>
                                                                <textarea class="textarea" name="note" maxlength="300" placeholder="Ví dụ: Đã đóng gói xong, chuẩn bị giao shipper..."></textarea>
                                                            </div>
                                                        </c:if>

                                                        <div style="display:flex; flex-direction:column; gap:10px;">
                                                            <c:choose>
                                                                <%-- CHỈ KHI ĐƠN ĐÃ CONFIRMED MỚI ĐƯỢC PHÉP ĐÓNG GÓI --%>
                                                                <c:when test="${selectedOrder.status eq 'CONFIRMED'}">
                                                                    <!-- Gắn thẳng name và value vào thẻ button, bỏ input hidden -->
                                                                    <button type="submit" name="status" value="PREPARING" class="btn block">📦 Xác nhận đóng gói (Chuyển sang Đang chuẩn bị)</button>
                                                                </c:when>

                                                                <c:when test="${selectedOrder.status eq 'PREPARING'}">
                                                                    <!-- Gắn thẳng name và value vào thẻ button, bỏ input hidden -->
                                                                    <button type="submit" name="status" value="DISPATCHED" class="btn block">🚀 Giao vận chuyển (Tự động gán Shipper)</button>
                                                                </c:when>

                                                                <c:when test="${selectedOrder.status eq 'DISPATCHED'}">
                                                                    <div style="font-size:13px; color:var(--ash); text-align:center; padding: 8px; border: 1px solid var(--line); border-radius: 4px; background: #fafafa;">
                                                                        Đơn hàng đang được Shipper phụ trách giao.
                                                                    </div>
                                                                </c:when>

                                                                <c:otherwise>
                                                                    <div style="font-size:13px; color:var(--ash); text-align:center; padding: 8px; border: 1px solid var(--line); border-radius: 4px; background: #fafafa;">
                                                                        Trạng thái hiện tại: ${selectedOrder.status} <br>
                                                                        <span style="font-size: 11px;">(Hệ thống chỉ cho phép xử lý khi đơn hàng đã chốt thanh toán / CONFIRMED)</span>
                                                                    </div>
                                                                </c:otherwise>
                                                            </c:choose>

                                                            <c:if test="${selectedOrder.status ne 'DELIVERED' and selectedOrder.status ne 'CANCELLED' and selectedOrder.status ne 'DISPATCHED'}">
                                                                <button type="submit" name="status" value="CANCELLED" class="btn block danger">❌ Huỷ đơn hàng</button>
                                                            </c:if>
                                                        </div>
                                                    </form>
                                                </c:otherwise>
                                            </c:choose>

                                        </div>
                                    </div>

                                </c:when>
                                <c:otherwise>
                                    <div class="panel" style="text-align: center; padding: 40px; color: var(--ash);">
                                        <div class="ring" style="margin: 0 auto 12px;"><svg width="24" height="24"><use href="#i-box"/></svg></div>
                                        <h4>Chưa chọn đơn hàng</h4>
                                        <p style="font-size: 13px;">Bấm nút <b>Xem</b> ở bảng bên trái để hiển thị chi tiết sản phẩm và các nút xử lý quy trình.</p>
                                    </div>
                                </c:otherwise>
                            </c:choose>

                        </div>

                    </div>
                </div>
            </div>
        </div>
    </body>
</html>