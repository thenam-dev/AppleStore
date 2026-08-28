# 1.3 Database Design

This section describes the 22 database tables that are directly used by the current ASOS source code. For each table, PK means Primary Key, FK means Foreign Key, UN means Unique, and NN means Not Null. For composite keys or composite unique constraints, the participating fields are identified in their descriptions.

## 1.3.1 users

**Brief Description:** Stores account, authentication, profile, role, and account-status information for customers, administrators, sales staff, and delivery staff. The table supports both local-password and Google authentication.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | user_id | Yes | No | Yes | Yes | Auto-incremented identifier of the user. |
| 2 | full_name | No | No | No | Yes | Full name displayed for the user. |
| 3 | email | No | No | Yes | Yes | Unique email used for login and communication. |
| 4 | password_hash | No | No | No | No | Hashed local password; may be null for Google accounts. |
| 5 | phone | No | No | Yes | No | Unique phone number of the user. |
| 6 | role | No | No | No | Yes | User role: CUSTOMER, ADMIN, SALE_STAFF, or DELIVERY. |
| 7 | status | No | No | No | Yes | Account status: ACTIVE, INACTIVE, LOCKED, or SUSPENDED. |
| 8 | avatar_url | No | No | No | No | URL of the user's profile image. |
| 9 | auth_provider | No | No | No | Yes | Authentication provider: LOCAL or GOOGLE. |
| 10 | google_id | No | No | Yes | No | Unique Google account identifier. |
| 11 | is_email_verified | No | No | No | Yes | Indicates whether the email address has been verified. |
| 12 | email_verification_code_hash | No | No | No | No | Hash of the email-verification code. |
| 13 | email_verification_expires_at | No | No | No | No | Expiration time of the verification code. |
| 14 | email_verification_resend_at | No | No | No | No | Earliest time at which another verification code may be sent. |
| 15 | email_verification_sent_at | No | No | No | No | Time at which the latest verification code was sent. |
| 16 | failed_login_count | No | No | No | Yes | Number of consecutive failed login attempts. |
| 17 | locked_until | No | No | No | No | Time until which the account is temporarily locked. |
| 18 | created_at | No | No | No | Yes | Date and time when the account was created. |
| 19 | updated_at | No | No | No | Yes | Date and time when the account was last updated. |

## 1.3.2 user_addresses

**Brief Description:** Stores customers' delivery addresses, recipient details, default-address selection, and soft-deletion status.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | address_id | Yes | No | Yes | Yes | Auto-incremented identifier of the address. |
| 2 | user_id | No | Yes | No | Yes | User who owns the address; references users.user_id. |
| 3 | recipient_name | No | No | No | Yes | Name of the delivery recipient. |
| 4 | recipient_phone | No | No | No | Yes | Phone number of the delivery recipient. |
| 5 | address_detail | No | No | No | Yes | Full delivery-address details. |
| 6 | province | No | No | No | No | Province or municipality of the address. |
| 7 | district | No | No | No | No | District of the address. |
| 8 | ward | No | No | No | No | Ward or commune of the address. |
| 9 | is_default | No | No | No | Yes | Indicates whether this is the user's default address. |
| 10 | is_deleted | No | No | No | Yes | Soft-deletion flag for the address. |
| 11 | created_at | No | No | No | Yes | Date and time when the address was created. |
| 12 | updated_at | No | No | No | Yes | Date and time when the address was last updated. |

## 1.3.3 categories

**Brief Description:** Stores product categories used to classify, order, activate, and display products in the online store.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | category_id | Yes | No | Yes | Yes | Auto-incremented identifier of the category. |
| 2 | name | No | No | Yes | Yes | Unique category name. |
| 3 | slug | No | No | Yes | Yes | Unique URL-friendly category identifier. |
| 4 | display_order | No | No | No | Yes | Position of the category in displayed lists. |
| 5 | is_active | No | No | No | Yes | Indicates whether the category is available for use. |

## 1.3.4 products

**Brief Description:** Stores the general information and lifecycle state of each Apple product, including its category, model, condition, origin, warranty, rating, and sales statistics.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | product_id | Yes | No | Yes | Yes | Auto-incremented identifier of the product. |
| 2 | created_by | No | Yes | No | No | User who created the product; references users.user_id. |
| 3 | category_id | No | Yes | No | Yes | Category containing the product; references categories.category_id. |
| 4 | name | No | No | No | Yes | Product name. |
| 5 | description | No | No | No | No | Detailed product description. |
| 6 | brand | No | No | No | Yes | Product brand; defaults to Apple. |
| 7 | model_code | No | No | No | No | Manufacturer or internal model code. |
| 8 | release_year | No | No | No | No | Year in which the product model was released. |
| 9 | product_condition | No | No | No | Yes | Product condition: NEW, LIKE_NEW, or REFURBISHED. |
| 10 | import_type | No | No | No | Yes | Regional import code such as VN/A or LL/A. |
| 11 | origin_country | No | No | No | No | Country of origin. |
| 12 | warranty_months | No | No | No | Yes | Standard warranty duration in months. |
| 13 | warranty_provider | No | No | No | No | Organization responsible for the warranty. |
| 14 | status | No | No | No | Yes | Product status: ACTIVE, INACTIVE, DELETED, or DISCONTINUED. |
| 15 | view_count | No | No | No | Yes | Number of times the product has been viewed. |
| 16 | rating | No | No | No | Yes | Average product rating from zero to five. |
| 17 | sold_quantity | No | No | No | Yes | Total quantity sold. |
| 18 | is_featured | No | No | No | Yes | Indicates whether the product is featured. |
| 19 | created_at | No | No | No | Yes | Date and time when the product was created. |
| 20 | updated_at | No | No | No | Yes | Date and time when the product was last updated. |

## 1.3.5 product_images

**Brief Description:** Stores image paths belonging to products and controls each image's display order and primary-image status.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | image_id | Yes | No | Yes | Yes | Auto-incremented identifier of the image. |
| 2 | product_id | No | Yes | No | Yes | Product owning the image; references products.product_id and participates in the one-primary-image constraint. |
| 3 | file_path | No | No | No | Yes | Stored path or URL of the image file. |
| 4 | display_order | No | No | No | Yes | Position of the image in the product gallery. |
| 5 | is_primary | No | No | No | Yes | Indicates whether this is the product's primary image. |
| 6 | primary_slot | No | No | No | No | Generated value used with product_id to enforce at most one primary image per product. |
| 7 | uploaded_at | No | No | No | Yes | Date and time when the image was uploaded. |

## 1.3.6 product_specifications

**Brief Description:** Stores product technical specifications as grouped name-value pairs with a configurable display order.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | spec_id | Yes | No | Yes | Yes | Auto-incremented identifier of the specification. |
| 2 | product_id | No | Yes | No | Yes | Product described by the specification; references products.product_id and participates in a composite unique constraint. |
| 3 | spec_group | No | No | No | Yes | Group such as Display, Processor, Camera, or Battery; participates in a composite unique constraint. |
| 4 | spec_name | No | No | No | Yes | Name of the specification; participates in a composite unique constraint with product_id and spec_group. |
| 5 | spec_value | No | No | No | Yes | Value of the specification. |
| 6 | display_order | No | No | No | Yes | Position of the specification in the displayed list. |

## 1.3.7 product_variants

**Brief Description:** Stores purchasable variants of a product, including identifying attributes, pricing, discounts, stock quantity, weight, and active status.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | variant_id | Yes | No | Yes | Yes | Auto-incremented identifier of the product variant. |
| 2 | product_id | No | Yes | No | Yes | Parent product; references products.product_id. |
| 3 | sku | No | No | Yes | Yes | Unique stock-keeping unit of the variant. |
| 4 | variant_label | No | No | No | Yes | Human-readable variant label. |
| 5 | color_name | No | No | No | No | Color of the variant. |
| 6 | case_size_mm | No | No | No | No | Device case size in millimetres, when applicable. |
| 7 | storage_capacity_gb | No | No | No | No | Storage capacity in gigabytes. |
| 8 | ram_gb | No | No | No | No | Memory capacity in gigabytes. |
| 9 | connectivity | No | No | No | No | Connectivity option: WIFI or WIFI_CELLULAR. |
| 10 | price | No | No | No | Yes | Regular selling price. |
| 11 | stock_quantity | No | No | No | Yes | Current available stock quantity. |
| 12 | weight_kg | No | No | No | Yes | Variant weight in kilograms. |
| 13 | discount_price | No | No | No | No | Promotional price, which cannot exceed the regular price. |
| 14 | discount_start | No | No | No | No | Date and time when the promotional price becomes valid. |
| 15 | discount_end | No | No | No | No | Date and time when the promotional price expires. |
| 16 | is_active | No | No | No | Yes | Indicates whether the variant is available for sale. |
| 17 | created_at | No | No | No | Yes | Date and time when the variant was created. |
| 18 | updated_at | No | No | No | Yes | Date and time when the variant was last updated. |

## 1.3.8 product_addon_services

**Brief Description:** Stores optional services, accessories, and warranty extensions that may be added to a product purchase.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | addon_id | Yes | No | Yes | Yes | Auto-incremented identifier of the add-on. |
| 2 | product_id | No | Yes | No | Yes | Product for which the add-on is offered; references products.product_id. |
| 3 | name | No | No | No | Yes | Name of the add-on. |
| 4 | addon_type | No | No | No | Yes | Add-on type: SERVICE, ACCESSORY, or WARRANTY_EXTENSION. |
| 5 | price_add | No | No | No | Yes | Additional amount charged for the add-on. |
| 6 | is_active | No | No | No | Yes | Indicates whether the add-on can currently be selected. |

## 1.3.9 inventory_logs

**Brief Description:** Records auditable stock changes for product variants, including the reason, quantity difference, resulting quantity, related order, responsible user, and timestamp.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | log_id | Yes | No | Yes | Yes | Auto-incremented identifier of the inventory log. |
| 2 | variant_id | No | Yes | No | Yes | Variant whose stock changed; references product_variants.variant_id. |
| 3 | changed_by | No | Yes | No | Yes | User responsible for the change; references users.user_id. |
| 4 | order_id | No | Yes | No | No | Related order, when applicable; references orders.order_id. |
| 5 | order_item_id | No | Yes | No | No | Related order item, when applicable; references order_items.order_item_id. |
| 6 | change_type | No | No | No | Yes | Reason for the stock change, such as ORDER_RESERVE or ORDER_RELEASE. |
| 7 | quantity_delta | No | No | No | Yes | Positive or negative quantity applied to stock. |
| 8 | quantity_after | No | No | No | Yes | Stock quantity remaining after the change. |
| 9 | note | No | No | No | No | Additional explanation for the stock change. |
| 10 | changed_at | No | No | No | Yes | Date and time when the stock change occurred. |

## 1.3.10 promotions

**Brief Description:** Stores promotion codes and their discount rules, applicable scope, benefit target, usage limits, validity period, creator, and activation state.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | promo_id | Yes | No | Yes | Yes | Auto-incremented identifier of the promotion. |
| 2 | code | No | No | Yes | Yes | Unique promotion or coupon code. |
| 3 | discount_type | No | No | No | Yes | Discount calculation type: PERCENT or FIXED. |
| 4 | discount_max | No | No | No | Yes | Maximum discount amount for percentage-based promotions. |
| 5 | discount_value | No | No | No | Yes | Percentage or fixed amount of the discount. |
| 6 | min_order_value | No | No | No | Yes | Minimum order value required to use the promotion. |
| 7 | scope | No | No | No | Yes | Promotion scope: ORDER, PRODUCT, or CATEGORY. |
| 8 | benefit_target | No | No | No | Yes | Target receiving the benefit: merchandise, shipping, product, or payment method. |
| 9 | max_uses | No | No | No | No | Maximum number of times the promotion may be used. |
| 10 | used_count | No | No | No | Yes | Number of recorded uses. |
| 11 | can_stack | No | No | No | Yes | Indicates whether the promotion can be combined with another promotion. |
| 12 | valid_from | No | No | No | Yes | Date and time when the promotion becomes valid. |
| 13 | valid_until | No | No | No | Yes | Date and time when the promotion expires. |
| 14 | created_by | No | Yes | No | Yes | User who created the promotion; references users.user_id. |
| 15 | created_at | No | No | No | Yes | Date and time when the promotion was created. |
| 16 | updated_at | No | No | No | Yes | Date and time when the promotion was last updated. |
| 17 | is_deleted | No | No | No | Yes | Soft-deletion flag for the promotion. |
| 18 | is_active | No | No | No | Yes | Indicates whether the promotion is enabled. |

## 1.3.11 promotion_categories

**Brief Description:** Implements the many-to-many relationship between promotions and the product categories to which they apply.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | promo_id | Yes | Yes | No | Yes | Promotion identifier; references promotions.promo_id and forms the composite primary key with category_id. |
| 2 | category_id | Yes | Yes | No | Yes | Category identifier; references categories.category_id and forms the composite primary key with promo_id. |

## 1.3.12 promotion_products

**Brief Description:** Implements the many-to-many relationship between promotions and the individual products to which they apply.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | promo_id | Yes | Yes | No | Yes | Promotion identifier; references promotions.promo_id and forms the composite primary key with product_id. |
| 2 | product_id | Yes | Yes | No | Yes | Product identifier; references products.product_id and forms the composite primary key with promo_id. |

## 1.3.13 cart

**Brief Description:** Stores one persistent shopping cart for each customer and tracks when the cart was created or updated.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | cart_id | Yes | No | Yes | Yes | Auto-incremented identifier of the shopping cart. |
| 2 | customer_id | No | Yes | Yes | Yes | Unique owner of the cart; references users.user_id. |
| 3 | created_at | No | No | No | Yes | Date and time when the cart was created. |
| 4 | updated_at | No | No | No | Yes | Date and time when the cart was last updated. |

## 1.3.14 cart_items

**Brief Description:** Stores the product variants, quantities, and optional add-on services currently included in a customer's shopping cart.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | cart_item_id | Yes | No | Yes | Yes | Auto-incremented identifier of the cart item. |
| 2 | cart_id | No | Yes | No | Yes | Cart containing the item; references cart.cart_id and participates in a composite unique constraint. |
| 3 | variant_id | No | Yes | No | Yes | Selected product variant; references product_variants.variant_id and participates in a composite unique constraint. |
| 4 | quantity | No | No | No | Yes | Quantity selected by the customer; must be at least one. |
| 5 | addon_id | No | Yes | No | No | Optional add-on; references product_addon_services.addon_id. |
| 6 | addon_id_norm | No | No | No | No | Generated normalized add-on identifier used in the composite unique constraint. |
| 7 | added_at | No | No | No | Yes | Date and time when the item was added to the cart. |

## 1.3.15 orders

**Brief Description:** Stores the main record of each customer order, including recipient and delivery information, assigned sales staff, monetary totals, payment method, processing status, acceptance data, and cancellation data.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | order_id | Yes | No | Yes | Yes | Auto-incremented identifier of the order. |
| 2 | customer_id | No | Yes | No | Yes | Customer who placed the order; references users.user_id and participates in a composite order-customer constraint. |
| 3 | assigned_sale_staff_id | No | Yes | No | No | Sales staff member assigned to the order; references users.user_id. |
| 4 | delivery_address | No | No | No | Yes | Delivery-address snapshot stored for the order. |
| 5 | recipient_name | No | No | No | Yes | Name of the delivery recipient. |
| 6 | recipient_phone | No | No | No | Yes | Phone number of the delivery recipient. |
| 7 | delivery_time_slot | No | No | No | No | Customer's preferred delivery time slot. |
| 8 | notes | No | No | No | No | Additional notes supplied for the order. |
| 9 | cancelled_at | No | No | No | No | Date and time when the order was cancelled. |
| 10 | cancelled_by | No | Yes | No | No | User who cancelled the order; references users.user_id. |
| 11 | cancellation_reason | No | No | No | No | Reason for cancelling the order. |
| 12 | status | No | No | No | Yes | Current order-processing status. |
| 13 | total_amount | No | No | No | Yes | Total merchandise amount before delivery fees and discounts. |
| 14 | delivery_fee | No | No | No | Yes | Delivery charge applied to the order. |
| 15 | discount_amount | No | No | No | Yes | Total discount deducted from the order. |
| 16 | final_amount | No | No | No | Yes | Final payable amount: total_amount plus delivery_fee minus discount_amount. |
| 17 | payment_method | No | No | No | Yes | Payment method: CK for bank transfer or COD for cash on delivery. |
| 18 | refund_status | No | No | No | Yes | Current refund-processing status. |
| 19 | received_status | No | No | No | Yes | Customer confirmation of whether the order was received. |
| 20 | acceptance_deadline | No | No | No | No | Deadline by which an assigned order should be accepted. |
| 21 | accepted_at | No | No | No | No | Date and time when the order was accepted. |
| 22 | created_at | No | No | No | Yes | Date and time when the order was created. |
| 23 | updated_at | No | No | No | Yes | Date and time when the order was last updated. |

## 1.3.16 order_items

**Brief Description:** Stores individual items in an order. Product, variant, price, quantity, and add-on snapshots preserve the purchased information even if the catalog later changes.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | order_item_id | Yes | No | Yes | Yes | Auto-incremented identifier of the order item; also participates in the composite order-item constraint. |
| 2 | order_id | No | Yes | No | Yes | Order containing the item; references orders.order_id and participates in a composite constraint. |
| 3 | variant_id | No | Yes | No | No | Purchased variant; references product_variants.variant_id and may become null if the variant is deleted. |
| 4 | serial_id | No | Yes | No | No | Assigned product serial; references product_serials.serial_id when serial tracking is used. |
| 5 | product_name_snapshot | No | No | No | Yes | Product name captured at checkout time. |
| 6 | variant_label_snapshot | No | No | No | Yes | Variant label captured at checkout time. |
| 7 | quantity | No | No | No | Yes | Number of units purchased. |
| 8 | unit_price | No | No | No | Yes | Unit price captured at checkout time. |
| 9 | subtotal | No | No | No | Yes | Total line amount for the purchased quantity. |
| 10 | addon_label_snapshot | No | No | No | No | Selected add-on name captured at checkout time. |
| 11 | addon_price_snapshot | No | No | No | Yes | Selected add-on price captured at checkout time. |

## 1.3.17 order_status_history

**Brief Description:** Records the chronological status-change history of each order, including the responsible user, explanatory note, and change time.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | history_id | Yes | No | Yes | Yes | Auto-incremented identifier of the history entry. |
| 2 | order_id | No | Yes | No | Yes | Order whose status changed; references orders.order_id. |
| 3 | status | No | No | No | Yes | Order status recorded by this history entry. |
| 4 | changed_by | No | Yes | No | No | User responsible for the change; references users.user_id. |
| 5 | note | No | No | No | No | Explanation or comment associated with the status change. |
| 6 | changed_at | No | No | No | Yes | Date and time when the status changed. |

## 1.3.18 order_promotions

**Brief Description:** Records the promotion applied to an order, including the customer, coupon snapshot, applied discount, benefit target, and usage time.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | usage_id | Yes | No | Yes | Yes | Auto-incremented identifier of the promotion usage record. |
| 2 | order_id | No | Yes | No | Yes | Order receiving the promotion; references orders.order_id and participates in the order-customer composite FK. |
| 3 | promo_id | No | Yes | No | Yes | Promotion that was applied; references promotions.promo_id. |
| 4 | customer_id | No | Yes | No | Yes | Customer using the promotion; references users.user_id and participates in the order-customer composite FK. |
| 5 | discount_applied | No | No | No | Yes | Actual discount amount applied to the order. |
| 6 | coupon_code | No | No | No | No | Coupon-code snapshot recorded at usage time. |
| 7 | benefit_target | No | No | No | No | Target to which the promotion benefit was applied. |
| 8 | used_at | No | No | No | Yes | Date and time when the promotion was used. |

## 1.3.19 payment_transactions

**Brief Description:** Stores SePay payment attempts for orders, including the payment amount, QR data, provider identifiers, processing status, expiration, provider response, errors, and client IP address.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | transaction_id | Yes | No | Yes | Yes | Auto-incremented identifier of the payment transaction. |
| 2 | order_id | No | Yes | No | Yes | Order being paid; references orders.order_id and forms a composite unique constraint with attempt_no. |
| 3 | attempt_no | No | No | No | Yes | Sequential payment-attempt number within the order. |
| 4 | payment_method | No | No | No | Yes | Payment provider or method; defaults to SEPAY. |
| 5 | sepay_transaction_id | No | No | Yes | No | Unique transaction identifier received from SePay. |
| 6 | sepay_reference | No | No | No | No | Payment reference received from SePay. |
| 7 | sepay_qr_code | No | No | No | No | Generated SePay QR-code URL or data. |
| 8 | amount | No | No | No | Yes | Amount expected or processed for the transaction. |
| 9 | currency | No | No | No | Yes | Three-character currency code; defaults to VND. |
| 10 | status | No | No | No | Yes | Payment-processing status. |
| 11 | initiated_at | No | No | No | Yes | Date and time when the payment attempt was initiated. |
| 12 | completed_at | No | No | No | No | Date and time when payment processing completed. |
| 13 | expires_at | No | No | No | No | Expiration time of the payment attempt. |
| 14 | provider_response | No | No | No | No | Raw or summarized response returned by the payment provider. |
| 15 | error_code | No | No | No | No | Provider or application error code. |
| 16 | error_message | No | No | No | No | Human-readable payment error message. |
| 17 | ip_address | No | No | No | No | IP address from which the payment attempt was initiated. |

## 1.3.20 sepay_webhook_dedup

**Brief Description:** Stores processed SePay webhook transaction identifiers to ensure idempotency and prevent the same payment notification from being processed more than once.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | dedup_id | Yes | No | Yes | Yes | Auto-incremented identifier of the deduplication record. |
| 2 | sepay_transaction_id | No | No | Yes | Yes | Unique SePay transaction identifier used as the idempotency key. |
| 3 | order_code | No | No | No | Yes | Order code extracted from the webhook notification. |
| 4 | process_result | No | No | No | Yes | Result of processing the webhook. |
| 5 | created_at | No | No | No | Yes | Date and time when the webhook record was created. |

## 1.3.21 deliveries

**Brief Description:** Stores the delivery assignment and fulfillment progress of an order, including assigned delivery staff, current status, delivery timestamps, proof image, estimated delivery time, and failure information.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | delivery_id | Yes | No | Yes | Yes | Auto-incremented identifier of the delivery record. |
| 2 | order_id | No | Yes | Yes | Yes | Unique order being delivered; references orders.order_id. |
| 3 | delivery_trip_id | No | Yes | No | No | Optional delivery trip; references delivery_trips.trip_id when trip planning is used. |
| 4 | trip_stop_seq | No | No | No | No | Stop sequence of the order within a delivery trip. |
| 5 | staff_id | No | Yes | No | No | Assigned delivery employee; references users.user_id. |
| 6 | status | No | No | No | Yes | Current delivery status. |
| 7 | picked_up_at | No | No | No | No | Date and time when the order was picked up for delivery. |
| 8 | delivered_at | No | No | No | No | Date and time when the order was delivered. |
| 9 | failure_reason | No | No | No | No | Reason why the delivery failed. |
| 10 | proof_image_url | No | No | No | No | URL of the delivery-proof image. |
| 11 | estimated_delivery_time | No | No | No | No | Estimated date and time of delivery. |
| 12 | created_at | No | No | No | Yes | Date and time when the delivery record was created. |
| 13 | updated_at | No | No | No | Yes | Date and time when the delivery record was last updated. |

## 1.3.22 reviews

**Brief Description:** Stores customer ratings, written comments, and optional images for purchased order items, while ensuring that a customer can review an order item only once.

| No. | Field | PK | FK | UN | NN | Description |
|---:|---|:---:|:---:|:---:|:---:|---|
| 1 | review_id | Yes | No | Yes | Yes | Auto-incremented identifier of the review. |
| 2 | order_item_id | No | Yes | No | Yes | Reviewed order item; participates in the order-item composite FK and the customer-item unique constraint. |
| 3 | order_id | No | Yes | No | Yes | Order containing the reviewed item; participates in the order-item and order-customer composite FKs. |
| 4 | customer_id | No | Yes | No | Yes | Customer writing the review; references users.user_id and participates in the customer-item unique constraint. |
| 5 | rating | No | No | No | Yes | Numeric rating from one to five. |
| 6 | review_text | No | No | No | No | Customer's written review. |
| 7 | review_image_url | No | No | No | No | URL of an image attached to the review. |
| 8 | is_hidden | No | No | No | Yes | Indicates whether the review is hidden from public display. |
| 9 | created_at | No | No | No | Yes | Date and time when the review was submitted. |
