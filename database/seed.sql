-- ==========================================================================
-- seed.sql
-- AppleStore seed data. Run this after schema.sql.
-- ==========================================================================

USE AppleStore;

-- ---------- 2.1 store_settings + system_config ----------
REPLACE INTO store_settings (store_id, store_name, store_description, logo_url, business_email, hotline, pickup_address, tax_code, low_stock_threshold) VALUES
    (1, 'Apple Store Việt Nam', 'Cửa hàng chính hãng Apple: iPhone, iPad, Mac, Apple Watch, AirPods.', '/images/store/logo.png', 'contact@applestore.vn', '19001234', '12 Lê Lợi, Q.1, TP.HCM', '0312345678', 5);

INSERT INTO system_config (config_key, config_value, description, data_type) VALUES
    ('gemini_api_key', '', 'Không còn dùng (chatbot đã bị gỡ bỏ khỏi hệ thống).', 'STRING'),
    ('product_auto_approve', 'true', 'Sản phẩm tạo mới hiển thị ngay không cần duyệt (mô hình 1 shop).', 'BOOLEAN');

-- ---------- 2.2 categories ----------
INSERT INTO categories (category_id, name, slug, display_order) VALUES
    (1, 'iPhone',       'iphone',       1),
    (2, 'iPad',         'ipad',         2),
    (3, 'Mac',          'mac',          3),
    (4, 'Apple Watch',  'apple-watch',  4),
    (5, 'AirPods',      'airpods',      5),
    (6, 'TV & Nhà thông minh', 'tv-home', 6),
    (7, 'Phụ kiện',     'phu-kien',     7);

-- ---------- 2.3 users ----------
INSERT INTO users (user_id, full_name, email, password_hash, phone, role, status, is_email_verified) VALUES
    (1, 'Quản trị hệ thống (Chủ shop)', 'admin@applestore.vn', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000001', 'ADMIN', 'ACTIVE', 1),
    (2, 'Phạm Văn Sơn', 'shipper1@applestore.vn', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000005', 'DELIVERY', 'ACTIVE', 1),
    (3, 'Đỗ Thanh Hải', 'shipper2@applestore.vn', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000006', 'DELIVERY', 'ACTIVE', 1),
    (4, 'Nguyễn Văn An', 'customer1@gmail.com', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000007', 'CUSTOMER', 'ACTIVE', 1),
    (5, 'Trần Thị Bích', 'customer2@gmail.com', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000008', 'CUSTOMER', 'ACTIVE', 1),
    (6, 'Lê Văn Chiến', 'customer3@gmail.com', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000009', 'CUSTOMER', 'ACTIVE', 1),
    (7, 'Phạm Thị Duyên', 'customer4@gmail.com', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000010', 'CUSTOMER', 'ACTIVE', 1),
    (8, 'Hoàng Văn Em', 'customer5@gmail.com', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000011', 'CUSTOMER', 'INACTIVE', 0),
    (9, 'Nguyễn Minh Sale', 'sale@applestore.vn', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000012', 'SALE_STAFF', 'ACTIVE', 1),
    (10, 'Nguyễn Luân Sale', 'sale1@applestore.vn', '210000:lAqSmZs36ZsJWkQol+ePIQ==:PWhweQHIwxxTgFI3xzy56wEIDQISuqX7+xcYp4ctdx4=', '0900000013', 'SALE_STAFF', 'ACTIVE', 1);

-- ---------- 2.4 user_addresses ----------
INSERT INTO user_addresses (user_id, recipient_name, recipient_phone, address_detail, is_default) VALUES
    (4, 'Nguyễn Văn An',  '0900000007', '123 Nguyễn Trãi, P.7, Q.5, TP.HCM', 1),
    (5, 'Trần Thị Bích',  '0900000008', '56 Phan Xích Long, P.2, Q.Phú Nhuận, TP.HCM', 1),
    (6, 'Lê Văn Chiến',   '0900000009', '78 Hoàng Văn Thụ, P.9, Q.Tân Bình, TP.HCM', 1),
    (7, 'Phạm Thị Duyên', '0900000010', '34 Nguyễn Văn Cừ, P.4, Q.1, TP.HCM', 1);

-- ---------- 2.5 products ----------
INSERT INTO products (product_id, created_by, category_id, name, description, model_code, release_year, product_condition, import_type, origin_country, warranty_months, status, view_count, rating, sold_quantity, is_featured) VALUES
    (1,  1, 1, 'iPhone 15 Pro Max',      'Chip A17 Pro, khung Titan, camera 5x Tele, cổng USB-C.', 'A2894', 2023, 'NEW', 'VN/A', 'Trung Quốc', 12, 'ACTIVE', 15420, 4.9, 210, 1),
    (2,  1, 1, 'iPhone 15',              'Chip A16 Bionic, Dynamic Island, camera chính 48MP.',    'A2846', 2023, 'NEW', 'VN/A', 'Ấn Độ',     12, 'ACTIVE', 9800,  4.7, 340, 1),
    (3,  1, 3, 'MacBook Air 13" M3',     'Chip Apple M3, màn hình Liquid Retina 13.6 inch, không quạt tản nhiệt.', 'A3113', 2024, 'NEW', 'VN/A', 'Việt Nam', 12, 'ACTIVE', 7600, 4.8, 150, 1),
    (4,  1, 3, 'MacBook Pro 14" M3 Pro', 'Chip M3 Pro, màn hình Liquid Retina XDR, dành cho dân chuyên nghiệp.',   'A2918', 2023, 'NEW', 'VN/A', 'Việt Nam', 12, 'ACTIVE', 5200, 4.9, 88,  0),
    (5,  1, 2, 'iPad Air 11" M2',        'Chip Apple M2, hỗ trợ Apple Pencil Pro, màn hình Liquid Retina.',        'A2902', 2024, 'NEW', 'VN/A', 'Việt Nam', 12, 'ACTIVE', 4300, 4.6, 120, 0),
    (6,  1, 2, 'iPad Pro 11" M4',        'Chip Apple M4, màn hình Ultra Retina XDR, siêu mỏng nhẹ.',               'A2836', 2024, 'NEW', 'VN/A', 'Việt Nam', 12, 'ACTIVE', 3900, 4.8, 60,  1),
    (7,  1, 4, 'Apple Watch Series 9',   'Cử chỉ Double Tap, chip S9, màn hình sáng gấp đôi ngoài trời.',          'A2986', 2023, 'NEW', 'VN/A', 'Việt Nam', 12, 'ACTIVE', 6100, 4.7, 175, 0),
    (8,  1, 5, 'AirPods Pro 2 (USB-C)',  'Chống ồn chủ động 2x, âm thanh không gian cá nhân hoá.',                 'A2698', 2023, 'NEW', 'VN/A', 'Việt Nam', 12, 'ACTIVE', 11200,4.8, 430, 1),
    (9,  1, 5, 'AirPods Max',            'Tai nghe over-ear, chống ồn chủ động, âm thanh Hi-Fi.',                  'A2096', 2020, 'NEW', 'VN/A', 'Trung Quốc', 12, 'ACTIVE', 2100, 4.5, 42,  0),
    (10, 1, 6, 'Apple TV 4K (Wi-Fi)',    'Chip A15 Bionic, hỗ trợ HDR10+, Dolby Vision, Dolby Atmos.',             'A2737', 2022, 'NEW', 'VN/A', 'Việt Nam', 12, 'ACTIVE', 1500, 4.4, 35,  0),
    (11, 1, 7, 'MagSafe Charger',        'Sạc không dây từ tính công suất 15W dành cho iPhone.',                   'A2140', 2020, 'NEW', 'VN/A', 'Trung Quốc', 12, 'ACTIVE', 3300, 4.3, 260, 0),
    (12, 1, 7, 'Magic Keyboard cho iPad Pro 11"', 'Bàn phím kèm trackpad, cổng USB-C sạc qua, có đèn nền phím.',   'A2074', 2024, 'NEW', 'VN/A', 'Việt Nam', 12, 'ACTIVE', 1800, 4.5, 55,  0);

-- ---------- 2.6 product_images ----------
INSERT INTO product_images (product_id, file_path, display_order, is_primary) VALUES
    (1, 'assets/images/products/iphone-15-pro-max-titan-tu-nhien.png', 1, 1),
    (1, 'assets/images/products/iphone-15-pro-max-titan-tu-nhien-goc-canh.png', 2, 0),
    (1, 'assets/images/products/iphone-15-pro-max-titan-tu-nhien-goc-sau.png', 3, 0),
    (1, 'assets/images/products/iphone-15-pro-max-titan-xanh.png', 4, 0),
    (1, 'assets/images/products/iphone-15-pro-max-titan-xanh-goc-canh.png', 5, 0),
    (1, 'assets/images/products/iphone-15-pro-max-titan-xanh-goc-sau.png', 6, 0),
    (2, 'assets/images/products/iphone-15-hong.png', 1, 1),
    (2, 'assets/images/products/iphone-15-hong-goc-canh.png', 2, 0),
    (2, 'assets/images/products/iphone-15-hong-goc-sau.png', 3, 0),
    (2, 'assets/images/products/iphone-15-den.png', 4, 0),
    (2, 'assets/images/products/iphone-15-den-goc-canh.png', 5, 0),
    (2, 'assets/images/products/iphone-15-den-goc-sau.png', 6, 0),
    (3, 'assets/images/products/macbook-air-13-m3-bac.png', 1, 1),
    (3, 'assets/images/products/macbook-air-13-m3-bac-goc-canh.png', 2, 0),
    (3, 'assets/images/products/macbook-air-13-m3-bac-goc-sau.png', 3, 0),
    (3, 'assets/images/products/macbook-air-13-m3-dem.png', 4, 0),
    (3, 'assets/images/products/macbook-air-13-m3-dem-goc-canh.png', 5, 0),
    (3, 'assets/images/products/macbook-air-13-m3-dem-goc-sau.png', 6, 0),
    (4, 'assets/images/products/macbook-pro-14-m3-pro-bac.png', 1, 1),
    (4, 'assets/images/products/macbook-pro-14-m3-pro-bac-goc-canh.png', 2, 0),
    (4, 'assets/images/products/macbook-pro-14-m3-pro-bac-goc-sau.png', 3, 0),
    (4, 'assets/images/products/macbook-pro-14-m3-pro-xam-khong-gian.png', 4, 0),
    (4, 'assets/images/products/macbook-pro-14-m3-pro-xam-khong-gian-goc-canh.png', 5, 0),
    (4, 'assets/images/products/macbook-pro-14-m3-pro-xam-khong-gian-goc-sau.png', 6, 0),
    (5, 'assets/images/products/ipad-air-11-m2-bac.png', 1, 1),
    (5, 'assets/images/products/ipad-air-11-m2-bac-goc-canh.png', 2, 0),
    (5, 'assets/images/products/ipad-air-11-m2-bac-goc-sau.png', 3, 0),
    (5, 'assets/images/products/ipad-air-11-m2-xanh-duong.png', 4, 0),
    (5, 'assets/images/products/ipad-air-11-m2-xanh-duong-goc-canh.png', 5, 0),
    (5, 'assets/images/products/ipad-air-11-m2-xanh-duong-goc-sau.png', 6, 0),
    (6, 'assets/images/products/ipad-pro-11-m4-den.png', 1, 1),
    (6, 'assets/images/products/ipad-pro-11-m4-den-goc-canh.png', 2, 0),
    (6, 'assets/images/products/ipad-pro-11-m4-den-goc-sau.png', 3, 0),
    (7, 'assets/images/products/apple-watch-series-9-anh-sao.png', 1, 1),
    (7, 'assets/images/products/apple-watch-series-9-anh-sao-goc-canh.png', 2, 0),
    (7, 'assets/images/products/apple-watch-series-9-anh-sao-goc-sau.png', 3, 0),
    (7, 'assets/images/products/apple-watch-series-9-giua-dem.png', 4, 0),
    (7, 'assets/images/products/apple-watch-series-9-giua-dem-goc-canh.png', 5, 0),
    (7, 'assets/images/products/apple-watch-series-9-giua-dem-goc-sau.png', 6, 0),
    (8, 'assets/images/products/airpods-pro-2-usbc-trang.png', 1, 1),
    (8, 'assets/images/products/airpods-pro-2-usbc-trang-goc-sau.png', 2, 0),
    (8, 'assets/images/products/airpods-pro-2-usbc-trang-goc-chi-tiet.png', 3, 0),
    (9, 'assets/images/products/airpods-max-xam-khong-gian.png', 1, 1),
    (9, 'assets/images/products/airpods-max-xam-khong-gian-goc-canh.png', 2, 0),
    (9, 'assets/images/products/airpods-max-xam-khong-gian-goc-sau.png', 3, 0),
    (9, 'assets/images/products/airpods-max-xanh-troi.png', 4, 0),
    (9, 'assets/images/products/airpods-max-xanh-troi-goc-canh.png', 5, 0),
    (9, 'assets/images/products/airpods-max-xanh-troi-goc-sau.png', 6, 0),
    (10, 'assets/images/products/apple-tv-4k-wifi.png', 1, 1),
    (10, 'assets/images/products/apple-tv-4k-wifi-goc-canh.png', 2, 0),
    (10, 'assets/images/products/apple-tv-4k-wifi-goc-sau.png', 3, 0),
    (11, 'assets/images/products/magsafe-charger-trang.png', 1, 1),
    (11, 'assets/images/products/magsafe-charger-trang-goc-canh.png', 2, 0),
    (11, 'assets/images/products/magsafe-charger-trang-goc-sau.png', 3, 0),
    (12, 'assets/images/products/magic-keyboard-ipad-pro-11-den.png', 1, 1),
    (12, 'assets/images/products/magic-keyboard-ipad-pro-11-den-goc-canh.png', 2, 0),
    (12, 'assets/images/products/magic-keyboard-ipad-pro-11-den-goc-tren.png', 3, 0),
    (12, 'assets/images/products/magic-keyboard-ipad-pro-11-trang.png', 4, 0),
    (12, 'assets/images/products/magic-keyboard-ipad-pro-11-trang-goc-canh.png', 5, 0),
    (12, 'assets/images/products/magic-keyboard-ipad-pro-11-trang-goc-tren.png', 6, 0);

-- ---------- 2.7 product_specifications ----------
INSERT INTO product_specifications (product_id, spec_group, spec_name, spec_value, display_order) VALUES
    (1, 'Màn hình', 'Kích thước', '6.7 inch Super Retina XDR', 1),
    (1, 'Chip xử lý', 'Chip', 'Apple A17 Pro (6 nhân CPU, 6 nhân GPU)', 2),
    (1, 'Camera', 'Camera sau', 'Chính 48MP, Tele 5x 12MP, Ultrawide 12MP', 3),
    (1, 'Pin & Sạc', 'Thời lượng pin', 'Xem video lên đến 29 giờ', 4),
    (1, 'Kết nối', 'Cổng kết nối', 'USB-C (USB 3, tốc độ lên đến 10Gb/s)', 5),
    (2, 'Màn hình', 'Kích thước', '6.1 inch Super Retina XDR', 1),
    (2, 'Chip xử lý', 'Chip', 'Apple A16 Bionic', 2),
    (2, 'Camera', 'Camera sau', 'Chính 48MP, Ultrawide 12MP', 3),
    (2, 'Pin & Sạc', 'Thời lượng pin', 'Xem video lên đến 20 giờ', 4),
    (3, 'Màn hình', 'Kích thước', '13.6 inch Liquid Retina', 1),
    (3, 'Chip xử lý', 'Chip', 'Apple M3 (8 nhân CPU, tối đa 10 nhân GPU)', 2),
    (3, 'Pin & Sạc', 'Thời lượng pin', 'Lên đến 18 giờ dùng Wi-Fi', 3),
    (3, 'Kết nối', 'Cổng kết nối', 'Thunderbolt/USB 4 (2 cổng), MagSafe 3', 4),
    (4, 'Màn hình', 'Kích thước', '14.2 inch Liquid Retina XDR', 1),
    (4, 'Chip xử lý', 'Chip', 'Apple M3 Pro (12 nhân CPU, 18 nhân GPU)', 2),
    (4, 'Pin & Sạc', 'Thời lượng pin', 'Lên đến 18 giờ dùng Wi-Fi', 3),
    (5, 'Màn hình', 'Kích thước', '11 inch Liquid Retina', 1),
    (5, 'Chip xử lý', 'Chip', 'Apple M2', 2),
    (5, 'Phụ kiện', 'Bút hỗ trợ', 'Apple Pencil Pro, Apple Pencil (USB-C)', 3),
    (6, 'Màn hình', 'Kích thước', '11 inch Ultra Retina XDR (OLED)', 1),
    (6, 'Chip xử lý', 'Chip', 'Apple M4', 2),
    (7, 'Màn hình', 'Kích thước', 'Luôn hiển thị, sáng tối đa 2000 nits', 1),
    (7, 'Chip xử lý', 'Chip', 'S9 SiP', 2),
    (7, 'Tính năng', 'Sức khoẻ', 'Đo nồng độ oxy trong máu, điện tâm đồ ECG', 3),
    (8, 'Âm thanh', 'Chống ồn', 'Chống ồn chủ động thế hệ 2, chế độ Xuyên âm thích ứng', 1),
    (8, 'Pin & Sạc', 'Thời lượng pin', 'Lên đến 6 giờ nghe nhạc (bật ANC)', 2),
    (9, 'Âm thanh', 'Kiểu dáng', 'Over-ear, đệm tai bằng lưới thoáng khí', 1),
    (9, 'Pin & Sạc', 'Thời lượng pin', 'Lên đến 20 giờ nghe nhạc', 2),
    (10, 'Chip xử lý', 'Chip', 'Apple A15 Bionic', 1),
    (10, 'Kết nối', 'Kết nối', 'Wi-Fi 6', 2),
    (12, 'Tương thích', 'Thiết bị', 'iPad Pro 11 inch', 1);

-- ---------- 2.8 product_variants ----------
INSERT INTO product_variants (variant_id, product_id, sku, variant_label, color_name, case_size_mm, storage_capacity_gb, ram_gb, connectivity, price, stock_quantity, weight_kg) VALUES
    (1,  1, 'IP15PM-256-NATT', '256GB - Titan Tự Nhiên', 'Titan Tự Nhiên', NULL, 256, NULL, NULL, 34990000, 25, 0.221),
    (2,  1, 'IP15PM-512-NATT', '512GB - Titan Tự Nhiên', 'Titan Tự Nhiên', NULL, 512, NULL, NULL, 40990000, 12, 0.221),
    (3,  1, 'IP15PM-256-BLTT', '256GB - Titan Xanh',     'Titan Xanh',     NULL, 256, NULL, NULL, 34990000, 18, 0.221),
    (4,  2, 'IP15-128-PINK',   '128GB - Hồng',            'Hồng',          NULL, 128, NULL, NULL, 22990000, 30, 0.171),
    (5,  2, 'IP15-256-BLACK',  '256GB - Đen',             'Đen',           NULL, 256, NULL, NULL, 25990000, 22, 0.171),
    (6,  3, 'MBA13-M3-256-SL', '8GB/256GB - Bạc',         'Bạc',           NULL, 256, 8,  NULL, 27990000, 15, 1.240),
    (7,  3, 'MBA13-M3-512-MN', '16GB/512GB - Đêm',        'Đêm',           NULL, 512, 16, NULL, 33990000, 8,  1.240),
    (8,  4, 'MBP14-M3P-512-SG', '18GB/512GB - Xám Không Gian', 'Xám Không Gian', NULL, 512, 18, NULL, 52990000, 6, 1.550),
    (9,  4, 'MBP14-M3P-1TB-SL', '18GB/1TB - Bạc',         'Bạc',           NULL, 1024, 18, NULL, 59990000, 4, 1.550),
    (10, 5, 'IPADAIR11-128-WIFI', '128GB - Wi-Fi - Xanh Dương', 'Xanh Dương', NULL, 128, 8, 'WIFI', 16990000, 20, 0.462),
    (11, 5, 'IPADAIR11-256-CELL', '256GB - Wi-Fi + Cellular - Bạc', 'Bạc', NULL, 256, 8, 'WIFI_CELLULAR', 21990000, 10, 0.470),
    (12, 6, 'IPADPRO11-256-WIFI', '256GB - Wi-Fi - Đen', 'Đen', NULL, 256, 8, 'WIFI', 28990000, 9, 0.446),
    (13, 7, 'AWS9-41-MID',  '41mm - Viền Nhôm Giữa Đêm', 'Giữa Đêm', 41, NULL, NULL, NULL, 10990000, 25, 0.038),
    (14, 7, 'AWS9-45-STAR', '45mm - Viền Nhôm Ánh Sao',  'Ánh Sao', 45, NULL, NULL, NULL, 11990000, 20, 0.039),
    (15, 8, 'APP2-USBC-WHT', 'Bản tiêu chuẩn - Trắng', 'Trắng', NULL, NULL, NULL, NULL, 5990000, 60, 0.061),
    (16, 9, 'APM-SPACEGRAY', 'Xám Không Gian', 'Xám Không Gian', NULL, NULL, NULL, NULL, 12990000, 10, 0.385),
    (17, 9, 'APM-SKYBLUE',   'Xanh Trời',       'Xanh Trời',      NULL, NULL, NULL, NULL, 12990000, 6,  0.385),
    (18, 10,'ATV4K-64',  '64GB', NULL, NULL, 64, NULL, NULL, 3490000, 15, 0.078),
    (19, 10,'ATV4K-128', '128GB', NULL, NULL, 128, NULL, NULL, 3990000, 10, 0.078),
    (20, 11,'MAGSAFE-CHG', 'Bản tiêu chuẩn', NULL, NULL, NULL, NULL, NULL, 990000, 80, 0.060),
    (21, 12,'MKB-IPADPRO11-BLK', 'Màu Đen', 'Đen', NULL, NULL, NULL, NULL, 7990000, 12, 0.340),
    (22, 12,'MKB-IPADPRO11-WHT', 'Màu Trắng', 'Trắng', NULL, NULL, NULL, NULL, 7990000, 8,  0.340);

-- ---------- 2.9 product_serials ----------
INSERT INTO product_serials (variant_id, serial_number, imei_1, imei_2, status, warranty_start_date, warranty_end_date) VALUES
    (1, 'SN-IP15PM-0001', '359123000000001', '359123000000002', 'IN_STOCK', NULL, NULL),
    (1, 'SN-IP15PM-0002', '359123000000003', '359123000000004', 'IN_STOCK', NULL, NULL),
    (1, 'SN-IP15PM-0003', '359123000000005', '359123000000006', 'SOLD',     '2025-01-05', '2026-01-05'),
    (3, 'SN-IP15PM-0004', '359123000000007', NULL,              'IN_STOCK', NULL, NULL),
    (4, 'SN-IP15-0001',   '359124000000001', NULL,              'IN_STOCK', NULL, NULL),
    (5, 'SN-IP15-0002',   '359124000000002', NULL,              'SOLD',     '2025-02-10', '2026-02-10'),
    (6, 'SN-MBA13-0001',  NULL, NULL, 'IN_STOCK', NULL, NULL),
    (7, 'SN-MBA13-0002',  NULL, NULL, 'SOLD',     '2025-01-20', '2026-01-20'),
    (8, 'SN-MBP14-0001',  NULL, NULL, 'IN_STOCK', NULL, NULL),
    (15,'SN-APP2-0001',   NULL, NULL, 'SOLD',     '2025-03-01', '2026-03-01'),
    (15,'SN-APP2-0002',   NULL, NULL, 'IN_STOCK', NULL, NULL);

-- ---------- 2.10 product_addon_services ----------
INSERT INTO product_addon_services (product_id, name, addon_type, price_add) VALUES
    (1, 'AppleCare+ 2 năm',              'WARRANTY_EXTENSION', 5490000),
    (1, 'Dán màn hình cường lực',        'SERVICE',             299000),
    (2, 'AppleCare+ 2 năm',              'WARRANTY_EXTENSION', 4490000),
    (3, 'AppleCare+ 3 năm cho Mac',      'WARRANTY_EXTENSION', 4990000),
    (3, 'Khắc tên/logo miễn phí',        'ACCESSORY',                0),
    (4, 'AppleCare+ 3 năm cho Mac',      'WARRANTY_EXTENSION', 6990000),
    (5, 'AppleCare+ cho iPad',           'WARRANTY_EXTENSION', 2490000),
    (6, 'AppleCare+ cho iPad',           'WARRANTY_EXTENSION', 2990000),
    (8, 'Khắc tên miễn phí trên hộp',    'ACCESSORY',                0);

-- ---------- 2.11 promotions ----------
INSERT INTO promotions (promo_id, code, discount_type, discount_max, discount_value, min_order_value, scope, benefit_target, max_uses, created_by, valid_from, valid_until) VALUES
    (1, 'WELCOME10',   'PERCENT', 500000, 10, 5000000,  'ORDER',   'MERCHANDISE', 1000, 1, '2025-01-01 00:00:00', '2026-12-31 23:59:59'),
    (2, 'FREESHIP',    'FIXED',   50000,  50000, 0,     'ORDER',   'SHIPPING',    5000, 1, '2025-01-01 00:00:00', '2026-12-31 23:59:59'),
    (3, 'IPHONE500K',  'FIXED',   500000, 500000, 20000000, 'PRODUCT', 'PRODUCT', 200,  1, '2025-06-01 00:00:00', '2026-12-31 23:59:59'),
    (4, 'MACBOOK1M',   'FIXED',   1000000,1000000, 25000000, 'PRODUCT','PRODUCT', 100,  1, '2025-06-01 00:00:00', '2026-12-31 23:59:59');

INSERT INTO promotion_products (promo_id, product_id) VALUES
    (3, 1),
    (4, 3);

-- ---------- 2.12 cart + cart_items ----------
INSERT INTO cart (cart_id, customer_id) VALUES (1, 4);
INSERT INTO cart_items (cart_id, variant_id, quantity, addon_id) VALUES
    (1, 15, 1, NULL),
    (1, 20, 2, NULL);

-- ---------- 2.13 orders + order_items ----------
INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status) VALUES
    (300, 4, '123 Nguyễn Trãi, P.7, Q.5, TP.HCM', 'Nguyễn Văn An', '0900000007', 'PENDING_PAYMENT', 40480000, 0, 0, 40480000, 'CK', 'NONE', 'PENDING');
INSERT INTO order_items (order_item_id, order_id, variant_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal, addon_label_snapshot, addon_price_snapshot) VALUES
    (300, 300, 1, 'iPhone 15 Pro Max', '256GB - Titan Tự Nhiên', 1, 34990000, 34990000, 'AppleCare+ 2 năm', 5490000);

INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status, accepted_at) VALUES
    (301, 5, '56 Phan Xích Long, P.2, Q.Phú Nhuận, TP.HCM', 'Trần Thị Bích', '0900000008', 'CONFIRMED', 5990000, 30000, 0, 6020000, 'COD', 'NONE', 'PENDING', CURRENT_TIMESTAMP);
INSERT INTO order_items (order_item_id, order_id, variant_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal) VALUES
    (301, 301, 15, 'AirPods Pro 2 (USB-C)', 'Bản tiêu chuẩn - Trắng', 1, 5990000, 5990000);

INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status, accepted_at) VALUES
    (302, 6, '78 Hoàng Văn Thụ, P.9, Q.Tân Bình, TP.HCM', 'Lê Văn Chiến', '0900000009', 'PREPARING', 27990000, 0, 0, 27990000, 'CK', 'NONE', 'PENDING', CURRENT_TIMESTAMP);
INSERT INTO order_items (order_item_id, order_id, variant_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal) VALUES
    (302, 302, 6, 'MacBook Air 13" M3', '8GB/256GB - Bạc', 1, 27990000, 27990000);

INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status, accepted_at) VALUES
    (303, 7, '34 Nguyễn Văn Cừ, P.4, Q.1, TP.HCM', 'Phạm Thị Duyên', '0900000010', 'DISPATCHED', 16990000, 20000, 0, 17010000, 'CK', 'NONE', 'PENDING', CURRENT_TIMESTAMP);
INSERT INTO order_items (order_item_id, order_id, variant_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal) VALUES
    (303, 303, 10, 'iPad Air 11" M2', '128GB - Wi-Fi - Xanh Dương', 1, 16990000, 16990000);

INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status, accepted_at) VALUES
    (304, 4, '123 Nguyễn Trãi, P.7, Q.5, TP.HCM', 'Nguyễn Văn An', '0900000007', 'DELIVERED', 25990000, 0, 500000, 25490000, 'CK', 'NONE', 'RECEIVED', CURRENT_TIMESTAMP);
INSERT INTO order_items (order_item_id, order_id, variant_id, serial_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal) VALUES
    (304, 304, 5, 6, 'iPhone 15', '256GB - Đen', 1, 25990000, 25990000);
UPDATE product_serials SET status = 'SOLD', order_item_id = 304, warranty_start_date = '2025-02-10', warranty_end_date = '2026-02-10' WHERE serial_id = 6;

INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status, accepted_at) VALUES
    (305, 5, '56 Phan Xích Long, P.2, Q.Phú Nhuận, TP.HCM', 'Trần Thị Bích', '0900000008', 'DELIVERED', 33990000, 0, 0, 33990000, 'CK', 'NONE', 'RECEIVED', CURRENT_TIMESTAMP);
INSERT INTO order_items (order_item_id, order_id, variant_id, serial_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal) VALUES
    (305, 305, 7, 8, 'MacBook Air 13" M3', '16GB/512GB - Đêm', 1, 33990000, 33990000);
UPDATE product_serials SET status = 'SOLD', order_item_id = 305, warranty_start_date = '2025-01-20', warranty_end_date = '2026-01-20' WHERE serial_id = 8;

INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status, cancelled_at, cancelled_by, cancellation_reason) VALUES
    (306, 6, '78 Hoàng Văn Thụ, P.9, Q.Tân Bình, TP.HCM', 'Lê Văn Chiến', '0900000009', 'CANCELLED', 10990000, 0, 0, 10990000, 'CK', 'NONE', 'PENDING', CURRENT_TIMESTAMP, 6, 'Khách đổi ý, không muốn mua nữa');
INSERT INTO order_items (order_item_id, order_id, variant_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal) VALUES
    (306, 306, 13, 'Apple Watch Series 9', '41mm - Viền Nhôm Giữa Đêm', 1, 10990000, 10990000);

INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status, accepted_at) VALUES
    (307, 7, '34 Nguyễn Văn Cừ, P.4, Q.1, TP.HCM', 'Phạm Thị Duyên', '0900000010', 'DELIVERED', 5990000, 0, 0, 5990000, 'CK', 'NONE', 'RECEIVED', CURRENT_TIMESTAMP);
INSERT INTO order_items (order_item_id, order_id, variant_id, serial_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal) VALUES
    (307, 307, 15, 10, 'AirPods Pro 2 (USB-C)', 'Bản tiêu chuẩn - Trắng', 1, 5990000, 5990000);
UPDATE product_serials SET status = 'SOLD', order_item_id = 307, warranty_start_date = '2025-03-01', warranty_end_date = '2026-03-01' WHERE serial_id = 10;

INSERT INTO orders (order_id, customer_id, delivery_address, recipient_name, recipient_phone, status, total_amount, delivery_fee, discount_amount, final_amount, payment_method, refund_status, received_status) VALUES
    (308, 8, '90 Lý Thường Kiệt, P.15, Q.10, TP.HCM', 'Hoàng Văn Em', '0900000011', 'PAYMENT_FAILED', 3990000, 0, 0, 3990000, 'CK', 'NONE', 'PENDING');
INSERT INTO order_items (order_item_id, order_id, variant_id, product_name_snapshot, variant_label_snapshot, quantity, unit_price, subtotal) VALUES
    (308, 308, 19, 'Apple TV 4K (Wi-Fi)', '128GB', 1, 3990000, 3990000);

-- ---------- 2.14 order_promotions ----------
INSERT INTO order_promotions (order_id, promo_id, customer_id, discount_applied, coupon_code, benefit_target) VALUES
    (304, 3, 4, 500000, 'IPHONE500K', 'PRODUCT');

-- ---------- 2.15 return_requests ----------
INSERT INTO return_requests (return_request_id, order_id, order_item_id, customer_id, request_type, reason_code, description, requested_quantity, refund_amount, status) VALUES
    (300, 304, 304, 4, 'RETURN', 'NOT_AS_DESCRIBED', 'Demo: máy không đúng như mô tả màu sắc', 1, 0, 'REQUESTED');
INSERT INTO return_requests (return_request_id, order_id, order_item_id, customer_id, request_type, reason_code, description, requested_quantity, resolution_type, refund_amount, status, decided_by) VALUES
    (301, 305, 305, 5, 'WARRANTY_CLAIM', 'HARDWARE_DEFECT', 'Demo: máy bị lỗi bàn phím, đã duyệt bảo hành đổi máy', 1, 'REPLACE', 0, 'APPROVED', 1);
INSERT INTO return_requests (return_request_id, order_id, order_item_id, customer_id, request_type, reason_code, description, requested_quantity, resolution_type, refund_amount, status, decided_by, resolved_at) VALUES
    (302, 307, 307, 7, 'RETURN', 'SOFTWARE_ISSUE', 'Demo: tai nghe lỗi kết nối Bluetooth, đã hoàn tiền xong', 1, 'REFUND', 5990000.00, 'COMPLETED', 1, CURRENT_TIMESTAMP);
INSERT INTO return_requests (return_request_id, order_id, order_item_id, customer_id, request_type, reason_code, description, requested_quantity, resolution_type, refund_amount, status, decided_by, decision_reason, resolved_at) VALUES
    (303, 306, 306, 6, 'CANCEL', 'CHANGED_MIND', 'Demo: yêu cầu huỷ bị từ chối vì đơn đã giao', 1, 'REJECT', 0, 'REJECTED', 1, 'Đơn hàng đã được giao thành công trước khi có yêu cầu huỷ', CURRENT_TIMESTAMP);

-- ---------- 2.16 payment_transactions ----------
INSERT INTO payment_transactions (order_id, payment_method, sepay_reference, sepay_qr_code, amount, status, expires_at) VALUES
    (300, 'SEPAY', 'DH300', 'https://qr.sepay.vn/img?bank=MBBank&acc=demo&amount=40480000&des=DH300', 40480000, 'PENDING', DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 15 MINUTE));

INSERT INTO payment_transactions (order_id, payment_method, sepay_reference, amount, status, completed_at) VALUES
    (304, 'SEPAY', 'DH304', 25490000, 'COMPLETED', CURRENT_TIMESTAMP),
    (305, 'SEPAY', 'DH305', 33990000, 'COMPLETED', CURRENT_TIMESTAMP),
    (307, 'SEPAY', 'DH307', 5990000,  'COMPLETED', CURRENT_TIMESTAMP);

INSERT INTO payment_transactions (order_id, payment_method, sepay_reference, amount, status, error_code, error_message) VALUES
    (308, 'SEPAY', 'DH308', 3990000, 'FAILED', 'INSUFFICIENT_FUNDS', 'Tài khoản không đủ số dư');

-- ---------- 2.17 delivery_trips + deliveries ----------
INSERT INTO delivery_trips (trip_id, parent_order_id, shipper_id, status, estimated_start_time, estimated_end_time) VALUES
    (300, 303, 2, 'IN_TRANSIT', CURRENT_TIMESTAMP, DATE_ADD(CURRENT_TIMESTAMP, INTERVAL 2 HOUR)),
    (301, 304, 2, 'DELIVERED',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (302, 305, 3, 'DELIVERED',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (303, 307, 3, 'DELIVERED',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO deliveries (delivery_id, order_id, delivery_trip_id, staff_id, status, picked_up_at, delivered_at) VALUES
    (300, 303, 300, 2, 'IN_TRANSIT', CURRENT_TIMESTAMP, NULL),
    (301, 304, 301, 2, 'DELIVERED',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (302, 305, 302, 3, 'DELIVERED',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
    (303, 307, 303, 3, 'DELIVERED',  CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

INSERT INTO deliveries (delivery_id, order_id, staff_id, status, failure_reason) VALUES
    (304, 306, 2, 'CANCELLED', 'Đơn hàng đã bị huỷ trước khi giao');

-- ---------- 2.18 reviews ----------
INSERT INTO reviews (order_item_id, order_id, customer_id, rating, review_text) VALUES
    (304, 304, 4, 5, 'Máy đẹp, giao nhanh, đóng gói cẩn thận. Rất hài lòng!'),
    (305, 305, 5, 4, 'MacBook chạy mượt, nhưng giao hàng hơi trễ so với dự kiến.'),
    (307, 307, 7, 5, 'Tai nghe chống ồn rất tốt, đúng hàng chính hãng VN/A.');

-- ---------- 2.19 notifications ----------
INSERT INTO notifications (user_id, type, title, message, action_url, is_read) VALUES
    (4, 'ORDER_UPDATE',     'Đơn hàng đang được giao', 'Đơn hàng #304 của bạn đã được giao thành công.', '/orders/304', 1),
    (5, 'ORDER_UPDATE',     'Đơn hàng đã xác nhận',    'Đơn hàng #301 của bạn đã được xác nhận.',    '/orders/301', 0),
    (1, 'INVENTORY_ALERT',  'Sắp hết hàng',            'Biến thể "iPhone 15 Pro Max - 512GB Titan Tự Nhiên" sắp hết hàng.', '/admin/inventory', 0),
    (7, 'WARRANTY_REMINDER','Nhắc lịch bảo hành',      'AirPods Pro 2 của bạn sẽ hết hạn bảo hành trong 30 ngày tới.', '/warranty', 0),
    (6, 'ORDER_UPDATE',     'Đơn hàng đã huỷ',         'Đơn hàng #306 của bạn đã được huỷ theo yêu cầu.', '/orders/306', 1);

-- ---------- 2.20 audit_logs ----------
INSERT INTO audit_logs (user_id, action, target_type, target_id, detail, ip_address) VALUES
    (1, 'CREATE_PRODUCT', 'product', 1, 'Admin thêm sản phẩm mới iPhone 15 Pro Max', '127.0.0.1'),
    (1, 'CONFIRM_ORDER',  'order',   301, 'Admin xác nhận đơn hàng #301', '127.0.0.1'),
    (1, 'UPDATE_STORE_SETTINGS', 'store_settings', 1, 'Admin cập nhật thông tin cửa hàng', '127.0.0.1');

-- ---------- 2.21 CẬP NHẬT RATING THEO YÊU CẦU ----------
SET SQL_SAFE_UPDATES = 0;
UPDATE products p
SET p.rating = (
    SELECT COALESCE(ROUND(AVG(r.rating), 2), 0)
    FROM reviews r
    JOIN order_items oi ON r.order_item_id = oi.order_item_id
    JOIN product_variants pv ON oi.variant_id = pv.variant_id
    WHERE pv.product_id = p.product_id AND r.is_hidden = 0
);
SET SQL_SAFE_UPDATES = 1;

-- ==========================================================================
