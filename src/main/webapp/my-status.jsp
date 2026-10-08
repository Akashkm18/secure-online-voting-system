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
    <title>My Voting Receipts | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <nav class="navbar" id="statusNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/dashboard.jsp" class="nav-link">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/elections" class="nav-link">Elections</a></li>
            <li><a href="${pageContext.request.contextPath}/my-status.jsp" class="nav-link active">My Status</a></li>
        </ul>
        <div class="nav-user">
            <span class="badge-role badge-voter">Voter</span>
            <span style="font-weight: 600;"><c:out value="${sessionScope.user.fullName}" /></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>
    </nav>

    <div class="container">
        <div style="margin-bottom: 2rem; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 1rem;">
            <div>
                <h1>My Voting Status & Receipts</h1>
                <p class="subtitle">Cryptographic verification ledger for your submitted ballots</p>
            </div>
            <!-- Student Mini Identity Badge -->
            <div style="display: flex; gap: 0.75rem; align-items: center; background: rgba(255,255,255,0.03); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 0.5rem 1rem;">
                <div style="width: 44px; height: 50px; border-radius: 4px; background: #1e1b4b; border: 1px solid #6366f1; overflow: hidden; display: flex; align-items: center; justify-content: center;">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.photoBase64}">
                            <img src="${sessionScope.user.photoBase64}" alt="Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </c:when>
                        <c:otherwise>
                            <span style="font-size: 1.4rem;">🎓</span>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div style="font-size: 0.85rem;">
                    <strong style="color: #f8fafc; display: block;"><c:out value="${sessionScope.user.fullName}" /></strong>
                    <span style="color: #818cf8; font-family: monospace; font-size: 0.78rem;"><c:out value="${sessionScope.user.collegeId}" /></span>
                    <div style="color: #94a3b8; font-size: 0.75rem;"><c:out value="${sessionScope.user.programName != null ? sessionScope.user.programName : 'B.Tech'}" /></div>
                </div>
            </div>
        </div>

        <c:choose>
            <c:when test="${not empty receipts}">
                <div style="display: flex; flex-direction: column; gap: 1.5rem;">
                    <c:forEach var="r" items="${receipts}">
                        <div class="card" style="background: var(--bg-surface);">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.5rem;">
                                <div>
                                    <h3 style="font-size: 1.25rem;"><c:out value="${r.electionName}" /></h3>
                                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.25rem;">
                                        Cast at: <fmt:formatDate value="${r.votedAt}" pattern="MMM dd, yyyy HH:mm:ss" />
                                    </div>
                                </div>
                                <span class="status-badge status-active">BALLOT COMMITTED</span>
                            </div>

                            <div>
                                <label style="font-size: 0.8rem; color: var(--text-muted); text-transform: uppercase;">Cryptographic Receipt Hash (SHA-256)</label>
                                <div class="receipt-box" style="margin: 0.5rem 0;">
                                    <c:out value="${r.voteHash}" />
                                </div>
                            </div>

                            <div style="display: flex; justify-content: space-between; align-items: center; margin-top: 0.75rem; font-size: 0.85rem; color: var(--text-secondary);">
                                <span>🔒 Candidate Choice Protected by Privacy Protocol</span>
                                <span style="color: var(--success); font-weight: 600;">Verified Counted</span>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card" style="text-align: center; padding: 3rem;">
                    <div style="font-size: 2.5rem; margin-bottom: 1rem;">🎫</div>
                    <h3>No Ballots Cast Yet</h3>
                    <p style="color: var(--text-secondary); margin-bottom: 1.5rem;">
                        You have not submitted a vote in any active election.
                    </p>
                    <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-primary">
                        Browse Active Elections
                    </a>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
