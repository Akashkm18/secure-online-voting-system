package controller;

import dao.AuditLogDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.User;
import util.PasswordUtil;
import util.SecurityUtil;
import util.ValidationUtil;

import java.io.IOException;

/**
 * Handles new voter registration with College ID card validation.
 * Performs rigorous server-side validation and BCrypt password encryption.
 */
@WebServlet(name = "RegisterServlet", urlPatterns = "/register")
public class RegisterServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.sendRedirect(req.getContextPath() + "/register.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ip = SecurityUtil.getClientIpAddress(req);
        String ua = SecurityUtil.getUserAgent(req);

        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String collegeId = req.getParameter("collegeId");
        String password = req.getParameter("password");
        String confirmPassword = req.getParameter("confirmPassword");

        // 1. Validate full name
        if (!ValidationUtil.isValidName(fullName)) {
            forwardError(req, resp, "Full Name must be between 2 and 100 characters (letters, spaces, dots, hyphens only).", fullName, email, collegeId);
            return;
        }

        // 2. Validate email format
        if (!ValidationUtil.isValidEmail(email)) {
            forwardError(req, resp, "Please provide a valid email address.", fullName, email, collegeId);
            return;
        }

        // 3. Validate College ID format
        if (!ValidationUtil.isValidCollegeId(collegeId)) {
            forwardError(req, resp, "Please provide a valid College ID Card number (e.g., ALU-2026-1001 or AU2024CS014).", fullName, email, collegeId);
            return;
        }

        // 4. Validate password strength
        if (!ValidationUtil.isValidPassword(password)) {
            forwardError(req, resp, "Password must be at least 6 characters long.", fullName, email, collegeId);
            return;
        }

        // 5. Validate password confirmation
        if (!password.equals(confirmPassword)) {
            forwardError(req, resp, "Passwords do not match.", fullName, email, collegeId);
            return;
        }

        // 6. Check duplicate email
        if (userDAO.findByEmail(email) != null) {
            forwardError(req, resp, "An account with this email already exists. Please sign in or use another email.", fullName, email, collegeId);
            return;
        }

        // 7. Check duplicate college ID
        if (userDAO.findByCollegeId(collegeId) != null) {
            forwardError(req, resp, "A voter account with this College ID is already registered.", fullName, email, collegeId);
            return;
        }

        // 8. Hash password with BCrypt
        String hash = PasswordUtil.hashPassword(password);

        // 9. Persist user
        String collegeName = req.getParameter("collegeName");
        String programName = req.getParameter("programName");
        String joiningYearStr = req.getParameter("joiningYear");
        String studyYear = req.getParameter("studyYear");
        String photoBase64 = req.getParameter("photoBase64");

        Integer joiningYear = null;
        if (joiningYearStr != null && !joiningYearStr.trim().isEmpty()) {
            try {
                joiningYear = Integer.parseInt(joiningYearStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        User newUser = new User();
        newUser.setFullName(fullName.trim());
        newUser.setEmail(email.trim().toLowerCase());
        newUser.setCollegeId(collegeId.trim().toUpperCase());
        newUser.setCollegeName(collegeName != null && !collegeName.trim().isEmpty() ? collegeName.trim() : "Alliance University");
        newUser.setProgramName(programName != null && !programName.trim().isEmpty() ? programName.trim() : "B.Tech Computer Science & Engineering");
        newUser.setJoiningYear(joiningYear != null ? joiningYear : 2024);
        newUser.setStudyYear(studyYear != null && !studyYear.trim().isEmpty() ? studyYear.trim() : "2nd Year");
        newUser.setPhotoBase64(photoBase64);
        newUser.setPasswordHash(hash);
        newUser.setRole("VOTER");
        newUser.setVerified(true);
        newUser.setActive(true);

        boolean created = userDAO.createUser(newUser);
        if (created) {
            auditLogDAO.log(newUser.getId(), "VOTER_REGISTRATION_SUCCESS_ID_" + newUser.getCollegeId(), ip, ua);
            resp.sendRedirect(req.getContextPath() + "/login.jsp?success=registered");
        } else {
            forwardError(req, resp, "Failed to register voter due to a database error. Please try again.", fullName, email, collegeId);
        }
    }

    private void forwardError(HttpServletRequest req, HttpServletResponse resp, String msg, String fullName, String email, String collegeId)
            throws ServletException, IOException {
        req.setAttribute("errorMessage", msg);
        req.setAttribute("fullName", fullName);
        req.setAttribute("email", email);
        req.setAttribute("collegeId", collegeId);
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }
}
