package util;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

public class SecurityUtilTest {

    @Test
    @DisplayName("Should escape dangerous HTML characters to prevent XSS")
    public void testEscapeHtml() {
        String xssPayload = "<script>alert('pwned')</script>";
        String escaped = SecurityUtil.escapeHtml(xssPayload);
        assertEquals("&lt;script&gt;alert(&#x27;pwned&#x27;)&lt;&#x2F;script&gt;", escaped);

        String attrBreakout = "\" onmouseover=\"alert(1)";
        String escapedAttr = SecurityUtil.escapeHtml(attrBreakout);
        assertEquals("&quot; onmouseover=&quot;alert(1)", escapedAttr);
    }

    @Test
    @DisplayName("Should generate deterministic and unique SHA-256 vote receipts")
    public void testGenerateVoteHash() {
        long timestamp = 1700000000000L;
        String hash1 = SecurityUtil.generateVoteHash(10, 1, 2, timestamp);
        String hash2 = SecurityUtil.generateVoteHash(10, 1, 2, timestamp);
        String hash3 = SecurityUtil.generateVoteHash(11, 1, 2, timestamp);

        assertNotNull(hash1);
        assertEquals(64, hash1.length()); // SHA-256 hex string length
        assertEquals(hash1, hash2, "Identical inputs must produce identical hash");
        assertNotEquals(hash1, hash3, "Different voter ID must produce different receipt");
    }
}
