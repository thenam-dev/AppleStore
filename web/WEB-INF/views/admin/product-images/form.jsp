<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="pageTitle" value="Ảnh sản phẩm · Quản trị HALO" />
<!DOCTYPE html>
<html lang="vi">
<head>
  <jsp:include page="/WEB-INF/views/common/head.jsp" />
  <style>
    .image-upload-feedback { margin-top: 10px; font-size: 12px; }
    .image-upload-feedback.error { color: #b42318; }
    .image-upload-feedback.summary { color: var(--ash); }
    .image-preview { display:grid; grid-template-columns:repeat(auto-fill,minmax(190px,1fr)); gap:10px; margin-top:12px; }
    .image-preview-item { display:flex; align-items:center; gap:8px; min-width:0; border:1px solid var(--line); padding:8px; background:var(--paper); }
    .image-preview-item img { width:52px; height:52px; flex:0 0 52px; object-fit:cover; background:#f5f5f5; }
    .image-preview-meta { min-width:0; flex:1; }
    .image-preview-name { overflow:hidden; text-overflow:ellipsis; white-space:nowrap; font-size:12px; }
    .image-preview-size { color:var(--ash); font-size:11px; margin-top:3px; }
    .image-preview-remove { border:0; background:transparent; color:var(--ash); cursor:pointer; padding:4px 6px; }
    .image-preview-remove:hover { color:var(--ink); }
    .product-image-grid { display:grid; grid-template-columns:repeat(auto-fill,minmax(190px,1fr)); gap:14px; }
    .product-image-card { border:1px solid var(--line); padding:10px; background:var(--paper); }
    .product-image-card img { display:block; width:100%; height:170px; object-fit:contain; background:#f5f5f5; }
    .product-image-card-actions { display:flex; align-items:center; justify-content:space-between; gap:8px; margin-top:10px; }
    .image-primary-label { font-size:11px; color:var(--gold); font-weight:700; }
    @media (max-width:700px) { .product-image-grid { grid-template-columns:repeat(2,minmax(0,1fr)); } .product-image-card img { height:130px; } }
  </style>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp" />
<div class="adm">
  <c:set var="activeAdmin" value="products" />
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

  <div class="adm-main">
    <div class="adm-bar">
      <div>
        <h2>Ảnh sản phẩm</h2>
        <span class="mono" style="font-size:11px;color:var(--ash)">${fn:escapeXml(product.name)} · ID ${product.productId}</span>
      </div>
      <div class="who">
        <a class="btn ghost sm" href="${appPath}/admin/products">Sản phẩm</a>
        <a class="btn ghost sm" href="${appPath}/admin/products/edit?id=${product.productId}">Sửa thông tin</a>
        <a class="btn ghost sm" href="${appPath}/admin/products/variants?productId=${product.productId}">Biến thể</a>
        <a class="btn ghost sm" href="${appPath}/admin/products/specifications?productId=${product.productId}">Thông số</a>
      </div>
    </div>

    <div class="adm-body">
      <nav aria-label="Breadcrumb" style="margin-bottom:16px;font-size:13px;color:var(--ash)">
        <a href="${appPath}/admin/products">Sản phẩm</a><span style="margin:0 8px">/</span>
        <span>${fn:escapeXml(product.name)}</span><span style="margin:0 8px">/</span><strong style="color:var(--ink)">Ảnh</strong>
      </nav>
      <jsp:include page="/WEB-INF/views/common/flash.jsp" />

      <section class="panel">
        <div class="panel-head"><h3>Thêm ảnh</h3></div>
        <div class="panel-pad">
          <form id="imageUploadForm" action="${appPath}/admin/products/images/upload" method="post" enctype="multipart/form-data">
            <input type="hidden" name="productId" value="${product.productId}">
            <div class="field">
              <label for="productImages">Chọn ảnh sản phẩm</label>
              <input id="productImages" class="input" type="file" name="images" accept="image/jpeg,image/png,image/webp" multiple data-max-file-bytes="5242880" data-max-total-bytes="31457280">
              <small style="display:block;margin-top:6px;color:var(--ash)">JPG, PNG hoặc WebP. Tối đa 5MB mỗi ảnh, tổng mỗi lần upload tối đa 30MB.</small>
              <div id="imageUploadFeedback" class="image-upload-feedback" aria-live="polite"></div>
            </div>
            <div id="imagePreview" class="image-preview" hidden></div>
            <div style="display:flex;justify-content:flex-end;margin-top:14px">
              <button id="imageUploadSubmit" class="btn" type="submit" disabled>Thêm ảnh</button>
            </div>
          </form>
        </div>
      </section>

      <section class="panel" style="margin-top:16px">
        <div class="panel-head" style="display:flex;align-items:center;justify-content:space-between;gap:16px">
          <h3>Thư viện ảnh</h3>
          <span style="font-size:12px;color:var(--ash)">${fn:length(productImages)} ảnh</span>
        </div>
        <div class="panel-pad">
          <c:choose>
            <c:when test="${not empty productImages}">
              <div class="product-image-grid">
                <c:forEach var="image" items="${productImages}">
                  <c:choose>
                    <c:when test="${fn:startsWith(image.filePath, '/')}">
                      <c:set var="imageUrl" value="${appPath}${image.filePath}" />
                    </c:when>
                    <c:otherwise>
                      <c:set var="imageUrl" value="${appPath}/${image.filePath}" />
                    </c:otherwise>
                  </c:choose>
                  <div class="product-image-card">
                    <img src="${fn:escapeXml(imageUrl)}" alt="Ảnh ${fn:escapeXml(product.name)}">
                    <div class="product-image-card-actions">
                      <c:choose>
                        <c:when test="${image.primary}">
                          <span class="image-primary-label">ẢNH CHÍNH</span>
                        </c:when>
                        <c:otherwise>
                          <form action="${appPath}/admin/products/images/primary" method="post">
                            <input type="hidden" name="productId" value="${product.productId}">
                            <input type="hidden" name="imageId" value="${image.imageId}">
                            <button class="btn ghost sm" type="submit">Đặt ảnh chính</button>
                          </form>
                        </c:otherwise>
                      </c:choose>
                      <form action="${appPath}/admin/products/images/delete" method="post" onsubmit="return confirm('Xóa ảnh này?');">
                        <input type="hidden" name="productId" value="${product.productId}">
                        <input type="hidden" name="imageId" value="${image.imageId}">
                        <button class="btn ghost sm" type="submit">Xóa</button>
                      </form>
                    </div>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:otherwise>
              <div style="padding:26px 0;text-align:center;color:var(--ash)">Sản phẩm chưa có ảnh. Hãy chọn ảnh ở khu vực phía trên.</div>
            </c:otherwise>
          </c:choose>
        </div>
      </section>
    </div>
  </div>
</div>
<script>
(function () {
  var input = document.getElementById('productImages');
  var submit = document.getElementById('imageUploadSubmit');
  var feedback = document.getElementById('imageUploadFeedback');
  var preview = document.getElementById('imagePreview');
  var selectedFiles = [];
  var allowedTypes = ['image/jpeg', 'image/png', 'image/webp'];

  function formatBytes(bytes) {
    if (bytes < 1024 * 1024) return Math.ceil(bytes / 1024) + ' KB';
    return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
  }

  function validType(file) {
    return allowedTypes.indexOf(file.type) >= 0 || /\.(jpe?g|png|webp)$/i.test(file.name);
  }

  function syncFiles() {
    var transfer = new DataTransfer();
    selectedFiles.forEach(function (file) { transfer.items.add(file); });
    input.files = transfer.files;
  }

  function render() {
    var maxFile = Number(input.dataset.maxFileBytes);
    var maxTotal = Number(input.dataset.maxTotalBytes);
    var total = selectedFiles.reduce(function (sum, file) { return sum + file.size; }, 0);
    var error = '';
    selectedFiles.some(function (file) {
      if (!validType(file)) { error = file.name + ': chỉ hỗ trợ JPG, PNG hoặc WebP.'; return true; }
      if (file.size > maxFile) { error = file.name + ': kích thước vượt quá 5MB.'; return true; }
      return false;
    });
    if (!error && total > maxTotal) error = 'Tổng dung lượng ảnh vượt quá 30MB.';

    feedback.className = 'image-upload-feedback ' + (error ? 'error' : 'summary');
    feedback.textContent = error || (selectedFiles.length ? selectedFiles.length + ' ảnh · ' + formatBytes(total) : '');
    submit.disabled = Boolean(error) || selectedFiles.length === 0;
    preview.innerHTML = '';
    preview.hidden = selectedFiles.length === 0;
    selectedFiles.forEach(function (file, index) {
      var item = document.createElement('div'); item.className = 'image-preview-item';
      var image = document.createElement('img'); var url = URL.createObjectURL(file); image.src = url; image.alt = '';
      image.onload = function () { URL.revokeObjectURL(url); };
      var meta = document.createElement('div'); meta.className = 'image-preview-meta';
      var name = document.createElement('div'); name.className = 'image-preview-name'; name.textContent = file.name;
      var size = document.createElement('div'); size.className = 'image-preview-size'; size.textContent = formatBytes(file.size);
      meta.appendChild(name); meta.appendChild(size);
      var remove = document.createElement('button'); remove.type = 'button'; remove.className = 'image-preview-remove'; remove.textContent = 'Bỏ'; remove.title = 'Bỏ ảnh này';
      remove.addEventListener('click', function () { selectedFiles.splice(index, 1); syncFiles(); render(); });
      item.appendChild(image); item.appendChild(meta); item.appendChild(remove); preview.appendChild(item);
    });
  }

  input.addEventListener('change', function () {
    Array.from(input.files).forEach(function (file) {
      var exists = selectedFiles.some(function (current) { return current.name === file.name && current.size === file.size && current.lastModified === file.lastModified; });
      if (!exists) selectedFiles.push(file);
    });
    syncFiles(); render();
  });
  input.form.addEventListener('submit', function (event) {
    render();
    if (submit.disabled) { event.preventDefault(); return; }
    submit.disabled = true; submit.textContent = 'Đang tải ảnh...';
  });
  render();
}());
</script>
</body>
</html>
