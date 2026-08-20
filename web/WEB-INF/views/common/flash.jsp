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

  errorMsg đơn (không kèm fieldErrors) hiện dạng TOAST đỏ (góc trên phải, ngay
  dưới header, tự biến mất) thay vì banner cố định đầu trang - trang nào cũng
  có sẵn CSS .toast/.toast-stack (style.css) và #i-alert (icons.jsp) nên dùng
  lại được luôn, không cần thêm gì.
  Khi có fieldErrors (nhiều lỗi cần đọc kỹ từng ô, vd. form nhiều trường) vẫn giữ
  banner cố định như cũ vì toast tự ẩn quá nhanh để đọc hết cả danh sách.
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<c:if test="${not empty errorMsg}">
  <c:choose>
    <c:when test="${empty fieldErrors}">
      <%-- Không in thẳng errorMsg vào <script> (JS string) để tránh phải tự lo
           escape ký tự đặc biệt - đẩy qua data-attribute (c:out escape chuẩn HTML)
           rồi JS đọc lại bằng dataset, an toàn tuyệt đối. --%>
      <div id="flashErrorToastData" data-message="<c:out value='${errorMsg}'/>" style="display:none" aria-hidden="true"></div>
      <script>
        (function () {
          var dataEl = document.getElementById('flashErrorToastData');
          if (!dataEl) { return; }
          var message = dataEl.dataset.message;
          if (!message) { return; }

          var stack = document.getElementById('toast-stack');
          if (!stack) {
            stack = document.createElement('div');
            stack.id = 'toast-stack';
            stack.className = 'toast-stack';
            document.body.appendChild(stack);
          }
          // Nảy vào từ phải, thu về phải lúc biến mất, có thanh thời gian
          // (.toast-timer) co dần theo DURATION (xem style.css .toast/.toast-timer).
          var DURATION = 4000;
          var ENTER_MS = 320; // khớp thời gian transition transform lúc .toast.show (style.css)
          var toast = document.createElement('div');
          toast.className = 'toast err';
          toast.setAttribute('role', 'alert');
          toast.innerHTML = '<svg width="16" height="16"><use href="#i-alert"/></svg>' +
            '<span></span><i class="toast-timer"></i>';
          toast.querySelector('span').textContent = message;
          stack.appendChild(toast);
          var timer = toast.querySelector('.toast-timer');
          timer.style.transitionDuration = Math.max(DURATION - ENTER_MS, 0) + 'ms';
          requestAnimationFrame(function () { toast.classList.add('show'); });
          // Chỉ bắt đầu co thanh thời gian SAU KHI toast nảy vào xong hẳn
          // (ENTER_MS) - kích cùng lúc với lúc chèn vào DOM (chung 1 rAF với
          // .show) khiến trình duyệt gộp 2 thay đổi transform lại, thanh co
          // gần như tức thì (nhìn như biến mất luôn, không co dần được).
          setTimeout(function () { timer.style.transform = 'scaleX(0)'; }, ENTER_MS);
          setTimeout(function () {
            toast.classList.remove('show');
            toast.classList.add('hide');
            setTimeout(function () { toast.remove(); }, 220);
          }, DURATION);
        })();
      </script>
    </c:when>
    <c:otherwise>
      <div class="flash err" role="alert" style="margin-bottom:16px">
        <svg width="18" height="18"><use href="#i-alert"/></svg>
        <div>
          <c:out value="${errorMsg}"/>
          <ul style="margin:8px 0 0;padding-left:18px">
            <c:forEach var="fieldError" items="${fieldErrors}">
              <li><c:out value="${fieldError.value}"/></li>
            </c:forEach>
          </ul>
        </div>
      </div>
    </c:otherwise>
  </c:choose>
</c:if>
