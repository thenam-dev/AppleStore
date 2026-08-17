<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AppleStore Quản trị | Tổng quan</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="${appPath}/assets/css/style.css">
    </head>
    <body class="site-body admin-app">
        <main class="admin-workspace">
            <c:set var="adminSidebarTitle" value="Tổng quan" scope="request" />
            <c:set var="adminSidebarDescription" value="Tóm tắt hiệu suất và trạng thái của cửa hàng." scope="request" />
            <c:set var="adminSidebarFooterTitle" value="Tổng quan" scope="request" />
            <c:set var="adminSidebarFooterDescription" value="Không gian quản lý dữ liệu và hệ thống." scope="request" />
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

            <section class="admin-main">    
                <div class="admin-page-head">
                    <div>
                        <h1>Tổng quan hệ thống & Báo cáo</h1>
                    </div>
                </div>

                <form action="${appPath}/admin/dashboard" method="GET" class="d-flex gap-2 align-items-center mb-4">
                    <label>Từ:</label>
                    <input type="date" name="startDate" class="form-control" value="${param.startDate}">
                    <label>Đến:</label>
                    <input type="date" name="endDate" class="form-control" value="${param.endDate}">
                    <button type="submit" class="btn btn-primary">Lọc</button>
                </form>

                <section class="admin-kpi-grid">
                    <article class="stat-card compact">
                        <div class="stat-label">Doanh thu</div>
                        <div class="stat-value">
                            <fmt:formatNumber value="${stats != null ? stats.totalRevenue : 0}" type="currency" currencyCode="VND" />
                        </div>
                        <p>Đơn hàng đã giao thành công</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Đơn hàng</div>
                        <div class="stat-value"><c:out value="${stats != null ? stats.totalOrders : 0}" /></div>
                        <p>Đang ở mọi trạng thái</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Sản phẩm</div>
                        <div class="stat-value"><c:out value="${stats != null ? stats.activeProducts : 0}" /></div>
                        <p>Sản phẩm đang kinh doanh</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Người dùng</div>
                        <div class="stat-value"><c:out value="${stats != null ? stats.totalUsers : 0}" /></div>
                        <p>Tài khoản đã đăng ký</p>
                    </article>
                </section>

                <div class="admin-panel mt-4 mb-4">
                    <div class="admin-panel-head">
                        <h2>Biểu đồ doanh thu theo thời gian</h2>
                    </div>
                    <div class="admin-chart-placeholder" style="padding: 20px;">
                        <canvas id="revenueChart" style="max-height: 400px; width: 100%;"></canvas>
                    </div>
                </div>

                <div class="admin-content-grid">
                    <div class="admin-section-stack">

                        <section class="admin-panel">
                            <div class="admin-panel-head">
                                <div>
                                    <h2>Đơn hàng gần đây</h2>
                                    <p>Danh sách các đơn hàng mới nhất vừa được tạo.</p>
                                </div>
                            </div>
                            <div class="table-responsive">
                                <table class="table app-table" id="ordersTable">
                                    <thead>
                                        <tr>
                                            <th scope="col">Mã đơn</th>
                                            <th scope="col">Khách hàng</th>
                                            <th scope="col">Ngày đặt</th>
                                            <th scope="col">Tổng tiền</th>
                                            <th scope="col">Trạng thái</th>
                                            <th scope="col" class="text-end">Thao tác</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <c:forEach items="${recentOrders}" var="order">
                                        <tr>
                                            <td><strong>#AOS-<c:out value="${order.orderId}" /></strong></td>
                                            <td><c:out value="${order.recipientName}" /></td>
                                            <td><c:out value="${order.formattedCreatedAt}" /></td>
                                            <td><fmt:formatNumber value="${order.finalAmount}" type="currency" currencyCode="VND" /></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${order.status eq 'PENDING_PAYMENT' or order.status eq 'APPROVED'}">
                                                        <span class="status-badge status-pending">Chờ xử lý</span>
                                                    </c:when>
                                                    <c:when test="${order.status eq 'CONFIRMED' or order.status eq 'PREPARING' or order.status eq 'DISPATCHED'}">
                                                        <span class="status-badge status-processing">Đang giao</span>
                                                    </c:when>
                                                    <c:when test="${order.status eq 'DELIVERED'}">
                                                        <span class="status-badge status-delivered">Đã giao</span>
                                                    </c:when>
                                                    <c:when test="${order.status eq 'CANCELLED' or order.status eq 'PAYMENT_FAILED' or order.status eq 'EXPIRED'}">
                                                        <span class="status-badge status-cancelled">Đã hủy</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <span class="status-badge">Khác</span>
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/orders/detail?id=${order.orderId}">Xem</a>
                                            </td>
                                        </tr>
                                        </c:forEach>
                                        <c:if test="${empty recentOrders}">
                                        <tr>
                                            <td colspan="6" class="text-center text-muted py-4">Chưa có đơn hàng nào.</td>
                                        </tr>
                                        </c:if>
                                    </tbody>
                                </table>
                            </div>
                        </section>
                    </div>

                    <div class="admin-section-stack">
                        <section class="admin-panel">
                            <div class="admin-panel-head">
                                <div>
                                    <h2>Trạng thái đơn hàng</h2>
                                    <p>Thống kê số lượng đơn hàng theo từng trạng thái.</p>
                                </div>
                            </div>
                            <ul class="admin-status-list">
                                <li>
                                    <span class="admin-status-label"><span class="admin-status-dot"></span>Chờ xác nhận</span>
                                    <strong><c:out value="${stats != null ? stats.pendingOrdersCount : 0}" /></strong>
                                </li>
                                <li>
                                    <span class="admin-status-label"><span class="admin-status-dot warning"></span>Đang giao hàng</span>
                                    <strong><c:out value="${stats != null ? stats.shippingOrdersCount : 0}" /></strong>
                                </li>
                                <li>
                                    <span class="admin-status-label"><span class="admin-status-dot success"></span>Giao thành công</span>
                                    <strong><c:out value="${stats != null ? stats.deliveredOrdersCount : 0}" /></strong>
                                </li>
                                <li>
                                    <span class="admin-status-label"><span class="admin-status-dot danger"></span>Đã hủy</span>
                                    <strong><c:out value="${stats != null ? stats.cancelledOrdersCount : 0}" /></strong>
                                </li>
                            </ul>
                        </section>

                        <section class="admin-panel">
                            <div class="admin-panel-head">
                                <div>
                                    <h2>Sản phẩm bán chạy</h2>
                                    <p>Danh sách các sản phẩm có doanh số cao nhất.</p>
                                </div>
                            </div>
                            <ul class="admin-mini-list">
                                <c:forEach items="${bestSellingProducts}" var="p">
                                <li class="admin-mini-list-item">
                                    <c:choose>
                                        <c:when test="${not empty p.imageUrl}">
                                            <img src="${appPath}${p.imageUrl}" alt="<c:out value='${p.name}' />">
                                        </c:when>
                                        <c:otherwise>
                                            <img src="${appPath}/assets/images/default-product.png" alt="<c:out value='${p.name}' />">
                                        </c:otherwise>
                                    </c:choose>
                                    <div>
                                        <strong><c:out value="${p.name}" /></strong>
                                        <small><c:out value="${p.totalSold}" /> sản phẩm bán ra</small>
                                    </div>
                                    <span class="status-badge status-in-stock">Bán chạy</span>
                                </li>
                                </c:forEach>
                                <c:if test="${empty bestSellingProducts}">
                                <li class="admin-mini-list-item">
                                    <div class="text-muted w-100 text-center">Chưa có dữ liệu.</div>
                                </li>
                                </c:if>
                            </ul>
                        </section>

                    </div>
                </div>

            </section>
        </main>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${appPath}/assets/js/main.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script>
            const labels = ${chartLabels != null ? chartLabels : '[]'};
            const dataValues = ${chartData != null ? chartData : '[]'};

            if (labels.length > 0) {
                const ctx = document.getElementById('revenueChart').getContext('2d');
                new Chart(ctx, {
                    type: 'bar',
                    data: {
                        labels: labels,
                        datasets: [{
                                label: 'Doanh thu (VNĐ)',
                                data: dataValues,
                                backgroundColor: 'rgba(54, 162, 235, 0.5)',
                                borderColor: 'rgba(54, 162, 235, 1)',
                                borderWidth: 1
                            }]
                    },
                    options: {responsive: true, maintainAspectRatio: false}
                });
            }
        </script>
    </body>
</html>
