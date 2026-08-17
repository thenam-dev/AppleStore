<%--
  login.jsp — đăng nhập.
  Servlet cần set: form{email}, errorMsg (sai email/mật khẩu), attemptsLeft
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
    <head>
        <c:set var="pageTitle" value="Đăng nhập · HALO"/>
        <jsp:include page="/WEB-INF/views/common/head.jsp"/>
    </head>
    <body>
        <jsp:include page="/WEB-INF/views/common/icons.jsp"/>

        <div style="min-height:100vh;display:flex;align-items:center;justify-content:center;background:var(--porcelain);padding:24px">
            <div class="frame" style="display:grid;grid-template-columns:.85fr 1.15fr;max-width:820px;width:100%;min-height:480px">
                <div style="background:var(--ink);color:#fff;padding:30px 24px;display:flex;flex-direction:column;justify-content:space-between">
                    <a href="${ctx}/index.jsp"><svg width="30" height="30" style="color:var(--titan)"><use href="#logo-halo"/></svg></a>
                    <div>
                        <h3 style="font-size:24px;text-transform:uppercase;color:#fff">Chào bạn quay lại</h3>
                        <p style="color:#AEB6C0;font-size:13px;margin:10px 0 0">
                            Đăng nhập để xem đơn hàng, mã giảm giá và danh sách yêu thích của bạn.
                        </p>
                    </div>
                    <div class="mono" style="font-size:10px;letter-spacing:.18em;color:#5C6470">HALO · ĐĂNG NHẬP</div>
                </div>

                <div style="padding:30px 26px">
                    <h2 style="font-size:22px;text-transform:uppercase;margin-bottom:20px">Đăng nhập</h2>

                    <jsp:include page="/WEB-INF/views/common/flash.jsp"/>
                    <c:if test="${not empty attemptsLeft}">
                        <p style="font-size:12px;color:var(--ash);margin-top:-8px;margin-bottom:16px">Bạn còn ${attemptsLeft} lần thử.</p>
                    </c:if>

                    <form method="post" action="${ctx}/login">
                        <input type="hidden" name="redirectTo" value="<c:out value='${param.redirectTo}'/>">
                        <div class="field">
                            <label>Email</label>
                            <input class="input" type="email" name="email" maxlength="100" required value="<c:out value='${form.email}'/>">
                        </div>
                        <div class="field">
                            <label>Mật khẩu</label>
                            <input class="input" type="password" name="password" required>
                        </div>
                        <div style="display:flex;align-items:center;gap:8px;margin-bottom:20px;font-size:13px">
                            <input type="checkbox" name="remember" id="rm" value="1">
                            <label for="rm" style="margin:0;font-weight:400">Ghi nhớ đăng nhập</label>
                        </div>
                        <button type="submit" class="btn block">Đăng nhập</button>
                    </form>
                    <p style="text-align:center;font-size:13px;color:var(--ash);margin:16px 0 0">
                        Chưa có tài khoản? <a href="${ctx}/register" style="color:var(--ink);border-bottom:1px solid var(--line)">Đăng ký ngay</a>
                    </p>
                </div>
            </div>
        </div>
    </body>
</html>
