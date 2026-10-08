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

    public List<User> getAllVoters() {
        List<User> list = new ArrayList<>();
        String sql = "SELECT id, full_name, email, college_id, college_name, program_name, joining_year, study_year, photo_base64, password_hash, role, is_verified, is_active, created_at " +
                     "FROM users WHERE role = 'VOTER' ORDER BY id DESC";
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
        String sql = "SELECT COUNT(*) FROM users WHERE role = 'VOTER'";
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
        return u;
    }
}
