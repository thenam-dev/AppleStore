<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%
    String appPath = request.getContextPath();
    
    Double totalRevenue = (Double) request.getAttribute("totalRevenue");
    if (totalRevenue == null) {
        totalRevenue = 0.0;
    }

    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("vi", "VN"));
%>
<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Apple Online Shop Admin | Báo cáo doanh thu</title>
        <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
        <link rel="stylesheet" href="<%= appPath %>/assets/css/style.css">
    </head>
    <body class="site-body admin-app">
        <main class="admin-workspace">
            <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

            <section class="admin-main">    
                <div class="admin-page-head">
                    <div>
                        <h1>Báo cáo doanh thu</h1>
                        <p>Phân tích tổng quan và chi tiết doanh thu theo thời gian.</p>
                    </div>
                </div>
                
                <form action="<%= appPath %>/admin/report" method="GET" class="d-flex gap-2 align-items-center mb-4">
                    <label>Từ:</label>
                    <input type="date" name="startDate" class="form-control" value="${param.startDate}">
                    <label>Đến:</label>
                    <input type="date" name="endDate" class="form-control" value="${param.endDate}">
                    <button type="submit" class="btn btn-primary">Lọc</button>
                </form>

                <div class="admin-panel mt-4 mb-4">
                    <div class="admin-panel-head">
                        <h2>Tổng doanh thu: <%= currencyFormatter.format(totalRevenue) %></h2>
                    </div>
                    <div class="admin-chart-placeholder" style="padding: 20px;">
                        <canvas id="revenueChart" style="max-height: 400px; width: 100%;"></canvas>
                    </div>
                </div>
            </section>
        </main>
        <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
        <script src="<%= appPath %>/assets/js/main.js"></script>
        <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
        <script>
            const labels = ${chartLabels != null ? chartLabels : '[]'};
            const dataValues = ${chartData != null ? chartData : '[]'};

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
        </script>
    </body>
</html>
