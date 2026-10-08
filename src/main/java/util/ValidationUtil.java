package util;

import java.util.regex.Pattern;

/**
 * Server-side input validation utility.
 * Protects against invalid formats, boundary overflows, and malformed parameters.
 */
public class ValidationUtil {

    private static final Pattern EMAIL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,63}$"
    );

    private static final Pattern NAME_PATTERN = Pattern.compile(
            "^[A-Za-z0-9\\s.'-]{2,100}$"
    );

    private static final Pattern SYMBOL_PATTERN = Pattern.compile(
            "^[A-Za-z0-9\\s.'-]{2,50}$"
    );

    private static final Pattern COLLEGE_ID_PATTERN = Pattern.compile(
            "^[A-Za-z0-9/._-]{3,50}$"
    );

    public static boolean isValidCollegeId(String collegeId) {
        if (collegeId == null) return false;
        String trimmed = collegeId.trim();
        return trimmed.length() >= 3 && trimmed.length() <= 50 && COLLEGE_ID_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidEmail(String email) {
        if (email == null) return false;
        String trimmed = email.trim();
        return trimmed.length() <= 150 && EMAIL_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidName(String name) {
        if (name == null) return false;
        String trimmed = name.trim();
        return trimmed.length() >= 2 && trimmed.length() <= 100 && NAME_PATTERN.matcher(trimmed).matches();
    }

    public static boolean isValidPassword(String password) {
        if (password == null) return false;
        // At least 6 characters (college micro-project friendly), max 128
        return password.length() >= 6 && password.length() <= 128;
    }

    public static boolean isValidPartyOrSymbol(String text) {
        if (text == null) return false;
        String trimmed = text.trim();
        return trimmed.length() >= 2 && trimmed.length() <= 100 && SYMBOL_PATTERN.matcher(trimmed).matches();
    }

    public static Integer parsePositiveInt(String input) {
        if (input == null || input.trim().isEmpty()) {
            return null;
        }
        try {
            int value = Integer.parseInt(input.trim());
            return value > 0 ? value : null;
        } catch (NumberFormatException e) {
            return null;
        }
    }

    public static boolean isValidElectionStatus(String status) {
        if (status == null) return false;
        return "UPCOMING".equalsIgnoreCase(status)
                || "ACTIVE".equalsIgnoreCase(status)
                || "COMPLETED".equalsIgnoreCase(status)
                || "PUBLISHED".equalsIgnoreCase(status);
    }
}
