<%--
  admin/product-form.jsp — dùng chung cho thêm mới và chỉnh sửa sản phẩm.
  Servlet cần set:
    form       : Product{id,name,sku,categoryId,price,oldPrice,stock,shortDesc,
                          images=List<String>,active,pinned,couponId}
    categories : List<Category> đang bán, để đổ vào select
    coupons    : List<Coupon> đang chạy
    specRows   : List<{label,value}> thông số kỹ thuật hiện có (rỗng nếu thêm mới)
    errors     : Map<String,String>
    uploadError: thông báo khi upload sai định dạng/ dung lượng
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<c:set var="ctx" value="${pageContext.request.contextPath}"/>
<c:set var="isNew" value="${empty form.id}"/>
<!DOCTYPE html>
<html lang="vi">
<head>
  <c:set var="pageTitle" value="${isNew ? 'Thêm' : 'Sửa'} sản phẩm · Quản trị HALO"/>
  <jsp:include page="/WEB-INF/views/common/head.jsp"/>
</head>
<body class="admin">
<jsp:include page="/WEB-INF/views/common/icons.jsp"/>

<div class="adm">
  <c:set var="activeAdmin" value="products"/>
  <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp"/>

  <div class="adm-main">
    <div class="adm-bar">
      <h2>${isNew ? 'Thêm sản phẩm' : 'Sửa sản phẩm'}</h2>
      <div class="who">
        <a class="btn ghost sm" href="${ctx}/admin/products">Huỷ</a>
        <button type="submit" form="prodForm" name="action" value="draft" class="btn ghost sm">Lưu nháp</button>
        <button type="submit" form="prodForm" name="action" value="publish" class="btn sm">Lưu và mở bán</button>
      </div>
    </div>

    <div class="adm-body">
      <jsp:include page="/WEB-INF/views/common/flash.jsp"/>

      <form id="prodForm" method="post" action="${ctx}/admin/product/save" enctype="multipart/form-data">
        <input type="hidden" name="id" value="${form.id}">
        <div class="split">
          <div style="display:flex;flex-direction:column;gap:18px">

            <div class="panel"><div class="panel-head"><h3>Thông tin cơ bản</h3></div><div class="panel-pad">
              <div class="field ${not empty errors.name ? 'err' : ''}">
                <label>Tên sản phẩm <span class="req">*</span></label>
                <input class="input" type="text" name="name" maxlength="100" value="<c:out value='${form.name}'/>">
                <c:if test="${not empty errors.name}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.name}"/></div></c:if>
              </div>
              <div class="grid-2">
                <div class="field ${not empty errors.sku ? 'err' : ''}">
                  <label>Mã sản phẩm <span class="req">*</span></label>
                  <input class="input" type="text" name="sku" maxlength="40" value="<c:out value='${form.sku}'/>">
                  <c:choose>
                    <c:when test="${not empty errors.sku}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.sku}"/></div></c:when>
                    <c:otherwise><div class="help">Viết hoa, không dấu, không khoảng trắng</div></c:otherwise>
                  </c:choose>
                </div>
                <div class="field">
                  <label>Danh mục <span class="req">*</span></label>
                  <select class="select" name="categoryId">
                    <c:forEach var="cat" items="${categories}">
                      <option value="${cat.id}" ${cat.id == form.categoryId ? 'selected' : ''}><c:out value="${cat.name}"/></option>
                    </c:forEach>
                  </select>
                </div>
              </div>
              <div class="grid-3">
                <div class="field ${not empty errors.price ? 'err' : ''}">
                  <label>Giá bán <span class="req">*</span></label>
                  <input class="input" type="text" inputmode="numeric" name="price" value="<c:out value='${form.price}'/>">
                  <c:choose>
                    <c:when test="${not empty errors.price}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.price}"/></div></c:when>
                    <c:otherwise><div class="help">Đơn vị: đồng</div></c:otherwise>
                  </c:choose>
                </div>
                <div class="field">
                  <label>Giá gạch ngang</label>
                  <input class="input" type="text" inputmode="numeric" name="oldPrice" value="<c:out value='${form.oldPrice}'/>">
                </div>
                <div class="field ${not empty errors.stock ? 'err' : ''}">
                  <label>Tồn kho <span class="req">*</span></label>
                  <input class="input" type="number" name="stock" min="0" value="${form.stock}">
                  <c:if test="${not empty errors.stock}"><div class="err-msg"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${errors.stock}"/></div></c:if>
                </div>
              </div>
              <div class="field" style="margin-bottom:0">
                <label>Mô tả ngắn</label>
                <textarea class="textarea" name="shortDesc" maxlength="500"><c:out value="${form.shortDesc}"/></textarea>
                <div class="help">Tối đa 500 ký tự, hiển thị ngay dưới tên sản phẩm</div>
              </div>
            </div></div>

            <div class="panel"><div class="panel-head"><h3>Thông số kỹ thuật</h3>
              <div class="r"><button type="button" class="btn ghost sm" id="addSpecRow"><svg width="14" height="14"><use href="#i-plus"/></svg>Thêm dòng</button></div>
            </div><div class="panel-pad" id="specRows">
              <c:forEach var="row" items="${specRows}" varStatus="st">
                <div style="display:flex;gap:10px;margin-bottom:10px" class="spec-row">
                  <input class="input" type="text" name="specLabel" maxlength="50" style="max-width:200px" value="<c:out value='${row.label}'/>" placeholder="Tên thông số">
                  <input class="input" type="text" name="specValue" maxlength="200" value="<c:out value='${row.value}'/>" placeholder="Giá trị">
                  <button type="button" class="icon-btn remove-spec-row"><svg width="14" height="14"><use href="#i-trash"/></svg></button>
                </div>
              </c:forEach>
              <c:if test="${empty specRows}">
                <div style="display:flex;gap:10px;margin-bottom:10px" class="spec-row">
                  <input class="input" type="text" name="specLabel" maxlength="50" style="max-width:200px" placeholder="Tên thông số">
                  <input class="input" type="text" name="specValue" maxlength="200" placeholder="Giá trị">
                  <button type="button" class="icon-btn remove-spec-row"><svg width="14" height="14"><use href="#i-trash"/></svg></button>
                </div>
              </c:if>
            </div></div>
          </div>

          <div style="display:flex;flex-direction:column;gap:18px">
            <div class="panel"><div class="panel-head"><h3>Ảnh sản phẩm</h3></div><div class="panel-pad">
              <div style="border:1px dashed var(--line);border-radius:var(--r-md);padding:26px;text-align:center">
                <div class="shot" style="width:76px;height:76px;aspect-ratio:auto;margin:0 auto 12px">
                  <svg style="color:#5B6472"><use href="#${empty form.iconKey ? 'd-acc' : form.iconKey}"/></svg>
                </div>
                <input type="file" name="images" id="imgInput" accept="image/png,image/jpeg" multiple class="sr-only">
                <label for="imgInput" class="btn ghost sm" style="cursor:pointer">Chọn ảnh từ máy</label>
                <div class="help" style="margin-top:8px">Chấp nhận jpg, jpeg, png · tối đa 2MB · nên dùng ảnh vuông 1000×1000</div>
              </div>
              <c:if test="${not empty uploadError}">
                <div class="err-msg" style="margin-top:10px"><svg width="14" height="14"><use href="#i-alert"/></svg><c:out value="${uploadError}"/></div>
              </c:if>
              <c:if test="${not empty form.images}">
                <div style="display:grid;grid-template-columns:repeat(4,1fr);gap:8px;margin-top:12px">
                  <c:forEach var="img" items="${form.images}">
                    <div class="shot"><img src="${ctx}/uploads/${img}" alt=""></div>
                  </c:forEach>
                </div>
              </c:if>
            </div></div>

            <div class="panel"><div class="panel-head"><h3>Hiển thị</h3></div><div class="panel-pad">
              <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                <input type="checkbox" name="active" id="pActive" value="1" ${form.active ? 'checked' : ''}>
                <label for="pActive" style="margin:0;font-weight:400;font-size:13.5px">Đang bán</label>
              </div>
              <div style="display:flex;align-items:center;gap:10px;margin-bottom:14px">
                <input type="checkbox" name="pinned" id="pPin" value="1" ${form.pinned ? 'checked' : ''}>
                <label for="pPin" style="margin:0;font-weight:400;font-size:13.5px">Ghim lên trang chủ</label>
              </div>
              <div class="field" style="margin-bottom:0">
                <label>Khuyến mãi áp dụng</label>
                <select class="select" name="couponId">
                  <option value="">Không áp dụng</option>
                  <c:forEach var="cp" items="${coupons}">
                    <option value="${cp.id}" ${cp.id == form.couponId ? 'selected' : ''}><c:out value="${cp.code}"/> · <c:out value="${cp.shortDesc}"/></option>
                  </c:forEach>
                </select>
              </div>
            </div></div>

            <div class="note-box"><b>Nhắc trước khi commit:</b> kiểm tra tên rỗng, tên toàn dấu cách,
              tên vượt độ dài cột trong cơ sở dữ liệu, giá âm và tồn kho âm.</div>
          </div>
        </div>
      </form>
    </div>
  </div>
</div>

<script>
document.getElementById('addSpecRow').addEventListener('click', function () {
  var wrap = document.getElementById('specRows');
  var row = document.createElement('div');
  row.className = 'spec-row';
  row.style.cssText = 'display:flex;gap:10px;margin-bottom:10px';
  row.innerHTML =
    '<input class="input" type="text" name="specLabel" maxlength="50" style="max-width:200px" placeholder="Tên thông số">' +
    '<input class="input" type="text" name="specValue" maxlength="200" placeholder="Giá trị">' +
    '<button type="button" class="icon-btn remove-spec-row"><svg width="14" height="14"><use href="#i-trash"/></svg></button>';
  wrap.appendChild(row);
});
document.getElementById('specRows').addEventListener('click', function (e) {
  var btn = e.target.closest('.remove-spec-row');
  if (btn) { btn.closest('.spec-row').remove(); }
});
</script>
</body>
</html>
