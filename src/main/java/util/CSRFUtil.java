package util;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;

/**
 * Utility for Cross-Site Request Forgery (CSRF) token generation and validation.
 */
public class CSRFUtil {

    public static final String CSRF_PARAM_NAME = "_csrf";
    public static final String CSRF_SESSION_ATTR = "_csrf_token";
    private static final SecureRandom RANDOM = new SecureRandom();

    /**
     * Retrieves existing token or creates and stores a new one in user session.
     */
    public static String getToken(HttpServletRequest request) {
        HttpSession session = request.getSession(true);
        String token = (String) session.getAttribute(CSRF_SESSION_ATTR);
        if (token == null || token.trim().isEmpty()) {
            token = generateNewToken();
            session.setAttribute(CSRF_SESSION_ATTR, token);
        }
        return token;
    }

    /**
     * Validates submitted token against session token using constant-time comparison.
     */
    public static boolean isValid(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) {
            return false;
        }

        String sessionToken = (String) session.getAttribute(CSRF_SESSION_ATTR);
        if (sessionToken == null || sessionToken.trim().isEmpty()) {
            return false;
        }

        String submittedToken = request.getParameter(CSRF_PARAM_NAME);
        if (submittedToken == null || submittedToken.trim().isEmpty()) {
            // Also check standard CSRF header X-CSRF-TOKEN
            submittedToken = request.getHeader("X-CSRF-TOKEN");
        }

        if (submittedToken == null || submittedToken.trim().isEmpty()) {
            return false;
        }

        return MessageDigest.isEqual(
                sessionToken.getBytes(StandardCharsets.UTF_8),
                submittedToken.getBytes(StandardCharsets.UTF_8)
        );
    }

    private static String generateNewToken() {
        byte[] buffer = new byte[32];
        RANDOM.nextBytes(buffer);
        return Base64.getUrlEncoder().withoutPadding().encodeToString(buffer);
    }
}
