<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<fmt:setLocale value="vi_VN" />
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="Tổng quan · Quản trị HALO" />
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
  <style>
    /* Styling for the charts and specific components inside panel */
    .admin-chart-placeholder { padding: 20px; }
  </style>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />

<div class="adm">
  <c:set var="activeAdmin" value="dashboard" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <h2>Tổng quan hệ thống & Báo cáo</h2>
      <div class="who">
        <c:if test="${sessionScope.user.role eq 'ADMIN'}"><button onclick="exportToCSV()" class="btn ghost sm">Xuất dữ liệu (CSV)</button></c:if>
      </div>
    </div>

    <div class="adm-body">
      <form action="${appPath}/admin/dashboard" method="GET" class="toolbar" onsubmit="return validateDateRange(this);">
        <div class="search" style="border:none;box-shadow:none;background:transparent;padding:0;">
          <label for="startDate" style="margin-right:8px;font-size:13px;color:var(--ash);">Từ:</label>
          <input type="date" id="startDate" name="startDate" class="input" value="${not empty sessionScope.badStartDate ? sessionScope.badStartDate : param.startDate}">
        </div>
        <div class="search" style="border:none;box-shadow:none;background:transparent;padding:0;">
          <label for="endDate" style="margin-right:8px;font-size:13px;color:var(--ash);">Đến:</label>
          <input type="date" id="endDate" name="endDate" class="input" value="${not empty sessionScope.badEndDate ? sessionScope.badEndDate : param.endDate}">
        </div>
        <c:remove var="badStartDate" scope="session"/>
        <c:remove var="badEndDate" scope="session"/>
        <button type="submit" class="btn sm">Lọc</button>
        <button type="button" onclick="setQuickDateRange(30)" class="btn ghost sm">30 ngày</button>
        <button type="button" onclick="setQuickDateRange(7)" class="btn ghost sm">7 ngày</button>
      </form>

      <div class="stats">
        <c:if test="${sessionScope.user.role ne 'DELIVERY'}">
          <div class="stat">
            <div class="lab">Doanh thu</div>
            <div class="val"><fmt:formatNumber value="${stats != null ? stats.totalRevenue : 0}" type="currency" currencyCode="VND" /></div>
            <div class="delta">Đơn hàng đã giao thành công</div>
          </div>
        </c:if>
        <div class="stat">
          <div class="lab">Đơn hàng</div>
          <div class="val"><c:out value="${stats != null ? stats.totalOrders : 0}" /></div>
          <div class="delta">Đang ở mọi trạng thái</div>
        </div>
        <c:if test="${sessionScope.user.role eq 'ADMIN'}">
          <div class="stat">
            <div class="lab">Sản phẩm</div>
            <div class="val"><c:out value="${stats != null ? stats.activeProducts : 0}" /></div>
            <div class="delta">Sản phẩm đang kinh doanh</div>
          </div>
          <div class="stat">
            <div class="lab">Người dùng</div>
            <div class="val"><c:out value="${stats != null ? stats.totalUsers : 0}" /></div>
            <div class="delta">Tài khoản đã đăng ký</div>
          </div>
        </c:if>
      </div>

      <div class="split">
        <c:if test="${sessionScope.user.role ne 'DELIVERY'}">
          <div class="panel">
            <div class="panel-head">
              <h3>Biểu đồ doanh thu theo thời gian</h3>
            </div>
            <div class="panel-pad">
              <div style="height:350px">
                <canvas id="revenueChart" style="width: 100%; height: 100%;"></canvas>
              </div>
            </div>
          </div>
        </c:if>
        <div class="panel" style="flex: 0 0 320px;">
          <div class="panel-head">
            <h3>Tỉ lệ trạng thái</h3>
          </div>
          <div class="panel-pad" style="display: flex; justify-content: center; align-items: center;">
            <div style="height:350px; width:100%;">
              <canvas id="orderStatusChart" style="width: 100%; height: 100%;"></canvas>
            </div>
          </div>
        </div>
      </div>

      <div class="split">
        <div class="panel" style="flex:2">
          <div class="panel-head">
            <h3>Đơn hàng gần đây</h3>
            <div class="r">
              <a class="btn ghost sm" href="${appPath}/staff/orders">Xem tất cả</a>
            </div>
          </div>
          <c:choose>
            <c:when test="${empty recentOrders}">
              <div class="empty">
                <div class="ring"><svg width="26" height="26"><use href="#i-check"/></svg></div>
                <h3>Chưa có đơn hàng nào</h3>
              </div>
            </c:when>
            <c:otherwise>
              <div class="table-scroll">
                <table class="table">
                  <thead>
                    <tr>
                      <th>Mã đơn</th>
                      <th>Khách hàng</th>
                      <th>Ngày đặt</th>
                      <th>Tổng tiền</th>
                      <th>Trạng thái</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach items="${recentOrders}" var="order">
                      <tr>
                        <td class="num">#AOS-<c:out value="${order.orderId}" /></td>
                        <td><c:out value="${order.recipientName}" /></td>
                        <td class="num"><c:out value="${order.formattedCreatedAt}" /></td>
                        <td class="num"><fmt:formatNumber value="${order.finalAmount}" type="currency" currencyCode="VND" /></td>
                        <td>
                          <c:choose>
                            <c:when test="${order.status eq 'PENDING_PAYMENT' or order.status eq 'APPROVED'}">
                              <span class="badge warn">Chờ xử lý</span>
                            </c:when>
                            <c:when test="${order.status eq 'CONFIRMED' or order.status eq 'PREPARING' or order.status eq 'DISPATCHED'}">
                              <span class="badge info">Đang giao</span>
                            </c:when>
                            <c:when test="${order.status eq 'DELIVERED'}">
                              <span class="badge ok">Đã giao</span>
                            </c:when>
                            <c:when test="${order.status eq 'CANCELLED' or order.status eq 'PAYMENT_FAILED' or order.status eq 'EXPIRED'}">
                              <span class="badge off">Đã hủy</span>
                            </c:when>
                            <c:otherwise>
                              <span class="badge">Khác</span>
                            </c:otherwise>
                          </c:choose>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
              </div>
            </c:otherwise>
          </c:choose>
        </div>

        <div style="flex:1; display:flex; flex-direction:column; gap:20px;">
          <div class="panel">
            <div class="panel-head">
              <h3>Trạng thái đơn hàng</h3>
            </div>
            <div class="panel-pad">
              <div style="display:flex;flex-direction:column;gap:12px;font-size:14px;">
                <div style="display:flex;justify-content:space-between">
                  <span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#f6c23e;margin-right:8px;"></span>Chờ xác nhận</span>
                  <strong><c:out value="${stats != null ? stats.pendingOrdersCount : 0}" /></strong>
                </div>
                <div style="display:flex;justify-content:space-between">
                  <span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#36b9cc;margin-right:8px;"></span>Đang giao hàng</span>
                  <strong><c:out value="${stats != null ? stats.shippingOrdersCount : 0}" /></strong>
                </div>
                <div style="display:flex;justify-content:space-between">
                  <span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#1cc88a;margin-right:8px;"></span>Giao thành công</span>
                  <strong><c:out value="${stats != null ? stats.deliveredOrdersCount : 0}" /></strong>
                </div>
                <div style="display:flex;justify-content:space-between">
                  <span><span style="display:inline-block;width:8px;height:8px;border-radius:50%;background:#e74a3b;margin-right:8px;"></span>Đã hủy</span>
                  <strong><c:out value="${stats != null ? stats.cancelledOrdersCount : 0}" /></strong>
                </div>
              </div>
            </div>
          </div>

        <c:if test="${sessionScope.user.role eq 'ADMIN'}">
          <div class="panel">
            <div class="panel-head">
              <h3>Sản phẩm bán chạy</h3>
            </div>
            <div class="panel-pad" style="display:flex;flex-direction:column;gap:12px">
              <c:forEach items="${bestSellingProducts}" var="p">
                <div style="display:flex;gap:11px;align-items:center">
                  <div class="shot" style="width:40px;height:40px;aspect-ratio:auto;border-radius:var(--r-sm);overflow:hidden;background:white;">
                    <c:choose>
                      <c:when test="${not empty p.imageUrl}">
                        <img src="${appPath}/${p.imageUrl}" alt="<c:out value='${p.name}' />" style="width:100%;height:100%;object-fit:cover;">
                      </c:when>
                      <c:otherwise>
                        <img src="${appPath}/assets/images/default-product.png" alt="<c:out value='${p.name}' />" style="width:100%;height:100%;object-fit:cover;">
                      </c:otherwise>
                    </c:choose>
                  </div>
                  <div style="flex:1;font-size:13px">
                    <b><c:out value="${p.name}" /></b><br>
                    <span style="color:var(--ash);font-size:12px"><c:out value="${p.totalSold}" /> máy | <c:out value="${p.orderCount}" /> đơn</span>
                  </div>
                  <span class="mono" style="font-size:12px"><fmt:formatNumber value="${p.totalRevenue}" type="currency" currencyCode="VND" /></span>
                </div>
              </c:forEach>
              <c:if test="${empty bestSellingProducts}">
                <div style="color:var(--ash);font-size:13px;text-align:center;">Chưa có dữ liệu.</div>
              </c:if>
            </div>
          </div>
        </c:if>
        </div>
      </div>
    </div>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<script>
    const labels = ${empty chartLabels or chartLabels eq "[]" ? "['']" : chartLabels};
    const dataValues = ${empty chartData or chartData eq "[]" ? "[0]" : chartData};
    const statusStatsData = ${orderStatusStatsJson != null ? orderStatusStatsJson : '[]'};
                            

    // Revenue Chart
    if (labels.length > 0) {
        const ctx = document.getElementById('revenueChart').getContext('2d');
        new Chart(ctx, {
            type: 'bar',
            data: {
                labels: labels,
                datasets: [{
                        label: 'Doanh thu (VNĐ)',
                        data: dataValues,
                        backgroundColor: 'rgba(54, 162, 235, 0.5)',
                        borderColor: 'rgba(54, 162, 235, 1)',
                        borderWidth: 1
                    }]
            },
            options: {responsive: true, maintainAspectRatio: false}
        });
    }

    // Order Status Doughnut Chart
    if (statusStatsData.length > 0) {
        const statusCtx = document.getElementById('orderStatusChart').getContext('2d');
        const statusLabelsVi = {
            'PENDING_PAYMENT': 'Chờ TT', 'APPROVED': 'Đã duyệt', 'CONFIRMED': 'Chờ duyệt',
            'PREPARING': 'Chuẩn bị', 'DISPATCHED': 'Đang giao', 'DELIVERED': 'Thành công',
            'CANCELLED': 'Đã hủy', 'PAYMENT_FAILED': 'TT Thất bại', 'EXPIRED': 'Hết hạn'
        };
        new Chart(statusCtx, {
            type: 'doughnut',
            data: {
                labels: statusStatsData.map(d => statusLabelsVi[d.status] || d.status),
                datasets: [{
                    data: statusStatsData.map(d => d.count),
                    backgroundColor: ['#f6c23e', '#4e73df', '#36b9cc', '#1cc88a', '#e74a3b', '#858796', '#5a5c69']
                }]
            },
            options: { responsive: true, maintainAspectRatio: false, plugins: { legend: { position: 'bottom' } } }
        });
    }

    // Validate and restrict date range dynamically
    const startDateInput = document.getElementById('startDate');
    const endDateInput = document.getElementById('endDate');

    function updateDateConstraints() {
        if (startDateInput.value) {
            endDateInput.min = startDateInput.value;
        } else {
            endDateInput.min = '';
        }
        
        if (endDateInput.value) {
            startDateInput.max = endDateInput.value;
        } else {
            startDateInput.max = '';
        }
    }

    // Apply constraints on page load and when values change
    startDateInput.addEventListener('change', updateDateConstraints);
    endDateInput.addEventListener('change', updateDateConstraints);
    updateDateConstraints(); // run once on load

    // Form validation (fallback for browsers that bypass min/max)
    function validateDateRange(form) {
        const start = form.startDate.value;
        const end = form.endDate.value;
        if (start && end) {
            if (new Date(start) > new Date(end)) {
                alert("Ngày kết thúc không được nhỏ hơn ngày bắt đầu!");
                return false;
            }
        }
        return true;
    }

    // Quick Date Range
    function setQuickDateRange(days) {
        const end = new Date();
        const start = new Date();
        start.setDate(end.getDate() - days);

        const formatDate = (date) => {
            let month = '' + (date.getMonth() + 1), day = '' + date.getDate(), year = date.getFullYear();
            if (month.length < 2) month = '0' + month;
            if (day.length < 2) day = '0' + day;
            return [year, month, day].join('-');
        };
        document.getElementsByName('startDate')[0].value = formatDate(start);
        document.getElementsByName('endDate')[0].value = formatDate(end);
        document.forms[0].submit();
    }

    // Export to CSV
    function exportToCSV() {
        const rows = [
            ["Báo Cáo Bán Hàng Sản Phẩm - AppleStore"],
            ["Giai đoạn", (document.getElementsByName('startDate')[0].value || "Tất cả") + " đến " + (document.getElementsByName('endDate')[0].value || "Tất cả")],
            [],
            ["Mã SP", "Tên Sản Phẩm", "Số lượng bán ra", "Số đơn hàng", "Tổng doanh thu"]
        ];

        const jspData = [
            <c:forEach var="p" items="${bestSellingProducts}">
                ["${p.productId}", "<c:out value='${p.name}' />", "${p.totalSold}", "${p.orderCount}", "${p.totalRevenue}"],
            </c:forEach>
        ];

        if (jspData.length === 0) {
            alert('Không có dữ liệu bán hàng nào để xuất!');
            return;
        }

        rows.push(...jspData);
        let csvContent = "";
        rows.forEach(function(rowArray) {
            let row = rowArray.map(val => {
                if (typeof val === 'string') return '"' + val.replace(/"/g, '""') + '"';
                return val;
            }).join(",");
            csvContent += row + "\r\n";
        });

        const BOM = "\uFEFF";
        const blob = new Blob([BOM + csvContent], { type: 'text/csv;charset=utf-8;' });
        const link = document.createElement("a");
        if (link.download !== undefined) {
            const url = URL.createObjectURL(blob);
            link.setAttribute("href", url);
            link.setAttribute("download", "AppleStore_BaoCao_" + new Date().toISOString().slice(0,10) + ".csv");
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
        }
    }
</script>
</body>
</html>

