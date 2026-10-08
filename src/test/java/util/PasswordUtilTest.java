package util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class PasswordUtilTest {

    @Test
    @DisplayName("Should successfully hash and verify password with BCrypt")
    public void testHashAndVerifySuccess() {
        String password = "VoterSecurePass#2026";
        String hash = PasswordUtil.hashPassword(password);

        assertNotNull(hash);
        assertTrue(hash.startsWith("$2a$") || hash.startsWith("$2b$") || hash.startsWith("$2y$"));
        assertTrue(PasswordUtil.verifyPassword(password, hash));
    }

    @Test
    @DisplayName("Should reject incorrect password")
    public void testWrongPasswordRejected() {
        String password = "CorrectPassword123";
        String hash = PasswordUtil.hashPassword(password);

        assertFalse(PasswordUtil.verifyPassword("WrongPassword123", hash));
        assertFalse(PasswordUtil.verifyPassword("", hash));
        assertFalse(PasswordUtil.verifyPassword(null, hash));
    }

    @Test
    @DisplayName("Should reject hashing null or empty password")
    public void testNullOrEmptyPassword() {
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(null));
        assertThrows(IllegalArgumentException.class, () -> PasswordUtil.hashPassword(""));
    }
}
