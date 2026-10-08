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
        List<AuditLog> list = new ArrayList<>();
        String sql = "SELECT a.id, a.user_id, a.action, a.ip_address, a.user_agent, a.created_at, u.email " +
                     "FROM audit_logs a " +
                     "LEFT JOIN users u ON a.user_id = u.id " +
                     "ORDER BY a.id DESC LIMIT ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, Math.max(limit, 10));
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    AuditLog log = new AuditLog();
                    log.setId(rs.getInt("id"));
                    int uid = rs.getInt("user_id");
                    log.setUserId(rs.wasNull() ? null : uid);
                    log.setUserEmail(rs.getString("email"));
                    log.setAction(rs.getString("action"));
                    log.setIpAddress(rs.getString("ip_address"));
                    log.setUserAgent(rs.getString("user_agent"));
                    log.setCreatedAt(rs.getTimestamp("created_at"));
                    list.add(log);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching audit logs", e);
        }
        return list;
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
