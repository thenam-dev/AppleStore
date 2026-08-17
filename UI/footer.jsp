<%--
  footer.jsp — chân trang của phần khách hàng.
  Cách dùng:  <jsp:include page="/WEB-INF/views/common/footer.jsp"/>
  Không cần biến nào. File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>

<footer class="sf-foot">
  <div class="cols">
    <div>
      <a class="sf-logo" href="${ctx}/home" style="margin-bottom:12px">
        <svg width="24" height="24" style="color:var(--titan)"><use href="#logo-halo"/></svg>
        <span class="wm" style="color:#fff;font-size:14px">HALO</span>
      </a>
      <p style="margin:0;max-width:260px">
        Hệ thống bán lẻ sản phẩm Apple. 128 Cầu Giấy, Hà Nội.
        Mở cửa 8:30–21:30 mỗi ngày.
      </p>
    </div>
    <div>
      <h4>Sản phẩm</h4>
      <ul>
        <li><a href="${ctx}/products?categoryId=1">iPhone</a></li>
        <li><a href="${ctx}/products?categoryId=2">Mac</a></li>
        <li><a href="${ctx}/products?categoryId=3">iPad</a></li>
        <li><a href="${ctx}/products?categoryId=5">Phụ kiện</a></li>
      </ul>
    </div>
    <div>
      <h4>Hỗ trợ</h4>
      <ul>
        <li><a href="${ctx}/order/track">Tra cứu đơn hàng</a></li>
        <li><a href="${ctx}/page/warranty">Chính sách bảo hành</a></li>
        <li><a href="${ctx}/page/return">Đổi trả 30 ngày</a></li>
        <li><a href="${ctx}/page/installment">Hướng dẫn trả góp</a></li>
      </ul>
    </div>
    <div>
      <h4>Liên hệ</h4>
      <ul>
        <li>1900 6868</li>
        <li>hotro@halo.vn</li>
        <li>Facebook · Zalo</li>
      </ul>
    </div>
  </div>
  <div class="copy">© 2026 HALO STORE · ĐỒ ÁN WEB APPLE STORE</div>
</footer>
