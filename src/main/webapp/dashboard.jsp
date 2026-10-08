<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // Ensure dashboard data is always loaded for direct visits
    dao.ElectionDAO electionDao = new dao.ElectionDAO();
    dao.VoteDAO voteDao = new dao.VoteDAO();
    model.User currentUser = (model.User) session.getAttribute("user");
    if (currentUser != null) {
        request.setAttribute("activeElections", electionDao.getActiveElections());
        request.setAttribute("votedElectionIds", voteDao.getUserVotedElectionIds(currentUser.getId()));
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Voter Dashboard - View active student elections and verify your ballot status.">
    <title>Voter Dashboard | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <nav class="navbar" id="dashboardNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/dashboard.jsp" class="nav-link active" id="navDash">Dashboard</a></li>
            <li><a href="${pageContext.request.contextPath}/elections" class="nav-link" id="navElections">All Elections</a></li>
            <li><a href="${pageContext.request.contextPath}/my-status.jsp" class="nav-link" id="navMyStatus">My Voting Receipts</a></li>
        </ul>
        <div class="nav-user">
            <span class="badge-role badge-voter">Voter</span>
            <span style="font-weight: 600; font-size: 0.95rem;"><c:out value="${sessionScope.user.fullName}" /></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm" id="dashboardLogoutBtn">Logout</a>
        </div>
    </nav>

    <div class="container">
        <!-- Welcome Banner with Verified Student Identity Card -->
        <section style="margin-bottom: 2.5rem; background: linear-gradient(135deg, rgba(79, 70, 229, 0.18), rgba(16, 185, 129, 0.10)); border: 1px solid var(--border-glow); border-radius: var(--radius-lg); padding: 2rem; position: relative;">
            <div style="display: flex; gap: 1.75rem; align-items: center; flex-wrap: wrap;">
                <!-- Student Photo Frame -->
                <div style="width: 95px; height: 110px; border-radius: 8px; background: #1e1b4b; border: 2px solid #6366f1; overflow: hidden; display: flex; align-items: center; justify-content: center; box-shadow: 0 4px 15px rgba(99, 102, 241, 0.3); flex-shrink: 0;">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.photoBase64}">
                            <img src="${sessionScope.user.photoBase64}" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </c:when>
                        <c:when test="${not empty sessionScope.studentPhoto}">
                            <img src="${sessionScope.studentPhoto}" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </c:when>
                        <c:otherwise>
                            <span style="font-size: 3rem;">🎓</span>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Student Identity Information -->
                <div style="flex: 1; min-width: 280px;">
                    <div style="display: flex; gap: 0.5rem; align-items: center; margin-bottom: 0.4rem; flex-wrap: wrap;">
                        <span class="badge-role badge-voter">Official Student Voter</span>
                        <span class="status-badge status-active" style="font-size: 0.72rem; padding: 0.2rem 0.5rem;">
                            ✓ ID Card Verified: <c:out value="${sessionScope.user.collegeId != null ? sessionScope.user.collegeId : sessionScope.collegeId}" />
                        </span>
                    </div>

                    <h1 style="font-size: 2rem; margin-bottom: 0.35rem; color: #f8fafc;">
                        Welcome, <c:out value="${sessionScope.user.fullName}" />!
                    </h1>

                    <div style="color: #cbd5e1; font-size: 0.95rem; margin-bottom: 0.25rem;">
                        🏛️ <strong><c:out value="${sessionScope.user.collegeName != null ? sessionScope.user.collegeName : (sessionScope.collegeName != null ? sessionScope.collegeName : 'Alliance University')}" /></strong>
                    </div>

                    <div style="display: flex; gap: 1rem; color: #94a3b8; font-size: 0.875rem; flex-wrap: wrap;">
                        <span>🎓 Program: <strong style="color: #e2e8f0;"><c:out value="${sessionScope.user.programName != null ? sessionScope.user.programName : (sessionScope.programName != null ? sessionScope.programName : 'B.Tech')}" /></strong></span>
                        <span>📅 Joined: <strong style="color: #38bdf8;"><c:out value="${sessionScope.user.joiningYear != null ? sessionScope.user.joiningYear : (sessionScope.joiningYear != null ? sessionScope.joiningYear : '2024')}" /></strong></span>
                        <span>⏳ Standing: <strong style="color: #34d399;"><c:out value="${sessionScope.user.studyYear != null ? sessionScope.user.studyYear : (sessionScope.studyYear != null ? sessionScope.studyYear : '2nd Year')}" /></strong></span>
                    </div>

                    <p style="color: var(--text-muted); font-size: 0.85rem; margin-top: 0.6rem; margin-bottom: 0;">
                        Campus Email: <c:out value="${sessionScope.user.email}" /> • Secret Ballot Voting is strictly enforced.
                    </p>
                </div>
            </div>
        </section>

        <!-- Active Elections Section -->
        <section style="margin-bottom: 3.5rem;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem;">
                <div>
                    <h2>Active Elections</h2>
                    <p style="color: var(--text-secondary); font-size: 0.925rem;">Live ballots open for participation</p>
                </div>
                <a href="${pageContext.request.contextPath}/elections" class="btn btn-outline btn-sm" id="btnViewAllElections">View All Elections →</a>
            </div>

            <c:choose>
                <c:when test="${not empty activeElections}">
                    <div class="grid-cards">
                        <c:forEach var="election" items="${activeElections}">
                            <div class="card" id="electionCard-${election.id}">
                                <div>
                                    <div class="card-header">
                                        <h3 style="font-size: 1.25rem;"><c:out value="${election.electionName}" /></h3>
                                        <span class="status-badge status-active">ACTIVE</span>
                                    </div>
                                    <p style="color: var(--text-secondary); font-size: 0.9rem; margin-bottom: 1.25rem;">
                                        <c:out value="${election.description}" />
                                    </p>
                                    <div style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1.5rem; line-height: 1.6;">
                                        <div>🕒 <strong>Starts:</strong> <fmt:formatDate value="${election.startTime}" pattern="MMM dd, yyyy HH:mm" /></div>
                                        <div>🏁 <strong>Ends:</strong> <fmt:formatDate value="${election.endTime}" pattern="MMM dd, yyyy HH:mm" /></div>
                                    </div>
                                </div>

                                <div>
                                    <c:set var="hasVoted" value="false" />
                                    <c:forEach var="votedId" items="${votedElectionIds}">
                                        <c:if test="${votedId == election.id}">
                                            <c:set var="hasVoted" value="true" />
                                        </c:if>
                                    </c:forEach>

                                    <c:choose>
                                        <c:when test="${hasVoted}">
                                            <div style="background: var(--success-bg); border: 1px solid rgba(16, 185, 129, 0.3); border-radius: var(--radius-md); padding: 0.75rem 1rem; display: flex; align-items: center; justify-content: space-between;">
                                                <span style="color: var(--success); font-weight: 600; font-size: 0.9rem;">
                                                    ✅ Vote Recorded
                                                </span>
                                                <a href="${pageContext.request.contextPath}/my-status.jsp?electionId=${election.id}" class="btn btn-outline btn-sm" id="btnReceipt-${election.id}">
                                                    Receipt
                                                </a>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/voting?electionId=${election.id}" class="btn btn-primary btn-block" id="btnVoteNow-${election.id}">
                                                <span>🗳️</span> Cast Your Vote
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card" style="text-align: center; padding: 3rem;">
                        <div style="font-size: 2.5rem; margin-bottom: 1rem;">📋</div>
                        <h3>No Active Elections Right Now</h3>
                        <p style="color: var(--text-secondary); margin-bottom: 1.5rem;">There are currently no active elections accepting ballots. Check back soon!</p>
                        <a href="${pageContext.request.contextPath}/elections" class="btn btn-outline" id="btnBrowseAll">Browse Upcoming & Past Elections</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- Quick Links & Security Notice -->
        <section class="card" style="background: #111827; border-color: #1f2937;">
            <div style="display: flex; gap: 1.5rem; align-items: center; flex-wrap: wrap;">
                <div style="font-size: 2.2rem;">🛡️</div>
                <div style="flex: 1;">
                    <h4 style="font-size: 1.1rem; color: var(--text-primary); margin-bottom: 0.25rem;">Privacy Guarantee</h4>
                    <p style="color: var(--text-secondary); font-size: 0.9rem;">
                        Under the Ballot Secrecy Architecture, your specific candidate choice is detached and never revealed in this dashboard. You can review your tamper-evident receipt tokens in <a href="${pageContext.request.contextPath}/my-status.jsp" style="color: var(--primary-light);">My Voting Receipts</a>.
                    </p>
                </div>
            </div>
        </section>
    </div>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
