<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Hồ sơ cá nhân · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
</head>
<body>

<c:set var="activeMenu" value="profile" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main>
    <section class="sec">
        <div class="container inner">
            
            <div class="profile-container">
                <!-- Sidebar được tách ra file riêng để tái sử dụng -->
                <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>

                <!-- Content (Form cập nhật) -->
                <div class="profile-content">
                    <div style="margin-bottom: 32px;">
                        <h1 style="font-size: 24px; font-weight: 700; margin: 0 0 8px 0; color: var(--txt); display: flex; align-items: center; gap: 8px;">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--titan);">
                                <path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"></path>
                                <circle cx="12" cy="7" r="4"></circle>
                            </svg>
                            Tài khoản cá nhân
                        </h1>
                        <p style="margin: 0; color: var(--txt-2); font-size: 14px;">Quản lý thông tin cá nhân và tài khoản của bạn.</p>
                    </div>

                    <!-- Alerts -->
                    <c:if test="${not empty requestScope.message}">
                        <div class="alert-msg success">
                            <strong>Thành công!</strong> ${requestScope.message}
                        </div>
                    </c:if>
                    <c:if test="${not empty requestScope.error}">
                        <div class="alert-msg error">
                            <strong>Lỗi!</strong> ${requestScope.error}
                        </div>
                    </c:if>

                    <!-- Form -->
                    <form action="${ctx}/update-profile" method="post" name="profileForm" style="max-width: 600px;">
                        <div class="form-grid">
                            <div class="form-group full">
                                <label>Họ và tên <span style="color: #d32f2f;">*</span></label>
                                <input class="input" type="text" name="fullName" value="${sessionScope.user.fullName}" required>
                            </div>

                            <div class="form-group full">
                                <label>Email (Chỉ đọc)</label>
                                <input class="input" type="email" name="email" value="${sessionScope.user.email}" readonly>
                                <small style="display: block; margin-top: 6px; color: var(--txt-3); font-size: 12px;">Email không thể thay đổi do liên kết với tài khoản đăng nhập.</small>
                            </div>

                            <div class="form-group full">
                                <label>Số điện thoại</label>
                                <input class="input" type="tel" name="phone" value="${sessionScope.user.phone}">
                            </div>

                            <div class="form-group full">
                                <label>Ảnh đại diện (URL)</label>
                                <input class="input" type="text" name="avatarUrl" value="${sessionScope.user.avatarUrl}" placeholder="https://...">
                            </div>
                        </div>

                        <div style="margin-top: 32px; padding-top: 24px; border-top: 1px solid var(--line); display: flex; justify-content: flex-end;">
                            <button class="btn titan" type="submit" style="padding: 12px 32px; font-size: 15px;">Lưu thay đổi</button>
                        </div>
                    </form>
                </div>
            </div>
            
        </div>
    </section>
</main>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
