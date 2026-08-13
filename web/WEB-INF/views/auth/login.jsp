<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AppleStore | Đăng nhập</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="${appPath}/assets/css/style.css">
    </head>
    <body class="site-body">
        <header class="site-header">
            <div class="container header-main">
                <a class="brand" href="${appPath}/index.jsp" aria-label="AppleStore">
                    <img src="${appPath}/assets/images/logo-mark.svg" alt="AppleStore mark">
                    <span>
                        <strong>AppleStore</strong>
                        <small>Đăng nhập tài khoản</small>
                    </span>
                </a>
                <div class="header-actions">
                    <a class="btn btn-app-ghost" href="${appPath}/index.jsp">Trang chủ</a>
                    <a class="btn btn-app-outline" href="${appPath}/register">Đăng ký</a>
                </div>
            </div>
        </header>

        <main>
            <section class="section-block auth-section">
                <div class="container">
                    <div class="row justify-content-center">
                        <div class="col-12 col-lg-6 col-xl-5">
                            <div class="auth-card">
                                <div class="auth-card-head">
                                    <h2>Đăng nhập</h2>
                                    <p>Dùng email và mật khẩu để tiếp tục.</p>
                                </div>
                                <div class="auth-alert alert" data-auth-alert hidden></div>
                                <form action="${appPath}/login" method="post" name="loginForm" class="auth-form">
                                    <input type="hidden" name="redirectTo" id="login-redirect-target" value="">
                                    <div>
                                        <label class="form-label" for="login-email">Email</label>
                                        <input id="login-email" class="form-control" type="email" name="email"
                                               placeholder="name@example.com" required>
                                    </div>
                                    <div>
                                        <label class="form-label" for="login-password">Mật khẩu</label>
                                        <input id="login-password" class="form-control" type="password" name="password"
                                               placeholder="Nhập mật khẩu" required>
                                    </div>
                                    <div class="auth-inline-row">
                                        <div class="form-check app-check">
                                            <input class="form-check-input" type="checkbox" value="1" id="remember-me" name="rememberMe">
                                            <label class="form-check-label" for="remember-me">Ghi nhớ đăng nhập</label>
                                        </div>
                                    </div>
                                    <button class="btn btn-app-primary btn-lg w-100" type="submit">Đăng nhập</button>
                                </form>
                                <div class="auth-footer-note">
                                    <span>Chưa có tài khoản?</span>
                                    <a href="${appPath}/register">Tạo tài khoản</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <footer class="site-footer">
            <div class="container footer-bottom footer-bottom-single">
                <small>&copy; <span data-current-year></span> AppleStore.</small>
            </div>
        </footer>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${appPath}/assets/js/main.js"></script>
    </body>
</html>
