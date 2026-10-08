package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import util.CSRFUtil;

import java.io.IOException;

/**
 * Filter that validates CSRF tokens on all state-altering HTTP methods (POST, PUT, DELETE).
 * Generates and ensures presence of CSRF token in session for all requests.
 */
@WebFilter(filterName = "CSRFProtectionFilter", urlPatterns = "/*")
public class CSRFProtectionFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (request instanceof HttpServletRequest && response instanceof HttpServletResponse) {
            HttpServletRequest req = (HttpServletRequest) request;
            HttpServletResponse res = (HttpServletResponse) response;

            // Always ensure token is generated and available in request scope for JSPs
            String csrfToken = CSRFUtil.getToken(req);
            req.setAttribute("csrfToken", csrfToken);

            String method = req.getMethod();

            // Validate token on POST requests
            if ("POST".equalsIgnoreCase(method)) {
                String uri = req.getRequestURI();
                // Exclude static assets and stateless APIs from CSRF
                if (!uri.endsWith(".css") && !uri.endsWith(".js") && !uri.contains("/api/id-card/analyze")) {
                    if (!CSRFUtil.isValid(req)) {
                        res.setStatus(HttpServletResponse.SC_FORBIDDEN);
                        req.setAttribute("errorMessage", "Invalid or expired security token (CSRF). Please refresh and try again.");
                        req.getRequestDispatcher("/error.jsp").forward(req, res);
                        return;
                    }
                }
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
