<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    </head>
    <body>
        <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:var(--porcelain);padding:24px">
            <div class="frame" style="max-width:460px;width:100%;padding:30px 26px">
                <h2>Quên mật khẩu</h2>
                <p style="color:var(--ash);font-size:13px;margin:0 0 20px">Nhập email của bạn để nhận mã OTP.</p>
                <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
                <form method="post" action="${ctx}/forgot-password">
                    <input type="hidden" name="action" value="verifyOtp">
                    <div class="field">
                        <label>Nhập mã 6 số từ Email</label>
                        <input class="input" type="text" name="otp" maxlength="6" required>
                    </div>
                    <button type="submit" class="btn block">Xác nhận</button>
                </form>
            </div>
        </div>
    </body>
</html>
