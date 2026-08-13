<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AppleStore | Đăng ký</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="${appPath}/assets/css/style.css">
    </head>
    <body class="site-body">
        <header class="site-header">
            <div class="topbar">
                <div class="container topbar-inner">
                    <p class="topbar-note">Tạo tài khoản để thanh toán nhanh hơn và theo dõi đơn hàng dễ hơn.</p>
                    <ul class="topbar-links">
                        <li><a href="${appPath}/index.jsp">Trang chủ</a></li>
                        <li><a href="${appPath}/login">Đăng nhập</a></li>
                        <li><a href="${appPath}/products.html">Sản phẩm</a></li>
                    </ul>
                </div>
            </div>
            <div class="container header-main">
                <a class="brand" href="${appPath}/index.jsp" aria-label="AppleStore">
                    <img src="${appPath}/assets/images/logo-mark.svg" alt="Biểu tượng AOS">
                    <span>
                        <strong>AppleStore</strong>
                        <small>Tạo tài khoản</small>
                    </span>
                </a>
                <form class="header-search" action="${appPath}/products.html" method="get" name="headerSearchForm">
                    <label class="visually-hidden" for="register-search-input">Tìm kiếm sản phẩm</label>
                    <input id="register-search-input" class="form-control" type="search" name="keyword" placeholder="Tìm kiếm sản phẩm">
                    <button class="btn btn-app-primary" type="submit">Tìm</button>
                </form>
                <div class="header-actions">
                    <a class="btn btn-app-outline" href="${appPath}/login">Đăng nhập</a>
                    <a class="cart-link" href="${appPath}/cart" aria-label="Xem giỏ hàng">
                        <span>Giỏ hàng</span>
                        <span class="cart-count">3</span>
                    </a>
                    <button class="mobile-menu-button" type="button" data-mobile-toggle aria-expanded="false" aria-label="Mở menu di động">
                        <span></span>
                        <span></span>
                        <span></span>
                    </button>
                </div>
            </div>
            <div class="mobile-drawer" data-mobile-panel>
                <div class="container mobile-drawer-inner">
                    <div class="mobile-links">
                        <a href="${appPath}/index.jsp">Trang chủ</a>
                        <a href="${appPath}/products.html">Sản phẩm</a>
                        <a href="${appPath}/login">Đăng nhập</a>
                        <a href="${appPath}/cart">Giỏ hàng</a>
                    </div>
                </div>
            </div>
        </header>

        <main>
            <section class="section-block auth-section">
                <div class="container">
                    <div class="auth-layout">
                        <div class="auth-showcase">
                            <span class="eyebrow">Tài khoản mới</span>
                            <h1>Tạo tài khoản khách hàng để quản lý hồ sơ, yêu thích và địa chỉ giao hàng.</h1>
                            <p>
                                Biểu mẫu này tạo tài khoản khách hàng thật qua Servlet và cơ sở dữ liệu,
                                đồng thời giữ trải nghiệm liền mạch với cửa hàng.
                            </p>
                            <div class="auth-benefit-list">
                                <div class="auth-benefit-item">
                                    <strong>Thanh toán nhanh hơn</strong>
                                    <span>Lưu thông tin một lần và dùng lại cho các đơn hàng sau.</span>
                                </div>
                                <div class="auth-benefit-item">
                                    <strong>Lịch sử đơn hàng</strong>
                                    <span>Xem lại giao dịch và trạng thái đơn hàng trong cùng một khu vực tài khoản.</span>
                                </div>
                                <div class="auth-benefit-item">
                                    <strong>Danh sách yêu thích</strong>
                                    <span>Lưu các sản phẩm Apple bạn muốn xem lại sau.</span>
                                </div>
                            </div>
                        </div>

                        <div class="auth-card">
                            <div class="auth-card-head">
                                <h2>Đăng ký</h2>
                                <p>Tạo hồ sơ khách hàng với các thông tin cần thiết cho tài khoản mới.</p>
                            </div>
                            <div class="auth-alert alert" data-auth-alert hidden></div>
                            <form action="${appPath}/register" method="post" name="registerForm" class="auth-form">
                                <div>
                                    <label class="form-label" for="register-fullname">Họ và tên</label>
                                    <input id="register-fullname" class="form-control" type="text" name="fullName" placeholder="Nguyen Van A" required maxlength="100">
                                </div>
                                <div>
                                    <label class="form-label" for="register-email">Email</label>
                                    <input id="register-email" class="form-control" type="email" name="email" placeholder="name@example.com" required>
                                </div>
                                <div>
                                    <label class="form-label" for="register-phone">Số điện thoại</label>
                                    <input id="register-phone" class="form-control" type="tel" name="phone" placeholder="0901234567" pattern="[0-9]{9,15}">
                                </div>
                                <div>
                                    <label class="form-label" for="register-password">Mật khẩu</label>
                                    <input id="register-password" class="form-control" type="password" name="password" placeholder="Tạo mật khẩu" required minlength="8">
                                </div>
                                <div>
                                    <label class="form-label" for="register-confirm-password">Xác nhận mật khẩu</label>
                                    <input id="register-confirm-password" class="form-control" type="password" name="confirmPassword" placeholder="Nhập lại mật khẩu" required minlength="8">
                                </div>
                                <button class="btn btn-app-primary btn-lg w-100" type="submit">Tạo tài khoản</button>
                            </form>
                            <div class="auth-footer-note">
                                <span>Đã có tài khoản?</span>
                                <a href="${appPath}/login">Đăng nhập tại đây</a>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <footer class="site-footer">
            <div class="container footer-bottom footer-bottom-single">
                <small>&copy; <span data-current-year></span> AppleStore. Màn hình đăng ký dành cho khách hàng.</small>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${appPath}/assets/js/main.js"></script>
    </body>
</html>
