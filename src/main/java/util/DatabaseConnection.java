package util;

import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Manages database connectivity using JDBC.
 * Reads configuration from Environment Variables (DB_URL, DB_USERNAME, DB_PASSWORD)
 * with graceful fallback to system properties and configuration file.
 */
public class DatabaseConnection {

    private static final Logger LOGGER = Logger.getLogger(DatabaseConnection.class.getName());

    private static final String DEFAULT_URL = "jdbc:mysql://localhost:3306/online_voting?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "";

    private static String dbUrl;
    private static String dbUsername;
    private static String dbPassword;

    static {
        loadConfiguration();
    }

    private static void loadConfiguration() {
        // 1. Try Environment Variables
        String envUrl = System.getenv("DB_URL");
        String envUser = System.getenv("DB_USERNAME");
        String envPass = System.getenv("DB_PASSWORD");

        // 2. Try System Properties if environment variables are not set
        if (envUrl == null || envUrl.trim().isEmpty()) {
            envUrl = System.getProperty("DB_URL");
        }
        if (envUser == null || envUser.trim().isEmpty()) {
            envUser = System.getProperty("DB_USERNAME");
        }
        if (envPass == null) {
            envPass = System.getProperty("DB_PASSWORD");
        }

        // 3. Try reading from db.properties if exists on classpath
        if (envUrl == null || envUser == null) {
            try (InputStream in = DatabaseConnection.class.getClassLoader().getResourceAsStream("db.properties")) {
                if (in != null) {
                    Properties props = new Properties();
                    props.load(in);
                    if (envUrl == null) envUrl = props.getProperty("db.url");
                    if (envUser == null) envUser = props.getProperty("db.username");
                    if (envPass == null) envPass = props.getProperty("db.password");
                }
            } catch (Exception e) {
                LOGGER.log(Level.FINE, "No db.properties file found on classpath", e);
            }
        }

        dbUrl = (envUrl != null && !envUrl.trim().isEmpty()) ? envUrl.trim() : DEFAULT_URL;
        dbUsername = (envUser != null && !envUser.trim().isEmpty()) ? envUser.trim() : DEFAULT_USER;
        dbPassword = (envPass != null) ? envPass : DEFAULT_PASSWORD;

        // Load JDBC Driver
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found in classpath!", e);
        }
    }

    /**
     * Obtains a new database connection.
     * Callers must close connection using try-with-resources.
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(dbUrl, dbUsername, dbPassword);
    }

    /**
     * Allows test harnesses to override database configuration (e.g. for in-memory H2).
     */
    public static void setCustomConfig(String url, String username, String password) {
        dbUrl = url;
        dbUsername = username;
        dbPassword = password;
    }

    public static String getDbUrl() {
        return dbUrl;
    }

    public static String getDbUsername() {
        return dbUsername;
    }
}
