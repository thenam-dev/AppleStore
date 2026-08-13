<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty variant and variant.variantId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Edit' : 'Create'}" />
<c:set var="adminSidebarTitle" scope="request" value="${formModeLabel} Variant" />
<c:set var="adminSidebarDescription" scope="request" value="Variant-level pricing, stock, and sellable SKU data." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Variant form" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Use this form to feed cart and checkout with valid variant data." />
<c:set var="adminSidebarActive" scope="request" value="products" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | ${formModeLabel} Variant</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/products/variants" method="get" name="adminVariantSearchForm">
                    <label class="visually-hidden" for="admin-variant-search">Search variants</label>
                    <input type="hidden" name="productId" value="${managedProduct.productId}">
                    <input id="admin-variant-search" class="form-control" type="search" name="keyword" placeholder="Search variant list">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}">Back to Variants</a>
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Back to Products</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/products">Products</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/products/variants?productId=${managedProduct.productId}">Variants</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${formModeLabel}</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Variant management</span>
                    <h1>${formModeLabel} variant</h1>
                    <p>Product: <strong><c:out value="${managedProduct.name}" /></strong> (${managedProduct.status})</p>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Variant information</h2>
                        <p>These fields map directly to the `product_variants` table and provide sellable SKU data.</p>
                    </div>
                </div>

                <form class="admin-form-stack" action="${appPath}/admin/products/variants/update" method="post">
                    <input type="hidden" name="productId" value="${managedProduct.productId}">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="variantId" value="${variant.variantId}">
                    </c:if>

                    <div class="admin-form-grid">
                        <div>
                            <label class="form-label" for="sku">SKU</label>
                            <input id="sku" class="form-control" type="text" name="sku" maxlength="50" value="${fn:escapeXml(variant.sku)}" required>
                        </div>
                        <div>
                            <label class="form-label" for="status">Status</label>
                            <select id="status" class="form-select" name="status" required>
                                <c:forEach var="status" items="${variantStatusOptions}">
                                    <c:choose>
                                        <c:when test="${(variant.active and status eq 'ACTIVE') or (not variant.active and status eq 'INACTIVE')}">
                                            <option value="${fn:escapeXml(status)}" selected><c:out value="${status}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(status)}"><c:out value="${status}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="field-span-full">
                            <label class="form-label" for="variantLabel">Variant label</label>
                            <input id="variantLabel" class="form-control" type="text" name="variantLabel" maxlength="150" value="${fn:escapeXml(variant.variantLabel)}" required>
                        </div>
                        <div>
                            <label class="form-label" for="colorName">Color name</label>
                            <input id="colorName" class="form-control" type="text" name="colorName" maxlength="50" value="${fn:escapeXml(variant.colorName)}">
                        </div>
                        <div>
                            <label class="form-label" for="colorHex">Color hex</label>
                            <input id="colorHex" class="form-control" type="text" name="colorHex" maxlength="7" placeholder="#1D1D1F" value="${fn:escapeXml(variant.colorHex)}">
                        </div>
                        <div>
                            <label class="form-label" for="storageCapacityGb">Storage (GB)</label>
                            <input id="storageCapacityGb" class="form-control" type="number" name="storageCapacityGb" min="0" value="${variant.storageCapacityGb}">
                        </div>
                        <div>
                            <label class="form-label" for="ramGb">RAM (GB)</label>
                            <input id="ramGb" class="form-control" type="number" name="ramGb" min="0" value="${variant.ramGb}">
                        </div>
                        <div>
                            <label class="form-label" for="connectivity">Connectivity</label>
                            <select id="connectivity" class="form-select" name="connectivity">
                                <option value="">Select connectivity</option>
                                <c:forEach var="connectivity" items="${variantConnectivityOptions}">
                                    <c:choose>
                                        <c:when test="${variant.connectivity eq connectivity}">
                                            <option value="${fn:escapeXml(connectivity)}" selected><c:out value="${connectivity}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(connectivity)}"><c:out value="${connectivity}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="chipOption">Chip option</label>
                            <input id="chipOption" class="form-control" type="text" name="chipOption" maxlength="50" value="${fn:escapeXml(variant.chipOption)}">
                        </div>
                        <div>
                            <label class="form-label" for="screenSizeInch">Screen size (inch)</label>
                            <input id="screenSizeInch" class="form-control" type="number" step="0.1" min="0.1" name="screenSizeInch" value="${variant.screenSizeInch}">
                        </div>
                        <div>
                            <label class="form-label" for="price">Price</label>
                            <input id="price" class="form-control" type="number" step="0.01" min="0" name="price" value="${variant.price}" required>
                        </div>
                        <div>
                            <label class="form-label" for="stockQuantity">Stock quantity</label>
                            <input id="stockQuantity" class="form-control" type="number" min="0" name="stockQuantity" value="${variant.stockQuantity}" required>
                        </div>
                        <div>
                            <label class="form-label" for="weightKg">Weight (kg)</label>
                            <input id="weightKg" class="form-control" type="number" step="0.001" min="0.001" name="weightKg" value="${variant.weightKg}" required>
                        </div>
                        <div>
                            <label class="form-label" for="discountPrice">Discount price</label>
                            <input id="discountPrice" class="form-control" type="number" step="0.01" min="0" name="discountPrice" value="${variant.discountPrice}">
                        </div>
                        <div>
                            <label class="form-label" for="discountStart">Discount start</label>
                            <input id="discountStart" class="form-control" type="datetime-local" name="discountStart" value="${discountStartValue}">
                        </div>
                        <div>
                            <label class="form-label" for="discountEnd">Discount end</label>
                            <input id="discountEnd" class="form-control" type="datetime-local" name="discountEnd" value="${discountEndValue}">
                        </div>
                    </div>

                    <div class="admin-summary-card">
                        <span>Done condition</span>
                        <strong>Variant data can feed cart and checkout tests</strong>
                        <small class="admin-note">A valid variant should have active status, a unique SKU, a positive weight, a non-negative price, and stock greater than zero for sellable test cases.</small>
                    </div>

                    <div class="admin-form-actions mt-4">
                        <a class="btn btn-app-outline" href="${appPath}/admin/products/variants?productId=${managedProduct.productId}">Cancel</a>
                        <c:choose>
                            <c:when test="${isEdit}">
                                <button class="btn btn-app-primary" type="submit">Save Changes</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-app-primary" type="submit">Create Variant</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </section>
        </section>
    </main>
</body>
</html>
