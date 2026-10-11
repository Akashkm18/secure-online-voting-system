package controller;

import dao.ElectionDAO;
import model.Election;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;
import org.mockito.Mockito;
import util.DatabaseConnection;
import util.ImageProcessingUtil;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import javax.imageio.ImageIO;
import java.awt.Color;
import java.awt.Graphics2D;
import java.awt.image.BufferedImage;
import java.io.ByteArrayOutputStream;
import java.sql.Connection;
import java.sql.Statement;
import java.sql.Timestamp;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

/**
 * JUnit test suite verifying:
 * 1. Election status transitions (UPCOMING -> ACTIVE -> COMPLETED -> PUBLISHED, no skipping or reversing)
 * 2. Publish certified results strictly blocked unless COMPLETED
 * 3. Photo validation in ImageProcessingUtil (rejects non-images, oversized files, renamed .exe)
 * 4. CandidatePhotoServlet ID validation (rejects invalid/non-positive IDs with 400)
 */
public class AdminWorkflowTest {

    private static ElectionDAO electionDAO;

    @BeforeAll
    public static void setup() throws Exception {
        String h2Url = "jdbc:h2:mem:admin_workflow_test;MODE=MySQL;DATABASE_TO_LOWER=TRUE;DB_CLOSE_DELAY=-1";
        DatabaseConnection.setCustomConfig(h2Url, "sa", "");

        electionDAO = new ElectionDAO();

        try (Connection con = DatabaseConnection.getConnection();
             Statement stmt = con.createStatement()) {

            stmt.execute("CREATE TABLE IF NOT EXISTS users (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "full_name VARCHAR(100) NOT NULL, " +
                    "email VARCHAR(150) NOT NULL UNIQUE, " +
                    "password_hash VARCHAR(255) NOT NULL, " +
                    "role VARCHAR(20) DEFAULT 'ADMIN', " +
                    "status VARCHAR(20) DEFAULT 'APPROVED', " +
                    "is_active BOOLEAN DEFAULT TRUE" +
                    ")");

            stmt.execute("CREATE TABLE IF NOT EXISTS elections (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "election_name VARCHAR(150) NOT NULL, " +
                    "description TEXT, " +
                    "start_time TIMESTAMP NOT NULL, " +
                    "end_time TIMESTAMP NOT NULL, " +
                    "status VARCHAR(20) DEFAULT 'UPCOMING', " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");

            stmt.execute("CREATE TABLE IF NOT EXISTS candidates (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "election_id INT NOT NULL, " +
                    "candidate_name VARCHAR(100) NOT NULL, " +
                    "party VARCHAR(100) NOT NULL, " +
                    "symbol VARCHAR(50) NOT NULL, " +
                    "position VARCHAR(100) DEFAULT 'Executive Representative', " +
                    "bio VARCHAR(500) NULL, " +
                    "manifesto VARCHAR(1000) NULL, " +
                    "photo_data BLOB NULL, " +
                    "photo_type VARCHAR(20) NULL, " +
                    "photo_updated_at TIMESTAMP NULL, " +
                    "is_active BOOLEAN DEFAULT TRUE" +
                    ")");

            stmt.execute("CREATE TABLE IF NOT EXISTS votes (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "election_id INT NOT NULL, " +
                    "voter_id INT NOT NULL, " +
                    "candidate_id INT NOT NULL, " +
                    "vote_hash VARCHAR(64) NOT NULL, " +
                    "voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");

            stmt.execute("CREATE TABLE IF NOT EXISTS audit_logs (" +
                    "id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "user_id INT NULL, " +
                    "user_role VARCHAR(20) NULL, " +
                    "action VARCHAR(100) NOT NULL, " +
                    "ip_address VARCHAR(50), " +
                    "user_agent VARCHAR(255), " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ")");
        }
    }

    // -------------------------------------------------------------------------
    // 1 & 2. Status Transitions & Publish Blocking
    // -------------------------------------------------------------------------

    @Test
    @DisplayName("Status workflow enforces UPCOMING -> ACTIVE -> COMPLETED -> PUBLISHED without skipping or reversing")
    public void testStrictStatusTransitionsWorkflow() {
        long now = System.currentTimeMillis();
        Election el = new Election();
        el.setElectionName("Council Workflow Election");
        el.setDescription("Testing strict workflow transitions");
        el.setStartTime(new Timestamp(now - 3600000));
        el.setEndTime(new Timestamp(now + 3600000));
        el.setStatus("UPCOMING");
        assertTrue(electionDAO.createElection(el));
        int id = el.getId();

        // 1. Initial status is UPCOMING
        Election fetched = electionDAO.findById(id);
        assertEquals("UPCOMING", fetched.getStatus());

        // 2. Reject skipping directly to COMPLETED or PUBLISHED from UPCOMING
        assertFalse(electionDAO.transitionStatus(id, "COMPLETED"), "Skipping UPCOMING -> COMPLETED must be rejected");
        assertFalse(electionDAO.transitionStatus(id, "PUBLISHED"), "Publishing an UPCOMING election must be blocked");
        assertEquals("UPCOMING", electionDAO.findById(id).getStatus());

        // 3. Valid transition: UPCOMING -> ACTIVE
        assertTrue(electionDAO.transitionStatus(id, "ACTIVE"));
        assertEquals("ACTIVE", electionDAO.findById(id).getStatus());

        // 4. Reject publishing directly from ACTIVE (publish blocked unless COMPLETED)
        assertFalse(electionDAO.transitionStatus(id, "PUBLISHED"), "Publishing an ACTIVE election must be strictly blocked");
        // Reject reversing ACTIVE -> UPCOMING
        assertFalse(electionDAO.transitionStatus(id, "UPCOMING"), "Reversing ACTIVE -> UPCOMING must be rejected");
        assertEquals("ACTIVE", electionDAO.findById(id).getStatus());

        // 5. Valid transition: ACTIVE -> COMPLETED
        assertTrue(electionDAO.transitionStatus(id, "COMPLETED"));
        assertEquals("COMPLETED", electionDAO.findById(id).getStatus());

        // 6. Reject reversing COMPLETED -> ACTIVE or COMPLETED -> UPCOMING
        assertFalse(electionDAO.transitionStatus(id, "ACTIVE"), "Reversing COMPLETED -> ACTIVE must be rejected");
        assertFalse(electionDAO.transitionStatus(id, "UPCOMING"), "Reversing COMPLETED -> UPCOMING must be rejected");
        assertEquals("COMPLETED", electionDAO.findById(id).getStatus());

        // 7. Valid transition: COMPLETED -> PUBLISHED (Publish certified results)
        assertTrue(electionDAO.transitionStatus(id, "PUBLISHED"));
        assertEquals("PUBLISHED", electionDAO.findById(id).getStatus());

        // 8. Reject reversing PUBLISHED -> COMPLETED or PUBLISHED -> ACTIVE
        assertFalse(electionDAO.transitionStatus(id, "COMPLETED"), "Reversing PUBLISHED -> COMPLETED must be rejected");
        assertFalse(electionDAO.transitionStatus(id, "ACTIVE"), "Reversing PUBLISHED -> ACTIVE must be rejected");
        assertEquals("PUBLISHED", electionDAO.findById(id).getStatus());
    }

    // -------------------------------------------------------------------------
    // 3. Photo Validation (rejects non-images, oversized files, renamed .exe)
    // -------------------------------------------------------------------------

    @Test
    @DisplayName("Photo validation accepts real PNG/JPEG and center-crops to 400x400")
    public void testPhotoValidationAcceptsValidImage() throws Exception {
        BufferedImage img = new BufferedImage(300, 200, BufferedImage.TYPE_INT_RGB);
        Graphics2D g = img.createGraphics();
        g.setColor(Color.BLUE);
        g.fillRect(0, 0, 300, 200);
        g.dispose();

        ByteArrayOutputStream baos = new ByteArrayOutputStream();
        ImageIO.write(img, "png", baos);
        byte[] pngBytes = baos.toByteArray();

        byte[] processed = ImageProcessingUtil.processCandidatePhoto(pngBytes, "image/png");
        assertNotNull(processed);
        assertTrue(processed.length > 0);

        // Verify output is a center-cropped 400x400 square image
        BufferedImage resultImg = ImageIO.read(new java.io.ByteArrayInputStream(processed));
        assertNotNull(resultImg);
        assertEquals(400, resultImg.getWidth());
        assertEquals(400, resultImg.getHeight());
    }

    @Test
    @DisplayName("Photo validation rejects oversized file > 2MB")
    public void testPhotoValidationRejectsOversized() {
        byte[] oversized = new byte[2 * 1024 * 1024 + 10]; // 2 MB + 10 bytes
        // Put JPEG header
        oversized[0] = (byte) 0xFF;
        oversized[1] = (byte) 0xD8;
        oversized[2] = (byte) 0xFF;

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            ImageProcessingUtil.processCandidatePhoto(oversized, "image/jpeg");
        });
        assertTrue(ex.getMessage().toLowerCase().contains("exceeds"), "Error message should mention size limit");
    }

    @Test
    @DisplayName("Photo validation rejects renamed executable (.exe) disguised as image")
    public void testPhotoValidationRejectsRenamedExecutable() {
        // Windows PE/DOS executable starts with 'M' 'Z' (0x4D, 0x5A)
        byte[] exePayload = new byte[512];
        exePayload[0] = 0x4D; // 'M'
        exePayload[1] = 0x5A; // 'Z'
        exePayload[2] = (byte) 0x90;
        exePayload[3] = 0x00;

        IllegalArgumentException ex = assertThrows(IllegalArgumentException.class, () -> {
            ImageProcessingUtil.processCandidatePhoto(exePayload, "image/jpeg");
        });
        assertTrue(ex.getMessage().contains("Invalid file format"), "Must reject invalid magic bytes");
    }

    @Test
    @DisplayName("Photo validation rejects non-image text/html payload")
    public void testPhotoValidationRejectsNonImage() {
        byte[] textPayload = "Hello world, this is a plain text file, not an image.".getBytes();

        assertThrows(IllegalArgumentException.class, () -> {
            ImageProcessingUtil.processCandidatePhoto(textPayload, "text/plain");
        });
    }

    // -------------------------------------------------------------------------
    // 4. CandidatePhotoServlet ID Validation
    // -------------------------------------------------------------------------

    @Test
    @DisplayName("CandidatePhotoServlet rejects non-positive or malformed IDs with HTTP 400")
    public void testCandidatePhotoServletIdValidation() throws Exception {
        CandidatePhotoServlet servlet = new CandidatePhotoServlet();

        // 1. Missing ID parameter -> 400
        HttpServletRequest reqMissing = mock(HttpServletRequest.class);
        HttpServletResponse resMissing = mock(HttpServletResponse.class);
        when(reqMissing.getParameter("id")).thenReturn(null);
        servlet.doGet(reqMissing, resMissing);
        verify(resMissing).sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing candidate ID.");

        // 2. Non-numeric ID parameter -> 400
        HttpServletRequest reqAlpha = mock(HttpServletRequest.class);
        HttpServletResponse resAlpha = mock(HttpServletResponse.class);
        when(reqAlpha.getParameter("id")).thenReturn("invalid_cand_id");
        servlet.doGet(reqAlpha, resAlpha);
        verify(resAlpha).sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing candidate ID.");

        // 3. Negative ID parameter -> 400
        HttpServletRequest reqNeg = mock(HttpServletRequest.class);
        HttpServletResponse resNeg = mock(HttpServletResponse.class);
        when(reqNeg.getParameter("id")).thenReturn("-5");
        servlet.doGet(reqNeg, resNeg);
        verify(resNeg).sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing candidate ID.");

        // 4. Zero ID parameter -> 400
        HttpServletRequest reqZero = mock(HttpServletRequest.class);
        HttpServletResponse resZero = mock(HttpServletResponse.class);
        when(reqZero.getParameter("id")).thenReturn("0");
        servlet.doGet(reqZero, resZero);
        verify(resZero).sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid or missing candidate ID.");
    }
}
