<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Cửa hàng Apple Trực tuyến | Trang chủ</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
    </head>
    <body class="site-body">
        <!--
            GHI CHÚ: mọi liên kết sang trang sản phẩm trong file này đều
            trỏ qua servlet, KHÔNG trỏ thẳng tên file .jsp:
                - Danh sách sản phẩm: ${ctx}/products (thay cho products-list.jsp)
                - Chi tiết sản phẩm : ${ctx}/product?id={productId} (thay cho product-detail.jsp)
            4 khối "Sản phẩm nổi bật" bên dưới vẫn là dữ liệu tĩnh (demo) nên
            productId đang gán cứng 1,2,3,4 - khớp với productId trong các
            form "Thêm vào giỏ" đã thêm trước đó. Khi trang chủ được nạp dữ
            liệu thật từ HomeServlet/ProductDAO, đổi các số cứng này thành
        ${p.productId} trong vòng lặp c:forEach.
        -->
        <c:set var="ctx" value="${pageContext.request.contextPath}" />

        <!-- Header trang -->
        <header class="site-header">
            <div class="container header-main">
                <a class="brand" href="${ctx}/index.jsp" aria-label="Cửa hàng Apple trực tuyến">
                    <img src="${ctx}/assets/images/logo-mark.svg" alt="Biểu tượng AOS">
                    <span>
                        <strong>Cửa hàng AOS</strong>
                        <small>Giao diện Apple</small>
                    </span>
                </a>
                <c:choose>
                    <c:when test="${not empty sessionScope.user and (sessionScope.user.role eq 'ADMIN' or sessionScope.user.role eq 'SALE_STAFF')}">
                        <a href="${ctx}/admin/dashboard" class="btn btn-app-primary ms-auto me-3">
                            Vào trang quản trị
                        </a>
                    </c:when>
                    <c:otherwise>
                        <div class="ms-auto"></div>
                    </c:otherwise>
                </c:choose>
                <div class="header-actions">
                    <div class="dropdown">
                        <button class="btn btn-app-ghost dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Tài khoản
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end app-dropdown-menu">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user}">
                                    <!-- Đã đăng nhập -->
                                    <li class="px-3 py-2 text-muted small">Xin chào, ${sessionScope.user.fullName}</li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item" href="${ctx}/profile">Hồ sơ cá nhân</a></li>
                                    <li><a class="dropdown-item" href="${ctx}/order-history">Lịch sử đơn hàng</a></li>
                                    <li><a class="dropdown-item" href="${ctx}/wishlist">Yêu thích</a></li>
                                    <li><hr class="dropdown-divider"></li>
                                    <li><a class="dropdown-item text-danger" href="${ctx}/logout">Đăng xuất</a></li>
                                    </c:when>
                                    <c:otherwise>
                                    <!-- Chưa đăng nhập -->
                                    <li><a class="dropdown-item" href="${ctx}/login">Đăng nhập</a></li>
                                    <li><a class="dropdown-item" href="${ctx}/register">Đăng ký</a></li>
                                    </c:otherwise>
                                </c:choose>
                        </ul>
                    </div>
                    <a class="cart-link" href="${ctx}/cart" aria-label="Xem giỏ hàng">
                        <span>Giỏ hàng</span>
                        <span class="cart-count">${not empty sessionScope.cartCount ? sessionScope.cartCount : '0'}</span>
                    </a>
                    <button class="mobile-menu-button" type="button" data-mobile-toggle aria-expanded="false" aria-label="Mở menu di động">
                        <span></span>
                        <span></span>
                        <span></span>
                    </button>
                </div>
            </div>
            <nav class="category-nav">
                <div class="container category-nav-inner">
                    <a href="${ctx}/products?category=iphone">iPhone</a>
                    <a href="${ctx}/products?category=mac">Mac</a>
                    <a href="${ctx}/products?category=ipad">iPad</a>
                    <a href="${ctx}/products?category=watch">Apple Watch</a>
                    <a href="${ctx}/products?category=airpods">AirPods</a>
                    <a href="${ctx}/products?category=accessories">Phụ kiện</a>
                    <a href="${ctx}/products">Tất cả sản phẩm</a>
                </div>
            </nav>
            <div class="mobile-drawer" data-mobile-panel>
                <div class="container mobile-drawer-inner">
                    <form class="mobile-search" action="${ctx}/products" method="get" name="mobileSearchForm">
                        <label class="visually-hidden" for="mobile-search-input">Tìm kiếm sản phẩm</label>
                        <input id="mobile-search-input" class="form-control" type="search" name="keyword" placeholder="Tìm kiếm sản phẩm">
                    </form>
                    <div class="mobile-links">
                        <a href="${ctx}/products?category=iphone">iPhone</a>
                        <a href="${ctx}/products?category=mac">Mac</a>
                        <a href="${ctx}/products?category=ipad">iPad</a>
                        <a href="${ctx}/products?category=watch">Apple Watch</a>
                        <a href="${ctx}/products?category=airpods">AirPods</a>
                        <a href="${ctx}/products?category=accessories">Phụ kiện</a>
                        <a href="${ctx}/login">Đăng nhập</a>
                        <a href="${ctx}/register">Đăng ký</a>
                        <a href="${ctx}/wishlist.html">Yêu thích</a>
                        <a href="${ctx}/components/component-demo.html">Bản thử nghiệm</a>
                    </div>
                </div>
            </div>
        </header>

        <main>
            <!-- Hero trang chủ -->
            <section class="hero-section home-hero">
                <div class="container">
                    <div class="hero-shell">
                        <div class="hero-copy">
                            <span class="eyebrow">Mùa mới / Dòng sản phẩm Apple</span>
                            <h1>Tìm kiếm thiết bị Apple bạn muốn xem, so sánh và mua sắm.</h1>
                            <p>
                                Cửa hàng trực tuyến tinh tế với giao diện sản phẩm trực quan, cấu trúc mua sắm tiện dụng và sẵn sàng mở rộng.
                            </p>

                            <div class="mt-4 mb-4">
                                <form class="hero-search d-flex gap-2" action="${ctx}/products" method="get" name="heroSearchForm">
                                    <label class="visually-hidden" for="hero-search-input">Tìm kiếm sản phẩm</label>
                                    <input id="hero-search-input" class="form-control form-control-lg" type="search" name="keyword" placeholder="Tìm kiếm iPhone, MacBook, AirPods...">
                                    <button class="btn btn-app-primary btn-lg px-4" type="submit">Tìm kiếm</button>
                                </form>
                            </div>

                            <div class="hero-actions">
                                <a class="btn btn-app-primary btn-lg" href="${ctx}/products">Mua sắm sản phẩm</a>
                            </div>
                        </div>
                        <div class="hero-visual">
                            <div class="hero-panel store-hero-panel">
                                <div class="hero-panel-top">
                                    <span class="hero-chip">Sản phẩm nổi bật</span>
                                    <span class="hero-chip hero-chip-muted">Bản 256GB từ $1,149</span>
                                </div>
                                <img src="${ctx}/assets/images/device-hero.svg" alt="Sản phẩm Apple nổi bật">
                                <div class="hero-panel-foot">
                                    <div>
                                        <small>Tiêu điểm</small>
                                        <strong>Dòng iPhone 16 Pro</strong>
                                    </div>
                                    <div>
                                        <small>Gói combo</small>
                                        <strong>Thu cũ đổi mới + Hỗ trợ siêu tốc</strong>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Danh mục -->
            <section class="section-block">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">Duyệt theo danh mục</span>
                            <h2>Khám phá các dòng sản phẩm Apple</h2>
                        </div>
                        <p>Dễ dàng tìm kiếm những thiết bị phù hợp nhất với nhu cầu cá nhân của bạn.</p>
                    </div>
                    <div class="row g-4">
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${ctx}/products?category=iphone">
                                <span class="category-showcase-icon">iPhone</span>
                                <h3>iPhone</h3>
                                <p>Các mẫu cao cấp, phiên bản Pro và sự lựa chọn hoàn hảo cho nhu cầu hàng ngày.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${ctx}/products?category=mac">
                                <span class="category-showcase-icon">Mac</span>
                                <h3>Mac</h3>
                                <p>MacBook Air, MacBook Pro và máy tính bàn cho học tập và công việc sáng tạo.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${ctx}/products?category=ipad">
                                <span class="category-showcase-icon">iPad</span>
                                <h3>iPad</h3>
                                <p>Máy tính bảng di động tiện dụng để ghi chú, phác thảo, giải trí và làm việc văn phòng.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${ctx}/products?category=watch">
                                <span class="category-showcase-icon">Đồng hồ</span>
                                <h3>Apple Watch</h3>
                                <p>Theo dõi thể thao, nhận thông báo và sở hữu thiết kế đồng hồ thông minh cao cấp.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${ctx}/products?category=airpods">
                                <span class="category-showcase-icon">Âm thanh</span>
                                <h3>AirPods</h3>
                                <p>Dòng sản phẩm âm thanh không dây hoàn hảo cho việc đi lại, nghe gọi và tập trung.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${ctx}/products?category=accessories">
                                <span class="category-showcase-icon">Phụ kiện</span>
                                <h3>Phụ kiện</h3>
                                <p>Ốp lưng, cáp sạc, giá đỡ và các tiện ích bổ sung làm hoàn thiện thiết bị của bạn.</p>
                            </a>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Sản phẩm nổi bật -->
            <section class="section-block section-soft">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">Sản phẩm nổi bật</span>
                            <h2>Các sản phẩm đáng chú ý nhất trên cửa hàng</h2>
                        </div>
                        <a class="btn btn-app-outline" href="${ctx}/products">Xem tất cả sản phẩm</a>
                    </div>
                    <div class="row g-4">
                        <c:forEach var="p" items="${featuredList}">
                            <div class="col-md-6 col-xl-3">
                                <article class="product-card">
                                    <div class="product-card-media">
                                        <span class="app-badge badge-sale">-8%</span>
                                        <img src="${not empty p.primaryImageUrl ? 
                                                    ctx.concat('/').concat(p.primaryImageUrl) : 
                                                    ctx.concat('/assets/images/iphone-card.svg')}" 
                                             alt="${p.name}">
                                    </div>
                                    <div class="product-card-body">
                                        <div class="product-meta">
                                            <span class="status-badge ${p.totalStock > 0 ? 
                                                                        'status-in-stock' : 'status-low-stock'}">
                                                      ${p.totalStock > 0 ? 'Còn hàng' : 'Hết hàng'}
                                                  </span>
                                                  <button class="wishlist-button" type="button">Lưu</button>
                                            </div>
                                            <h3>${p.name}</h3>
                                            <div class="product-price">
                                                <strong><fmt:formatNumber value="${p.minPrice}" 
                                                                  type="currency" currencySymbol="$" maxFractionDigits="0"/></strong>
                                            </div>
                                            <!-- Nút xem chi tiết và thêm vào giỏ ... -->
                                            <div class="product-actions">
                                                <a class="btn btn-app-outline w-100" href="${ctx}/product?id=${p.productId}">Xem chi tiết</a>
                                                <form action="${ctx}/cart" method="post" class="w-100">
                                                    <input type="hidden" name="action" value="add">
                                                    <input type="hidden" name="productId" value="${p.productId}">
                                                    <input type="hidden" name="quantity" value="1">
                                                    <button class="btn btn-app-primary w-100" type="submit">Thêm vào giỏ</button>
                                                </form>
                                            </div>
                                        </div>
                                    </article>
                                </div>
                            </c:forEach>
                        </div>
                </section>

                <!-- Khuyến mãi -->
                <section class="section-block">
                    <div class="container">
                        <div class="promo-banner">
                            <div class="promo-banner-copy">
                                <span class="eyebrow">Chương trình khuyến mãi</span>
                                <h2>Thu cũ đổi mới - Tiết kiệm nhiều hơn cho thiết bị tiếp theo.</h2>
                                <p>
                                    Khám phá các ưu đãi đặc biệt, chương trình thu cũ đổi mới, tuần lễ ra mắt và các chính sách trả góp nổi bật.
                                </p>
                                <div class="hero-actions">
                                    <a class="btn btn-app-primary" href="${ctx}/products">Khám phá ưu đãi</a>
                                    <a class="btn btn-app-outline" href="${ctx}/product?id=1">Xem sản phẩm nổi bật</a>
                                </div>
                            </div>
                            <div class="promo-banner-stats">
                                <div class="promo-stat-card">
                                    <small>Tuần lễ ra mắt</small>
                                    <strong>Giảm tới 10%</strong>
                                    <span>cho các sản phẩm Apple chọn lọc</span>
                                </div>
                                <div class="promo-stat-card">
                                    <small>Hỗ trợ</small>
                                    <strong>Giao hàng siêu tốc</strong>
                                    <span>và tư vấn tận tình</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </section>

                <!-- Sản phẩm mới -->
                <section class="section-block section-soft">
                    <div class="container">
                        <div class="section-heading">
                            <div>
                                <span class="eyebrow">Sản phẩm mới</span>
                                <h2>Những thiết bị Apple mới nhất vừa lên kệ</h2>
                            </div>
                            <p>Cập nhật ngay những xu hướng và công nghệ mới nhất từ Apple.</p>
                        </div>
                        <div class="row g-4">
                            <c:forEach var="p" items="${newList}">
                                <div class="col-md-6 col-xl-3">
                                    <a href="${ctx}/product?id=${p.productId}" class="text-decoration-none text-dark d-block h-100">
                                        <article class="spotlight-card h-100">
                                            <img src="${not empty p.primaryImageUrl ? ctx.concat('/').concat(p.primaryImageUrl) : ctx.concat('/assets/images/mac-card.svg')}" alt="${p.name}">
                                            <div>
                                                <h3>${p.name}</h3>
                                                <!-- Hiển thị mô tả ngắn, nếu mô tả quá dài thì tuỳ vào CSS của bạn có thể cắt bớt -->
                                                <p>${p.description}</p>
                                            </div>
                                        </article>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </section>

                <!-- Sản phẩm bán chạy -->
                <section class="section-block">
                    <div class="container">
                        <div class="section-heading">
                            <div>
                                <span class="eyebrow">Sản phẩm bán chạy</span>
                                <h2>Các thiết bị được khách hàng ưa chuộng nhất</h2>
                            </div>
                            <p>Những sản phẩm hiệu năng cao bạn không nên bỏ lỡ tại cửa hàng của chúng tôi.</p>
                        </div>
                        <div class="row g-4">
                            <c:forEach var="p" items="${bestSellerList}" varStatus="status">
                                <div class="col-lg-4">
                                    <a href="${ctx}/product?id=${p.productId}" class="text-decoration-none text-dark d-block h-100">
                                        <article class="best-seller-card h-100">
                                            <!-- Tự động sinh số thứ hạng: 01, 02, 03... -->
                                            <div class="best-seller-rank">0${status.count}</div>

                                            <div>
                                                <h3>${p.name}</h3>
                                                <p>${p.description}</p>
                                            </div>

                                            <!-- Giá tiền minPrice -->
                                            <strong><fmt:formatNumber value="${p.minPrice}" type="currency" currencySymbol="$" maxFractionDigits="0"/></strong>
                                        </article>
                                    </a>
                                </div>
                            </c:forEach>
                        </div>
                    </div>
                </section>

                <!-- Lợi ích -->
                <section class="section-block section-soft">
                    <div class="container">
                        <div class="section-heading">
                            <div>
                                <span class="eyebrow">Tiện ích và Dịch vụ</span>
                                <h2>Cam kết chất lượng mang đến sự an tâm cho khách hàng</h2>
                            </div>
                            <p>Trải nghiệm dịch vụ và sự hỗ trợ đẳng cấp tại cửa hàng Apple trực tuyến.</p>
                        </div>
                        <div class="row g-4">
                            <div class="col-md-6 col-xl-3">
                                <article class="service-card">
                                    <h3>Tư vấn sản phẩm</h3>
                                    <p>Hỗ trợ khách hàng lựa chọn thiết bị Apple phù hợp nhất để học tập, làm việc hay sáng tạo.</p>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-3">
                                <article class="service-card">
                                    <h3>Đóng gói cẩn thận</h3>
                                    <p>Các sản phẩm cao cấp được đóng gói và vận chuyển với tiêu chuẩn an toàn cao nhất.</p>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-3">
                                <article class="service-card">
                                    <h3>Bảo hành & Hỗ trợ</h3>
                                    <p>Hỗ trợ kỹ thuật 24/7 và áp dụng chính sách bảo hành chính hãng chuẩn Apple trên toàn quốc.</p>
                                </article>
                            </div>
                            <div class="col-md-6 col-xl-3">
                                <article class="service-card">
                                    <h3>Sẵn sàng thu cũ đổi mới</h3>
                                    <p>Cung cấp chính sách định giá linh hoạt, trả góp 0% hoặc trợ giá đặc biệt khi nâng cấp máy.</p>
                                </article>
                            </div>
                        </div>
                    </div>
                </section>
            </main>

            <!-- Footer trang -->
            <footer class="site-footer">
                <div class="container footer-grid">
                    <div>
                        <a class="brand brand-footer" href="${ctx}/index.jsp">
                            <img src="${ctx}/assets/images/logo-mark.svg" alt="Biểu tượng AOS">
                            <span>
                                <strong>Cửa hàng AOS</strong>
                                <small>Trang chủ</small>
                            </span>
                        </a>
                        <p class="footer-copy">
                            Giao diện Cửa hàng trực tuyến Apple dành cho dự án Java Web sử dụng HTML, CSS, Bootstrap 5 và JavaScript thuần.
                        </p>
                    </div>
                    <div>
                        <h3 class="footer-title">Khám phá</h3>
                        <ul class="footer-links">
                            <li><a href="${ctx}/products">Tất cả sản phẩm</a></li>
                            <li><a href="${ctx}/products?category=iphone">iPhone</a></li>
                            <li><a href="${ctx}/products?category=mac">Mac</a></li>
                            <li><a href="${ctx}/about.html">Giới thiệu về chúng tôi</a></li>
                        </ul>
                    </div>
                    <div>
                        <h3 class="footer-title">Chính sách</h3>
                        <ul class="footer-links">
                            <li><a href="${ctx}/privacy.html">Chính sách bảo mật</a></li>
                            <li><a href="${ctx}/refund.html">Đổi trả & Hoàn tiền</a></li>
                            <li><a href="${ctx}/shipping.html">Quy trình giao nhận</a></li>
                            <li><a href="${ctx}/support.html">Hướng dẫn & Hỗ trợ</a></li>
                        </ul>
                    </div>
                    <div>
                        <h3 class="footer-title">Liên hệ</h3>
                        <ul class="footer-links">
                            <li>Địa chỉ: Tầng 12, Toà nhà FPT, Khu CNC Hoà Lạc, Hà Nội</li>
                            <li>Hotline: <strong>1900 8198</strong> (8:00–22:00)</li>
                            <li>Email: support@applestore.com</li>
                        </ul>
                    </div>
                </div>
                <div class="container footer-bottom">
                    <small>&copy; <span data-current-year></span> AppleStore. Tất cả các quyền được bảo lưu.</small>
                </div>
            </footer>

            <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
            <script src="${ctx}/assets/js/main.js"></script>
        </body>
    </html>
