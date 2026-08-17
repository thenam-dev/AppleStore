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
        Cửa hàng trực tuyến chuyên các sản phẩm Apple chính hãng —
        giỏ hàng, thanh toán và theo dõi đơn hàng ngay trên web.
      </p>
    </div>
    <div>
      <h4>Sản phẩm</h4>
      <ul>
        <li><a href="${ctx}/products?categoryId=1">iPhone</a></li>
        <li><a href="${ctx}/products?categoryId=3">Mac</a></li>
        <li><a href="${ctx}/products?categoryId=2">iPad</a></li>
        <li><a href="${ctx}/products?categoryId=7">Phụ kiện</a></li>
      </ul>
    </div>
    <div>
      <h4>Hỗ trợ</h4>
      <ul>
        <li><a href="${ctx}/cart">Giỏ hàng của bạn</a></li>
        <li><a href="${ctx}/vouchers">Mã khuyến mãi</a></li>
        <li><a href="${ctx}/products">Tất cả sản phẩm</a></li>
      </ul>
    </div>
    <div>
      <h4>Tài khoản</h4>
      <ul>
        <c:choose>
          <c:when test="${not empty sessionScope.user}">
            <li><a href="${ctx}/change-password">Đổi mật khẩu</a></li>
            <li><a href="${ctx}/logout">Đăng xuất</a></li>
          </c:when>
          <c:otherwise>
            <li><a href="${ctx}/login">Đăng nhập</a></li>
            <li><a href="${ctx}/register">Đăng ký</a></li>
          </c:otherwise>
        </c:choose>
      </ul>
    </div>
  </div>
  <div class="copy">© 2026 AOS · APPLESTORE — ĐỒ ÁN WEB SWP391</div>
</footer>
