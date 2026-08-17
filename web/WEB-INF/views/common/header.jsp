<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<header class="site-header">
    <div class="topbar">
        <div class="container topbar-inner">
            <p class="topbar-note">Mua sắm Apple trực tuyến với giỏ hàng và thanh toán dành cho khách hàng.</p>
            <ul class="topbar-links">
                <li><a href="${appPath}/index.jsp">Trang chủ</a></li>
                <li><a href="${appPath}/products">Sản phẩm</a></li>
                <c:choose>
                    <c:when test="${empty sessionScope.user}">
                        <li><a href="${appPath}/login">Đăng nhập</a></li>
                        <li><a href="${appPath}/register">Đăng ký</a></li>
                    </c:when>
                    <c:otherwise>
                        <li><a href="${appPath}/cart">Giỏ hàng</a></li>
                        <li><a href="${appPath}/logout">Đăng xuất</a></li>
                    </c:otherwise>
                </c:choose>
            </ul>
        </div>
    </div>
    <div class="container header-main">
        <a class="brand" href="${appPath}/index.jsp" aria-label="AppleStore">
            <img src="${appPath}/assets/images/logo-mark.svg" alt="Biểu tượng AOS">
            <span>
                <strong>Cửa hàng AOS</strong>
                <small>Cửa hàng trực tuyến</small>
            </span>
        </a>
        <form class="header-search" action="${appPath}/products" method="get" name="headerSearchForm">
            <label class="visually-hidden" for="shared-header-search-input">Tìm kiếm sản phẩm</label>
            <input id="shared-header-search-input" class="form-control" type="search" name="keyword" placeholder="Tìm kiếm sản phẩm">
            <button class="btn btn-app-primary" type="submit">Tìm</button>
        </form>
        <div class="header-actions">
            <c:if test="${not empty sessionScope.user and (sessionScope.user.role eq 'ADMIN' or sessionScope.user.role eq 'SALE_STAFF')}">
                <a href="${appPath}/admin/dashboard" class="btn btn-app-primary btn-sm">Vào quản trị</a>
            </c:if>
            <c:choose>
                <c:when test="${empty sessionScope.user}">
                    <a class="btn btn-app-outline" href="${appPath}/login">Đăng nhập</a>
                    <a class="btn btn-app-primary" href="${appPath}/register">Đăng ký</a>
                </c:when>
                <c:otherwise>
                    <div class="dropdown">
                        <button class="btn btn-app-ghost dropdown-toggle" type="button" data-bs-toggle="dropdown" aria-expanded="false">
                            ${sessionScope.user.fullName != null ? sessionScope.user.fullName : sessionScope.user.email}
                        </button>
                        <ul class="dropdown-menu dropdown-menu-end app-dropdown-menu">
                            <li><a class="dropdown-item" href="${appPath}/change-password">Đổi mật khẩu</a></li>
                            <li><a class="dropdown-item" href="${appPath}/logout">Đăng xuất</a></li>
                        </ul>
                    </div>
                </c:otherwise>
            </c:choose>
            <a class="cart-link" href="${appPath}/cart" aria-label="Xem giỏ hàng">
                <span>Giỏ hàng</span>
                <span class="cart-count">${requestScope.cartItemCount != null ? requestScope.cartItemCount : 0}</span>
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
                <a href="${appPath}/products">Sản phẩm</a>
                <a href="${appPath}/cart">Giỏ hàng</a>
                <c:choose>
                    <c:when test="${empty sessionScope.user}">
                        <a href="${appPath}/login">Đăng nhập</a>
                        <a href="${appPath}/register">Đăng ký</a>
                    </c:when>
                    <c:otherwise>
                        <a href="${appPath}/logout">Đăng xuất</a>
                    </c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>
</header>
