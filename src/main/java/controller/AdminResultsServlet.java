package controller;

import dao.AuditLogDAO;
import dao.ElectionDAO;
import dao.UserDAO;
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
import java.io.PrintWriter;
import java.util.List;

/**
 * Controller for Election Results & Certified Tally inspection and publishing.
 * URL: /admin/results
 */
@WebServlet(name = "AdminResultsServlet", urlPatterns = "/admin/results")
public class AdminResultsServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final VoteDAO voteDAO = new VoteDAO();
    private final UserDAO userDAO = new UserDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        List<Election> allElections = electionDAO.getAllElections();
        req.setAttribute("allElections", allElections);

        Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        if (electionId == null && !allElections.isEmpty()) {
            electionId = allElections.get(0).getId();
        }

        if (electionId != null) {
            Election election = electionDAO.findById(electionId);
            if (election != null) {
                // CSV export
                if ("csv".equalsIgnoreCase(req.getParameter("export"))) {
                    handleCsvExport(resp, election);
                    return;
                }

                List<Candidate> results = voteDAO.getElectionResults(electionId);
                int totalVotesInElection = 0;
                int maxVotes = -1;
                int countWithMax = 0;

                for (Candidate c : results) {
                    totalVotesInElection += c.getVoteCount();
                    if (c.getVoteCount() > maxVotes) {
                        maxVotes = c.getVoteCount();
                        countWithMax = 1;
                    } else if (c.getVoteCount() == maxVotes && maxVotes > 0) {
                        countWithMax++;
                    }
                }

                boolean isTie = (countWithMax > 1 && maxVotes > 0);
                int eligibleVoters = userDAO.countTotalVoters();
                double turnout = (eligibleVoters > 0)
                        ? Math.min(100.0, Math.round(((double) totalVotesInElection / eligibleVoters) * 1000.0) / 10.0)
                        : 0.0;

                req.setAttribute("selectedElection", election);
                req.setAttribute("results", results);
                req.setAttribute("totalVotesInElection", totalVotesInElection);
                req.setAttribute("eligibleVoters", eligibleVoters);
                req.setAttribute("turnoutPercentage", turnout);
                req.setAttribute("winningVoteCount", maxVotes);
                req.setAttribute("isTie", isTie);
            }
        }

        req.setAttribute("activeNav", "results");
        handleFlashMessages(req);

        req.getRequestDispatcher("/admin/results.jsp").forward(req, resp);
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

        if (electionId == null) {
            session.setAttribute("flashError", "Invalid election ID.");
            resp.sendRedirect(req.getContextPath() + "/admin/results");
            return;
        }

        if ("publish".equalsIgnoreCase(action)) {
            Election election = electionDAO.findById(electionId);
            if (election == null) {
                session.setAttribute("flashError", "Election not found.");
                resp.sendRedirect(req.getContextPath() + "/admin/results");
                return;
            }

            // CRITICAL SERVER CONSTRAINT: Election MUST be COMPLETED before publishing certified results
            if (!"COMPLETED".equalsIgnoreCase(election.getStatus())) {
                session.setAttribute("flashError", "Results certification denied: Results can only be certified and published once the election has ended in COMPLETED status (current status: " + election.getStatus() + ").");
                auditLogDAO.log(user.getId(), "RESULTS_PUBLISH_BLOCKED_NON_COMPLETED_STATUS_ELECTION_" + electionId, ip, ua);
                resp.sendRedirect(req.getContextPath() + "/admin/results?electionId=" + electionId);
                return;
            }

            boolean transitioned = electionDAO.transitionStatus(electionId, "PUBLISHED");
            if (transitioned) {
                auditLogDAO.log(user.getId(), "RESULTS_CERTIFIED_AND_PUBLISHED_ELECTION_" + electionId, ip, ua);
                session.setAttribute("flashSuccess", "Certified results for \"" + election.getElectionName() + "\" have been published to the voter portal.");
            } else {
                session.setAttribute("flashError", "Failed to transition election to PUBLISHED.");
            }
        }

        resp.sendRedirect(req.getContextPath() + "/admin/results?electionId=" + electionId);
    }

    private void handleCsvExport(HttpServletResponse resp, Election election) throws IOException {
        List<Candidate> results = voteDAO.getElectionResults(election.getId());

        resp.setContentType("text/csv; charset=UTF-8");
        resp.setHeader("Content-Disposition", "attachment; filename=\"certified-results-election-" + election.getId() + ".csv\"");
        resp.setHeader("X-Content-Type-Options", "nosniff");

        PrintWriter writer = resp.getWriter();
        writer.println("Election Title: \"" + election.getElectionName().replace("\"", "\"\"") + "\"");
        writer.println("Status: " + election.getStatus());
        writer.println();
        writer.println("Rank,Candidate Name,Party,Position,Emblem,Total Votes,Vote Share %");

        int rank = 1;
        for (Candidate c : results) {
            writer.printf("\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%d\",\"%.1f%%\"%n",
                    rank++,
                    escapeCsv(c.getCandidateName()),
                    escapeCsv(c.getParty()),
                    escapeCsv(c.getPosition() != null ? c.getPosition() : "Candidate"),
                    escapeCsv(c.getSymbol() != null ? c.getSymbol() : ""),
                    c.getVoteCount(),
                    c.getVotePercentage()
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
