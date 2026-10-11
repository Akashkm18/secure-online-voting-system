package controller;

import dao.AuditLogDAO;
import dao.ElectionDAO;
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
 * Controller for Election Management (full CRUD and server-enforced workflow).
 * URL: /admin/elections
 */
@WebServlet(name = "AdminElectionsServlet", urlPatterns = "/admin/elections")
public class AdminElectionsServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String search = req.getParameter("q");
        String status = req.getParameter("status");
        if (status == null || status.trim().isEmpty()) {
            status = "ALL";
        }

        int page = 1;
        int pageSize = 10;
        try {
            String pStr = req.getParameter("page");
            if (pStr != null) page = Math.max(1, Integer.parseInt(pStr.trim()));
        } catch (NumberFormatException ignored) {}

        int offset = (page - 1) * pageSize;
        int totalItems = electionDAO.countElections(search, status);
        int totalPages = (int) Math.ceil((double) totalItems / pageSize);

        List<Election> elections = electionDAO.getElectionsFiltered(search, status, offset, pageSize);

        req.setAttribute("elections", elections);
        req.setAttribute("searchQuery", search != null ? search : "");
        req.setAttribute("currentStatus", status);
        req.setAttribute("currentPage", page);
        req.setAttribute("totalPages", Math.max(1, totalPages));
        req.setAttribute("totalItems", totalItems);
        req.setAttribute("activeNav", "elections");

        // Flash message handling
        handleFlashMessages(req);

        req.getRequestDispatcher("/admin/elections.jsp").forward(req, resp);
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
            handleCreate(req, session, user, ip, ua);
        } else if ("edit".equalsIgnoreCase(action)) {
            handleEdit(req, session, user, ip, ua);
        } else if ("transition".equalsIgnoreCase(action)) {
            handleTransition(req, session, user, ip, ua);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDelete(req, session, user, ip, ua);
        } else {
            session.setAttribute("flashError", "Unrecognized election action.");
        }

        resp.sendRedirect(req.getContextPath() + "/admin/elections");
    }

    private void handleCreate(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        String name = req.getParameter("electionName");
        String description = req.getParameter("description");
        String startStr = req.getParameter("startTime");
        String endStr = req.getParameter("endTime");

        if (name == null || name.trim().length() < 3 || name.trim().length() > 150) {
            session.setAttribute("flashError", "Election title must be between 3 and 150 characters.");
            return;
        }

        Timestamp startTs;
        Timestamp endTs;
        try {
            startTs = parseTimestamp(startStr);
            endTs = parseTimestamp(endStr);
            if (!endTs.after(startTs)) {
                session.setAttribute("flashError", "Election end date and time must be strictly after the start date and time.");
                return;
            }
        } catch (Exception e) {
            session.setAttribute("flashError", "Invalid date format. Please specify valid start and end timestamps.");
            return;
        }

        Election el = new Election();
        el.setElectionName(name.trim());
        el.setDescription(description != null ? description.trim() : "");
        el.setStartTime(startTs);
        el.setEndTime(endTs);
        el.setStatus("UPCOMING");

        boolean created = electionDAO.createElection(el);
        if (created) {
            auditLogDAO.log(user.getId(), "ELECTION_CREATED_ID_" + el.getId() + "_" + el.getElectionName(), ip, ua);
            session.setAttribute("flashSuccess", "Election \"" + el.getElectionName() + "\" created successfully in UPCOMING status.");
        } else {
            session.setAttribute("flashError", "Failed to create election. Please verify parameters.");
        }
    }

    private void handleEdit(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        Integer id = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        if (id == null) {
            session.setAttribute("flashError", "Invalid election ID.");
            return;
        }

        Election existing = electionDAO.findById(id);
        if (existing == null) {
            session.setAttribute("flashError", "Election not found.");
            return;
        }

        String name = req.getParameter("electionName");
        String description = req.getParameter("description");
        String startStr = req.getParameter("startTime");
        String endStr = req.getParameter("endTime");

        if (name == null || name.trim().length() < 3 || name.trim().length() > 150) {
            session.setAttribute("flashError", "Election title must be between 3 and 150 characters.");
            return;
        }

        boolean hasVotes = electionDAO.hasVotes(id);
        Timestamp startTs = existing.getStartTime();
        Timestamp endTs = existing.getEndTime();

        if (startStr != null && !startStr.trim().isEmpty() && endStr != null && !endStr.trim().isEmpty()) {
            try {
                Timestamp newStart = parseTimestamp(startStr);
                Timestamp newEnd = parseTimestamp(endStr);
                if (!newEnd.after(newStart)) {
                    session.setAttribute("flashError", "Election end date must be after the start date.");
                    return;
                }
                if (hasVotes && (!newStart.equals(existing.getStartTime()) || !newEnd.equals(existing.getEndTime()))) {
                    session.setAttribute("flashError", "Editing election dates is blocked because votes have already been cast.");
                    return;
                }
                startTs = newStart;
                endTs = newEnd;
            } catch (Exception e) {
                session.setAttribute("flashError", "Invalid date format specified.");
                return;
            }
        }

        existing.setElectionName(name.trim());
        existing.setDescription(description != null ? description.trim() : "");
        existing.setStartTime(startTs);
        existing.setEndTime(endTs);

        boolean updated = electionDAO.updateElection(existing);
        if (updated) {
            auditLogDAO.log(user.getId(), "ELECTION_EDITED_ID_" + id, ip, ua);
            session.setAttribute("flashSuccess", "Election \"" + existing.getElectionName() + "\" updated successfully.");
        } else {
            session.setAttribute("flashError", "Failed to update election details.");
        }
    }

    private void handleTransition(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        Integer id = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        String targetStatus = req.getParameter("targetStatus");

        if (id == null || targetStatus == null) {
            session.setAttribute("flashError", "Invalid election status transition request.");
            return;
        }

        boolean transitioned = electionDAO.transitionStatus(id, targetStatus.trim().toUpperCase());
        if (transitioned) {
            auditLogDAO.log(user.getId(), "ELECTION_STATUS_TRANSITION_ID_" + id + "_TO_" + targetStatus.toUpperCase(), ip, ua);
            session.setAttribute("flashSuccess", "Election status updated to " + targetStatus.toUpperCase() + ".");
        } else {
            session.setAttribute("flashError", "Illegal status transition. Workflow strictly enforces: UPCOMING -> ACTIVE -> COMPLETED -> PUBLISHED.");
        }
    }

    private void handleDelete(HttpServletRequest req, HttpSession session, User user, String ip, String ua) {
        Integer id = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        if (id == null) {
            session.setAttribute("flashError", "Invalid election ID.");
            return;
        }

        if (electionDAO.hasVotes(id)) {
            session.setAttribute("flashError", "Deleting an election with existing recorded votes is strictly prohibited. Archive it instead.");
            return;
        }

        boolean deleted = electionDAO.deleteElection(id);
        if (deleted) {
            auditLogDAO.log(user.getId(), "ELECTION_DELETED_ID_" + id, ip, ua);
            session.setAttribute("flashSuccess", "Election deleted successfully.");
        } else {
            session.setAttribute("flashError", "Failed to delete election.");
        }
    }

    private Timestamp parseTimestamp(String dtStr) {
        if (dtStr == null || dtStr.trim().isEmpty()) {
            throw new IllegalArgumentException("Empty timestamp");
        }
        String clean = dtStr.trim();
        if (clean.length() == 16) { // "yyyy-MM-dd'T'HH:mm"
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
            LocalDateTime ldt = LocalDateTime.parse(clean, formatter);
            return Timestamp.valueOf(ldt);
        } else if (clean.length() == 19) { // "yyyy-MM-dd HH:mm:ss" or with 'T'
            String replaced = clean.replace('T', ' ');
            return Timestamp.valueOf(replaced);
        }
        DateTimeFormatter iso = DateTimeFormatter.ISO_DATE_TIME;
        return Timestamp.valueOf(LocalDateTime.parse(clean, iso));
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
