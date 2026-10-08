package controller;

import dao.AuditLogDAO;
import dao.CandidateDAO;
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
import java.sql.SQLException;
import java.util.List;

/**
 * Handles casting votes within an active election.
 * Enforces atomic single-transaction execution and duplicate vote prevention.
 */
@WebServlet(name = "VotingServlet", urlPatterns = "/voting")
public class VotingServlet extends HttpServlet {

    private final VoteDAO voteDAO = new VoteDAO();
    private final ElectionDAO electionDAO = new ElectionDAO();
    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final AuditLogDAO auditLogDAO = new AuditLogDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // GET displays the ballot page for an election
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        if (electionId == null) {
            resp.sendRedirect(req.getContextPath() + "/elections.jsp");
            return;
        }

        Election election = electionDAO.findById(electionId);
        if (election == null) {
            req.setAttribute("errorMessage", "Election not found.");
            req.getRequestDispatcher("/elections.jsp").forward(req, resp);
            return;
        }

        // Check if user has already voted
        if (voteDAO.hasUserVoted(electionId, user.getId())) {
            req.setAttribute("infoMessage", "You have already cast your vote in this election.");
            resp.sendRedirect(req.getContextPath() + "/my-status.jsp");
            return;
        }

        List<Candidate> candidates = candidateDAO.findByElectionId(electionId, true);
        req.setAttribute("election", election);
        req.setAttribute("candidates", candidates);
        req.getRequestDispatcher("/vote.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;
        if (user == null) {
            resp.sendRedirect(req.getContextPath() + "/login.jsp");
            return;
        }

        String ip = SecurityUtil.getClientIpAddress(req);
        String ua = SecurityUtil.getUserAgent(req);

        Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        Integer candidateId = ValidationUtil.parsePositiveInt(req.getParameter("candidateId"));

        if (electionId == null || candidateId == null) {
            forwardVoteError(req, resp, electionId, "Invalid election or candidate selection. Please select a candidate.");
            return;
        }

        try {
            // Atomic transaction in VoteDAO
            String receiptHash = voteDAO.castVote(electionId, user.getId(), candidateId, ip, ua);

            Election election = electionDAO.findById(electionId);
            String electionName = (election != null) ? election.getElectionName() : "Election #" + electionId;

            // Store receipt details in session for vote-success.jsp (No candidate identity revealed)
            session.setAttribute("lastVoteHash", receiptHash);
            session.setAttribute("lastVoteElection", electionName);
            session.setAttribute("lastVoteTime", new java.util.Date());

            resp.sendRedirect(req.getContextPath() + "/vote-success.jsp");

        } catch (IllegalStateException e) {
            auditLogDAO.log(user.getId(), "VOTE_REJECTED: " + e.getMessage(), ip, ua);
            forwardVoteError(req, resp, electionId, e.getMessage());
        } catch (SQLException e) {
            auditLogDAO.log(user.getId(), "VOTE_ERROR_DATABASE: " + e.getMessage(), ip, ua);
            forwardVoteError(req, resp, electionId, "Database error during voting: " + e.getMessage());
        } catch (Exception e) {
            auditLogDAO.log(user.getId(), "VOTE_UNEXPECTED_ERROR: " + e.getMessage(), ip, ua);
            forwardVoteError(req, resp, electionId, "An unexpected error occurred while casting your vote.");
        }
    }

    private void forwardVoteError(HttpServletRequest req, HttpServletResponse resp, Integer electionId, String errorMessage)
            throws ServletException, IOException {
        req.setAttribute("errorMessage", errorMessage);
        if (electionId != null) {
            Election election = electionDAO.findById(electionId);
            List<Candidate> candidates = candidateDAO.findByElectionId(electionId, true);
            req.setAttribute("election", election);
            req.setAttribute("candidates", candidates);
            req.getRequestDispatcher("/vote.jsp").forward(req, resp);
        } else {
            resp.sendRedirect(req.getContextPath() + "/elections.jsp?error=invalid_election");
        }
    }
}
