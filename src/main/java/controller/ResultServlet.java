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
import model.Candidate;
import model.Election;
import model.User;
import util.SecurityUtil;
import util.ValidationUtil;

import java.io.IOException;
import java.util.List;

/**
 * Handles election results computation and publishing.
 * Voters can view results only once an election is PUBLISHED by administrators.
 */
@WebServlet(name = "ResultServlet", urlPatterns = {"/results", "/admin/results"})
public class ResultServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final VoteDAO voteDAO = new VoteDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String uri = req.getRequestURI();
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        boolean isAdmin = (user != null && user.isAdmin());

        if (uri.endsWith("/admin/results")) {
            // Admin Results View: Can inspect all elections and their live counts
            List<Election> elections = electionDAO.getAllElections();
            req.setAttribute("elections", elections);

            Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
            if (electionId == null && !elections.isEmpty()) {
                electionId = elections.get(0).getId();
            }

            if (electionId != null) {
                Election selectedElection = electionDAO.findById(electionId);
                List<Candidate> results = voteDAO.getElectionResults(electionId);
                req.setAttribute("selectedElection", selectedElection);
                req.setAttribute("results", results);
            }

            req.getRequestDispatcher("/admin/results.jsp").forward(req, resp);

        } else {
            // Public/Voter Results View: Only published elections
            Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
            List<Election> allElections = electionDAO.getAllElections();
            req.setAttribute("allElections", allElections);

            if (electionId != null) {
                Election selected = electionDAO.findById(electionId);
                if (selected != null) {
                    if (selected.isPublished() || isAdmin) {
                        List<Candidate> results = voteDAO.getElectionResults(electionId);
                        req.setAttribute("selectedElection", selected);
                        req.setAttribute("results", results);
                    } else {
                        req.setAttribute("infoMessage", "Results for this election have not been officially published yet.");
                    }
                }
            }

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
        Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        String ip = SecurityUtil.getClientIpAddress(req);
        String ua = SecurityUtil.getUserAgent(req);

        if ("publish".equalsIgnoreCase(action) && electionId != null) {
            boolean updated = electionDAO.updateStatus(electionId, "PUBLISHED");
            if (updated) {
                auditLogDAO.log(user.getId(), "ELECTION_RESULTS_PUBLISHED_ID_" + electionId, ip, ua);
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/results?electionId=" + (electionId != null ? electionId : ""));
    }
}
