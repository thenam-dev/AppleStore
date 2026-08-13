<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.entity.order.Order" %>
<%@ page import="dto.DashboardStatsDTO" %>
<%@ page import="dto.BestSellingProductDTO" %>
<%!
    private String h(Object value) {
        if (value == null) {
            return "";
        }
        return String.valueOf(value)
                .replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
%>
<%
    String appPath = request.getContextPath();
    
    DashboardStatsDTO stats = (DashboardStatsDTO) request.getAttribute("stats");
    if (stats == null) {
        stats = new DashboardStatsDTO();
    }
    
    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");
    if (recentOrders == null) {
        recentOrders = Collections.emptyList();
    }
    
    List<BestSellingProductDTO> bestSellingProducts = (List<BestSellingProductDTO>) request.getAttribute("bestSellingProducts");
    if (bestSellingProducts == null) {
        bestSellingProducts = Collections.emptyList();
    }

    DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("MMM dd, yyyy");
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Apple Online Shop Admin | Dashboard</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
    </head>
    <body class="site-body admin-app">
        <main class="admin-workspace">
            <%
                request.setAttribute("adminSidebarTitle", "Tổng quan");
                request.setAttribute("adminSidebarDescription", "Tóm tắt hiệu suất và trạng thái của cửa hàng.");
                request.setAttribute("adminSidebarFooterTitle", "Tổng quan");
                request.setAttribute("adminSidebarFooterDescription", "Không gian quản lý dữ liệu và hệ thống.");
                request.setAttribute("adminSidebarShowUserQuickLinks", Boolean.TRUE);
            %>
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

            <section class="admin-main">    
                <div class="admin-page-head">
                    <div>
                        <h1>Tổng quan hệ thống</h1>
                    </div>
                </div>

                <section class="admin-kpi-grid">
                    <article class="stat-card compact">
                        <div class="stat-label">Doanh thu</div>
                        <div class="stat-value">
                            <%= currencyFormatter.format(stats.getTotalRevenue()) %>
                        </div>
                        <p>Đơn hàng đã giao thành công</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Đơn hàng</div>
                        <div class="stat-value"><%= stats.getTotalOrders() %></div>
                        <p>Đang ở mọi trạng thái</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Sản phẩm</div>
                        <div class="stat-value"><%= stats.getActiveProducts() %></div>
                        <p>Sản phẩm đang kinh doanh</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Người dùng</div>
                        <div class="stat-value"><%= stats.getTotalUsers() %></div>
                        <p>Tài khoản đã đăng ký</p>
                    </article>
                </section>

                <div class="admin-content-grid">
                    <div class="admin-section-stack">
                        <!-- Sales overview removed -->

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
                                        <% for (Order order : recentOrders) { %>
                                        <tr>
                                            <td><strong>#AOS-<%= order.getOrderId() %></strong></td>
                                            <td><%= h(order.getRecipientName()) %></td>
                                            <td><%= order.getCreatedAt() != null ? dateFormatter.format(order.getCreatedAt()) : "" %></td>
                                            <td><%= currencyFormatter.format(order.getFinalAmount()) %></td>
                                            <td>
                                                <% 
                                                    String st = order.getStatus();
                                                    if ("PENDING_PAYMENT".equals(st) || "APPROVED".equals(st)) { 
                                                %>
                                                <span class="status-badge status-pending">Chờ xử lý</span>
                                                <% } else if ("CONFIRMED".equals(st) || "PREPARING".equals(st) || "DISPATCHED".equals(st)) { %>
                                                <span class="status-badge status-processing">Đang giao</span>
                                                <% } else if ("DELIVERED".equals(st)) { %>
                                                <span class="status-badge status-delivered">Đã giao</span>
                                                <% } else if ("CANCELLED".equals(st) || "PAYMENT_FAILED".equals(st) || "EXPIRED".equals(st)) { %>
                                                <span class="status-badge status-cancelled">Đã hủy</span>
                                                <% } else { %>
                                                <span class="status-badge">Khác</span>
                                                <% } %>
                                            </td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/orders/detail?id=<%= order.getOrderId() %>">Xem</a>
                                            </td>
                                        </tr>
                                        <% } %>
                                        <% if (recentOrders.isEmpty()) { %>
                                        <tr>
                                            <td colspan="6" class="text-center text-muted py-4">Chưa có đơn hàng nào.</td>
                                        </tr>
                                        <% } %>
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
                                    <strong><%= stats.getPendingOrdersCount() %></strong>
                                </li>
                                <li>
                                    <span class="admin-status-label"><span class="admin-status-dot warning"></span>Đang giao hàng</span>
                                    <strong><%= stats.getShippingOrdersCount() %></strong>
                                </li>
                                <li>
                                    <span class="admin-status-label"><span class="admin-status-dot success"></span>Giao thành công</span>
                                    <strong><%= stats.getDeliveredOrdersCount() %></strong>
                                </li>
                                <li>
                                    <span class="admin-status-label"><span class="admin-status-dot danger"></span>Đã hủy</span>
                                    <strong><%= stats.getCancelledOrdersCount() %></strong>
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
                                <% for (BestSellingProductDTO p : bestSellingProducts) { %>
                                <li class="admin-mini-list-item">
                                    <img src="<%= appPath %><%= p.getImageUrl() != null ? p.getImageUrl() : "/assets/images/default-product.png" %>" alt="<%= h(p.getName()) %>">
                                    <div>
                                        <strong><%= h(p.getName()) %></strong>
                                        <small><%= p.getTotalSold() %> sản phẩm bán ra</small>
                                    </div>
                                    <span class="status-badge status-in-stock">Bán chạy</span>
                                </li>
                                <% } %>
                                <% if (bestSellingProducts.isEmpty()) { %>
                                <li class="admin-mini-list-item">
                                    <div class="text-muted w-100 text-center">Chưa có dữ liệu.</div>
                                </li>
                                <% } %>
                            </ul>
                        </section>

                    </div>
                </div>

            </section>
        </main>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="<%= appPath %>/assets/js/main.js"></script>
    </body>
</html>
