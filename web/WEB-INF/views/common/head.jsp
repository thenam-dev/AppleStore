<%--
  head.jsp — phần <head> dùng chung cho mọi trang.
  Cách dùng:
      <c:set var="pageTitle" value="Sản phẩm"/>
      <jsp:include page="/WEB-INF/views/common/head.jsp"/>
  Biến nhận vào (đều không bắt buộc):
      pageTitle : tiêu đề trang, mặc định "HALO"
      bodyClass : thêm class cho body, ví dụ "admin"
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title><c:out value="${empty pageTitle ? 'HALO · Đồ Apple chính hãng' : pageTitle}"/></title>
<link rel="icon" href="${pageContext.request.contextPath}/assets/img/favicon.svg" type="image/svg+xml">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
<link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/halo.css">
