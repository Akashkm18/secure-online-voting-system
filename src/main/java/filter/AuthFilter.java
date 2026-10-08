package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import model.User;

import java.io.IOException;

/**
 * Filter ensuring that only authenticated users can access voter and member features.
 */
@WebFilter(filterName = "AuthFilter", urlPatterns = {
        "/dashboard.jsp",
        "/elections.jsp",
        "/candidates.jsp",
        "/vote.jsp",
        "/vote-success.jsp",
        "/my-status.jsp",
        "/voting",
        "/elections",
        "/candidates",
        "/logout"
})
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        HttpServletRequest req = (HttpServletRequest) request;
        HttpServletResponse res = (HttpServletResponse) response;

        HttpSession session = req.getSession(false);
        User user = (session != null) ? (User) session.getAttribute("user") : null;

        if (user == null) {
            String contextPath = req.getContextPath();
            res.sendRedirect(contextPath + "/login.jsp?error=unauthorized");
            return;
        }

        // Check if user is active
        if (!user.isActive()) {
            if (session != null) {
                session.invalidate();
            }
            res.sendRedirect(req.getContextPath() + "/login.jsp?error=account_disabled");
            return;
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
