package dao;

import model.Candidate;
import util.DatabaseConnection;
import util.SecurityUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.logging.Level;
import java.util.logging.Logger;

public class VoteDAO {

    private static final Logger LOGGER = Logger.getLogger(VoteDAO.class.getName());

    /**
     * Checks if a voter has already cast a vote in the specified election.
     */
    public boolean hasUserVoted(int electionId, int voterId) {
        String sql = "SELECT 1 FROM votes WHERE election_id = ? AND voter_id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            ps.setInt(2, voterId);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking user voting status", e);
        }
        return false;
    }

    /**
     * Returns the list of election IDs where the voter has already voted.
     */
    public List<Integer> getUserVotedElectionIds(int voterId) {
        List<Integer> list = new ArrayList<>();
        String sql = "SELECT election_id FROM votes WHERE voter_id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, voterId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getInt("election_id"));
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error retrieving voted election IDs for voter: " + voterId, e);
        }
        return list;
    }

    /**
     * Performs atomic vote casting inside a single ACID database transaction.
     * Validates election active window, candidate validity, and single-vote constraint.
     * Rolls back completely if any validation or constraint fails.
     *
     * @return generated vote hash receipt string
     * @throws IllegalStateException or SQLException if voting conditions fail
     */
    public String castVote(int electionId, int voterId, int candidateId, String ipAddress, String userAgent)
            throws SQLException, IllegalStateException {

        Connection con = null;
        try {
            con = DatabaseConnection.getConnection();
            con.setAutoCommit(false);

            // 1. Verify election exists and is currently ACTIVE
            String checkElectionSql = "SELECT election_name, status, start_time, end_time FROM elections WHERE id = ?";
            try (PreparedStatement psElection = con.prepareStatement(checkElectionSql)) {
                psElection.setInt(1, electionId);
                try (ResultSet rsElection = psElection.executeQuery()) {
                    if (!rsElection.next()) {
                        throw new IllegalStateException("Selected election does not exist.");
                    }
                    String status = rsElection.getString("status");
                    Timestamp start = rsElection.getTimestamp("start_time");
                    Timestamp end = rsElection.getTimestamp("end_time");
                    long now = System.currentTimeMillis();

                    if (!"ACTIVE".equalsIgnoreCase(status) || now < start.getTime() || now > end.getTime()) {
                        throw new IllegalStateException("Voting is not open for this election at this time.");
                    }
                }
            }

            // 2. Verify candidate belongs to election and is active
            String checkCandidateSql = "SELECT is_active FROM candidates WHERE id = ? AND election_id = ?";
            try (PreparedStatement psCand = con.prepareStatement(checkCandidateSql)) {
                psCand.setInt(1, candidateId);
                psCand.setInt(2, electionId);
                try (ResultSet rsCand = psCand.executeQuery()) {
                    if (!rsCand.next()) {
                        throw new IllegalStateException("Candidate does not belong to this election.");
                    }
                    if (!rsCand.getBoolean("is_active")) {
                        throw new IllegalStateException("This candidate is no longer active in this election.");
                    }
                }
            }

            // 3. Verify voter has not voted in this election
            String checkVoteSql = "SELECT 1 FROM votes WHERE election_id = ? AND voter_id = ?";
            try (PreparedStatement psCheck = con.prepareStatement(checkVoteSql)) {
                psCheck.setInt(1, electionId);
                psCheck.setInt(2, voterId);
                try (ResultSet rsCheck = psCheck.executeQuery()) {
                    if (rsCheck.next()) {
                        throw new IllegalStateException("You have already cast your vote in this election. Duplicate voting is prohibited.");
                    }
                }
            }

            // 4. Generate cryptographic receipt hash
            long nowTs = System.currentTimeMillis();
            String voteHash = SecurityUtil.generateVoteHash(voterId, electionId, candidateId, nowTs);

            // 5. Insert vote record
            String insertVoteSql = "INSERT INTO votes (election_id, voter_id, candidate_id, vote_hash, voted_at) " +
                    "VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement psInsert = con.prepareStatement(insertVoteSql)) {
                psInsert.setInt(1, electionId);
                psInsert.setInt(2, voterId);
                psInsert.setInt(3, candidateId);
                psInsert.setString(4, voteHash);
                psInsert.setTimestamp(5, new Timestamp(nowTs));
                psInsert.executeUpdate();
            }

            // 6. Record audit log inside the same transaction
            String auditSql = "INSERT INTO audit_logs (user_id, action, ip_address, user_agent, created_at) " +
                    "VALUES (?, ?, ?, ?, ?)";
            try (PreparedStatement psAudit = con.prepareStatement(auditSql)) {
                psAudit.setInt(1, voterId);
                psAudit.setString(2, "VOTE_CAST_ELECTION_" + electionId);
                psAudit.setString(3, ipAddress != null ? ipAddress : "127.0.0.1");
                psAudit.setString(4, userAgent != null ? userAgent : "Unknown");
                psAudit.setTimestamp(5, new Timestamp(nowTs));
                psAudit.executeUpdate();
            }

            // Commit atomic transaction
            con.commit();
            LOGGER.log(Level.INFO, "Vote successfully recorded for voter {0} in election {1}", new Object[]{voterId, electionId});
            return voteHash;

        } catch (Exception e) {
            if (con != null) {
                try {
                    con.rollback();
                    LOGGER.log(Level.WARNING, "Vote transaction rolled back due to error: " + e.getMessage());
                } catch (SQLException ex) {
                    LOGGER.log(Level.SEVERE, "Failed to rollback vote transaction", ex);
                }
            }
            if (e instanceof IllegalStateException) {
                throw (IllegalStateException) e;
            } else if (e instanceof SQLException) {
                // Check for MySQL Duplicate key error code 1062
                SQLException sqlEx = (SQLException) e;
                if (sqlEx.getErrorCode() == 1062 || (sqlEx.getMessage() != null && sqlEx.getMessage().contains("uq_election_voter"))) {
                    throw new IllegalStateException("Duplicate vote detected by database integrity constraint.", e);
                }
                throw sqlEx;
            } else {
                throw new SQLException("Voting process failed: " + e.getMessage(), e);
            }
        } finally {
            if (con != null) {
                try {
                    con.setAutoCommit(true);
                    con.close();
                } catch (SQLException e) {
                    LOGGER.log(Level.SEVERE, "Error closing connection", e);
                }
            }
        }
    }

    /**
     * VOTE PRIVACY:
     * Returns vote receipt information WITHOUT revealing the candidate selected.
     * Contains only election name, vote_hash, and timestamp.
     */
    public Map<String, Object> getVoteReceipt(int electionId, int voterId) {
        String sql = "SELECT v.vote_hash, v.voted_at, e.election_name " +
                     "FROM votes v " +
                     "JOIN elections e ON v.election_id = e.id " +
                     "WHERE v.election_id = ? AND v.voter_id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql)) {

            ps.setInt(1, electionId);
            ps.setInt(2, voterId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Map<String, Object> receipt = new HashMap<>();
                    receipt.put("voteHash", rs.getString("vote_hash"));
                    receipt.put("votedAt", rs.getTimestamp("voted_at"));
                    receipt.put("electionName", rs.getString("election_name"));
                    return receipt;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching vote receipt", e);
        }
        return null;
    }

    /**
     * Computes candidate-wise aggregated vote counts and percentages for an election.
     * Used by Admin Dashboard and published results.
     */
    public List<Candidate> getElectionResults(int electionId) {
        List<Candidate> results = new ArrayList<>();

        // First count total votes for this election
        int totalVotesInElection = 0;
        String totalSql = "SELECT COUNT(*) FROM votes WHERE election_id = ?";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement psTotal = con.prepareStatement(totalSql)) {

            psTotal.setInt(1, electionId);
            try (ResultSet rsTotal = psTotal.executeQuery()) {
                if (rsTotal.next()) {
                    totalVotesInElection = rsTotal.getInt(1);
                }
            }

            // Next aggregate candidate vote counts sorted descending
            String aggSql = "SELECT c.id, c.election_id, c.candidate_name, c.party, c.symbol, c.is_active, " +
                            "COUNT(v.id) AS vote_count " +
                            "FROM candidates c " +
                            "LEFT JOIN votes v ON c.id = v.candidate_id " +
                            "WHERE c.election_id = ? " +
                            "GROUP BY c.id, c.election_id, c.candidate_name, c.party, c.symbol, c.is_active " +
                            "ORDER BY vote_count DESC, c.candidate_name ASC";

            try (PreparedStatement psAgg = con.prepareStatement(aggSql)) {
                psAgg.setInt(1, electionId);
                try (ResultSet rs = psAgg.executeQuery()) {
                    while (rs.next()) {
                        Candidate c = new Candidate();
                        c.setId(rs.getInt("id"));
                        c.setElectionId(rs.getInt("election_id"));
                        c.setCandidateName(rs.getString("candidate_name"));
                        c.setParty(rs.getString("party"));
                        c.setSymbol(rs.getString("symbol"));
                        c.setActive(rs.getBoolean("is_active"));

                        int count = rs.getInt("vote_count");
                        c.setVoteCount(count);
                        double pct = (totalVotesInElection > 0)
                                ? ((double) count / totalVotesInElection) * 100.0
                                : 0.0;
                        c.setVotePercentage(Math.round(pct * 10.0) / 10.0);

                        results.add(c);
                    }
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error calculating election results for election: " + electionId, e);
        }
        return results;
    }

    public int getTotalVotesCount() {
        String sql = "SELECT COUNT(*) FROM votes";
        try (Connection con = DatabaseConnection.getConnection();
             PreparedStatement ps = con.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {

            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error counting total votes", e);
        }
        return 0;
    }
}
