# AppleStore

## Database setup

Run the SQL files in this order:

```text
database/schema.sql
database/seed.sql
```

The database name is `AppleStore`.

`database/schema.sql` starts by running `DROP TABLE IF EXISTS` for all project
tables, so rerunning it will delete and recreate the local database schema.
After pulling database changes from Git, run `schema.sql` first, then `seed.sql`
to reload sample data without duplicate rows.

## Backend structure

This project uses a simple Java Web Servlet + JSP + JDBC structure without a `com.*` base package:

```text
src/java/
  controller/
    admin/
      user/
  dao/
  filter/
  model/
  service/
  util/
web/
  assets/
    css/
    js/
    images/
  WEB-INF/
    views/
      admin/
        users/
      common/
```

Layer convention:

```text
JSP        renders data and submits forms
Servlet    receives request/response and chooses view/redirect
Service    validates input and handles business rules
DAO        runs SQL/JDBC only
Model      maps database rows to Java objects
Util       shared helpers such as DBConnection
Filter     authentication/authorization checks
```

## Frontend structure

Static assets stay public:

```text
web/assets/css
web/assets/js
web/assets/images
```

Protected JSP views must stay under `WEB-INF/views` so users cannot open them directly by URL:

```text
web/WEB-INF/views/
  common/
    admin-sidebar.jsp
  admin/
    users/
      list.jsp
      form.jsp
```

Existing `.html` pages under `web/` and `web/admin/` are still UI prototypes. When a module is connected to real backend data, move its JSP views into `WEB-INF/views` and expose it through a servlet route.

Common layout rule:

```jsp
<jsp:include page="/WEB-INF/views/common/admin-sidebar.jsp" />
```

## User Management sample flow

The first backend sample is Admin User Management:

```text
web/WEB-INF/views/admin/users/list.jsp
web/WEB-INF/views/admin/users/form.jsp
-> controller.admin.user.UserListServlet
-> controller.admin.user.UserEditServlet
-> controller.admin.user.UserUpdateServlet
-> controller.admin.user.UserStatusServlet
-> service.UserService
-> dao.UserDAO
-> util.DBConnection
-> MySQL users table
```

Routes:

```text
GET  /admin/users
GET  /admin/users/edit?id=1
POST /admin/users/update
POST /admin/users/status
```

This sample supports:

```text
list users
filter by keyword, role, status
edit full name, email, phone, role, status
change user status
```

Password changes are not included in this flow. Login/session logic now lives in its own
flow — see "Register / Login flow" below.

## JDBC configuration

Default connection in `src/java/util/DBConnection.java`:

```text
URL: jdbc:mysql://localhost:3306/AppleStore
Username: root
Password: empty
```

You can override it with environment variables:

```text
DB_URL
DB_USERNAME
DB_PASSWORD
```

Or JVM properties:

```text
db.url
db.username
db.password
```

This repo already includes MySQL Connector/J at:

```text
web/WEB-INF/lib/mysql-connector-j-8.4.0.jar
```

If the driver is removed later, Tomcat must have MySQL Connector/J available, either in:

```text
web/WEB-INF/lib
```

or:

```text
TOMCAT_HOME/lib
```

## Register / Login flow

```text
web/login.html
web/register.html
-> controller.auth.LoginServlet      (POST /login)
-> controller.auth.RegisterServlet   (POST /register)
-> controller.auth.LogoutServlet     (GET  /logout)
-> service.AuthService
-> dao.UserDAO
-> util.PasswordUtil
-> util.DBConnection
-> MySQL users table
```

`login.html` and `register.html` stay plain `.html` (not JSP): the servlets validate input, then redirect back
to the same page with `?error=...` (plus non-sensitive field values, never the password) or to a success
destination. `web/assets/js/main.js` (`initAuthFlashMessages`) reads these from `location.search` on page load
and renders them into the `[data-auth-alert]` box already present in both pages.

Behavior:

```text
Register: validates full name, email, phone, password length/confirmation;
          rejects duplicate email/phone; hashes password with PasswordUtil; inserts as CUSTOMER/ACTIVE.
Login:    looks up by email, checks lock/status, verifies password hash;
          5 wrong attempts locks the account for 15 minutes (failed_login_count / locked_until columns);
          on success stores the User in the HttpSession under key "user" and honors an in-app-only
          redirectTo param (rejects absolute/protocol-relative URLs to avoid open redirects).
Logout:   invalidates the session and redirects to login.html.
```

Session lifetime: 30 minutes by default, 14 days if "Remember me" is checked.

The session key `"user"` (`LoginServlet.SESSION_USER`) is shared with `filter.CustomerFilter` and the
`controller.customer.cart.*` servlets — keep them in sync if this key ever changes.

## Filter status

`AuthFilter` (`@WebFilter` on `/profile.html`, `/addresses.html`, `/wishlist.html`, `/order-history.html`,
`/order-detail.html`, `/checkout.html`) and `AdminFilter` (`@WebFilter` on `/admin/*`) are enabled. Both read
session attribute `"user"`; `AdminFilter` additionally requires role `ADMIN` or `SALE_STAFF` and returns 403
otherwise. Anonymous requests are redirected to `login.html?redirectTo=...`, and both filters also copy the
authenticated user into request attribute `authenticatedUser` for convenience in downstream JSPs/servlets.
`filter.CustomerFilter` (`/cart`, `/cart/*`) follows the same pattern independently for the cart feature.

## Git notes

Do not commit generated or local IDE files:

```text
build/
dist/
nbproject/private/
```