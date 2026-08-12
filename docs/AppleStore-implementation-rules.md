# AppleStore Team Implementation Rules

## 1. Mục tiêu chung

- Toàn team chỉ làm trên 1 source chung của nhóm.
- Code phải ưu tiên đồng nhất, tái sử dụng, dễ demo, dễ sửa trực tiếp khi bảo vệ.
- Khi demo, hệ thống phải chạy từ source chung đã merge, không demo mỗi người một bản riêng.

## 2. Quy tắc kiến trúc

- Giữ kiến trúc: `Controller -> Service -> DAO -> JSP`.
- Service layer vẫn được giữ để gom validation, business rule, và điều phối DAO.
- DAO chỉ xử lý SQL và mapping dữ liệu.
- Controller xử lý request/response, điều hướng trang, và flash message.
- Không đưa business logic phức tạp vào JSP.

## 3. Quy tắc Servlet

- Servlet mới phải dùng `@WebServlet`.
- Không thêm servlet mapping mới vào `web.xml` nếu không thật sự cần.
- `doPost()` phải bắt đầu bằng:

```java
request.setCharacterEncoding("UTF-8");
```

- Mỗi module master data nên theo pattern thống nhất:
  - `ListServlet`
  - `EditServlet`
  - `UpdateServlet`
  - `StatusServlet`
  - `SupportServlet` hoặc helper chung nếu cần

## 4. Quy tắc DAO

- DAO phải dùng:
  - `DBConnection.getConnection()`
  - `PreparedStatement`
  - `try-with-resources`
  - hàm `mapRow(...)` hoặc `mapEntity(...)`
- Không nối chuỗi SQL trực tiếp từ input người dùng.
- Với master data, DAO nên có nhóm hàm:
  - `findAll(...)`
  - `findById(...)`
  - `existsBy...(...)`
  - `existsBy...ForOther...(...)`
  - `insert(...)`
  - `update(...)`
  - `updateStatus(...)`
  - `count...(...)`

## 5. Quy tắc JSP

- Cấm scriptlet trong JSP mới hoặc JSP được refactor:
  - không dùng `<% %>`
  - không dùng `<%= %>`
  - không dùng `<%! %>`
- Ưu tiên `JSTL` và `EL`.
- Dữ liệu, boolean, message, trạng thái `selected/active` phải được chuẩn bị ở servlet trước.
- Các phần dùng chung như `header`, `footer`, `sidebar`, `menu` phải tách thành JSP dùng chung để include vào.

## 6. Quy tắc validation

- Bắt buộc validate tối thiểu:
  - `required`
  - `length`
  - `format`
- Phải test các trường hợp:
  - nhập rỗng
  - nhập toàn dấu cách
  - nhập quá độ dài DB
  - nhập sai format
- Ví dụ format cần kiểm tra:
  - `date`
  - `email`
  - `mobile`
  - `image/file extension` như `jpg`, `jpeg`, `png`
- Validation phải làm ở server-side.
- Khi validate lỗi:
  - hiển thị message rõ ràng
  - giữ lại dữ liệu người dùng đã nhập nếu có thể

## 7. Quy tắc master data

- Master data như `category`, `product`, `user management` phải ưu tiên:
  - `list`
  - `search`
  - `filter`
  - `sort`
  - `paging`
  - `create`
  - `update`
  - `status toggle`
- Không xóa vật lý master data nếu không thật sự bắt buộc.
- Ưu tiên dùng `ACTIVE / INACTIVE` thay cho delete.
- Action đổi trạng thái phải dùng `POST`.

## 8. Quy tắc list page

- Mỗi bảng dữ liệu bắt buộc phải có đủ:
  - `search`
  - `filter`
  - `sort`
  - `paging`
- List page phải đồng nhất:
  - ô tìm kiếm
  - bộ lọc
  - nút create
  - badge status
  - action theo từng dòng
  - empty state rõ ràng
- Pagination phải hoạt động thật, không chỉ có code trong DAO mà chưa nối lên servlet/JSP.

## 9. Quy tắc create/update form

- Form create/update của cùng một module nên dùng chung càng nhiều càng tốt.
- Các màn hình UI tương tự nhau phải dùng chung source:
  - chung form layout
  - chung partial
  - chung CSS class
  - chung validation style
- Nếu cùng một chức năng cho nhiều role, phải dùng 1 source chung, không tách mỗi role một màn hình riêng nếu logic gần giống nhau.
- Khác nhau giữa role phải xử lý bằng:
  - phân quyền
  - condition render
  - kiểm tra quyền thao tác

## 10. Flash message và điều hướng

- Sau thao tác `POST`, ưu tiên theo PRG:
  - xử lý xong -> redirect
  - list page đọc message và hiển thị
- Thống nhất key message toàn hệ thống:
  - `successMsg`
  - `errorMsg`
- Nếu team chốt key khác, phải dùng đồng nhất toàn bộ hệ thống.

## 11. Quy tắc source chung của team

- Code phải được tích hợp vào source chung hằng ngày.
- Ưu tiên merge/pull thường xuyên để tránh lệch source.
- Không giữ code lâu ở máy cá nhân rồi mới gộp.
- File dùng chung chỉ sửa khi thật sự cần và phải báo team:
  - sidebar
  - header/footer
  - auth/filter
  - CSS dùng chung
  - file SQL chung

## 12. Quy tắc report và bảo vệ

- Mỗi ngày phải có daily report.
- Khi thầy yêu cầu sửa source trực tiếp, team phải sửa được trong thời gian ngắn.
- Vì vậy code phải:
  - dễ tìm
  - naming rõ ràng
  - module tách mạch lạc
  - không copy-paste lan man

## 13. Quy tắc review trước khi commit

Trước khi push, mỗi member tự check:

- validate đủ chưa
- list có đủ `search/filter/sort/paging` chưa
- create/update có giữ data khi lỗi chưa
- status action có chạy bằng `POST` chưa
- có lỡ sửa file teammate phụ trách không
- JSP mới có còn scriptlet không
- code đã build chạy được chưa

## 14. Quy tắc áp dụng ngay cho AppleStore

- `User`, `Category`, `Promotion`, `Product` phải dần thống nhất cùng pattern.
- Code mới từ thời điểm này trở đi phải tuân theo rule này.
- Code cũ chưa chuẩn thì refactor dần khi chạm vào module đó, không phá ồ ạt cả hệ thống.
