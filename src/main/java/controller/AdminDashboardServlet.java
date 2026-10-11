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
import model.AuditLog;
import model.Election;

import java.io.IOException;
import java.util.List;

/**
 * Controller for the Administrator Dashboard overview.
 * URL: /admin/dashboard
 */
@WebServlet(name = "AdminDashboardServlet", urlPatterns = "/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final ElectionDAO electionDAO = new ElectionDAO();
    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final VoteDAO voteDAO = new VoteDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        int totalVoters = userDAO.countTotalVoters();
        int pendingApprovals = userDAO.countVotersByStatus("PENDING");
        int activeElections = electionDAO.countByStatus("ACTIVE");
        int totalVotes = voteDAO.getTotalVotesCount();

        double turnout = 0.0;
        if (totalVoters > 0) {
            turnout = Math.min(100.0, Math.round(((double) totalVotes / totalVoters) * 1000.0) / 10.0);
        }

        List<Election> latestElections = electionDAO.getElectionsFiltered(null, null, 0, 5);
        List<AuditLog> recentLogs = auditLogDAO.getRecentLogs(6);

        req.setAttribute("totalVoters", totalVoters);
        req.setAttribute("pendingApprovals", pendingApprovals);
        req.setAttribute("activeElectionsCount", activeElections);
        req.setAttribute("totalVotesCount", totalVotes);
        req.setAttribute("turnoutPercentage", turnout);
        req.setAttribute("latestElections", latestElections);
        req.setAttribute("recentAuditLogs", recentLogs);
        req.setAttribute("activeNav", "dashboard");

        // Flash message handling
        handleFlashMessages(req);

        req.getRequestDispatcher("/admin/dashboard.jsp").forward(req, resp);
    }

    private void handleFlashMessages(HttpServletRequest req) {
        var session = req.getSession(false);
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
