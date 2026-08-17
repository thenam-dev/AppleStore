<%--
  pagination.jsp — thanh phân trang dùng chung cho mọi bảng dữ liệu (rule 8).

  Cách dùng:
      <c:set var="pageUrl" value="${ctx}/admin/products"/>
      <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>

  Biến servlet phải chuẩn bị (rule 5 — JSP không tự tính):
      pageUrl     : đường dẫn gốc, ví dụ "/AppleStore/admin/products"
      page        : trang hiện tại, bắt đầu từ 1
      totalPages  : tổng số trang
      totalItems  : tổng số bản ghi
      pageSize    : số dòng mỗi trang
      filterQuery : phần query giữ lại bộ lọc, ĐÃ encode, bắt đầu bằng "&"
                    ví dụ "&keyword=iphone+16&categoryId=1&sort=newest"
                    dùng Paging.buildFilterQuery(request, "page") để sinh ra
      itemLabel   : tên đối tượng, mặc định "bản ghi" (ví dụ "sản phẩm", "đơn")
      showPageSize: true thì hiện ô chọn số dòng mỗi trang

  Không hiện gì nếu chỉ có 1 trang và dưới 1 trang dữ liệu.
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="label" value="${empty itemLabel ? 'bản ghi' : itemLabel}"/>
<c:set var="from"  value="${totalItems == 0 ? 0 : (page - 1) * pageSize + 1}"/>
<c:set var="to"    value="${page * pageSize > totalItems ? totalItems : page * pageSize}"/>

<%-- cửa sổ tối đa 5 số trang quanh trang hiện tại, tính bằng EL thuần --%>
<c:set var="start" value="${page - 2 lt 1 ? 1 : page - 2}"/>
<c:set var="end"   value="${start + 4 gt totalPages ? totalPages : start + 4}"/>
<c:set var="start" value="${end - 4 lt 1 ? 1 : end - 4}"/>

<div class="pager">
  <span class="info">Hiển thị ${from}–${to} trong ${totalItems} ${label}</span>

  <div style="display:flex;gap:12px;align-items:center">
    <c:if test="${showPageSize}">
      <form method="get" action="${pageUrl}">
        <%-- giữ lại bộ lọc khi đổi số dòng, và luôn quay về trang 1 --%>
        <c:forEach var="p" items="${filterParams}">
          <input type="hidden" name="${p.key}" value="<c:out value='${p.value}'/>">
        </c:forEach>
        <input type="hidden" name="page" value="1">
        <label class="sr-only" for="pgSize">Số dòng mỗi trang</label>
        <select id="pgSize" class="select" name="size" style="height:34px;font-size:12.5px;min-width:130px"
                onchange="this.form.submit()">
          <option value="10" ${pageSize == 10 ? 'selected' : ''}>10 dòng/trang</option>
          <option value="20" ${pageSize == 20 ? 'selected' : ''}>20 dòng/trang</option>
          <option value="50" ${pageSize == 50 ? 'selected' : ''}>50 dòng/trang</option>
        </select>
      </form>
    </c:if>

    <c:if test="${totalPages gt 1}">
      <nav class="pages" aria-label="Phân trang">
        <c:choose>
          <c:when test="${page le 1}">
            <span class="pg disabled" aria-hidden="true">‹</span>
          </c:when>
          <c:otherwise>
            <a class="pg" href="${pageUrl}?page=${page - 1}${filterQuery}" aria-label="Trang trước">‹</a>
          </c:otherwise>
        </c:choose>

        <c:if test="${start gt 1}">
          <a class="pg" href="${pageUrl}?page=1${filterQuery}">1</a>
          <c:if test="${start gt 2}"><span class="pg gap">…</span></c:if>
        </c:if>

        <c:forEach var="i" begin="${start}" end="${end}">
          <c:choose>
            <c:when test="${i == page}">
              <span class="pg on" aria-current="page">${i}</span>
            </c:when>
            <c:otherwise>
              <a class="pg" href="${pageUrl}?page=${i}${filterQuery}">${i}</a>
            </c:otherwise>
          </c:choose>
        </c:forEach>

        <c:if test="${end lt totalPages}">
          <c:if test="${end lt totalPages - 1}"><span class="pg gap">…</span></c:if>
          <a class="pg" href="${pageUrl}?page=${totalPages}${filterQuery}">${totalPages}</a>
        </c:if>

        <c:choose>
          <c:when test="${page ge totalPages}">
            <span class="pg disabled" aria-hidden="true">›</span>
          </c:when>
          <c:otherwise>
            <a class="pg" href="${pageUrl}?page=${page + 1}${filterQuery}" aria-label="Trang sau">›</a>
          </c:otherwise>
        </c:choose>
      </nav>
    </c:if>
  </div>
</div>
