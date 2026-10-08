package util;

import jakarta.servlet.http.HttpServletRequest;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.HexFormat;

/**
 * Security helper methods including IP resolution, vote cryptographic hashing,
 * and HTML escaping for XSS prevention.
 */
public class SecurityUtil {

    private static final String SALT = "SECURE_VOTING_SECRET_SALT_2026";

    /**
     * Resolves the real IP address of the client, checking reverse proxy headers.
     */
    public static String getClientIpAddress(HttpServletRequest request) {
        if (request == null) return "0.0.0.0";

        String[] headers = {
                "X-Forwarded-For",
                "Proxy-Client-IP",
                "WL-Proxy-Client-IP",
                "HTTP_CLIENT_IP",
                "HTTP_X_FORWARDED_FOR"
        };

        for (String header : headers) {
            String ip = request.getHeader(header);
            if (ip != null && !ip.isEmpty() && !"unknown".equalsIgnoreCase(ip)) {
                // If forwarded through multiple proxies, take first IP
                if (ip.contains(",")) {
                    ip = ip.split(",")[0].trim();
                }
                return sanitizeIp(ip);
            }
        }

        return sanitizeIp(request.getRemoteAddr());
    }

    private static String sanitizeIp(String ip) {
        if (ip == null) return "unknown";
        // IPv6 localhost loopback format
        if ("0:0:0:0:0:0:0:1".equals(ip) || "::1".equals(ip)) {
            return "127.0.0.1";
        }
        return ip.length() > 45 ? ip.substring(0, 45) : ip;
    }

    /**
     * Safely reads User-Agent header, truncated to database column length.
     */
    public static String getUserAgent(HttpServletRequest request) {
        if (request == null) return "Unknown";
        String ua = request.getHeader("User-Agent");
        if (ua == null || ua.trim().isEmpty()) {
            return "Unknown";
        }
        return ua.length() > 250 ? ua.substring(0, 250) : ua;
    }

    /**
     * Generates a tamper-evident SHA-256 cryptographic receipt hash for each vote.
     */
    public static String generateVoteHash(int voterId, int electionId, int candidateId, long timestamp) {
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            String raw = voterId + ":" + electionId + ":" + candidateId + ":" + timestamp + ":" + SALT;
            byte[] hash = digest.digest(raw.getBytes(StandardCharsets.UTF_8));
            return HexFormat.of().formatHex(hash);
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException("SHA-256 algorithm unavailable", e);
        }
    }

    /**
     * Escapes critical HTML characters to prevent XSS injection.
     */
    public static String escapeHtml(String input) {
        if (input == null) return "";
        StringBuilder sb = new StringBuilder(input.length());
        for (int i = 0; i < input.length(); i++) {
            char c = input.charAt(i);
            switch (c) {
                case '&':  sb.append("&amp;"); break;
                case '<':  sb.append("&lt;"); break;
                case '>':  sb.append("&gt;"); break;
                case '"':  sb.append("&quot;"); break;
                case '\'': sb.append("&#x27;"); break;
                case '/':  sb.append("&#x2F;"); break;
                default:   sb.append(c); break;
            }
        }
        return sb.toString();
    }
}
