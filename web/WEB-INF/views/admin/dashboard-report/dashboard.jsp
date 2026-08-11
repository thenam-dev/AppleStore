<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="model.Order" %>
<%@ page import="model.DashboardStats" %>
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
    
    DashboardStats stats = (DashboardStats) request.getAttribute("stats");
    if (stats == null) {
        stats = new DashboardStats();
    }
    
    List<Order> recentOrders = (List<Order>) request.getAttribute("recentOrders");
    if (recentOrders == null) {
        recentOrders = Collections.emptyList();
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
            request.setAttribute("adminSidebarTitle", "Dashboard");
            request.setAttribute("adminSidebarDescription", "A clean snapshot of shop performance and status.");
            request.setAttribute("adminSidebarFooterTitle", "Overview");
            request.setAttribute("adminSidebarFooterDescription", "Management workspace for dashboard and master data.");
            request.setAttribute("adminSidebarShowUserQuickLinks", Boolean.TRUE);
        %>
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="<%= appPath %>/admin/dashboard" method="get" name="adminDashboardSearchForm">
                    <label class="visually-hidden" for="admin-dashboard-search">Search admin workspace</label>
                    <input id="admin-dashboard-search" class="form-control" type="search" name="keyword" placeholder="Search order, product, customer">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/">Storefront</a>
                    <div class="admin-user-pill">
                        <div class="account-avatar admin-user-pill-avatar">AD</div>
                        <div>
                            <strong>Admin</strong>
                            <small>Dashboard View</small>
                        </div>
                    </div>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Dashboard</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Admin overview</span>
                    <h1>Dashboard summary</h1>
                    <p>
                        A clean snapshot of shop performance, operational status, and high-priority items for the
                        product owner or admin role.
                    </p>
                </div>
                <div class="admin-page-actions">
                    <a class="btn btn-app-outline" href="<%= appPath %>/admin/orders">Review Orders</a>
                    <a class="btn btn-app-primary" href="<%= appPath %>/admin/products/new">Add Product</a>
                </div>
            </div>

            <section class="admin-kpi-grid">
                <article class="stat-card compact">
                    <div class="stat-label">Revenue</div>
                    <div class="stat-value">
                        <%= currencyFormatter.format(stats.getTotalRevenue()) %>
                    </div>
                    <p>Total delivered orders</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Orders</div>
                    <div class="stat-value"><%= stats.getTotalOrders() %></div>
                    <p>Across all statuses</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Products</div>
                    <div class="stat-value"><%= stats.getActiveProducts() %></div>
                    <p>Active catalog items</p>
                </article>
                <article class="stat-card compact">
                    <div class="stat-label">Customers</div>
                    <div class="stat-value"><%= stats.getTotalCustomers() %></div>
                    <p>Registered accounts</p>
                </article>
            </section>

            <div class="admin-content-grid">
                <div class="admin-section-stack">
                    <section class="admin-panel">
                        <div class="admin-panel-head">
                            <div>
                                <h2>Sales overview</h2>
                                <p>Placeholder chart only, styled for later backend reporting integration.</p>
                            </div>
                            <span class="status-badge status-processing">Last 6 weeks</span>
                        </div>
                        <div class="admin-chart-placeholder">
                            <div class="admin-chart-bars" aria-hidden="true">
                                <div class="admin-chart-bar" style="height: 42%;"><span>$14K</span></div>
                                <div class="admin-chart-bar" style="height: 56%;"><span>$19K</span></div>
                                <div class="admin-chart-bar" style="height: 48%;"><span>$16K</span></div>
                                <div class="admin-chart-bar" style="height: 72%;"><span>$24K</span></div>
                                <div class="admin-chart-bar" style="height: 66%;"><span>$22K</span></div>
                                <div class="admin-chart-bar" style="height: 88%;"><span>$29K</span></div>
                            </div>
                            <div class="admin-chart-labels">
                                <span>Week 1</span>
                                <span>Week 2</span>
                                <span>Week 3</span>
                                <span>Week 4</span>
                                <span>Week 5</span>
                                <span>Week 6</span>
                            </div>
                        </div>
                    </section>

                    <section class="admin-panel">
                        <div class="admin-panel-head">
                            <div>
                                <h2>Recent orders</h2>
                                <p>High-signal table for the newest activity entering the system.</p>
                            </div>
                            <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/orders">View all</a>
                        </div>
                        <div class="table-responsive">
                            <table class="table app-table">
                                <thead>
                                    <tr>
                                        <th scope="col">Order ID</th>
                                        <th scope="col">Customer</th>
                                        <th scope="col">Date</th>
                                        <th scope="col">Total</th>
                                        <th scope="col">Status</th>
                                        <th scope="col" class="text-end">Action</th>
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
                                                        <span class="status-badge status-pending">Pending</span>
                                                <% } else if ("CONFIRMED".equals(st) || "PREPARING".equals(st) || "DISPATCHED".equals(st)) { %>
                                                        <span class="status-badge status-processing"><%= h(st) %></span>
                                                <% } else if ("DELIVERED".equals(st)) { %>
                                                        <span class="status-badge status-delivered">Delivered</span>
                                                <% } else if ("CANCELLED".equals(st) || "PAYMENT_FAILED".equals(st) || "EXPIRED".equals(st)) { %>
                                                        <span class="status-badge status-cancelled"><%= h(st) %></span>
                                                <% } else { %>
                                                        <span class="status-badge"><%= h(st) %></span>
                                                <% } %>
                                            </td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/orders/detail?id=<%= order.getOrderId() %>">Open</a>
                                            </td>
                                        </tr>
                                    <% } %>
                                    <% if (recentOrders.isEmpty()) { %>
                                        <tr>
                                            <td colspan="6" class="text-center text-muted py-4">No recent orders found.</td>
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
                                <h2>Order status summary</h2>
                                <p>Useful for triage without opening the full order page.</p>
                            </div>
                        </div>
                        <ul class="admin-status-list">
                            <li>
                                <span class="admin-status-label"><span class="admin-status-dot"></span>Pending confirmation</span>
                                <strong><%= stats.getPendingOrdersCount() %></strong>
                            </li>
                            <li>
                                <span class="admin-status-label"><span class="admin-status-dot warning"></span>Shipping</span>
                                <strong><%= stats.getShippingOrdersCount() %></strong>
                            </li>
                            <li>
                                <span class="admin-status-label"><span class="admin-status-dot success"></span>Delivered</span>
                                <strong><%= stats.getDeliveredOrdersCount() %></strong>
                            </li>
                            <li>
                                <span class="admin-status-label"><span class="admin-status-dot danger"></span>Cancelled</span>
                                <strong><%= stats.getCancelledOrdersCount() %></strong>
                            </li>
                        </ul>
                    </section>

                    <section class="admin-panel">
                        <div class="admin-panel-head">
                            <div>
                                <h2>Best selling products</h2>
                                <p>Simple ranked list for spotlight decisions.</p>
                            </div>
                            <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/products">Manage</a>
                        </div>
                        <ul class="admin-mini-list">
                            <li class="admin-mini-list-item">
                                <img src="<%= appPath %>/assets/images/iphone-card.svg" alt="iPhone 16 Pro">
                                <div>
                                    <strong>iPhone 16 Pro</strong>
                                    <small>142 units sold this month</small>
                                </div>
                                <span class="status-badge status-in-stock">Hot</span>
                            </li>
                            <li class="admin-mini-list-item">
                                <img src="<%= appPath %>/assets/images/mac-card.svg" alt="MacBook Air M4">
                                <div>
                                    <strong>MacBook Air M4</strong>
                                    <small>88 units sold this month</small>
                                </div>
                                <span class="status-badge status-low-stock">Low stock</span>
                            </li>
                            <li class="admin-mini-list-item">
                                <img src="<%= appPath %>/assets/images/watch-card.svg" alt="Apple Watch Series 11">
                                <div>
                                    <strong>Apple Watch Series 11</strong>
                                    <small>67 units sold this month</small>
                                </div>
                                <span class="status-badge status-in-stock">Stable</span>
                            </li>
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
