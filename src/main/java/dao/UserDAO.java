package dao;

import model.User;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class UserDAO {

    private static final Logger LOGGER = Logger.getLogger(UserDAO.class.getName());

    public User findByEmail(String email) {
        String sql = "SELECT id, full_name, email, college_id, college_name, program_name, joining_year, study_year, photo_base64, password_hash, role, is_verified, is_active, created_at " +
                     "FROM users WHERE email = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, email.trim().toLowerCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByEmail for email: " + email, e);
        }
        return null;
    }

    public User findByCollegeId(String collegeId) {
        if (collegeId == null || collegeId.trim().isEmpty()) return null;
        String sql = "SELECT id, full_name, email, college_id, college_name, program_name, joining_year, study_year, photo_base64, password_hash, role, is_verified, is_active, created_at " +
                     "FROM users WHERE UPPER(college_id) = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, collegeId.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findByCollegeId: " + collegeId, e);
        }
        return null;
    }

    public User findById(int id) {
        String sql = "SELECT id, full_name, email, college_id, college_name, program_name, joining_year, study_year, photo_base64, password_hash, role, is_verified, is_active, created_at " +
                     "FROM users WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToUser(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findById: " + id, e);
        }
        return null;
    }

    public boolean createUser(User user) {
        String sql = "INSERT INTO users (full_name, email, college_id, college_name, program_name, joining_year, study_year, photo_base64, password_hash, role, is_verified, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, user.getFullName().trim());
            ps.setString(2, user.getEmail().trim().toLowerCase());
            ps.setString(3, user.getCollegeId() != null ? user.getCollegeId().trim().toUpperCase() : null);
            ps.setString(4, user.getCollegeName() != null ? user.getCollegeName().trim() : "Alliance University");
            ps.setString(5, user.getProgramName() != null ? user.getProgramName().trim() : "B.Tech Computer Science & Engineering");
            if (user.getJoiningYear() != null) {
                ps.setInt(6, user.getJoiningYear());
            } else {
                ps.setNull(6, java.sql.Types.INTEGER);
            }
            ps.setString(7, user.getStudyYear() != null ? user.getStudyYear().trim() : "2nd Year");
            ps.setString(8, user.getPhotoBase64());
            ps.setString(9, user.getPasswordHash());
            ps.setString(10, user.getRole() != null ? user.getRole().toUpperCase() : "VOTER");
            ps.setBoolean(11, user.isVerified());
            ps.setBoolean(12, user.isActive());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        user.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating user: " + user.getEmail(), e);
        }
        return false;
    }

    public boolean updateStudentDetails(int userId, String collegeName, String programName, Integer joiningYear, String studyYear, String photoBase64) {
        StringBuilder sql = new StringBuilder("UPDATE users SET ");
        List<Object> params = new ArrayList<>();

        if (collegeName != null && !collegeName.trim().isEmpty()) {
            sql.append("college_name = ?, ");
            params.add(collegeName.trim());
        }
        if (programName != null && !programName.trim().isEmpty()) {
            sql.append("program_name = ?, ");
            params.add(programName.trim());
        }
        if (joiningYear != null) {
            sql.append("joining_year = ?, ");
            params.add(joiningYear);
        }
        if (studyYear != null && !studyYear.trim().isEmpty()) {
            sql.append("study_year = ?, ");
            params.add(studyYear.trim());
        }
        if (photoBase64 != null && !photoBase64.trim().isEmpty()) {
            sql.append("photo_base64 = ?, ");
            params.add(photoBase64.trim());
        }

        // Strip trailing comma if fields were updated
        if (params.isEmpty()) {
            return false;
        }

        sql.setLength(sql.length() - 2);
        sql.append(" WHERE id = ?");
        params.add(userId);

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating student details for user: " + userId, e);
        }
        return false;
    }

    public boolean updateUserProfile(User user) {
        String sql = "UPDATE users SET full_name = ?, college_id = ?, college_name = ?, program_name = ?, " +
                     "joining_year = ?, study_year = ?, photo_base64 = ?, password_hash = ?, role = ?, " +
                     "is_verified = ?, is_active = ? WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {
            ps.setString(1, user.getFullName().trim());
            ps.setString(2, user.getCollegeId() != null ? user.getCollegeId().trim().toUpperCase() : null);
            ps.setString(3, user.getCollegeName() != null ? user.getCollegeName().trim() : "Alliance University");
            ps.setString(4, user.getProgramName() != null ? user.getProgramName().trim() : "B.Tech Computer Science & Engineering");
            if (user.getJoiningYear() != null) {
                ps.setInt(5, user.getJoiningYear());
            } else {
                ps.setNull(5, java.sql.Types.INTEGER);
            }
            ps.setString(6, user.getStudyYear() != null ? user.getStudyYear().trim() : "2nd Year");
            ps.setString(7, user.getPhotoBase64());
            ps.setString(8, user.getPasswordHash());
            ps.setString(9, user.getRole() != null ? user.getRole().toUpperCase() : "VOTER");
            ps.setBoolean(10, user.isVerified());
            ps.setBoolean(11, user.isActive());
            ps.setInt(12, user.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating user profile: " + user.getEmail(), e);
        }
        return false;
    }

    public List<User> getAllVoters() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, full_name, email, college_id, college_name, program_name, joining_year, study_year, photo_base64, password_hash, role, is_verified, is_active, created_at " +
                     "FROM users ORDER BY id DESC";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToUser(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching voters", e);
        }
        return list;
    }

    public int countTotalVoters() {
        String sql = "SELECT COUNT(*) FROM users";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting voters", e);
        }
        return 0;
    }

    public boolean updateActiveStatus(int userId, boolean isActive) {
        String sql = "UPDATE users SET is_active = ? WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setBoolean(1, isActive);
            ps.setInt(2, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating user active status: " + userId, e);
        }
        return false;
    }

    public boolean updatePassword(String email, String collegeId, String newPasswordHash) {
        String sql = "UPDATE users SET password_hash = ? WHERE email = ? AND UPPER(college_id) = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newPasswordHash);
            ps.setString(2, email.trim().toLowerCase());
            ps.setString(3, collegeId.trim().toUpperCase());
            
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating password for email: " + email, e);
        }
        return false;
    }

    public List<User> getVotersFiltered(String search, String status, int offset, int limit) {
        List<User> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT u.id, u.full_name, u.email, u.college_id, u.college_name, u.program_name, " +
                "u.joining_year, u.study_year, u.photo_base64, u.password_hash, u.role, " +
                "u.is_verified, u.is_active, u.status, u.rejection_reason, u.force_password_reset, u.created_at, " +
                "(SELECT COUNT(*) FROM votes v WHERE v.voter_id = u.id) > 0 AS has_voted " +
                "FROM users u WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(u.college_id) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql.append("AND UPPER(u.status) = ? ");
            params.add(status.trim().toUpperCase());
        }

        sql.append("ORDER BY u.id DESC LIMIT ? OFFSET ?");
        params.add(limit > 0 ? limit : 20);
        params.add(offset >= 0 ? offset : 0);

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToUser(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching filtered voters", e);
        }
        return list;
    }

    public int countVotersFiltered(String search, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM users u WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(u.full_name) LIKE ? OR LOWER(u.email) LIKE ? OR LOWER(u.college_id) LIKE ?) ");
            String term = "%" + search.trim().toLowerCase() + "%";
            params.add(term);
            params.add(term);
            params.add(term);
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql.append("AND UPPER(u.status) = ? ");
            params.add(status.trim().toUpperCase());
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
            LOGGER.log(Level.SEVERE, "Error counting filtered voters", e);
        }
        return 0;
    }

    public int countVotersByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM users WHERE UPPER(status) = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status.trim().toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting voters by status: " + status, e);
        }
        return 0;
    }

    public boolean updateUserStatus(int userId, String status, String rejectionReason) {
        String st = (status != null) ? status.trim().toUpperCase() : "APPROVED";
        boolean isActive = !"DISABLED".equals(st) && !"REJECTED".equals(st);
        boolean isVerified = "APPROVED".equals(st);

        String sql = "UPDATE users SET status = ?, rejection_reason = ?, is_active = ?, is_verified = ? WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, st);
            ps.setString(2, rejectionReason != null ? rejectionReason.trim() : null);
            ps.setBoolean(3, isActive);
            ps.setBoolean(4, isVerified);
            ps.setInt(5, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating status for voter: " + userId, e);
        }
        return false;
    }

    public boolean resetPasswordWithFlag(int userId, String newPasswordHash) {
        String sql = "UPDATE users SET password_hash = ?, force_password_reset = TRUE WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, newPasswordHash);
            ps.setInt(2, userId);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error resetting password for voter: " + userId, e);
        }
        return false;
    }

    public boolean hasUserVotedAnyElection(int userId) {
        String sql = "SELECT 1 FROM votes WHERE voter_id = ? LIMIT 1";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking user voting history: " + userId, e);
        }
        return false;
    }

    public boolean deleteVoter(int userId) {
        if (hasUserVotedAnyElection(userId)) {
            LOGGER.warning("Refusing to delete voter " + userId + " because votes have already been recorded.");
            return false;
        }

        String sql = "DELETE FROM users WHERE id = ? AND role != 'ADMIN'";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, userId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting voter: " + userId, e);
        }
        return false;
    }

    public List<java.util.Map<String, Object>> getVoterElectionParticipation(int voterId) {
        List<java.util.Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT e.id AS election_id, e.election_name, e.status, e.start_time, e.end_time, " +
                     "(v.id IS NOT NULL) AS has_voted, v.voted_at " +
                     "FROM elections e " +
                     "LEFT JOIN votes v ON e.id = v.election_id AND v.voter_id = ? " +
                     "ORDER BY e.id DESC";

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, voterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    java.util.Map<String, Object> map = new java.util.HashMap<>();
                    map.put("electionId", rs.getInt("election_id"));
                    map.put("electionName", rs.getString("election_name"));
                    map.put("electionStatus", rs.getString("status"));
                    map.put("startTime", rs.getTimestamp("start_time"));
                    map.put("endTime", rs.getTimestamp("end_time"));
                    map.put("hasVoted", rs.getBoolean("has_voted"));
                    map.put("votedAt", rs.getTimestamp("voted_at"));
                    list.add(map);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching participation for voter: " + voterId, e);
        }
        return list;
    }

    private User mapRowToUser(ResultSet rs) throws SQLException {
        User u = new User();
        u.setId(rs.getInt("id"));
        u.setFullName(rs.getString("full_name"));
        u.setEmail(rs.getString("email"));
        u.setCollegeId(rs.getString("college_id"));

        try {
            u.setCollegeName(rs.getString("college_name"));
            u.setProgramName(rs.getString("program_name"));
            int jy = rs.getInt("joining_year");
            if (!rs.wasNull()) {
                u.setJoiningYear(jy);
            }
            u.setStudyYear(rs.getString("study_year"));
            u.setPhotoBase64(rs.getString("photo_base64"));
        } catch (SQLException ignore) {
            // Safe fallback for query projections
        }

        u.setPasswordHash(rs.getString("password_hash"));
        u.setRole(rs.getString("role"));
        u.setVerified(rs.getBoolean("is_verified"));
        u.setActive(rs.getBoolean("is_active"));
        u.setCreatedAt(rs.getTimestamp("created_at"));

        try {
            u.setStatus(rs.getString("status"));
            u.setRejectionReason(rs.getString("rejection_reason"));
            u.setForcePasswordReset(rs.getBoolean("force_password_reset"));
            u.setHasVoted(rs.getBoolean("has_voted"));
        } catch (SQLException ignore) {
            // Fallback for older projections
        }

        return u;
    }
}
