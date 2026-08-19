<%--
  footer.jsp — chân trang dùng chung cho toàn bộ site.
  Cách dùng:  <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
  Không cần biến nào. File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<footer class="sf-foot">
  <div class="cols">
    <div>
      <a class="sf-logo" href="${ctx}/home" style="margin-bottom:12px">
        <svg width="24" height="24" style="color:var(--titan)"><use href="#logo-mark"/></svg>
        <span class="wm" style="color:#fff;font-size:14px">AOS · APPLESTORE</span>
      </a>
      <p style="margin:0;max-width:260px">
        Công ty Cổ phần Thương mại và Dịch vụ APPLESTORE Việt Nam 
        trải qua nhiều năm hoạt động, APPLESTORE hiện nay được biết đến như 1 đơn vị dẫn đầu trong ngành bán lẻ Điện thoại di động - Máy tính bảng - MacBook - Phụ kiện công nghệ Apple chính hãng, giá tốt.
      </p>
    </div>
    <div>
      <h4>Sản phẩm</h4>
      <ul>
        <li><a href="${ctx}/products?categoryId=1">iPhone</a></li>
        <li><a href="${ctx}/products?categoryId=3">MacBook</a></li>
        <li><a href="${ctx}/products?categoryId=2">iPad</a></li>
        <li><a href="${ctx}/products?categoryId=7">Phụ kiện</a></li>
      </ul>
    </div>
    <div>
      <h4>Chính sách</h4>
      <ul>
        <li><a href="">Chính sách mua hàng</a></li>
        <li><a href="">Chính sách bảo hành</a></li>
        <li><a href="">Chính sách vận chuyển</a></li>
        <li><a href="">Chính sách bảo mật</a></li>
      </ul>
    </div>
      <div>
      <h4>Hỗ trợ khách hàng</h4>
      <ul>
        <li><a href="">Giải đáp mua hàng online</a></li>
        <li><a href="">Phương thức thanh toán</a></li>
        <li><a href="">Câu hỏi thường gặp</a></li>
      </ul>
    </div>
  </div>
  <div class="copy">© 2026 AOS · APPLESTORE — PROJECT WEB SWP391</div>
</footer>
