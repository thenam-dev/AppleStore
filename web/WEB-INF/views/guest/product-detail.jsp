<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cửa hàng Apple Trực tuyến | ${empty product ? 'Sản phẩm' : product.name}</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="site-body">

    <c:set var="ctx" value="${pageContext.request.contextPath}" />

    <%-- =====================================================
         Trang này được ProductDetailServlet (controller.customer.product,
         urlPatterns = {"/product"}, tham số ?id=) forward tới, với attribute:
             product          : model.entity.catalog.Product (null nếu lỗi)
             variants         : List<ProductVariant> (mọi variant active của sp)
             variantColors    : List<String> màu duy nhất, đúng thứ tự
             variantStorages  : List<Integer> dung lượng (GB) duy nhất
             defaultVariant   : ProductVariant được chọn sẵn khi vào trang
             relatedProducts  : List<Product> gợi ý cùng danh mục
             errorMsg         : String (nếu product null)
         Giá/khuyến mãi/tồn kho thuộc về ProductVariant, không thuộc Product,
         nên phần giá + nút "Thêm vào giỏ" phụ thuộc vào variant đang chọn
         (xử lý bằng JS ở cuối trang dựa trên mảng productVariants).
    ===================================================== --%>

    <c:choose>
    <c:when test="${empty product}">
        <div class="container py-5">
            <h2>Không tìm thấy sản phẩm</h2>
            <p>${not empty errorMsg ? errorMsg : 'Sản phẩm không tồn tại hoặc đã ngừng kinh doanh.'}</p>
            <a class="btn btn-app-primary" href="${ctx}/products">Quay lại danh sách sản phẩm</a>
        </div>
    </c:when>
    <c:otherwise>

    <jsp:include page="/WEB-INF/views/common/header.jsp">
        <jsp:param name="active" value="products" />
    </jsp:include>

    <main>
        <section class="section-block">
            <div class="container">
                <nav aria-label="Breadcrumb">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="${ctx}/index.jsp">Trang chủ</a></li>
                        <li class="breadcrumb-item"><a href="${ctx}/products">Sản phẩm</a></li>
                        <li class="breadcrumb-item"><a href="${ctx}/products?categoryId=${product.categoryId}">${product.categoryName}</a></li>
                        <li class="breadcrumb-item active" aria-current="page">${product.name}</li>
                    </ol>
                </nav>

                <div class="product-detail-layout">
                    <div class="product-gallery-shell">
                        <div class="product-main-media">
                            <%-- TODO: chưa có bảng ảnh sản phẩm, tạm dùng ảnh placeholder theo danh mục --%>
                            <img src="${ctx}/assets/images/iphone-detail-front.svg" alt="${product.name}" data-gallery-main>
                        </div>
                    </div>

                    <div class="product-detail-summary">
                        <span class="eyebrow">${product.categoryName}<c:if test="${not empty product.brand}"> &middot; ${product.brand}</c:if></span>
                        <h1>${product.name}</h1>

                        <c:if test="${product.rating != null}">
                            <div class="detail-rating">
                                <strong><fmt:formatNumber value="${product.rating}" pattern="0.0"/></strong>
                                <span>Đã bán ${product.soldQuantity} sản phẩm</span>
                            </div>
                        </c:if>

                        <c:if test="${empty variants}">
                            <div class="alert alert-warning">Sản phẩm hiện chưa có phiên bản (màu/dung lượng) nào để bán.</div>
                        </c:if>

                        <c:if test="${not empty variants}">
                        <div class="price-stack">
                            <div class="product-price">
                                <strong id="detail-current-price">$0</strong>
                                <span id="detail-original-price" class="is-hidden">$0</span>
                            </div>
                            <span id="detail-save-badge" class="app-badge badge-sale is-hidden">Tiết kiệm</span>
                        </div>

                        <div class="detail-availability">
                            <span id="detail-stock-badge" class="status-badge status-in-stock">Còn hàng</span>
                        </div>
                        </c:if>

                        <p class="detail-intro">${product.description}</p>

                        <form id="add-to-cart-form" action="${ctx}/cart" method="post">
                            <input type="hidden" name="action" value="add">
                            <input type="hidden" name="productId" value="${product.productId}">
                            <input type="hidden" name="variantId" id="selected-variant-id"
                                   value="${defaultVariant != null ? defaultVariant.variantId : ''}">

                            <c:if test="${not empty variantColors}">
                                <div class="detail-selector-group">
                                    <div class="selector-head">
                                        <strong>Màu sắc</strong>
                                        <small>Đã chọn: <span id="detail-color-selected"></span></small>
                                    </div>
                                    <div class="option-group" id="color-option-group">
                                        <c:forEach items="${variantColors}" var="color">
                                            <button class="option-chip" type="button"
                                                    data-variant-color="${fn:escapeXml(color)}"
                                                    aria-pressed="false">${color}</button>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                            <c:if test="${not empty variantStorages}">
                                <div class="detail-selector-group">
                                    <div class="selector-head">
                                        <strong>Dung lượng</strong>
                                        <small>Đã chọn: <span id="detail-storage-selected"></span></small>
                                    </div>
                                    <div class="option-group" id="storage-option-group">
                                        <c:forEach items="${variantStorages}" var="storage">
                                            <button class="option-chip" type="button"
                                                    data-variant-storage="${storage}"
                                                    aria-pressed="false">${storage}GB</button>
                                        </c:forEach>
                                    </div>
                                </div>
                            </c:if>

                            <div class="detail-selector-group">
                                <div class="selector-head">
                                    <strong>Số lượng</strong>
                                </div>
                                <div class="quantity-control" data-quantity-control>
                                    <button type="button" data-quantity-action="decrease">-</button>
                                    <input type="number" name="quantity" id="detail-quantity-input" value="1" min="1" max="5">
                                    <button type="button" data-quantity-action="increase">+</button>
                                </div>
                            </div>

                            <div class="detail-actions">
                                <button id="add-to-cart-btn" class="btn btn-app-primary btn-lg" type="submit"
                                        ${empty variants ? 'disabled' : ''}>Thêm vào giỏ</button>
                                <button id="buy-now-btn" class="btn btn-app-secondary btn-lg" type="submit" formaction="${ctx}/checkout"
                                        ${empty variants ? 'disabled' : ''}>Mua ngay</button>
                                <button class="btn btn-app-outline btn-lg" type="button">Thêm vào yêu thích</button>
                            </div>
                        </form>

                        <div class="detail-meta-grid">
                            <c:if test="${product.warrantyMonths > 0}">
                                <div class="detail-meta-card">
                                    <strong>Bảo hành</strong>
                                    <span>${product.warrantyMonths} tháng<c:if test="${not empty product.warrantyProvider}"> &ndash; ${product.warrantyProvider}</c:if></span>
                                </div>
                            </c:if>
                            <c:if test="${not empty product.productCondition}">
                                <div class="detail-meta-card">
                                    <strong>Tình trạng</strong>
                                    <span>${product.productCondition}</span>
                                </div>
                            </c:if>
                            <c:if test="${not empty product.importType}">
                                <div class="detail-meta-card">
                                    <strong>Xuất xứ</strong>
                                    <span>${product.importType}<c:if test="${not empty product.originCountry}"> &ndash; ${product.originCountry}</c:if></span>
                                </div>
                            </c:if>
                        </div>
                    </div>
                </div>
            </div>
        </section>

        <c:if test="${not empty variants}">
        <section class="section-block section-soft">
            <div class="container">
                <div class="detail-section-card">
                    <ul class="nav nav-tabs app-tabs" id="productDetailTabs" role="tablist">
                        <li class="nav-item" role="presentation">
                            <button class="nav-link active" data-bs-toggle="tab" data-bs-target="#detail-description-pane" type="button">Mô tả</button>
                        </li>
                        <li class="nav-item" role="presentation">
                            <button class="nav-link" data-bs-toggle="tab" data-bs-target="#detail-spec-pane" type="button">Thông số</button>
                        </li>
                    </ul>
                    <div class="tab-content app-tab-content detail-tab-body">
                        <div class="tab-pane fade show active" id="detail-description-pane">
                            ${product.description}
                        </div>
                        <div class="tab-pane fade" id="detail-spec-pane">
                            <div class="spec-grid">
                                <c:if test="${not empty product.modelCode}"><div><strong>Model</strong><span>${product.modelCode}</span></div></c:if>
                                <c:if test="${product.releaseYear != null}"><div><strong>Năm ra mắt</strong><span>${product.releaseYear}</span></div></c:if>
                                <c:forEach items="${variants}" var="v">
                                    <div><strong>${v.variantLabel != null ? v.variantLabel : v.sku}</strong>
                                        <span>
                                            <c:if test="${v.storageCapacityGb != null}">${v.storageCapacityGb}GB </c:if>
                                            <c:if test="${v.ramGb != null}">/ ${v.ramGb}GB RAM </c:if>
                                            <c:if test="${not empty v.chipOption}">/ ${v.chipOption} </c:if>
                                            <c:if test="${not empty v.connectivity}">/ ${v.connectivity}</c:if>
                                        </span>
                                    </div>
                                </c:forEach>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </section>
        </c:if>

        <c:if test="${not empty relatedProducts}">
        <section class="section-block">
            <div class="container">
                <div class="section-heading">
                    <div>
                        <span class="eyebrow">Sản phẩm liên quan</span>
                        <h2>Có thể bạn cũng quan tâm</h2>
                    </div>
                    <a class="btn btn-app-outline" href="${ctx}/products">Quay lại danh mục</a>
                </div>
                <div class="row g-4 related-grid">
                    <c:forEach items="${relatedProducts}" var="rp">
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <img src="${ctx}/assets/images/iphone-card.svg" alt="${rp.name}">
                                </div>
                                <div class="product-card-body">
                                    <h3>${rp.name}</h3>
                                    <div class="product-price">
                                        <strong>Từ <fmt:formatNumber value="${rp.minPrice}" pattern="#,##0"/> VND</strong>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-primary w-100" href="${ctx}/product?id=${rp.productId}">Xem chi tiết</a>
                                    </div>
                                </div>
                            </article>
                        </div>
                    </c:forEach>
                </div>
            </div>
        </section>
        </c:if>
    </main>

    <jsp:include page="/WEB-INF/views/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${ctx}/assets/js/main.js"></script>

    <c:if test="${not empty variants}">
    <script>
    (function () {
        // Dữ liệu variant do servlet chuẩn bị, JS chỉ dùng để đổi giá/tồn kho
        // khi khách bấm chọn màu/dung lượng khác nhau - KHÔNG có business logic
        // nào khác ngoài việc match đúng variant tương ứng.
        var productVariants = [
            <c:forEach items="${variants}" var="v" varStatus="st">
            {
                id: ${v.variantId},
                color: "${fn:escapeXml(v.colorName)}",
                storage: ${v.storageCapacityGb != null ? v.storageCapacityGb : 'null'},
                price: ${v.price},
                discountPrice: ${v.discountPrice != null ? v.discountPrice : 'null'},
                discountStart: "${v.discountStart}",
                discountEnd: "${v.discountEnd}",
                stock: ${v.stockQuantity},
                active: ${v.active}
            }<c:if test="${!st.last}">,</c:if>
            </c:forEach>
        ];

        var LOW_STOCK_THRESHOLD = ${lowStockThreshold};
        var defaultVariantId = ${defaultVariant != null ? defaultVariant.variantId : 'null'};

        var selectedColor = null;
        var selectedStorage = null;

        function findVariant(color, storage) {
            for (var i = 0; i < productVariants.length; i++) {
                var v = productVariants[i];
                if ((color === null || v.color === color) && (storage === null || v.storage === storage)) {
                    return v;
                }
            }
            return null;
        }

        function isDiscountActive(v) {
            if (v.discountPrice == null) { return false; }
            var now = new Date();
            var start = v.discountStart ? new Date(v.discountStart) : null;
            var end = v.discountEnd ? new Date(v.discountEnd) : null;
            if (start && now < start) { return false; }
            if (end && now > end) { return false; }
            return true;
        }

        function formatPrice(value) {
            return '$' + Math.round(value).toLocaleString('en-US');
        }

        function renderVariant(v) {
            if (!v) { return; }
            document.getElementById('selected-variant-id').value = v.id;

            var currentPriceEl = document.getElementById('detail-current-price');
            var originalPriceEl = document.getElementById('detail-original-price');
            var saveBadgeEl = document.getElementById('detail-save-badge');

            if (isDiscountActive(v)) {
                currentPriceEl.textContent = formatPrice(v.discountPrice);
                originalPriceEl.textContent = formatPrice(v.price);
                originalPriceEl.classList.remove('is-hidden');
                saveBadgeEl.textContent = 'Tiết kiệm ' + formatPrice(v.price - v.discountPrice);
                saveBadgeEl.classList.remove('is-hidden');
            } else {
                currentPriceEl.textContent = formatPrice(v.price);
                originalPriceEl.classList.add('is-hidden');
                saveBadgeEl.classList.add('is-hidden');
            }

            var stockBadge = document.getElementById('detail-stock-badge');
            var addBtn = document.getElementById('add-to-cart-btn');
            var buyBtn = document.getElementById('buy-now-btn');
            var qtyInput = document.getElementById('detail-quantity-input');

            if (v.stock <= 0 || !v.active) {
                stockBadge.textContent = 'Hết hàng';
                stockBadge.className = 'status-badge status-out-stock';
                addBtn.disabled = true;
                buyBtn.disabled = true;
                qtyInput.max = 1;
            } else if (v.stock < LOW_STOCK_THRESHOLD) {
                stockBadge.textContent = 'Sắp hết hàng';
                stockBadge.className = 'status-badge status-low-stock';
                addBtn.disabled = false;
                buyBtn.disabled = false;
                qtyInput.max = Math.min(5, v.stock);
            } else {
                stockBadge.textContent = 'Còn hàng';
                stockBadge.className = 'status-badge status-in-stock';
                addBtn.disabled = false;
                buyBtn.disabled = false;
                qtyInput.max = 5;
            }
        }

        function selectColor(color, btn) {
            selectedColor = color;
            document.getElementById('detail-color-selected').textContent = color;
            document.querySelectorAll('#color-option-group .option-chip').forEach(function (c) {
                c.classList.remove('active');
                c.setAttribute('aria-pressed', 'false');
            });
            btn.classList.add('active');
            btn.setAttribute('aria-pressed', 'true');
            applySelection();
        }

        function selectStorage(storage, btn) {
            selectedStorage = storage;
            document.getElementById('detail-storage-selected').textContent = storage + 'GB';
            document.querySelectorAll('#storage-option-group .option-chip').forEach(function (c) {
                c.classList.remove('active');
                c.setAttribute('aria-pressed', 'false');
            });
            btn.classList.add('active');
            btn.setAttribute('aria-pressed', 'true');
            applySelection();
        }

        function applySelection() {
            var match = findVariant(selectedColor, selectedStorage);
            if (match) {
                renderVariant(match);
            }
        }

        document.querySelectorAll('#color-option-group .option-chip').forEach(function (btn) {
            btn.addEventListener('click', function () {
                selectColor(btn.getAttribute('data-variant-color'), btn);
            });
        });
        document.querySelectorAll('#storage-option-group .option-chip').forEach(function (btn) {
            btn.addEventListener('click', function () {
                selectStorage(parseInt(btn.getAttribute('data-variant-storage'), 10), btn);
            });
        });

        // Khởi tạo trạng thái ban đầu theo defaultVariant do servlet chọn sẵn
        var initial = null;
        for (var i = 0; i < productVariants.length; i++) {
            if (productVariants[i].id === defaultVariantId) { initial = productVariants[i]; break; }
        }
        if (!initial && productVariants.length > 0) { initial = productVariants[0]; }
        if (initial) {
            var colorBtn = document.querySelector('#color-option-group .option-chip[data-variant-color="' + initial.color + '"]');
            var storageBtn = document.querySelector('#storage-option-group .option-chip[data-variant-storage="' + initial.storage + '"]');
            if (colorBtn) { selectColor(initial.color, colorBtn); }
            if (storageBtn) { selectStorage(initial.storage, storageBtn); }
            if (!colorBtn && !storageBtn) { renderVariant(initial); }
        }
    })();
    </script>
    </c:if>

    </c:otherwise>
    </c:choose>
</body>
</html>
