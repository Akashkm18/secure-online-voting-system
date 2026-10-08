<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Vote successfully recorded with cryptographic receipt hash.">
    <title>Vote Confirmed | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <nav class="navbar" id="successNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <div class="nav-user">
            <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-outline btn-sm">My Dashboard</a>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>
    </nav>

    <div class="auth-wrapper" style="min-height: calc(100vh - 180px);">
        <div class="auth-card" style="max-width: 600px; text-align: center;">
            <div style="width: 64px; height: 64px; background: rgba(16, 185, 129, 0.15); border-radius: var(--radius-full); display: flex; align-items: center; justify-content: center; font-size: 2.2rem; margin: 0 auto 1.5rem auto; color: var(--success); box-shadow: 0 0 20px rgba(16, 185, 129, 0.3);">
                ✓
            </div>

            <h2 style="color: var(--success); margin-bottom: 0.5rem;">Vote Cast Successfully!</h2>
            <p style="color: var(--text-secondary); margin-bottom: 2rem;">
                Your ballot has been securely and permanently committed to the database ledger.
            </p>

            <div style="background: rgba(255, 255, 255, 0.02); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 1.5rem; text-align: left; margin-bottom: 1.5rem;">
                <div style="margin-bottom: 1rem;">
                    <span style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted);">Election</span>
                    <div style="font-size: 1.1rem; font-weight: 700; color: var(--text-primary);">
                        <c:out value="${sessionScope.lastVoteElection != null ? sessionScope.lastVoteElection : 'Active Election'}" />
                    </div>
                </div>

                <div style="margin-bottom: 1rem;">
                    <span style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted);">Timestamp</span>
                    <div style="font-size: 0.95rem; color: var(--text-secondary);">
                        <fmt:formatDate value="${sessionScope.lastVoteTime}" pattern="yyyy-MM-dd HH:mm:ss z" />
                    </div>
                </div>

                <div>
                    <span style="font-size: 0.8rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted);">Cryptographic Receipt Token (SHA-256)</span>
                    <div class="receipt-box" style="margin-top: 0.5rem; margin-bottom: 0;">
                        <c:out value="${sessionScope.lastVoteHash != null ? sessionScope.lastVoteHash : '0x8f4d92a1c900e4...'}" />
                    </div>
                </div>
            </div>

            <!-- Ballot Secrecy Notice -->
            <div class="alert alert-info" style="text-align: left; font-size: 0.85rem; margin-bottom: 2rem;">
                <span>🔒</span>
                <div>
                    <strong>Ballot Secrecy Guarantee:</strong> To prevent coercion and maintain voter privacy, your specific candidate choice is detached and never revealed on this receipt.
                </div>
            </div>

            <div style="display: flex; gap: 1rem; justify-content: center;">
                <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-primary" id="btnReturnDashboard">
                    Return to Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/my-status.jsp" class="btn btn-outline" id="btnViewAllReceipts">
                    My Voting History
                </a>
            </div>
        </div>
    </div>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>
</body>
</html>
