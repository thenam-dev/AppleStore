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

    // Google OAuth2 Constants
    public static final String GOOGLE_CLIENT_ID = "684587825406-uc8fb2uv7rmn8nih7is39ss2dhqgj2os.apps.googleusercontent.com";
    public static final String GOOGLE_CLIENT_SECRET = "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";
    public static final String GOOGLE_LINK_GET_TOKEN = "https://oauth2.googleapis.com/token";
    public static final String GOOGLE_LINK_GET_USER_INFO = "https://www.googleapis.com/oauth2/v1/userinfo?access_token=";
    public static final String GOOGLE_GRANT_TYPE = "authorization_code";

    private AppConfig() {
    }
}
