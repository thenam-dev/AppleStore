# Role Mapping

Tai lieu nay ghi lai mapping nen khi tham khao nghiep vu tu `Ban_Hoa_Qua_Online`
sang he thong `AppleStore`.

## Mapping Nen

```text
Ban_Hoa_Qua_Online SHOP_OWNER -> AppleStore ADMIN
Ban_Hoa_Qua_Online CUSTOMER   -> AppleStore CUSTOMER
Ban_Hoa_Qua_Online DELIVERY   -> AppleStore DELIVERY
Ban_Hoa_Qua_Online ADMIN      -> chi lay phan quan tri he thong can thiet
AppleStore SALE_STAFF         -> tach tu nghiep vu order/admin ban hang
```

## Ghi Chu Ap Dung

- `ADMIN`: quan tri san pham, nguoi dung, voucher, dashboard va cac man hinh quan tri can thiet.
- `CUSTOMER`: tai khoan mua hang, gio hang, don hang, dia chi, wishlist va profile.
- `DELIVERY`: nhan va cap nhat trang thai giao hang neu module delivery duoc them vao AppleStore.
- `SALE_STAFF`: xu ly nghiep vu ban hang/order/back-office, tach rieng khoi quyen admin tong.

Khi dua mapping nay vao code, chi nen dung role cuoi cung cua `AppleStore` trong
database va Java code: `ADMIN`, `CUSTOMER`, `DELIVERY`, `SALE_STAFF`.
