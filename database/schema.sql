-- ==========================================================================
-- schema.sql
-- AppleStore database schema for MySQL 8.0+.
-- ==========================================================================

CREATE DATABASE IF NOT EXISTS AppleStore CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE AppleStore;

SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS reviews;
DROP TABLE IF EXISTS deliveries;
DROP TABLE IF EXISTS delivery_trips;
DROP TABLE IF EXISTS sepay_webhook_dedup;
DROP TABLE IF EXISTS payment_transactions;
DROP TABLE IF EXISTS return_requests;
DROP TABLE IF EXISTS order_promotions;
DROP TABLE IF EXISTS order_status_history;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS cart_items;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS promotion_products;
DROP TABLE IF EXISTS promotion_categories;
DROP TABLE IF EXISTS promotions;
DROP TABLE IF EXISTS inventory_logs;
DROP TABLE IF EXISTS product_addon_services;
DROP TABLE IF EXISTS product_serials;
DROP TABLE IF EXISTS product_variants;
DROP TABLE IF EXISTS product_specifications;
DROP TABLE IF EXISTS product_images;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS categories;
DROP TABLE IF EXISTS store_settings;
DROP TABLE IF EXISTS system_config;
DROP TABLE IF EXISTS user_addresses;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. users
CREATE TABLE users (
    user_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NULL,
    phone VARCHAR(15) NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'CUSTOMER' CHECK (role IN ('CUSTOMER','ADMIN','SALE_STAFF','DELIVERY')),
    status VARCHAR(20) NOT NULL DEFAULT 'INACTIVE' CHECK (status IN ('ACTIVE','INACTIVE','LOCKED','SUSPENDED')),
    avatar_url VARCHAR(500) NULL,
    auth_provider VARCHAR(20) NOT NULL DEFAULT 'LOCAL' CHECK (auth_provider IN ('LOCAL','GOOGLE')),
    google_id VARCHAR(100) NULL,
    is_email_verified TINYINT(1) NOT NULL DEFAULT 0,
    email_verification_code_hash VARCHAR(255) NULL,
    email_verification_expires_at DATETIME NULL,
    email_verification_resend_at DATETIME NULL,
    email_verification_sent_at DATETIME NULL,
    failed_login_count INT NOT NULL DEFAULT 0 CHECK (failed_login_count >= 0),
    locked_until DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY UX_users_phone (phone),
    UNIQUE KEY UX_users_google_id (google_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. user_sessions
CREATE TABLE user_sessions (
    session_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    refresh_token_hash VARCHAR(255) NOT NULL UNIQUE,
    device_info VARCHAR(200) NULL,
    expires_at DATETIME NOT NULL,
    revoked_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 3. user_addresses
CREATE TABLE user_addresses (
    address_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    address_detail VARCHAR(500) NOT NULL,
    province VARCHAR(100) NULL,
    district VARCHAR(100) NULL,
    ward VARCHAR(100) NULL,
    is_default TINYINT(1) NOT NULL DEFAULT 0,
    is_deleted TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 4. store_settings
CREATE TABLE store_settings (
    store_id            TINYINT PRIMARY KEY DEFAULT 1,
    store_name          VARCHAR(150) NOT NULL,
    store_description   TEXT NULL,
    logo_url             VARCHAR(500) NULL,
    cover_url            VARCHAR(500) NULL,
    business_email       VARCHAR(255) NULL,
    hotline               VARCHAR(15) NULL,
    pickup_address        VARCHAR(500) NULL,
    tax_code               VARCHAR(50) NULL,
    rating                  DECIMAL(3,2) NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    low_stock_threshold     INT NOT NULL DEFAULT 5,
    created_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at              DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT CK_store_settings_single_row CHECK (store_id = 1)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 5. categories
CREATE TABLE categories (
    category_id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(100) NOT NULL UNIQUE,
    slug VARCHAR(100) NOT NULL UNIQUE,
    display_order INT NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 6. products
CREATE TABLE products (
    product_id            INT PRIMARY KEY AUTO_INCREMENT,
    created_by             INT NULL,
    category_id            INT NOT NULL,
    name                    VARCHAR(200) NOT NULL,
    description             TEXT NULL,
    brand                   VARCHAR(50) NOT NULL DEFAULT 'Apple',
    model_code              VARCHAR(50) NULL,
    release_year            INT NULL CHECK (release_year BETWEEN 1998 AND 2100),
    product_condition       VARCHAR(20) NOT NULL DEFAULT 'NEW' CHECK (product_condition IN ('NEW','LIKE_NEW','REFURBISHED')),
    import_type             VARCHAR(10) NOT NULL DEFAULT 'VN/A' CHECK (import_type IN ('VN/A','LL/A','ZA/A','ZP/A','J/A','KH/A')),
    origin_country           VARCHAR(100) NULL,
    warranty_months          INT NOT NULL DEFAULT 12 CHECK (warranty_months >= 0),
    warranty_provider        VARCHAR(100) NULL DEFAULT 'Apple Việt Nam',
    status                  VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (status IN ('ACTIVE','INACTIVE','DELETED','DISCONTINUED')),
    view_count              INT NOT NULL DEFAULT 0 CHECK (view_count >= 0),
    rating                  DECIMAL(3,2) NOT NULL DEFAULT 0 CHECK (rating >= 0 AND rating <= 5),
    sold_quantity            INT NOT NULL DEFAULT 0 CHECK (sold_quantity >= 0),
    is_featured               TINYINT(1) NOT NULL DEFAULT 0,
    created_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at               DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (created_by) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (category_id) REFERENCES categories(category_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 7. product_images
CREATE TABLE product_images (
    image_id INT PRIMARY KEY AUTO_INCREMENT,
    product_id INT NOT NULL,
    file_path VARCHAR(500) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    is_primary TINYINT(1) NOT NULL DEFAULT 0,
    primary_slot TINYINT AS (CASE WHEN is_primary = 1 THEN 1 ELSE NULL END) STORED,
    uploaded_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    KEY IX_product_images_product_id (product_id),
    UNIQUE KEY UX_product_images_one_primary (product_id, primary_slot),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 8. product_specifications
CREATE TABLE product_specifications (
    spec_id       INT PRIMARY KEY AUTO_INCREMENT,
    product_id    INT NOT NULL,
    spec_group    VARCHAR(50)  NOT NULL,
    spec_name     VARCHAR(100) NOT NULL,
    spec_value    VARCHAR(300) NOT NULL,
    display_order INT NOT NULL DEFAULT 0,
    UNIQUE KEY UX_product_specifications_name (product_id, spec_group, spec_name),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE INDEX IX_product_specifications_product_id ON product_specifications (product_id, display_order);

-- 9. product_variants
CREATE TABLE product_variants (
    variant_id            INT PRIMARY KEY AUTO_INCREMENT,
    product_id            INT NOT NULL,
    sku                   VARCHAR(50) NOT NULL UNIQUE,
    variant_label         VARCHAR(150) NOT NULL,
    color_name            VARCHAR(50) NULL,
    case_size_mm          INT NULL CHECK (case_size_mm IS NULL OR case_size_mm > 0),
    storage_capacity_gb   INT NULL CHECK (storage_capacity_gb IS NULL OR storage_capacity_gb >= 0),
    ram_gb                INT NULL CHECK (ram_gb IS NULL OR ram_gb >= 0),
    connectivity          VARCHAR(20) NULL
                          CHECK (connectivity IS NULL OR connectivity IN ('WIFI','WIFI_CELLULAR')),
    price                 DECIMAL(12,2) NOT NULL CHECK (price >= 0),
    stock_quantity        INT NOT NULL DEFAULT 0 CHECK (stock_quantity >= 0),
    weight_kg             DECIMAL(6,3) NOT NULL DEFAULT 0.200 CHECK (weight_kg > 0.000),
    discount_price        DECIMAL(12,2) NULL CHECK (discount_price IS NULL OR discount_price >= 0),
    discount_start        DATETIME NULL,
    discount_end          DATETIME NULL,
    is_active             TINYINT(1) NOT NULL DEFAULT 1,
    created_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT CK_product_variants_discount_price CHECK (discount_price IS NULL OR discount_price <= price),
    CONSTRAINT CK_product_variants_discount_dates CHECK (
        (discount_start IS NULL AND discount_end IS NULL)
        OR (discount_start IS NOT NULL AND discount_end IS NOT NULL AND discount_end > discount_start)
    ),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 10. product_serials
CREATE TABLE product_serials (
    serial_id            INT PRIMARY KEY AUTO_INCREMENT,
    variant_id            INT NOT NULL,
    serial_number         VARCHAR(50) NOT NULL UNIQUE,
    imei_1                VARCHAR(20) NULL,
    imei_2                VARCHAR(20) NULL,
    status                 VARCHAR(20) NOT NULL DEFAULT 'IN_STOCK' CHECK (status IN ('IN_STOCK','RESERVED','SOLD','RETURNED','DEFECTIVE')),
    order_item_id          INT NULL,
    warranty_start_date    DATE NULL,
    warranty_end_date      DATE NULL,
    imported_at            DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_at             DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE INDEX IX_product_serials_variant_id_status ON product_serials (variant_id, status);

-- 11. product_addon_services
CREATE TABLE product_addon_services (
    addon_id     INT PRIMARY KEY AUTO_INCREMENT,
    product_id   INT NOT NULL,
    name         VARCHAR(150) NOT NULL,
    addon_type   VARCHAR(20) NOT NULL DEFAULT 'SERVICE' CHECK (addon_type IN ('SERVICE','ACCESSORY','WARRANTY_EXTENSION')),
    price_add    DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (price_add >= 0),
    is_active    TINYINT(1) NOT NULL DEFAULT 1,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 12. inventory_logs
CREATE TABLE inventory_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    variant_id INT NOT NULL,
    changed_by INT NOT NULL,
    order_id INT NULL,
    order_item_id INT NULL,
    change_type VARCHAR(20) NOT NULL CHECK (change_type IN ('MANUAL_ADJUST','ORDER_RESERVE','ORDER_RELEASE','ORDER_CONFIRM','RETURN','DEFECTIVE')),
    quantity_delta INT NOT NULL,
    quantity_after INT NOT NULL CHECK (quantity_after >= 0),
    note VARCHAR(300) NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id),
    FOREIGN KEY (changed_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13. promotions (Đã loại bỏ hoàn toàn các cột product_id, category_id thừa)
CREATE TABLE promotions (
    promo_id INT PRIMARY KEY AUTO_INCREMENT,
    code VARCHAR(50) NOT NULL UNIQUE,
    discount_type VARCHAR(10) NOT NULL CHECK (discount_type IN ('PERCENT','FIXED')),
    discount_max DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (discount_max >= 0),
    discount_value DECIMAL(10,2) NOT NULL,
    min_order_value DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (min_order_value >= 0),
    scope VARCHAR(15) NOT NULL CHECK (scope IN ('ORDER','PRODUCT','CATEGORY')), 
    benefit_target VARCHAR(20) NOT NULL DEFAULT 'MERCHANDISE' CHECK (benefit_target IN ('MERCHANDISE','SHIPPING','PRODUCT','PAYMENT_METHOD')),
    max_uses INT NULL CHECK (max_uses IS NULL OR max_uses >= 0),
    used_count INT NOT NULL DEFAULT 0 CHECK (used_count >= 0),
    can_stack TINYINT(1) NOT NULL DEFAULT 0,
    valid_from DATETIME NOT NULL,
    valid_until DATETIME NOT NULL,
    created_by INT NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    is_deleted TINYINT(1) NOT NULL DEFAULT 0,
    is_active TINYINT(1) NOT NULL DEFAULT 1,
    CONSTRAINT CK_promotions_valid_dates CHECK (valid_until > valid_from),
    CONSTRAINT CK_promotions_discount_value CHECK (
        (discount_type = 'PERCENT' AND discount_value > 0 AND discount_value <= 100)
        OR (discount_type = 'FIXED' AND discount_value > 0)
    ),
    CONSTRAINT CK_promotions_used_count CHECK (max_uses IS NULL OR used_count <= max_uses),
    FOREIGN KEY (created_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13.1. Bảng nối: Danh mục (1 Promotion -> Nhiều Category)
CREATE TABLE promotion_categories (
    promo_id INT NOT NULL,
    category_id INT NOT NULL,
    PRIMARY KEY (promo_id, category_id),
    FOREIGN KEY (promo_id) REFERENCES promotions(promo_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 13.2. Bảng nối: Sản phẩm (1 Promotion -> Nhiều Product)
CREATE TABLE promotion_products (
    promo_id INT NOT NULL,
    product_id INT NOT NULL,
    PRIMARY KEY (promo_id, product_id),
    FOREIGN KEY (promo_id) REFERENCES promotions(promo_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 14. cart
CREATE TABLE cart (
    cart_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL UNIQUE,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (customer_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 15. cart_items
CREATE TABLE cart_items (
    cart_item_id INT PRIMARY KEY AUTO_INCREMENT,
    cart_id      INT NOT NULL,
    variant_id   INT NOT NULL,
    quantity     INT NOT NULL CHECK (quantity >= 1),
    addon_id     INT NULL,
    addon_id_norm INT AS (IFNULL(addon_id, 0)) STORED,
    added_at     DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (cart_id) REFERENCES cart(cart_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id),
    FOREIGN KEY (addon_id) REFERENCES product_addon_services(addon_id),
    UNIQUE KEY UX_cart_items_cart_variant_addon (cart_id, variant_id, addon_id_norm)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 16. orders
CREATE TABLE orders (
    order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT NOT NULL,
    assigned_sale_staff_id INT NULL,
    delivery_address VARCHAR(500) NOT NULL,
    recipient_name VARCHAR(100) NOT NULL,
    recipient_phone VARCHAR(15) NOT NULL,
    delivery_time_slot VARCHAR(100) NULL,
    notes VARCHAR(300) NULL,
    cancelled_at DATETIME NULL,
    cancelled_by INT NULL,
    cancellation_reason VARCHAR(500) NULL,
    status VARCHAR(25) NOT NULL DEFAULT 'PENDING_PAYMENT' CHECK (status IN ('PENDING_PAYMENT','APPROVED','CONFIRMED','PREPARING','DISPATCHED','DELIVERED','CANCELLED','PAYMENT_FAILED','EXPIRED')),
    total_amount DECIMAL(14,2) NOT NULL CHECK (total_amount >= 0),
    delivery_fee DECIMAL(10,2) NOT NULL DEFAULT 0 CHECK (delivery_fee >= 0),
    discount_amount DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (discount_amount >= 0),
    final_amount DECIMAL(14,2) NOT NULL CHECK (final_amount >= 0),
    payment_method VARCHAR(20) NOT NULL CHECK (payment_method IN ('CK','COD')),
    refund_status VARCHAR(20) NOT NULL DEFAULT 'NONE' CHECK (refund_status IN ('NONE','PENDING','APPROVED','REJECTED','PROCESSING','REFUNDED','FAILED')),
    received_status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (received_status IN ('PENDING','RECEIVED','NOT_RECEIVED')),
    acceptance_deadline DATETIME NULL,
    accepted_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT CK_orders_final_amount CHECK (final_amount = total_amount + delivery_fee - discount_amount),
    FOREIGN KEY (customer_id) REFERENCES users(user_id),
    FOREIGN KEY (assigned_sale_staff_id) REFERENCES users(user_id),
    FOREIGN KEY (cancelled_by) REFERENCES users(user_id),
    UNIQUE KEY UQ_orders_order_customer (order_id, customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 17. order_items
CREATE TABLE order_items (
    order_item_id            INT PRIMARY KEY AUTO_INCREMENT,
    order_id                 INT NOT NULL,
    variant_id               INT NULL,
    serial_id                INT NULL,
    product_name_snapshot    VARCHAR(200) NOT NULL,
    variant_label_snapshot   VARCHAR(150) NOT NULL,
    quantity                 INT NOT NULL CHECK (quantity >= 1),
    unit_price               DECIMAL(12,2) NOT NULL CHECK (unit_price >= 0),
    subtotal                 DECIMAL(14,2) NOT NULL CHECK (subtotal >= 0),
    addon_label_snapshot     VARCHAR(150) NULL,
    addon_price_snapshot     DECIMAL(12,2) NOT NULL DEFAULT 0 CHECK (addon_price_snapshot >= 0),
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (variant_id) REFERENCES product_variants(variant_id) ON DELETE SET NULL,
    FOREIGN KEY (serial_id) REFERENCES product_serials(serial_id),
    UNIQUE KEY UQ_order_items_order_item_order (order_item_id, order_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

ALTER TABLE product_serials ADD CONSTRAINT FK_product_serials_order_items FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id);
ALTER TABLE inventory_logs ADD CONSTRAINT FK_inventory_logs_orders FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE SET NULL, ADD CONSTRAINT FK_inventory_logs_order_items FOREIGN KEY (order_item_id) REFERENCES order_items(order_item_id) ON DELETE SET NULL;

-- 17b. order_status_history
CREATE TABLE order_status_history (
    history_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    status VARCHAR(25) NOT NULL,
    changed_by INT NULL,
    note VARCHAR(300) NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (changed_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
CREATE INDEX IX_order_status_history_order_id ON order_status_history (order_id, changed_at DESC);

-- 18. order_promotions
CREATE TABLE order_promotions (
    usage_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    promo_id INT NOT NULL,
    customer_id INT NOT NULL,
    discount_applied DECIMAL(12,2) NOT NULL CHECK (discount_applied >= 0),
    coupon_code VARCHAR(50) NULL,
    benefit_target VARCHAR(20) NULL CHECK (benefit_target IS NULL OR benefit_target IN ('MERCHANDISE','SHIPPING','PRODUCT','PAYMENT_METHOD')),
    used_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (promo_id) REFERENCES promotions(promo_id),
    FOREIGN KEY (customer_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id, customer_id) REFERENCES orders(order_id, customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 19. return_requests
CREATE TABLE return_requests (
    return_request_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    order_item_id INT NULL,
    customer_id INT NOT NULL,
    request_type VARCHAR(20) NOT NULL CHECK (request_type IN ('CANCEL','RETURN','EXCHANGE','WARRANTY_CLAIM')),
    reason_code VARCHAR(50) NOT NULL CHECK (reason_code IN ('WRONG_ITEM','HARDWARE_DEFECT','SOFTWARE_ISSUE','MISSING_ITEM','LATE_DELIVERY','NOT_AS_DESCRIBED','CHANGED_MIND','OTHER')),
    description VARCHAR(1000) NULL,
    evidence_url VARCHAR(500) NULL,
    requested_quantity INT NOT NULL DEFAULT 1 CHECK (requested_quantity >= 1),
    resolution_type VARCHAR(20) NULL CHECK (resolution_type IN ('REFUND','REPLACE','DISCOUNT','REJECT')),
    replacement_variant_id INT NULL,
    refund_amount DECIMAL(14,2) NOT NULL DEFAULT 0 CHECK (refund_amount >= 0),
    status VARCHAR(20) NOT NULL DEFAULT 'REQUESTED' CHECK (status IN ('REQUESTED','APPROVED','REJECTED','PROCESSING','COMPLETED','CANCELLED')),
    decided_by INT NULL,
    decision_reason VARCHAR(500) NULL,
    resolved_at DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (customer_id) REFERENCES users(user_id),
    FOREIGN KEY (replacement_variant_id) REFERENCES product_variants(variant_id),
    FOREIGN KEY (decided_by) REFERENCES users(user_id),
    FOREIGN KEY (order_item_id, order_id) REFERENCES order_items(order_item_id, order_id),
    FOREIGN KEY (order_id, customer_id) REFERENCES orders(order_id, customer_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 20. payment_transactions
CREATE TABLE payment_transactions (
    transaction_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL,
    attempt_no INT NOT NULL DEFAULT 1 CHECK (attempt_no >= 1),
    payment_method VARCHAR(30) NOT NULL DEFAULT 'SEPAY',
    sepay_transaction_id VARCHAR(100) NULL,
    sepay_reference VARCHAR(100) NULL,
    sepay_qr_code VARCHAR(500) NULL,
    amount DECIMAL(14,2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'VND',
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'PROCESSING', 'COMPLETED', 'FAILED', 'CANCELLED', 'REFUNDED', 'EXPIRED')),
    initiated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    completed_at DATETIME NULL,
    expires_at DATETIME NULL,
    provider_response TEXT NULL,
    error_code VARCHAR(50) NULL,
    error_message VARCHAR(500) NULL,
    ip_address VARCHAR(45) NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    UNIQUE KEY UQ_payment_transactions_order_attempt (order_id, attempt_no),
    UNIQUE KEY UX_payment_transactions_sepay_transaction_id (sepay_transaction_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE sepay_webhook_dedup (
    dedup_id INT PRIMARY KEY AUTO_INCREMENT,
    sepay_transaction_id VARCHAR(100) NOT NULL UNIQUE,
    order_code VARCHAR(100) NOT NULL,
    process_result VARCHAR(30) NOT NULL DEFAULT 'processed',
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 21-22. delivery_trips / deliveries
CREATE TABLE delivery_trips (
    trip_id INT PRIMARY KEY AUTO_INCREMENT,
    parent_order_id INT NOT NULL,
    shipper_id INT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'PLANNED' CHECK (status IN ('PLANNED','ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED','CANCELLED')),
    estimated_start_time DATETIME NULL,
    estimated_end_time DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_order_id) REFERENCES orders(order_id),
    FOREIGN KEY (shipper_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE deliveries (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    order_id INT NOT NULL UNIQUE,
    delivery_trip_id INT NULL,
    trip_stop_seq INT NULL,
    staff_id INT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'ASSIGNED' CHECK (status IN ('ASSIGNED','PICKED_UP','IN_TRANSIT','DELIVERED','FAILED','CANCELLED')),
    picked_up_at DATETIME NULL,
    delivered_at DATETIME NULL,
    failure_reason VARCHAR(300) NULL,
    proof_image_url VARCHAR(500) NULL,
    estimated_delivery_time DATETIME NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (delivery_trip_id) REFERENCES delivery_trips(trip_id),
    FOREIGN KEY (staff_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 23. reviews
CREATE TABLE reviews (
    review_id INT PRIMARY KEY AUTO_INCREMENT,
    order_item_id INT NOT NULL,
    order_id INT NOT NULL,
    customer_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text VARCHAR(1000) NULL,
    review_image_url VARCHAR(500) NULL,
    is_hidden TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_item_id, order_id) REFERENCES order_items(order_item_id, order_id),
    FOREIGN KEY (customer_id) REFERENCES users(user_id),
    FOREIGN KEY (order_id, customer_id) REFERENCES orders(order_id, customer_id),
    UNIQUE KEY UQ_review_customer_item (customer_id, order_item_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 24. notifications
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL CHECK (type IN ('ORDER_UPDATE', 'PROMOTION', 'SYSTEM', 'INVENTORY_ALERT', 'PAYMENT', 'WARRANTY_REMINDER')),
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    action_url VARCHAR(300) NULL,
    is_read TINYINT(1) NOT NULL DEFAULT 0,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 25. system_config
CREATE TABLE system_config (
    config_key VARCHAR(100) PRIMARY KEY,
    config_value VARCHAR(500) NOT NULL,
    description VARCHAR(500) NULL,
    data_type VARCHAR(20) NOT NULL DEFAULT 'STRING' CHECK (data_type IN ('STRING','INT','DECIMAL','BOOLEAN')),
    effective_date DATETIME NULL,
    previous_value VARCHAR(500) NULL,
    changed_by INT NULL,
    changed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (changed_by) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 26. audit_logs
CREATE TABLE audit_logs (
    log_id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NULL,
    action VARCHAR(100) NOT NULL,
    target_type VARCHAR(50) NOT NULL,
    target_id INT NULL,
    detail TEXT NOT NULL,
    ip_address VARCHAR(45) NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Index bổ sung
CREATE INDEX IX_orders_acceptance_auto_cancel ON orders (status, acceptance_deadline);
CREATE INDEX IX_return_requests_status ON return_requests(status, created_at);
CREATE INDEX IX_products_status_product_id ON products(status, product_id DESC);
CREATE INDEX IX_products_category_id ON products(category_id, status);
CREATE INDEX IX_cart_items_cart_id_added_at ON cart_items (cart_id, added_at DESC);
CREATE INDEX IX_orders_customer_id_order_id_desc ON orders (customer_id, order_id DESC);
CREATE INDEX IX_orders_status_order_id_desc ON orders (status, order_id DESC);
CREATE INDEX IX_order_items_order_id ON order_items (order_id, order_item_id);
CREATE INDEX IX_order_items_variant_id ON order_items (variant_id, order_item_id);
CREATE INDEX IX_inventory_logs_variant_id_changed_at_desc ON inventory_logs (variant_id, changed_at DESC);
CREATE INDEX IX_return_requests_order_id_created_at_desc ON return_requests (order_id, created_at DESC);
CREATE INDEX IX_deliveries_staff_id_status_delivery_id_desc ON deliveries (staff_id, status, delivery_id DESC);
CREATE INDEX IX_reviews_order_item_id ON reviews (order_item_id);
CREATE INDEX IX_notifications_user_id_is_read_created_at_desc ON notifications (user_id, is_read, created_at DESC);
CREATE INDEX IX_audit_logs_user_id ON audit_logs (user_id);
