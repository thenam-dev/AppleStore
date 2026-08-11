<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.Collections" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Promotion" %>
<%! 
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("dd/MM/yyyy HH:mm");
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
    private String statusClass(boolean isActive) {
        return isActive ? "status-in-stock" : "status-out-stock";
    }
    private String formatDate(LocalDateTime value) {
        if (value == null) {
            return "";
        }
        return DATE_FORMATTER.format(value);
    }
%>
<%
    List<Promotion> promotions = (List<Promotion>) request.getAttribute("promotions");
    if (promotions == null) {
        promotions = Collections.emptyList();
    }
    String keyword = (String) request.getAttribute("keyword");
    String successMessage = (String) request.getAttribute("successMessage");
    String errorMessage = (String) request.getAttribute("errorMessage");
    String appPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Promotions</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <%
            request.setAttribute("adminSidebarTitle", "Quản lý Khuyến mãi");
            request.setAttribute("adminSidebarDescription", "Servlet, service, DAO and JDBC sample flow.");
            request.setAttribute("adminSidebarFooterTitle", "Backend sample");
            request.setAttribute("adminSidebarFooterDescription", "Promotion module dựa trên UI chuẩn.");
        %>
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />
        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="<%= appPath %>/admin/promotions" method="get" name="adminPromotionsSearchForm">
                    <label class="visually-hidden" for="admin-promotions-search">Tìm khuyến mãi</label>
                    <input id="admin-promotions-search" class="form-control" type="search" name="keyword" value="<%= h(keyword) %>" placeholder="Tìm theo mã voucher...">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/promotions">Reset</a>
                    <div class="admin-user-pill">
                        <div class="account-avatar admin-user-pill-avatar">AD</div>
                        <div>
                            <strong>Admin</strong>
                            <small>Promotion operations</small>
                        </div>
                    </div>
                </div>
            </div>
            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard.html">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Promotions</li>
                </ol>
            </nav>
            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Marketing</span>
                    <h1>Danh sách Voucher</h1>
                    <p>Sample backend flow from JSP to servlet, service, DAO and MySQL.</p>
                </div>
                <a class="btn btn-app-primary" href="<%= appPath %>/admin/promotions/edit">Tạo mới Voucher</a>
            </div>
            <% if (successMessage != null && !successMessage.isBlank()) { %>
                <div class="alert alert-success" role="alert"><%= h(successMessage) %></div>
            <% } %>
            <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="alert alert-danger" role="alert"><%= h(errorMessage) %></div>
            <% } %>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Vouchers</h2>
                        <p>DAO reads from the promotions table and the servlet forwards this collection to JSP.</p>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table app-table">
                        <thead>
                            <tr>
                                <th scope="col">Mã Voucher</th>
                                <th scope="col">Loại & Giá trị</th>
                                <th scope="col">Phạm vi</th>
                                <th scope="col">Sử dụng</th>
                                <th scope="col">Hiệu lực</th>
                                <th scope="col">Trạng thái</th>
                                <th scope="col" class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (promotions.isEmpty()) { %>
                                <tr>
                                    <td colspan="7" class="text-center text-muted py-4">No promotions found.</td>
                                </tr>
                            <% } %>
                            <% for (Promotion p : promotions) { %>
                                <tr>
                                    <td>
                                        <strong><%= h(p.getCode()) %></strong>
                                        <small class="d-block text-muted">ID: #<%= p.getPromoId() %></small>
                                    </td>
                                    <td>
                                        <strong><%= p.getDiscountValue() %> <%= "PERCENT".equals(p.getDiscountType()) ? "%" : "VNĐ" %></strong>
                                        <% if (p.getDiscountMax() != null) { %>
                                            <small class="d-block text-muted">Tối đa: <%= p.getDiscountMax() %></small>
                                        <% } %>
                                    </td>
                                    <td>
                                        <span class="status-badge status-processing"><%= h(p.getScope()) %></span>
                                        <small class="d-block text-muted"><%= h(p.getBenefitTarget()) %></small>
                                    </td>
                                    <td><%= p.getUsedCount() %> / <%= p.getMaxUses() != null ? p.getMaxUses() : "∞" %></td>
                                    <td>
                                        <small class="d-block"><%= h(formatDate(p.getValidFrom())) %></small>
                                        <small class="d-block text-muted"><%= h(formatDate(p.getValidUntil())) %></small>
                                    </td>
                                    <td><span class="status-badge <%= statusClass(p.isActive()) %>"><%= p.isActive() ? "ACTIVE" : "INACTIVE" %></span></td>
                                    <td class="text-end table-actions">
                                        <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/promotions/edit?id=<%= p.getPromoId() %>">Edit</a>
                                        <form class="d-inline" action="<%= appPath %>/admin/promotions/status" method="post">
                                            <input type="hidden" name="promoId" value="<%= p.getPromoId() %>">
                                            <input type="hidden" name="isActive" value="<%= !p.isActive() %>">
                                            <button class="btn <%= p.isActive() ? "btn-app-outline" : "btn-app-primary" %> btn-sm" type="submit">
                                                <%= p.isActive() ? "Deactivate" : "Activate" %>
                                            </button>
                                        </form>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </section>
        </section>
    </main>
</body>
</html>