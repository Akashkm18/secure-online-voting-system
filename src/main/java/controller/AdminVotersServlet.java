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
import java.io.PrintWriter;
import java.security.SecureRandom;
import java.util.List;
import java.util.Map;

/**
 * Controller for Voters Registry management.
 * URL: /admin/voters
 */
@WebServlet(name = "AdminVotersServlet", urlPatterns = "/admin/voters")
public class AdminVotersServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();
    private static final SecureRandom RANDOM = new SecureRandom();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("q");
        String status = req.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        // CSV Export handling
        if ("csv".equalsIgnoreCase(req.getParameter("export"))) {
            handleCsvExport(req, resp, search, status);
            return;
        }

        // Voter detail inspection modal / parameter
        Integer detailId = ValidationUtil.parsePositiveInt(req.getParameter("detailId"));
        if (detailId != null) {
            User detailUser = userDAO.findById(detailId);
            if (detailUser != null) {
                List<Map<String, Object>> participation = userDAO.getVoterElectionParticipation(detailId);
                req.setAttribute("voterDetail", detailUser);
                req.setAttribute("voterParticipation", participation);
            }
        }

        int page = 1;
        int pageSize = 15;
        try {
            String pStr = req.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr.trim()));
        } catch (NumberFormatException ignored) {}

        int offset = (page - 1) * pageSize;
        int totalItems = userDAO.countVotersFiltered(search, status);
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);

        List<User> voters = userDAO.getVotersFiltered(search, status, offset, pageSize);

        req.setAttribute("voters", voters);
        req.setAttribute("searchQuery", search != null ? search : "");
        req.setAttribute("currentStatus", status);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalItems", totalItems);

        // Status counts for registry badges
        req.setAttribute("pendingCount", userDAO.countVotersByStatus("PENDING"));
        req.setAttribute("approvedCount", userDAO.countVotersByStatus("APPROVED"));
        req.setAttribute("rejectedCount", userDAO.countVotersByStatus("REJECTED"));
        req.setAttribute("disabledCount", userDAO.countVotersByStatus("DISABLED"));

        req.setAttribute("activeNav", "voters");
        handleFlashMessages(req);

        req.getRequestDispatcher("/admin/voters.jsp").forward(req, resp);
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
        Integer voterId = ValidationUtil.parsePositiveInt(req.getParameter("voterId"));
        String ip = SecurityUtil.getClientIpAddress(req);
        String ua = SecurityUtil.getUserAgent(req);

        if (voterId == null) {
            session.setAttribute("flashError", "Invalid voter ID.");
            resp.sendRedirect(req.getContextPath() + "/admin/voters");
            return;
        }

        if ("approve".equalsIgnoreCase(action)) {
            handleApprove(voterId, session, user, ip, ua);
        } else if ("reject".equalsIgnoreCase(action)) {
            handleReject(req, voterId, session, user, ip, ua);
        } else if ("toggleStatus".equalsIgnoreCase(action)) {
            handleToggleStatus(voterId, session, user, ip, ua);
        } else if ("resetPassword".equalsIgnoreCase(action)) {
            handleResetPassword(voterId, session, user, ip, ua);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDelete(voterId, session, user, ip, ua);
        } else {
            session.setAttribute("flashError", "Unrecognized voter action.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/voters");
    }

    private void handleApprove(int voterId, HttpSession session, User adminUser, String ip, String ua) {
        boolean ok = userDAO.updateUserStatus(voterId, "APPROVED", null);
        if (ok) {
            auditLogDAO.log(adminUser.getId(), "VOTER_APPROVED_ID_" + voterId, ip, ua);
            session.setAttribute("flashSuccess", "Voter ID " + voterId + " has been approved successfully.");
        } else {
            session.setAttribute("flashError", "Failed to approve voter.");
        }
    }

    private void handleReject(HttpServletRequest req, int voterId, HttpSession session, User adminUser, String ip, String ua) {
        String reason = req.getParameter("rejectionReason");
        if (reason == null || reason.trim().isEmpty()) {
            reason = "Document verification requirements were not met.";
        }

        boolean ok = userDAO.updateUserStatus(voterId, "REJECTED", reason.trim());
        if (ok) {
            auditLogDAO.log(adminUser.getId(), "VOTER_REJECTED_ID_" + voterId + "_REASON_" + reason.trim(), ip, ua);
            session.setAttribute("flashSuccess", "Voter ID " + voterId + " status marked as REJECTED.");
        } else {
            session.setAttribute("flashError", "Failed to reject voter.");
        }
    }

    private void handleToggleStatus(int voterId, HttpSession session, User adminUser, String ip, String ua) {
        User target = userDAO.findById(voterId);
        if (target == null) {
            session.setAttribute("flashError", "Voter not found.");
            return;
        }

        boolean currentActive = target.isActive();
        String nextStatus = currentActive ? "DISABLED" : "APPROVED";
        boolean ok = userDAO.updateUserStatus(voterId, nextStatus, null);
        if (ok) {
            auditLogDAO.log(adminUser.getId(), "VOTER_STATUS_TOGGLED_ID_" + voterId + "_TO_" + nextStatus, ip, ua);
            session.setAttribute("flashSuccess", "Voter ID " + voterId + " status updated to " + nextStatus + ".");
        } else {
            session.setAttribute("flashError", "Failed to update voter status.");
        }
    }

    private void handleResetPassword(int voterId, HttpSession session, User adminUser, String ip, String ua) {
        // Generate a cryptographically secure 8-character temporary password
        String characters = "ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnpqrstuvwxyz23456789!@#$";
        StringBuilder sb = new StringBuilder("AU-Temp@");
        for (int i = 0; i < 4; i++) {
            sb.append(characters.charAt(RANDOM.nextInt(characters.length())));
        }
        String tempPass = sb.toString();
        String hash = PasswordUtil.hashPassword(tempPass);

        boolean ok = userDAO.resetPasswordWithFlag(voterId, hash);
        if (ok) {
            auditLogDAO.log(adminUser.getId(), "VOTER_PASSWORD_RESET_ID_" + voterId, ip, ua);
            session.setAttribute("flashSuccess", "Temporary password generated: <strong>" + tempPass + "</strong> (User will be required to change password on login). Copy and share securely.");
        } else {
            session.setAttribute("flashError", "Failed to reset password for voter ID " + voterId);
        }
    }

    private void handleDelete(int voterId, HttpSession session, User adminUser, String ip, String ua) {
        if (userDAO.hasUserVotedAnyElection(voterId)) {
            session.setAttribute("flashError", "Cannot delete voter ID " + voterId + " because they have already cast votes in one or more elections.");
            return;
        }

        boolean ok = userDAO.deleteVoter(voterId);
        if (ok) {
            auditLogDAO.log(adminUser.getId(), "VOTER_DELETED_ID_" + voterId, ip, ua);
            session.setAttribute("flashSuccess", "Voter removed successfully.");
        } else {
            session.setAttribute("flashError", "Failed to delete voter.");
        }
    }

    private void handleCsvExport(HttpServletRequest req, HttpServletResponse resp, String search, String status) throws IOException {
        List<User> list = userDAO.getVotersFiltered(search, status, 0, 5000);

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"voters-registry.csv\"");
        resp.setHeader("X-Content-Type-Options", "nosniff");

        PrintWriter writer = resp.getWriter();
        writer.println("ID,Full Name,Email,College ID,Program,Status,Has Voted,Registered At");

        for (User u : list) {
            writer.printf("\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"%n",
                    u.getId(),
                    escapeCsv(u.getFullName()),
                    escapeCsv(u.getEmail()),
                    escapeCsv(u.getCollegeId() != null ? u.getCollegeId() : ""),
                    escapeCsv(u.getProgramName() != null ? u.getProgramName() : ""),
                    escapeCsv(u.getStatus()),
                    u.isHasVoted() ? "YES" : "NO",
                    u.getCreatedAt() != null ? u.getCreatedAt().toString() : ""
            );
        }
        writer.flush();
    }

    private String escapeCsv(String val) {
        if (val == null) return "";
        return val.replace("\"", "\"\"");
    }

    private void handleFlashMessages(HttpServletRequest req) {
        HttpSession session = req.getSession(false);
        if (session != null) {
            String success = (String) session.getAttribute("flashSuccess");
            if (success != null) {
                req.setAttribute("flashSuccess", success);
                session.removeAttribute("flashSuccess");
            }
            String error = (String) session.getAttribute("flashError");
            if (error != null) {
                req.setAttribute("flashError", error);
                session.removeAttribute("flashError");
            }
        }
    }
}
