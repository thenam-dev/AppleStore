<%--
  icons.jsp — bộ icon SVG dùng chung, nhúng 1 lần ngay sau thẻ <body>.
  Dùng lại ở mọi nơi bằng:  <svg width="16" height="16"><use href="#i-cart"/></svg>
  Muốn thêm icon mới thì thêm <symbol> vào đây, đừng dán SVG rời trong từng trang.
  File dùng chung — sửa phải báo team (rule 11).
--%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<svg style="display:none" aria-hidden="true">
  <symbol id="i-search" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="11" cy="11" r="7"/><path d="m20 20-3.5-3.5"/></symbol>
  <symbol id="i-cart" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M3 4h2.2l2 11.2a2 2 0 0 0 2 1.6h7.8a2 2 0 0 0 2-1.6L20.5 8H6"/><circle cx="10" cy="20" r="1.4"/><circle cx="17" cy="20" r="1.4"/></symbol>
  <symbol id="i-heart" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M12 20s-7-4.4-7-9.2A3.8 3.8 0 0 1 12 8a3.8 3.8 0 0 1 7 2.8C19 15.6 12 20 12 20Z"/></symbol>
  <symbol id="i-home" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M3 11.5 12 4l9 7.5"/><path d="M5.5 10.5V20h13v-9.5"/><path d="M9.5 20v-6h5v6"/></symbol>
  <symbol id="i-user" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><circle cx="12" cy="8.5" r="3.6"/><path d="M4.5 20a7.5 7.5 0 0 1 15 0"/></symbol>
  <symbol id="i-edit" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M4 20h4L19 9a2.1 2.1 0 0 0-3-3L5 17v3Z"/></symbol>
  <symbol id="i-eye" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M2 12s4-6.5 10-6.5S22 12 22 12s-4 6.5-10 6.5S2 12 2 12Z"/><circle cx="12" cy="12" r="2.6"/></symbol>
  <symbol id="i-plus" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M12 5v14M5 12h14"/></symbol>
  <symbol id="i-check" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m5 12.5 4.5 4.5L19 7"/></symbol>
  <symbol id="i-alert" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8"><circle cx="12" cy="12" r="9"/><path d="M12 7.5v5.5M12 16.3v.2"/></symbol>
  <symbol id="i-lock" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><rect x="5" y="10" width="14" height="10" rx="2.5"/><path d="M8.5 10V7.5a3.5 3.5 0 0 1 7 0V10"/></symbol>
  <symbol id="i-trash" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M4 7h16M9 7V5h6v2M6.5 7l1 13h9l1-13"/></symbol>
  <symbol id="i-logout" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M9 20H5a1 1 0 0 1-1-1V5a1 1 0 0 1 1-1h4M16 16l4-4-4-4M20 12H9"/></symbol>
  <symbol id="i-box" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M12 3 4 7v10l8 4 8-4V7l-8-4Z"/><path d="m4 7 8 4 8-4M12 11v10"/></symbol>
  <symbol id="i-grid" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><rect x="4" y="4" width="7" height="7" rx="1.5"/><rect x="13" y="4" width="7" height="7" rx="1.5"/><rect x="4" y="13" width="7" height="7" rx="1.5"/><rect x="13" y="13" width="7" height="7" rx="1.5"/></symbol>
  <symbol id="i-tag" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M3 12.5V4h8.5L21 13.5 12.5 22 3 12.5Z"/><circle cx="7.5" cy="8" r="1.4"/></symbol>
  <symbol id="i-chart" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M4 20V10M10 20V4M16 20v-7M22 20H2"/></symbol>
  <symbol id="i-truck" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6"><path d="M2 6h11v10H2zM13 9h4l4 3.5V16h-8"/><circle cx="6" cy="18" r="1.6"/><circle cx="17" cy="18" r="1.6"/></symbol>
  <symbol id="i-chevron-down" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m6 9 6 6 6-6"/></symbol>
  <symbol id="i-chevron-left" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m15 6-6 6 6 6"/></symbol>
  <symbol id="i-chevron-right" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="m9 6 6 6-6 6"/></symbol>
  <symbol id="i-swap" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M4 8h13M13 4l4 4-4 4"/><path d="M20 16H7M11 12l-4 4 4 4"/></symbol>
  <symbol id="i-percent" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M19 5 5 19"/><circle cx="7.5" cy="7.5" r="2.5"/><circle cx="16.5" cy="16.5" r="2.5"/></symbol>
  <symbol id="i-phone" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7"><path d="M6.6 3h3l1.4 4-2 1.6a13 13 0 0 0 6.4 6.4l1.6-2 4 1.4v3a2 2 0 0 1-2.2 2A17 17 0 0 1 4.6 5.2 2 2 0 0 1 6.6 3Z"/></symbol>
  <%-- logo dùng trong header/footer/admin-sidebar (nền tối) - tô màu bằng CSS color trên thẻ <svg> bọc
       ngoài. "logo-mark" và "logo-halo" là cùng một hình, giữ cả 2 id vì 2 nhóm trang khách/quản trị
       đang trỏ tới tên khác nhau; khác với web/assets/images/logo-mark.svg (file tĩnh dùng làm favicon,
       tự có màu nền riêng, không liên quan symbol này). --%>
  <symbol id="logo-mark" viewBox="0 0 100 100"><circle cx="50" cy="54" r="31" fill="none" stroke="currentColor" stroke-width="9" stroke-linecap="round" stroke-dasharray="150 45" transform="rotate(-63 50 54)"/><path d="M64 10c11 3 15 12 12 22-11-1-15-11-12-22Z" fill="currentColor"/></symbol>
  <symbol id="logo-halo" viewBox="0 0 100 100"><circle cx="50" cy="54" r="31" fill="none" stroke="currentColor" stroke-width="9" stroke-linecap="round" stroke-dasharray="150 45" transform="rotate(-63 50 54)"/><path d="M64 10c11 3 15 12 12 22-11-1-15-11-12-22Z" fill="currentColor"/></symbol>
  <%-- hình sản phẩm tạm thời khi chưa có ảnh trong CSDL, chọn theo categoryId --%>
  <symbol id="d-phone" viewBox="0 0 120 200"><rect x="18" y="6" width="84" height="188" rx="19" fill="none" stroke="currentColor" stroke-width="3"/><rect x="27" y="15" width="66" height="170" rx="12" fill="currentColor" opacity=".07"/><rect x="46" y="12" width="28" height="7" rx="3.5" fill="currentColor" opacity=".5"/></symbol>
  <symbol id="d-mac" viewBox="0 0 220 150"><rect x="26" y="14" width="168" height="104" rx="8" fill="none" stroke="currentColor" stroke-width="3"/><rect x="34" y="22" width="152" height="88" rx="4" fill="currentColor" opacity=".07"/><path d="M8 128h204l-10 10H18z" fill="none" stroke="currentColor" stroke-width="3" stroke-linejoin="round"/><path d="M96 128h28" stroke="currentColor" stroke-width="3"/></symbol>
  <symbol id="d-watch" viewBox="0 0 120 190"><rect x="30" y="8" width="60" height="34" rx="12" fill="currentColor" opacity=".25"/><rect x="30" y="148" width="60" height="34" rx="12" fill="currentColor" opacity=".25"/><rect x="22" y="42" width="76" height="106" rx="24" fill="none" stroke="currentColor" stroke-width="3"/><rect x="31" y="51" width="58" height="88" rx="18" fill="currentColor" opacity=".08"/></symbol>
  <symbol id="d-pods" viewBox="0 0 160 130"><rect x="20" y="30" width="120" height="82" rx="26" fill="none" stroke="currentColor" stroke-width="3"/><path d="M20 66h120" stroke="currentColor" stroke-width="2" opacity=".4"/><circle cx="62" cy="10" r="7" fill="currentColor" opacity=".35"/><circle cx="98" cy="10" r="7" fill="currentColor" opacity=".35"/></symbol>
  <symbol id="d-pad" viewBox="0 0 160 200"><rect x="14" y="8" width="132" height="184" rx="14" fill="none" stroke="currentColor" stroke-width="3"/><rect x="24" y="18" width="112" height="164" rx="6" fill="currentColor" opacity=".07"/><circle cx="36" cy="32" r="7" fill="none" stroke="currentColor" stroke-width="2.2" opacity=".5"/></symbol>
  <symbol id="d-acc" viewBox="0 0 160 160"><circle cx="80" cy="80" r="52" fill="none" stroke="currentColor" stroke-width="3"/><circle cx="80" cy="80" r="26" fill="currentColor" opacity=".1"/><path d="M80 28v-14M80 146v-14M28 80H14M146 80h-14" stroke="currentColor" stroke-width="3" stroke-linecap="round"/></symbol>
</svg>
