package util;

import at.favre.lib.crypto.bcrypt.BCrypt;

/**
 * Utility for BCrypt password hashing and verification.
 * Adheres to college project security guidelines: cost factor 12.
 */
public class PasswordUtil {

    private static final int COST = 12;

    /**
     * Hashes plain text password using BCrypt.
     * @param plainPassword Raw password
     * @return Formatted BCrypt hash string
     */
    public static String hashPassword(String plainPassword) {
        if (plainPassword == null || plainPassword.isEmpty()) {
            throw new IllegalArgumentException("Password cannot be null or empty.");
        }
        return BCrypt.withDefaults().hashToString(COST, plainPassword.toCharArray());
    }

    /**
     * Verifies plain text password against stored BCrypt hash.
     * @param plainPassword Raw password
     * @param storedHash Stored BCrypt hash
     * @return True if matches, false otherwise
     */
    public static boolean verifyPassword(String plainPassword, String storedHash) {
        if (plainPassword == null || storedHash == null || storedHash.isEmpty()) {
            return false;
        }
        try {
            BCrypt.Result result = BCrypt.verifyer().verify(plainPassword.toCharArray(), storedHash);
            return result.verified;
        } catch (Exception e) {
            return false;
        }
    }
}
