<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="okMsg" value="${not empty successMsg ? successMsg : sessionScope.successMsg}" />
<c:set var="badMsg" value="${not empty errorMsg ? errorMsg : sessionScope.errorMsg}" />

<c:if test="${not empty okMsg}">
  <div class="flash ok" role="status">
    <svg width="18" height="18"><use href="#i-check" /></svg>
    <div><c:out value="${okMsg}" /></div>
  </div>
  <c:remove var="successMsg" scope="session" />
</c:if>

<c:if test="${not empty badMsg}">
  <div class="flash err" role="alert">
    <svg width="18" height="18"><use href="#i-alert" /></svg>
    <div><c:out value="${badMsg}" /></div>
  </div>
  <c:remove var="errorMsg" scope="session" />
</c:if>

<c:if test="${not empty errors and empty badMsg}">
  <div class="flash err" role="alert">
    <svg width="18" height="18"><use href="#i-alert" /></svg>
    <div><b>Chưa lưu được.</b> Có ${fn:length(errors)} ô chưa hợp lệ, xem chi tiết bên dưới.</div>
  </div>
</c:if>
