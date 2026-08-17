<%--
  admin/dashboard.jsp — tổng quan.
  Servlet cần set:
    todayRevenue, revenueDeltaPct, newOrders, newOrdersDelta, pendingOrders, lowStockCount
    weekRevenue   : List<{label,amount,pct}> 7 cột cho biểu đồ (pct 0..100 để set chiều cao)
    topProducts   : List<Product>{name,soldQty,revenue,iconKey}
    pendingList   : List<Order> cần xử lý (hiện tối đa 5 dòng)
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Dashboard · Quản trị HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <c:set var="activeAdmin" value="dashboard"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Dashboard</h2>
      <span class="badge ok">Hôm nay · <fmt:formatDate value="${now}" pattern="dd/MM/yyyy"/></span>
      <div class="who">
        <span><c:out value="${sessionScope.currentUser.fullName}"/></span>
        <span class="av"><c:out value="${sessionScope.currentUser.initials}"/></span>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <div class="stats">
        <div class="stat"><div class="lab">Doanh thu hôm nay</div>
          <div class="val"><fmt:formatNumber value="${todayRevenue}" type="number" maxFractionDigits="1"/> tr</div>
          <div class="delta ${revenueDeltaPct < 0 ? 'down' : ''}">${revenueDeltaPct >= 0 ? '+' : ''}${revenueDeltaPct}% so với hôm qua</div></div>
        <div class="stat"><div class="lab">Đơn mới</div><div class="val">${newOrders}</div>
          <div class="delta">+${newOrdersDelta} đơn</div></div>
        <div class="stat"><div class="lab">Chờ xác nhận</div><div class="val">${pendingOrders}</div>
          <div class="delta down">Cần xử lý trong hôm nay</div></div>
        <div class="stat"><div class="lab">Sản phẩm sắp hết</div><div class="val">${lowStockCount}</div>
          <div class="delta down">Tồn dưới 3 máy</div></div>
      </div>

      <div class="split">
        <div class="panel">
          <div class="panel-head"><h3>Doanh thu 7 ngày gần nhất</h3></div>
          <div class="panel-pad">
            <div style="display:flex;align-items:flex-end;gap:14px;height:180px">
              <c:forEach var="d" items="${weekRevenue}" varStatus="st">
                <div style="flex:1;text-align:center">
                  <div style="height:${d.pct}%;background:${st.last ? 'linear-gradient(180deg,#EBDCBB,#C9B58C)' : '#E7E9ED'};border-radius:6px 6px 0 0"></div>
                  <div class="mono" style="font-size:10px;color:${st.last ? 'var(--ink)' : 'var(--ash)'};margin-top:7px"><c:out value="${d.label}"/></div>
                </div>
              </c:forEach>
            </div>
          </div>
        </div>

        <div class="panel">
          <div class="panel-head"><h3>Bán chạy tháng này</h3></div>
          <div class="panel-pad" style="display:flex;flex-direction:column;gap:12px">
            <c:forEach var="p" items="${topProducts}">
              <div style="display:flex;gap:11px;align-items:center">
                <div class="shot" style="width:40px;height:40px;aspect-ratio:auto;border-radius:var(--r-sm)">
                  <svg style="color:#5B6472"><use href="#${empty p.iconKey ? 'd-acc' : p.iconKey}"/></svg>
                </div>
                <div style="flex:1;font-size:13px"><b><c:out value="${p.name}"/></b><br>
                  <span style="color:var(--ash);font-size:12px">${p.soldQty} máy</span></div>
                <span class="mono" style="font-size:12px"><fmt:formatNumber value="${p.revenue}" type="number" maxFractionDigits="1"/> tr</span>
              </div>
            </c:forEach>
          </div>
        </div>
      </div>

      <div class="panel">
        <div class="panel-head"><h3>Đơn cần xử lý</h3><div class="r"><a class="btn ghost sm" href="${ctx}/admin/orders">Xem tất cả đơn</a></div></div>
        <c:choose>
          <c:when test="${empty pendingList}">
            <div class="empty">
              <div class="ring"><svg width="26" height="26"><use href="#i-check"/></svg></div>
              <h3>Không có đơn nào cần xử lý</h3>
              <p>Mọi đơn hàng hiện tại đã được xác nhận.</p>
            </div>
          </c:when>
          <c:otherwise>
            <table class="table">
              <thead><tr><th>Mã đơn</th><th>Khách hàng</th><th>Sản phẩm</th><th>Tổng tiền</th><th>Trạng thái</th><th>Đặt lúc</th><th></th></tr></thead>
              <tbody>
                <c:forEach var="o" items="${pendingList}">
                  <tr>
                    <td class="num"><c:out value="${o.code}"/></td>
                    <td><c:out value="${o.receiverName}"/></td>
                    <td><c:out value="${o.itemCount}"/> sản phẩm</td>
                    <td class="num"><fmt:formatNumber value="${o.total}" type="number" maxFractionDigits="0"/> ₫</td>
                    <td><span class="badge warn"><c:out value="${o.statusLabel}"/></span></td>
                    <td class="num"><fmt:formatDate value="${o.createdAt}" pattern="HH:mm"/></td>
                    <td class="row-actions">
                      <form method="post" action="${ctx}/admin/order/status">
                        <input type="hidden" name="code" value="${o.code}">
                        <input type="hidden" name="status" value="CONFIRMED">
                        <input type="hidden" name="returnUrl" value="${ctx}/admin/dashboard">
                        <button type="submit" class="btn xs">Xác nhận</button>
                      </form>
                    </td>
                  </tr>
                </c:forEach>
              </tbody>
            </table>
          </c:otherwise>
        </c:choose>
      </div>
    </div>
  </div>
</div>
</body>
</html>
