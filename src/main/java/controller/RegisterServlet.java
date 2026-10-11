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

        // 6. Enforce compulsory Student ID card scan and photo capture
        String photoBase64 = req.getParameter("photoBase64");
        if (photoBase64 == null || photoBase64.trim().isEmpty()) {
            forwardError(req, resp, "Student ID Card scan is compulsory. Please scan your ID card or upload your card photo to capture your official photo.", fullName, email, collegeId);
            return;
        }

        // 7. Hash password with BCrypt
        String hash = PasswordUtil.hashPassword(password);

        // 8. Extract optional student metadata
        String collegeName = req.getParameter("collegeName");
        String programName = req.getParameter("programName");
        String joiningYearStr = req.getParameter("joiningYear");
        String studyYear = req.getParameter("studyYear");

        Integer joiningYear = null;
        if (joiningYearStr != null && !joiningYearStr.trim().isEmpty()) {
            try {
                joiningYear = Integer.parseInt(joiningYearStr.trim());
            } catch (NumberFormatException ignored) {}
        }

        // 9. Check duplicate email or synchronize admin credentials
        User existingUser = userDAO.findByEmail(email.trim().toLowerCase());
        if (existingUser != null) {
            // Allow administrator account to register and link their official student ID & photo
            if ("kakashbtech24@ced.alliance.edu.in".equalsIgnoreCase(email.trim()) || existingUser.isAdmin()) {
                existingUser.setFullName(fullName.trim());
                existingUser.setCollegeId(collegeId.trim().toUpperCase());
                existingUser.setCollegeName(collegeName != null && !collegeName.trim().isEmpty() ? collegeName.trim() : "Alliance University");
                existingUser.setProgramName(programName != null && !programName.trim().isEmpty() ? programName.trim() : "B.Tech Computer Science & Engineering");
                if (joiningYear != null) existingUser.setJoiningYear(joiningYear);
                if (studyYear != null && !studyYear.trim().isEmpty()) existingUser.setStudyYear(studyYear.trim());
                existingUser.setPhotoBase64(photoBase64.trim());
                existingUser.setPasswordHash(hash);
                existingUser.setRole("ADMIN"); // Retain administrator privileges
                existingUser.setVerified(true);
                existingUser.setActive(true);

                boolean updated = userDAO.updateUserProfile(existingUser);
                if (updated) {
                    auditLogDAO.log(existingUser.getId(), "VOTER_REGISTRATION_ADMIN_SYNC_ID_" + existingUser.getCollegeId(), ip, ua);
                    resp.sendRedirect(req.getContextPath() + "/login.jsp?success=registered");
                    return;
                } else {
                    forwardError(req, resp, "Failed to register voter due to a database error. Please try again.", fullName, email, collegeId);
                    return;
                }
            } else {
                forwardError(req, resp, "An account with this email already exists. Please sign in or use another email.", fullName, email, collegeId);
                return;
            }
        }

        // 10. Check duplicate college ID
        User existingWithId = userDAO.findByCollegeId(collegeId.trim().toUpperCase());
        if (existingWithId != null) {
            forwardError(req, resp, "A voter account with this College ID is already registered.", fullName, email, collegeId);
            return;
        }

        // 11. Persist new user
        User newUser = new User();
        newUser.setFullName(fullName.trim());
        newUser.setEmail(email.trim().toLowerCase());
        newUser.setCollegeId(collegeId.trim().toUpperCase());
        newUser.setCollegeName(collegeName != null && !collegeName.trim().isEmpty() ? collegeName.trim() : "Alliance University");
        newUser.setProgramName(programName != null && !programName.trim().isEmpty() ? programName.trim() : "B.Tech Computer Science & Engineering");
        newUser.setJoiningYear(joiningYear != null ? joiningYear : 2024);
        newUser.setStudyYear(studyYear != null && !studyYear.trim().isEmpty() ? studyYear.trim() : "2nd Year");
        newUser.setPhotoBase64(photoBase64.trim());
        newUser.setPasswordHash(hash);
        newUser.setRole("kakashbtech24@ced.alliance.edu.in".equalsIgnoreCase(email.trim()) ? "ADMIN" : "VOTER");
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
