<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<c:set var="isCategoryMenuActive" value="${activeMenu eq 'home' or activeMenu eq 'iphone' or activeMenu eq 'ipad' or activeMenu eq 'mac' or activeMenu eq 'watch' or activeMenu eq 'accessory'}"/>

<header class="sf-top" id="siteHeader">
    <%-- Đơn hàng chuyển lên dải trên cùng (rule mới) - đứng cuối dòng, cạnh
         các thông tin giao hàng/bảo hành, thay vì nằm trong nav chính. Dòng
         khuyến mãi bên trái chạy marquee phải→trái liên tục (rule mới) - nội
         dung lặp lại 2 lần trong .etch-track để vòng lặp liền mạch (xem CSS
         @keyframes etchMarquee: translateX 0 -> -50%, đúng 1 vòng nội dung). --%>
    <div class="etch" id="headerPromo">
        <div class="etch-marquee">
            <div class="etch-track">
                <span class="etch-item"><svg width="13" height="13"><use href="#i-truck"/></svg>Giao nhanh - Miễn phí cho đơn từ 300k</span><i class="dot"></i>
                <span class="etch-item"><svg width="13" height="13"><use href="#i-swap"/></svg>Thu cũ giá ngon - Lên đời tiết kiệm</span><i class="dot"></i>
                <span class="etch-item"><svg width="13" height="13"><use href="#i-percent"/></svg>Trả góp 0%</span><i class="dot"></i>
                <span class="etch-item"><svg width="13" height="13"><use href="#i-check"/></svg>Sản phẩm chính hãng - Xuất VAT đầy đủ</span><i class="dot"></i>
                <%-- Lặp lại y hệt, aria-hidden để trình đọc màn hình không đọc 2 lần --%>
                <span class="etch-item" aria-hidden="true"><svg width="13" height="13"><use href="#i-truck"/></svg>Giao nhanh - Miễn phí cho đơn từ 300k</span><i class="dot" aria-hidden="true"></i>
                <span class="etch-item" aria-hidden="true"><svg width="13" height="13"><use href="#i-swap"/></svg>Thu cũ giá ngon - Lên đời tiết kiệm</span><i class="dot" aria-hidden="true"></i>
                <span class="etch-item" aria-hidden="true"><svg width="13" height="13"><use href="#i-percent"/></svg>Trả góp 0%</span><i class="dot" aria-hidden="true"></i>
                <span class="etch-item" aria-hidden="true"><svg width="13" height="13"><use href="#i-check"/></svg>Sản phẩm chính hãng - Xuất VAT đầy đủ</span><i class="dot" aria-hidden="true"></i>
            </div>
        </div>
        <div class="etch-right">
            <a class="etch-link ${activeMenu eq 'order' ? 'on' : ''}" href="${ctx}/account/orders">
                <svg width="13" height="13"><use href="#i-box"/></svg>Tra Cứu Đơn hàng
            </a>
            <span class="etch-link etch-phone">
                <svg width="13" height="13"><use href="#i-phone"/></svg>1800 8888
            </span>
        </div>
    </div>

    <nav class="sf-nav">
        <a class="sf-logo" href="${ctx}/home">
            <svg width="26" height="26" style="color:var(--titan)"><use href="#logo-mark"/></svg>
            <span class="wm">AOS · APPLESTORE</span>
        </a>

        <%-- Toàn bộ danh mục sản phẩm gói vào 1 dropdown thay vì dàn hàng
             ngang (rule mới) - bấm mở, bấm ra ngoài / Esc để đóng, xem
             script cuối trang. --%>
        <div class="sf-menu" id="categoryMenu">
            <button type="button" class="sf-menu-btn ${isCategoryMenuActive ? 'on' : ''}" id="categoryMenuBtn"
                    aria-haspopup="true" aria-expanded="false" aria-controls="categoryMenuPanel">
                <svg width="16" height="16"><use href="#i-grid"/></svg>
                <span>Danh mục</span>
                <svg width="11" height="11" class="chev"><use href="#i-chevron-down"/></svg>
            </button>
            <div class="sf-menu-panel" id="categoryMenuPanel" role="menu">
                <a class="${activeMenu eq 'iphone' ? 'on' : ''}" href="${ctx}/products?categoryId=1" role="menuitem">iPhone</a>
                <a class="${activeMenu eq 'ipad' ? 'on' : ''}" href="${ctx}/products?categoryId=2" role="menuitem">iPad</a>
                <a class="${activeMenu eq 'mac' ? 'on' : ''}" href="${ctx}/products?categoryId=3" role="menuitem">Mac</a>
                <a class="${activeMenu eq 'watch' ? 'on' : ''}" href="${ctx}/products?categoryId=4" role="menuitem">Apple Watch</a>
                <a class="${activeMenu eq 'accessory' ? 'on' : ''}" href="${ctx}/products?categoryId=7" role="menuitem">Phụ kiện</a>
            </div>
        </div>

        <a class="sf-chip ${activeMenu eq 'voucher' ? 'on' : ''}" href="${ctx}/vouchers">
            <svg width="15" height="15"><use href="#i-tag"/></svg>
            <span>Khuyến mãi</span>
        </a>

        <form class="sf-search" method="get" action="${ctx}/products" role="search">
            <label class="sr-only" for="hdSearch">Tìm sản phẩm</label>
            <svg width="15" height="15"><use href="#i-search"/></svg>
            <input id="hdSearch" type="text" name="keyword" value="<c:out value='${keyword}'/>"
                   placeholder="Tìm iPhone, Mac, iPad…" maxlength="100">
        </form>

        <div class="tools">
            <%-- Phân luồng nút truy cập quản trị/nhiệm vụ theo từng role --%>
            <c:if test="${not empty sessionScope.user}">
                <c:choose>
                    <c:when test="${sessionScope.user.role eq 'ADMIN' or sessionScope.user.role eq 'SALE_STAFF'}">
                        <a class="btn titan xs" href="${ctx}/admin/dashboard">Vào quản trị</a>
                    </c:when>
                    <c:when test="${sessionScope.user.role eq 'DELIVERY'}">
                        <a class="btn titan xs" href="${ctx}/staff/tasks">Nhiệm vụ giao hàng</a>
                    </c:when>
                </c:choose>
            </c:if>

            <%-- Chữ "Giỏ hàng" đứng trước icon (rule mới) - .ic vẫn giữ để JS
                 (cart.jsp/product-detail.jsp) tìm đúng link qua selector
                 .ic[href$="/cart"], .sf-cart chỉ đổi hình dạng tròn thành viên
                 thuốc có chữ. Icon bọc riêng trong .sf-cart-icon để badge số
                 lượng (.dot-n) ghim đúng vào góc icon, không lệch ra góc cả ô. --%>
            <a class="ic sf-cart" href="${ctx}/cart" title="Giỏ hàng">
                <span>Giỏ hàng</span>
                <span class="sf-cart-icon">
                    <svg width="20" height="20"><use href="#i-cart"/></svg>
                    <c:if test="${not empty requestScope.cartItemCount and requestScope.cartItemCount > 0}">
                        <span class="dot-n">${requestScope.cartItemCount}</span>
                    </c:if>
                </span>
            </a>

            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <c:set var="avatarLetter" value="U"/>
                    <c:if test="${not empty sessionScope.user.fullName}">
                        <c:set var="avatarLetter" value="${fn:toUpperCase(fn:substring(sessionScope.user.fullName, 0, 1))}"/>
                    </c:if>
                    <%-- Chữ cái đầu tên rồi mới đến icon người dùng (rule mới) -
                         gộp chung 1 ô thay vì avatar tròn trơn như trước. --%>
                    <a class="sf-account" href="${ctx}/profile" title="<c:out value='${sessionScope.user.fullName}'/> · Xem hồ sơ">
                        <span class="sf-account-name"><c:out value="${avatarLetter}"/></span>
                    </a>
                    <a class="ic" href="${ctx}/logout" title="Đăng xuất">
                        <svg width="17" height="17"><use href="#i-logout"/></svg>
                    </a>
                </c:when>
                <c:otherwise>
                    <a class="ic" href="${ctx}/login" title="Đăng nhập">
                        <svg width="17" height="17"><use href="#i-user"/></svg>
                    </a>
                </c:otherwise>
            </c:choose>
        </div>
    </nav>
</header>

<script>
    (function () {
        var header = document.getElementById('siteHeader');
        var promo = document.getElementById('headerPromo');
        if (!header) { return; }

        // Header giờ position:sticky (style.css) - đo chiều cao thật để ghi
        // vào biến --sf-header-h, cho các khối sticky khác (panel tóm tắt đơn
        // hàng ở cart.jsp/checkout.jsp/order-success.jsp) canh top bên dưới
        // header thay vì bị header đè lên.
        function syncHeaderHeight() {
            document.documentElement.style.setProperty('--sf-header-h', header.offsetHeight + 'px');
        }
        syncHeaderHeight();
        window.addEventListener('resize', syncHeaderHeight);
        window.addEventListener('load', syncHeaderHeight);

        if (!promo) { return; }

        // Vuốt xuống -> chỉ thu gọn dải khuyến mãi #headerPromo ("Giao hàng
        // toàn quốc..."), phần logo/menu (.sf-nav) LUÔN đứng yên, không ẩn
        // theo. Vuốt lên (bất kỳ lúc nào) -> hiện lại dải khuyến mãi ngay.
        // Đọc scrollY trong rAF (không xử lý trực tiếp trong sự kiện scroll)
        // để không chặn luồng cuộn - mượt hơn nhiều so với gắn logic thẳng
        // vào 'scroll'. Ngưỡng lệch tối thiểu (SCROLL_DELTA) để lướt nhẹ/rung
        // chuột không làm dải khuyến mãi nhấp nháy ẩn/hiện liên tục. Luôn
        // hiện khi còn gần đỉnh trang (dưới chiều cao header) để tránh
        // "lơ lửng" nửa ẩn nửa hiện.
        var SCROLL_DELTA = 6;
        var lastY = window.scrollY || window.pageYOffset || 0;
        var ticking = false;

        function onFrame() {
            ticking = false;
            var currentY = window.scrollY || window.pageYOffset || 0;
            var diff = currentY - lastY;

            if (currentY <= header.offsetHeight) {
                promo.classList.remove('promo--hidden');
            } else if (diff > SCROLL_DELTA) {
                promo.classList.add('promo--hidden');
            } else if (diff < -SCROLL_DELTA) {
                promo.classList.remove('promo--hidden');
            }
            lastY = currentY;

            // Chiều cao header đổi theo lúc dải khuyến mãi thu/giãn - đo lại
            // ngay để các panel sticky khác (top:calc(var(--sf-header-h)...))
            // bám sát mép header thay vì để hở/khuất một khoảng trong lúc
            // animate (transitionend bên dưới bắt luôn khung hình cuối).
            syncHeaderHeight();
        }

        window.addEventListener('scroll', function () {
            if (!ticking) {
                ticking = true;
                requestAnimationFrame(onFrame);
            }
        }, { passive: true });

        promo.addEventListener('transitionend', function (e) {
            if (e.propertyName === 'max-height') { syncHeaderHeight(); }
        });
    })();

    // Dropdown "Danh mục" - bấm nút để mở/đóng, bấm ra ngoài hoặc nhấn Esc
    // để đóng lại. aria-expanded đồng bộ với class .open để hỗ trợ đọc màn hình.
    (function () {
        var menu = document.getElementById('categoryMenu');
        var btn = document.getElementById('categoryMenuBtn');
        var panel = document.getElementById('categoryMenuPanel');
        if (!menu || !btn || !panel) { return; }

        function closeMenu() {
            panel.classList.remove('open');
            btn.setAttribute('aria-expanded', 'false');
        }

        function toggleMenu() {
            var willOpen = !panel.classList.contains('open');
            panel.classList.toggle('open', willOpen);
            btn.setAttribute('aria-expanded', String(willOpen));
        }

        btn.addEventListener('click', function (e) {
            e.stopPropagation();
            toggleMenu();
        });

        document.addEventListener('click', function (e) {
            if (!menu.contains(e.target)) { closeMenu(); }
        });

        document.addEventListener('keydown', function (e) {
            if (e.key === 'Escape') { closeMenu(); btn.focus(); }
        });
    })();
</script>
