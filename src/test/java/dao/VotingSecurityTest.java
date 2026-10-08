package dao;

import model.Candidate;
import model.Election;
import model.User;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import util.DatabaseConnection;
import util.PasswordUtil;

import java.sql.Connection;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.List;
import java.util.concurrent.CountDownLatch;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.atomic.AtomicInteger;

import static org.junit.jupiter.api.Assertions.*;

public class VotingSecurityTest {

    private static UserDAO userDAO;
    private static ElectionDAO electionDAO;
    private static CandidateDAO candidateDAO;
    private static VoteDAO voteDAO;

    @BeforeAll
    public static void setupInMemoryDatabase() throws Exception {
        // Point DatabaseConnection to in-memory H2 database in MySQL compatibility mode
        String h2Url = "jdbc:h2:mem:online_voting_test;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1";
        DatabaseConnection.setCustomConfig(h2Url, "sa", "");

        userDAO = new UserDAO();
        electionDAO = new ElectionDAO();
        candidateDAO = new CandidateDAO();
        voteDAO = new VoteDAO();

        try (Connection con = DatabaseConnection.getConnection();
             Statement stmt = con.createStatement()) {

            // Create users table
            stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "full_name VARCHAR(100) NOT NULL, " +
                    "email VARCHAR(150) NOT NULL UNIQUE, " +
                    "college_id VARCHAR(50) NULL UNIQUE, " +
                    "college_name VARCHAR(150) NULL, " +
                    "program_name VARCHAR(100) NULL, " +
                    "joining_year INT NULL, " +
                    "study_year VARCHAR(30) NULL, " +
                    "photo_base64 VARCHAR(2000) NULL, " +
                    "password_hash VARCHAR(255) NOT NULL, " +
                    "role VARCHAR(20) DEFAULT 'VOTER', " +
                    "is_verified BOOLEAN DEFAULT TRUE, " +
                    "is_active BOOLEAN DEFAULT TRUE, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");

            // Create elections table
            stmt.execute("CREATE TABLE IF NOT EXISTS elections (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "election_name VARCHAR(150) NOT NULL, " +
                    "description TEXT, " +
                    "start_time TIMESTAMP NOT NULL, " +
                    "end_time TIMESTAMP NOT NULL, " +
                    "status VARCHAR(20) DEFAULT 'UPCOMING', " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");

            // Create candidates table
            stmt.execute("CREATE TABLE IF NOT EXISTS candidates (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "election_id INT NOT NULL, " +
                    "candidate_name VARCHAR(100) NOT NULL, " +
                    "party VARCHAR(100) NOT NULL, " +
                    "symbol VARCHAR(50) NOT NULL, " +
                    "is_active BOOLEAN DEFAULT TRUE" +
                    ")");

            // Create votes table with UNIQUE(election_id, voter_id)
            stmt.execute("CREATE TABLE IF NOT EXISTS votes (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "election_id INT NOT NULL, " +
                    "voter_id INT NOT NULL, " +
                    "candidate_id INT NOT NULL, " +
                    "vote_hash VARCHAR(64) NOT NULL, " +
                    "voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP, " +
                    "CONSTRAINT uq_election_voter UNIQUE (election_id, voter_id)" +
                    ")");

            // Create audit_logs table
            stmt.execute("CREATE TABLE IF NOT EXISTS audit_logs (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "user_id INT NULL, " +
                    "action VARCHAR(100) NOT NULL, " +
                    "ip_address VARCHAR(50), " +
                    "user_agent VARCHAR(255), " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");
        }
    }

    @Test
    @DisplayName("Test 1: Successful voter registration & BCrypt password verification")
    public void testSuccessfulRegistrationAndLogin() {
        User user = new User();
        user.setFullName("Test Voter One");
        user.setEmail("voter1@test.edu");
        user.setPasswordHash(PasswordUtil.hashPassword("SecurePass123"));
        user.setRole("VOTER");
        user.setVerified(true);
        user.setActive(true);

        boolean created = userDAO.createUser(user);
        assertTrue(created, "User creation must succeed");
        assertTrue(user.getId() > 0, "Generated ID must be assigned");

        // Verify login
        User fetched = userDAO.findByEmail("voter1@test.edu");
        assertNotNull(fetched);
        assertTrue(PasswordUtil.verifyPassword("SecurePass123", fetched.getPasswordHash()));
        assertFalse(PasswordUtil.verifyPassword("WrongPassword", fetched.getPasswordHash()));
    }

    @Test
    @DisplayName("Test 2: Duplicate email registration prevention")
    public void testDuplicateEmailRegistrationFails() {
        User user1 = new User();
        user1.setFullName("Duplicate Test Voter");
        user1.setEmail("duplicate@test.edu");
        user1.setPasswordHash(PasswordUtil.hashPassword("Password@123"));
        user1.setRole("VOTER");
        user1.setVerified(true);
        user1.setActive(true);
        assertTrue(userDAO.createUser(user1));

        User user2 = new User();
        user2.setFullName("Another Voter");
        user2.setEmail("duplicate@test.edu"); // same email
        user2.setPasswordHash(PasswordUtil.hashPassword("Password@123"));
        user2.setRole("VOTER");
        user2.setVerified(true);
        user2.setActive(true);

        // Database UNIQUE constraint must prevent duplicate insertion
        boolean duplicateCreated = userDAO.createUser(user2);
        assertFalse(duplicateCreated, "Duplicate email registration must fail");
    }

    @Test
    @DisplayName("Test 3: Vote transaction validation (candidate belonging to election)")
    public void testCandidateElectionMismatchRejected() {
        // Create an election
        Election election = new Election();
        election.setElectionName("Mismatched Candidate Election");
        election.setDescription("Testing election validation");
        election.setStartTime(new Timestamp(System.currentTimeMillis() - 3600000));
        election.setEndTime(new Timestamp(System.currentTimeMillis() + 3600000));
        election.setStatus("ACTIVE");
        assertTrue(electionDAO.createElection(election));

        // Create a candidate in a DIFFERENT election (id: 9999)
        Candidate candidate = new Candidate();
        candidate.setElectionId(9999);
        candidate.setCandidateName("Alien Candidate");
        candidate.setParty("Alien Party");
        candidate.setSymbol("Flying Saucer");
        candidate.setActive(true);
        assertTrue(candidateDAO.createCandidate(candidate));

        // Create a test voter
        User voter = new User();
        voter.setFullName("Mismatch Voter");
        voter.setEmail("mismatch@test.edu");
        voter.setPasswordHash(PasswordUtil.hashPassword("Pass@123"));
        voter.setRole("VOTER");
        voter.setVerified(true);
        voter.setActive(true);
        assertTrue(userDAO.createUser(voter));

        // Casting vote with mismatched candidate must throw IllegalStateException
        assertThrows(IllegalStateException.class, () -> {
            voteDAO.castVote(election.getId(), voter.getId(), candidate.getId(), "127.0.0.1", "JUnit");
        });
    }

    @Test
    @DisplayName("Test 4: Successful vote casting, duplicate vote prevention & receipt privacy")
    public void testVoteCastingAndDuplicatePrevention() throws Exception {
        // 1. Create active election
        Election election = new Election();
        election.setElectionName("Campus Council Election");
        election.setDescription("Election for council members");
        election.setStartTime(new Timestamp(System.currentTimeMillis() - 100000));
        election.setEndTime(new Timestamp(System.currentTimeMillis() + 100000));
        election.setStatus("ACTIVE");
        assertTrue(electionDAO.createElection(election));

        // 2. Create candidate
        Candidate candidate = new Candidate();
        candidate.setElectionId(election.getId());
        candidate.setCandidateName("Jane Council");
        candidate.setParty("Progressive Students");
        candidate.setSymbol("Star");
        candidate.setActive(true);
        assertTrue(candidateDAO.createCandidate(candidate));

        // 3. Create voter
        User voter = new User();
        voter.setFullName("Single Vote Voter");
        voter.setEmail("singlevote@test.edu");
        voter.setPasswordHash(PasswordUtil.hashPassword("Pass@123"));
        voter.setRole("VOTER");
        voter.setVerified(true);
        voter.setActive(true);
        assertTrue(userDAO.createUser(voter));

        assertFalse(voteDAO.hasUserVoted(election.getId(), voter.getId()));

        // 4. Cast first vote -> must succeed
        String receiptHash = voteDAO.castVote(election.getId(), voter.getId(), candidate.getId(), "127.0.0.1", "JUnit");
        assertNotNull(receiptHash);
        assertEquals(64, receiptHash.length());
        assertTrue(voteDAO.hasUserVoted(election.getId(), voter.getId()));

        // 5. Verify receipt does not leak candidate details
        var receipt = voteDAO.getVoteReceipt(election.getId(), voter.getId());
        assertNotNull(receipt);
        assertEquals(receiptHash, receipt.get("voteHash"));
        assertEquals("Campus Council Election", receipt.get("electionName"));
        assertFalse(receipt.containsKey("candidateName"), "Receipt must not contain candidate choice");

        // 6. Attempt duplicate vote -> must be rejected by single-vote constraint
        assertThrows(IllegalStateException.class, () -> {
            voteDAO.castVote(election.getId(), voter.getId(), candidate.getId(), "127.0.0.1", "JUnit");
        });
    }

    @Test
    @DisplayName("Test 5: Concurrent duplicate voting attack simulation")
    public void testConcurrentDuplicateVoting() throws Exception {
        Election election = new Election();
        election.setElectionName("Concurrent Election");
        election.setDescription("Stress testing concurrency");
        election.setStartTime(new Timestamp(System.currentTimeMillis() - 100000));
        election.setEndTime(new Timestamp(System.currentTimeMillis() + 100000));
        election.setStatus("ACTIVE");
        assertTrue(electionDAO.createElection(election));

        Candidate candidate = new Candidate();
        candidate.setElectionId(election.getId());
        candidate.setCandidateName("Concurrency Candidate");
        candidate.setParty("Tech Party");
        candidate.setSymbol("Processor");
        candidate.setActive(true);
        assertTrue(candidateDAO.createCandidate(candidate));

        User voter = new User();
        voter.setFullName("Concurrent Voter");
        voter.setEmail("concurrent@test.edu");
        voter.setPasswordHash(PasswordUtil.hashPassword("Pass@123"));
        voter.setRole("VOTER");
        voter.setVerified(true);
        voter.setActive(true);
        assertTrue(userDAO.createUser(voter));

        // Fire 2 concurrent voting requests simultaneously for the same voter in the same election
        int threads = 2;
        ExecutorService executor = Executors.newFixedThreadPool(threads);
        CountDownLatch latch = new CountDownLatch(1);
        AtomicInteger successCount = new AtomicInteger(0);
        AtomicInteger failureCount = new AtomicInteger(0);

        for (int i = 0; i < threads; i++) {
            executor.submit(() -> {
                try {
                    latch.await(); // ensure simultaneous execution
                    voteDAO.castVote(election.getId(), voter.getId(), candidate.getId(), "127.0.0.1", "JUnit-Concurrent");
                    successCount.incrementAndGet();
                } catch (Exception e) {
                    failureCount.incrementAndGet();
                }
            });
        }

        latch.countDown();
        executor.shutdown();
        executor.awaitTermination(5, java.util.concurrent.TimeUnit.SECONDS);

        // Exactly ONE vote must have succeeded and ONE must have failed!
        assertEquals(1, successCount.get(), "Exactly one concurrent vote must commit");
        assertEquals(1, failureCount.get(), "Concurrent duplicate attempt must fail");
    }

    @Test
    @DisplayName("Test 6: Admin result calculation and publishing")
    public void testResultsAndPublishing() throws Exception {
        Election election = new Election();
        election.setElectionName("Tally Test Election");
        election.setDescription("Testing vote count calculation");
        election.setStartTime(new Timestamp(System.currentTimeMillis() - 100000));
        election.setEndTime(new Timestamp(System.currentTimeMillis() + 100000));
        election.setStatus("ACTIVE");
        assertTrue(electionDAO.createElection(election));

        Candidate candA = new Candidate(0, election.getId(), "Alice Winner", "Party A", "Apple", true);
        Candidate candB = new Candidate(0, election.getId(), "Bob RunnerUp", "Party B", "Banana", true);
        assertTrue(candidateDAO.createCandidate(candA));
        assertTrue(candidateDAO.createCandidate(candB));

        // Create 3 voters: 2 vote for Alice, 1 votes for Bob
        for (int i = 1; i <= 3; i++) {
            User v = new User(0, "Voter " + i, "voter" + i + "@tally.edu", "COL-" + i, PasswordUtil.hashPassword("Pass@123"), "VOTER", true, true, null);
            assertTrue(userDAO.createUser(v));
            int chosenCand = (i <= 2) ? candA.getId() : candB.getId();
            voteDAO.castVote(election.getId(), v.getId(), chosenCand, "127.0.0.1", "TallyTest");
        }

        // Tally results
        List<Candidate> results = voteDAO.getElectionResults(election.getId());
        assertEquals(2, results.size());
        assertEquals("Alice Winner", results.get(0).getCandidateName());
        assertEquals(2, results.get(0).getVoteCount());
        assertEquals(66.7, results.get(0).getVotePercentage(), 0.5);

        assertEquals("Bob RunnerUp", results.get(1).getCandidateName());
        assertEquals(1, results.get(1).getVoteCount());
        assertEquals(33.3, results.get(1).getVotePercentage(), 0.5);

        // Test status update to PUBLISHED
        boolean published = electionDAO.updateStatus(election.getId(), "PUBLISHED");
        assertTrue(published);
        Election updatedElection = electionDAO.findById(election.getId());
        assertEquals("PUBLISHED", updatedElection.getStatus());
        assertTrue(updatedElection.isPublished());
    }
}
