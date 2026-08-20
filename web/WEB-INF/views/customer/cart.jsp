<%--
  cart.jsp — giỏ hàng.
  Servlet (CartServlet) set:
    cartItems       : List<CartItem> {cartItemId,productName,variantLabel,unitPrice,
                       stockQuantity,addonLabel,addonPrice,imageUrl,quantity,lineTotal,overStock}
    cartTotal       : BigDecimal tổng tạm tính
    cartItemCount   : int tổng số lượng sản phẩm
    hasOverStockItem: boolean có dòng nào vượt tồn kho không
    successMsg / errorMsg : flash message (rule 10)
  Cộng/trừ số lượng và xoá sản phẩm ở trang này gọi action=update|remove qua
  fetch() (kèm header X-Requested-With) - CartServlet nhận diện header này thì
  trả JSON {success,message,cartItemCount} thay vì PRG, để cập nhật tại chỗ
  (không reload trang, không cần nút "Cập nhật", không dùng confirm() khi xoá).
  Form submit thường (không có header đó) vẫn theo PRG như cũ.
  Mọi lần cộng/trừ/xoá thành công đều hiện toast (góc trên bên phải, xem
  .toast-stack trong style.css). Bấm "-" khi số lượng đang là 1 sẽ xoá luôn
  dòng đó khỏi giỏ thay vì đứng yên ở mức tối thiểu 1 (removeRow()).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" language="java" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn"  uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Giỏ hàng · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
</head>
<body>

<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<c:set var="activeStep" value="1" scope="request"/>
<jsp:include page="/WEB-INF/views/common/checkout-steps.jsp"/>

<div style="padding:22px 26px">
  <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

  <c:if test="${hasOverStockItem}">
    <div class="flash err" id="overStockBanner" style="margin-bottom:16px">
      <svg width="18" height="18"><use href="#i-alert"/></svg>
      <div>Một số sản phẩm trong giỏ đã vượt quá số lượng tồn kho hiện tại, vui lòng cập nhật lại trước khi thanh toán.</div>
    </div>
  </c:if>

  <%-- Form "ảo" gom các checkbox tick chọn sản phẩm (mỗi checkbox trỏ tới form
       này qua thuộc tính form="cart-selection-form") để submit GET sang
       /checkout, mang theo đúng những dòng khách muốn thanh toán (rule 4). --%>
  <form id="cart-selection-form" method="get" action="${ctx}/checkout">
    <input type="hidden" name="fromCart" value="1">
  </form>

  <c:choose>
    <%-- ================= GIỎ HÀNG CÓ SẢN PHẨM ================= --%>
    <c:when test="${not empty cartItems}">
      <div class="split">
        <div class="panel">
          <div class="panel-head">
            <label style="display:flex;align-items:center;gap:8px;font-size:12.5px;color:var(--graphite);cursor:pointer">
              <input type="checkbox" id="selectAllItems" class="cart-chk" checked>Chọn tất cả
            </label>
            <h3 class="r" style="margin-left:auto">Sản phẩm trong giỏ</h3>
            <span class="mono" id="cartItemCountLabel" style="font-size:11px;color:var(--ash)">${cartItemCount} món</span>
          </div>
          <div class="panel-pad">
            <c:forEach var="item" items="${cartItems}">
              <div class="line-item" data-cart-item-id="${item.cartItemId}"
                   data-unit-price="${item.unitPrice}"
                   data-addon-price="${not empty item.addonPrice ? item.addonPrice : 0}">
                <input type="checkbox" class="cart-chk cart-select" form="cart-selection-form"
                       name="cartItemId" value="${item.cartItemId}"
                       data-line-total="${item.lineTotal}" data-qty="${item.quantity}" checked>

                <div class="shot thumb-lg">
                  <c:choose>
                    <c:when test="${not empty item.imageUrl}">
                      <img src="${ctx}/${item.imageUrl}" alt="<c:out value='${item.productName}'/>">
                    </c:when>
                    <c:otherwise><svg style="color:#5B6472"><use href="#d-acc"/></svg></c:otherwise>
                  </c:choose>
                </div>

                <div style="flex:1;min-width:0">
                  <b style="font-size:13.5px"><c:out value="${item.productName}"/></b><br>
                  <span style="font-size:12px;color:var(--ash)">
                    <c:out value="${item.variantLabel}"/>
                    <c:if test="${not empty item.addonLabel}"> &middot; Dịch vụ thêm: <c:out value="${item.addonLabel}"/></c:if>
                  </span><br>
                  <span class="mono" style="font-size:12px">
                    <fmt:formatNumber value="${item.unitPrice}" type="number" maxFractionDigits="0"/> ₫
                    <c:if test="${not empty item.addonPrice and item.addonPrice > 0}">
                      (+ <fmt:formatNumber value="${item.addonPrice}" type="number" maxFractionDigits="0"/> ₫ dịch vụ thêm)
                    </c:if>
                  </span>
                  <c:if test="${item.overStock}">
                    <div class="err-msg stock-warn"><svg width="14" height="14"><use href="#i-alert"/></svg>Chỉ còn ${item.stockQuantity} sản phẩm trong kho</div>
                  </c:if>
                  <c:if test="${item.stockQuantity <= 0}">
                    <div class="err-msg stock-warn"><svg width="14" height="14"><use href="#i-alert"/></svg>Sản phẩm đã hết hàng, vui lòng xoá khỏi giỏ</div>
                  </c:if>
                </div>

                <div class="qty cart-qty">
                  <button type="button" class="qty-btn" data-qty-action="decrease" aria-label="Giảm số lượng">−</button>
                  <input type="number" class="qty-input" value="${item.quantity}"
                         min="1" max="${item.stockQuantity}" inputmode="numeric" aria-label="Số lượng">
                  <button type="button" class="qty-btn" data-qty-action="increase" aria-label="Tăng số lượng">+</button>
                </div>

                <div class="line-total-cell" style="width:110px;text-align:right;font-family:var(--display);font-stretch:112%;font-weight:700;font-size:14.5px">
                  <fmt:formatNumber value="${item.lineTotal}" type="number" maxFractionDigits="0"/> ₫
                </div>

                <button type="button" class="icon-btn cart-remove-btn" title="Xoá">
                  <svg width="15" height="15"><use href="#i-trash"/></svg>
                </button>
              </div>
            </c:forEach>
          </div>
        </div>

        <div class="panel" style="position:sticky;top:calc(var(--sf-header-h) + 16px)">
          <div class="panel-head"><h3>Thông tin đơn hàng</h3></div>
          <div class="panel-pad">
            <div class="sum-row"><span>Số lượng sản phẩm</span><span><span id="selectedCount">${cartItemCount}</div>
            <div class="sum-row"><span>Tạm tính</span><span id="selectedSubtotal"><fmt:formatNumber value="${cartTotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
            <div class="sum-row"><span>Phí vận chuyển</span><span style="color:var(--ash)">Miễn phí</span></div>
            <div class="sum-row total"><span>Tổng cộng</span><span id="selectedTotal"><fmt:formatNumber value="${cartTotal}" type="number" maxFractionDigits="0"/> ₫</span></div>
            <div class="help" id="selectNoneWarn" style="display:none;color:var(--danger);margin-top:6px">Vui lòng chọn ít nhất 1 sản phẩm để thanh toán</div>
            <button type="submit" form="cart-selection-form" id="checkoutSubmitBtn" class="btn titan block" style="margin-top:16px">Tiến hành thanh toán</button>
            <a class="btn ghost block" style="margin-top:10px" href="${ctx}/products">Tiếp tục mua sắm</a>
          </div>
        </div>
      </div>

      <script>
        (function () {
          var boxes = Array.prototype.slice.call(document.querySelectorAll('.cart-select'));
          var selectAll = document.getElementById('selectAllItems');
          var subtotalEl = document.getElementById('selectedSubtotal');
          var totalEl = document.getElementById('selectedTotal');
          var countEl = document.getElementById('selectedCount');
          var submitBtn = document.getElementById('checkoutSubmitBtn');
          var warnEl = document.getElementById('selectNoneWarn');
          var cartCountLabel = document.getElementById('cartItemCountLabel');

          function formatVnd(amount) {
            return new Intl.NumberFormat('vi-VN').format(Math.round(amount)) + ' ₫';
          }

          function recalc() {
            var total = 0, checkedQty = 0, checkedRows = 0;
            boxes.forEach(function (box) {
              if (box.checked) {
                total += parseFloat(box.dataset.lineTotal || '0');
                checkedQty += parseInt(box.dataset.qty || '0', 10);
                checkedRows++;
              }
            });
            if (subtotalEl) subtotalEl.textContent = formatVnd(total);
            if (totalEl) totalEl.textContent = formatVnd(total);
            if (countEl) countEl.textContent = checkedQty;
            if (submitBtn) submitBtn.disabled = checkedRows === 0;
            if (warnEl) warnEl.style.display = checkedRows === 0 ? 'block' : 'none';
            if (selectAll) selectAll.checked = boxes.length > 0 && checkedRows === boxes.length;
          }

          boxes.forEach(function (box) {
            box.addEventListener('change', recalc);
          });
          if (selectAll) {
            selectAll.addEventListener('change', function () {
              boxes.forEach(function (box) { box.checked = selectAll.checked; });
              recalc();
            });
          }
          recalc();

          // ---------- Toast dùng chung cho cập nhật số lượng / xoá sản phẩm ----------
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

          // Gửi action=update|remove qua fetch, dùng URLSearchParams (không phải
          // FormData) để request theo application/x-www-form-urlencoded - đúng kiểu
          // mà CartServlet.getParameter() đọc được (CartServlet không có
          // @MultipartConfig nên không đọc được multipart/form-data).
          function postCart(payload) {
            return fetch('${ctx}/cart', {
              method: 'POST',
              body: new URLSearchParams(payload),
              headers: { 'X-Requested-With': 'XMLHttpRequest' },
              credentials: 'same-origin'
            }).then(function (res) {
              var contentType = res.headers.get('content-type') || '';
              if (contentType.indexOf('application/json') === -1) {
                if (res.redirected && res.url.indexOf('/login') !== -1) {
                  window.location.href = '${ctx}/login';
                  return null;
                }
                throw new Error('unexpected response ' + res.status);
              }
              return res.json();
            });
          }

          // ---------- Cộng/trừ/nhập số lượng - cập nhật ngay----------
          // ---------- Xoá sản phẩm - xoá ngay + hiện toast----------
          document.querySelectorAll('.line-item').forEach(function (row) {
            var cartItemId = row.dataset.cartItemId;
            var unitPrice = parseFloat(row.dataset.unitPrice || '0');
            var addonPrice = parseFloat(row.dataset.addonPrice || '0');
            var qtyInput = row.querySelector('.qty-input');
            var lineTotalCell = row.querySelector('.line-total-cell');
            var checkbox = row.querySelector('.cart-select');
            var removeBtn = row.querySelector('.cart-remove-btn');
            if (!qtyInput) { return; }
            var lastGoodQty = qtyInput.value;
            var pending = false;

            function applyQuantity(newQty) {
              var max = parseInt(qtyInput.max, 10);
              var min = parseInt(qtyInput.min || '1', 10);
              if (isNaN(newQty) || newQty < min) { newQty = min; }
              if (!isNaN(max) && newQty > max) { newQty = max; }
              if (pending) { qtyInput.value = lastGoodQty; return; }
              if (String(newQty) === String(lastGoodQty)) {
                qtyInput.value = newQty;
                return;
              }
              pending = true;
              qtyInput.disabled = true;

              postCart({ action: 'update', cartItemId: cartItemId, quantity: newQty })
                .then(function (data) {
                  if (!data) { return; }
                  if (!data.success) {
                    showToast(data.message || 'Không thể cập nhật số lượng', 'err');
                    qtyInput.value = lastGoodQty;
                    return;
                  }
                  lastGoodQty = newQty;
                  qtyInput.value = newQty;
                  var newLineTotal = (unitPrice + addonPrice) * newQty;
                  if (lineTotalCell) { lineTotalCell.textContent = formatVnd(newLineTotal); }
                  if (checkbox) {
                    checkbox.dataset.lineTotal = newLineTotal;
                    checkbox.dataset.qty = newQty;
                    recalc();
                  }
                  if (cartCountLabel && typeof data.cartItemCount === 'number') {
                    cartCountLabel.textContent = data.cartItemCount + ' món';
                  }
                  updateHeaderBadge(data.cartItemCount);
                  showToast(data.message || 'Đã cập nhật số lượng', 'ok');

                  // Server đã chấp nhận số lượng mới -> chắc chắn không còn vượt tồn
                  // kho / hết hàng cho DÒNG NÀY nữa, gỡ cảnh báo cũ (nếu có) để tránh
                  // hiện sai sau khi đã sửa đúng.
                  row.querySelectorAll('.stock-warn').forEach(function (el) { el.remove(); });
                  var overStockBanner = document.getElementById('overStockBanner');
                  if (overStockBanner && !document.querySelector('.stock-warn')) {
                    overStockBanner.remove();
                  }
                })
                .catch(function () {
                  showToast('Không thể kết nối máy chủ, vui lòng thử lại', 'err');
                  qtyInput.value = lastGoodQty;
                })
                .finally(function () {
                  pending = false;
                  qtyInput.disabled = false;
                });
            }

            // Xoá dòng này khỏi giỏ - dùng chung cho nút thùng rác lẫn cho việc
            // bấm "-" khi số lượng đang là 1 (rule mới: còn 1 sản phẩm mà bấm
            // trừ thì xoá luôn khỏi giỏ thay vì đứng yên ở mức tối thiểu 1).
            function removeRow() {
              if (pending) { return; }
              pending = true;
              if (removeBtn) { removeBtn.disabled = true; }
              qtyInput.disabled = true;

              postCart({ action: 'remove', cartItemId: cartItemId })
                .then(function (data) {
                  if (!data) { return; }
                  if (!data.success) {
                    showToast(data.message || 'Không thể xoá sản phẩm', 'err');
                    return;
                  }
                  showToast(data.message || 'Đã xoá sản phẩm khỏi giỏ hàng', 'ok');
                  updateHeaderBadge(data.cartItemCount);
                  if (!data.cartItemCount) {
                    // Giỏ hàng trống hẳn - tải lại trang để hiện đúng trạng thái rỗng
                    window.location.reload();
                    return;
                  }
                  row.remove();
                  boxes = boxes.filter(function (box) { return box !== checkbox; });
                  if (cartCountLabel) { cartCountLabel.textContent = data.cartItemCount + ' món'; }
                  recalc();
                })
                .catch(function () {
                  showToast('Không thể kết nối máy chủ, vui lòng thử lại', 'err');
                })
                .finally(function () {
                  pending = false;
                  if (removeBtn) { removeBtn.disabled = false; }
                  qtyInput.disabled = false;
                });
            }

            row.querySelectorAll('.qty-btn').forEach(function (btn) {
              btn.addEventListener('click', function () {
                var isDecrease = btn.getAttribute('data-qty-action') !== 'increase';
                if (isDecrease && parseInt(qtyInput.value, 10) <= 1) {
                  removeRow();
                  return;
                }
                var step = isDecrease ? -1 : 1;
                applyQuantity(parseInt(qtyInput.value, 10) + step);
              });
            });
            qtyInput.addEventListener('change', function () {
              applyQuantity(parseInt(qtyInput.value, 10));
            });

            if (removeBtn) {
              removeBtn.addEventListener('click', function () {
                if (removeBtn.disabled) { return; }
                removeRow();
              });
            }
          });
        })();
      </script>
    </c:when>

    <%-- ================= GIỎ HÀNG TRỐNG ================= --%>
    <c:otherwise>
      <div class="empty">
        <div class="ring"><svg width="28" height="28"><use href="#i-cart"/></svg></div>
        <h3>Giỏ hàng của bạn hiện đang trống</h3>
        <p>Chọn sản phẩm bạn thích và thêm vào giỏ hàng để bắt đầu mua sắm.</p>
        <div style="display:flex;gap:10px;justify-content:center;flex-wrap:wrap">
          <a class="btn titan" href="${ctx}/products">Xem sản phẩm</a>
          <a class="btn ghost" href="${ctx}/home">Về trang chủ</a>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
