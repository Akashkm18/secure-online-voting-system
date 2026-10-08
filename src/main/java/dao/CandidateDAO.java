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
        String sql = "SELECT c.id, c.election_id, c.candidate_name, c.party, c.symbol, c.is_active, e.election_name " +
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
        String sql = "SELECT c.id, c.election_id, c.candidate_name, c.party, c.symbol, c.is_active, e.election_name " +
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
        String sql = "SELECT c.id, c.election_id, c.candidate_name, c.party, c.symbol, c.is_active, e.election_name " +
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
        String sql = "INSERT INTO candidates (election_id, candidate_name, party, symbol, is_active) " +
                     "VALUES (?, ?, ?, ?, ?)";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            ps.setInt(1, c.getElectionId());
            ps.setString(2, c.getCandidateName().trim());
            ps.setString(3, c.getParty().trim());
            ps.setString(4, c.getSymbol().trim());
            ps.setBoolean(5, c.isActive());

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
        String sql = "UPDATE candidates SET candidate_name = ?, party = ?, symbol = ?, is_active = ? " +
                     "WHERE id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setString(1, c.getCandidateName().trim());
            ps.setString(2, c.getParty().trim());
            ps.setString(3, c.getSymbol().trim());
            ps.setBoolean(4, c.isActive());
            ps.setInt(5, c.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating candidate: " + c.getId(), e);
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
        return c;
    }
}
