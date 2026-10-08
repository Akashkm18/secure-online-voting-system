package controller;

import dao.AuditLogDAO;
import dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;
import util.PasswordUtil;
import util.SecurityUtil;
import util.ValidationUtil;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Handles authentication for both Voters and Administrators.
 * Enforces dual-factor student verification requiring verified College ID Card scanning/matching.
 * Features rate-limiting / brute-force lockout, session regeneration,
 * and generic error reporting.
 */
@WebServlet(name = "LoginServlet", urlPatterns = {"/login", "/admin/login"})
public class LoginServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    // In-memory rate limiting tracker: IP -> [failedCount, lastAttemptEpochMs]
    private static final Map<String, long[]> ATTEMPT_TRACKER = new ConcurrentHashMap<>();
    private static final int MAX_ATTEMPTS = 5;
    private static final long LOCKOUT_DURATION_MS = 3 * 60 * 1000; // 3 minutes

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        if (uri.endsWith("/admin/login")) {
            resp.sendRedirect(req.getContextPath() + "/admin/login.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String ip = SecurityUtil.getClientIpAddress(req);
        String ua = SecurityUtil.getUserAgent(req);
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String collegeId = req.getParameter("collegeId");
        boolean isAdminPortal = req.getRequestURI().endsWith("/admin/login");

        // 1. Check rate limiting
        long now = System.currentTimeMillis();
        long[] attemptData = ATTEMPT_TRACKER.computeIfAbsent(ip, k -> new long[]{0, now});
        if (attemptData[0] >= MAX_ATTEMPTS) {
            long elapsed = now - attemptData[1];
            if (elapsed < LOCKOUT_DURATION_MS) {
                long remainingSeconds = (LOCKOUT_DURATION_MS - elapsed) / 1000;
                auditLogDAO.log(null, "LOGIN_RATE_LIMITED_IP_" + ip, ip, ua);
                forwardError(req, resp, isAdminPortal,
                        "Too many failed login attempts. Please wait " + remainingSeconds + " seconds before trying again.");
                return;
            } else {
                // Lockout expired, reset counter
                attemptData[0] = 0;
            }
        }

        // 2. Validate input format
        if (!ValidationUtil.isValidEmail(email) || password == null || password.isEmpty()) {
            recordFailedAttempt(ip, now, attemptData);
            auditLogDAO.log(null, "LOGIN_FAILED_INVALID_FORMAT", ip, ua);
            forwardError(req, resp, isAdminPortal, "Invalid email or password.");
            return;
        }

        // 3. For voter portal: require College ID Card
        if (!isAdminPortal) {
            if (collegeId == null || collegeId.trim().isEmpty()) {
                recordFailedAttempt(ip, now, attemptData);
                auditLogDAO.log(null, "LOGIN_FAILED_MISSING_COLLEGE_ID", ip, ua);
                forwardError(req, resp, false, "College ID Card scan/number is required to verify student identity.");
                return;
            }
        }

        // 4. Look up user
        User user = userDAO.findByEmail(email);

        // 5. Verify password and user existence
        if (user == null || !PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            recordFailedAttempt(ip, now, attemptData);
            auditLogDAO.log(user != null ? user.getId() : null, "LOGIN_FAILED_WRONG_CREDENTIALS", ip, ua);
            forwardError(req, resp, isAdminPortal, "Invalid email or password.");
            return;
        }

        // 6. Check if user account is disabled
        if (!user.isActive()) {
            auditLogDAO.log(user.getId(), "LOGIN_FAILED_INACTIVE_ACCOUNT", ip, ua);
            forwardError(req, resp, isAdminPortal, "Your account is deactivated. Please contact the administrator.");
            return;
        }

        // 7. If logging in via admin portal, verify role
        if (isAdminPortal && !user.isAdmin()) {
            recordFailedAttempt(ip, now, attemptData);
            auditLogDAO.log(user.getId(), "ADMIN_LOGIN_UNAUTHORIZED_ROLE", ip, ua);
            forwardError(req, resp, isAdminPortal, "Access denied. Administrator privileges required.");
            return;
        }

        // 8. For student voter login: Verify College ID Card matches the user account
        if (!isAdminPortal && !user.isAdmin()) {
            String registeredCollegeId = user.getCollegeId();
            if (registeredCollegeId != null && !registeredCollegeId.trim().equalsIgnoreCase(collegeId.trim())) {
                recordFailedAttempt(ip, now, attemptData);
                auditLogDAO.log(user.getId(), "LOGIN_FAILED_MISMATCHED_COLLEGE_ID_INPUT_" + collegeId, ip, ua);
                forwardError(req, resp, false, "Scanned College ID does not match the registered record for this student account (" + email + ").");
                return;
            }

            // Sync any extracted details / student photo from the scanner
            String submittedCollegeName = req.getParameter("collegeName");
            String submittedProgramName = req.getParameter("programName");
            String submittedJoiningYear = req.getParameter("joiningYear");
            String submittedStudyYear = req.getParameter("studyYear");
            String submittedPhotoBase64 = req.getParameter("photoBase64");

            Integer parsedJoiningYear = null;
            if (submittedJoiningYear != null && !submittedJoiningYear.trim().isEmpty()) {
                try {
                    parsedJoiningYear = Integer.parseInt(submittedJoiningYear.trim());
                } catch (NumberFormatException ignored) {}
            }

            boolean needsUpdate = false;
            String newColName = user.getCollegeName();
            String newProg = user.getProgramName();
            Integer newJoinYear = user.getJoiningYear();
            String newStudyYr = user.getStudyYear();
            String newPhoto = user.getPhotoBase64();

            if (submittedCollegeName != null && !submittedCollegeName.trim().isEmpty()) {
                newColName = submittedCollegeName.trim();
                needsUpdate = true;
            }
            if (submittedProgramName != null && !submittedProgramName.trim().isEmpty()) {
                newProg = submittedProgramName.trim();
                needsUpdate = true;
            }
            if (parsedJoiningYear != null) {
                newJoinYear = parsedJoiningYear;
                needsUpdate = true;
            }
            if (submittedStudyYear != null && !submittedStudyYear.trim().isEmpty()) {
                newStudyYr = submittedStudyYear.trim();
                needsUpdate = true;
            }
            if (submittedPhotoBase64 != null && !submittedPhotoBase64.trim().isEmpty()) {
                newPhoto = submittedPhotoBase64.trim();
                needsUpdate = true;
            }

            if (needsUpdate) {
                userDAO.updateStudentDetails(user.getId(), newColName, newProg, newJoinYear, newStudyYr, newPhoto);
                user.setCollegeName(newColName);
                user.setProgramName(newProg);
                user.setJoiningYear(newJoinYear);
                user.setStudyYear(newStudyYr);
                user.setPhotoBase64(newPhoto);
            }
        }

        // Login successful: reset failed attempt counter for this IP
        ATTEMPT_TRACKER.remove(ip);

        // 9. Session Fixation Protection: create or change session ID
        HttpSession session = req.getSession(true);
        req.changeSessionId();

        // Set session attributes
        session.setAttribute("user", user);
        session.setAttribute("userId", user.getId());
        session.setAttribute("userRole", user.getRole());
        session.setAttribute("userName", user.getFullName());
        session.setAttribute("collegeId", user.getCollegeId());
        session.setAttribute("collegeName", user.getCollegeName());
        session.setAttribute("programName", user.getProgramName());
        session.setAttribute("joiningYear", user.getJoiningYear());
        session.setAttribute("studyYear", user.getStudyYear());
        session.setAttribute("studentPhoto", user.getPhotoBase64());
        session.setMaxInactiveInterval(30 * 60); // 30 minutes session timeout

        // 10. Log success audit event with College ID verification
        auditLogDAO.log(user.getId(), "LOGIN_SUCCESS_COLLEGE_ID_" + (user.getCollegeId() != null ? user.getCollegeId() : "ADMIN"), ip, ua);

        // 11. Redirect appropriately
        if (user.isAdmin()) {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard.jsp");
        } else {
            resp.sendRedirect(req.getContextPath() + "/dashboard.jsp");
        }
    }

    private void recordFailedAttempt(String ip, long now, long[] attemptData) {
        attemptData[0]++;
        attemptData[1] = now;
        ATTEMPT_TRACKER.put(ip, attemptData);
    }

    private void forwardError(HttpServletRequest req, HttpServletResponse resp, boolean isAdminPortal, String errorMsg)
            throws ServletException, IOException {
        req.setAttribute("errorMessage", errorMsg);
        String forwardPath = isAdminPortal ? "/admin/login.jsp" : "/login.jsp";
        req.getRequestDispatcher(forwardPath).forward(req, resp);
    }
}
