# ASOS UML source-alignment report

## Scope and output

- Class diagrams: 5 (`docs/diagrams/class`)
- Sequence diagrams: 16 (`docs/diagrams/sequence`)
- Each diagram has a `.puml`, `.png`, and `.svg` file.
- Total diagrams: 21; total generated files: 63.

The request did not define the five class-diagram subjects. They were grouped by the source architecture so that all sixteen required sequences are covered:

1. Authentication
2. Product Catalog
3. Cart and Checkout
4. Order, Payment and Delivery
5. Administration

## Source and design deviations

| Area | Requested design | Actual source/schema | Diagram treatment |
|---|---|---|---|
| Forgot password | OTP has an explicit validity time and expired branch | `ForgotPasswordServlet` stores `resetOtp`, `resetEmail`, `otpVerified`, and `otpAttempts` in `HttpSession`, but no expiry timestamp | Diagram shows the implemented flow and includes a note that expired OTP is currently indistinguishable from missing/invalid OTP |
| Registration status | Create a Customer with a default status | The schema default is `INACTIVE`, but `UserDAO.insertCustomer(...)` explicitly inserts a CUSTOMER with `status='ACTIVE'` | Diagram follows the executed DAO statement and uses `ACTIVE`; this is a schema/default versus implementation difference |
| Browse products | `ProductService` and `CategoryService` participants | Guest `ProductListServlet` calls `ProductDAO` and `CategoryDAO` directly | Diagram uses the actual DAOs and includes a source note |
| Product details | Product, variant, image, specification and review services plus DAOs | `ProductDetailServlet` calls `ProductDAO`, `ProductVariantDAO`, and `ReviewDAO` directly; only images/specifications use services; `ProductVariantAttributeService` is also used | Diagram follows the actual mixed service/DAO implementation |
| Product variant selection | Server request after every selection | JSP receives `variantJson` and updates price/stock client-side | Diagram shows local JSP matching after initial page load |
| SePay checkout | Separate SePay QR service | `CheckoutService.buildQrUrl(...)` builds the QR URL; there is no SePay QR Java class | The external QR participant represents the URL-based integration, while the message keeps the real method name |
| Payment method naming | “SePay” checkout | `orders.payment_method` uses `CK`; `payment_transactions.payment_method` defaults to `SEPAY` | Diagram uses `CK` for the order and SePay for the payment transaction/integration |
| COD payment | Possible common payment record | Source explicitly confirms COD without creating `PaymentTransaction` | Diagram includes the no-payment-transaction note |
| Customer cancellation | Service/DAO plus explicit variant DAO | Customer cancellation and stock restoration are transactional inside `OrderDAO.cancelOrderByCustomer(...)`; staff cancellation uses `StaffOrderDAO.cancelOrderAndRestoreStock(...)` | Diagram presents the logical stock restoration while naming the actual cancellation methods |
| Order processing | Generic delivery-staff lookup | Actual method is `StaffOrderDAO.findBestShipperId()` followed by `assignDelivery(...)` | Diagram uses the real methods |
| Delivery completion | Separate updates may be expected | `StaffOrderDAO.updateDeliveryCompletedSecure(...)` performs the authorization and database updates | Diagram represents the single secure DAO operation and its SQL effects |
| Catalog management | Generic Category/Product Servlet | Source has separate `CategoryUpdateServlet`, `CategoryStatusServlet`, `ProductUpdateServlet`, and `ProductStatusServlet` | Diagram uses the concrete servlet classes |
| Supporting product data | Generic corresponding servlets | Source has separate variant, specification, upload, primary-image, and delete-image servlets | Diagram uses each concrete servlet and actual service/DAO methods |
| Shop Owner role | Role named Shop Owner | Source and schema use role `ADMIN`; the guard is `countActiveAdmins()` | Actor label remains “Shop Owner” for the SDS language, while class/method names use `ADMIN` semantics |
| Class-diagram scope | Exactly five diagrams, subjects unspecified | No existing five-diagram mapping was found | Five source-based architectural groups were selected and documented above |

## Verification

- All 21 PlantUML files pass PlantUML `-checkonly` validation.
- All 21 PNG files and all 21 SVG files were rendered successfully.
- Rendered diagrams were visually reviewed for clipping, duplicate lifelines, overlapping text, and crossed labels.
