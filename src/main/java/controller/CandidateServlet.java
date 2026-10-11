package controller;

import dao.CandidateDAO;
import dao.ElectionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import model.Candidate;
import model.Election;
import util.ValidationUtil;

import java.io.IOException;
import java.util.List;

/**
 * Handles viewing of candidates on the voter and public portal.
 * Admin actions are managed via AdminCandidatesServlet.
 */
@WebServlet(name = "CandidateServlet", urlPatterns = "/candidates")
public class CandidateServlet extends HttpServlet {

    private final CandidateDAO candidateDAO = new CandidateDAO();
    private final ElectionDAO electionDAO = new ElectionDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        Integer electionId = ValidationUtil.parsePositiveInt(req.getParameter("electionId"));
        List<Election> allElections = electionDAO.getAllElections();
        req.setAttribute("allElections", allElections);

        if (electionId != null) {
            Election election = electionDAO.findById(electionId);
            List<Candidate> candidates = candidateDAO.findByElectionId(electionId, true);
            req.setAttribute("selectedElection", election);
            req.setAttribute("candidates", candidates);
        } else {
            List<Candidate> allCandidates = candidateDAO.getAllCandidates();
            req.setAttribute("candidates", allCandidates);
        }
        req.getRequestDispatcher("/candidates.jsp").forward(req, resp);
    }
}
