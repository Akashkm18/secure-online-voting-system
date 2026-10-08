package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Filter that protects all administrator endpoints (/admin/*).
 * Ensures requester possesses valid ADMIN session role.
 */
@WebFilter(filterName = "AdminFilter", urlPatterns = "/admin/*")
public class AdminFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        String uri = req.getRequestURI();
        String contextPath = req.getContextPath();

        // Allow public access to Admin login page and login submission
        if (uri.endsWith("/admin/login.jsp") || uri.endsWith("/admin/login")) {
            // If already logged in as ADMIN, automatically direct to admin dashboard
            HttpSession session = req.getSession(false);
            if (session != null) {
                User user = (User) session.getAttribute("user");
                if (user != null && user.isAdmin()) {
                    res.sendRedirect(contextPath + "/admin/dashboard.jsp");
                    return;
                }
            }
            chain.doFilter(request, response);
            return;
        }

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        // Not authenticated
        if (user == null) {
            res.sendRedirect(contextPath + "/admin/login.jsp?error=unauthorized");
            return;
        }

        // Authenticated but not an administrator
        if (!user.isAdmin()) {
            res.setStatus(HttpServletResponse.SC_FORBIDDEN);
            req.setAttribute("errorMessage", "Access Denied: You do not possess administrator credentials to view this section.");
            req.getRequestDispatcher("/error.jsp").forward(req, res);
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
