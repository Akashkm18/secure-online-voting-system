<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<footer class="app-footer">
    <div class="footer-container">
        <div class="footer-meta">
            <span class="footer-copyright">© 2026 Secure Online Voting System. All rights reserved.</span>
            <span class="footer-security-note">Cryptographically verified ballot integrity & single-vote protection.</span>
        </div>
        <div class="footer-links">
            <a href="${pageContext.request.contextPath}/index.jsp#security" class="footer-link">Security Protocol</a>
            <a href="${pageContext.request.contextPath}/index.jsp#privacy" class="footer-link">Privacy Policy</a>
            <a href="${pageContext.request.contextPath}/index.jsp#contact" class="footer-link">Contact Support</a>
            <c:if test="${empty sessionScope.user or not sessionScope.user.admin}">
                <a href="${pageContext.request.contextPath}/admin/login.jsp" class="footer-link footer-admin-link" id="footerAdminLink" title="Authorized Election Officials">
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 3px; vertical-align: -1px;">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                    Admin Portal
                </a>
            </c:if>
        </div>
    </div>
</footer>
