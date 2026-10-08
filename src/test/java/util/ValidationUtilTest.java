package util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class ValidationUtilTest {

    @Test
    @DisplayName("Should validate valid email formats")
    public void testValidEmails() {
        assertTrue(ValidationUtil.isValidEmail("student@voting.edu"));
        assertTrue(ValidationUtil.isValidEmail("john.doe@university.ac.in"));
        assertTrue(ValidationUtil.isValidEmail("voter123@campus.org"));
    }

    @Test
    @DisplayName("Should reject malformed emails")
    public void testInvalidEmails() {
        assertFalse(ValidationUtil.isValidEmail("plainaddress"));
        assertFalse(ValidationUtil.isValidEmail("@missingusername.com"));
        assertFalse(ValidationUtil.isValidEmail("spaces in@domain.com"));
        assertFalse(ValidationUtil.isValidEmail(null));
        assertFalse(ValidationUtil.isValidEmail(""));
    }

    @Test
    @DisplayName("Should validate full names correctly")
    public void testValidNames() {
        assertTrue(ValidationUtil.isValidName("John Doe"));
        assertTrue(ValidationUtil.isValidName("Maya Sharma"));
        assertTrue(ValidationUtil.isValidName("O'Connor-Smith"));
    }

    @Test
    @DisplayName("Should reject invalid or dangerous names")
    public void testInvalidNames() {
        assertFalse(ValidationUtil.isValidName("A")); // too short
        assertFalse(ValidationUtil.isValidName("<script>alert(1)</script>")); // XSS injection
        assertFalse(ValidationUtil.isValidName(""));
        assertFalse(ValidationUtil.isValidName(null));
    }

    @Test
    @DisplayName("Should safely parse positive integers and reject SQL injection strings")
    public void testParsePositiveInt() {
        assertEquals(1, ValidationUtil.parsePositiveInt("1"));
        assertEquals(42, ValidationUtil.parsePositiveInt(" 42 "));
        assertNull(ValidationUtil.parsePositiveInt("0"));
        assertNull(ValidationUtil.parsePositiveInt("-5"));
        assertNull(ValidationUtil.parsePositiveInt("1 OR 1=1"));
        assertNull(ValidationUtil.parsePositiveInt("abc"));
        assertNull(ValidationUtil.parsePositiveInt(null));
    }

    @Test
    @DisplayName("Should validate election status")
    public void testElectionStatus() {
        assertTrue(ValidationUtil.isValidElectionStatus("UPCOMING"));
        assertTrue(ValidationUtil.isValidElectionStatus("ACTIVE"));
        assertTrue(ValidationUtil.isValidElectionStatus("COMPLETED"));
        assertTrue(ValidationUtil.isValidElectionStatus("PUBLISHED"));
        assertFalse(ValidationUtil.isValidElectionStatus("DELETED"));
        assertFalse(ValidationUtil.isValidElectionStatus(null));
    }
}
