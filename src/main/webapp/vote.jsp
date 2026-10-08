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

    <nav class="navbar" id="voteNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/dashboard.jsp" class="nav-link">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/elections" class="nav-link">Elections</a></li>
            <li><a href="${pageContext.request.contextPath}/my-status.jsp" class="nav-link">My Status</a></li>
        </ul>
        <div class="nav-user">
            <span class="badge-role badge-voter">Voter</span>
            <span style="font-weight: 600;"><c:out value="${sessionScope.user.fullName}" /></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>
    </nav>

    <div class="container" style="max-width: 800px;">
        <!-- Election Header -->
        <div style="margin-bottom: 2rem;">
            <div style="display: flex; align-items: center; gap: 0.75rem; margin-bottom: 0.5rem;">
                <span class="status-badge status-active">OFFICIAL BALLOT</span>
                <span style="color: var(--text-muted); font-size: 0.85rem;">Election ID: #${election.id}</span>
            </div>
            <h1><c:out value="${election.electionName}" /></h1>
            <p style="color: var(--text-secondary); font-size: 1rem;"><c:out value="${election.description}" /></p>
        </div>

        <!-- Error Notification -->
        <c:if test="${not empty errorMessage}">
            <div class="alert alert-danger" id="alertVoteError">
                <span>⚠️</span>
                <div><c:out value="${errorMessage}" /></div>
            </div>
        </c:if>

        <!-- Ballot Instructions -->
        <div class="card" style="margin-bottom: 2rem; background: rgba(99, 102, 241, 0.08); border-color: rgba(99, 102, 241, 0.25);">
            <h4 style="margin-bottom: 0.5rem; color: #a5b4fc;">Voting Instructions</h4>
            <ul style="color: var(--text-secondary); font-size: 0.9rem; padding-left: 1.25rem; line-height: 1.6;">
                <li>Select one candidate card below by clicking it or checking the radio button.</li>
                <li>Once cast, your ballot is irreversibly committed to the database.</li>
                <li>A cryptographic SHA-256 verification hash receipt will be generated for your records.</li>
            </ul>
        </div>

        <!-- Ballot Submission Form -->
        <form action="${pageContext.request.contextPath}/voting" method="POST" id="ballotForm">
            <!-- CSRF Token -->
            <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
            <input type="hidden" name="electionId" value="${election.id}" />

            <div style="margin-bottom: 2rem;">
                <label style="font-size: 1rem; font-weight: 600; color: var(--text-primary); margin-bottom: 1rem;">
                    Select Your Candidate:
                </label>

                <c:choose>
                    <c:when test="${not empty candidates}">
                        <c:forEach var="candidate" items="${candidates}">
                            <div class="candidate-ballot-card" id="ballotCard-${candidate.id}">
                                <input type="radio" name="candidateId" value="${candidate.id}" id="candidateRadio-${candidate.id}" class="candidate-radio" required />
                                <div class="symbol-badge">
                                    <span>🗳️</span>
                                </div>
                                <div class="candidate-details">
                                    <div class="candidate-name"><c:out value="${candidate.candidateName}" /></div>
                                    <div class="candidate-party"><c:out value="${candidate.party}" /></div>
                                    <div style="font-size: 0.8rem; color: var(--text-muted); margin-top: 0.25rem;">Symbol: <strong><c:out value="${candidate.symbol}" /></strong></div>
                                </div>
                            </div>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <div class="alert alert-info">
                            <span>ℹ️</span>
                            <div>No active candidates registered for this election.</div>
                        </div>
                    </c:otherwise>
                </c:choose>
            </div>

            <div style="display: flex; gap: 1rem; align-items: center; justify-content: flex-end; margin-top: 2rem;">
                <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-outline" id="btnCancelBallot">
                    Cancel & Return
                </a>
                <button type="submit" class="btn btn-primary" id="btnSubmitVote" style="font-size: 1.05rem; padding: 0.85rem 2rem;">
                    <span>🔒</span> Confirm & Submit Vote
                </button>
            </div>
        </form>
    </div>

    <!-- Vote Confirmation Modal Dialog -->
    <div class="modal-overlay" id="voteConfirmModal">
        <div class="modal-box">
            <h3 class="modal-title">Confirm Ballot Submission</h3>
            <div class="modal-body">
                <p style="margin-bottom: 1rem; font-weight: 600; color: #f87171;">
                    Are you sure you want to submit your vote?
                </p>
                <p>
                    Your vote cannot be changed after submission. The database integrity constraint will permanently record your ballot for this election.
                </p>
            </div>
            <div class="modal-actions">
                <button type="button" class="btn btn-secondary" id="cancelVoteBtn">Review Ballot</button>
                <button type="button" class="btn btn-primary" id="confirmVoteBtn">Yes, Submit My Vote</button>
            </div>
        </div>
    </div>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
