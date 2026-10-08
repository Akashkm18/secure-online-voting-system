package controller;

import dao.AuditLogDAO;
import dao.CandidateDAO;
import dao.ElectionDAO;
import dao.UserDAO;
import dao.VoteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.AuditLog;
import model.User;
import util.PasswordUtil;
import util.SecurityUtil;
import util.ValidationUtil;

import java.io.IOException;
import java.util.List;

/**
 * Controller for Admin dashboard statistics, voter management, and audit log inspection.
 */
@WebServlet(name = "AdminServlet", urlPatterns = {
        "/admin/dashboard",
        "/admin/voters",
        "/admin/audit-logs",
        "/admin/action"
})
public class AdminServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ElectionDAO electionDAO = new ElectionDAO();
    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final VoteDAO voteDAO = new VoteDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();

        if (uri.endsWith("/admin/dashboard")) {
            populateDashboardMetrics(req);
            req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
        } else if (uri.endsWith("/admin/voters")) {
            List<User> voters = userDAO.getAllVoters();
            req.setAttribute("voters", voters);
            req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);
        } else if (uri.endsWith("/admin/audit-logs")) {
            List<AuditLog> logs = auditLogDAO.getRecentLogs(100);
            req.setAttribute("auditLogs", logs);
            req.getRequestDispatcher("/admin/audit-logs.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null || !user.isAdmin()) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Admin privileges required.");
            return;
        }

        String action = req.getParameter("action");
        String ip = SecurityUtil.getClientIpAddress(req);
        String ua = SecurityUtil.getUserAgent(req);

        if ("addVoter".equalsIgnoreCase(action)) {
            handleAddVoter(req, resp, user, ip, ua);
        } else if ("toggleVoterStatus".equalsIgnoreCase(action)) {
            handleToggleVoterStatus(req, resp, user, ip, ua);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/dashboard");
        }
    }

    private void populateDashboardMetrics(HttpServletRequest req) {
        req.setAttribute("totalVoters", userDAO.countTotalVoters());
        req.setAttribute("totalCandidates", candidateDAO.countTotal());
        req.setAttribute("activeElectionsCount", electionDAO.countByStatus("ACTIVE"));
        req.setAttribute("completedElectionsCount", electionDAO.countByStatus("COMPLETED") + electionDAO.countByStatus("PUBLISHED"));
        req.setAttribute("totalVotesCount", voteDAO.getTotalVotesCount());
        req.setAttribute("recentAuditLogs", auditLogDAO.getRecentLogs(10));
        req.setAttribute("allElections", electionDAO.getAllElections());
    }

    private void handleAddVoter(HttpServletRequest req, HttpServletResponse resp, User adminUser, String ip, String ua)
            throws ServletException, IOException {

        String fullName = req.getParameter("fullName");
        String email = req.getParameter("email");
        String collegeId = req.getParameter("collegeId");
        String password = req.getParameter("password");

        if (!ValidationUtil.isValidName(fullName) || !ValidationUtil.isValidEmail(email)
                || !ValidationUtil.isValidCollegeId(collegeId) || !ValidationUtil.isValidPassword(password)) {
            req.setAttribute("errorMessage", "Invalid voter data. Check name, valid email, College ID format, and password length (min 6).");
            List<User> voters = userDAO.getAllVoters();
            req.setAttribute("voters", voters);
            req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);
            return;
        }

        if (userDAO.findByEmail(email) != null) {
            req.setAttribute("errorMessage", "A user with this email address already exists.");
            List<User> voters = userDAO.getAllVoters();
            req.setAttribute("voters", voters);
            req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);
            return;
        }

        if (userDAO.findByCollegeId(collegeId) != null) {
            req.setAttribute("errorMessage", "A voter with this College ID already exists.");
            List<User> voters = userDAO.getAllVoters();
            req.setAttribute("voters", voters);
            req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);
            return;
        }

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

        User newVoter = new User();
        newVoter.setFullName(fullName.trim());
        newVoter.setEmail(email.trim().toLowerCase());
        newVoter.setCollegeId(collegeId.trim().toUpperCase());
        newVoter.setCollegeName(collegeName != null && !collegeName.trim().isEmpty() ? collegeName.trim() : "Alliance University");
        newVoter.setProgramName(programName != null && !programName.trim().isEmpty() ? programName.trim() : "B.Tech Computer Science & Engineering");
        newVoter.setJoiningYear(joiningYear != null ? joiningYear : 2024);
        newVoter.setStudyYear(studyYear != null && !studyYear.trim().isEmpty() ? studyYear.trim() : "2nd Year");
        newVoter.setPasswordHash(PasswordUtil.hashPassword(password));
        newVoter.setRole("VOTER");
        newVoter.setVerified(true);
        newVoter.setActive(true);

        boolean created = userDAO.createUser(newVoter);
        if (created) {
            auditLogDAO.log(adminUser.getId(), "ADMIN_ADDED_VOTER_" + newVoter.getId() + "_COLLEGE_ID_" + newVoter.getCollegeId(), ip, ua);
            resp.sendRedirect(req.getContextPath() + "/admin/voters?success=voter_added");
        } else {
            req.setAttribute("errorMessage", "Database error occurred while adding voter.");
            List<User> voters = userDAO.getAllVoters();
            req.setAttribute("voters", voters);
            req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);
        }
    }

    private void handleToggleVoterStatus(HttpServletRequest req, HttpServletResponse resp, User adminUser, String ip, String ua)
            throws IOException {

        Integer voterId = ValidationUtil.parsePositiveInt(req.getParameter("voterId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        if (voterId != null) {
            userDAO.updateActiveStatus(voterId, active);
            auditLogDAO.log(adminUser.getId(), "ADMIN_SET_VOTER_ACTIVE_" + voterId + "_TO_" + active, ip, ua);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/voters?success=status_updated");
    }
}
