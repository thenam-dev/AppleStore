<%--
  register.jsp — đăng ký.
  Servlet cần set: form{fullName,phone,email}, errors : Map lỗi từng ô
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <c:set var="pageTitle" value="Đăng ký · HALO"/>
        <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    </head>
    <body>
        <jsp:include page="/WEB-INF/views/common/icons.jsp"/>

        <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:var(--porcelain);padding:24px">
            <div class="frame" style="max-width:520px;width:100%;padding:30px 26px">
                <a href="${ctx}/index.jsp" style="display:flex;align-items:center;gap:9px;margin-bottom:22px">
                    <svg width="26" height="26" style="color:var(--titan)"><use href="#logo-halo"/></svg>
                    <span style="font-family:var(--display);font-weight:800;font-stretch:118%;letter-spacing:.18em;font-size:15px">HALO</span>
                </a>

                <h2 style="font-size:22px;text-transform:uppercase;margin-bottom:6px">Đăng ký</h2>
                <p style="color:var(--ash);font-size:13px;margin:0 0 20px">Tạo tài khoản để nhận mã giảm 500.000 ₫ cho đơn đầu tiên.</p>

                <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

                <form method="post" action="${ctx}/register">
                    <div class="grid-2">
                        <div class="field ${not empty errors.fullName ? 'err' : ''}">
                            <label>Họ và tên <span class="req">*</span></label>
                            <input class="input" type="text" name="fullName" maxlength="100" value="<c:out value='${form.fullName}'/>" required>
                            <c:if test="${not empty errors.fullName}">
                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.fullName}"/></div>
                                </c:if>
                        </div>
                        <div class="field ${not empty errors.phone ? 'err' : ''}">
                            <label>Số điện thoại <span class="req">*</span></label>
                            <input class="input" type="tel" name="phone" maxlength="10" value="<c:out value='${form.phone}'/>" required>
                            <c:if test="${not empty errors.phone}">
                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.phone}"/></div>
                                </c:if>
                        </div>
                    </div>

                    <div class="field ${not empty errors.email ? 'err' : ''}">
                        <label>Email <span class="req">*</span></label>
                        <input class="input" type="email" name="email" maxlength="100" value="<c:out value='${form.email}'/>" required>
                        <c:if test="${not empty errors.email}">
                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.email}"/></div>
                            </c:if>
                    </div>

                    <div class="grid-2">
                        <div class="field ${not empty errors.password ? 'err' : ''}">
                            <label>Mật khẩu <span class="req">*</span></label>
                            <input class="input" type="password" name="password" required>
                            <c:choose>
                                <c:when test="${not empty errors.password}">
                                    <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.password}"/></div>
                                    </c:when>
                                    <c:otherwise><div class="help">Từ 8 ký tự, có chữ và số</div></c:otherwise>
                            </c:choose>
                        </div>
                        <div class="field ${not empty errors.confirmPassword ? 'err' : ''}">
                            <label>Nhập lại mật khẩu <span class="req">*</span></label>
                            <input class="input" type="password" name="confirmPassword" required>
                            <c:if test="${not empty errors.confirmPassword}">
                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.confirmPassword}"/></div>
                                </c:if>
                        </div>
                    </div>

                    <div style="display:flex;gap:9px;align-items:flex-start;font-size:12.5px;color:var(--graphite);margin:4px 0 18px">
                        <input type="checkbox" name="agree" id="ag" value="1" required style="margin-top:2px">
                        <label for="ag" style="margin:0;font-weight:400">
                            Tôi đồng ý với <a href="${ctx}/page/terms" style="border-bottom:1px solid var(--line)">điều khoản sử dụng</a>
                            và <a href="${ctx}/page/privacy" style="border-bottom:1px solid var(--line)">chính sách bảo mật</a> của HALO.
                        </label>
                    </div>

                    <button type="submit" class="btn titan block">Tạo tài khoản</button>

                    <div style="display:flex; align-items:center; margin:24px 0 16px;">
                        <div style="flex-grow:1; height:1px; background:#e0e0e0;"></div>
                        <span style="padding:0 12px; color:#888; font-size:12px; font-weight:600;">HOẶC</span>
                        <div style="flex-grow:1; height:1px; background:#e0e0e0;"></div>
                    </div>

                    <a href="${ctx}/auth/google-login" class="btn block" style="background:#fff; color:#495057; border:1px solid #ced4da; display:flex; align-items:center; justify-content:center; gap:10px; font-weight:500;">
                        <img src="https://upload.wikimedia.org/wikipedia/commons/c/c1/Google_%22G%22_logo.svg" alt="Google Logo" width="18" height="18">
                        Đăng ký nhanh bằng Google
                    </a>
                </form>
                <p style="text-align:center;font-size:13px;color:var(--ash);margin:16px 0 0">
                    Đã có tài khoản? <a href="${ctx}/login" style="color:var(--ink);border-bottom:1px solid var(--line)">Đăng nhập</a>
                </p>
            </div>
        </div>
    </body>
</html>
