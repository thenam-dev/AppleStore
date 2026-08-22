<%--
  change-password.jsp — đổi mật khẩu cho user đã đăng nhập.
  Servlet cần set: errors (Map lỗi từng ô: currentPassword/newPassword/confirmNewPassword)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Đổi mật khẩu · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
</head>
<body>

<c:set var="activeMenu" value="change-password" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main>
    <section class="sec">
        <div class="container inner">
            
            <div class="profile-container">
                <!-- Sidebar -->
                <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>

                <!-- Content -->
                <div class="profile-content">
                    <div style="margin-bottom: 32px;">
                        <h1 style="font-size: 24px; font-weight: 700; margin: 0 0 8px 0; color: var(--txt); display: flex; align-items: center; gap: 8px;">
                            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--titan);">
                                <rect x="3" y="11" width="18" height="11" rx="2" ry="2"></rect>
                                <path d="M7 11V7a5 5 0 0 1 10 0v4"></path>
                            </svg>
                            Đổi mật khẩu
                        </h1>
                        <p style="margin: 0; color: var(--txt-2); font-size: 14px;">Bảo vệ tài khoản của bạn bằng mật khẩu an toàn.</p>
                    </div>

                    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

                    <form method="post" action="${ctx}/change-password" style="max-width: 460px;">
                        <div class="field ${not empty errors.currentPassword ? 'err' : ''}">
                            <label>Mật khẩu hiện tại <span class="req">*</span></label>
                            <input class="input" type="password" name="currentPassword" required>
                            <c:if test="${not empty errors.currentPassword}">
                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.currentPassword}"/></div>
                            </c:if>
                        </div>

                        <div class="field ${not empty errors.newPassword ? 'err' : ''}">
                            <label>Mật khẩu mới <span class="req">*</span></label>
                            <input class="input" type="password" name="newPassword" required>
                            <c:choose>
                                <c:when test="${not empty errors.newPassword}">
                                    <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.newPassword}"/></div>
                                </c:when>
                                <c:otherwise><div class="help">Từ 8 ký tự, có chữ và số</div></c:otherwise>
                            </c:choose>
                        </div>

                        <div class="field ${not empty errors.confirmNewPassword ? 'err' : ''}">
                            <label>Xác nhận mật khẩu mới <span class="req">*</span></label>
                            <input class="input" type="password" name="confirmNewPassword" required>
                            <c:if test="${not empty errors.confirmNewPassword}">
                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.confirmNewPassword}"/></div>
                            </c:if>
                        </div>

                        <button type="submit" class="btn titan block" style="margin-top: 24px;">Đổi mật khẩu</button>
                    </form>
                </div>
            </div>
        </div>
    </section>
</main>
<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>