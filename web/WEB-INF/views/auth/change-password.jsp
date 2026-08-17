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
        <c:set var="pageTitle" value="Đổi mật khẩu · HALO"/>
        <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    </head>
    <body>
        <jsp:include page="/WEB-INF/views/common/icons.jsp"/>

        <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:var(--porcelain);padding:24px">
            <div class="frame" style="max-width:460px;width:100%;padding:30px 26px">
                <a href="${ctx}/index.jsp" style="display:flex;align-items:center;gap:9px;margin-bottom:22px">
                    <svg width="26" height="26" style="color:var(--titan)"><use href="#logo-halo"/></svg>
                    <span style="font-family:var(--display);font-weight:800;font-stretch:118%;letter-spacing:.18em;font-size:15px">HALO</span>
                </a>

                <h2 style="font-size:22px;text-transform:uppercase;margin-bottom:6px">Đổi mật khẩu</h2>
                <p style="color:var(--ash);font-size:13px;margin:0 0 20px">Nhập mật khẩu hiện tại và mật khẩu mới của bạn.</p>

                <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

                <form method="post" action="${ctx}/change-password">
                    <div class="field ${not empty errors.currentPassword ? 'err' : ''}">
                        <label>Mật khẩu hiện tại <span class="req">*</span></label>
                        <input class="input" type="password" name="currentPassword">
                        <c:if test="${not empty errors.currentPassword}">
                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.currentPassword}"/></div>
                            </c:if>
                    </div>

                    <div class="field ${not empty errors.newPassword ? 'err' : ''}">
                        <label>Mật khẩu mới <span class="req">*</span></label>
                        <input class="input" type="password" name="newPassword">
                        <c:choose>
                            <c:when test="${not empty errors.newPassword}">
                                <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.newPassword}"/></div>
                                </c:when>
                                <c:otherwise><div class="help">Từ 8 ký tự, có chữ và số</div></c:otherwise>
                        </c:choose>
                    </div>

                    <div class="field ${not empty errors.confirmNewPassword ? 'err' : ''}">
                        <label>Xác nhận mật khẩu mới <span class="req">*</span></label>
                        <input class="input" type="password" name="confirmNewPassword">
                        <c:if test="${not empty errors.confirmNewPassword}">
                            <div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.confirmNewPassword}"/></div>
                            </c:if>
                    </div>

                    <button type="submit" class="btn titan block">Đổi mật khẩu</button>
                </form>
                <p style="text-align:center;font-size:13px;color:var(--ash);margin:16px 0 0">
                    <a href="${ctx}/index.jsp" style="color:var(--ink);border-bottom:1px solid var(--line)">Về trang chủ</a>
                </p>
            </div>
        </div>
    </body>
</html>
