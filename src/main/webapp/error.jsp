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
    <title>System Notice | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="auth-wrapper" style="min-height: calc(100vh - 160px);">
        <div class="auth-card" style="max-width: 520px; text-align: center;">
            <div style="width: 56px; height: 56px; border-radius: 50%; background: rgba(239, 68, 68, 0.1); border: 1px solid rgba(239, 68, 68, 0.25); display: flex; align-items: center; justify-content: center; margin: 0 auto 1.25rem auto; color: var(--danger);">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
            </div>
            
            <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.5rem;">
                <c:choose>
                    <c:when test="${pageContext.errorData.statusCode == 404}">Page Not Found</c:when>
                    <c:when test="${pageContext.errorData.statusCode == 403}">Access Restricted</c:when>
                    <c:otherwise>System Notice</c:otherwise>
                </c:choose>
            </h1>
            
            <p style="color: var(--text-secondary); margin: 0.75rem 0 1.75rem 0; font-size: 0.9rem; line-height: 1.6;">
                <c:choose>
                    <c:when test="${not empty errorMessage}">
                        <c:out value="${errorMessage}" />
                    </c:when>
                    <c:when test="${pageContext.errorData.statusCode == 404}">
                        The requested election resource or page does not exist or has been relocated.
                    </c:when>
                    <c:when test="${pageContext.errorData.statusCode == 403}">
                        You do not possess the required credentials to access this system resource.
                    </c:when>
                    <c:otherwise>
                        An unexpected issue occurred while processing your request. For platform security, details have been logged in the audit ledger.
                    </c:otherwise>
                </c:choose>
            </p>

            <div style="display: flex; gap: 0.75rem; justify-content: center; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/index.jsp" class="btn btn-primary btn-sm" id="btnBackHome">
                    Return to Home
                </a>
                <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-secondary btn-sm" id="btnBackLogin">
                    Voter Sign In
                </a>
            </div>
        </div>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

</body>
</html>
