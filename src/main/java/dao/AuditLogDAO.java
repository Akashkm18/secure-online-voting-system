package dao;

import model.AuditLog;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class AuditLogDAO {

    private static final Logger LOGGER = Logger.getLogger(AuditLogDAO.class.getName());

    public void log(Integer userId, String action, String ipAddress, String userAgent) {
        String sql = "INSERT INTO audit_logs (user_id, action, ip_address, user_agent, created_at) " +
                     "VALUES (?, ?, ?, ?, NOW())";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            if (userId != null && userId > 0) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, action != null ? action : "UNKNOWN_ACTION");
            ps.setString(3, ipAddress != null ? ipAddress : "127.0.0.1");
            ps.setString(4, userAgent != null ? (userAgent.length() > 250 ? userAgent.substring(0, 250) : userAgent) : "Unknown");

            ps.executeUpdate();
        } catch (SQLException e) {
            // Never crash the primary request if logging encounters a minor db failure
            LOGGER.log(Level.WARNING, "Failed to record audit log: " + action, e);
        }
    }

    public List<AuditLog> getRecentLogs(int limit) {
        return getFilteredLogs(null, null, null, null, 0, Math.max(limit, 10));
    }

    public List<AuditLog> getFilteredLogs(String action, String userSearch, String startDate, String endDate, int offset, int limit) {
        List<AuditLog> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT a.id, a.user_id, a.action, a.ip_address, a.user_agent, a.created_at, u.email, u.role " +
                "FROM audit_logs a " +
                "LEFT JOIN users u ON a.user_id = u.id " +
                "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (action != null && !action.trim().isEmpty() && !"ALL".equalsIgnoreCase(action.trim())) {
            sql.append("AND LOWER(a.action) LIKE ? ");
            params.add("%" + action.trim().toLowerCase() + "%");
        }

        if (userSearch != null && !userSearch.trim().isEmpty()) {
            sql.append("AND (LOWER(u.email) LIKE ? OR LOWER(u.full_name) LIKE ?) ");
            String us = "%" + userSearch.trim().toLowerCase() + "%";
            params.add(us);
            params.add(us);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            try {
                sql.append("AND a.created_at >= ? ");
                params.add(Timestamp.valueOf(startDate.trim() + " 00:00:00"));
            } catch (Exception ignored) {}
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            try {
                sql.append("AND a.created_at <= ? ");
                params.add(Timestamp.valueOf(endDate.trim() + " 23:59:59"));
            } catch (Exception ignored) {}
        }

        sql.append("ORDER BY a.id DESC LIMIT ? OFFSET ?");
        params.add(limit > 0 ? limit : 20);
        params.add(offset >= 0 ? offset : 0);

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setId(rs.getInt("id"));
                    int uid = rs.getInt("user_id");
                    log.setUserId(rs.wasNull() ? null : uid);
                    log.setUserEmail(rs.getString("email"));
                    log.setUserRole(rs.getString("role"));
                    log.setAction(rs.getString("action"));
                    log.setIpAddress(rs.getString("ip_address"));
                    log.setUserAgent(rs.getString("user_agent"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching filtered audit logs", e);
        }
        return list;
    }

    public int countFilteredLogs(String action, String userSearch, String startDate, String endDate) {
        StringBuilder sql = new StringBuilder(
                "SELECT COUNT(*) FROM audit_logs a " +
                "LEFT JOIN users u ON a.user_id = u.id " +
                "WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (action != null && !action.trim().isEmpty() && !"ALL".equalsIgnoreCase(action.trim())) {
            sql.append("AND LOWER(a.action) LIKE ? ");
            params.add("%" + action.trim().toLowerCase() + "%");
        }

        if (userSearch != null && !userSearch.trim().isEmpty()) {
            sql.append("AND (LOWER(u.email) LIKE ? OR LOWER(u.full_name) LIKE ?) ");
            String us = "%" + userSearch.trim().toLowerCase() + "%";
            params.add(us);
            params.add(us);
        }

        if (startDate != null && !startDate.trim().isEmpty()) {
            try {
                sql.append("AND a.created_at >= ? ");
                params.add(Timestamp.valueOf(startDate.trim() + " 00:00:00"));
            } catch (Exception ignored) {}
        }

        if (endDate != null && !endDate.trim().isEmpty()) {
            try {
                sql.append("AND a.created_at <= ? ");
                params.add(Timestamp.valueOf(endDate.trim() + " 23:59:59"));
            } catch (Exception ignored) {}
        }

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting filtered audit logs", e);
        }
        return 0;
    }

    public int countTotal() {
        String sql = "SELECT COUNT(*) FROM audit_logs";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting audit logs", e);
        }
        return 0;
    }
}
