<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cửa hàng Apple Trực tuyến | Sản phẩm</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/assets/css/style.css">
</head>
<body class="site-body">

    <c:set var="ctx" value="${pageContext.request.contextPath}" />

    <%-- =====================================================
         Trang này được ProductListServlet (controller.customer.product,
         urlPatterns = {"/products"}) forward tới, với các request attribute:
             productList        : List<model.entity.catalog.Product>
             categories         : List<model.entity.catalog.Category>
             keyword, categoryId, sort, currentPage, totalPages, totalItems
             lowStockThreshold  : int
         Product KHÔNG có field "price" hay "imageUrl" trực tiếp — giá hiển
         thị ở đây là minPrice (giá thấp nhất trong các variant), và ảnh
         hiện đang dùng ảnh placeholder theo danh mục vì entity chưa có
         bảng ảnh sản phẩm riêng.
         KHÔNG có nút "Thêm vào giỏ" nhanh ở đây vì sản phẩm bắt buộc phải
         chọn variant (màu/dung lượng) trước khi thêm vào giỏ — việc đó xử
         lý ở product-detail.jsp.
    ===================================================== --%>

    <jsp:include page="/WEB-INF/views/common/header.jsp">
        <jsp:param name="active" value="products" />
    </jsp:include>

    <main>
        <section class="section-block">
            <div class="container">
                <nav aria-label="Breadcrumb">
                    <ol class="breadcrumb app-breadcrumb">
                        <li class="breadcrumb-item"><a href="${ctx}/index.jsp">Trang chủ</a></li>
                        <li class="breadcrumb-item active" aria-current="page">Sản phẩm</li>
                    </ol>
                </nav>
                <div class="store-page-heading">
                    <div>
                        <span class="eyebrow">Danh sách sản phẩm</span>
                        <h1>Danh mục thiết bị Apple</h1>
                        <p>Tìm kiếm, lọc theo danh mục và sắp xếp theo nhu cầu của bạn.</p>
                    </div>
                    <div class="store-heading-meta">
                        <strong>${totalItems}</strong>
                        <span>sản phẩm tìm thấy</span>
                    </div>
                </div>
                <c:if test="${not empty errorMsg}">
                    <div class="alert alert-danger">${errorMsg}</div>
                </c:if>
            </div>
        </section>

        <section class="section-block section-soft">
            <div class="container">
                <div class="products-layout">
                    <aside class="catalog-sidebar">
                        <form class="filter-panel" action="${ctx}/products" method="get" name="productFilterForm">
                            <div class="filter-group">
                                <label class="form-label" for="product-search">Tìm kiếm</label>
                                <input id="product-search" class="form-control" type="search" name="keyword"
                                       value="${fn:escapeXml(keyword)}" placeholder="Tìm theo tên sản phẩm">
                            </div>
                            <div class="filter-group">
                                <label class="form-label" for="filter-category">Danh mục</label>
                                <select id="filter-category" class="form-select" name="categoryId">
                                    <option value="" ${empty categoryId ? 'selected' : ''}>Tất cả danh mục</option>
                                    <c:forEach items="${categories}" var="cat">
                                        <option value="${cat.categoryId}"
                                                ${categoryId != null && categoryId == cat.categoryId ? 'selected' : ''}>
                                                ${cat.name}
                                        </option>
                                    </c:forEach>
                                </select>
                            </div>
                            <input type="hidden" name="sort" value="${sort}">
                            <button class="btn btn-app-primary w-100 mb-2" type="submit">Áp dụng</button>
                            <a class="btn btn-app-outline w-100" href="${ctx}/products">Xoá bộ lọc</a>
                        </form>
                    </aside>

                    <div class="catalog-content">
                        <div class="store-toolbar">
                            <div class="product-count-text">
                                Hiển thị <strong>${fn:length(productList)}</strong> / ${totalItems} sản phẩm
                                &ndash; trang ${currentPage} / ${totalPages}
                            </div>
                            <div class="store-toolbar-sort">
                                <form action="${ctx}/products" method="get" name="productSortForm">
                                    <input type="hidden" name="keyword" value="${fn:escapeXml(keyword)}">
                                    <input type="hidden" name="categoryId" value="${categoryId}">
                                    <label class="visually-hidden" for="product-sort">Sắp xếp</label>
                                    <select id="product-sort" class="form-select" name="sort" onchange="this.form.submit()">
                                        <option value="featured" ${sort == 'featured' ? 'selected' : ''}>Nổi bật</option>
                                        <option value="newest" ${sort == 'newest' ? 'selected' : ''}>Mới nhất</option>
                                        <option value="best-selling" ${sort == 'best-selling' ? 'selected' : ''}>Bán chạy</option>
                                        <option value="price-asc" ${sort == 'price-asc' ? 'selected' : ''}>Giá tăng dần</option>
                                        <option value="price-desc" ${sort == 'price-desc' ? 'selected' : ''}>Giá giảm dần</option>
                                    </select>
                                </form>
                            </div>
                        </div>

                        <c:choose>
                            <c:when test="${empty productList}">
                                <div class="list-empty-state">
                                    <h3>Không tìm thấy sản phẩm phù hợp</h3>
                                    <p>Hãy thử từ khoá khác hoặc xoá bớt bộ lọc hiện tại.</p>
                                </div>
                            </c:when>
                            <c:otherwise>
                                <div class="row g-4 product-grid">
                                    <c:forEach items="${productList}" var="p">
                                        <div class="col-md-6 col-xl-4">
                                            <article class="product-card">
                                                <div class="product-card-media">
                                                    <c:if test="${p.featured}">
                                                        <span class="app-badge badge-new">Nổi bật</span>
                                                    </c:if>
                                                    <%-- Product chưa có field ảnh riêng -> dùng ảnh placeholder theo danh mục --%>
                                                    <img src="${ctx}/assets/images/iphone-card.svg" alt="${p.name}">
                                                </div>
                                                <div class="product-card-body">
                                                    <div class="product-meta">
                                                        <c:choose>
                                                            <c:when test="${p.totalStock <= 0}">
                                                                <span class="status-badge status-out-stock">Hết hàng</span>
                                                            </c:when>
                                                            <c:when test="${p.totalStock < lowStockThreshold}">
                                                                <span class="status-badge status-low-stock">Sắp hết hàng</span>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <span class="status-badge status-in-stock">Còn hàng</span>
                                                            </c:otherwise>
                                                        </c:choose>
                                                        <button class="wishlist-button" type="button">Lưu</button>
                                                    </div>
                                                    <h3>${p.name}</h3>
                                                    <p>${p.categoryName}</p>
                                                    <div class="product-price">
                                                        <c:choose>
                                                            <c:when test="${p.variantCount > 1}">
                                                                <strong>Từ <fmt:formatNumber value="${p.minPrice}" pattern="#,##0"/> VND</strong>
                                                            </c:when>
                                                            <c:otherwise>
                                                                <strong><fmt:formatNumber value="${p.minPrice}" pattern="#,##0"/> VND</strong>
                                                            </c:otherwise>
                                                        </c:choose>
                                                    </div>
                                                    <div class="product-actions">
                                                        <a class="btn btn-app-primary w-100" href="${ctx}/product?id=${p.productId}">Xem chi tiết</a>
                                                    </div>
                                                </div>
                                            </article>
                                        </div>
                                    </c:forEach>
                                </div>

                                <nav aria-label="Product pagination" class="pt-4">
                                    <ul class="pagination app-pagination justify-content-center">
                                        <li class="page-item ${currentPage <= 1 ? 'disabled' : ''}">
                                            <c:url var="prevUrl" value="/products">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="categoryId" value="${categoryId}"/>
                                                <c:param name="sort" value="${sort}"/>
                                                <c:param name="page" value="${currentPage - 1}"/>
                                            </c:url>
                                            <a class="page-link" href="${prevUrl}">Trước</a>
                                        </li>
                                        <c:forEach begin="1" end="${totalPages}" var="pg">
                                            <c:url var="pageUrl" value="/products">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="categoryId" value="${categoryId}"/>
                                                <c:param name="sort" value="${sort}"/>
                                                <c:param name="page" value="${pg}"/>
                                            </c:url>
                                            <li class="page-item ${pg == currentPage ? 'active' : ''}">
                                                <a class="page-link" href="${pageUrl}">${pg}</a>
                                            </li>
                                        </c:forEach>
                                        <li class="page-item ${currentPage >= totalPages ? 'disabled' : ''}">
                                            <c:url var="nextUrl" value="/products">
                                                <c:param name="keyword" value="${keyword}"/>
                                                <c:param name="categoryId" value="${categoryId}"/>
                                                <c:param name="sort" value="${sort}"/>
                                                <c:param name="page" value="${currentPage + 1}"/>
                                            </c:url>
                                            <a class="page-link" href="${nextUrl}">Sau</a>
                                        </li>
                                    </ul>
                                </nav>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/views/common/footer.jsp" />

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
    <script src="${ctx}/assets/js/main.js"></script>
</body>
</html>
