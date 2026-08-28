<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="breadcrumbAppPath" value="${pageContext.request.contextPath}" />

<c:if test="${not empty breadcrumbSection}">
  <nav class="crumb" aria-label="Breadcrumb">
    <a href="${breadcrumbAppPath}/admin/products">Sản phẩm</a>
    <span>/</span>
    <span style="color:var(--ink)"><c:out value="${breadcrumbSection}" /></span>
  </nav>
</c:if>
