<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="isEdit" value="${not empty category and category.categoryId gt 0}" />
<c:set var="formModeLabel" value="${isEdit ? 'Edit' : 'Create'}" />
<c:choose>
    <c:when test="${isEdit}">
        <c:set var="adminSidebarTitle" scope="request" value="Edit Category" />
    </c:when>
    <c:otherwise>
        <c:set var="adminSidebarTitle" scope="request" value="Create Category" />
    </c:otherwise>
</c:choose>
<c:set var="adminSidebarDescription" scope="request" value="Validate in service, persist through DAO." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Catalog form" />
<c:set var="adminSidebarFooterDescription" scope="request" value="This form keeps category data small and easy to maintain." />
<c:set var="adminSidebarActive" scope="request" value="categories" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | ${formModeLabel} Category</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/categories" method="get" name="adminCategoriesSearchForm">
                    <label class="visually-hidden" for="admin-categories-search">Search categories</label>
                    <input id="admin-categories-search" class="form-control" type="search" name="keyword" placeholder="Search category name or slug">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/categories">Back to Categories</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/categories">Categories</a></li>
                    <li class="breadcrumb-item active" aria-current="page">${formModeLabel}</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">Category management</span>
                    <h1>${formModeLabel} category</h1>
                    <p>Servlet receives the form, service validates the request, DAO writes to the categories table.</p>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Category information</h2>
                        <p>Keep the taxonomy simple so product assignment and storefront filters remain predictable.</p>
                    </div>
                </div>

                <form class="admin-form-stack" action="${appPath}/admin/categories/update" method="post">
                    <c:if test="${isEdit}">
                        <input type="hidden" name="categoryId" value="${category.categoryId}">
                    </c:if>

                    <div class="admin-form-grid">
                        <div>
                            <label class="form-label" for="name">Category name</label>
                            <input id="name" class="form-control" type="text" name="name" maxlength="100" value="${fn:escapeXml(category.name)}" required>
                        </div>
                        <div>
                            <label class="form-label" for="slug">Slug</label>
                            <input id="slug" class="form-control" type="text" name="slug" maxlength="100" pattern="[a-z0-9]+(?:-[a-z0-9]+)*" title="Use lowercase letters, numbers, and hyphens only." value="${fn:escapeXml(category.slug)}" placeholder="iphone" required>
                        </div>
                        <div>
                            <label class="form-label" for="displayOrder">Display order</label>
                            <input id="displayOrder" class="form-control" type="number" name="displayOrder" min="0" value="${category.displayOrder}" required>
                        </div>
                        <div>
                            <label class="form-label" for="status">Status</label>
                            <select id="status" class="form-select" name="status" required>
                                <c:forEach var="status" items="${categoryStatusOptions}">
                                    <c:choose>
                                        <c:when test="${(category.isActive and status eq 'ACTIVE') or (not category.isActive and status eq 'INACTIVE')}">
                                            <option value="${fn:escapeXml(status)}" selected><c:out value="${status}" /></option>
                                        </c:when>
                                        <c:otherwise>
                                            <option value="${fn:escapeXml(status)}"><c:out value="${status}" /></option>
                                        </c:otherwise>
                                    </c:choose>
                                </c:forEach>
                            </select>
                        </div>
                    </div>

                    <div class="admin-form-actions mt-4">
                        <a class="btn btn-app-outline" href="${appPath}/admin/categories">Cancel</a>
                        <c:choose>
                            <c:when test="${isEdit}">
                                <button class="btn btn-app-primary" type="submit">Save Changes</button>
                            </c:when>
                            <c:otherwise>
                                <button class="btn btn-app-primary" type="submit">Create Category</button>
                            </c:otherwise>
                        </c:choose>
                    </div>
                </form>
            </section>
        </section>
    </main>
</body>
</html>
