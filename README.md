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

Password changes and login/session logic are intentionally not included in this flow.

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

## Filter status

`AuthFilter` and `AdminFilter` are included as skeleton classes only. They are not enabled yet because the login/session flow has not been implemented.

## Git notes

Do not commit generated or local IDE files:

```text
build/
dist/
nbproject/private/
```
