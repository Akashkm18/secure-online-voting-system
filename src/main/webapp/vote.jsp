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

    <main class="container" style="max-width: 780px; padding-top: 2rem; padding-bottom: 3.5rem;">
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
                    Select one candidate card below. Once cast, your ballot is irreversibly sealed in the cryptographic ledger and an anonymous SHA-256 verification receipt hash will be issued.
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
                    Select Your Candidate:
                </label>

                <c:choose>
                    <c:when test="${not empty candidates}">
                        <div style="display: flex; flex-direction: column; gap: 0.75rem;">
                            <c:forEach var="candidate" items="${candidates}">
                                <div class="candidate-ballot-card" id="ballotCard-${candidate.id}" style="padding: 1.1rem 1.25rem;">
                                    <input type="radio" name="candidateId" value="${candidate.id}" id="candidateRadio-${candidate.id}" class="candidate-radio" required />

                                    <!-- Candidate Photo -->
                                    <div style="width: 58px; height: 58px; border-radius: 50%; overflow: hidden; background: var(--bg-surface); border: 2px solid var(--border-color); flex-shrink: 0; box-shadow: 0 2px 6px rgba(0,0,0,0.2);">
                                        <img src="${pageContext.request.contextPath}/candidate-photo?id=${candidate.id}" alt="${candidate.candidateName}" style="width: 100%; height: 100%; object-fit: cover; display: block;" loading="lazy">
                                    </div>

                                    <!-- Candidate Details -->
                                    <div class="candidate-details" style="flex: 1; min-width: 0;">
                                        <div class="candidate-name" style="font-size: 1.1rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.15rem;">
                                            <c:out value="${candidate.candidateName}" />
                                        </div>
                                        <div style="color: var(--primary); font-size: 0.85rem; font-weight: 600; margin-bottom: 0.15rem;">
                                            <c:out value="${candidate.position != null ? candidate.position : 'Candidate'}" />
                                        </div>
                                        <div class="candidate-party" style="font-size: 0.85rem; color: var(--text-secondary);">
                                            <c:out value="${candidate.party}" />
                                        </div>
                                    </div>

                                    <!-- Ballot Symbol Badge -->
                                    <div style="text-align: right; flex-shrink: 0;">
                                        <span class="badge badge-pending" style="font-size: 0.82rem; padding: 0.35rem 0.65rem;">
                                            <c:out value="${candidate.symbol}" />
                                        </span>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
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
                <button type="button" class="btn btn-primary" id="btnSubmitVote" style="font-size: 0.95rem; padding: 0.65rem 1.75rem;">
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
                    Are you sure you want to cast your official vote?
                </p>
                <p style="margin: 0;">
                    Your vote cannot be modified or withdrawn after submission. The system will irreversibly record your choice in the ledger and issue a cryptographic verification hash receipt.
                </p>
            </div>
            <div class="modal-actions" style="display: flex; gap: 0.75rem; justify-content: flex-end;">
                <button type="button" class="btn btn-secondary btn-sm" id="cancelVoteBtn">Review Ballot</button>
                <button type="button" class="btn btn-primary btn-sm" id="confirmVoteBtn">Confirm & Cast Vote</button>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/voter.js"></script>
</body>
</html>
