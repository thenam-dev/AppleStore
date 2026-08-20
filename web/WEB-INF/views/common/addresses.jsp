<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c"   uri="jakarta.tags.core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Sổ địa chỉ · AppleStore</title>
  <link rel="icon" href="${ctx}/assets/images/logo-mark.svg" type="image/svg+xml">
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Archivo:wdth,wght@100..125,400..800&family=Be+Vietnam+Pro:wght@300;400;500;600;700&family=JetBrains+Mono:wght@400;500;700&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="${ctx}/assets/css/style.css?v=2">
  <style>
      .address-card {
          border: 1px solid var(--line);
          border-radius: var(--r-md);
          padding: 24px;
          margin-bottom: 20px;
          position: relative;
          background: #fff;
          transition: border-color 0.2s;
      }
      .address-card:hover {
          border-color: #d1d5db;
      }
      .address-header {
          display: flex;
          align-items: center;
          gap: 12px;
          margin-bottom: 8px;
      }
      .address-name {
          font-weight: 600;
          font-size: 16px;
          color: var(--txt);
          margin: 0;
      }
      .address-phone {
          color: var(--txt-2);
          font-size: 14px;
      }
      .default-badge {
          font-size: 11px;
          color: #d32f2f;
          border: 1px solid #d32f2f;
          padding: 2px 8px;
          border-radius: 4px;
          font-weight: bold;
      }
      .address-detail {
          color: var(--txt-2);
          font-size: 14px;
          margin: 4px 0 16px;
          line-height: 1.5;
      }
      .address-actions {
          display: flex;
          gap: 16px;
          align-items: center;
      }
      .action-link {
          color: var(--titan);
          font-size: 14px;
          font-weight: 500;
          text-decoration: none;
          cursor: pointer;
      }
      .action-link:hover {
          text-decoration: underline;
      }
      .set-default-btn {
          border: 1px solid var(--line);
          background: transparent;
          padding: 6px 12px;
          border-radius: 6px;
          font-size: 13px;
          font-weight: 500;
          cursor: pointer;
          color: var(--txt);
          transition: background 0.2s;
      }
      .set-default-btn:hover {
          background: #f9fafb;
      }
      /* Modal Styles */
      dialog {
          border: none;
          border-radius: var(--r-md);
          padding: 0;
          box-shadow: 0 10px 30px rgba(0,0,0,0.2);
          width: 90%;
          max-width: 600px;
      }
      dialog::backdrop {
          background: rgba(0,0,0,0.5);
      }
      .modal-header {
          padding: 24px;
          border-bottom: 1px solid var(--line);
          display: flex;
          justify-content: space-between;
          align-items: center;
      }
      .modal-header h2 {
          margin: 0;
          font-size: 18px;
          font-weight: 600;
      }
      .close-btn {
          background: none;
          border: none;
          font-size: 24px;
          cursor: pointer;
          color: var(--txt-2);
      }
      .modal-body {
          padding: 24px;
      }
      .modal-footer {
          padding: 16px 24px;
          border-top: 1px solid var(--line);
          display: flex;
          justify-content: flex-end;
          gap: 12px;
      }
  </style>
</head>
<body>

<c:set var="activeMenu" value="addresses" scope="request"/>
<jsp:include page="/WEB-INF/views/common/header.jsp"/>

<main>
    <section class="sec">
        <div class="container inner">
            
            <div class="profile-container">
                <!-- Sidebar -->
                <jsp:include page="/WEB-INF/views/common/account-sidebar.jsp"/>

                <!-- Content -->
                <div class="profile-content">
                    
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 32px; flex-wrap: wrap; gap: 16px;">
                        <div>
                            <h1 style="font-size: 24px; font-weight: 700; margin: 0 0 8px 0; color: var(--txt);">Địa chỉ của tôi</h1>
                            <p style="margin: 0; color: var(--txt-2); font-size: 14px;">Quản lý thông tin địa chỉ nhận hàng.</p>
                        </div>
                        <button class="btn titan" onclick="openModal()" style="display: flex; align-items: center; gap: 8px;">
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></svg>
                            Thêm địa chỉ mới
                        </button>
                    </div>

                    <!-- Filter/Search Form -->
                    <form action="${ctx}/addresses" method="get" style="display: flex; gap: 12px; margin-bottom: 24px; flex-wrap: wrap;">
                        <input type="text" name="keyword" value="${keyword}" placeholder="Tìm kiếm địa chỉ, tên, SĐT..." class="input" style="flex: 1; min-width: 200px;">
                        
                        <select name="filter" class="input" style="width: 150px;" onchange="this.form.submit()">
                            <option value="">Tất cả địa chỉ</option>
                            <option value="default" ${filter == 'default' ? 'selected' : ''}>Mặc định</option>
                            <option value="normal" ${filter == 'normal' ? 'selected' : ''}>Thường</option>
                        </select>
                        
                        <select name="sort" class="input" style="width: 150px;" onchange="this.form.submit()">
                            <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                            <option value="oldest" ${sort == 'oldest' ? 'selected' : ''}>Cũ nhất</option>
                        </select>
                        
                        <button type="submit" class="btn ghost">Tìm</button>
                    </form>

                    <!-- Alerts -->
                    <c:if test="${not empty requestScope.message}">
                        <div class="alert-msg success" style="margin-bottom: 24px;"><strong>Thành công!</strong> ${requestScope.message}</div>
                    </c:if>
                    <c:if test="${not empty requestScope.error}">
                        <div class="alert-msg error" style="margin-bottom: 24px;"><strong>Lỗi!</strong> ${requestScope.error}</div>
                    </c:if>

                    <!-- Address List -->
                    <div>
                        <c:choose>
                            <c:when test="${empty requestScope.addressList}">
                                <div style="text-align: center; padding: 48px; border: 1px dashed var(--line); border-radius: 8px;">
                                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="var(--txt-3)" stroke-width="1.5" style="margin-bottom: 16px;"><path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0 1 18 0z"></path><circle cx="12" cy="10" r="3"></circle></svg>
                                    <p style="color: var(--txt-2); margin-bottom: 16px; font-size: 15px;">Bạn chưa có địa chỉ giao hàng nào.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <c:forEach var="addr" items="${requestScope.addressList}">
                                    <div class="address-card">
                                        <div class="address-header">
                                            <h3 class="address-name"><c:out value="${addr.recipientName}"/></h3>
                                            <span style="color: var(--line);">|</span>
                                            <span class="address-phone"><c:out value="${addr.recipientPhone}"/></span>
                                        </div>
                                        <div class="address-detail">
                                            <c:out value="${addr.addressDetail}"/><br>
                                            <c:if test="${addr.isDefault == 1}">
                                                <br><span class="default-badge" style="display: inline-block; margin-top: 8px;">Mặc định</span>
                                            </c:if>
                                        </div>
                                        <div class="address-actions">
                                            <%-- Dùng data-* (đã escape qua c:out) + JS đọc lại thay vì nhồi thẳng vào
                                                 chuỗi JS trong onclick='...' như bản trước - vì HTML-escape (&quot;...)
                                                 KHÔNG chặn được injection ở đây: trình duyệt giải mã HTML entity trước
                                                 rồi mới đưa chuỗi cho JS parser, nên "&quot;" lại quay về thành "
                                                 đúng lúc JS đọc onclick, khiến khách vẫn thoát được ra khỏi chuỗi nếu
                                                 recipientName/địa chỉ chứa dấu ngoặc kép. --%>
                                            <a class="action-link update-address-link"
                                               data-address-id="${addr.addressId}"
                                               data-recipient-name="<c:out value='${addr.recipientName}'/>"
                                               data-recipient-phone="<c:out value='${addr.recipientPhone}'/>"
                                               data-province="<c:out value='${addr.province}'/>"
                                               data-district="<c:out value='${addr.district}'/>"
                                               data-ward="<c:out value='${addr.ward}'/>"
                                               data-address-detail="<c:out value='${addr.addressDetail}'/>">Cập nhật</a>
                                            <c:if test="${addr.isDefault == 0}">
                                                <form action="${ctx}/delete-address" method="post" style="display: inline;" onsubmit="return confirm('Bạn có chắc muốn xóa địa chỉ này?');">
                                                    <input type="hidden" name="addressId" value="${addr.addressId}">
                                                    <button type="submit" class="action-link" style="background: none; border: none; padding: 0;">Xóa</button>
                                                </form>
                                                <form action="${ctx}/set-default-address" method="post" style="display: inline; margin-left: auto;">
                                                    <input type="hidden" name="addressId" value="${addr.addressId}">
                                                    <button type="submit" class="set-default-btn">Thiết lập mặc định</button>
                                                </form>
                                            </c:if>
                                        </div>
                                    </div>
                                </c:forEach>
                            </c:otherwise>
                        </c:choose>
                    </div>

                </div>
            </div>
            
        </div>
    </section>
</main>

<!-- Address Modal (Popup) -->
<dialog id="addressModal">
    <div class="modal-header">
        <h2 id="modalTitle">Thêm địa chỉ mới</h2>
        <button class="close-btn" type="button" onclick="closeModal()">&times;</button>
    </div>
    <form id="addressForm" action="${ctx}/add-address" method="post">
        <input type="hidden" name="addressId" id="addressId" value="">
        <div class="modal-body" style="display: grid; grid-template-columns: 1fr 1fr; gap: 20px;">
            <div style="grid-column: span 1;">
                <label style="display: block; font-weight: 500; margin-bottom: 8px; font-size: 14px;">Họ và tên</label>
                <input class="input" type="text" name="recipientName" id="recipientName" required maxlength="100" style="width: 100%; border: 1px solid var(--line); padding: 10px 14px; border-radius: 8px;">
            </div>
            <div style="grid-column: span 1;">
                <label style="display: block; font-weight: 500; margin-bottom: 8px; font-size: 14px;">Số điện thoại</label>
                <input class="input" type="tel" name="recipientPhone" id="recipientPhone" required pattern="[0-9]{9,15}" title="Từ 9 đến 15 chữ số" style="width: 100%; border: 1px solid var(--line); padding: 10px 14px; border-radius: 8px;">
            </div>
            <div style="grid-column: span 2;">
                <label style="display: block; font-weight: 500; margin-bottom: 8px; font-size: 14px;">Địa chỉ cụ thể</label>
                <textarea class="input" name="addressDetail" id="addressDetail" rows="3" required maxlength="500" style="width: 100%; resize: none; border: 1px solid var(--line); padding: 10px 14px; border-radius: 8px;"></textarea>
            </div>
        </div>
        <div class="modal-footer">
            <button type="button" class="btn ghost" onclick="closeModal()">Trở lại</button>
            <button type="submit" class="btn titan">Hoàn thành</button>
        </div>
    </form>
</dialog>

<jsp:include page="/WEB-INF/views/common/footer.jsp"/>

<script>
    const modal = document.getElementById('addressModal');
    const form = document.getElementById('addressForm');
    
    function openModal(id, name, phone, detail) {
        if (id) {
            document.getElementById('modalTitle').innerText = 'Cập nhật địa chỉ';
            form.action = '${ctx}/update-address';
            document.getElementById('addressId').value = id;
            document.getElementById('recipientName').value = name;
            document.getElementById('recipientPhone').value = phone;
            document.getElementById('addressDetail').value = detail;
        } else {
            document.getElementById('modalTitle').innerText = 'Thêm địa chỉ mới';
            form.action = '${ctx}/add-address';
            form.reset();
            document.getElementById('addressId').value = '';
        }
        modal.showModal();
    }

    function closeModal() {
        modal.close();
    }

    // Uỷ quyền sự kiện click cho các nút "Cập nhật" - đọc dữ liệu qua dataset
    // (đã được c:out escape đúng chuẩn HTML attribute ở JSP) thay vì nhồi chuỗi
    // trực tiếp vào onclick='...' như trước, tránh việc khách thoát khỏi chuỗi
    // JS nếu tên/địa chỉ chứa dấu ngoặc kép.
    document.querySelectorAll('.update-address-link').forEach(function (link) {
        link.addEventListener('click', function () {
            openModal(
                link.dataset.addressId,
                link.dataset.recipientName,
                link.dataset.recipientPhone,
                link.dataset.province,
                link.dataset.district,
                link.dataset.ward,
                link.dataset.addressDetail
            );
        });
    });
</script>
</body>
</html>


