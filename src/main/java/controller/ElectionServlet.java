package controller;

import dao.AuditLogDAO;
import dao.ElectionDAO;
import dao.VoteDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Election;
import model.User;
import util.SecurityUtil;
import util.ValidationUtil;

import java.io.IOException;
import java.sql.Timestamp;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Handles viewing and administrative management of elections.
 */
@WebServlet(name = "ElectionServlet", urlPatterns = {"/elections", "/admin/elections"})
public class ElectionServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final VoteDAO voteDAO = new VoteDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (uri.endsWith("/admin/elections")) {
            // Admin election management view
            List<Election> allElections = electionDAO.getAllElections();
            req.setAttribute("elections", allElections);
            req.getRequestDispatcher("/admin/elections.jsp").forward(req, resp);
        } else {
            // Voter elections view
            List<Election> allElections = electionDAO.getAllElections();
            if (user != null) {
                List<Integer> votedElectionIds = voteDAO.getUserVotedElectionIds(user.getId());
                req.setAttribute("votedElectionIds", votedElectionIds);
            }
            req.setAttribute("elections", allElections);
            req.getRequestDispatcher("/elections.jsp").forward(req, resp);
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

        if ("create".equalsIgnoreCase(action)) {
            handleCreateElection(req, resp, user, ip, ua);
        } else if ("updateStatus".equalsIgnoreCase(action)) {
            handleUpdateStatus(req, resp, user, ip, ua);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/elections");
        }
    }

    private void handleCreateElection(HttpServletRequest req, HttpServletResponse resp, User user, String ip, String ua)
            throws ServletException, IOException {

        String name = req.getParameter("electionName");
        String description = req.getParameter("description");
        String startStr = req.getParameter("startTime");
        String endStr = req.getParameter("endTime");

        if (name == null || name.trim().length() < 3 || name.trim().length() > 150) {
            req.setAttribute("errorMessage", "Election Name must be between 3 and 150 characters.");
            doGet(req, resp);
            return;
        }

        Timestamp startTs;
        Timestamp endTs;
        try {
            // Standard HTML5 datetime-local format: yyyy-MM-dd'T'HH:mm
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime startLdt = LocalDateTime.parse(startStr, formatter);
            LocalDateTime endLdt = LocalDateTime.parse(endStr, formatter);

            if (!endLdt.isAfter(startLdt)) {
                req.setAttribute("errorMessage", "Election End Time must be later than Start Time.");
                doGet(req, resp);
                return;
            }

            startTs = Timestamp.valueOf(startLdt);
            endTs = Timestamp.valueOf(endLdt);
        } catch (Exception e) {
            req.setAttribute("errorMessage", "Invalid start or end date/time format. Please use the date picker.");
            doGet(req, resp);
            return;
        }

        Election election = new Election();
        election.setElectionName(name.trim());
        election.setDescription(description != null ? description.trim() : "");
        election.setStartTime(startTs);
        election.setEndTime(endTs);
        election.setStatus("UPCOMING");

        boolean created = electionDAO.createElection(election);
        if (created) {
            auditLogDAO.log(user.getId(), "ELECTION_CREATED_ID_" + election.getId(), ip, ua);
            resp.sendRedirect(req.getContextPath() + "/admin/elections?success=created");
        } else {
            req.setAttribute("errorMessage", "Database error occurred while creating election.");
            doGet(req, resp);
        }
    }

    private void handleUpdateStatus(HttpServletRequest req, HttpServletResponse resp, User user, String ip, String ua)
            throws IOException {

        Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        String status = req.getParameter("status");

        if (electionId != null && ValidationUtil.isValidElectionStatus(status)) {
            boolean updated = electionDAO.updateStatus(electionId, status.toUpperCase());
            if (updated) {
                auditLogDAO.log(user.getId(), "ELECTION_STATUS_UPDATED_" + electionId + "_TO_" + status.toUpperCase(), ip, ua);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/elections");
    }
}
