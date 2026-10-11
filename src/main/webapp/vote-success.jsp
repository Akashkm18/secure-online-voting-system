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

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="auth-wrapper" style="min-height: calc(100vh - 160px); padding-top: 2rem; padding-bottom: 3rem;">
        <div class="auth-card" style="max-width: 580px; text-align: center;">
            <div style="width: 56px; height: 56px; background: var(--success-bg); border: 1px solid rgba(16, 185, 129, 0.3); border-radius: 50%; display: flex; align-items: center; justify-content: center; margin: 0 auto 1.25rem auto; color: var(--success);">
                <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5">
                    <polyline points="20 6 9 17 4 12"/>
                </svg>
            </div>

            <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;">Ballot Recorded Successfully</h1>
            <p style="color: var(--text-secondary); font-size: 0.875rem; margin-bottom: 1.75rem;">
                Your ballot has been committed to the cryptographic ledger.
            </p>

            <div style="background: var(--bg-surface-elevated); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 1.25rem; text-align: left; margin-bottom: 1.5rem;">
                <div style="margin-bottom: 0.85rem;">
                    <span style="font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted);">Election</span>
                    <div style="font-size: 1rem; font-weight: 600; color: var(--text-primary);">
                        <c:out value="${sessionScope.lastVoteElection != null ? sessionScope.lastVoteElection : 'Active Election'}" />
                    </div>
                </div>

                <div style="margin-bottom: 0.85rem;">
                    <span style="font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted);">Timestamp</span>
                    <div style="font-size: 0.875rem; color: var(--text-secondary);">
                        <fmt:formatDate value="${sessionScope.lastVoteTime}" pattern="yyyy-MM-dd HH:mm:ss z" />
                    </div>
                </div>

                <div>
                    <span style="font-size: 0.72rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted);">Verification Receipt Hash (SHA-256)</span>
                    <div style="display: flex; gap: 0.5rem; align-items: center; margin-top: 0.35rem;">
                        <input type="text" id="receiptHashInput" readonly class="form-control" style="font-family: monospace; font-size: 0.82rem; background: var(--bg-surface); color: var(--primary); padding: 0.45rem 0.65rem;" value="<c:out value='${sessionScope.lastVoteHash != null ? sessionScope.lastVoteHash : \"\"}' />" />
                        <button type="button" class="btn btn-secondary btn-sm" id="btnCopyHash" onclick="copyReceiptHash()" style="flex-shrink: 0; display: inline-flex; align-items: center; gap: 0.35rem; padding: 0.45rem 0.75rem;">
                            <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="9" y="9" width="13" height="13" rx="2" ry="2"/>
                                <path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/>
                            </svg>
                            <span id="copyBtnText">Copy</span>
                        </button>
                    </div>
                </div>
            </div>

            <!-- Ballot Secrecy Notice -->
            <div class="alert alert-info" style="text-align: left; font-size: 0.82rem; margin-bottom: 1.75rem;">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink: 0;">
                    <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                    <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                </svg>
                <div>
                    <strong>Ballot Secrecy Protocol:</strong> To preserve voter confidentiality, your specific candidate choice is detached from your receipt token.
                </div>
            </div>

            <div style="display: flex; gap: 0.75rem; justify-content: center; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-primary btn-sm" id="btnReturnDashboard">
                    Return to Dashboard
                </a>
                <a href="${pageContext.request.contextPath}/my-status.jsp" class="btn btn-secondary btn-sm" id="btnViewAllReceipts">
                    My Voting History
                </a>
            </div>
        </div>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script>
        function copyReceiptHash() {
            var input = document.getElementById('receiptHashInput');
            if (input && input.value) {
                navigator.clipboard.writeText(input.value).then(function() {
                    var btnText = document.getElementById('copyBtnText');
                    if (btnText) {
                        btnText.textContent = 'Copied!';
                        setTimeout(function() {
                            btnText.textContent = 'Copy';
                        }, 2000);
                    }
                });
            }
        }
    </script>
</body>
</html>
