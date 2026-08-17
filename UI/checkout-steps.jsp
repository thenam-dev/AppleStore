<%--
  checkout-steps.jsp — thanh 4 bước dùng chung cho giỏ hàng, thanh toán, hoàn tất.
  Cách dùng:
      <c:set var="activeStep" value="2"/>  <%-- 1=Giỏ hàng 2=Giao hàng 3=Thanh toán 4=Hoàn tất --%>
      <jsp:include page="/WEB-INF/views/common/checkout-steps.jsp"/>
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<div class="steps">
  <div class="st ${activeStep == 1 ? 'on' : ''}"><b>1</b>Giỏ hàng</div>
  <span class="bar"></span>
  <div class="st ${activeStep == 2 ? 'on' : ''}"><b>2</b>Thông tin giao hàng</div>
  <span class="bar"></span>
  <div class="st ${activeStep == 3 ? 'on' : ''}"><b>3</b>Thanh toán</div>
  <span class="bar"></span>
  <div class="st ${activeStep == 4 ? 'on' : ''}"><b>4</b>Hoàn tất</div>
</div>
