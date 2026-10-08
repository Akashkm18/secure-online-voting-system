package controller;

import dao.AuditLogDAO;
import dao.CandidateDAO;
import dao.ElectionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.Candidate;
import model.Election;
import model.User;
import util.SecurityUtil;
import util.ValidationUtil;

import java.io.IOException;
import java.util.List;

/**
 * Handles viewing and administrative management of candidates.
 */
@WebServlet(name = "CandidateServlet", urlPatterns = {"/candidates", "/admin/candidates"})
public class CandidateServlet extends HttpServlet {

    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final ElectionDAO electionDAO = new ElectionDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();

        if (uri.endsWith("/admin/candidates")) {
            List<Candidate> candidates = candidateDAO.getAllCandidates();
            List<Election> elections = electionDAO.getAllElections();
            req.setAttribute("candidates", candidates);
            req.setAttribute("elections", elections);
            req.getRequestDispatcher("/admin/candidates.jsp").forward(req, resp);
        } else {
            // Public/voter candidate list by election
            Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
            if (electionId != null) {
                Election election = electionDAO.findById(electionId);
                List<Candidate> candidates = candidateDAO.findByElectionId(electionId, true);
                req.setAttribute("election", election);
                req.setAttribute("candidates", candidates);
            } else {
                List<Candidate> allCandidates = candidateDAO.getAllCandidates();
                req.setAttribute("candidates", allCandidates);
            }
            req.getRequestDispatcher("/candidates.jsp").forward(req, resp);
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

        if ("add".equalsIgnoreCase(action)) {
            handleAddCandidate(req, resp, user, ip, ua);
        } else if ("edit".equalsIgnoreCase(action)) {
            handleEditCandidate(req, resp, user, ip, ua);
        } else if ("toggleActive".equalsIgnoreCase(action)) {
            handleToggleActive(req, resp, user, ip, ua);
        } else if ("delete".equalsIgnoreCase(action)) {
            handleDeleteCandidate(req, resp, user, ip, ua);
        } else {
            resp.sendRedirect(req.getContextPath() + "/admin/candidates");
        }
    }

    private void handleAddCandidate(HttpServletRequest req, HttpServletResponse resp, User user, String ip, String ua)
            throws ServletException, IOException {

        Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        String name = req.getParameter("candidateName");
        String party = req.getParameter("party");
        String symbol = req.getParameter("symbol");

        if (electionId == null || !ValidationUtil.isValidName(name)
                || !ValidationUtil.isValidPartyOrSymbol(party)
                || !ValidationUtil.isValidPartyOrSymbol(symbol)) {
            req.setAttribute("errorMessage", "Invalid candidate details. Please ensure all fields are correctly formatted.");
            doGet(req, resp);
            return;
        }

        Candidate c = new Candidate();
        c.setElectionId(electionId);
        c.setCandidateName(name.trim());
        c.setParty(party.trim());
        c.setSymbol(symbol.trim());
        c.setActive(true);

        boolean created = candidateDAO.createCandidate(c);
        if (created) {
            auditLogDAO.log(user.getId(), "CANDIDATE_ADDED_" + c.getId() + "_IN_ELECTION_" + electionId, ip, ua);
            resp.sendRedirect(req.getContextPath() + "/admin/candidates?success=added");
        } else {
            req.setAttribute("errorMessage", "Database error occurred while adding candidate.");
            doGet(req, resp);
        }
    }

    private void handleEditCandidate(HttpServletRequest req, HttpServletResponse resp, User user, String ip, String ua)
            throws ServletException, IOException {

        Integer candidateId = ValidationUtil.parsePositiveInt(req.getParameter("candidateId"));
        String name = req.getParameter("candidateName");
        String party = req.getParameter("party");
        String symbol = req.getParameter("symbol");
        boolean active = "true".equalsIgnoreCase(req.getParameter("active"));

        if (candidateId == null || !ValidationUtil.isValidName(name)
                || !ValidationUtil.isValidPartyOrSymbol(party)
                || !ValidationUtil.isValidPartyOrSymbol(symbol)) {
            req.setAttribute("errorMessage", "Invalid candidate data provided.");
            doGet(req, resp);
            return;
        }

        Candidate c = candidateDAO.findById(candidateId);
        if (c != null) {
            c.setCandidateName(name.trim());
            c.setParty(party.trim());
            c.setSymbol(symbol.trim());
            c.setActive(active);
            candidateDAO.updateCandidate(c);
            auditLogDAO.log(user.getId(), "CANDIDATE_UPDATED_ID_" + candidateId, ip, ua);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/candidates?success=updated");
    }

    private void handleToggleActive(HttpServletRequest req, HttpServletResponse resp, User user, String ip, String ua)
            throws IOException {

        Integer candidateId = ValidationUtil.parsePositiveInt(req.getParameter("candidateId"));
        boolean active = Boolean.parseBoolean(req.getParameter("active"));

        if (candidateId != null) {
            candidateDAO.setActiveStatus(candidateId, active);
            auditLogDAO.log(user.getId(), "CANDIDATE_STATUS_ID_" + candidateId + "_TO_" + active, ip, ua);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/candidates");
    }

    private void handleDeleteCandidate(HttpServletRequest req, HttpServletResponse resp, User user, String ip, String ua)
            throws IOException {

        Integer candidateId = ValidationUtil.parsePositiveInt(req.getParameter("candidateId"));
        if (candidateId != null) {
            candidateDAO.deleteCandidate(candidateId);
            auditLogDAO.log(user.getId(), "CANDIDATE_DELETED_ID_" + candidateId, ip, ua);
        }

        resp.sendRedirect(req.getContextPath() + "/admin/candidates?success=deleted");
    }
}
