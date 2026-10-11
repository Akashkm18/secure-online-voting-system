package controller;

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

import java.io.IOException;
import java.util.List;

/**
 * Handles viewing of elections on the voter and public side.
 * Admin actions are managed via AdminElectionsServlet.
 */
@WebServlet(name = "ElectionServlet", urlPatterns = "/elections")
public class ElectionServlet extends HttpServlet {

    private final ElectionDAO electionDAO = new ElectionDAO();
    private final VoteDAO voteDAO = new VoteDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        List<Election> allElections = electionDAO.getAllElections();
        if (user != null) {
            List<Integer> votedElectionIds = voteDAO.getUserVotedElectionIds(user.getId());
            req.setAttribute("votedElectionIds", votedElectionIds);
        }
        req.setAttribute("elections", allElections);
        req.getRequestDispatcher("/elections.jsp").forward(req, resp);
    }
}
