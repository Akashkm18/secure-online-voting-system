package util;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.logging.Level;
import java.util.logging.Logger;

/**
 * Automatically applies non-destructive database schema updates (migrations)
 * ensuring all required columns exist in MySQL, MariaDB, PostgreSQL, and H2.
 */
public class DatabaseMigration {

    private static final Logger LOGGER = Logger.getLogger(DatabaseMigration.class.getName());
    private static volatile boolean migrated = false;

    public static synchronized void runMigrations(Connection con) {
        if (migrated || con == null) {
            return;
        }

        try {
            String dbType = con.getMetaData().getDatabaseProductName().toLowerCase();
            boolean isPostgres = dbType.contains("postgres");

            // 1. Columns for candidates table
            addColumnIfNotExists(con, "candidates", "position", "VARCHAR(100) DEFAULT 'Candidate'");
            addColumnIfNotExists(con, "candidates", "bio", "VARCHAR(500)");
            addColumnIfNotExists(con, "candidates", "manifesto", "VARCHAR(1000)");
            addColumnIfNotExists(con, "candidates", "photo_data", isPostgres ? "BYTEA" : "LONGBLOB");
            addColumnIfNotExists(con, "candidates", "photo_type", "VARCHAR(20)");
            addColumnIfNotExists(con, "candidates", "photo_updated_at", "TIMESTAMP NULL");

            // 2. Columns for users table
            addColumnIfNotExists(con, "users", "status", "VARCHAR(20) DEFAULT 'APPROVED'");
            addColumnIfNotExists(con, "users", "rejection_reason", "VARCHAR(255)");
            addColumnIfNotExists(con, "users", "force_password_reset", "BOOLEAN DEFAULT FALSE");

            // 3. Columns for audit_logs table
            addColumnIfNotExists(con, "audit_logs", "user_role", "VARCHAR(20)");

            migrated = true;
            LOGGER.info("Database schema migration verified successfully for " + dbType);
        } catch (Exception e) {
            LOGGER.log(Level.WARNING, "Database migration check encountered an error: " + e.getMessage(), e);
        }
    }

    private static void addColumnIfNotExists(Connection con, String tableName, String columnName, String columnDef) {
        try {
            if (!columnExists(con, tableName, columnName)) {
                String sql = "ALTER TABLE " + tableName + " ADD COLUMN " + columnName + " " + columnDef;
                try (Statement stmt = con.createStatement()) {
                    stmt.execute(sql);
                    LOGGER.info("Migrated table " + tableName + ": added column " + columnName);
                }
            }
        } catch (SQLException e) {
            // Ignore if column already exists or table does not exist yet
            LOGGER.log(Level.FINE, "Column check/add for " + tableName + "." + columnName + ": " + e.getMessage());
        }
    }

    private static boolean columnExists(Connection con, String tableName, String columnName) throws SQLException {
        // Try uppercase
        try (ResultSet rs = con.getMetaData().getColumns(null, null, tableName.toUpperCase(), columnName.toUpperCase())) {
            if (rs.next()) return true;
        }
        // Try lowercase
        try (ResultSet rs = con.getMetaData().getColumns(null, null, tableName.toLowerCase(), columnName.toLowerCase())) {
            if (rs.next()) return true;
        }
        // Try exact
        try (ResultSet rs = con.getMetaData().getColumns(null, null, tableName, columnName)) {
            if (rs.next()) return true;
        }
        return false;
    }

    public static void reset() {
        migrated = false;
    }
}
