<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>AppleStore | Đổi mật khẩu</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="${appPath}/assets/css/style.css">
    </head>
    <body class="site-body">
        <jsp:include page="/WEB-INF/views/common/header.jsp"/>

        <main>
            <section class="section-block auth-section">
                <div class="container">
                    <div class="row justify-content-center">
                        <div class="col-12 col-lg-6 col-xl-5">
                            <div class="auth-card">
                                <div class="auth-card-head">
                                    <h2>Đổi mật khẩu</h2>
                                    <p>Nhập mật khẩu hiện tại và mật khẩu mới.</p>
                                </div>
                                <div class="auth-alert alert" data-auth-alert hidden></div>
                                <form action="${appPath}/change-password" method="post" name="changePasswordForm" class="auth-form">
                                    <div>
                                        <label class="form-label" for="current-password">Mật khẩu hiện tại</label>
                                        <input id="current-password" class="form-control" type="password" name="currentPassword"
                                               placeholder="Nhập mật khẩu hiện tại" required>
                                    </div>
                                    <div>
                                        <label class="form-label" for="new-password">Mật khẩu mới</label>
                                        <input id="new-password" class="form-control" type="password" name="newPassword"
                                               placeholder="Ít nhất 8 ký tự" minlength="8" required>
                                    </div>
                                    <div>
                                        <label class="form-label" for="confirm-new-password">Xác nhận mật khẩu mới</label>
                                        <input id="confirm-new-password" class="form-control" type="password" name="confirmNewPassword"
                                               placeholder="Nhập lại mật khẩu mới" minlength="8" required>
                                    </div>
                                    <button class="btn btn-app-primary btn-lg w-100" type="submit">Đổi mật khẩu</button>
                                </form>
                                <div class="auth-footer-note">
                                    <span>Muốn quay lại?</span>
                                    <a href="${appPath}/index.jsp">Về trang chủ</a>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

        <jsp:include page="/WEB-INF/views/common/footer.jsp"/>

        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="${appPath}/assets/js/main.js"></script>
    </body>
</html>
