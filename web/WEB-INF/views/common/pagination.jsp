<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:set var="page" value="${empty page ? currentPage : page}" />
<c:set var="page" value="${empty page ? 1 : page}" />
<c:set var="totalPages" value="${empty totalPages ? 1 : totalPages}" />
<c:set var="label" value="${empty itemLabel ? 'bản ghi' : itemLabel}" />
<c:set var="querySuffix" value="${empty filterQuery ? listQuerySuffix : filterQuery}" />
<c:set var="querySuffix" value="${empty querySuffix ? '' : querySuffix}" />
<c:set var="joiner" value="${fn:contains(pageUrl, '?') ? '&amp;' : '?'}" />
<c:set var="start" value="${page - 2 lt 1 ? 1 : page - 2}" />
<c:set var="end" value="${start + 4 gt totalPages ? totalPages : start + 4}" />
<c:set var="start" value="${end - 4 lt 1 ? 1 : end - 4}" />

<div class="pager">
  <span class="info">Trang ${page} / ${totalPages}<c:if test="${not empty totalItems}"> · ${totalItems} ${label}</c:if></span>

  <c:if test="${totalPages gt 1}">
    <nav class="pages" aria-label="Phân trang">
      <c:choose>
        <c:when test="${page le 1}">
          <span class="pg disabled" aria-hidden="true">‹</span>
        </c:when>
        <c:otherwise>
          <a class="pg" href="${pageUrl}${joiner}page=${page - 1}${querySuffix}" aria-label="Trang trước">‹</a>
        </c:otherwise>
      </c:choose>

      <c:if test="${start gt 1}">
        <a class="pg" href="${pageUrl}${joiner}page=1${querySuffix}">1</a>
        <c:if test="${start gt 2}"><span class="pg gap">...</span></c:if>
      </c:if>

      <c:forEach var="i" begin="${start}" end="${end}">
        <c:choose>
          <c:when test="${i eq page}">
            <span class="pg on" aria-current="page">${i}</span>
          </c:when>
          <c:otherwise>
            <a class="pg" href="${pageUrl}${joiner}page=${i}${querySuffix}">${i}</a>
          </c:otherwise>
        </c:choose>
      </c:forEach>

      <c:if test="${end lt totalPages}">
        <c:if test="${end lt totalPages - 1}"><span class="pg gap">...</span></c:if>
        <a class="pg" href="${pageUrl}${joiner}page=${totalPages}${querySuffix}">${totalPages}</a>
      </c:if>

      <c:choose>
        <c:when test="${page ge totalPages}">
          <span class="pg disabled" aria-hidden="true">›</span>
        </c:when>
        <c:otherwise>
          <a class="pg" href="${pageUrl}${joiner}page=${page + 1}${querySuffix}" aria-label="Trang sau">›</a>
        </c:otherwise>
      </c:choose>
    </nav>
  </c:if>
</div>
