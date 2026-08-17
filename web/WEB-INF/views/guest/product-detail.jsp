<%--
  product-detail.jsp — chi tiết sản phẩm.
  Servlet (ProductDetailServlet, /product?id=) forward tới đây với:
    product         : Product (null nếu không tìm thấy / đã ngừng bán) —
                       {productId,name,description,brand,modelCode,releaseYear,productCondition,
                        importType,originCountry,warrantyMonths,warrantyProvider,categoryId,
                        categoryName,rating,soldQuantity,primaryImageUrl}
    variants        : List<ProductVariant> mọi variant ACTIVE của sản phẩm
                       {variantId,variantLabel,sku,colorName,storageCapacityGb,ramGb,chipOption,
                        connectivity,price,discountPrice,discountStart,discountEnd,stockQuantity,active}
    variantColors   : List<String> màu duy nhất theo đúng thứ tự xuất hiện
    variantStorages : List<Integer> dung lượng (GB) duy nhất theo đúng thứ tự xuất hiện
    defaultVariant  : ProductVariant được chọn sẵn khi vào trang (null nếu không có variant nào)
    relatedProducts : List<Product> gợi ý cùng danh mục
    lowStockThreshold : int
    errorMsg        : String (khi product null)
  Giá/khuyến mãi/tồn kho thuộc về ProductVariant chứ không thuộc Product, nên phần giá +
  nút "Thêm vào giỏ" đổi theo variant đang chọn — xử lý bằng JS ở cuối trang dựa trên
  mảng variant JSON, KHÔNG có business logic nào khác ngoài việc match đúng variant.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title><c:out value="${empty product ? 'Sản phẩm' : product.name}"/> · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
</head>
<body>

<c:choose>
  <%-- ================= KHÔNG TÌM THẤY SẢN PHẨM ================= --%>
  <c:when test="${empty product}">
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>
    <div style="padding:60px 26px">
      <div class="empty">
        <div class="ring"><svg width="26" height="26"><use href="#i-alert"/></svg></div>
        <h3>Không tìm thấy sản phẩm</h3>
        <p><c:out value="${not empty errorMsg ? errorMsg : 'Sản phẩm không tồn tại hoặc đã ngừng kinh doanh.'}"/></p>
        <a class="btn titan" href="${ctx}/products">Quay lại danh sách sản phẩm</a>
      </div>
    </div>
    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
  </c:when>

  <%-- ================= CHI TIẾT SẢN PHẨM ================= --%>
  <c:otherwise>
    <c:set var="pIcon" value="${product.categoryId == 1 ? 'd-phone' : product.categoryId == 2 ? 'd-pad' : product.categoryId == 3 ? 'd-mac' : product.categoryId == 4 ? 'd-watch' : product.categoryId == 5 ? 'd-pods' : 'd-acc'}"/>
    <c:set var="activeMenu" value="${product.categoryId == 1 ? 'iphone' : product.categoryId == 2 ? 'ipad' : product.categoryId == 3 ? 'mac' : product.categoryId == 4 ? 'watch' : product.categoryId == 7 ? 'accessory' : ''}" scope="request"/>
    <jsp:include page="/WEB-INF/views/common/header.jsp"/>

    <nav class="crumb">
      <a href="${ctx}/home">Trang chủ</a><span>/</span>
      <a href="${ctx}/products?categoryId=${product.categoryId}"><c:out value="${product.categoryName}"/></a><span>/</span>
      <span style="color:var(--ink)"><c:out value="${product.name}"/></span>
    </nav>

    <div style="padding:0 26px">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
    </div>

    <div style="padding:14px 26px 30px;display:grid;grid-template-columns:1fr 1fr;gap:34px">

      <div class="shot dark" style="aspect-ratio:4/3">
        <c:choose>
          <c:when test="${not empty product.primaryImageUrl}">
            <img src="${ctx}/${product.primaryImageUrl}" alt="<c:out value='${product.name}'/>">
          </c:when>
          <c:otherwise><svg style="color:var(--titan);width:34%"><use href="#${pIcon}"/></svg></c:otherwise>
        </c:choose>
      </div>

      <div>
        <div style="display:flex;gap:8px;align-items:center;margin-bottom:12px;flex-wrap:wrap">
          <c:choose>
            <c:when test="${empty defaultVariant}"><span class="badge off">Chưa có phiên bản bán</span></c:when>
            <c:when test="${defaultVariant.stockQuantity <= 0}"><span id="detail-stock-badge" class="badge off">Hết hàng</span></c:when>
            <c:when test="${defaultVariant.stockQuantity < lowStockThreshold}"><span id="detail-stock-badge" class="badge warn">Sắp hết hàng</span></c:when>
            <c:otherwise><span id="detail-stock-badge" class="badge ok">Còn ${defaultVariant.stockQuantity} máy</span></c:otherwise>
          </c:choose>
          <c:if test="${product.rating != null}">
            <span class="mono" style="font-size:11px;color:var(--ash)">★ <fmt:formatNumber value="${product.rating}" pattern="0.0"/> · Đã bán ${product.soldQuantity}</span>
          </c:if>
        </div>

        <span class="t-eyebrow"><c:out value="${product.categoryName}"/><c:if test="${not empty product.brand}"> · <c:out value="${product.brand}"/></c:if></span>
        <h1 style="font-size:28px;text-transform:uppercase;margin-top:6px"><c:out value="${product.name}"/></h1>

        <c:choose>
          <c:when test="${empty variants}">
            <div class="flash err" style="margin:16px 0">
              <svg width="18" height="18"><use href="#i-alert"/></svg>
              <div>Sản phẩm hiện chưa có phiên bản (màu/dung lượng) nào để bán.</div>
            </div>
          </c:when>
          <c:otherwise>
            <div style="display:flex;align-items:baseline;gap:12px;margin:16px 0 4px">
              <span id="detail-current-price" style="font-family:var(--display);font-stretch:114%;font-weight:700;font-size:28px">
                <fmt:formatNumber value="${defaultVariant.price}" type="number" maxFractionDigits="0"/> ₫
              </span>
              <span id="detail-original-price" style="text-decoration:line-through;color:var(--ash);font-size:14px;display:none"></span>
              <span id="detail-save-badge" class="badge dan" style="display:none"></span>
            </div>
          </c:otherwise>
        </c:choose>

        <p style="color:var(--graphite);font-size:13.5px;margin:0 0 20px"><c:out value="${product.description}"/></p>

        <form id="add-to-cart-form" method="post" action="${ctx}/cart">
          <input type="hidden" name="action" value="add">
          <input type="hidden" name="variantId" id="selected-variant-id" value="${defaultVariant.variantId}">

          <c:if test="${not empty variantColors}">
            <div style="margin-bottom:18px">
              <div class="selector-head" style="display:flex;justify-content:space-between;margin-bottom:9px">
                <span class="t-eyebrow" style="margin:0">Màu sắc</span>
                <small style="font-size:12px;color:var(--ash)">Đã chọn: <span id="detail-color-selected"></span></small>
              </div>
              <div style="display:flex;gap:9px;flex-wrap:wrap" id="color-option-group">
                <c:forEach var="color" items="${variantColors}">
                  <button class="option-chip ${color eq defaultVariant.colorName ? 'active' : ''}" type="button"
                          data-variant-color="<c:out value='${color}'/>" aria-pressed="${color eq defaultVariant.colorName}">
                    <c:out value="${color}"/>
                  </button>
                </c:forEach>
              </div>
            </div>
          </c:if>

          <c:if test="${not empty variantStorages}">
            <div style="margin-bottom:22px">
              <div class="selector-head" style="display:flex;justify-content:space-between;margin-bottom:9px">
                <span class="t-eyebrow" style="margin:0">Dung lượng</span>
                <small style="font-size:12px;color:var(--ash)">Đã chọn: <span id="detail-storage-selected"></span></small>
              </div>
              <div style="display:flex;gap:9px;flex-wrap:wrap" id="storage-option-group">
                <c:forEach var="storage" items="${variantStorages}">
                  <button class="option-chip ${storage eq defaultVariant.storageCapacityGb ? 'active' : ''}" type="button"
                          data-variant-storage="${storage}" aria-pressed="${storage eq defaultVariant.storageCapacityGb}">
                    ${storage}GB
                  </button>
                </c:forEach>
              </div>
            </div>
          </c:if>

          <div style="display:flex;gap:10px;align-items:center;margin-bottom:20px;flex-wrap:wrap">
            <div class="qty" data-quantity-control>
              <button type="button" data-quantity-action="decrease" aria-label="Giảm số lượng">−</button>
              <input type="number" name="quantity" id="detail-quantity-input" value="1" min="1"
                     max="${empty defaultVariant ? 1 : defaultVariant.stockQuantity}" inputmode="numeric">
              <button type="button" data-quantity-action="increase" aria-label="Tăng số lượng">+</button>
            </div>
            <c:choose>
              <c:when test="${not empty defaultVariant}">
                <button type="submit" id="add-to-cart-btn" class="btn titan" style="flex:1">Thêm vào giỏ hàng</button>
              </c:when>
              <c:otherwise>
                <button type="button" class="btn quiet" style="flex:1" disabled>Hết hàng</button>
              </c:otherwise>
            </c:choose>
            <a class="btn ghost" href="${ctx}/cart">Xem giỏ hàng</a>
          </div>
        </form>

        <div class="etch" style="border-radius:var(--r-sm);margin-bottom:18px">
          <span>Chính hãng Apple</span><i class="dot"></i><span>Đổi trả 7 ngày</span><i class="dot"></i><span>Giao toàn quốc</span>
        </div>

        <div class="panel">
          <div class="panel-head"><h3>Thông số kỹ thuật</h3></div>
          <div class="panel-pad">
            <dl class="kv">
              <c:if test="${not empty product.modelCode}"><dt>Model</dt><dd><c:out value="${product.modelCode}"/></dd></c:if>
              <c:if test="${product.releaseYear != null}"><dt>Năm ra mắt</dt><dd>${product.releaseYear}</dd></c:if>
              <c:if test="${product.warrantyMonths > 0}">
                <dt>Bảo hành</dt><dd>${product.warrantyMonths} tháng<c:if test="${not empty product.warrantyProvider}"> – <c:out value="${product.warrantyProvider}"/></c:if></dd>
              </c:if>
              <c:if test="${not empty product.productCondition}"><dt>Tình trạng</dt><dd><c:out value="${product.productCondition}"/></dd></c:if>
              <c:if test="${not empty product.importType}">
                <dt>Xuất xứ</dt><dd><c:out value="${product.importType}"/><c:if test="${not empty product.originCountry}"> – <c:out value="${product.originCountry}"/></c:if></dd>
              </c:if>
            </dl>
            <c:if test="${not empty variants}">
              <table class="table" style="margin-top:14px">
                <thead><tr><th>Phiên bản</th><th>Thông số</th><th>Giá</th><th>Kho</th></tr></thead>
                <tbody>
                  <c:forEach var="v" items="${variants}">
                    <tr>
                      <td><b><c:out value="${not empty v.variantLabel ? v.variantLabel : v.sku}"/></b></td>
                      <td style="color:var(--ash)">
                        <c:if test="${v.storageCapacityGb != null}">${v.storageCapacityGb}GB </c:if>
                        <c:if test="${v.ramGb != null}">/ ${v.ramGb}GB RAM </c:if>
                        <c:if test="${not empty v.chipOption}">/ <c:out value="${v.chipOption}"/> </c:if>
                        <c:if test="${not empty v.connectivity}">/ <c:out value="${v.connectivity}"/></c:if>
                      </td>
                      <td class="num"><fmt:formatNumber value="${v.price}" type="number" maxFractionDigits="0"/> ₫</td>
                      <td class="num">${v.stockQuantity}</td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </c:if>
          </div>
        </div>
      </div>
    </div>

    <c:if test="${not empty relatedProducts}">
      <section class="sec" style="border-top:1px solid var(--line)">
        <div class="sec-head"><h3>Sản phẩm liên quan</h3><a href="${ctx}/products?categoryId=${product.categoryId}">Xem cả danh mục</a></div>
        <div class="p-grid">
          <c:forEach var="p" items="${relatedProducts}">
            <c:set var="card" value="${p}" scope="request"/>
            <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
          </c:forEach>
        </div>
      </section>
    </c:if>

    <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

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
            return Math.round(value).toLocaleString('vi-VN') + ' ₫';
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
                originalPriceEl.style.display = '';
                saveBadgeEl.textContent = 'Giảm ' + formatPrice(v.price - v.discountPrice);
                saveBadgeEl.style.display = 'inline-flex';
            } else {
                currentPriceEl.textContent = formatPrice(v.price);
                originalPriceEl.style.display = 'none';
                saveBadgeEl.style.display = 'none';
            }

            var stockBadge = document.getElementById('detail-stock-badge');
            var addBtn = document.getElementById('add-to-cart-btn');
            var qtyInput = document.getElementById('detail-quantity-input');

            if (v.stock <= 0 || !v.active) {
                if (stockBadge) { stockBadge.textContent = 'Hết hàng'; stockBadge.className = 'badge off'; }
                if (addBtn) { addBtn.disabled = true; }
                qtyInput.max = 1;
            } else if (v.stock < LOW_STOCK_THRESHOLD) {
                if (stockBadge) { stockBadge.textContent = 'Sắp hết hàng'; stockBadge.className = 'badge warn'; }
                if (addBtn) { addBtn.disabled = false; }
                qtyInput.max = v.stock;
            } else {
                if (stockBadge) { stockBadge.textContent = 'Còn ' + v.stock + ' máy'; stockBadge.className = 'badge ok'; }
                if (addBtn) { addBtn.disabled = false; }
                qtyInput.max = v.stock;
            }
            if (Number(qtyInput.value) > Number(qtyInput.max)) { qtyInput.value = qtyInput.max; }
        }

        function selectColor(color, btn) {
            selectedColor = color;
            var label = document.getElementById('detail-color-selected');
            if (label) { label.textContent = color; }
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
            var label = document.getElementById('detail-storage-selected');
            if (label) { label.textContent = storage + 'GB'; }
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
            if (match) { renderVariant(match); }
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
