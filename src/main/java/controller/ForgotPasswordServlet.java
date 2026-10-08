package controller;

import dao.UserDAO;
import model.User;
import util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {

    private final UserDAO userDao = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String email = req.getParameter("email");
        String collegeId = req.getParameter("collegeId");
        String otp = req.getParameter("otp");
        String newPassword = req.getParameter("newPassword");
        String confirmPassword = req.getParameter("confirmPassword");

        if (email == null || collegeId == null || newPassword == null || confirmPassword == null || email.trim().isEmpty() || collegeId.trim().isEmpty()) {
            req.setAttribute("errorMessage", "All fields are required.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (!newPassword.equals(confirmPassword)) {
            req.setAttribute("errorMessage", "Passwords do not match.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        if (newPassword.length() < 6) {
            req.setAttribute("errorMessage", "Password must be at least 6 characters.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Verify the user exists with this email and college ID
        User user = userDao.findByEmail(email.trim());
        if (user == null || !user.getCollegeId().equalsIgnoreCase(collegeId.trim())) {
            req.setAttribute("errorMessage", "No matching user found for this Email and College ID.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
            return;
        }

        // Hash new password and update
        String newPasswordHash = PasswordUtil.hashPassword(newPassword);
        boolean updated = userDao.updatePassword(email, collegeId, newPasswordHash);

        if (updated) {
            // Clear session OTP data
            req.getSession().removeAttribute("reset_otp");
            req.getSession().removeAttribute("reset_email");
            req.getSession().removeAttribute("reset_college_id");
            
            req.setAttribute("successMessage", "Password reset successfully! You can now login.");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        } else {
            req.setAttribute("errorMessage", "Failed to reset password. Please try again.");
            req.getRequestDispatcher("/forgot-password.jsp").forward(req, resp);
        }
    }
}
