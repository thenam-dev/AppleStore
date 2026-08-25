<%--
  product-detail.jsp — chi tiết sản phẩm.
  Servlet (ProductDetailServlet, /product?id=) forward tới đây với:
    product         : Product (null nếu không tìm thấy / đã ngừng bán) —
                       {productId,name,description,brand,modelCode,releaseYear,productCondition,
                        importType,originCountry,warrantyMonths,warrantyProvider,categoryId,
                        categoryName,rating,soldQuantity,primaryImageUrl}
    variants        : List<ProductVariant> mọi variant ACTIVE của sản phẩm
                       {variantId,variantLabel,sku,colorName,storageCapacityGb,ramGb,
                        connectivity,price,discountPrice,discountStart,discountEnd,stockQuantity,active}
    variantAttributeDefinitions : các chiều selector do nhóm sản phẩm cấu hình
    defaultVariant  : ProductVariant được chọn sẵn khi vào trang (null nếu không có variant nào)
    relatedProducts : List<Product> gợi ý cùng danh mục
    lowStockThreshold : int
    productSpecifications : List<ProductSpecification> thông số dynamic theo nhóm/tên/giá trị
    errorMsg        : String (khi product null)
  Giá/khuyến mãi/tồn kho thuộc về ProductVariant chứ không thuộc Product, nên phần giá +
  nút "Thêm vào giỏ" đổi theo variant đang chọn — xử lý bằng JS ở cuối trang dựa trên
  mảng variant JSON, KHÔNG có business logic nào khác ngoài việc match đúng variant.
  Nút "Thêm vào giỏ hàng" submit qua fetch() (kèm header X-Requested-With) thay vì
  submit thường - CartServlet nhận diện header này thì trả JSON thay vì PRG, nhờ vậy
  đứng yên tại trang, chỉ hiện toast (góc trên bên phải) + cập nhật badge giỏ hàng
  trên header, không điều hướng sang /cart (xem CartServlet.doPost).
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
        <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=10">
    </head>
    <body>

        <c:choose>
            <%-- ================= KHÔNG TÌM THẤY SẢN PHẨM ================= --%>
            <c:when test="${empty product}">
                <jsp:include page="/WEB-INF/views/common/header.jsp"/>
                <div style="padding:60px 26px;max-width:1280px;margin:0 auto">
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

                <nav class="crumb" style="max-width:1280px;margin:0 auto">
                    <a href="${ctx}/home">Trang chủ</a><span>/</span>
                    <a href="${ctx}/products?categoryId=${product.categoryId}"><c:out value="${product.categoryName}"/></a><span>/</span>
                    <span style="color:var(--ink)"><c:out value="${product.name}"/></span>
                </nav>

                <div style="padding:0 26px;max-width:1280px;margin:0 auto">
                    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
                </div>

                <div style="padding:14px 26px 30px;display:grid;grid-template-columns:1fr 1fr;gap:34px;max-width:1280px;margin:0 auto">

                    <div>
                        <div class="gallery-card">
                            <div class="gallery-frame">
                                <div class="shot gallery-stage" style="aspect-ratio:4/3">
                                    <c:choose>
                                        <c:when test="${not empty productImages}">
                                            <c:set var="firstProductImage" value="${productImages[0]}" />
                                            <c:choose>
                                                <c:when test="${fn:startsWith(firstProductImage.filePath, '/')}">
                                                    <img data-gallery-main src="${ctx}${firstProductImage.filePath}" alt="<c:out value='${product.name}'/>" />
                                                </c:when>
                                                <c:otherwise>
                                                    <img data-gallery-main src="${ctx}/${firstProductImage.filePath}" alt="<c:out value='${product.name}'/>" />
                                                </c:otherwise>
                                            </c:choose>
                                        </c:when>
                                        <c:when test="${not empty product.primaryImageUrl}">
                                            <img data-gallery-main src="${ctx}/${product.primaryImageUrl}" alt="<c:out value='${product.name}'/>" />
                                        </c:when>
                                        <c:otherwise><svg style="color:var(--titan);width:34%"><use href="#${pIcon}"/></svg></c:otherwise>
                                    </c:choose>
                                </div>
                                <c:if test="${fn:length(productImages) > 1}">
                                    <button type="button" class="gallery-nav prev" data-gallery-prev aria-label="Ảnh trước">
                                        <svg width="22" height="22"><use href="#i-chevron-left"/></svg>
                                    </button>
                                    <button type="button" class="gallery-nav next" data-gallery-next aria-label="Ảnh sau">
                                        <svg width="22" height="22"><use href="#i-chevron-right"/></svg>
                                    </button>
                                </c:if>
                            </div>

                            <c:if test="${not empty productImages}">
                                <div class="gallery-thumb-row">
                                    
                                    <div class="gallery-thumbs" data-gallery-thumbs aria-label="Ảnh sản phẩm">
                                        <c:forEach var="image" items="${productImages}" varStatus="status">
                                            <c:choose>
                                                <c:when test="${fn:startsWith(image.filePath, '/')}">
                                                    <c:set var="imageUrl" value="${ctx}${image.filePath}" />
                                                </c:when>
                                                <c:otherwise>
                                                    <c:set var="imageUrl" value="${ctx}/${image.filePath}" />
                                                </c:otherwise>
                                            </c:choose>
                                            <button type="button" data-gallery-thumb data-image-src="${imageUrl}"
                                                    data-image-alt="<c:out value='${product.name}'/>"
                                                    class="gallery-thumb ${status.first ? 'active' : ''}">
                                                <img src="${imageUrl}" alt="" style="display:block;width:100%;height:100%;object-fit:contain" />
                                            </button>
                                        </c:forEach>
                                    </div>
                 
                                </div>
                            </c:if>
                        </div>
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

                            <div id="variant-selector-groups" style="margin-bottom:22px"></div>

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
                                        <%-- "Mua ngay" = thêm vào giỏ RỒI nhảy thẳng sang bước điền địa chỉ
                                             (/checkout), CHỈ đúng 1 sản phẩm/variant/số lượng đang chọn ở
                                             trang này - không phải toàn bộ giỏ hàng hiện có (nếu khách đã có
                                             sẵn sản phẩm khác trong giỏ). Không dùng <a href="${ctx}/cart">
                                             tĩnh như cũ nữa vì như vậy chỉ đưa khách tới giỏ hàng, không tự
                                             thêm sản phẩm này vào giỏ. Xử lý bằng JS (buyNow(), xem script
                                             cuối file JSP này, cùng chỗ với submitAddToCart()). --%>
                                        <button type="button" id="buy-now-btn" class="btn ghost">Mua ngay</button>
                                    </c:when>
                                    <c:otherwise>
                                        <button type="button" class="btn quiet" style="flex:1" disabled>Hết hàng</button>
                                        <button type="button" class="btn ghost" disabled>Mua ngay</button>
                                    </c:otherwise>
                                </c:choose>
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
                                <c:if test="${not empty productSpecifications}">
                                    <c:set var="currentSpecGroup" value="" />
                                    <c:forEach var="specification" items="${productSpecifications}">
                                        <c:if test="${currentSpecGroup ne specification.specGroup}">
                                            <c:if test="${not empty currentSpecGroup}">
                                                </dl>
                                            </c:if>
                                            <h4 style="margin:18px 0 8px;font-size:12px;text-transform:uppercase;color:var(--ash);letter-spacing:.08em">
                                                <c:out value="${specification.specGroup}" />
                                            </h4>
                                            <dl class="kv">
                                            <c:set var="currentSpecGroup" value="${specification.specGroup}" />
                                        </c:if>
                                        <dt><c:out value="${specification.specName}" /></dt>
                                        <dd><c:out value="${specification.specValue}" /></dd>
                                    </c:forEach>
                                    </dl>
                                </c:if>
                                <c:if test="${not empty variants}">
                                    <table class="table" style="margin-top:14px">
                                        <thead><tr><th>Phiên bản</th><th>Thông số</th><th>Giá</th><th>Kho</th></tr></thead>
                                        <tbody>
                                            <c:forEach var="v" items="${variants}">
                                                <tr>
                                                    <td><b><c:out value="${not empty v.variantLabel ? v.variantLabel : v.sku}"/></b></td>
                                                    <td style="color:var(--ash)">
                                                        <c:if test="${not empty v.colorName}"><c:out value="${v.colorName}"/> </c:if>
                                                        <c:if test="${v.caseSizeMm != null}">/ ${v.caseSizeMm}mm </c:if>
                                                        <c:if test="${v.storageCapacityGb != null}">${v.storageCapacityGb}GB </c:if>
                                                        <c:if test="${v.ramGb != null}">/ ${v.ramGb}GB RAM </c:if>
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

                <!-- ================= KHU VỰC ĐÁNH GIÁ (FEEDBACK) ================= -->
                <div style="padding: 0 26px 30px;max-width:1280px;margin:0 auto">
                    <div class="panel">
                        <div class="panel-head" style="display: flex; align-items: center; justify-content: space-between;">
                            <h3 style="margin: 0;">Khách hàng đánh giá</h3>
                            <c:if test="${not empty reviews}">
                                <span class="badge info">Có ${fn:length(reviews)} đánh giá</span>
                            </c:if>
                        </div>

                        <div class="panel-pad">
                            <c:choose>
                                <c:when test="${empty reviews}">
                                    <div style="text-align: center; padding: 30px 10px; color: var(--ash);">
                                        <div style="font-size: 32px; margin-bottom: 10px;">⭐</div>
                                        <p style="margin: 0;">Chưa có đánh giá nào cho sản phẩm này.</p>
                                    </div>
                                </c:when>
                                <c:otherwise>
                                    <!-- Tính điểm trung bình (Tùy chọn hiển thị) -->
                                    <c:set var="totalStars" value="0" />
                                    <c:forEach var="rv" items="${reviews}">
                                        <c:set var="totalStars" value="${totalStars + rv.rating}" />
                                    </c:forEach>
                                    <div style="display: flex; align-items: center; gap: 16px; margin-bottom: 24px; padding-bottom: 20px; border-bottom: 1px solid var(--line);">
                                        <div style="font-family: var(--display); font-size: 36px; font-weight: 700; color: #f59e0b; line-height: 1;">
                                            <fmt:formatNumber value="${totalStars / fn:length(reviews)}" pattern="0.0"/>
                                        </div>
                                        <div>
                                            <div style="color: #f59e0b; font-size: 18px; margin-bottom: 4px;">
                                                ★★★★★
                                            </div>
                                            <div style="font-size: 13px; color: var(--ash);">Dựa trên ${fn:length(reviews)} đánh giá</div>
                                        </div>
                                    </div>

                                    <!-- Danh sách từng feedback -->
                                    <div style="display: flex; flex-direction: column; gap: 20px;">
                                        <c:forEach var="review" items="${reviews}">
                                            <div style="display: flex; gap: 16px;">
                                                <!-- Avatar chữ cái đầu -->
                                                <div style="width: 40px; height: 40px; border-radius: 50%; background: var(--titan); color: #fff; display: flex; align-items: center; justify-content: center; font-weight: bold; flex-shrink: 0;">
                                                    ${fn:substring(review.customerName, 0, 1)}
                                                </div>

                                                <div style="flex: 1;">
                                                    <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                                                        <div>
                                                            <b style="font-size: 14px; color: var(--ink);"><c:out value="${review.customerName}"/></b>
                                                            <div style="color: #f59e0b; font-size: 12px; margin: 4px 0;">
                                                                <c:forEach begin="1" end="${review.rating}">★</c:forEach><c:forEach begin="1" end="${5 - review.rating}">☆</c:forEach>
                                                                </div>
                                                            </div>
                                                            <span style="font-size: 12px; color: var(--ash);">
                                                            <c:if test="${not empty review.createdAt}">
                                                                <fmt:formatDate value="${review.createdAt}" pattern="dd/MM/yyyy"/>
                                                            </c:if>
                                                        </span>
                                                    </div>

                                                    <!-- Phân loại hàng khách đã mua -->
                                                    <div style="font-size: 12px; color: var(--ash); margin-bottom: 8px;">
                                                        Phân loại: <c:out value="${review.variantLabel}"/>
                                                    </div>

                                                    <!-- Nội dung đánh giá -->
                                                    <p style="margin: 0; font-size: 14px; color: var(--graphite); line-height: 1.5;">
                                                        <c:out value="${review.reviewText}"/>
                                                    </p>
                                                </div>
                                            </div>
                                            <hr style="border: 0; border-top: 1px dashed #eee; margin: 0;">
                                        </c:forEach>
                                    </div>
                                </c:otherwise>
                            </c:choose>
                        </div>
                    </div>
                </div>
                
                <c:if test="${not empty relatedProducts}">
                    <section class="sec" style="border-top:1px solid var(--line)">
                        <div class="sec-inner">
                            <div class="sec-head"><h3>Sản phẩm liên quan</h3><a href="${ctx}/products?categoryId=${product.categoryId}">Xem cả danh mục</a></div>
                            <div class="p-grid">
                                <c:forEach var="p" items="${relatedProducts}">
                                    <c:set var="card" value="${p}" scope="request"/>
                                    <jsp:include page="/WEB-INF/views/common/product-card.jsp"/>
                                </c:forEach>
                            </div>
                        </div>
                    </section>
                </c:if>

                <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

                <script src="${ctx}/assets/js/main.js?v=9"></script>
                <c:if test="${not empty variants}">
                    <script>
                        (function () {
                            var productVariants = <c:out value="${variantJson}" escapeXml="false"/>;
                            var attributeDefinitions = <c:out value="${variantAttributeJson}" escapeXml="false"/>;
                            var lowStockThreshold = ${lowStockThreshold};
                            var defaultVariantId = ${defaultVariant != null ? defaultVariant.variantId : 'null'};
                            var selectedValues = {};
                            var selectorRoot = document.getElementById('variant-selector-groups');

                            function valueOf(variant, key) {
                                var value = variant[key];
                                return value === null || value === undefined ? '' : String(value);
                            }

                            function displayValue(key, value) {
                                if (key === 'storage' || key === 'ram') { return value + ' GB'; }
                                if (key === 'caseSize') { return value + ' mm'; }
                                if (key === 'connectivity' && value === 'WIFI_CELLULAR') { return 'WiFi + di động'; }
                                if (key === 'connectivity' && value === 'WIFI') { return 'WiFi'; }
                                return value;
                            }

                            function uniqueValues(key) {
                                var seen = {};
                                var result = [];
                                productVariants.forEach(function (variant) {
                                    var value = valueOf(variant, key);
                                    if (value && !seen[value]) {
                                        seen[value] = true;
                                        result.push(value);
                                    }
                                });
                                return result;
                            }

                            function renderSelectors() {
                                selectorRoot.innerHTML = '';
                                attributeDefinitions.forEach(function (definition) {
                                    var values = uniqueValues(definition.key);
                                    if (!values.length) { return; }
                                    var fixed = values.length === 1;
                                    var group = document.createElement('div');
                                    group.style.marginBottom = '18px';
                                    var head = document.createElement('div');
                                    head.className = 'selector-head';
                                    head.style.cssText = 'display:flex;justify-content:space-between;margin-bottom:9px';
                                    head.innerHTML = '<span class="t-eyebrow" style="margin:0"></span>'
                                        + '<small style="font-size:12px;color:var(--ash)">Đã chọn: <span></span></small>';
                                    head.querySelector('span').textContent = definition.label;
                                    group.appendChild(head);
                                    var options = document.createElement('div');
                                    options.style.cssText = 'display:flex;gap:9px;flex-wrap:wrap';
                                    values.forEach(function (value) {
                                        var button = document.createElement('button');
                                        button.type = 'button';
                                        button.className = fixed ? 'option-chip fixed' : 'option-chip';
                                        button.disabled = fixed;
                                        button.dataset.fixed = fixed ? 'true' : 'false';
                                        button.dataset.attributeKey = definition.key;
                                        button.dataset.attributeValue = value;
                                        button.textContent = displayValue(definition.key, value);
                                        options.appendChild(button);
                                    });
                                    group.appendChild(options);
                                    selectorRoot.appendChild(group);
                                });
                            }

                            function updateSelectors() {
                                selectorRoot.querySelectorAll('.option-chip').forEach(function (button) {
                                    var key = button.dataset.attributeKey;
                                    var value = button.dataset.attributeValue;
                                    var active = selectedValues[key] === value;
                                    // Cho phép đổi từng chiều để hiển thị rõ tổ hợp không tồn tại.
                                    // Khi không có variant khớp, applySelection sẽ khóa thao tác mua.
                                    button.disabled = button.dataset.fixed === 'true';
                                    button.classList.toggle('active', active);
                                    button.setAttribute('aria-pressed', active ? 'true' : 'false');
                                });
                                selectorRoot.querySelectorAll('.selector-head').forEach(function (head, index) {
                                    var definition = attributeDefinitions.filter(function (item) {
                                        return uniqueValues(item.key).length > 0;
                                    })[index];
                                    var selected = selectedValues[definition.key] || 'Chưa chọn';
                                    head.querySelector('small span').textContent = selected === 'Chưa chọn'
                                        ? selected : displayValue(definition.key, selected);
                                });
                            }

                            function findExactVariant() {
                                return productVariants.find(function (variant) {
                                    return attributeDefinitions.every(function (definition) {
                                        return valueOf(variant, definition.key) === (selectedValues[definition.key] || '');
                                    });
                                }) || null;
                            }

                            function isDiscountActive(variant) {
                                if (variant.discountPrice == null) { return false; }
                                var now = new Date();
                                var start = variant.discountStart ? new Date(variant.discountStart) : null;
                                var end = variant.discountEnd ? new Date(variant.discountEnd) : null;
                                return (!start || now >= start) && (!end || now <= end);
                            }

                            function formatPrice(value) {
                                return Math.round(value).toLocaleString('vi-VN') + ' ₫';
                            }

                            function renderVariant(variant) {
                                document.getElementById('selected-variant-id').value = variant.id;
                                var currentPrice = document.getElementById('detail-current-price');
                                var originalPrice = document.getElementById('detail-original-price');
                                var saveBadge = document.getElementById('detail-save-badge');
                                if (isDiscountActive(variant)) {
                                    currentPrice.textContent = formatPrice(variant.discountPrice);
                                    originalPrice.textContent = formatPrice(variant.price);
                                    originalPrice.style.display = '';
                                    saveBadge.textContent = 'Giảm ' + formatPrice(variant.price - variant.discountPrice);
                                    saveBadge.style.display = 'inline-flex';
                                } else {
                                    currentPrice.textContent = formatPrice(variant.price);
                                    originalPrice.style.display = 'none';
                                    saveBadge.style.display = 'none';
                                }
                                var stockBadge = document.getElementById('detail-stock-badge');
                                var addButton = document.getElementById('add-to-cart-btn');
                                var buyButton = document.getElementById('buy-now-btn');
                                var quantity = document.getElementById('detail-quantity-input');
                                var unavailable = variant.stock <= 0 || !variant.active;
                                if (stockBadge) {
                                    stockBadge.textContent = unavailable ? 'Hết hàng'
                                        : (variant.stock < lowStockThreshold ? 'Sắp hết hàng' : 'Còn ' + variant.stock + ' máy');
                                    stockBadge.className = unavailable ? 'badge off'
                                        : (variant.stock < lowStockThreshold ? 'badge warn' : 'badge ok');
                                }
                                if (addButton) { addButton.disabled = unavailable; }
                                // "Mua ngay" đi chung số phận với "Thêm vào giỏ hàng" - đổi sang
                                // variant hết hàng thì khoá luôn cả 2, không riêng gì nút kia.
                                if (buyButton) { buyButton.disabled = unavailable; }
                                quantity.max = unavailable ? 1 : variant.stock;
                                if (Number(quantity.value) > Number(quantity.max)) { quantity.value = quantity.max; }
                            }

                            function clearVariant() {
                                document.getElementById('selected-variant-id').value = '';
                                document.getElementById('detail-current-price').textContent = 'Không có phiên bản';
                                document.getElementById('detail-original-price').style.display = 'none';
                                document.getElementById('detail-save-badge').style.display = 'none';
                                var stockBadge = document.getElementById('detail-stock-badge');
                                if (stockBadge) { stockBadge.textContent = 'Hết hàng'; stockBadge.className = 'badge off'; }
                                var addButton = document.getElementById('add-to-cart-btn');
                                if (addButton) { addButton.disabled = true; }
                                var buyButton = document.getElementById('buy-now-btn');
                                if (buyButton) { buyButton.disabled = true; }
                                document.getElementById('detail-quantity-input').max = 1;
                            }

                            function applySelection() {
                                var match = findExactVariant();
                                if (match) { renderVariant(match); } else { clearVariant(); }
                                updateSelectors();
                            }

                            // Đổi màu thì nảy ảnh chính sang ảnh khớp màu đó (xem
                            // productGallerySelectColor trong main.js - so khớp theo tên
                            // file ảnh, không cần bảng ánh xạ màu-ảnh riêng trong CSDL).
                            function syncGalleryToSelectedColor() {
                                if (selectedValues.color && typeof window.productGallerySelectColor === 'function') {
                                    window.productGallerySelectColor(selectedValues.color);
                                }
                            }

                            selectorRoot.addEventListener('click', function (event) {
                                var button = event.target.closest('.option-chip');
                                if (!button || button.disabled) { return; }
                                selectedValues[button.dataset.attributeKey] = button.dataset.attributeValue;
                                applySelection();
                                if (button.dataset.attributeKey === 'color') { syncGalleryToSelectedColor(); }
                            });

                            var initial = productVariants.find(function (variant) { return variant.id === defaultVariantId; })
                                || productVariants[0];
                            if (initial) {
                                attributeDefinitions.forEach(function (definition) {
                                    selectedValues[definition.key] = valueOf(initial, definition.key);
                                });
                            }
                            renderSelectors();
                            if (initial) { renderVariant(initial); }
                            updateSelectors();
                            // window.productGallerySelectColor được main.js gắn trong
                            // handler DOMContentLoaded của chính nó - script này chạy
                            // trước lúc đó nên đợi cùng sự kiện để chắc chắn đã sẵn sàng.
                            if (document.readyState === 'loading') {
                                document.addEventListener('DOMContentLoaded', syncGalleryToSelectedColor);
                            } else {
                                syncGalleryToSelectedColor();
                            }
                        })();
                    </script>
                </c:if>

                <script>
                    (function () {
                        // "Thêm vào giỏ hàng" gửi qua fetch() (kèm header X-Requested-With) để
                        // CartServlet trả JSON {success,message,cartItemCount} thay vì PRG -
                        // đứng yên tại trang, chỉ hiện toast + cập nhật badge giỏ hàng trên
                        // header, KHÔNG điều hướng sang /cart (xem CartServlet.doPost).
                        //
                        // Nếu chưa đăng nhập: AuthFilter trả JSON 401 {requiresLogin:true}
                        // (không sendRedirect - tránh trình duyệt tự đổi POST->GET và làm rơi
                        // mất variantId/quantity khi theo redirect). Ở đây tự dựng URL đăng
                        // nhập, đính kèm variantId/quantity vào chính URL trang sản phẩm qua
                        // query "pendingAddVariantId"/"pendingAddQty" rồi điều hướng sang
                        // /login?redirectTo=... Đăng nhập xong, LoginServlet redirect đúng về
                        // trang này với 2 param đó vẫn còn -> khối script cuối file phát hiện
                        // và tự gọi lại API thêm vào giỏ (xem addPendingCartItemAfterLogin()).
                        var ctxPath = '${ctx}';
                        var form = document.getElementById('add-to-cart-form');
                        var submitBtn = form ? document.getElementById('add-to-cart-btn') : null;
                        var pending = false;

                        // Nảy vào từ phải, thu về phải lúc biến mất, có thanh thời gian
                        // (.toast-timer) co dần theo DURATION (xem style.css .toast/.toast-timer).
                        function showToast(message, variant) {
                            var stack = document.getElementById('toast-stack');
                            if (!stack) {
                                stack = document.createElement('div');
                                stack.id = 'toast-stack';
                                stack.className = 'toast-stack';
                                document.body.appendChild(stack);
                            }
                            var DURATION = 2600;
                            var ENTER_MS = 320; // khớp thời gian transition transform lúc .toast.show (style.css)
                            var toast = document.createElement('div');
                            toast.className = 'toast ' + (variant === 'err' ? 'err' : 'ok');
                            toast.innerHTML = '<svg width="16" height="16"><use href="#' + (variant === 'err' ? 'i-alert' : 'i-check') + '"/></svg>' +
                                '<span></span><i class="toast-timer"></i>';
                            toast.querySelector('span').textContent = message;
                            stack.appendChild(toast);
                            var timer = toast.querySelector('.toast-timer');
                            timer.style.transitionDuration = Math.max(DURATION - ENTER_MS, 0) + 'ms';
                            requestAnimationFrame(function () { toast.classList.add('show'); });
                            // Chỉ bắt đầu co thanh thời gian SAU KHI toast nảy vào xong hẳn
                            // (ENTER_MS) - kích cùng lúc với lúc chèn vào DOM (chung 1 rAF
                            // với .show) khiến trình duyệt gộp 2 thay đổi transform lại,
                            // thanh co gần như tức thì (nhìn như biến mất luôn, không co dần).
                            setTimeout(function () { timer.style.transform = 'scaleX(0)'; }, ENTER_MS);
                            setTimeout(function () {
                                toast.classList.remove('show');
                                toast.classList.add('hide');
                                setTimeout(function () { toast.remove(); }, 220);
                            }, DURATION);
                        }

                        function updateHeaderBadge(count) {
                            var link = document.querySelector('.ic[href$="/cart"]');
                            if (!link) { return; }
                            var badge = link.querySelector('.dot-n');
                            if (typeof count !== 'number' || count <= 0) {
                                if (badge) { badge.remove(); }
                                return;
                            }
                            if (!badge) {
                                badge = document.createElement('span');
                                badge.className = 'dot-n';
                                // Ghim vào .sf-cart-icon (bọc riêng cái icon) nếu có, để badge
                                // bám đúng góc icon - không phải link.appendChild() thẳng vào
                                // .ic (giờ là cả viên thuốc "Giỏ hàng" + icon, xem header.jsp).
                                (link.querySelector('.sf-cart-icon') || link).appendChild(badge);
                            }
                            badge.textContent = count;
                        }

                        // Bỏ context path khỏi window.location.pathname để ra path "thuần" mà
                        // LoginServlet mong đợi ở redirectTo (nó tự nối lại contextPath).
                        function pathWithoutCtx() {
                            var path = window.location.pathname;
                            if (ctxPath && path.indexOf(ctxPath) === 0) {
                                path = path.substring(ctxPath.length);
                            }
                            return path;
                        }

                        // Dựng URL /login?redirectTo=... trỏ về ĐÚNG trang sản phẩm đang xem,
                        // kèm variantId/quantity định thêm để sau khi đăng nhập xong tự làm lại
                        // đúng thao tác khách vừa định làm. mode phân biệt 2 luồng khác nhau:
                        //   'add'    - bấm "Thêm vào giỏ hàng" -> chỉ thêm + hiện toast (submitAddToCart)
                        //   'buyNow' - bấm "Mua ngay" -> thêm XONG rồi nhảy thẳng sang /checkout (buyNow)
                        // dùng 2 cặp tên param riêng (pendingAdd.../pendingBuy...) để không lẫn
                        // lộn 2 luồng nếu khách đổi ý giữa chừng lúc đang ở trang login.
                        function buildLoginRedirectUrl(variantId, quantity, mode) {
                            var params = new URLSearchParams(window.location.search);
                            if (mode === 'buyNow') {
                                params.set('pendingBuyVariantId', variantId);
                                params.set('pendingBuyQty', quantity);
                            } else {
                                params.set('pendingAddVariantId', variantId);
                                params.set('pendingAddQty', quantity);
                            }
                            var redirectTarget = pathWithoutCtx() + '?' + params.toString();
                            return ctxPath + '/login?redirectTo=' + encodeURIComponent(redirectTarget);
                        }

                        // Gọi API thêm vào giỏ - KHÔNG tự quyết định làm gì tiếp theo (không tự
                        // showToast/redirect ở đây) để submitAddToCart() và buyNow() bên dưới mỗi
                        // hàm tự xử lý phần "sau khi thêm thành công" khác nhau. Trả về Promise
                        // resolve ra data JSON, hoặc null nếu đã tự điều hướng sang trang login rồi
                        // (không cần làm gì thêm ở nơi gọi).
                        function postAddToCart(variantId, quantity, mode) {
                            return fetch(ctxPath + '/cart', {
                                method: 'POST',
                                body: new URLSearchParams({ action: 'add', variantId: variantId, quantity: quantity }),
                                headers: { 'X-Requested-With': 'XMLHttpRequest' },
                                credentials: 'same-origin'
                            }).then(function (res) {
                                var contentType = res.headers.get('content-type') || '';
                                if (contentType.indexOf('application/json') === -1) {
                                    // Phòng hờ trường hợp bị redirect ngoài dự kiến (vd filter khác).
                                    if (res.redirected && res.url.indexOf('/login') !== -1) {
                                        window.location.href = buildLoginRedirectUrl(variantId, quantity, mode);
                                        return null;
                                    }
                                    throw new Error('unexpected response ' + res.status);
                                }
                                return res.json().then(function (data) {
                                    return { status: res.status, data: data };
                                });
                            }).then(function (wrapped) {
                                if (!wrapped) { return null; }
                                var data = wrapped.data;
                                if (wrapped.status === 401 || data.requiresLogin) {
                                    window.location.href = buildLoginRedirectUrl(variantId, quantity, mode);
                                    return null;
                                }
                                return data;
                            });
                        }

                        // Dùng chung cho cả submit thủ công lẫn tự thêm lại sau khi đăng nhập.
                        function submitAddToCart(variantId, quantity) {
                            return postAddToCart(variantId, quantity, 'add').then(function (data) {
                                if (!data) { return; }
                                if (!data.success) {
                                    showToast(data.message || 'Không thể thêm vào giỏ hàng', 'err');
                                    return;
                                }
                                showToast(data.message || 'Đã thêm vào giỏ hàng', 'ok');
                                updateHeaderBadge(data.cartItemCount);
                            }).catch(function () {
                                showToast('Không thể kết nối máy chủ, vui lòng thử lại', 'err');
                            });
                        }

                        // "Mua ngay" - thêm vào giỏ XONG RỒI nhảy thẳng sang /checkout, CHỈ đúng
                        // đúng 1 sản phẩm/variant/số lượng đang chọn ở trang này (không phải toàn
                        // bộ giỏ hàng khách có sẵn) - gửi fromCart=1&cartItemId=<vừa thêm>, giống
                        // hệt cách cart.jsp gửi khi khách tick chọn sản phẩm rồi bấm "Tiến hành
                        // thanh toán" (xem CheckoutServlet.resolveSelectedIds()).
                        function buyNow(variantId, quantity) {
                            return postAddToCart(variantId, quantity, 'buyNow').then(function (data) {
                                if (!data) { return; }
                                if (!data.success) {
                                    showToast(data.message || 'Không thể thêm vào giỏ hàng', 'err');
                                    return;
                                }
                                if (!data.cartItemId) {
                                    // Phòng hờ - không có cartItemId (không nên xảy ra) thì về giỏ
                                    // hàng để khách tự bấm thanh toán, còn hơn văng lỗi giữa chừng.
                                    window.location.href = ctxPath + '/cart';
                                    return;
                                }
                                window.location.href = ctxPath + '/checkout?fromCart=1&cartItemId=' + encodeURIComponent(data.cartItemId);
                            }).catch(function () {
                                showToast('Không thể kết nối máy chủ, vui lòng thử lại', 'err');
                            });
                        }

                        if (form) {
                            form.addEventListener('submit', function (e) {
                                e.preventDefault();
                                if (pending) { return; }
                                pending = true;
                                if (submitBtn) { submitBtn.disabled = true; }

                                var variantInput = document.getElementById('selected-variant-id');
                                var quantityInput = document.getElementById('detail-quantity-input');
                                var variantId = variantInput ? variantInput.value : '';
                                var quantity = quantityInput ? quantityInput.value : '1';

                                submitAddToCart(variantId, quantity).finally(function () {
                                    pending = false;
                                    if (submitBtn) { submitBtn.disabled = false; }
                                });
                            });
                        }

                        // "Mua ngay" - KHÔNG nằm trong <form> add-to-cart-form (type="button",
                        // không submit form) để không đụng vào luồng "Thêm vào giỏ hàng" ở trên -
                        // 2 nút dùng chung ô số lượng/variant đang chọn nhưng có pending cờ riêng.
                        var buyNowBtn = document.getElementById('buy-now-btn');
                        var buyNowPending = false;
                        if (buyNowBtn) {
                            buyNowBtn.addEventListener('click', function () {
                                if (buyNowPending) { return; }
                                buyNowPending = true;
                                buyNowBtn.disabled = true;

                                var variantInput = document.getElementById('selected-variant-id');
                                var quantityInput = document.getElementById('detail-quantity-input');
                                var variantId = variantInput ? variantInput.value : '';
                                var quantity = quantityInput ? quantityInput.value : '1';

                                buyNow(variantId, quantity).finally(function () {
                                    buyNowPending = false;
                                    buyNowBtn.disabled = false;
                                });
                            });
                        }

                        // Vừa quay lại từ /login sau khi bị yêu cầu đăng nhập lúc bấm "Thêm vào
                        // giỏ hàng" HOẶC "Mua ngay" -> URL còn param pending.../pendingBuy... (xem
                        // buildLoginRedirectUrl), tự làm lại đúng thao tác khách vừa định làm
                        // (KHÔNG cần bấm lại nút). Xoá param khỏi URL (history.replaceState) TRƯỚC
                        // khi gọi API để F5/Back không lặp lại việc thêm vào giỏ.
                        (function resumePendingCartActionAfterLogin() {
                            var params = new URLSearchParams(window.location.search);
                            var pendingAddVariantId = params.get('pendingAddVariantId');
                            var pendingBuyVariantId = params.get('pendingBuyVariantId');
                            if (!pendingAddVariantId && !pendingBuyVariantId) { return; }

                            var pendingQty = params.get(pendingBuyVariantId ? 'pendingBuyQty' : 'pendingAddQty') || '1';

                            params.delete('pendingAddVariantId');
                            params.delete('pendingAddQty');
                            params.delete('pendingBuyVariantId');
                            params.delete('pendingBuyQty');
                            var remaining = params.toString();
                            var cleanUrl = window.location.pathname + (remaining ? '?' + remaining : '') + window.location.hash;
                            window.history.replaceState(null, '', cleanUrl);

                            if (pendingBuyVariantId) {
                                buyNow(pendingBuyVariantId, pendingQty);
                            } else {
                                submitAddToCart(pendingAddVariantId, pendingQty);
                            }
                        })();
                    })();
                </script>

                <%-- Lightbox phóng to ảnh - bấm vào ảnh chính (data-gallery-main) sẽ mở
                     lớp phủ toàn màn hình này, hiện đúng ảnh đang xem to hơn, có nút
                     đóng/chuyển ảnh trước-sau. Nội dung <img> để trống, JS
                     (initProductGallery trong main.js) tự đổ src khi mở. --%>
                <div class="lightbox" data-lightbox aria-hidden="true">
                    <button type="button" class="lightbox-close" data-lightbox-close aria-label="Đóng ảnh phóng to">
                        <svg width="20" height="20"><use href="#i-x"/></svg>
                    </button>
                    <button type="button" class="lightbox-nav prev" data-lightbox-prev aria-label="Ảnh trước">
                        <svg width="24" height="24"><use href="#i-chevron-left"/></svg>
                    </button>
                    <img class="lightbox-image" data-lightbox-image src="" alt="">
                    <button type="button" class="lightbox-nav next" data-lightbox-next aria-label="Ảnh sau">
                        <svg width="24" height="24"><use href="#i-chevron-right"/></svg>
                    </button>
                </div>
            </c:otherwise>
        </c:choose>
    </body>
</html>
