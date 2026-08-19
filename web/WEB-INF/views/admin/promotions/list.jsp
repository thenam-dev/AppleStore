<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Khuyến mãi · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="promotions" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Khuyến mãi</h2>
      <span style="font-size:13px;color:var(--ash)">Kết quả lọc: ${totalRecords}</span>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <section class="stats">
        <article class="stat">
          <div class="lab">Tổng mã giảm giá</div>
          <div class="val">${totalRecords}</div>
          <div class="delta">Toàn bộ hệ thống</div>
        </article>
        <article class="stat">
          <div class="lab">Đang chạy</div>
          <div class="val">${activeCount}</div>
          <div class="delta">Hiển thị cho khách</div>
        </article>
        <article class="stat">
          <div class="lab">Lượt đã dùng</div>
          <div class="val">${totalRedeemed}</div>
          <div class="delta">Trên toàn hệ thống</div>
        </article>
        <article class="stat">
          <div class="lab">Sắp hết hạn</div>
          <div class="val">${expiringSoon}</div>
          <div class="delta down">Trong vòng 7 ngày</div>
        </article>
      </section>

      <div class="panel">
        <div class="panel-head">
          <h3>Bảng mã khuyến mãi</h3>
          <div class="r">
            <a class="btn sm" href="${appPath}/admin/promotions/edit"><svg width="15" height="15"><use href="#i-plus" /></svg>Tạo khuyến mãi</a>
          </div>
        </div>

        <form class="toolbar" action="${appPath}/admin/promotions" method="get" name="adminPromoFilterForm">
          <div class="search">
            <svg width="17" height="17"><use href="#i-search" /></svg>
            <label class="sr-only" for="admin-promo-search">Tìm khuyến mãi</label>
            <input id="admin-promo-search" class="input" type="search" name="keyword" maxlength="50"
                   value="${fn:escapeXml(keyword)}" placeholder="Nhập mã CODE (VD: SALE50)">
          </div>
          <select class="select" name="status" aria-label="Trạng thái">
            <option value="">Tất cả trạng thái</option>
            <option value="1" ${statusFilter == '1' ? 'selected' : ''}>Đang chạy</option>
            <option value="0" ${statusFilter == '0' ? 'selected' : ''}>Tạm dừng</option>
          </select>
          <input type="hidden" name="page" value="1">
          <button class="btn sm" type="submit">Áp dụng</button>
          <a class="btn ghost sm" href="${appPath}/admin/promotions">Đặt lại</a>
        </form>

        <c:choose>
          <c:when test="${empty promotions}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-tag" /></svg></div>
              <h3>Không tìm thấy khuyến mãi</h3>
              <p>Thử xoá bộ lọc hoặc tạo mã khuyến mãi mới.</p>
              <a class="btn" href="${appPath}/admin/promotions/edit">Tạo khuyến mãi</a>
            </div>
          </c:when>
          <c:otherwise>
            <div class="table-scroll">
              <table class="table">
                <thead>
                  <tr>
                    <th>Mã giảm giá</th>
                    <th>Mức giảm</th>
                    <th>Phạm vi</th>
                    <th>Đã dùng</th>
                    <th>Hết hạn</th>
                    <th>Trạng thái</th>
                    <th style="text-align:right">Thao tác</th>
                  </tr>
                </thead>
                <tbody>
                  <c:forEach var="p" items="${promotions}">
                    <tr>
                      <td class="num">
                        <b><c:out value="${p.code}" /></b>
                        <div class="mono" style="font-size:11px;color:var(--ash)">ID: #${p.promoId}</div>
                      </td>
                      <td class="num">
                        <c:choose>
                          <c:when test="${p.discountType eq 'PERCENT'}">${p.discountValue}%</c:when>
                          <c:otherwise><fmt:formatNumber value="${p.discountValue}" pattern="#,##0.##" /> VND</c:otherwise>
                        </c:choose>
                      </td>
                      <td><span class="tag"><c:out value="${p.scope}" /></span></td>
                      <td class="num">${p.usedCount} / ${empty p.maxUses ? '∞' : p.maxUses}</td>
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
                      <td>
                        <div class="row-actions">
                          <a class="btn xs quiet" href="${appPath}/admin/promotions/edit?id=${p.promoId}" title="Sửa">
                            <svg width="13" height="13"><use href="#i-edit" /></svg>
                          </a>
                          <form class="inline-form" action="${appPath}/admin/promotions/status" method="post">
                            <input type="hidden" name="promoId" value="${p.promoId}">
                            <input type="hidden" name="isActive" value="${!p.IsActive()}">
                            <button class="btn xs ${p.IsActive() ? 'danger' : ''}" type="submit">
                              ${p.IsActive() ? 'Dừng' : 'Bật'}
                            </button>
                          </form>
                        </div>
                      </td>
                    </tr>
                  </c:forEach>
                </tbody>
              </table>
            </div>
            <c:set var="pageUrl" value="${appPath}/admin/promotions" />
            <c:set var="itemLabel" value="khuyến mãi" />
            <c:set var="totalItems" value="${totalRecords}" />
            <jsp:include page="/WEB-INF/views/common/pagination.jsp" />
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>