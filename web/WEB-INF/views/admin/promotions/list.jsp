<%--
  admin/promotions/list.jsp — danh sách + panel tạo/sửa khuyến mãi chuẩn xác theo Entity Promotion.
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Khuyến mãi · Quản trị HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <c:set var="activeAdmin" value="promotions"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Khuyến mãi</h2>
      <span style="font-size:13px;color:var(--ash)">
        <strong>${activeCount}</strong> đang kích hoạt · <strong>${expiringSoon}</strong> sắp hết hạn · <strong>${totalRedeemed}</strong> lượt đã dùng
      </span>
      <div class="who"><span class="av"><c:out value="${sessionScope.currentUser.initials}"/></span></div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="split">
        <!-- BÊN TRÁI: DANH SÁCH KHUYẾN MÃI -->
        <div class="panel">
          <div class="panel-head"><h3>Danh sách khuyến mãi</h3></div>

          <form class="toolbar" method="get" action="${ctx}/admin/promotions">
            <div class="search">
              <svg width="17" height="17"><use href="#i-search"/></svg>
              <label class="sr-only" for="kw">Tìm khuyến mãi</label>
              <input id="kw" class="input" type="text" name="keyword" maxlength="50" value="<c:out value='${keyword}'/>" placeholder="Tìm theo mã...">
            </div>
            <select class="select" name="status" style="max-width: 150px;">
              <option value="">Tất cả trạng thái</option>
              <option value="1" ${statusFilter == '1' ? 'selected' : ''}>Đang kích hoạt</option>
              <option value="0" ${statusFilter == '0' ? 'selected' : ''}>Đã vô hiệu hóa</option>
            </select>
            <input type="hidden" name="page" value="1">
            <button type="submit" class="btn sm">Lọc</button>
            <a class="btn quiet sm" href="${ctx}/admin/promotions">Xoá</a>
          </form>

          <c:choose>
            <c:when test="${empty promotions}">
              <div class="empty">
                <div class="ring"><svg width="26" height="26"><use href="#i-tag"/></svg></div>
                <h3>Chưa có chương trình nào khớp bộ lọc</h3>
                <p>Tạo chương trình mới ở khung bên phải.</p>
              </div>
            </c:when>
            <c:otherwise>
              <table class="table">
                <thead>
                  <tr>
                    <th>Mã giảm giá</th>
                    <th>Mức giảm</th>
                    <th>Phạm vi</th>
                    <th>Hết hạn</th>
                    <th>Trạng thái</th>
                    <th style="text-align:right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="p" items="${promotions}">
                    <tr>
                      <td class="num"><b><c:out value="${p.code}"/></b></td>
                      <td class="num">
                        <c:choose>
                          <c:when test="${p.discountType eq 'PERCENT'}">${p.discountValue}%</c:when>
                          <c:otherwise><fmt:formatNumber value="${p.discountValue}" type="number" maxFractionDigits="0"/> đ</c:otherwise>
                        </c:choose>
                      </td>
                      <td><c:out value="${p.scope}"/></td>
                      <td class="num">
                        <c:if test="${not empty p.validUntil}">
                          ${p.validUntil.format(dateFormatter)}
                        </c:if>
                      </td>
                      <td>
                        <c:choose>
                          <c:when test="${p.IsActive()}"><span class="badge ok">Đang chạy</span></c:when>
                          <c:otherwise><span class="badge off">Đã dừng</span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="row-actions">
                        <a class="btn xs quiet" href="${ctx}/admin/promotions/edit?id=${p.promoId}" title="Sửa"><svg width="13" height="13"><use href="#i-edit"/></svg></a>
                        <form class="inline-form" method="post" action="${ctx}/admin/promotions/status">
                          <input type="hidden" name="promoId" value="${p.promoId}">
                          <input type="hidden" name="isActive" value="${!p.IsActive()}">
                          <button type="submit" class="btn xs ${p.IsActive() ? 'danger' : ''}">${p.IsActive() ? 'Dừng' : 'Bật'}</button>
                        </form>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>

              <!-- PHÂN TRANG -->
              <c:if test="${totalPages > 1}">
                <div style="padding: 16px; border-top: 1px solid var(--line); display: flex; justify-content: flex-end; gap: 6px;">
                  <c:if test="${currentPage > 1}">
                    <a class="btn sm quiet" href="?page=${currentPage - 1}&keyword=${keyword}&status=${statusFilter}">Trước</a>
                  </c:if>
                  <c:forEach begin="1" end="${totalPages}" var="i">
                    <a class="btn sm ${currentPage == i ? '' : 'quiet'}" href="?page=${i}&keyword=${keyword}&status=${statusFilter}">${i}</a>
                  </c:forEach>
                  <c:if test="${currentPage < totalPages}">
                    <a class="btn sm quiet" href="?page=${currentPage + 1}&keyword=${keyword}&status=${statusFilter}">Sau</a>
                  </c:if>
                </div>
              </c:if>
            </c:otherwise>
          </c:choose>
        </div>

        <!-- BÊN PHẢI: FORM TẠO / SỬA -->
        <div class="panel">
          <div class="panel-head">
            <h3>${isEdit ? 'Sửa khuyến mãi' : 'Tạo khuyến mãi mới'}</h3>
            <c:if test="${isEdit}">
              <a class="btn xs quiet" href="${ctx}/admin/promotions" style="margin-left: auto;">+ Tạo mới</a>
            </c:if>
          </div>
          <form method="post" action="${ctx}/admin/promotions/update">
            <c:if test="${isEdit}">
              <input type="hidden" name="promoId" value="${promo.promoId}">
            </c:if>
            <div class="panel-pad">
              <div class="field">
                <label>Mã giảm giá <span class="req">*</span></label>
                <input class="input" type="text" name="code" maxlength="20" value="<c:out value='${promo.code}'/>" placeholder="VD: SALE50">
                <div class="help">Viết hoa, 4–20 ký tự</div>
              </div>

              <div class="grid-2">
                <div class="field">
                  <label>Kiểu giảm <span class="req">*</span></label>
                  <select class="select" name="discountType">
                    <option value="FIXED" ${promo.discountType eq 'FIXED' ? 'selected' : ''}>Số tiền cố định</option>
                    <option value="PERCENT" ${promo.discountType eq 'PERCENT' ? 'selected' : ''}>Phần trăm (%)</option>
                  </select>
                </div>
                <div class="field">
                  <label>Giá trị <span class="req">*</span></label>
                  <input class="input" type="number" step="0.01" name="discountValue" value="${promo.discountValue}" placeholder="0">
                </div>
              </div>

              <div class="grid-2">
                <div class="field">
                  <label>Bắt đầu <span class="req">*</span></label>
                  <input class="input" type="datetime-local" name="validFrom" value="${validFromStr}">
                </div>
                <div class="field">
                  <label>Kết thúc <span class="req">*</span></label>
                  <input class="input" type="datetime-local" name="validUntil" value="${validUntilStr}">
                </div>
              </div>

              <div class="grid-2">
                <div class="field">
                  <label>Đơn tối thiểu (đ)</label>
                  <input class="input" type="number" step="0.01" name="minOrderValue" value="${not empty promo.minOrderValue ? promo.minOrderValue : '0'}">
                </div>
                <div class="field">
                  <label>Số lượt tối đa</label>
                  <input class="input" type="number" min="1" name="maxUses" value="${promo.maxUses}" placeholder="Không giới hạn">
                </div>
              </div>

              <div class="field">
                <label>Áp dụng cho (Scope)</label>
                <select class="select" name="scope">
                  <option value="ORDER" ${promo.scope eq 'ORDER' ? 'selected' : ''}>Toàn bộ đơn hàng</option>
                  <option value="CATEGORY" ${promo.scope eq 'CATEGORY' ? 'selected' : ''}>Theo danh mục</option>
                  <option value="PRODUCT" ${promo.scope eq 'PRODUCT' ? 'selected' : ''}>Sản phẩm chỉ định</option>
                </select>
              </div>

              <div style="margin-top:16px; display:flex; flex-direction:column; gap:8px; font-size:13px;">
                <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
                  <input type="checkbox" name="canStack" ${isEdit and promo.canStack ? 'checked' : ''}>
                  <span>Cho phép cộng dồn mã</span>
                </label>
                <label style="display:flex; align-items:center; gap:8px; cursor:pointer;">
                  <input type="checkbox" name="isActive" ${not isEdit or promo.IsActive() ? 'checked' : ''}>
                  <span>Kích hoạt chạy ngay</span>
                </label>
              </div>

              <button type="submit" class="btn block" style="margin-top: 20px;">${isEdit ? 'Cập nhật khuyến mãi' : 'Tạo khuyến mãi mới'}</button>
            </div>
          </form>
        </div>

      </div>
    </div>
  </div>
</div>
</body>
</html>