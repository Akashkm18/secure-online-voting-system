package filter;

import jakarta.servlet.*;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;

/**
 * Filter that attaches security-hardening HTTP response headers to every request.
 * Enforces CSP, X-Frame-Options, X-Content-Type-Options, Referrer-Policy, and cache prevention.
 */
@WebFilter(filterName = "SecurityHeadersFilter", urlPatterns = "/*")
public class SecurityHeadersFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain)
            throws IOException, ServletException {

        if (response instanceof HttpServletResponse) {
            HttpServletResponse res = (HttpServletResponse) response;
            HttpServletRequest req = (HttpServletRequest) request;

            // Content-Security-Policy
            res.setHeader("Content-Security-Policy",
                    "default-src 'self'; " +
                    "script-src 'self' 'unsafe-inline'; " +
                    "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
                    "font-src 'self' https://fonts.gstatic.com; " +
                    "img-src 'self' data:; " +
                    "object-src 'none'; " +
                    "base-uri 'self'; " +
                    "frame-ancestors 'none';");

            // Prevent MIME type sniffing
            res.setHeader("X-Content-Type-Options", "nosniff");

            // Prevent Clickjacking
            res.setHeader("X-Frame-Options", "DENY");

            // Referrer Policy
            res.setHeader("Referrer-Policy", "strict-origin-when-cross-origin");

            // Feature / Permissions Policy
            res.setHeader("Permissions-Policy", "geolocation=(), camera=(), microphone=()");

            // Strict Cache Control for non-static pages to avoid browser back-button caching authenticated data
            String path = req.getRequestURI();
            if (!path.endsWith(".css") && !path.endsWith(".js") && !path.endsWith(".png") && !path.endsWith(".ico")) {
                res.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
                res.setHeader("Pragma", "no-cache");
                res.setDateHeader("Expires", 0);
            }
        }

        chain.doFilter(request, response);
    }

    @Override
    public void destroy() {}
}
