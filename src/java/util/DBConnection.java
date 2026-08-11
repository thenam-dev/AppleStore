package util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public final class DBConnection {
    private static final String DEFAULT_URL =
            "jdbc:mysql://localhost:3306/AppleStore"
            + "?useSSL=false"
            + "&allowPublicKeyRetrieval=true"
            + "&serverTimezone=Asia/Ho_Chi_Minh"
            + "&characterEncoding=UTF-8";
    private static final String DEFAULT_USERNAME = "root";
    private static final String DEFAULT_PASSWORD = "";

    private DBConnection() {
    }

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException ex) {
            throw new ExceptionInInitializerError(
                    "MySQL Connector/J is missing. Add mysql-connector-j to WEB-INF/lib or Tomcat lib.");
        }
    }

    public static Connection getConnection() throws SQLException {
        String url = getConfig("DB_URL", "db.url", DEFAULT_URL);
        String username = getConfig("DB_USERNAME", "db.username", DEFAULT_USERNAME);
        String password = getConfig("DB_PASSWORD", "db.password", DEFAULT_PASSWORD);
        return DriverManager.getConnection(url, username, password);
    }

    private static String getConfig(String envName, String propertyName, String defaultValue) {
        String propertyValue = System.getProperty(propertyName);
        if (propertyValue != null && !propertyValue.isBlank()) {
            return propertyValue;
        }

        String envValue = System.getenv(envName);
        if (envValue != null && !envValue.isBlank()) {
            return envValue;
        }

        return defaultValue;
    }
}
