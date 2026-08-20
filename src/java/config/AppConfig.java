/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package config;

/**
 *
 * @author T14s G2
 */
public class AppConfig {

    public static final String ROLE_CUSTOMER = "CUSTOMER";
    public static final String ROLE_ADMIN = "ADMIN";
    public static final String ROLE_SALE_STAFF = "SALE_STAFF";
    public static final String ROLE_DELIVERY = "DELIVERY";

    public static final String SESSION_USER = "user";

    public static final int PAGE_SIZE_ADMIN = 20;
    public static final int PAGE_SIZE_PRODUCTS = 12;

    // Product image uploads are kept outside the source tree so runtime files
    // do not get mixed with static assets committed to the repository.
    public static final String UPLOAD_DIR = "uploads";
    public static final String PRODUCT_UPLOAD_DIR = "products";
    public static final String PERSISTENT_UPLOAD_DIR =
            System.getProperty("user.home") + java.io.File.separator + "applestore_uploads";
    public static final long MAX_UPLOAD_SIZE_BYTES = 5L * 1024 * 1024;
    public static final String[] ALLOWED_IMAGE_EXTS = {"jpg", "jpeg", "png", "webp"};

    // ==== SePay (thanh toán chuyển khoản QR) ====
    public static final String SEPAY_ACCOUNT_NUMBER = "9999928012004";
    public static final String SEPAY_BANK_CODE = "MBBank";
    // API Key khai báo khi đăng ký Webhook trên dashboard SePay (Cấu hình >
    // Webhooks > Authorization: "Apikey <giá trị này>").
    public static final String SEPAY_WEBHOOK_API_KEY = "spsk_live_mX1i64k7v5SbxfYVFHSbZi65SvJu1THH";

    // Google OAuth2 Constants
    public static final String GOOGLE_CLIENT_ID = "684587825406-uc8fb2uv7rmn8nih7is39ss2dhqgj2os.apps.googleusercontent.com";
    public static final String GOOGLE_CLIENT_SECRET = "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";
    public static final String GOOGLE_LINK_GET_TOKEN = "https://oauth2.googleapis.com/token";
    public static final String GOOGLE_LINK_GET_USER_INFO = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=";
    public static final String GOOGLE_GRANT_TYPE = "authorization_code";

    private AppConfig() {
    }
}
