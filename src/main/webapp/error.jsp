<%@ page contentType="text/html;charset=UTF-8" language="java" isErrorPage="true" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Security check: never display technical exception message or stack trace to client
    if (exception != null) {
        // Log technical stack trace on the server side only
        application.log("Uncaught Exception intercepted by error.jsp: " + exception.getMessage(), exception);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Error Encountered | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <nav class="navbar" id="errorNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
    </nav>

    <div class="auth-wrapper">
        <div class="auth-card" style="max-width: 500px; text-align: center;">
            <div style="font-size: 3rem; margin-bottom: 1rem;">⚠️</div>
            <h2>Notice</h2>
            
            <p style="color: var(--text-secondary); margin: 1.25rem 0 2rem 0; font-size: 0.95rem;">
                <c:choose>
                    <c:when test="${not empty errorMessage}">
                        <c:out value="${errorMessage}" />
                    </c:when>
                    <c:when test="${pageContext.errorData.statusCode == 404}">
                        The requested page or resource could not be found.
                    </c:when>
                    <c:when test="${pageContext.errorData.statusCode == 403}">
                        Access denied. You do not have permission to view this resource.
                    </c:when>
                    <c:otherwise>
                        An unexpected issue occurred while processing your request. For security reasons, details have been logged on the server.
                    </c:otherwise>
                </c:choose>
            </p>

            <div style="display: flex; gap: 1rem; justify-content: center;">
                <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary" id="btnBackHome">
                    Return to Home
                </a>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-outline" id="btnBackLogin">
                    Sign In
                </a>
            </div>
        </div>
    </div>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>
</body>
</html>
