<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
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

    <nav class="navbar" id="adminLoginNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
            <div class="brand-icon" style="background: linear-gradient(135deg, #f59e0b, #d97706);">🛡️</div>
            <span>Election Administration</span>
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/index.jsp" class="nav-link">Main Site</a></li>
            <li><a href="${pageContext.request.contextPath}/login.jsp" class="nav-link">Voter Login</a></li>
        </ul>
    </nav>

    <div class="auth-wrapper">
        <div class="auth-card" id="adminLoginFormCard" style="border-top-color: #f59e0b;">
            <div style="text-align: center; margin-bottom: 2rem;">
                <div class="brand-icon" style="margin: 0 auto 1rem auto; width: 48px; height: 48px; font-size: 1.5rem; background: linear-gradient(135deg, #f59e0b, #d97706);">🔑</div>
                <h2>Admin Sign In</h2>
                <p style="color: var(--text-secondary); font-size: 0.9rem;">Authorized election personnel access only</p>
            </div>

            <!-- Error Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" id="alertAdminError">
                    <span>⚠️</span>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <c:if test="${param.error == 'unauthorized'}">
                <div class="alert alert-danger">
                    <span>🔒</span>
                    <div>Please sign in with administrator credentials.</div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/admin/login" method="POST" id="adminLoginForm" autocomplete="off">
                <!-- CSRF Token -->
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />

                <div class="form-group">
                    <label for="adminEmail">Administrator Email</label>
                    <input type="email" id="adminEmail" name="email" class="form-control" 
                           placeholder="admin@voting.edu" required />
                </div>

                <div class="form-group">
                    <label for="adminPassword">Administrator Password</label>
                    <input type="password" id="adminPassword" name="password" class="form-control" 
                           placeholder="••••••••" required />
                </div>

                <button type="submit" class="btn btn-primary btn-block" id="submitAdminLoginBtn" 
                        style="margin-top: 1.5rem; background: linear-gradient(135deg, #d97706, #f59e0b); color: #000; font-weight: 700;">
                    Authenticate as Admin
                </button>
            </form>

            <div style="margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid var(--border-color); text-align: center; font-size: 0.85rem; color: var(--text-muted);">
                Default Seed Account: <code>admin@voting.edu</code> / <code>Admin@123</code>
                <div style="margin-top: 0.75rem;">
                    <a href="${pageContext.request.contextPath}/login.jsp" style="color: var(--primary-light);">
                        ← Back to Voter Sign In
                    </a>
                </div>
            </div>
        </div>
    </div>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
