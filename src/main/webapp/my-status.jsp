<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // Load voter's receipts
    model.User user = (model.User) session.getAttribute("user");
    if (user != null) {
        dao.ElectionDAO electionDao = new dao.ElectionDAO();
        dao.VoteDAO voteDao = new dao.VoteDAO();
        java.util.List<Integer> votedElectionIds = voteDao.getUserVotedElectionIds(user.getId());
        java.util.List<java.util.Map<String, Object>> receipts = new java.util.ArrayList<>();
        for (Integer eId : votedElectionIds) {
            java.util.Map<String, Object> r = voteDao.getVoteReceipt(eId, user.getId());
            if (r != null) {
                receipts.add(r);
            }
        }
        request.setAttribute("receipts", receipts);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="View your official voting receipts and proof of participation.">
    <title>My Receipts | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="container" style="padding-top: 2rem; padding-bottom: 3.5rem;">
        <div style="margin-bottom: 2rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
            <div>
                <h1 style="font-size: 1.75rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;">Voting Receipts & Ledger</h1>
                <p style="color: var(--text-secondary); font-size: 0.95rem;">Cryptographic verification proof for your submitted ballots</p>
            </div>
            <!-- Voter Identity Token -->
            <div style="display: flex; gap: 0.75rem; align-items: center; background: var(--bg-surface-elevated); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 0.5rem 0.85rem;">
                <div style="width: 38px; height: 44px; border-radius: 4px; background: var(--bg-surface); border: 1px solid var(--border-color); overflow: hidden; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.photoBase64}">
                            <img src="${sessionScope.user.photoBase64}" alt="Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </c:when>
                        <c:otherwise>
                            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--text-muted);">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                <circle cx="12" cy="7" r="4"/>
                            </svg>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div style="font-size: 0.82rem;">
                    <strong style="color: var(--text-primary); display: block;"><c:out value="${sessionScope.user.fullName}" /></strong>
                    <span style="color: var(--primary); font-family: monospace; font-size: 0.75rem;"><c:out value="${sessionScope.user.collegeId}" /></span>
                    <c:if test="${not empty sessionScope.user.programName}">
                        <div style="color: var(--text-muted); font-size: 0.72rem;"><c:out value="${sessionScope.user.programName}" /></div>
                    </c:if>
                </div>
            </div>
        </div>

        <c:choose>
            <c:when test="${not empty receipts}">
                <div style="display: flex; flex-direction: column; gap: 1.25rem;">
                    <c:forEach var="r" items="${receipts}" varStatus="loop">
                        <div class="card" style="background: var(--bg-surface-elevated);">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.85rem; flex-wrap: wrap; gap: 0.5rem;">
                                <div>
                                    <h3 style="font-size: 1.15rem; font-weight: 600; color: var(--text-primary);"><c:out value="${r.electionName}" /></h3>
                                    <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 0.2rem;">
                                        Cast at: <fmt:formatDate value="${r.votedAt}" pattern="MMM dd, yyyy HH:mm:ss" />
                                    </div>
                                </div>
                                <span class="badge badge-active">Ballot Committed</span>
                            </div>

                            <div style="margin-bottom: 0.85rem;">
                                <label style="font-size: 0.72rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; display: block; margin-bottom: 0.25rem;">Cryptographic Receipt Hash (SHA-256)</label>
                                <div style="display: flex; gap: 0.5rem; align-items: center;">
                                    <input type="text" id="hash_${loop.index}" readonly class="form-control" style="font-family: monospace; font-size: 0.82rem; background: var(--bg-surface); color: var(--primary); padding: 0.45rem 0.65rem;" value="<c:out value='${r.voteHash}' />" />
                                    <button type="button" class="btn btn-secondary btn-sm" onclick="copyReceipt('${loop.index}', this)" style="flex-shrink: 0; padding: 0.45rem 0.75rem;">
                                        Copy
                                    </button>
                                </div>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.8rem; color: var(--text-secondary); border-top: 1px solid var(--border-color); padding-top: 0.75rem;">
                                <span style="display: inline-flex; align-items: center; gap: 0.35rem;">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><rect x="3" y="11" width="18" height="11" rx="2" ry="2"/><path d="M7 11V7a5 5 0 0 1 10 0v4"/></svg>
                                    Ballot choice protected by privacy protocol
                                </span>
                                <span style="color: var(--success); font-weight: 600;">Verified Counted</span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card empty-state">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--text-muted); margin-bottom: 0.75rem;">
                        <rect x="2" y="7" width="20" height="14" rx="2" ry="2"/>
                        <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>
                    </svg>
                    <h3 style="font-size: 1.1rem; margin-bottom: 0.35rem;">No Ballots Cast Yet</h3>
                    <p style="color: var(--text-secondary); font-size: 0.875rem; margin-bottom: 1.25rem;">
                        You have not submitted a vote in any active election.
                    </p>
                    <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-primary btn-sm">
                        Browse Active Elections
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script>
        function copyReceipt(id, btn) {
            var input = document.getElementById('hash_' + id);
            if (input && input.value) {
                navigator.clipboard.writeText(input.value).then(function() {
                    var orig = btn.textContent;
                    btn.textContent = 'Copied!';
                    setTimeout(function() { btn.textContent = orig; }, 2000);
                });
            }
        }
    </script>
</body>
</html>
