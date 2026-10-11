<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Automatically ensure designated admin credentials and clean legacy voter records
    try (java.sql.Connection con = util.DatabaseConnection.getConnection()) {
        try (java.sql.PreparedStatement psDel = con.prepareStatement(
                "DELETE FROM users WHERE college_id = 'AU-2024-CED-014' OR email = 'voter@voting.edu'")) {
            psDel.executeUpdate();
        }
        String adminSql = "INSERT INTO users (full_name, email, college_id, college_name, program_name, joining_year, study_year, password_hash, role, is_verified, is_active) " +
                          "VALUES ('Akash K M', 'kakashbtech24@ced.alliance.edu.in', '4107241562', 'Office of Chief Election Officer', 'Election Commission', 2024, 'Faculty / Admin', " +
                          "'$2a$12$/nPDV4EbzMJsKlktc12sWel4wajpR46zcICV.2mh6kg3OCfqJ77h.', 'ADMIN', TRUE, TRUE) " +
                          "ON DUPLICATE KEY UPDATE password_hash = '$2a$12$/nPDV4EbzMJsKlktc12sWel4wajpR46zcICV.2mh6kg3OCfqJ77h.', role = 'ADMIN', is_active = TRUE";
        try (java.sql.PreparedStatement psAdmin = con.prepareStatement(adminSql)) {
            psAdmin.executeUpdate();
        }
    } catch (Exception e) {
        // Fallback silently if DB is initializing
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Secure administrator access for election configuration and result publication.">
    <title>Administrator Login | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Shared Header Navigation Fragment -->
    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <div class="auth-wrapper">
        <div class="auth-card" id="adminLoginFormCard">
            <div class="auth-header">
                <div class="auth-header-icon admin">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                </div>
                <div style="margin-bottom: 0.35rem;">
                    <span class="badge badge-admin">Administrator Access</span>
                </div>
                <h1 class="auth-title">Election Administration</h1>
                <p class="auth-subtitle">Sign in to manage elections, candidate registries, and tallies</p>
            </div>

            <!-- Error Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" id="alertAdminError">
                    <svg class="alert-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <c:if test="${param.error == 'unauthorized'}">
                <div class="alert alert-danger">
                    <svg class="alert-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div>Please sign in with authorized administrator credentials.</div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/login" method="POST" id="adminLoginForm" autocomplete="off">
                <!-- CSRF Token -->
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />

                <div class="form-group">
                    <label for="adminEmail">Administrator Email</label>
                    <input type="email" id="adminEmail" name="email" class="form-control" 
                           placeholder="admin@institution.edu" required />
                </div>

                <div class="form-group">
                    <label for="adminPassword">Password</label>
                    <div class="input-password-wrapper">
                        <input type="password" id="adminPassword" name="password" class="form-control" 
                               placeholder="••••••••" required />
                        <button type="button" class="password-toggle-btn" aria-label="Toggle password visibility">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-block" id="submitAdminLoginBtn" style="margin-top: 1.25rem;">
                    Sign In to Admin Portal
                </button>
            </form>

            <div style="margin-top: 1.5rem; padding-top: 1.25rem; border-top: 1px solid var(--border-color); text-align: center; font-size: 0.85rem;">
                <a href="${pageContext.request.contextPath}/login.jsp" class="footer-link">
                    ← Return to Voter Sign In
                </a>
            </div>
        </div>
    </div>

    <!-- Shared Footer Fragment -->
    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
