<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Promotion" %>
<%! 
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("MMM d, yyyy");
    
    private String h(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
%>
<%
    List<Promotion> promotions = (List<Promotion>) request.getAttribute("promotions");
    if (promotions == null) promotions = Collections.emptyList();
    
    String keyword = (String) request.getAttribute("keyword");
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String appPath = request.getContextPath();
    
    // Logic đếm nhanh số lượng đang active để hiển thị lên KPI Grid
    long activeCount = promotions.stream().filter(Promotion::IsActive).count();
    Long totalRedeemed = (Long) request.getAttribute("totalRedeemed");
    Integer expiringSoon = (Integer) request.getAttribute("expiringSoon");
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Apple Online Shop Admin | Vouchers</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
    </head>
    <body class="site-body admin-app">
        <main class="admin-workspace">
            <%
                request.setAttribute("adminSidebarTitle", "Promotion view");
                request.setAttribute("adminSidebarDescription", "Simple voucher management for a lightweight online shop MVP.");
                request.setAttribute("adminSidebarFooterTitle", "Voucher scope");
                request.setAttribute("adminSidebarFooterDescription", "Enough UI to cover code creation, activation, search, and tracking.");
            %>
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

            <section class="admin-main">
                <!-- TOPBAR -->
                <div class="admin-topbar">
                    <form class="admin-topbar-search" action="<%= appPath %>/admin/promotions" method="get" name="adminVoucherSearchForm">
                        <label class="visually-hidden" for="admin-vouchers-search">Search vouchers</label>
                        <input id="admin-vouchers-search" class="form-control" type="search" name="keyword" value="<%= h(keyword) %>" placeholder="Search code or campaign">
                        <button class="btn btn-app-primary" type="submit">Search</button>
                    </form>
                    <div class="admin-topbar-actions">
                        <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/dashboard.html">Dashboard</a>
                        <a class="btn btn-app-primary btn-sm" href="<%= appPath %>/admin/promotions/edit">New Voucher</a>
                    </div>
                </div>

                <!-- BREADCRUMB -->
                <nav aria-label="Breadcrumb">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard.html">Admin</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Vouchers</li>
                    </ol>
                </nav>

                <!-- PAGE HEAD -->
                <div class="admin-page-head">
                    <div>
                        <span class="eyebrow">Promotion master data</span>
                        <h1>Voucher Management</h1>
                        <p>This page gives the team a clean placeholder for voucher CRUD, campaign tracking, and redemption monitoring.</p>
                    </div>
                    <div class="admin-page-actions">
                        <a class="btn btn-app-outline" href="<%= appPath %>/admin/orders">Order Impact</a>
                        <a class="btn btn-app-primary" href="<%= appPath %>/admin/promotions/edit">Create Voucher</a>
                    </div>
                </div>

                <% if (successMessage != null && !successMessage.isBlank()) { %>
                <div class="alert alert-success" role="alert"><%= h(successMessage) %></div>
                <% } %>
                <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="alert alert-danger" role="alert"><%= h(errorMessage) %></div>
                <% } %>

                <!-- KHỐI 1: KPI GRID -->
                <section class="admin-kpi-grid">
                    <article class="stat-card compact">
                        <div class="stat-label">Active</div>
                        <div class="stat-value"><%= activeCount %></div>
                        <p>Running voucher campaigns</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Total Valid</div>
                        <div class="stat-value"><%= promotions.size() %></div>
                        <p>All non-deleted vouchers</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Redeemed</div>
                        <div class="stat-value"><%= totalRedeemed != null ? totalRedeemed : 0 %></div>
                        <p>Tổng lượt đã sử dụng</p>
                    </article>
                    <article class="stat-card compact">
                        <div class="stat-label">Expiring</div>
                        <div class="stat-value"><%= expiringSoon != null ? expiringSoon : 0 %></div>
                        <p>Hết hạn trong 7 ngày tới</p>
                    </article>
                </section>

                <!-- KHỐI 2: VOUCHER LIST -->
                <section class="admin-panel mt-4">
                    <div class="admin-panel-head">
                        <div>
                            <h2>Voucher list</h2>
                            <p>Table-first layout backed by promotions database.</p>
                        </div>
                    </div>
                    <div class="table-responsive">
                        <table class="table app-table">
                            <thead>
                                <tr>
                                    <th scope="col">Code</th>
                                    <th scope="col">Scope</th>
                                    <th scope="col">Discount</th>
                                    <th scope="col">Condition</th>
                                    <th scope="col">Period</th>
                                    <th scope="col">Status</th>
                                    <th scope="col" class="text-end">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (promotions.isEmpty()) { %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">No vouchers found.</td>
                                </tr>
                                <% } %>
                                <% for (Promotion promo : promotions) { %>
                                <tr>
                                    <td><strong><%= h(promo.getCode()) %></strong></td>
                                    <td><%= h(promo.getScope()) %></td>
                                    <td>
                                        <%= promo.getDiscountValue() %><%= "PERCENT".equals(promo.getDiscountType()) ? "%" : " VNĐ" %> off
                                    </td>
                                    <td>Min <%= promo.getMinOrderValue() != null ? promo.getMinOrderValue() : "0" %></td>
                                    <td>
                                        <small class="d-block"><%= promo.getValidFrom() != null ? promo.getValidFrom().format(DATE_FORMATTER) : "" %></small>
                                        <small class="d-block text-muted"><%= promo.getValidUntil() != null ? promo.getValidUntil().format(DATE_FORMATTER) : "" %></small>
                                    </td>
                                    <td>
                                        <span class="status-badge <%= promo.IsActive() ? "status-in-stock" : "status-out-stock" %>">
                                            <%= promo.IsActive() ? "Active" : "Inactive" %>
                                        </span>
                                    </td>
                                    <td class="text-end table-actions">
                                        <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/promotions/edit?id=<%= promo.getPromoId() %>">Edit</a>
                                    </td>
                                </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </section>

                <!-- KHỐI 3: SETUP NOTES -->
                <jsp:include page="/WEB-INF/views/admin/promotions/setup-notes.jsp" />

                <p class="admin-footer-note mt-4">Voucher data is rendered dynamically from the database.</p>
            </section>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="<%= appPath %>/assets/js/main.js"></script>
    </body>
</html>