<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="User Management" />
<c:set var="adminSidebarDescription" scope="request" value="Servlet, service, DAO and JDBC sample flow." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Backend sample" />
<c:set var="adminSidebarFooterDescription" scope="request" value="Use this page as the pattern for product, order and category modules." />
<c:set var="adminSidebarActive" scope="request" value="users" />
<c:set var="adminSidebarShowUserQuickLinks" scope="request" value="${true}" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Users</title>
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css">
    <link rel="stylesheet" href="${appPath}/assets/css/style.css">
</head>
<body class="site-body admin-app">
    <main class="admin-workspace">
        <jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />

        <section class="admin-main">
            <div class="admin-topbar">
                <form class="admin-topbar-search" action="${appPath}/admin/users" method="get" name="adminUsersSearchForm">
                    <label class="visually-hidden" for="admin-users-search">Search users</label>
                    <input id="admin-users-search" class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Search name, email, phone">
                    <input type="hidden" name="role" value="${fn:escapeXml(selectedRole)}">
                    <input type="hidden" name="status" value="${fn:escapeXml(selectedStatus)}">
                    <input type="hidden" name="sort" value="${fn:escapeXml(selectedSort)}">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/users">Reset</a>
                    <div class="admin-user-pill">
                        <div class="account-avatar admin-user-pill-avatar">AD</div>
                        <div>
                            <strong>Admin</strong>
                            <small>User operations</small>
                        </div>
                    </div>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Users</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">User management</span>
                    <h1>User list</h1>
                    <p>Sample backend flow from JSP to servlet, service, DAO and MySQL.</p>
                </div>
            </div>

            <c:if test="${not empty successMsg}">
                <div class="alert alert-success" role="alert"><c:out value="${successMsg}" /></div>
            </c:if>
            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <section class="admin-panel">
                <div class="admin-panel-head">
                    <div>
                        <h2>Users</h2>
                        <p>DAO reads from the users table and the servlet forwards the current filtered page to JSP.</p>
                    </div>
                    <span class="text-muted small">Total matching users: ${totalUsers}</span>
                </div>
                <div class="table-toolbar">
                    <form class="admin-filter-bar compact" action="${appPath}/admin/users" method="get" name="adminUserFilterForm">
                        <input class="form-control" type="search" name="keyword" value="${fn:escapeXml(keyword)}" placeholder="Search name, email, phone">
                        <select class="form-select" name="role">
                            <option value="">All roles</option>
                            <c:forEach var="role" items="${roles}">
                                <c:choose>
                                    <c:when test="${selectedRole eq role}">
                                        <option value="${fn:escapeXml(role)}" selected><c:out value="${role}" /></option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(role)}"><c:out value="${role}" /></option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </select>
                        <select class="form-select" name="status">
                            <option value="">All status</option>
                            <c:forEach var="status" items="${statuses}">
                                <c:choose>
                                    <c:when test="${selectedStatus eq status}">
                                        <option value="${fn:escapeXml(status)}" selected><c:out value="${status}" /></option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(status)}"><c:out value="${status}" /></option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </select>
                        <select class="form-select" name="sort">
                            <c:forEach var="sortOption" items="${sortOptions}">
                                <c:choose>
                                    <c:when test="${selectedSort eq sortOption.value}">
                                        <option value="${fn:escapeXml(sortOption.value)}" selected><c:out value="${sortOption.label}" /></option>
                                    </c:when>
                                    <c:otherwise>
                                        <option value="${fn:escapeXml(sortOption.value)}"><c:out value="${sortOption.label}" /></option>
                                    </c:otherwise>
                                </c:choose>
                            </c:forEach>
                        </select>
                        <button class="btn btn-app-primary" type="submit">Filter</button>
                    </form>
                </div>
                <div class="table-responsive">
                    <table class="table app-table">
                        <thead>
                            <tr>
                                <th scope="col">User</th>
                                <th scope="col">Contact</th>
                                <th scope="col">Role</th>
                                <th scope="col">Status</th>
                                <th scope="col">Verified</th>
                                <th scope="col">Created</th>
                                <th scope="col" class="text-end">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${empty users}">
                                    <tr>
                                        <td colspan="7" class="text-center text-muted py-4">No users found.</td>
                                    </tr>
                                </c:when>
                                <c:otherwise>
                                    <c:forEach var="user" items="${users}">
                                        <c:choose>
                                            <c:when test="${user.status eq 'ACTIVE'}">
                                                <c:set var="userStatusClass" value="status-in-stock" />
                                            </c:when>
                                            <c:when test="${user.status eq 'INACTIVE'}">
                                                <c:set var="userStatusClass" value="status-out-stock" />
                                            </c:when>
                                            <c:when test="${user.status eq 'LOCKED' or user.status eq 'SUSPENDED'}">
                                                <c:set var="userStatusClass" value="status-cancelled" />
                                            </c:when>
                                            <c:otherwise>
                                                <c:set var="userStatusClass" value="status-pending" />
                                            </c:otherwise>
                                        </c:choose>
                                        <tr>
                                            <td>
                                                <div class="admin-user-pill">
                                                    <div class="account-avatar admin-user-pill-avatar"><c:out value="${userInitialsMap[user.userId]}" /></div>
                                                    <div>
                                                        <strong><c:out value="${user.fullName}" /></strong>
                                                        <small>#${user.userId}</small>
                                                    </div>
                                                </div>
                                            </td>
                                            <td>
                                                <strong><c:out value="${user.email}" /></strong>
                                                <small class="d-block text-muted"><c:out value="${user.phone}" /></small>
                                            </td>
                                            <td><span class="status-badge status-processing"><c:out value="${user.role}" /></span></td>
                                            <td><span class="status-badge ${userStatusClass}"><c:out value="${user.status}" /></span></td>
                                            <td>${user.emailVerified ? 'Yes' : 'No'}</td>
                                            <td><c:out value="${userCreatedAtMap[user.userId]}" /></td>
                                            <td class="text-end table-actions">
                                                <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/users/edit?id=${user.userId}">Edit</a>
                                                <form class="d-inline" action="${appPath}/admin/users/status" method="post">
                                                    <input type="hidden" name="userId" value="${user.userId}">
                                                    <c:choose>
                                                        <c:when test="${user.status eq 'ACTIVE'}">
                                                            <input type="hidden" name="status" value="LOCKED">
                                                            <button class="btn btn-app-outline btn-sm" type="submit">Lock</button>
                                                        </c:when>
                                                        <c:otherwise>
                                                            <input type="hidden" name="status" value="ACTIVE">
                                                            <button class="btn btn-app-primary btn-sm" type="submit">Activate</button>
                                                        </c:otherwise>
                                                    </c:choose>
                                                </form>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
                <nav aria-label="User pagination" class="mt-3">
                    <ul class="pagination app-pagination justify-content-end mb-0">
                        <li class="page-item ${currentPage le 1 ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage le 1}">
                                    <span class="page-link">Prev</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/users?page=${currentPage - 1}${listQuerySuffix}">Prev</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                        <c:forEach var="pageNumber" begin="1" end="${totalPages}">
                            <li class="page-item ${pageNumber eq currentPage ? 'active' : ''}">
                                <c:choose>
                                    <c:when test="${pageNumber eq currentPage}">
                                        <span class="page-link">${pageNumber}</span>
                                    </c:when>
                                    <c:otherwise>
                                        <a class="page-link" href="${appPath}/admin/users?page=${pageNumber}${listQuerySuffix}">${pageNumber}</a>
                                    </c:otherwise>
                                </c:choose>
                            </li>
                        </c:forEach>
                        <li class="page-item ${currentPage ge totalPages ? 'disabled' : ''}">
                            <c:choose>
                                <c:when test="${currentPage ge totalPages}">
                                    <span class="page-link">Next</span>
                                </c:when>
                                <c:otherwise>
                                    <a class="page-link" href="${appPath}/admin/users?page=${currentPage + 1}${listQuerySuffix}">Next</a>
                                </c:otherwise>
                            </c:choose>
                        </li>
                    </ul>
                </nav>
            </section>

            <p class="admin-footer-note">Route sample: GET /admin/users, GET /admin/users/edit?id=1, POST /admin/users/update, POST /admin/users/status.</p>
        </section>
    </main>
</body>
</html>
