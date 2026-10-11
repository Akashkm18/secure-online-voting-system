package dao;

import model.Election;
import util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class ElectionDAO {

    private static final Logger LOGGER = Logger.getLogger(ElectionDAO.class.getName());

    public Election findById(int id) {
        String sql = "SELECT id, election_name, description, start_time, end_time, status, created_at " +
                     "FROM elections WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, id);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return mapRowToElection(rs);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error in findById for election: " + id, e);
        }
        return null;
    }

    public List<Election> getAllElections() {
        return getElectionsFiltered(null, null, 0, 500);
    }

    public List<Election> getElectionsFiltered(String search, String status, int offset, int limit) {
        List<Election> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
                "SELECT e.id, e.election_name, e.description, e.start_time, e.end_time, e.status, e.created_at, " +
                "(SELECT COUNT(*) FROM votes v WHERE v.election_id = e.id) AS total_votes, " +
                "(SELECT COUNT(*) FROM candidates c WHERE c.election_id = e.id) AS candidates_count " +
                "FROM elections e WHERE 1=1 ");

        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(e.election_name) LIKE ? OR LOWER(e.description) LIKE ?) ");
            String s = "%" + search.trim().toLowerCase() + "%";
            params.add(s);
            params.add(s);
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql.append("AND e.status = ? ");
            params.add(status.trim().toUpperCase());
        }

        sql.append("ORDER BY e.id DESC LIMIT ? OFFSET ?");
        params.add(limit > 0 ? limit : 20);
        params.add(offset >= 0 ? offset : 0);

        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql.toString())) {

            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }

            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Election el = mapRowToElection(rs);
                    el.setTotalVotes(rs.getInt("total_votes"));
                    el.setCandidatesCount(rs.getInt("candidates_count"));
                    list.add(el);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching filtered elections", e);
        }
        return list;
    }

    public int countElections(String search, String status) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM elections e WHERE 1=1 ");
        List<Object> params = new ArrayList<>();

        if (search != null && !search.trim().isEmpty()) {
            sql.append("AND (LOWER(e.election_name) LIKE ? OR LOWER(e.description) LIKE ?) ");
            String s = "%" + search.trim().toLowerCase() + "%";
            params.add(s);
            params.add(s);
        }

        if (status != null && !status.trim().isEmpty() && !"ALL".equalsIgnoreCase(status.trim())) {
            sql.append("AND e.status = ? ");
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
            LOGGER.log(Level.SEVERE, "Error counting filtered elections", e);
        }
        return 0;
    }

    public List<Election> getActiveElections() {
        List<Election> list = new ArrayList<>();
        // An election is active if status is ACTIVE and current time falls between start and end time
        String sql = "SELECT e.id, e.election_name, e.description, e.start_time, e.end_time, e.status, e.created_at, " +
                     "(SELECT COUNT(*) FROM votes v WHERE v.election_id = e.id) AS total_votes, " +
                     "(SELECT COUNT(*) FROM candidates c WHERE c.election_id = e.id) AS candidates_count " +
                     "FROM elections e WHERE e.status = 'ACTIVE' AND NOW() BETWEEN e.start_time AND e.end_time " +
                     "ORDER BY e.end_time ASC";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Election el = mapRowToElection(rs);
                el.setTotalVotes(rs.getInt("total_votes"));
                el.setCandidatesCount(rs.getInt("candidates_count"));
                list.add(el);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching active elections", e);
        }
        return list;
    }

    public boolean createElection(Election election) {
        String sql = "INSERT INTO elections (election_name, description, start_time, end_time, status) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setString(1, election.getElectionName().trim());
            ps.setString(2, election.getDescription() != null ? election.getDescription().trim() : "");
            ps.setTimestamp(3, election.getStartTime());
            ps.setTimestamp(4, election.getEndTime());
            ps.setString(5, election.getStatus() != null ? election.getStatus().toUpperCase() : "UPCOMING");

            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        election.setId(rs.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error creating election", e);
        }
        return false;
    }

    public boolean updateElection(Election election) {
        String sql = "UPDATE elections SET election_name = ?, description = ?, start_time = ?, end_time = ? " +
                     "WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, election.getElectionName().trim());
            ps.setString(2, election.getDescription() != null ? election.getDescription().trim() : "");
            ps.setTimestamp(3, election.getStartTime());
            ps.setTimestamp(4, election.getEndTime());
            ps.setInt(5, election.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating election: " + election.getId(), e);
        }
        return false;
    }

    public boolean hasVotes(int electionId) {
        String sql = "SELECT 1 FROM votes WHERE election_id = ? LIMIT 1";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking votes for election: " + electionId, e);
        }
        return false;
    }

    /**
     * Strictly enforces the server-side status workflow:
     * UPCOMING -> ACTIVE -> COMPLETED -> PUBLISHED
     * Returns true if transition is legally valid and applied, false otherwise.
     */
    public boolean transitionStatus(int electionId, String targetStatus) {
        if (targetStatus == null) return false;
        String next = targetStatus.trim().toUpperCase();

        Election current = findById(electionId);
        if (current == null) return false;

        String prev = current.getStatus() != null ? current.getStatus().toUpperCase() : "UPCOMING";

        // Strict workflow rules:
        // UPCOMING -> ACTIVE
        // ACTIVE -> COMPLETED
        // COMPLETED -> PUBLISHED
        // ARCHIVED is allowed from COMPLETED or PUBLISHED
        boolean validTransition = false;
        if ("UPCOMING".equals(prev) && "ACTIVE".equals(next)) {
            validTransition = true;
        } else if ("ACTIVE".equals(prev) && "COMPLETED".equals(next)) {
            validTransition = true;
        } else if ("COMPLETED".equals(prev) && "PUBLISHED".equals(next)) {
            validTransition = true;
        } else if ("ARCHIVED".equals(next) && ("COMPLETED".equals(prev) || "PUBLISHED".equals(prev))) {
            validTransition = true;
        }

        if (!validTransition) {
            LOGGER.warning("Illegal election status transition attempted: " + prev + " -> " + next + " for id: " + electionId);
            return false;
        }

        return updateStatus(electionId, next);
    }

    public boolean updateStatus(int electionId, String status) {
        String sql = "UPDATE elections SET status = ? WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status.toUpperCase());
            ps.setInt(2, electionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating election status for id: " + electionId, e);
        }
        return false;
    }

    public boolean deleteElection(int electionId) {
        // Enforce safety: do not delete if votes have been cast!
        if (hasVotes(electionId)) {
            LOGGER.warning("Cannot delete election " + electionId + " because votes exist. Archive instead.");
            return false;
        }

        String sql = "DELETE FROM elections WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting election: " + electionId, e);
        }
        return false;
    }

    public int countByStatus(String status) {
        String sql = "SELECT COUNT(*) FROM elections WHERE status = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, status.toUpperCase());
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting elections by status: " + status, e);
        }
        return 0;
    }

    public int countTotal() {
        String sql = "SELECT COUNT(*) FROM elections";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting total elections", e);
        }
        return 0;
    }

    private Election mapRowToElection(ResultSet rs) throws SQLException {
        Election e = new Election();
        e.setId(rs.getInt("id"));
        e.setElectionName(rs.getString("election_name"));
        e.setDescription(rs.getString("description"));
        e.setStartTime(rs.getTimestamp("start_time"));
        e.setEndTime(rs.getTimestamp("end_time"));
        e.setStatus(rs.getString("status"));
        e.setCreatedAt(rs.getTimestamp("created_at"));
        return e;
    }
}
