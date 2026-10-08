package util;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.logging.Level;
import java.util.logging.Logger;

public class Msg91Util {
    private static final Logger LOGGER = Logger.getLogger(Msg91Util.class.getName());

    // =========================================================================
    // TODO: MSG91 CONFIGURATION REQUIRED HERE
    // You must provide your MSG91 Auth Key and Template ID.
    // =========================================================================
    private static final String AUTH_KEY = "563686A8KqS22eq6a8b38afP1";
    private static final String TEMPLATE_ID = "366877726155323838303734";

    public static boolean sendSmsOtp(String mobileNumber, String otp) {
        try {
            URL url = new URL("https://control.msg91.com/api/v5/otp");
            HttpURLConnection conn = (HttpURLConnection) url.openConnection();
            conn.setRequestMethod("POST");
            conn.setRequestProperty("authkey", AUTH_KEY);
            conn.setRequestProperty("Content-Type", "application/json");
            conn.setDoOutput(true);

            // Construct JSON Payload for MSG91 OTP API (SMS)
            // Ensure the mobile number includes the country code (e.g., 91 for India)
            String jsonPayload = String.format(
                "{\"template_id\":\"%s\",\"mobile\":\"%s\",\"otp\":\"%s\"}",
                TEMPLATE_ID, mobileNumber, otp
            );

            // Send payload
            try (OutputStream os = conn.getOutputStream()) {
                byte[] input = jsonPayload.getBytes(StandardCharsets.UTF_8);
                os.write(input, 0, input.length);
            }

            int responseCode = conn.getResponseCode();
            if (responseCode >= 200 && responseCode < 300) {
                LOGGER.info("MSG91 SMS OTP successfully sent to: " + mobileNumber);
                return true;
            } else {
                LOGGER.severe("MSG91 API Failed with Response Code: " + responseCode);
                return false;
            }

        } catch (Exception e) {
            LOGGER.log(Level.SEVERE, "Failed to connect to MSG91 API", e);
            return false;
        }
    }
}
