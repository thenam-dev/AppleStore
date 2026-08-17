<%--
  flash.jsp — hiển thị lỗi dùng chung cho luồng giỏ hàng - thanh toán.
  Cách dùng: đặt ngay đầu vùng nội dung của trang.
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

  Key đọc trực tiếp bằng EL nên tự tìm cả request lẫn session, không cần khai báo thêm:
      errorMsg    : chuỗi thông báo lỗi chung của cả form
      fieldErrors : Map<String,String> lỗi từng ô (tuỳ trang có hay không)
  CHỦ Ý: successMsg KHÔNG hiện ở đây nữa — tiến độ giỏ hàng/thanh toán đã thể hiện qua
  thanh bước checkout-steps.jsp (bước nào xong tự tô xanh), không cần thêm banner
  "thành công" gây trùng lặp thông tin. servlet vẫn có thể set successMsg cho session,
  chỉ là JSP không in ra nữa; đừng gỡ session.setAttribute("successMsg", ...) bên servlet
  vì chỗ khác (nếu có) có thể còn cần.
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:if test="${not empty errorMsg}">
  <div class="flash err" role="alert" style="margin-bottom:16px">
    <svg width="18" height="18"><use href="#i-alert"/></svg>
    <div>
      <c:out value="${errorMsg}"/>
      <c:if test="${not empty fieldErrors}">
        <ul style="margin:8px 0 0;padding-left:18px">
          <c:forEach var="fieldError" items="${fieldErrors}">
            <li><c:out value="${fieldError.value}"/></li>
          </c:forEach>
        </ul>
      </c:if>
    </div>
  </div>
</c:if>
