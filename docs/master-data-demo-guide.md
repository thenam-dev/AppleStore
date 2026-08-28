# Master Data – Demo & Code Walkthrough

Tài liệu này là bản đồ nhanh để trình bày phần master data của AppleStore. Phạm vi gồm: user, customer, category, product, product variant, product image và product specification.

## 1. Câu nói mở đầu nên nhớ

> Các màn quản trị đi theo luồng `Servlet/Controller → Service → DAO → MySQL`; JSP chỉ nhận dữ liệu và render giao diện. Service giữ validation và business rule, còn DAO chịu trách nhiệm SQL. Riêng image có thêm bước lưu file vật lý trên disk.

Các file nền tảng:

- `src/java/config/AppConfig.java`: role, status, page size, upload path.
- `src/java/config/DBConnection.java`: tạo JDBC connection.
- `src/java/filter/AdminFilter.java`: bảo vệ toàn bộ `/admin/*`, đọc lại user từ DB để kiểm tra role/status hiện tại.
- `src/java/util/PasswordUtil.java`: hash password bằng PBKDF2.
- `src/java/util/FileUploadUtil.java`: kiểm tra extension, magic bytes, kích thước và lưu file an toàn.
- `database/schema.sql`: bảng và foreign key.

## 2. Mô hình dữ liệu cần vẽ khi nói

```text
users
 ├─ role = ADMIN/SALE_STAFF/DELIVERY  → User Management
 └─ role = CUSTOMER                    → Customer Management

categories
 └─ products
     ├─ product_variants   (SKU, giá, tồn kho, thuộc tính bán hàng)
     ├─ product_images      (file ảnh, thứ tự, ảnh chính)
     └─ product_specifications (thông số mô tả chung)
```

Điểm dễ bị hỏi:

- Không có bảng `customers` riêng. Customer là một record trong `users` với `role = CUSTOMER`; hai màn hình chỉ khác nhóm lọc và nghiệp vụ.
- `Product` là thông tin chung của một dòng sản phẩm. `ProductVariant` là phiên bản có SKU, giá, stock và các lựa chọn như màu/dung lượng/RAM.
- Specification mô tả chung, ví dụ màn hình hoặc chip; nó không quyết định SKU. Các thuộc tính quyết định variant được xử lý bởi `ProductVariantAttributeService`.
- Hệ thống giữ quan hệ cha-con theo hướng: category → product → variant. Không thể bật variant nếu product/category chưa active; không thể tắt category nếu còn product active; không thể tắt product nếu còn variant active.

## 3. Route và file chính

| Module | GET/list | GET/form/detail | POST/update/status | Service | DAO |
|---|---|---|---|---|---|
| User | `/admin/users` | `/admin/users/edit` | `/admin/users/update`, `/status` | `UserService` | `UserDAO` |
| Customer | `/admin/customers` | `/admin/customers/detail` | `/admin/customers/status` | `UserService` | `UserDAO` |
| Category | `/admin/categories` | `/admin/categories/edit` | `/admin/categories/update`, `/status` | `CategoryService` | `CategoryDAO` |
| Product | `/admin/products` | `/admin/products/edit` | `/admin/products/update`, `/status` | `ProductService` | `ProductDAO` |
| Variant | `/admin/products/variants` | `/.../variants/edit` | `/.../variants/update`, `/status` | `ProductVariantService` | `ProductVariantDAO` |
| Image | `/admin/products/images` | form quản lý ảnh | `/upload`, `/primary`, `/delete` | `ProductImageService` | `ProductImageDAO` |
| Specification | `/admin/products/specifications` | form quản lý spec | `/specifications/update` | `ProductSpecificationService` | `ProductSpecificationDAO` |

Tên class đầy đủ có thể tra theo package tương ứng dưới `src/java/controller/admin`, `src/java/service` và `src/java/dao`.

## 4. Luồng request chung

### Luồng đọc danh sách

1. Admin gửi GET kèm keyword/filter/sort/page.
2. `AdminFilter` kiểm tra session và user hiện tại trong DB.
3. List Servlet gọi Service.
4. Service chuẩn hóa tham số phân trang và sort.
5. DAO dùng `PreparedStatement`, lọc SQL, `LIMIT/OFFSET`, map `ResultSet` vào entity.
6. Servlet forward tới JSP; JSP dùng JSTL/EL để render.

### Luồng ghi dữ liệu

1. Form gửi POST.
2. Servlet parse request thành entity hoặc list field.
3. Service normalize, validate, kiểm tra duplicate và các rule liên quan.
4. DAO insert/update bằng parameter binding.
5. Redirect theo PRG và lưu flash message `successMsg`/`errorMsg`.

Khi bị hỏi “vì sao không viết SQL trong Servlet?”, câu trả lời là: tách như vậy giúp UI không biết database, business rule nằm một chỗ, dễ test Service và giảm nguy cơ SQL injection nhờ PreparedStatement.

## 5. Giải thích từng module

### 5.1 User Management

Màn này quản lý tài khoản nội bộ: `ADMIN`, `SALE_STAFF`, `DELIVERY`. Code chính nằm ở `UserService.java`, `UserDAO.java` và các Servlet dưới `controller/admin/user`.

Các rule quan trọng:

- Email và phone không được trùng.
- Role của màn này chỉ là nhóm internal role.
- Tạo staff phải có password tối thiểu 8 ký tự, có chữ và số; password được hash trước khi insert.
- Không cho admin tự khóa/vô hiệu hóa tài khoản của chính mình.
- Không cho làm mất admin active cuối cùng.
- Nếu đổi email, email verification được reset.
- Status được đổi bằng POST riêng, không dùng GET để tránh thay đổi dữ liệu ngoài ý muốn.

Cách demo: mở danh sách staff → lọc theo role/status → sửa thông tin → thử duplicate email → thử đổi status tài khoản hiện tại hoặc admin cuối cùng để cho thấy Service chặn nghiệp vụ.

### 5.2 Customer Management

Customer dùng lại `UserService`/`UserDAO`, nhưng mọi truy vấn đều giới hạn `role = CUSTOMER`. Màn này có list, search theo tên/email/phone, detail readonly và đổi status.

Rule đáng nói nhất: không cho khóa customer nếu customer còn đơn chưa hoàn tất hoặc còn refund đang xử lý. Service kiểm tra qua `countUnfinishedCustomerOrders` trước khi cập nhật status.

Cách demo: tìm một customer → xem detail → đổi Active/Locked → nếu có đơn đang xử lý thì giải thích vì sao hệ thống từ chối.

### 5.3 Category Management

Category có `name`, `slug`, `displayOrder`, `isActive`. Service normalize name/slug, kiểm tra format slug, độ dài và duplicate name/slug.

Rule liên kết: category chỉ được chuyển sang inactive khi không còn product active thuộc category đó. Đây là rule ở `CategoryService.changeCategoryStatus`, có gọi `ProductDAO.countActiveByCategory`.

Cách demo: tạo/sửa category → thử slug sai hoặc tên trùng → thử tắt category đang có product active → sau khi product không còn active thì thao tác mới hợp lệ.

### 5.4 Product Management

Product lưu thông tin chung: tên, category, model code, năm phát hành, condition, import type, origin, warranty, description, featured và status.

`ProductDAO` không chỉ đọc cột product: list còn tính min price, tổng stock và số variant active từ bảng variant; sold quantity được tính từ order đã delivered; ảnh chính lấy từ `product_images`.

Rule chính:

- Category phải tồn tại và phải active khi tạo product.
- Tên/model code không được trùng.
- Không được bật product nếu category inactive.
- Không được tắt product khi còn variant active.
- UI hiện tại tập trung vào Apple Store nên brand và warranty provider được gán mặc định trong support/controller.

Cách demo: tạo product → chọn category → lưu → hệ thống chuyển sang quản lý ảnh → tạo variants → quay lại product list để thấy min price/stock/count thay đổi.

### 5.5 Product Variant Management

Variant là lớp bán hàng thực tế: SKU, label, màu, case size, storage, RAM, connectivity, price, stock, weight, discount và active.

`ProductVariantService` kiểm tra:

- SKU unique, normalize thành uppercase.
- Variant phải thuộc đúng product; DAO cũng dùng `WHERE variant_id = ? AND product_id = ?` để chống cập nhật nhầm parent.
- Các thuộc tính cấu hình không được trùng nhau giữa hai variant, kể cả khi SKU khác.
- Giá/stock không âm, weight lớn hơn 0; discount không lớn hơn giá gốc.
- Thời gian discount phải đi thành cặp và end phải sau start.
- Variant chỉ được active khi product và category đều active.

`ProductVariantAttributeService` chọn các field theo category: iPhone dùng color/storage, iPad thêm connectivity, Mac dùng RAM/storage, Watch dùng case size, AirPods dùng color, Apple TV dùng storage. Hiện code có ngoại lệ theo product ID cho product 11 và 12; đây là điểm cần biết khi hội đồng hỏi về khả năng mở rộng.

Cách demo: tạo hai variant cùng tổ hợp màu/dung lượng để thấy bị chặn → nhập SKU khác nhưng cùng tổ hợp để chứng minh hệ thống chống duplicate theo cấu hình → thử active khi parent inactive.

### 5.6 Product Image Management

Image có hai phần:

- Metadata trong DB: `product_images` gồm product, path, display order, primary.
- Binary file trên disk: thư mục persistent `applestore_uploads/products`.

Service validate toàn bộ danh sách file trước khi ghi để tránh upload nửa chừng; `FileUploadUtil` kiểm tra kích thước, extension, magic bytes và tạo tên UUID. DB có unique rule để mỗi product chỉ có tối đa một ảnh primary.

Khi xóa ảnh primary, Service chọn ảnh còn lại đầu tiên làm primary. Khi insert lỗi sau khi file đã ghi, Service cố gắng xóa các file vừa tạo để tránh file rác.

Cách demo: upload nhiều ảnh → chọn ảnh chính → thử file sai loại/quá dung lượng → xóa ảnh chính và quan sát ảnh khác được chọn thay.

### 5.7 Product Specification Management

Specification là danh sách động gồm `specGroup`, `specName`, `specValue`, `displayOrder`. Ví dụ group “Display”, name “Size”, value “6.1 inch”.

Đây là màn hình replace-all: Service đọc toàn bộ các dòng form, bỏ dòng trống hoàn toàn, validate từng dòng, chặn duplicate group/name và duplicate display order, sau đó DAO transaction `DELETE` cũ rồi batch `INSERT` mới. Vì vậy không có update từng dòng riêng lẻ.

Cách demo: thêm vài nhóm thông số → lưu → sửa/xóa một dòng → lưu lại → thử duplicate name trong cùng group để thấy validation.

## 6. Kịch bản demo ngắn, có logic

1. Nói kiến trúc và mô hình quan hệ ở phần 1–2.
2. Vào Category, tạo hoặc sửa category.
3. Vào Product, tạo product thuộc category đó.
4. Vào Specifications, thêm thông số mô tả chung.
5. Vào Images, upload và chọn primary.
6. Vào Variants, tạo hai SKU có các tổ hợp khác nhau; chỉ ra giá/stock là của variant, không phải product.
7. Quay lại Product list, chỉ ra min price, total stock, variant count và primary image được tính từ bảng con.
8. Vào User/Customer để trình bày phân quyền, status và các rule bảo vệ dữ liệu.
9. Kết thúc bằng một negative case: tắt category/product khi dữ liệu con còn active để chứng minh business rule.

## 7. Câu hỏi hội đồng thường hỏi

**Vì sao customer và staff dùng chung users?** Vì thông tin đăng nhập và identity dùng chung; role phân biệt nhóm nghiệp vụ, tránh trùng bảng và trùng logic authentication.

**Vì sao product không chứa trực tiếp price/stock?** Một product có thể có nhiều SKU; price/stock thay đổi theo từng variant.

**Tại sao không xóa cứng?** Status inactive/discontinued giữ lịch sử, đơn hàng và liên kết; hệ thống chủ yếu ẩn dữ liệu khỏi kinh doanh thay vì phá dữ liệu.

**Làm sao chống SQL injection?** Giá trị người dùng đi qua PreparedStatement; riêng ORDER BY không bind được nên DAO chỉ chọn từ allowlist sort đã định nghĩa.

**Làm sao đảm bảo chỉ có một primary image?** DAO reset primary của product rồi set ảnh được chọn trong transaction; schema còn có unique `(product_id, primary_slot)`.

**Nếu hai người cùng mua stock cuối thì sao?** DAO có thao tác giảm stock có điều kiện `stock_quantity >= quantity` trong một câu lệnh atomic; số lượng không bị giảm xuống âm.

## 8. Điểm cần chủ động biết trước khi demo

- `ProductVariantAttributeService` đang hardcode một số product ID đặc biệt; nếu seed ID thay đổi thì nên chuyển sang cấu hình theo product type/model.
- Regex phone trong `UserService.validateUser` hiện nhận đúng 10 chữ số, nhưng thông báo lỗi generic vẫn ghi “9 đến 15”.
- Schema có status `DELETED`, nhưng Service/UI không cho chọn status này; đây có vẻ là chủ ý để không xóa product khỏi luồng quản trị.
- Image metadata và file vật lý không nằm trong cùng một transaction; Service có cleanup bù khi upload DB thất bại, nhưng đây vẫn là điểm có thể cải thiện.
- Một số cấu hình nhạy cảm còn nằm trong `AppConfig`; nếu hội đồng hỏi về production readiness, nên nói sẽ chuyển sang environment variable/secret manager.

## 9. Một câu kết luận mẫu

> Phần master data được tổ chức theo quan hệ cha-con và tách lớp rõ ràng. Controller tiếp nhận request, Service bảo vệ business rule, DAO đảm nhiệm persistence. Nhờ các rule liên kết category–product–variant và việc tách metadata/file đối với image, dữ liệu quản trị vừa nhất quán vừa phù hợp với luồng bán hàng phía sau.
