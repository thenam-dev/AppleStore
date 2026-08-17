<%--
  flash.jsp — hiển thị thông báo sau thao tác POST (rule 10).
  Cách dùng: đặt ngay đầu vùng nội dung của trang list hoặc form.
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

  Key thống nhất toàn hệ thống, không đặt tên khác:
      successMsg : chuỗi thông báo thành công
      errorMsg   : chuỗi thông báo lỗi chung của cả form

  Phía servlet, theo PRG:
      session.setAttribute("successMsg", "Đã cập nhật danh mục.");
      response.sendRedirect(request.getContextPath() + "/admin/categories");
  File này tự xoá key khỏi session sau khi hiện, nên tải lại trang sẽ không thấy lại.
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%-- gom message từ cả request và session để servlet dùng kiểu nào cũng chạy --%>
<c:set var="okMsg"  value="${not empty successMsg ? successMsg : sessionScope.successMsg}"/>
<c:set var="badMsg" value="${not empty errorMsg   ? errorMsg   : sessionScope.errorMsg}"/>

<c:if test="${not empty okMsg}">
  <div class="flash ok" role="status">
    <svg width="18" height="18"><use href="#i-check"/></svg>
    <div><c:out value="${okMsg}"/></div>
  </div>
  <c:remove var="successMsg" scope="session"/>
</c:if>

<c:if test="${not empty badMsg}">
  <div class="flash err" role="alert">
    <svg width="18" height="18"><use href="#i-alert"/></svg>
    <div><c:out value="${badMsg}"/></div>
  </div>
  <c:remove var="errorMsg" scope="session"/>
</c:if>

<%-- Lỗi theo từng ô: servlet đẩy xuống Map<String,String> tên là errors.
     Ô nào lỗi thì trong form thêm class err và in ${errors.tenTruong}.
     Ở đây chỉ hiện phần tổng kết khi có lỗi mà chưa có errorMsg riêng. --%>
<c:if test="${not empty errors and empty badMsg}">
  <div class="flash err" role="alert">
    <svg width="18" height="18"><use href="#i-alert"/></svg>
    <div><b>Chưa lưu được.</b> Có ${fn:length(errors)} ô chưa hợp lệ, xem chi tiết bên dưới.</div>
  </div>
</c:if>
