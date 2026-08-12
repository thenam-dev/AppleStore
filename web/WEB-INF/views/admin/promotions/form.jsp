<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="model.Promotion" %>
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
    private String selected(Object current, String option) {
        if (current == null) {
            return "";
        }
        return option.equalsIgnoreCase(String.valueOf(current)) ? "selected" : "";
    }
%>
<%
    Promotion p = (Promotion) request.getAttribute("promo");
    boolean isEdit = (p != null);
    String errorMessage = (String) request.getAttribute("errorMessage");
    String appPath = request.getContextPath();
    DateTimeFormatter htmlFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | <%= isEdit ? "Edit" : "Create" %> Promotion</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <%
            request.setAttribute("adminSidebarTitle", isEdit ? "Edit Promotion" : "Create Promotion");
            request.setAttribute("adminSidebarDescription", "Validate in service, persist through DAO.");
            request.setAttribute("adminSidebarFooterTitle", "Form sample");
            request.setAttribute("adminSidebarFooterDescription", "Form đồng nhất với cấu trúc chuẩn của dự án.");
        %>
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />
        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="<%= appPath %>/admin/promotions" method="get" name="adminPromotionsSearchForm">
                    <label class="visually-hidden" for="admin-promotions-search">Tìm khuyến mãi</label>
                    <input id="admin-promotions-search" class="form-control" type="search" name="keyword" placeholder="Tìm theo mã voucher...">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/promotions">Back to Promotions</a>
                </div>
            </div>
            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item"><a href="<%= appPath %>/admin/promotions">Promotions</a></li>
                    <li class="breadcrumb-item active" aria-current="page"><%= isEdit ? "Edit" : "Create" %></li>
                </ol>
            </nav>
            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Marketing</span>
                    <h1><%= isEdit ? "Sửa thông tin Voucher" : "Tạo Voucher mới" %></h1>
                    <p>Servlet receives the form, service validates the request, DAO updates the promotions table.</p>
                </div>
            </div>
            <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="alert alert-danger" role="alert"><%= h(errorMessage) %></div>
            <% } %>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Thông tin Voucher</h2>
                        <p>Form chia 2 cột đồng nhất với user_form.</p>
                    </div>
                </div>
                <form class="admin-form-stack" action="<%= appPath %>/admin/promotions/update" method="post">
                    <% if (isEdit) { %>
                        <input type="hidden" name="promoId" value="<%= p.getPromoId() %>">
                    <% } %>
                    
                    <div class="admin-form-grid">
                        <div>
                            <label class="form-label" for="code">Mã Voucher</label>
                            <input id="code" class="form-control" type="text" name="code" value="<%= isEdit ? h(p.getCode()) : "" %>" required>
                        </div>
                        <div>
                            <label class="form-label" for="discountType">Loại giảm giá</label>
                            <select id="discountType" class="form-select" name="discountType" required>
                                <option value="FIXED" <%= selected(isEdit ? p.getDiscountType() : "", "FIXED") %>>Tiền cố định (FIXED)</option>
                                <option value="PERCENT" <%= selected(isEdit ? p.getDiscountType() : "", "PERCENT") %>>Phần trăm (PERCENT)</option>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="discountValue">Giá trị giảm</label>
                            <input id="discountValue" class="form-control" type="number" step="0.01" name="discountValue" value="<%= isEdit && p.getDiscountValue() != null ? p.getDiscountValue() : "" %>" required>
                        </div>
                        <div>
                            <label class="form-label" for="discountMax">Giảm tối đa (Nếu là %)</label>
                            <input id="discountMax" class="form-control" type="number" step="0.01" name="discountMax" value="<%= isEdit && p.getDiscountMax() != null ? p.getDiscountMax() : "" %>">
                        </div>
                        <div>
                            <label class="form-label" for="minOrderValue">Đơn tối thiểu</label>
                            <input id="minOrderValue" class="form-control" type="number" step="0.01" name="minOrderValue" value="<%= isEdit && p.getMinOrderValue() != null ? p.getMinOrderValue() : "0" %>">
                        </div>
                        <div>
                            <label class="form-label" for="maxUses">Số lượt tối đa</label>
                            <input id="maxUses" class="form-control" type="number" name="maxUses" placeholder="Bỏ trống nếu không giới hạn" value="<%= isEdit && p.getMaxUses() != null ? p.getMaxUses() : "" %>">
                        </div>
                        <div>
                            <label class="form-label" for="scope">Phạm vi áp dụng (Scope)</label>
                            <select id="scope" class="form-select" name="scope">
                                <option value="ORDER" <%= selected(isEdit ? p.getScope() : "", "ORDER") %>>Toàn bộ Đơn hàng</option>
                                <option value="PRODUCT" <%= selected(isEdit ? p.getScope() : "", "PRODUCT") %>>Một sản phẩm cụ thể</option>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="benefitTarget">Mục tiêu (Benefit Target)</label>
                            <select id="benefitTarget" class="form-select" name="benefitTarget">
                                <option value="MERCHANDISE" <%= selected(isEdit ? p.getBenefitTarget() : "", "MERCHANDISE") %>>Tiền hàng</option>
                                <option value="SHIPPING" <%= selected(isEdit ? p.getBenefitTarget() : "", "SHIPPING") %>>Phí vận chuyển</option>
                                <option value="PAYMENT_METHOD" <%= selected(isEdit ? p.getBenefitTarget() : "", "PAYMENT_METHOD") %>>Thanh toán</option>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="validFrom">Từ ngày</label>
                            <input id="validFrom" class="form-control" type="datetime-local" name="validFrom" value="<%= isEdit && p.getValidFrom() != null ? p.getValidFrom().format(htmlFormatter) : "" %>" required>
                        </div>
                        <div>
                            <label class="form-label" for="validUntil">Đến ngày</label>
                            <input id="validUntil" class="form-control" type="datetime-local" name="validUntil" value="<%= isEdit && p.getValidUntil() != null ? p.getValidUntil().format(htmlFormatter) : "" %>" required>
                        </div>
                        
                        <div class="form-check align-self-end mt-3">
                            <input id="canStack" class="form-check-input" type="checkbox" name="canStack" <%= isEdit && p.isCanStack() ? "checked" : "" %>>
                            <label class="form-check-label" for="canStack">Cộng dồn (Can Stack)</label>
                        </div>
                        <div class="form-check align-self-end mt-3">
                            <input id="isActive" class="form-check-input" type="checkbox" name="isActive" <%= !isEdit || p.isActive() ? "checked" : "" %>>
                            <label class="form-check-label" for="isActive">Kích hoạt (Active)</label>
                        </div>
                    </div>

                    <div class="admin-form-actions mt-4">
                        <a class="btn btn-app-outline" href="<%= appPath %>/admin/promotions">Cancel</a>
                        <button class="btn btn-app-primary" type="submit">Save Changes</button>
                    </div>
                </form>
            </section>
        </section>
    </main>
</body>
</html>
