-- Bo sung rieng 15 bien the moi tu seed.sql, khong reset database.
-- Chay file nay tren database AppleStore hien tai; KHONG chay lai schema.sql.
-- Dieu kien: cac product_id 1, 2, 3, 4, 5, 7 van la san pham goc trong seed.sql.
-- variant_id duoc AUTO_INCREMENT tu sinh; SKU da ton tai se duoc bo qua.
-- Khong cap nhat gia, ton kho hay bat ky du lieu cu nao.
-- Gia va ton kho ben duoi la du lieu mau, giong 15 dong moi trong seed.sql.
-- Chi chay mot phien script tai mot thoi diem. Nen sao luu database truoc khi chay.

USE AppleStore;
SET NAMES utf8mb4;

START TRANSACTION;

INSERT INTO product_variants (
    product_id, sku, variant_label, color_name, case_size_mm,
    storage_capacity_gb, ram_gb, connectivity, price, stock_quantity, weight_kg
)
SELECT
    new_variant.product_id, new_variant.sku, new_variant.variant_label,
    new_variant.color_name, new_variant.case_size_mm,
    new_variant.storage_capacity_gb, new_variant.ram_gb,
    new_variant.connectivity, new_variant.price,
    new_variant.stock_quantity, new_variant.weight_kg
FROM (
    SELECT 1 AS product_id, 'IP15PM-512-BLTT' AS sku,
        '512GB - Titan Xanh' AS variant_label, 'Titan Xanh' AS color_name,
        NULL AS case_size_mm, 512 AS storage_capacity_gb, NULL AS ram_gb,
        NULL AS connectivity, 40990000 AS price, 10 AS stock_quantity, 0.221 AS weight_kg
    UNION ALL SELECT 2, 'IP15-128-BLACK', '128GB - Đen', 'Đen', NULL, 128, NULL, NULL, 22990000, 28, 0.171
    UNION ALL SELECT 2, 'IP15-256-PINK', '256GB - Hồng', 'Hồng', NULL, 256, NULL, NULL, 25990000, 20, 0.171
    UNION ALL SELECT 3, 'MBA13-M3-256-MN', '8GB/256GB - Đêm', 'Đêm', NULL, 256, 8, NULL, 27990000, 13, 1.240
    UNION ALL SELECT 3, 'MBA13-M3-512-SL', '16GB/512GB - Bạc', 'Bạc', NULL, 512, 16, NULL, 33990000, 7, 1.240
    UNION ALL SELECT 4, 'MBP14-M3P-512-SL', '18GB/512GB - Bạc', 'Bạc', NULL, 512, 18, NULL, 52990000, 5, 1.550
    UNION ALL SELECT 4, 'MBP14-M3P-1TB-SG', '18GB/1TB - Xám Không Gian', 'Xám Không Gian', NULL, 1024, 18, NULL, 59990000, 3, 1.550
    UNION ALL SELECT 5, 'IPADAIR11-128-WIFI-SL', '128GB - Wi-Fi - Bạc', 'Bạc', NULL, 128, 8, 'WIFI', 16990000, 18, 0.462
    UNION ALL SELECT 5, 'IPADAIR11-128-CELL-BL', '128GB - Wi-Fi + Cellular - Xanh Dương', 'Xanh Dương', NULL, 128, 8, 'WIFI_CELLULAR', 19990000, 12, 0.470
    UNION ALL SELECT 5, 'IPADAIR11-128-CELL-SL', '128GB - Wi-Fi + Cellular - Bạc', 'Bạc', NULL, 128, 8, 'WIFI_CELLULAR', 19990000, 11, 0.470
    UNION ALL SELECT 5, 'IPADAIR11-256-WIFI-BL', '256GB - Wi-Fi - Xanh Dương', 'Xanh Dương', NULL, 256, 8, 'WIFI', 18990000, 14, 0.462
    UNION ALL SELECT 5, 'IPADAIR11-256-WIFI-SL', '256GB - Wi-Fi - Bạc', 'Bạc', NULL, 256, 8, 'WIFI', 18990000, 13, 0.462
    UNION ALL SELECT 5, 'IPADAIR11-256-CELL-BL', '256GB - Wi-Fi + Cellular - Xanh Dương', 'Xanh Dương', NULL, 256, 8, 'WIFI_CELLULAR', 21990000, 9, 0.470
    UNION ALL SELECT 7, 'AWS9-41-STAR', '41mm - Viền Nhôm Ánh Sao', 'Ánh Sao', 41, NULL, NULL, NULL, 10990000, 22, 0.038
    UNION ALL SELECT 7, 'AWS9-45-MID', '45mm - Viền Nhôm Giữa Đêm', 'Giữa Đêm', 45, NULL, NULL, NULL, 11990000, 18, 0.039
) AS new_variant
WHERE NOT EXISTS (
    SELECT 1
    FROM product_variants AS existing_variant
    WHERE existing_variant.sku = new_variant.sku
);

-- Ket qua: 15 neu chua co SKU nao; 0 neu da co du; 1-14 neu da co mot phan.
SELECT ROW_COUNT() AS inserted_variants;

COMMIT;
