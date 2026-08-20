<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<div class="steps">
  <div class="st ${activeStep == 1 ? 'on' : (activeStep > 1 ? 'done' : '')}"><b>1</b>Giỏ hàng</div>
  <span class="bar ${activeStep > 1 ? 'done' : ''}"></span>
  <div class="st ${activeStep == 2 ? 'on' : (activeStep > 2 ? 'done' : '')}"><b>2</b>Thông tin &amp; thanh toán</div>
  <span class="bar ${activeStep > 2 ? 'done' : ''}"></span>
  <div class="st ${activeStep == 3 ? 'on' : (activeStep > 3 ? 'done' : '')}"><b>3</b>Xác nhận chuyển khoản</div>
</div>
