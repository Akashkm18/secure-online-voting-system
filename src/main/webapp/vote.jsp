<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Cast your official vote securely with cryptographic ballot integrity.">
    <title>Official Ballot | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="container" style="max-width: 760px; padding-top: 2rem; padding-bottom: 3.5rem;">
        <!-- Election Header -->
        <div style="margin-bottom: 1.75rem;">
            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem;">
                <span class="badge badge-active">Official Ballot</span>
                <span style="color: var(--text-muted); font-size: 0.8rem; font-family: monospace;">ELECTION #${election.id}</span>
            </div>
            <h1 style="font-size: 1.65rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;"><c:out value="${election.electionName}" /></h1>
            <p style="color: var(--text-secondary); font-size: 0.95rem; line-height: 1.5;"><c:out value="${election.description}" /></p>
        </div>

        <!-- Error Notification -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" id="alertVoteError">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="8" x2="12" y2="12"/>
                    <line x1="12" y1="16" x2="12.01" y2="16"/>
                </svg>
                <div><c:out value="${errorMessage}" /></div>
            </div>
        </c:if>

        <!-- Ballot Instructions -->
        <div class="card" style="margin-bottom: 1.75rem; background: var(--bg-surface-elevated); border-color: var(--border-color); padding: 1.25rem;">
            <div style="display: flex; gap: 0.75rem; align-items: flex-start;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--primary); margin-top: 2px; flex-shrink: 0;">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                <div style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.6;">
                    <strong style="color: var(--text-primary); display: block; margin-bottom: 0.25rem;">Ballot Instructions</strong>
                    Select one candidate card below. Once cast, your ballot is irreversibly recorded in the cryptographic ledger and a SHA-256 verification receipt hash will be provided.
                </div>
            </div>
        </div>

        <!-- Ballot Submission Form -->
        <form action="${pageContext.request.contextPath}/voting" method="POST" id="ballotForm">
            <!-- CSRF Token -->
            <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
            <input type="hidden" name="electionId" value="${election.id}" />

            <div style="margin-bottom: 2rem;">
                <label style="font-size: 0.95rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.85rem; display: block;">
                    Select Candidate:
                </label>

                <c:choose>
                    <c:when test="${not empty candidates}">
                        <c:forEach var="candidate" items="${candidates}">
                            <div class="candidate-ballot-card" id="ballotCard-${candidate.id}">
                                <input type="radio" name="candidateId" value="${candidate.id}" id="candidateRadio-${candidate.id}" class="candidate-radio" required />
                                <div style="width: 40px; height: 40px; border-radius: 8px; background: rgba(37, 99, 235, 0.1); color: var(--primary); display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                        <circle cx="12" cy="7" r="4"/>
                                    </svg>
                                </div>
                                <div class="candidate-details">
                                    <div class="candidate-name"><c:out value="${candidate.candidateName}" /></div>
                                    <div class="candidate-party"><c:out value="${candidate.party}" /></div>
                                    <div style="font-size: 0.78rem; color: var(--text-muted); margin-top: 0.2rem;">Symbol: <strong><c:out value="${candidate.symbol}" /></strong></div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-info">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                                <circle cx="12" cy="12" r="10"/>
                                <line x1="12" y1="16" x2="12" y2="12"/>
                                <line x1="12" y1="8" x2="12.01" y2="8"/>
                            </svg>
                            <div>No active candidates registered for this election.</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div style="display: flex; gap: 0.75rem; align-items: center; justify-content: flex-end; margin-top: 2rem;">
                <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-secondary" id="btnCancelBallot">
                    Cancel & Return
                </a>
                <button type="submit" class="btn btn-primary" id="btnSubmitVote" style="font-size: 0.95rem; padding: 0.65rem 1.75rem;">
                    Review & Confirm Vote
                </button>
            </div>
        </form>
    </main>

    <!-- Vote Confirmation Modal Dialog -->
    <div class="modal-overlay" id="voteConfirmModal">
        <div class="modal-box">
            <h3 class="modal-title" style="margin-top: 0; font-size: 1.15rem; color: var(--text-primary);">Confirm Ballot Submission</h3>
            <div class="modal-body" style="padding: 1rem 0; font-size: 0.9rem; line-height: 1.6; color: var(--text-secondary);">
                <p style="margin-bottom: 0.75rem; font-weight: 600; color: var(--danger);">
                    Are you sure you want to submit your ballot?
                </p>
                <p style="margin: 0;">
                    Your vote cannot be modified after submission. The system will irrevocably seal your vote and issue an anonymous cryptographic receipt hash.
                </p>
            </div>
            <div class="modal-actions" style="display: flex; gap: 0.75rem; justify-content: flex-end;">
                <button type="button" class="btn btn-secondary btn-sm" id="cancelVoteBtn">Review Ballot</button>
                <button type="button" class="btn btn-primary btn-sm" id="confirmVoteBtn">Confirm & Submit</button>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
