<%--
  error/404.jsp — trang không tìm thấy.
  Khai báo trong web.xml: <error-page><error-code>404</error-code>
    <location>/WEB-INF/views/error/404.jsp</location></error-page>
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" isErrorPage="true" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Không tìm thấy trang · HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body>
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>
<c:set var="activeMenu" value="home"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<div class="frame dark" style="margin:26px;border-radius:var(--r-lg)">
  <div class="empty" style="color:#fff">
    <div class="ring" style="border-color:var(--line-d)"><span class="mono" style="color:var(--titan);font-size:13px">404</span></div>
    <h3 style="color:#fff">Không tìm thấy trang này</h3>
    <p style="color:#98A0AB">Đường dẫn có thể đã đổi hoặc sản phẩm đã ngừng bán.</p>
    <div style="display:flex;gap:9px;justify-content:center">
      <a class="btn titan" href="${ctx}/home">Về trang chủ</a>
      <a class="btn ghost" style="color:#fff;border-color:#2A313B" href="tel:19006868">Liên hệ 1900 6868</a>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>
</body>
</html>
