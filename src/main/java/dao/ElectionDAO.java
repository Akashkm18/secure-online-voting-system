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
        List<Election> list = new ArrayList<>();
        String sql = "SELECT e.id, e.election_name, e.description, e.start_time, e.end_time, e.status, e.created_at, " +
                     "(SELECT COUNT(*) FROM votes v WHERE v.election_id = e.id) AS total_votes " +
                     "FROM elections e ORDER BY e.id DESC";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                Election el = mapRowToElection(rs);
                el.setTotalVotes(rs.getInt("total_votes"));
                list.add(el);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all elections", e);
        }
        return list;
    }

    public List<Election> getActiveElections() {
        List<Election> list = new ArrayList<>();
        // An election is active if status is ACTIVE and current time falls between start and end time
        String sql = "SELECT id, election_name, description, start_time, end_time, status, created_at " +
                     "FROM elections WHERE status = 'ACTIVE' AND NOW() BETWEEN start_time AND end_time " +
                     "ORDER BY end_time ASC";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            while (rs.next()) {
                list.add(mapRowToElection(rs));
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
