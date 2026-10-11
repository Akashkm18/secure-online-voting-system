package dao;

import model.Candidate;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class CandidateDAO {

    private static final Logger LOGGER = Logger.getLogger(CandidateDAO.class.getName());

    public List<Candidate> findByElectionId(int electionId, boolean onlyActive) {
        List<Candidate> list = new ArrayList<>();
        String sql = "SELECT c.id, c.election_id, c.candidate_name, c.party, c.symbol, " +
                     "c.position, c.bio, c.manifesto, c.photo_type, c.photo_updated_at, " +
                     "(c.photo_data IS NOT NULL AND LENGTH(c.photo_data) > 0) AS has_photo, " +
                     "c.is_active, e.election_name " +
                     "FROM candidates c " +
                     "JOIN elections e ON c.election_id = e.id " +
                     "WHERE c.election_id = ?" + (onlyActive ? " AND c.is_active = TRUE" : "") + " " +
                     "ORDER BY c.id ASC";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRowToCandidate(rs));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching candidates for election: " + electionId, e);
        }
        return list;
    }

    public List<Candidate> getAllCandidates() {
        List<Candidate> list = new ArrayList<>();
        String sql = "SELECT c.id, c.election_id, c.candidate_name, c.party, c.symbol, " +
                     "c.position, c.bio, c.manifesto, c.photo_type, c.photo_updated_at, " +
                     "(c.photo_data IS NOT NULL AND LENGTH(c.photo_data) > 0) AS has_photo, " +
                     "c.is_active, e.election_name " +
                     "FROM candidates c " +
                     "JOIN elections e ON c.election_id = e.id " +
                     "ORDER BY c.id DESC";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToCandidate(rs));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all candidates", e);
        }
        return list;
    }

    public Candidate findById(int id) {
        String sql = "SELECT c.id, c.election_id, c.candidate_name, c.party, c.symbol, " +
                     "c.position, c.bio, c.manifesto, c.photo_type, c.photo_updated_at, " +
                     "(c.photo_data IS NOT NULL AND LENGTH(c.photo_data) > 0) AS has_photo, " +
                     "c.is_active, e.election_name " +
                     "FROM candidates c " +
                     "JOIN elections e ON c.election_id = e.id " +
                     "WHERE c.id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToCandidate(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching candidate by id: " + id, e);
        }
        return null;
    }

    public boolean createCandidate(Candidate c) {
        String sql = "INSERT INTO candidates (election_id, candidate_name, party, symbol, position, bio, manifesto, photo_data, photo_type, photo_updated_at, is_active) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, c.getElectionId());
            ps.setString(2, c.getCandidateName().trim());
            ps.setString(3, c.getParty().trim());
            ps.setString(4, c.getSymbol() != null ? c.getSymbol().trim() : "");
            ps.setString(5, c.getPosition() != null ? c.getPosition().trim() : "Candidate");
            ps.setString(6, c.getBio() != null ? c.getBio().trim() : "");
            ps.setString(7, c.getManifesto() != null ? c.getManifesto().trim() : "");

            if (c.getPhotoData() != null && c.getPhotoData().length > 0) {
                ps.setBytes(8, c.getPhotoData());
                ps.setString(9, c.getPhotoType() != null ? c.getPhotoType() : "image/png");
                ps.setTimestamp(10, new Timestamp(System.currentTimeMillis()));
            } else {
                ps.setNull(8, Types.BLOB);
                ps.setNull(9, Types.VARCHAR);
                ps.setNull(10, Types.TIMESTAMP);
            }

            ps.setBoolean(11, c.isActive());

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        c.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting candidate", e);
        }
        return false;
    }

    public boolean updateCandidate(Candidate c) {
        boolean hasNewPhoto = (c.getPhotoData() != null && c.getPhotoData().length > 0);
        String sql = hasNewPhoto
                ? "UPDATE candidates SET candidate_name = ?, party = ?, symbol = ?, position = ?, bio = ?, manifesto = ?, photo_data = ?, photo_type = ?, photo_updated_at = NOW(), is_active = ? WHERE id = ?"
                : "UPDATE candidates SET candidate_name = ?, party = ?, symbol = ?, position = ?, bio = ?, manifesto = ?, is_active = ? WHERE id = ?";

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, c.getCandidateName().trim());
            ps.setString(2, c.getParty().trim());
            ps.setString(3, c.getSymbol() != null ? c.getSymbol().trim() : "");
            ps.setString(4, c.getPosition() != null ? c.getPosition().trim() : "Candidate");
            ps.setString(5, c.getBio() != null ? c.getBio().trim() : "");
            ps.setString(6, c.getManifesto() != null ? c.getManifesto().trim() : "");

            if (hasNewPhoto) {
                ps.setBytes(7, c.getPhotoData());
                ps.setString(8, c.getPhotoType() != null ? c.getPhotoType() : "image/png");
                ps.setBoolean(9, c.isActive());
                ps.setInt(10, c.getId());
            } else {
                ps.setBoolean(7, c.isActive());
                ps.setInt(8, c.getId());
            }

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating candidate: " + c.getId(), e);
        }
        return false;
    }

    public boolean removePhoto(int id) {
        String sql = "UPDATE candidates SET photo_data = NULL, photo_type = NULL, photo_updated_at = NOW() WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error removing photo for candidate: " + id, e);
        }
        return false;
    }

    public byte[] getPhotoBytes(int id) {
        String sql = "SELECT photo_data FROM candidates WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getBytes("photo_data");
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching photo bytes for candidate: " + id, e);
        }
        return null;
    }

    public Candidate getPhotoMeta(int id) {
        String sql = "SELECT id, candidate_name, photo_data, photo_type, photo_updated_at FROM candidates WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Candidate c = new Candidate();
                    c.setId(rs.getInt("id"));
                    c.setCandidateName(rs.getString("candidate_name"));
                    c.setPhotoData(rs.getBytes("photo_data"));
                    c.setPhotoType(rs.getString("photo_type"));
                    c.setPhotoUpdatedAt(rs.getTimestamp("photo_updated_at"));
                    return c;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching photo metadata for candidate: " + id, e);
        }
        return null;
    }

    public boolean hasVotes(int candidateId) {
        String sql = "SELECT 1 FROM votes WHERE candidate_id = ? LIMIT 1";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, candidateId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking votes for candidate: " + candidateId, e);
        }
        return false;
    }

    public boolean setActiveStatus(int id, boolean active) {
        String sql = "UPDATE candidates SET is_active = ? WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setBoolean(1, active);
            ps.setInt(2, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error setting candidate active status: " + id, e);
        }
        return false;
    }

    public boolean deleteCandidate(int id) {
        // Enforce safety: do not delete if votes exist
        if (hasVotes(id)) {
            LOGGER.warning("Refusing to delete candidate " + id + " because votes have already been cast.");
            return false;
        }

        String sql = "DELETE FROM candidates WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting candidate: " + id, e);
        }
        return false;
    }

    public int countTotal() {
        String sql = "SELECT COUNT(*) FROM candidates";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting total candidates", e);
        }
        return 0;
    }

    private Candidate mapRowToCandidate(ResultSet rs) throws SQLException {
        Candidate c = new Candidate();
        c.setId(rs.getInt("id"));
        c.setElectionId(rs.getInt("election_id"));
        c.setCandidateName(rs.getString("candidate_name"));
        c.setParty(rs.getString("party"));
        c.setSymbol(rs.getString("symbol"));
        c.setActive(rs.getBoolean("is_active"));
        c.setElectionName(rs.getString("election_name"));

        try {
            c.setPosition(rs.getString("position"));
            c.setBio(rs.getString("bio"));
            c.setManifesto(rs.getString("manifesto"));
            c.setPhotoType(rs.getString("photo_type"));
            c.setPhotoUpdatedAt(rs.getTimestamp("photo_updated_at"));
            boolean hasPhoto = rs.getBoolean("has_photo");
            if (hasPhoto) {
                c.setPhotoData(new byte[]{1}); // marker that photo exists
            }
        } catch (SQLException ignore) {
            // column might not exist in old projection
        }

        return c;
    }
}
