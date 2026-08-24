document.addEventListener("DOMContentLoaded", function () {
    initMobileDrawer();
    initOptionGroups();
    initQuantityControls();
    initProductGallery();
    initProductCatalog();
    initCartDemo();
    initLoadingButtons();
    initToastTriggers();
    initCurrentYear();
    initAuthFlashMessages();
});

function initMobileDrawer() {
    var toggleButtons = document.querySelectorAll("[data-mobile-toggle]");
    var mobilePanel = document.querySelector("[data-mobile-panel]");

    if (!toggleButtons.length || !mobilePanel) {
        return;
    }

    toggleButtons.forEach(function (button) {
        button.setAttribute("aria-expanded", "false");
    });

    toggleButtons.forEach(function (button) {
        button.addEventListener("click", function () {
            mobilePanel.classList.toggle("is-open");
            var expanded = mobilePanel.classList.contains("is-open");
            button.setAttribute("aria-expanded", String(expanded));
        });
    });
}

function initOptionGroups() {
    var groups = document.querySelectorAll("[data-option-group]");

    groups.forEach(function (group) {
        var chips = group.querySelectorAll(".option-chip");
        var selectedTargetId = group.getAttribute("data-selected-target");
        var selectedTarget = selectedTargetId ? document.getElementById(selectedTargetId) : null;

        chips.forEach(function (chip) {
            chip.addEventListener("click", function () {
                chips.forEach(function (button) {
                    button.classList.remove("active");
                    button.setAttribute("aria-pressed", "false");
                });

                chip.classList.add("active");
                chip.setAttribute("aria-pressed", "true");

                if (selectedTarget) {
                    selectedTarget.textContent = chip.textContent.trim();
                }
            });
        });
    });
}

function initQuantityControls() {
    var controls = document.querySelectorAll("[data-quantity-control]");

    controls.forEach(function (control) {
        var input = control.querySelector("input[type='number']");
        var decreaseButton = control.querySelector("[data-quantity-action='decrease']");
        var increaseButton = control.querySelector("[data-quantity-action='increase']");

        if (!input || !decreaseButton || !increaseButton) {
            return;
        }

        decreaseButton.addEventListener("click", function () {
            var currentValue = Number(input.value || 0);
            var minimum = Number(input.min || 1);
            input.value = Math.max(currentValue - 1, minimum);
            input.dispatchEvent(new Event("input", {bubbles: true}));
        });

        increaseButton.addEventListener("click", function () {
            var currentValue = Number(input.value || 0);
            var maximum = Number(input.max || 9999);
            input.value = Math.min(currentValue + 1, maximum);
            input.dispatchEvent(new Event("input", {bubbles: true}));
        });
    });
}

// Bỏ dấu tiếng Việt, hạ chữ thường, đổi khoảng trắng/ký tự lạ thành "-".
// Dùng để so khớp tên màu (vd "Xám Không Gian") với tên file ảnh
// (vd "airpods-max-xam-khong-gian.png") - kho ảnh hiện đặt tên file theo
// đúng quy tắc này nên không cần thêm cột ánh xạ màu-ảnh trong CSDL.
function slugifyForImageMatch(text) {
    return (text || "")
        .toString()
        .normalize("NFD")
        .replace(new RegExp("[\\u0300-\\u036f]", "g"), "")
        .replace(/đ/gi, "d")
        .toLowerCase()
        .trim()
        .replace(/[^a-z0-9]+/g, "-")
        .replace(/^-+|-+$/g, "");
}

function initProductGallery() {
    var mainImage = document.querySelector("[data-gallery-main]");
    var thumbs = Array.prototype.slice.call(document.querySelectorAll("[data-gallery-thumb]"));
    var prevButton = document.querySelector("[data-gallery-prev]");
    var nextButton = document.querySelector("[data-gallery-next]");
    var thumbTrack = document.querySelector("[data-gallery-thumbs]");
    var thumbPrevButton = document.querySelector("[data-gallery-thumb-prev]");
    var thumbNextButton = document.querySelector("[data-gallery-thumb-next]");

    if (!mainImage || !thumbs.length) {
        return;
    }

    var currentIndex = Math.max(thumbs.findIndex(function (button) {
        return button.classList.contains("active");
    }), 0);

    function showThumb(index) {
        var count = thumbs.length;
        currentIndex = ((index % count) + count) % count;
        var thumb = thumbs[currentIndex];

        thumbs.forEach(function (button) {
            button.classList.remove("active");
        });

        thumb.classList.add("active");
        mainImage.src = thumb.getAttribute("data-image-src");
        mainImage.alt = thumb.getAttribute("data-image-alt");
        // Dải ảnh nhỏ cuộn ngang (xem .gallery-thumbs trong style.css) - kéo ảnh
        // đang chọn vào giữa khung nhìn cho khỏi bị khuất 2 đầu dải.
        thumb.scrollIntoView({behavior: "smooth", inline: "center", block: "nearest"});
    }

    thumbs.forEach(function (thumb, index) {
        thumb.addEventListener("click", function () {
            // Bấm vào ảnh nhỏ (productImage) trong dải thumbnail CHỈ đổi ảnh đang
            // hiện ở gallery-frame - không mở popup phóng to. Popup chỉ mở khi
            // bấm vào chính ảnh lớn ở gallery-frame (xem mainImage click bên dưới).
            showThumb(index);
        });
    });

    if (prevButton) {
        prevButton.addEventListener("click", function () {
            showThumb(currentIndex - 1);
        });
    }

    if (nextButton) {
        nextButton.addEventListener("click", function () {
            showThumb(currentIndex + 1);
        });
    }

    // Kéo/vuốt ngang trên ảnh chính cũng chuyển ảnh trước/sau y hệt 2 nút
    // prev/next - dùng Pointer Events (gộp chung chuột/touch/bút cảm ứng vào
    // 1 API) nên vừa vuốt được trên điện thoại, vừa KÉO được bằng chuột trên
    // laptop, không cần viết 2 bộ handler riêng cho touch và mouse.
    // Chỉ tính là "kéo/vuốt" khi độ dịch ngang đủ lớn (ngưỡng SWIPE_THRESHOLD)
    // VÀ trội hơn hẳn độ dịch dọc, tránh nhầm với cuộn trang dọc / click chọn
    // ảnh (thumbnail) thông thường.
    var gallerySwipeStage = mainImage.closest(".gallery-stage") || mainImage.parentElement;

    // Bấm vào ẢNH CHÍNH ở gallery-frame -> mở lightbox phóng to đúng ảnh đang
    // hiển thị (xem markup <div data-lightbox> ở product-detail.jsp). Bấm vào
    // ảnh nhỏ/productImage trong dải thumbnail thì KHÔNG mở popup - chỉ đổi
    // ảnh đang hiện ở gallery-frame (xem thumbs.forEach phía trên).
    //
    // openLightbox khai báo TRƯỚC khối kéo/vuốt bên dưới (dù chỉ dùng trong đó)
    // vì đây là function declaration, được hoist lên đầu scope nên thứ tự đứng
    // trước/sau không quan trọng - đặt trước cho dễ đọc theo mạch "định nghĩa
    // trước, dùng sau".
    var lightbox = document.querySelector("[data-lightbox]");
    var lightboxImage = lightbox ? lightbox.querySelector("[data-lightbox-image]") : null;
    var lightboxClose = lightbox ? lightbox.querySelector("[data-lightbox-close]") : null;
    var lightboxPrev = lightbox ? lightbox.querySelector("[data-lightbox-prev]") : null;
    var lightboxNext = lightbox ? lightbox.querySelector("[data-lightbox-next]") : null;

    function syncLightboxImage() {
        if (!lightboxImage) { return; }
        lightboxImage.src = mainImage.src;
        lightboxImage.alt = mainImage.alt;
    }

    function openLightbox() {
        if (!lightbox || !lightboxImage) { return; }
        syncLightboxImage();
        lightbox.classList.add("open");
        lightbox.setAttribute("aria-hidden", "false");
        document.body.style.overflow = "hidden"; // khoá cuộn nền trong lúc xem ảnh to
    }

    function closeLightbox() {
        if (!lightbox) { return; }
        lightbox.classList.remove("open");
        lightbox.setAttribute("aria-hidden", "true");
        document.body.style.overflow = "";
    }

    if (lightbox && lightboxImage) {
        // KHÔNG gắn listener "click" riêng lên mainImage để mở lightbox - khối
        // kéo/vuốt bên dưới (gallerySwipeStage) gọi setPointerCapture() trên
        // pointerdown, khiến MỌI pointer event tiếp theo (kể cả click phái sinh
        // từ chuột) bị route thẳng về gallerySwipeStage thay vì mainImage, nên
        // 1 listener "click" gắn riêng trên mainImage sẽ KHÔNG BAO GIỜ được gọi
        // với thao tác chuột/tay thật (chỉ chạy được nếu tự bắn .click() bằng
        // JS, che giấu mất bug này lúc test). Việc "bấm = mở lightbox" được xử
        // lý gộp chung trong endSwipe() (chính là pointerup của gallerySwipeStage)
        // ở khối bên dưới thay vào đó.

        if (lightboxClose) {
            lightboxClose.addEventListener("click", closeLightbox);
        }

        // Bấm trúng nền tối (không phải ảnh/nút bên trong) cũng đóng.
        lightbox.addEventListener("click", function (event) {
            if (event.target === lightbox) {
                closeLightbox();
            }
        });

        document.addEventListener("keydown", function (event) {
            if (!lightbox.classList.contains("open")) {
                return;
            }
            if (event.key === "Escape") {
                closeLightbox();
            } else if (event.key === "ArrowLeft") {
                showThumb(currentIndex - 1);
                syncLightboxImage();
            } else if (event.key === "ArrowRight") {
                showThumb(currentIndex + 1);
                syncLightboxImage();
            }
        });

        if (thumbs.length > 1) {
            if (lightboxPrev) {
                lightboxPrev.addEventListener("click", function () {
                    showThumb(currentIndex - 1);
                    syncLightboxImage();
                });
            }
            if (lightboxNext) {
                lightboxNext.addEventListener("click", function () {
                    showThumb(currentIndex + 1);
                    syncLightboxImage();
                });
            }
        } else {
            // Chỉ 1 ảnh - không có gì để chuyển, ẩn luôn 2 nút prev/next.
            if (lightboxPrev) { lightboxPrev.style.display = "none"; }
            if (lightboxNext) { lightboxNext.style.display = "none"; }
        }
    }

    // Kéo/vuốt ngang trên ảnh chính chuyển ảnh trước/sau (giống 2 nút prev/next),
    // bấm bình thường (không kéo đủ xa) thì mở lightbox - GỘP CHUNG cả 2 hành vi
    // vào đúng 1 pointerup (endSwipe) thay vì tách click riêng, vì
    // setPointerCapture() ở pointerdown khiến "click" gốc không còn đáng tin cậy
    // (xem giải thích ở khối "if (lightbox && lightboxImage)" phía trên).
    // Dùng Pointer Events (gộp chung chuột/touch/bút cảm ứng vào 1 API) nên vừa
    // vuốt được trên điện thoại, vừa kéo được bằng chuột trên laptop.
    if (gallerySwipeStage) {
        var swipeStartX = 0;
        var swipeStartY = 0;
        var swipePointerId = null;
        var SWIPE_THRESHOLD = 40; // px

        // Chặn hành vi kéo-thả ảnh mặc định của trình duyệt (ghost image) - nếu
        // không chặn, giữ chuột kéo trên <img> sẽ kích hoạt native drag thay vì
        // pointermove/pointerup của mình, khiến thao tác kéo không nhận được.
        gallerySwipeStage.addEventListener("dragstart", function (event) {
            event.preventDefault();
        });

        gallerySwipeStage.addEventListener("pointerdown", function (event) {
            // Chuột: chỉ bắt nút trái (button 0). Touch/bút không có "button"
            // phân biệt nên coi như hợp lệ luôn (button === 0 hoặc -1 tuỳ trình duyệt).
            if (event.pointerType === "mouse" && event.button !== 0) {
                return;
            }
            swipeStartX = event.clientX;
            swipeStartY = event.clientY;
            swipePointerId = event.pointerId;
            // Giữ pointer capture trên chính phần tử này để vẫn nhận được
            // pointerup dù chuột đã kéo ra ngoài vùng ảnh trước khi thả.
            gallerySwipeStage.setPointerCapture(event.pointerId);
            gallerySwipeStage.classList.add("gallery-stage-dragging");
        });

        function endSwipe(event) {
            if (swipePointerId === null || event.pointerId !== swipePointerId) {
                return;
            }
            swipePointerId = null;
            gallerySwipeStage.classList.remove("gallery-stage-dragging");

            var deltaX = event.clientX - swipeStartX;
            var deltaY = event.clientY - swipeStartY;
            var isSwipe = thumbs.length > 1
                && Math.abs(deltaX) >= SWIPE_THRESHOLD
                && Math.abs(deltaX) > Math.abs(deltaY);

            if (isSwipe) {
                if (deltaX < 0) {
                    showThumb(currentIndex + 1); // kéo/vuốt sang trái -> ảnh sau
                } else {
                    showThumb(currentIndex - 1); // kéo/vuốt sang phải -> ảnh trước
                }
                return;
            }

            // Không kéo đủ xa để tính là vuốt -> coi như 1 cú bấm bình thường.
            openLightbox();
        }

        gallerySwipeStage.addEventListener("pointerup", endSwipe);
        gallerySwipeStage.addEventListener("pointercancel", function () {
            swipePointerId = null;
            gallerySwipeStage.classList.remove("gallery-stage-dragging");
        });
    }

    // 2 nút nhỏ cạnh dải ảnh chỉ cuộn dải thumbnail, KHÔNG đổi ảnh chính -
    // đổi ảnh chính vẫn phải bấm đúng thumbnail hoặc dùng 2 nút to ở ảnh lớn.
    if (thumbTrack && thumbPrevButton) {
        thumbPrevButton.addEventListener("click", function () {
            thumbTrack.scrollBy({left: -thumbTrack.clientWidth * 0.8, behavior: "smooth"});
        });
    }

    if (thumbTrack && thumbNextButton) {
        thumbNextButton.addEventListener("click", function () {
            thumbTrack.scrollBy({left: thumbTrack.clientWidth * 0.8, behavior: "smooth"});
        });
    }

    // Gọi từ product-detail.jsp mỗi khi người dùng bấm chọn màu variant, để
    // ảnh chính nảy sang đúng ảnh của màu đó. Không tìm thấy ảnh khớp thì
    // giữ nguyên ảnh đang hiển thị (không có bảng ánh xạ màu-ảnh nào khác).
    window.productGallerySelectColor = function (colorName) {
        var slug = slugifyForImageMatch(colorName);
        if (!slug) {
            return;
        }
        var matchIndex = thumbs.findIndex(function (thumb) {
            var src = (thumb.getAttribute("data-image-src") || "").toLowerCase();
            return src.indexOf(slug) !== -1;
        });
        if (matchIndex !== -1) {
            showThumb(matchIndex);
        }
    };
}

function initProductCatalog() {
    var filterForm = document.querySelector("[data-product-filter-form]");
    var grid = document.querySelector("[data-product-grid]");

    if (!filterForm || !grid) {
        return;
    }

    var items = Array.prototype.slice.call(grid.querySelectorAll("[data-product-item]"));
    var searchInput = filterForm.querySelector("[data-product-search]");
    var sortSelect = document.querySelector("[data-product-sort]");
    var emptyState = document.querySelector("[data-product-empty]");
    var countNodes = document.querySelectorAll("[data-product-count], [data-product-count-inline]");
    var resetButton = filterForm.querySelector("[data-product-reset]");

    function getFilterValue(key) {
        var field = filterForm.querySelector("[data-product-filter='" + key + "']");
        return field ? field.value : "all";
    }

    function matchPrice(priceValue, rangeValue) {
        var priceNumber = Number(priceValue || 0);

        if (rangeValue === "under-500") {
            return priceNumber < 500;
        }

        if (rangeValue === "500-1000") {
            return priceNumber >= 500 && priceNumber <= 1000;
        }

        if (rangeValue === "1000-1500") {
            return priceNumber > 1000 && priceNumber <= 1500;
        }

        if (rangeValue === "1500-plus") {
            return priceNumber > 1500;
        }

        return true;
    }

    function resolveSortValue(item, sortValue) {
        if (sortValue === "price-asc") {
            return Number(item.dataset.price);
        }

        if (sortValue === "price-desc") {
            return Number(item.dataset.price) * -1;
        }

        if (sortValue === "newest") {
            return Number(item.dataset.newestRank);
        }

        if (sortValue === "best-selling") {
            return Number(item.dataset.bestRank);
        }

        return Number(item.dataset.featuredRank);
    }

    function applyCatalogState() {
        var keyword = searchInput ? searchInput.value.trim().toLowerCase() : "";
        var category = getFilterValue("category");
        var price = getFilterValue("price");
        var color = getFilterValue("color");
        var storage = getFilterValue("storage");
        var availability = getFilterValue("availability");
        var sortValue = sortSelect ? sortSelect.value : "featured";
        var visibleCount = 0;

        items.sort(function (first, second) {
            return resolveSortValue(first, sortValue) - resolveSortValue(second, sortValue);
        });

        items.forEach(function (item) {
            grid.appendChild(item);
        });

        items.forEach(function (item) {
            var matchesKeyword = !keyword || item.dataset.name.indexOf(keyword) !== -1;
            var matchesCategory = category === "all" || item.dataset.category === category;
            var matchesPrice = matchPrice(item.dataset.price, price);
            var matchesColor = color === "all" || item.dataset.color === color;
            var matchesStorage = storage === "all" || item.dataset.storage === storage;
            var matchesAvailability = availability === "all" || item.dataset.availability === availability;
            var isVisible = matchesKeyword && matchesCategory && matchesPrice && matchesColor && matchesStorage && matchesAvailability;

            item.classList.toggle("is-hidden", !isVisible);

            if (isVisible) {
                visibleCount += 1;
            }
        });

        countNodes.forEach(function (node) {
            node.textContent = String(visibleCount);
        });

        if (emptyState) {
            emptyState.classList.toggle("is-hidden", visibleCount !== 0);
        }
    }

    filterForm.addEventListener("input", applyCatalogState);
    filterForm.addEventListener("change", applyCatalogState);

    if (sortSelect) {
        sortSelect.addEventListener("change", applyCatalogState);
    }

    if (resetButton) {
        resetButton.addEventListener("click", function () {
            window.setTimeout(applyCatalogState, 0);
        });
    }

    applyCatalogState();
}

function initCartDemo() {
    var cartRoot = document.querySelector("[data-cart-root]");

    if (!cartRoot) {
        return;
    }

    var filledState = cartRoot.querySelector("[data-cart-filled]");
    var summaryCard = cartRoot.querySelector("[data-cart-summary]");
    var emptyState = document.querySelector("[data-cart-empty]");
    var subtotalNode = cartRoot.querySelector("[data-cart-subtotal]");
    var totalNode = cartRoot.querySelector("[data-cart-total]");
    var discountNode = cartRoot.querySelector("[data-cart-discount]");
    var shippingNode = cartRoot.querySelector("[data-cart-shipping]");
    var countNodes = document.querySelectorAll("[data-cart-count]");
    var badgeNodes = document.querySelectorAll("[data-cart-badge]");
    var baseShipping = Number(cartRoot.getAttribute("data-cart-shipping-value") || 0);
    var baseDiscount = Number(cartRoot.getAttribute("data-cart-discount-value") || 0);
    var currencyFormatter = new Intl.NumberFormat("en-US", {
        style: "currency",
        currency: "USD",
        maximumFractionDigits: 0
    });

    function formatCurrency(value) {
        return currencyFormatter.format(value);
    }

    function updateCart() {
        var items = Array.prototype.slice.call(cartRoot.querySelectorAll("[data-cart-item]"));
        var subtotal = 0;
        var itemCount = 0;

        items.forEach(function (item) {
            var input = item.querySelector("input[type='number']");
            var lineTotalNode = item.querySelector("[data-cart-line-total]");
            var unitPrice = Number(item.getAttribute("data-unit-price") || 0);
            var minimum = Number(input.min || 1);
            var maximum = Number(input.max || 9999);
            var quantity = Number(input.value || minimum);

            quantity = Math.max(minimum, Math.min(quantity, maximum));
            input.value = quantity;

            var lineTotal = unitPrice * quantity;
            subtotal += lineTotal;
            itemCount += quantity;

            if (lineTotalNode) {
                lineTotalNode.textContent = formatCurrency(lineTotal);
            }
        });

        var shippingValue = itemCount > 0 ? baseShipping : 0;
        var discountValue = itemCount > 0 ? baseDiscount : 0;
        var total = Math.max(subtotal + shippingValue - discountValue, 0);

        if (subtotalNode) {
            subtotalNode.textContent = formatCurrency(subtotal);
        }

        if (totalNode) {
            totalNode.textContent = formatCurrency(total);
        }

        if (discountNode) {
            discountNode.textContent = discountValue > 0 ? "-" + formatCurrency(discountValue) : formatCurrency(0);
        }

        if (shippingNode) {
            shippingNode.textContent = formatCurrency(shippingValue);
        }

        countNodes.forEach(function (node) {
            node.textContent = String(itemCount);
        });

        badgeNodes.forEach(function (node) {
            node.textContent = String(itemCount);
        });

        if (filledState) {
            filledState.classList.toggle("is-hidden", itemCount === 0);
        }

        if (summaryCard) {
            summaryCard.classList.toggle("is-hidden", itemCount === 0);
        }

        if (emptyState) {
            emptyState.classList.toggle("is-hidden", itemCount !== 0);
        }
    }

    cartRoot.addEventListener("click", function (event) {
        var removeButton = event.target.closest("[data-cart-remove]");

        if (!removeButton) {
            return;
        }

        var item = removeButton.closest("[data-cart-item]");

        if (item) {
            item.remove();
            updateCart();
        }
    });

    cartRoot.addEventListener("input", function (event) {
        if (event.target.matches("[data-cart-item] input[type='number']")) {
            updateCart();
        }
    });

    updateCart();
}

function initLoadingButtons() {
    var loadingButtons = document.querySelectorAll("[data-loading-button]");

    loadingButtons.forEach(function (button) {
        button.addEventListener("click", function (event) {
            event.preventDefault();

            if (button.classList.contains("is-loading")) {
                return;
            }

            button.classList.add("is-loading");
            button.setAttribute("aria-busy", "true");

            window.setTimeout(function () {
                button.classList.remove("is-loading");
                button.removeAttribute("aria-busy");
            }, 1400);
        });
    });
}

function initToastTriggers() {
    var triggerButtons = document.querySelectorAll("[data-toast-trigger]");

    triggerButtons.forEach(function (button) {
        var toastId = button.getAttribute("data-toast-trigger");
        var toastElement = document.getElementById(toastId);

        if (!toastElement || typeof bootstrap === "undefined") {
            return;
        }

        var toastInstance = bootstrap.Toast.getOrCreateInstance(toastElement);

        button.addEventListener("click", function () {
            toastInstance.show();
        });
    });
}

function initCurrentYear() {
    var yearNodes = document.querySelectorAll("[data-current-year]");
    var currentYear = new Date().getFullYear();

    yearNodes.forEach(function (node) {
        node.textContent = String(currentYear);
    });
}

/**
 * Shared login/register flash-message handling.
 *
 * The auth servlets communicate success/error state back through the query string:
 *   - error=<message>            shown as a red alert
 *   - registered=1               shown as a green "account created" alert
 *   - email / fullName / phone   re-filled into the form after a failed submit
 *   - redirectTo=<in-app path>   copied into the hidden #login-redirect-target
 *                                 field so login?redirectTo=/checkout.html
 *                                 (set by AuthFilter/AdminFilter/CustomerFilter)
 *                                 sends the customer back where they started.
 */
function initAuthFlashMessages() {
    var alertBox = document.querySelector("[data-auth-alert]");
    var params = new URLSearchParams(window.location.search);

    if (alertBox) {
        var errorMessage = params.get("error");
        var registered = params.get("registered");
        var changed = params.get("changed");

        if (errorMessage) {
            alertBox.textContent = errorMessage;
            alertBox.classList.remove("alert-success");
            alertBox.classList.add("alert-danger");
            alertBox.hidden = false;
        } else if (registered) {
            alertBox.textContent = "Account created successfully. Please sign in.";
            alertBox.classList.remove("alert-danger");
            alertBox.classList.add("alert-success");
            alertBox.hidden = false;
        } else if (changed) {
            alertBox.textContent = "Đổi mật khẩu thành công.";
            alertBox.classList.remove("alert-danger");
            alertBox.classList.add("alert-success");
            alertBox.hidden = false;
        }
    }

    refillField("login-email", params.get("email"));
    refillField("register-fullname", params.get("fullName"));
    refillField("register-email", params.get("email"));
    refillField("register-phone", params.get("phone"));

    var redirectField = document.getElementById("login-redirect-target");
    var redirectTo = params.get("redirectTo");
    if (redirectField && redirectTo) {
        redirectField.value = redirectTo;
    }
}

function refillField(elementId, value) {
    var field = document.getElementById(elementId);
    if (field && value) {
        field.value = value;
    }
}

/**
 * Client-side "passwords match" nudge for register. The server
 * (service.AuthService) is still the source of truth for this check.
 */
(function initRegisterPasswordMatchHint() {
    document.addEventListener("DOMContentLoaded", function () {
        var form = document.forms.registerForm;
        if (!form) {
            return;
        }

        var password = form.querySelector("#register-password");
        var confirm = form.querySelector("#register-confirm-password");
        if (!password || !confirm) {
            return;
        }

        function validateMatch() {
            confirm.setCustomValidity(
                    confirm.value && confirm.value !== password.value ? "Passwords do not match." : ""
                    );
        }

        password.addEventListener("input", validateMatch);
        confirm.addEventListener("input", validateMatch);
    });
})();
