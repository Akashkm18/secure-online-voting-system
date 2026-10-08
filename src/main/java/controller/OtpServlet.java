package controller;

import dao.UserDAO;
import model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Random;
import java.util.logging.Logger;

@WebServlet("/send-otp")
public class OtpServlet extends HttpServlet {
    private static final Logger LOGGER = Logger.getLogger(OtpServlet.class.getName());
    private final UserDAO userDao = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String collegeId = req.getParameter("collegeId");

        resp.setContentType("application/json");
        PrintWriter out = resp.getWriter();

        String mobileNumber = req.getParameter("mobileNumber");

        if (email == null || collegeId == null || mobileNumber == null || email.trim().isEmpty() || collegeId.trim().isEmpty() || mobileNumber.trim().isEmpty()) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"Email, College ID, and Mobile Number are required.\"}");
            return;
        }

        User user = userDao.findByEmail(email);
        if (user == null || !user.getCollegeId().equalsIgnoreCase(collegeId.trim())) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"success\": false, \"message\": \"No matching user found for this Email and College ID.\"}");
            return;
        }

        // Generate 6-digit OTP
        String otp = String.format("%06d", new Random().nextInt(999999));
        
        // Store OTP in session
        HttpSession session = req.getSession();
        session.setAttribute("reset_otp", otp);
        session.setAttribute("reset_email", email.trim().toLowerCase());
        session.setAttribute("reset_college_id", collegeId.trim().toUpperCase());
        session.setMaxInactiveInterval(300); // 5 minutes expiration

        // SEND REAL SMS OTP USING MSG91
        boolean otpSent = util.Msg91Util.sendSmsOtp(mobileNumber.trim(), otp);

        if (otpSent) {
            LOGGER.info("MSG91 SMS OTP generated and sent to " + mobileNumber);
            out.print("{\"success\": true, \"message\": \"A 6-digit OTP has been sent via SMS to " + mobileNumber + ".\"}");
        } else {
            LOGGER.severe("Failed to send real OTP via MSG91 to " + mobileNumber);
            out.print("{\"success\": false, \"message\": \"Server failed to send the OTP. Please ask the administrator to configure the MSG91 API credentials.\"}");
        }
    }
}
