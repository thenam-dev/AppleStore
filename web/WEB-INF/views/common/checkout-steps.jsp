<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>

<%-- .steps giữ nguyên full-bleed (nền trắng + viền dưới kẻ hết chiều rộng) -
     nội dung 3 bước bọc riêng trong .steps-inner để canh giữa max-width, không
     đặt max-width thẳng lên .steps (sẽ làm mất nền/viền tràn viewport). --%>
<div class="steps">
  <div class="steps-inner">
    <div class="st ${activeStep == 1 ? 'on' : (activeStep > 1 ? 'done' : '')}"><b>1</b>Giỏ hàng</div>
    <span class="bar ${activeStep > 1 ? 'done' : ''}"></span>
    <div class="st ${activeStep == 2 ? 'on' : (activeStep > 2 ? 'done' : '')}"><b>2</b>Thông tin &amp; thanh toán</div>
    <span class="bar ${activeStep > 2 ? 'done' : ''}"></span>
    <div class="st ${activeStep == 3 ? 'on' : (activeStep > 3 ? 'done' : '')}"><b>3</b>Xác nhận chuyển khoản</div>
  </div>
</div>
