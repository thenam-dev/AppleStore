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
        <!-- Site header -->
        <header class="site-header">
            <div class="container header-main">
                <a class="brand" href="${pageContext.request.contextPath}/index.jsp" aria-label="Apple Online Shop">
                    <img src="${pageContext.request.contextPath}/assets/images/logo-mark.svg" alt="AOS mark">
                    <span>
                        <strong>Cửa hàng AOS</strong>
                        <small>Giao diện Apple</small>
                    </span>
                </a>
                <c:if test="${not empty sessionScope.user and (sessionScope.user.role eq 'ADMIN' or sessionScope.user.role eq 'SALE_STAFF')}">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="btn btn-app-primary ms-auto me-3">
                        Vào trang Quản trị (Admin)
                    </a>
                </c:if>
                <div class="header-actions">
                    <div class="dropdown">
                        <button class="btn btn-app-ghost dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            Tài khoản
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end app-dropdown-menu">
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/login">Đăng nhập</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/register">Đăng ký</a></li>
                            <li><a class="dropdown-item" href="${pageContext.request.contextPath}/wishlist.html">Yêu thích</a></li>
                        </ul>
                    </div>
                    <a class="cart-link" href="${pageContext.request.contextPath}/cart" aria-label="View cart">
                        <span>Giỏ hàng</span>
                        <span class="cart-count">3</span>
                    </a>
                    <button class="mobile-menu-button" type="button" data-mobile-toggle aria-expanded="false" aria-label="Open mobile navigation">
                        <span></span>
                        <span></span>
                        <span></span>
                    </button>
                </div>
            </div>
            <nav class="category-nav">
                <div class="container category-nav-inner">
                    <a href="${pageContext.request.contextPath}/products.html?category=iphone">iPhone</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=mac">Mac</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=ipad">iPad</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=watch">Apple Watch</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=airpods">AirPods</a>
                    <a href="${pageContext.request.contextPath}/products.html?category=accessories">Phụ kiện</a>
                    <a href="${pageContext.request.contextPath}/products.html">Tất cả sản phẩm</a>
                </div>
            </nav>
            <div class="mobile-drawer" data-mobile-panel>
                <div class="container mobile-drawer-inner">
                    <form class="mobile-search" action="${pageContext.request.contextPath}/products.html" method="get" name="mobileSearchForm">
                        <label class="visually-hidden" for="mobile-search-input">Tìm kiếm sản phẩm</label>
                        <input id="mobile-search-input" class="form-control" type="search" name="keyword" placeholder="Tìm kiếm sản phẩm">
                    </form>
                    <div class="mobile-links">
                        <a href="${pageContext.request.contextPath}/products.html?category=iphone">iPhone</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=mac">Mac</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=ipad">iPad</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=watch">Apple Watch</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=airpods">AirPods</a>
                        <a href="${pageContext.request.contextPath}/products.html?category=accessories">Phụ kiện</a>
                        <a href="${pageContext.request.contextPath}/login">Đăng nhập</a>
                        <a href="${pageContext.request.contextPath}/register">Đăng ký</a>
                        <a href="${pageContext.request.contextPath}/wishlist.html">Yêu thích</a>
                        <a href="${pageContext.request.contextPath}/components/component-demo.html">Bản Demo</a>
                    </div>
                </div>
            </div>
        </header>

        <main>
            <!-- Home hero -->
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
                                <form class="hero-search d-flex gap-2" action="${pageContext.request.contextPath}/products.html" method="get" name="heroSearchForm">
                                    <label class="visually-hidden" for="hero-search-input">Tìm kiếm sản phẩm</label>
                                    <input id="hero-search-input" class="form-control form-control-lg" type="search" name="keyword" placeholder="Tìm kiếm iPhone, MacBook, AirPods...">
                                    <button class="btn btn-app-primary btn-lg px-4" type="submit">Tìm kiếm</button>
                                </form>
                            </div>

                            <div class="hero-actions">
                                <a class="btn btn-app-primary btn-lg" href="${pageContext.request.contextPath}/products.html">Mua sắm sản phẩm</a>
                            </div>
                        </div>
                        <div class="hero-visual">
                            <div class="hero-panel store-hero-panel">
                                <div class="hero-panel-top">
                                    <span class="hero-chip">Sản phẩm nổi bật</span>
                                    <span class="hero-chip hero-chip-muted">Bản 256GB từ $1,149</span>
                                </div>
                                <img src="${pageContext.request.contextPath}/assets/images/device-hero.svg" alt="Apple storefront spotlight">
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

            <!-- Categories -->
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
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=iphone">
                                <span class="category-showcase-icon">iPhone</span>
                                <h3>iPhone</h3>
                                <p>Các mẫu cao cấp, phiên bản Pro và sự lựa chọn hoàn hảo cho nhu cầu hàng ngày.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=mac">
                                <span class="category-showcase-icon">Mac</span>
                                <h3>Mac</h3>
                                <p>MacBook Air, MacBook Pro và máy tính bàn cho học tập và công việc sáng tạo.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=ipad">
                                <span class="category-showcase-icon">iPad</span>
                                <h3>iPad</h3>
                                <p>Máy tính bảng di động tiện dụng để ghi chú, phác thảo, giải trí và làm việc văn phòng.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=watch">
                                <span class="category-showcase-icon">Đồng hồ</span>
                                <h3>Apple Watch</h3>
                                <p>Theo dõi thể thao, nhận thông báo và sở hữu thiết kế đồng hồ thông minh cao cấp.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=airpods">
                                <span class="category-showcase-icon">Âm thanh</span>
                                <h3>AirPods</h3>
                                <p>Dòng sản phẩm âm thanh không dây hoàn hảo cho việc đi lại, nghe gọi và tập trung.</p>
                            </a>
                        </div>
                        <div class="col-md-6 col-xl-4">
                            <a class="category-showcase-card" href="${pageContext.request.contextPath}/products.html?category=accessories">
                                <span class="category-showcase-icon">Phụ kiện</span>
                                <h3>Phụ kiện</h3>
                                <p>Ốp lưng, cáp sạc, giá đỡ và các tiện ích bổ sung làm hoàn thiện thiết bị của bạn.</p>
                            </a>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Featured products -->
            <section class="section-block section-soft">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">Sản phẩm nổi bật</span>
                            <h2>Các sản phẩm đáng chú ý nhất trên cửa hàng</h2>
                        </div>
                        <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/products.html">Xem tất cả sản phẩm</a>
                    </div>
                    <div class="row g-4">
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <span class="app-badge badge-sale">-8%</span>
                                    <img src="${pageContext.request.contextPath}/assets/images/iphone-card.svg" alt="iPhone 16 Pro">
                                </div>
                                <div class="product-card-body">
                                    <div class="product-meta">
                                        <span class="status-badge status-in-stock">Còn hàng</span>
                                        <button class="wishlist-button" type="button">Lưu</button>
                                    </div>
                                    <h3>iPhone 16 Pro</h3>
                                    <p>256GB / Titan Tự nhiên</p>
                                    <div class="product-price">
                                        <strong>$1,149</strong>
                                        <span>$1,249</span>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-outline w-100" href="${pageContext.request.contextPath}/product-detail.html">Xem chi tiết</a>
                                        <button class="btn btn-app-primary w-100" type="button">Thêm vào giỏ</button>
                                    </div>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <span class="app-badge badge-new">Mới</span>
                                    <img src="${pageContext.request.contextPath}/assets/images/mac-card.svg" alt="MacBook Air M4">
                                </div>
                                <div class="product-card-body">
                                    <div class="product-meta">
                                        <span class="status-badge status-low-stock">Sắp hết hàng</span>
                                        <button class="wishlist-button" type="button">Lưu</button>
                                    </div>
                                    <h3>MacBook Air M4</h3>
                                    <p>13-inch / 16GB / 512GB</p>
                                    <div class="product-price">
                                        <strong>$1,399</strong>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-outline w-100" href="${pageContext.request.contextPath}/product-detail.html">Xem chi tiết</a>
                                        <button class="btn btn-app-primary w-100" type="button">Thêm vào giỏ</button>
                                    </div>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <img src="${pageContext.request.contextPath}/assets/images/watch-card.svg" alt="Apple Watch Series 11">
                                </div>
                                <div class="product-card-body">
                                    <div class="product-meta">
                                        <span class="status-badge status-in-stock">Còn hàng</span>
                                        <button class="wishlist-button" type="button">Lưu</button>
                                    </div>
                                    <h3>Apple Watch Series 11</h3>
                                    <p>46mm / Dây Midnight Sport</p>
                                    <div class="product-price">
                                        <strong>$479</strong>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-outline w-100" href="${pageContext.request.contextPath}/product-detail.html">Xem chi tiết</a>
                                        <button class="btn btn-app-primary w-100" type="button">Thêm vào giỏ</button>
                                    </div>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="product-card">
                                <div class="product-card-media">
                                    <span class="app-badge badge-sale">Combo</span>
                                    <img src="${pageContext.request.contextPath}/assets/images/iphone-card.svg" alt="AirPods Pro 3">
                                </div>
                                <div class="product-card-body">
                                    <div class="product-meta">
                                        <span class="status-badge status-in-stock">Còn hàng</span>
                                        <button class="wishlist-button" type="button">Lưu</button>
                                    </div>
                                    <h3>AirPods Pro 3</h3>
                                    <p>USB-C / Chống ồn chủ động</p>
                                    <div class="product-price">
                                        <strong>$289</strong>
                                        <span>$329</span>
                                    </div>
                                    <div class="product-actions">
                                        <a class="btn btn-app-outline w-100" href="${pageContext.request.contextPath}/product-detail.html">Xem chi tiết</a>
                                        <button class="btn btn-app-primary w-100" type="button">Thêm vào giỏ</button>
                                    </div>
                                </div>
                            </article>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Promotion -->
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
                                <a class="btn btn-app-primary" href="${pageContext.request.contextPath}/products.html">Khám phá ưu đãi</a>
                                <a class="btn btn-app-outline" href="${pageContext.request.contextPath}/product-detail.html">Xem sản phẩm nổi bật</a>
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

            <!-- New arrivals -->
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
                        <div class="col-md-6 col-xl-3">
                            <article class="spotlight-card">
                                <img src="${pageContext.request.contextPath}/assets/images/mac-card.svg" alt="Mac mini M4">
                                <div>
                                    <h3>Mac mini M4</h3>
                                    <p>Máy tính bàn hiệu năng cao vô cùng nhỏ gọn, hoàn hảo cho lập trình và thiết kế.</p>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="spotlight-card">
                                <img src="${pageContext.request.contextPath}/assets/images/watch-card.svg" alt="Apple Watch Ultra">
                                <div>
                                    <h3>Apple Watch Ultra</h3>
                                    <p>Đồng hồ thể thao ngoài trời với thiết kế bền bỉ cực kỳ cao cấp.</p>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="spotlight-card">
                                <img src="${pageContext.request.contextPath}/assets/images/iphone-card.svg" alt="iPad Air">
                                <div>
                                    <h3>iPad Air</h3>
                                    <p>Màn hình di động mỏng nhẹ, lý tưởng cho việc học tập, làm việc và giải trí.</p>
                                </div>
                            </article>
                        </div>
                        <div class="col-md-6 col-xl-3">
                            <article class="spotlight-card">
                                <img src="${pageContext.request.contextPath}/assets/images/iphone-card.svg" alt="MagSafe Duo Kit">
                                <div>
                                    <h3>Bộ sạc MagSafe Duo</h3>
                                    <p>Gói phụ kiện sạc tiện lợi, thường được bán kèm trong các đợt khuyến mãi.</p>
                                </div>
                            </article>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Best sellers -->
            <section class="section-block">
                <div class="container">
                    <div class="section-heading">
                        <div>
                            <span class="eyebrow">Sản phẩm bán chạy</span>
                            <h2>Các thiết bị được khách hàng ưa chuộng nhất</h2>
                        </div>
                        <p>Top những sản phẩm hiệu năng cao bạn không nên bỏ lỡ tại cửa hàng của chúng tôi.</p>
                    </div>
                    <div class="row g-4">
                        <div class="col-lg-4">
                            <article class="best-seller-card">
                                <div class="best-seller-rank">01</div>
                                <div>
                                    <h3>iPhone 16 Pro Max</h3>
                                    <p>Mẫu flagship bán chạy nhất với kích thước lớn và hiệu suất đỉnh cao.</p>
                                </div>
                                <strong>$1,349</strong>
                            </article>
                        </div>
                        <div class="col-lg-4">
                            <article class="best-seller-card">
                                <div class="best-seller-rank">02</div>
                                <div>
                                    <h3>MacBook Air M4</h3>
                                    <p>Sản phẩm đáng tin cậy dành cho học sinh, sinh viên và dân văn phòng.</p>
                                </div>
                                <strong>$1,399</strong>
                            </article>
                        </div>
                        <div class="col-lg-4">
                            <article class="best-seller-card">
                                <div class="best-seller-rank">03</div>
                                <div>
                                    <h3>AirPods Pro 3</h3>
                                    <p>Phụ kiện âm thanh tuyệt vời, lượng mua cao và thường được đi kèm với iPhone.</p>
                                </div>
                                <strong>$289</strong>
                            </article>
                        </div>
                    </div>
                </div>
            </section>

            <!-- Benefits -->
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

        <!-- Site footer -->
        <footer class="site-footer">
            <div class="container footer-grid">
                <div>
                    <a class="brand brand-footer" href="${pageContext.request.contextPath}/index.jsp">
                        <img src="${pageContext.request.contextPath}/assets/images/logo-mark.svg" alt="AOS mark">
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
                        <li><a href="${pageContext.request.contextPath}/products.html">Tất cả sản phẩm</a></li>
                        <li><a href="${pageContext.request.contextPath}/products.html?category=iphone">iPhone</a></li>
                        <li><a href="${pageContext.request.contextPath}/products.html?category=mac">Mac</a></li>
                        <li><a href="${pageContext.request.contextPath}/about.html">Giới thiệu về chúng tôi</a></li>
                    </ul>
                </div>
                <div>
                    <h3 class="footer-title">Chính sách</h3>
                    <ul class="footer-links">
                        <li><a href="${pageContext.request.contextPath}/privacy.html">Chính sách bảo mật</a></li>
                        <li><a href="${pageContext.request.contextPath}/refund.html">Đổi trả & Hoàn tiền</a></li>
                        <li><a href="${pageContext.request.contextPath}/shipping.html">Quy trình giao nhận</a></li>
                        <li><a href="${pageContext.request.contextPath}/support.html">Hướng dẫn & Hỗ trợ</a></li>
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
                <small>&copy; <span data-current-year></span> Apple Store. Tất cả các quyền được bảo lưu.</small>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${pageContext.request.contextPath}/assets/js/main.js"></script>
    </body>
</html>
