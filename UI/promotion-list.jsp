<%--
  admin/promotion-list.jsp — danh sách + panel tạo khuyến mãi.
  Servlet cần set:
    promotions : List<Coupon>{code,name,discountLabel,startDate,endDate,usedCount,
                               usageLimit,status,statusLabel,statusClass}
    keyword, statusFilter, sort
    form, errors : dữ liệu form tạo mới bên phải (giữ lại khi lỗi)
    + Paging.export(request, "chương trình")
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
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
      <span style="font-size:13px;color:var(--ash)">${runningCount} chương trình đang chạy</span>
      <div class="who"><span class="av"><c:out value="${sessionScope.currentUser.initials}"/></span></div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="split">
        <div class="panel">
          <div class="panel-head"><h3>Danh sách khuyến mãi</h3></div>

          <form class="toolbar" method="get" action="${ctx}/admin/promotions">
            <div class="search">
              <svg width="17" height="17"><use href="#i-search"/></svg>
              <label class="sr-only" for="kw">Tìm khuyến mãi</label>
              <input id="kw" class="input" type="text" name="keyword" maxlength="50" value="<c:out value='${keyword}'/>" placeholder="Tìm theo mã hoặc tên chương trình">
            </div>
            <select class="select" name="status">
              <option value="">Tất cả trạng thái</option>
              <option value="RUNNING" ${statusFilter eq 'RUNNING' ? 'selected' : ''}>Đang chạy</option>
              <option value="UPCOMING" ${statusFilter eq 'UPCOMING' ? 'selected' : ''}>Sắp bắt đầu</option>
              <option value="ENDED" ${statusFilter eq 'ENDED' ? 'selected' : ''}>Đã kết thúc</option>
            </select>
            <input type="hidden" name="page" value="1">
            <button type="submit" class="btn sm">Áp dụng</button>
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
                <thead><tr><th>Mã</th><th>Tên chương trình</th><th>Mức giảm</th><th>Thời gian</th><th>Đã dùng</th><th>Trạng thái</th><th style="text-align:right">Thao tác</th></tr></thead>
                <tbody>
                  <c:forEach var="p" items="${promotions}">
                    <tr>
                      <td class="num"><b><c:out value="${p.code}"/></b></td>
                      <td><c:out value="${p.name}"/></td>
                      <td class="num"><c:out value="${p.discountLabel}"/></td>
                      <td class="num"><fmt:formatDate value="${p.startDate}" pattern="dd/MM"/> → <fmt:formatDate value="${p.endDate}" pattern="dd/MM"/></td>
                      <td class="num">${p.usedCount} / ${p.usageLimit}</td>
                      <td>
                        <c:choose>
                          <c:when test="${p.status eq 'RUNNING'}"><span class="badge ok"><c:out value="${p.statusLabel}"/></span></c:when>
                          <c:when test="${p.status eq 'UPCOMING'}"><span class="badge warn"><c:out value="${p.statusLabel}"/></span></c:when>
                          <c:otherwise><span class="badge off"><c:out value="${p.statusLabel}"/></span></c:otherwise>
                        </c:choose>
                      </td>
                      <td class="row-actions">
                        <c:choose>
                          <c:when test="${p.status eq 'ENDED'}">
                            <a class="btn xs quiet" href="${ctx}/admin/promotion/detail?code=${p.code}"><svg width="13" height="13"><use href="#i-eye"/></svg></a>
                            <a class="btn xs quiet" href="${ctx}/admin/promotions?duplicate=${p.code}">Nhân bản</a>
                          </c:when>
                          <c:otherwise>
                            <a class="btn xs quiet" href="${ctx}/admin/promotions?code=${p.code}"><svg width="13" height="13"><use href="#i-edit"/></svg></a>
                            <c:if test="${p.status eq 'RUNNING'}">
                              <form class="inline-form" method="post" action="${ctx}/admin/promotion/status">
                                <input type="hidden" name="code" value="${p.code}">
                                <input type="hidden" name="status" value="ENDED">
                                <input type="hidden" name="returnUrl" value="${ctx}/admin/promotions?page=${page}${filterQuery}">
                                <button type="submit" class="btn xs danger">Dừng</button>
                              </form>
                            </c:if>
                          </c:otherwise>
                        </c:choose>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
              <c:set var="pageUrl"   value="${ctx}/admin/promotions"/>
              <c:set var="itemLabel" value="chương trình"/>
              <jsp:include page="/WEB-INF/views/common/pagination.jsp"/>
            </c:otherwise>
          </c:choose>
        </div>

        <div class="panel">
          <div class="panel-head"><h3>${empty form.code ? 'Tạo khuyến mãi' : 'Sửa khuyến mãi'}</h3></div>
          <form method="post" action="${ctx}/admin/promotion/save">
            <input type="hidden" name="originalCode" value="${form.code}">
            <div class="panel-pad">
              <div class="field ${not empty errors.code ? 'err' : ''}">
                <label>Mã giảm giá <span class="req">*</span></label>
                <input class="input" type="text" name="code" maxlength="20" value="<c:out value='${form.code}'/>">
                <c:choose>
                  <c:when test="${not empty errors.code}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.code}"/></div></c:when>
                  <c:otherwise><div class="help">Viết hoa, 4–20 ký tự, không trùng mã cũ</div></c:otherwise>
                </c:choose>
              </div>
              <div class="field ${not empty errors.name ? 'err' : ''}">
                <label>Tên chương trình <span class="req">*</span></label>
                <input class="input" type="text" name="name" maxlength="100" value="<c:out value='${form.name}'/>">
                <c:if test="${not empty errors.name}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.name}"/></div></c:if>
              </div>
              <div class="grid-2">
                <div class="field">
                  <label>Kiểu giảm <span class="req">*</span></label>
                  <select class="select" name="discountType">
                    <option value="AMOUNT"  ${form.discountType eq 'AMOUNT'  ? 'selected' : ''}>Số tiền cố định</option>
                    <option value="PERCENT" ${form.discountType eq 'PERCENT' ? 'selected' : ''}>Phần trăm</option>
                  </select>
                </div>
                <div class="field ${not empty errors.discountValue ? 'err' : ''}">
                  <label>Giá trị <span class="req">*</span></label>
                  <input class="input" type="text" inputmode="numeric" name="discountValue" value="<c:out value='${form.discountValue}'/>">
                  <c:if test="${not empty errors.discountValue}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.discountValue}"/></div></c:if>
                </div>
                <div class="field ${not empty errors.startDate ? 'err' : ''}">
                  <label>Bắt đầu <span class="req">*</span></label>
                  <input class="input" type="date" name="startDate" value="<fmt:formatDate value='${form.startDate}' pattern='yyyy-MM-dd'/>">
                  <c:if test="${not empty errors.startDate}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.startDate}"/></div></c:if>
                </div>
                <div class="field ${not empty errors.endDate ? 'err' : ''}">
                  <label>Kết thúc <span class="req">*</span></label>
                  <input class="input" type="date" name="endDate" value="<fmt:formatDate value='${form.endDate}' pattern='yyyy-MM-dd'/>">
                  <c:if test="${not empty errors.endDate}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.endDate}"/></div></c:if>
                </div>
              </div>
              <div class="grid-2">
                <div class="field">
                  <label>Đơn tối thiểu</label>
                  <input class="input" type="text" inputmode="numeric" name="minOrderValue" value="<c:out value='${form.minOrderValue}'/>">
                </div>
                <div class="field">
                  <label>Số lượt tối đa</label>
                  <input class="input" type="number" min="1" name="usageLimit" value="${form.usageLimit}">
                </div>
              </div>
              <div class="field">
                <label>Áp dụng cho</label>
                <select class="select" name="scope">
                  <option value="ALL"      ${form.scope eq 'ALL'      ? 'selected' : ''}>Toàn bộ sản phẩm</option>
                  <option value="CATEGORY" ${form.scope eq 'CATEGORY' ? 'selected' : ''}>Theo danh mục</option>
                  <option value="PRODUCT"  ${form.scope eq 'PRODUCT'  ? 'selected' : ''}>Sản phẩm chỉ định</option>
                </select>
              </div>
              <button type="submit" class="btn block">Lưu khuyến mãi</button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>
</body>
</html>
