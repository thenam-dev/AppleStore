<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty product and product.productId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Edit' : 'Create'}" />
<c:set var="adminSidebarTitle" scope="request" value="${isEdit ? 'Edit Product' : 'Create Product'}" />
<c:set var="adminSidebarDescription" scope="request" value="Validate in service, persist through DAO." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Product form" />
<c:set var="adminSidebarFooterDescription" scope="request" value="This first form focuses on product master data only. Variant and media management come next." />
<c:set var="adminSidebarActive" scope="request" value="products" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | ${formModeLabel} Product</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/products" method="get" name="adminProductSearchForm">
                    <label class="visually-hidden" for="admin-product-search">Search products</label>
                    <input id="admin-product-search" class="form-control" type="search" name="keyword" placeholder="Search by product name or model code">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/products">Back to Products</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/products">Products</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${formModeLabel}</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Product management</span>
                    <h1>${formModeLabel} product</h1>
                    <p>Product master data first. Variant-level pricing, stock, and media will be added after this core flow is stable.</p>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Basic information</h2>
                        <p>These fields map directly to the `products` table in AppleStore.</p>
                    </div>
                </div>

                <form class="admin-form-stack" action="${appPath}/admin/products/update" method="post">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="productId" value="${product.productId}">
                    </c:if>

                    <div class="admin-form-grid">
                        <div class="field-span-full">
                            <label class="form-label" for="name">Product name</label>
                            <input id="name" class="form-control" type="text" name="name" maxlength="200" value="${fn:escapeXml(product.name)}" required>
                        </div>
                        <div>
                            <label class="form-label" for="categoryId">Category</label>
                            <select id="categoryId" class="form-select" name="categoryId" required>
                                <option value="">Select category</option>
                                <c:forEach var="category" items="${categories}">
                                    <c:choose>
                                        <c:when test="${product.categoryId eq category.categoryId}">
                                            <option value="${category.categoryId}" selected><c:out value="${category.name}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${category.categoryId}"><c:out value="${category.name}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="status">Status</label>
                            <select id="status" class="form-select" name="status" required>
                                <c:forEach var="status" items="${productStatusOptions}">
                                    <c:choose>
                                        <c:when test="${product.status eq status}">
                                            <option value="${fn:escapeXml(status)}" selected><c:out value="${status}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(status)}"><c:out value="${status}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="modelCode">Model code</label>
                            <input id="modelCode" class="form-control" type="text" name="modelCode" maxlength="50" value="${fn:escapeXml(product.modelCode)}">
                        </div>
                        <div>
                            <label class="form-label" for="releaseYear">Release year</label>
                            <input id="releaseYear" class="form-control" type="number" name="releaseYear" min="1998" max="2100" value="${product.releaseYear}">
                        </div>
                        <div>
                            <label class="form-label" for="productCondition">Condition</label>
                            <select id="productCondition" class="form-select" name="productCondition" required>
                                <c:forEach var="condition" items="${productConditionOptions}">
                                    <c:choose>
                                        <c:when test="${product.productCondition eq condition}">
                                            <option value="${fn:escapeXml(condition)}" selected><c:out value="${condition}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(condition)}"><c:out value="${condition}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="importType">Import type</label>
                            <select id="importType" class="form-select" name="importType" required>
                                <c:forEach var="importType" items="${productImportTypeOptions}">
                                    <c:choose>
                                        <c:when test="${product.importType eq importType}">
                                            <option value="${fn:escapeXml(importType)}" selected><c:out value="${importType}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(importType)}"><c:out value="${importType}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                        <div>
                            <label class="form-label" for="originCountry">Origin country</label>
                            <input id="originCountry" class="form-control" type="text" name="originCountry" maxlength="100" value="${fn:escapeXml(product.originCountry)}">
                        </div>
                        <div>
                            <label class="form-label" for="warrantyMonths">Warranty months</label>
                            <input id="warrantyMonths" class="form-control" type="number" name="warrantyMonths" min="0" value="${product.warrantyMonths}" required>
                        </div>
                        <div class="form-check align-self-end mt-3">
                            <c:choose>
                                <c:when test="${product.featured}">
                                    <input id="isFeatured" class="form-check-input" type="checkbox" name="isFeatured" checked>
                                </c:when>
                                <c:otherwise>
                                    <input id="isFeatured" class="form-check-input" type="checkbox" name="isFeatured">
                                </c:otherwise>
                            </c:choose>
                            <label class="form-check-label" for="isFeatured">Feature on storefront</label>
                        </div>
                        <div class="field-span-full">
                            <label class="form-label" for="description">Description</label>
                            <textarea id="description" class="form-control" name="description" rows="5" maxlength="2000">${fn:escapeXml(product.description)}</textarea>
                        </div>
                    </div>

                    <div class="admin-summary-card">
                        <span>Next phase</span>
                        <strong>Variant / image / specification management</strong>
                        <small class="admin-note">This skeleton intentionally keeps the first product form focused on master data so the CRUD flow stays clean and reviewable.</small>
                    </div>

                    <div class="admin-form-actions mt-4">
                        <a class="btn btn-app-outline" href="${appPath}/admin/products">Cancel</a>
                        <c:choose>
                            <c:when test="${isEdit}">
                                <button class="btn btn-app-primary" type="submit">Save Changes</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-app-primary" type="submit">Create Product</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </section>
        </section>
    </main>
</body>
</html>
