<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.util.List" %>
<%@ page import="model.Promotion" %>
<%@ page import="model.Category" %>
<%! 
    private String h(Object value) {
        if (value == null) return "";
        return String.valueOf(value).replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;").replace("\"", "&quot;").replace("'", "&#39;");
    }
    private String selected(Object current, String option) {
        if (current == null) return "";
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
        <title>Apple Online Shop Admin | <%= isEdit ? "Edit" : "Create" %> Voucher</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
    </head>
    <body class="site-body admin-app">
        <main class="admin-workspace">
            <%
                request.setAttribute("adminSidebarTitle", isEdit ? "Edit Voucher" : "Create Voucher");
                request.setAttribute("adminSidebarDescription", "Manage discount information.");
                request.setAttribute("adminSidebarFooterTitle", "Voucher scope");
                request.setAttribute("adminSidebarFooterDescription", "Validate logic using PromotionService.");
            %>
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

            <section class="admin-main">
                <!-- TOPBAR -->
                <div class="admin-topbar">
                    <div class="admin-topbar-actions ms-auto">
                        <a class="btn btn-app-outline btn-sm" href="<%= appPath %>/admin/promotions">Back to Vouchers</a>
                    </div>
                </div>

                <!-- BREADCRUMB -->
                <nav aria-label="Breadcrumb">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="<%= appPath %>/admin/dashboard.html">Admin</a></li>
                        <li class="breadcrumb-item"><a href="<%= appPath %>/admin/promotions">Vouchers</a></li>
                        <li class="breadcrumb-item active" aria-current="page"><%= isEdit ? "Edit" : "Create" %></li>
                    </ol>
                </nav>

                <div class="admin-page-head">
                    <div>
                        <span class="eyebrow">Promotion master data</span>
                        <h1><%= isEdit ? "Edit voucher: " + h(p.getCode()) : "Create new voucher" %></h1>
                        <p>Enter the details for the discount campaign.</p>
                    </div>
                </div>

                <% if (errorMessage != null && !errorMessage.isBlank()) { %>
                <div class="alert alert-danger" role="alert"><%= h(errorMessage) %></div>
                <% } %>

                <!-- FORM PANEL -->
                <section class="admin-panel">
                    <form action="<%= appPath %>/admin/promotions/update" method="post" name="adminVoucherForm" class="admin-form-stack">
                        <% if (isEdit) { %>
                        <input type="hidden" name="promoId" value="<%= p.getPromoId() %>">
                        <% } %>

                        <div class="admin-form-grid">
                            <div>
                                <label class="form-label" for="voucher-code">Voucher code</label>
                                <input id="voucher-code" class="form-control" type="text" name="code" value="<%= isEdit ? h(p.getCode()) : "" %>" placeholder="APPLE40" required>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-type">Discount type</label>
                                <select id="voucher-type" class="form-select" name="discountType">
                                    <option value="FIXED" <%= selected(isEdit ? p.getDiscountType() : "", "FIXED") %>>Fixed amount</option>
                                    <option value="PERCENT" <%= selected(isEdit ? p.getDiscountType() : "", "PERCENT") %>>Percentage</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-value">Discount value</label>
                                <input id="voucher-value" class="form-control" type="number" step="0.01" name="discountValue" value="<%= isEdit && p.getDiscountValue() != null ? p.getDiscountValue() : "" %>" placeholder="40" required>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-discount-max">Max discount (If %)</label>
                                <input id="voucher-discount-max" class="form-control" type="number" step="0.01" name="discountMax" value="<%= isEdit && p.getDiscountMax() != null ? p.getDiscountMax() : "" %>" placeholder="Optional max limit">
                            </div>
                            
                            <!-- BỔ SUNG OPTION CATEGORY -->
                            <div>
                                <label class="form-label" for="voucher-scope">Apply scope</label>
                                <select id="voucher-scope" class="form-select" name="scope">
                                    <option value="ORDER" <%= selected(isEdit ? p.getScope() : "", "ORDER") %>>Order total</option>
                                    <option value="CATEGORY" <%= selected(isEdit ? p.getScope() : "", "CATEGORY") %>>Product Category</option>
                                    <option value="PRODUCT" <%= selected(isEdit ? p.getScope() : "", "PRODUCT") %>>Product variant</option>
                                </select>
                            </div>

                            <!-- KHỐI CHỌN DANH MỤC (CATEGORY) -->
                            <div id="category-selection-group" style="display: none;">
                                <label class="form-label" for="voucher-category">Danh mục áp dụng</label>
                                <select id="voucher-category" class="form-select" name="categoryId">
                                    <option value="">-- Chọn danh mục --</option>
                                    <% 
                                        List<Category> categories = (List<Category>) request.getAttribute("categories");
                                        if (categories != null) {
                                            for (Category cat : categories) {
                                    %>
                                        <option value="<%= cat.getCategoryId() %>" <%= (isEdit && p.getCategoryId() != null && p.getCategoryId() == cat.getCategoryId()) ? "selected" : "" %>>
                                            <%= h(cat.getName()) %>
                                        </option>
                                    <%      } 
                                        } 
                                    %>
                                </select>
                                <small class="text-muted d-block mt-1">Bắt buộc khi phạm vi là Category.</small>
                            </div>
                            
                            <!-- KHỐI CHỌN SẢN PHẨM (PRODUCT) -->
                            <div id="product-selection-group" style="display: none;">
                                <label class="form-label" for="voucher-product">Sản phẩm áp dụng</label>
                                <input id="voucher-product" class="form-control" type="number" name="productId" value="<%= isEdit && p.getProductId() != null ? p.getProductId() : "" %>" placeholder="Nhập ID sản phẩm">
                                <small class="text-muted d-block mt-1">Bắt buộc khi phạm vi là Product.</small>
                            </div>
                            
                            <div>
                                <label class="form-label" for="voucher-target">Benefit Target</label>
                                <select id="voucher-target" class="form-select" name="benefitTarget">
                                    <option value="MERCHANDISE" <%= selected(isEdit ? p.getBenefitTarget() : "", "MERCHANDISE") %>>Merchandise (Tiền hàng)</option>
                                    <option value="SHIPPING" <%= selected(isEdit ? p.getBenefitTarget() : "", "SHIPPING") %>>Shipping (Vận chuyển)</option>
                                    <option value="PRODUCT" <%= selected(isEdit ? p.getBenefitTarget() : "", "PRODUCT") %>>Product (Sản phẩm)</option>
                                </select>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-min-order">Minimum order</label>
                                <input id="voucher-min-order" class="form-control" type="number" step="0.01" name="minOrderValue" value="<%= isEdit && p.getMinOrderValue() != null ? p.getMinOrderValue() : "0" %>" placeholder="2500">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-usage-limit">Usage limit</label>
                                <input id="voucher-usage-limit" class="form-control" type="number" name="maxUses" value="<%= isEdit && p.getMaxUses() != null ? p.getMaxUses() : "" %>" placeholder="Leave blank for unlimited">
                            </div>
                            <div>
                                <label class="form-label" for="voucher-start-date">Start date</label>
                                <input id="voucher-start-date" class="form-control" type="datetime-local" name="validFrom" value="<%= isEdit && p.getValidFrom() != null ? p.getValidFrom().format(htmlFormatter) : "" %>" required>
                            </div>
                            <div>
                                <label class="form-label" for="voucher-end-date">End date</label>
                                <input id="voucher-end-date" class="form-control" type="datetime-local" name="validUntil" value="<%= isEdit && p.getValidUntil() != null ? p.getValidUntil().format(htmlFormatter) : "" %>" required>
                            </div>

                            <div class="form-check align-self-end mt-3">
                                <input id="canStack" class="form-check-input" type="checkbox" name="canStack" <%= isEdit && p.isCanStack() ? "checked" : "" %>>
                                <label class="form-check-label" for="canStack">Can Stack (Cộng dồn)</label>
                            </div>
                            <div class="form-check align-self-end mt-3">
                                <input id="isActive" class="form-check-input" type="checkbox" name="isActive" <%= !isEdit || p.isActive() ? "checked" : "" %>>
                                <label class="form-check-label" for="isActive">Active (Kích hoạt)</label>
                            </div>
                        </div>

                        <div class="mt-3">
                            <label class="form-label" for="voucher-note">Internal note (Optional)</label>
                            <textarea id="voucher-note" class="form-control" name="note" rows="4" placeholder="Campaign note, excluded products, or internal approval remark."></textarea>
                        </div>

                        <div class="admin-form-actions mt-4">
                            <a class="btn btn-app-outline" href="<%= appPath %>/admin/promotions">Cancel</a>
                            <button class="btn btn-app-primary" type="submit"><%= isEdit ? "Update Voucher" : "Publish Voucher" %></button>
                        </div>
                    </form>
                </section>

                <jsp:include page="/WEB-INF/views/admin/promotions/setup-notes.jsp" />
            </section>
        </main>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="<%= appPath %>/assets/js/main.js"></script>

        <script>
            document.addEventListener('DOMContentLoaded', function () {
                const discountTypeSelect = document.getElementById('voucher-type');
                const discountMaxInput = document.getElementById('voucher-discount-max');
                
                const scopeSelect = document.getElementById('voucher-scope');
                const productGroup = document.getElementById('product-selection-group');
                const productInput = document.getElementById('voucher-product');
                const categoryGroup = document.getElementById('category-selection-group');
                const categoryInput = document.getElementById('voucher-category');
                const targetSelect = document.getElementById('voucher-target');

                // 1. Hàm kiểm tra và bật/tắt ô Giảm tối đa
                function toggleDiscountMax() {
                    if (discountTypeSelect.value === 'FIXED') {
                        discountMaxInput.disabled = true;  
                        discountMaxInput.value = '';       
                    } else {
                        discountMaxInput.disabled = false; 
                    }
                }

                // 2. Hàm kiểm tra và ẩn/hiện ô Nhập ID Sản phẩm / Danh mục
                function toggleScopeSelection() {
                    // Reset trạng thái hiển thị
                    productGroup.style.display = 'none';
                    categoryGroup.style.display = 'none';
                    targetSelect.style.pointerEvents = 'auto';
                    targetSelect.style.opacity = '1';
                    
                    if (scopeSelect.value === 'PRODUCT') {
                        productGroup.style.display = 'block'; 
                        categoryInput.value = ''; // Xóa data category cũ
                        targetSelect.value = 'PRODUCT';
                        targetSelect.style.pointerEvents = 'none'; 
                        targetSelect.style.opacity = '0.6';
                    } else if (scopeSelect.value === 'CATEGORY') {
                        categoryGroup.style.display = 'block';
                        productInput.value = ''; // Xóa data product cũ
                        if(targetSelect.value === 'PRODUCT') targetSelect.value = 'MERCHANDISE';
                    } else { // ORDER
                        productInput.value = '';
                        categoryInput.value = '';
                        if(targetSelect.value === 'PRODUCT') targetSelect.value = 'MERCHANDISE';
                    }
                }

                // Gọi chạy ngay lần đầu và gán event listener
                toggleDiscountMax();
                discountTypeSelect.addEventListener('change', toggleDiscountMax);
                
                toggleScopeSelection();
                scopeSelect.addEventListener('change', toggleScopeSelection);

                // 3. KIỂM TRA DỮ LIỆU KHI SUBMIT
                document.forms['adminVoucherForm'].addEventListener('submit', function (event) {
                    const discountType = discountTypeSelect.value;
                    const discountValue = parseFloat(document.getElementById('voucher-value').value);
                    const validFrom = document.getElementById('voucher-start-date').value;
                    const validUntil = document.getElementById('voucher-end-date').value;

                    if (discountType === 'PERCENT') {
                        if (discountValue <= 0 || discountValue > 100) {
                            alert('Lỗi: Giá trị giảm theo Phần trăm (%) phải lớn hơn 0 và tối đa là 100.');
                            event.preventDefault(); 
                            return;
                        }
                    } else if (discountType === 'FIXED') {
                        if (discountValue <= 0) {
                            alert('Lỗi: Số tiền giảm cố định phải lớn hơn 0.');
                            event.preventDefault();
                            return;
                        }
                    }

                    // Validate cho PRODUCT
                    if (scopeSelect.value === 'PRODUCT' && productInput.value.trim() === '') {
                        alert('Lỗi: Bạn phải nhập ID Sản phẩm áp dụng khi phạm vi là Product.');
                        event.preventDefault();
                        return;
                    }
                    
                    // Validate cho CATEGORY
                    if (scopeSelect.value === 'CATEGORY' && categoryInput.value.trim() === '') {
                        alert('Lỗi: Bạn phải chọn Danh mục áp dụng khi phạm vi là Category.');
                        event.preventDefault();
                        return;
                    }

                    if (validFrom && validUntil) {
                        const startDate = new Date(validFrom);
                        const endDate = new Date(validUntil);
                        if (endDate <= startDate) {
                            alert('Lỗi: Thời gian kết thúc phải diễn ra SAU thời gian bắt đầu.');
                            event.preventDefault();
                            return;
                        }
                    }
                });
            });
        </script>
    </body>
</html>