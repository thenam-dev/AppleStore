<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>
<c:set var="appPath" value="${pageContext.request.contextPath}" />
<c:set var="adminSidebarTitle" scope="request" value="Edit User" />
<c:set var="adminSidebarDescription" scope="request" value="Validate in service, persist through DAO." />
<c:set var="adminSidebarFooterTitle" scope="request" value="Form sample" />
<c:set var="adminSidebarFooterDescription" scope="request" value="This form intentionally avoids password changes until auth is implemented." />
<c:set var="adminSidebarActive" scope="request" value="users" />
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Apple Online Shop Admin | Edit User</title>
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
                    <input id="admin-users-search" class="form-control" type="search" name="keyword" placeholder="Search name, email, phone">
                    <button class="btn btn-app-primary" type="submit">Search</button>
                </form>
                <div class="admin-topbar-actions">
                    <a class="btn btn-app-outline btn-sm" href="${appPath}/admin/users">Back to Users</a>
                </div>
            </div>

            <nav aria-label="Breadcrumb">
                <ol class="breadcrumb app-breadcrumb">
                    <li class="breadcrumb-item"><a href="${appPath}/admin/dashboard">Admin</a></li>
                    <li class="breadcrumb-item"><a href="${appPath}/admin/users">Users</a></li>
                    <li class="breadcrumb-item active" aria-current="page">Edit</li>
                </ol>
            </nav>

            <div class="admin-page-head">
                <div>
                    <span class="eyebrow">User management</span>
                    <h1>Edit user</h1>
                    <p>Servlet receives the form, service validates the request, DAO updates the users table.</p>
                </div>
            </div>

            <c:if test="${not empty errorMsg}">
                <div class="alert alert-danger" role="alert"><c:out value="${errorMsg}" /></div>
            </c:if>

            <c:choose>
                <c:when test="${empty user}">
                    <section class="admin-panel">
                        <p class="mb-0">User not found.</p>
                    </section>
                </c:when>
                <c:otherwise>
                    <section class="admin-panel">
                        <div class="admin-panel-head">
                            <div>
                                <h2>Account information</h2>
                                <p>Only profile, role and status are editable in this starter flow.</p>
                            </div>
                        </div>

                        <form class="admin-form-stack" action="${appPath}/admin/users/update" method="post">
                            <input type="hidden" name="userId" value="${user.userId}">

                            <div class="admin-form-grid">
                                <div>
                                    <label class="form-label" for="fullName">Full name</label>
                                    <input id="fullName" class="form-control" type="text" name="fullName" maxlength="100" value="${fn:escapeXml(user.fullName)}" required>
                                </div>
                                <div>
                                    <label class="form-label" for="email">Email</label>
                                    <input id="email" class="form-control" type="email" name="email" maxlength="255" value="${fn:escapeXml(user.email)}" required>
                                </div>
                                <div>
                                    <label class="form-label" for="phone">Phone</label>
                                    <input id="phone" class="form-control" type="tel" name="phone" maxlength="15" pattern="[0-9]{9,15}" title="Phone must contain 9 to 15 digits." value="${fn:escapeXml(user.phone)}">
                                </div>
                                <div>
                                    <label class="form-label" for="role">Role</label>
                                    <select id="role" class="form-select" name="role" required>
                                        <c:forEach var="role" items="${roles}">
                                            <c:choose>
                                                <c:when test="${user.role eq role}">
                                                    <option value="${fn:escapeXml(role)}" selected><c:out value="${role}" /></option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="${fn:escapeXml(role)}"><c:out value="${role}" /></option>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div>
                                    <label class="form-label" for="status">Status</label>
                                    <select id="status" class="form-select" name="status" required>
                                        <c:forEach var="status" items="${statuses}">
                                            <c:choose>
                                                <c:when test="${user.status eq status}">
                                                    <option value="${fn:escapeXml(status)}" selected><c:out value="${status}" /></option>
                                                </c:when>
                                                <c:otherwise>
                                                    <option value="${fn:escapeXml(status)}"><c:out value="${status}" /></option>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:forEach>
                                    </select>
                                </div>
                                <div class="form-check align-self-end">
                                    <c:choose>
                                        <c:when test="${user.emailVerified}">
                                            <input id="emailVerified" class="form-check-input" type="checkbox" name="emailVerified" checked>
                                        </c:when>
                                        <c:otherwise>
                                            <input id="emailVerified" class="form-check-input" type="checkbox" name="emailVerified">
                                        </c:otherwise>
                                    </c:choose>
                                    <label class="form-check-label" for="emailVerified">Email verified</label>
                                </div>
                            </div>

                            <div class="admin-form-actions">
                                <a class="btn btn-app-outline" href="${appPath}/admin/users">Cancel</a>
                                <button class="btn btn-app-primary" type="submit">Save Changes</button>
                            </div>
                        </form>
                    </section>
                </c:otherwise>
            </c:choose>

            <p class="admin-footer-note">Password and login session logic are intentionally left for the auth flow owner.</p>
        </section>
    </main>
</body>
</html>
