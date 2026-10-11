package controller;

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
import util.ValidationUtil;

import java.io.IOException;
import java.util.List;

/**
 * Handles voter and public viewing of election results.
 * Results are strictly visible to voters ONLY when election status is PUBLISHED.
 */
@WebServlet(name = "ResultServlet", urlPatterns = "/results")
public class ResultServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final VoteDAO voteDAO = new VoteDAO();

    private final dao.UserDAO userDAO = new dao.UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        boolean isAdmin = (user != null && user.isAdmin());

        Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        List<Election> allElections = electionDAO.getAllElections();
        req.setAttribute("allElections", allElections);

        // If no election requested, default to first published election (or first election if admin)
        if (electionId == null && !allElections.isEmpty()) {
            for (Election el : allElections) {
                if (el.isPublished() || isAdmin) {
                    electionId = el.getId();
                    break;
                }
            }
        }

        if (electionId != null) {
            Election selected = electionDAO.findById(electionId);
            if (selected != null) {
                if (selected.isPublished() || isAdmin) {
                    List<Candidate> results = voteDAO.getElectionResults(electionId);
                    req.setAttribute("selectedElection", selected);
                    req.setAttribute("results", results);

                    int totalVotes = 0;
                    int maxVotes = -1;
                    int winnerCount = 0;
                    for (Candidate c : results) {
                        totalVotes += c.getVoteCount();
                        if (c.getVoteCount() > maxVotes) {
                            maxVotes = c.getVoteCount();
                            winnerCount = 1;
                        } else if (c.getVoteCount() == maxVotes && maxVotes > 0) {
                            winnerCount++;
                        }
                    }

                    int eligible = userDAO.countVotersByStatus("APPROVED");
                    if (eligible == 0) eligible = userDAO.countTotalVoters();
                    double turnoutPct = (eligible > 0) ? Math.min(100.0, ((double) totalVotes / eligible) * 100.0) : 0.0;

                    req.setAttribute("totalVotes", totalVotes);
                    req.setAttribute("eligibleVoters", eligible);
                    req.setAttribute("turnoutPercentage", Math.round(turnoutPct * 10.0) / 10.0);
                    req.setAttribute("maxVotes", maxVotes);
                    req.setAttribute("isTie", winnerCount > 1);
                } else {
                    req.setAttribute("infoMessage", "Certified results for \"" + selected.getElectionName() + "\" have not been officially published yet.");
                }
            }
        }

        req.getRequestDispatcher("/results.jsp").forward(req, resp);
    }
}
