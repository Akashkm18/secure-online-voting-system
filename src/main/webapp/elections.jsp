<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // Ensure elections list is available if visited directly
    if (request.getAttribute("elections") == null) {
        dao.ElectionDAO electionDao = new dao.ElectionDAO();
        request.setAttribute("elections", electionDao.getAllElections());
        model.User user = (model.User) session.getAttribute("user");
        if (user != null) {
            dao.VoteDAO voteDao = new dao.VoteDAO();
            request.setAttribute("votedElectionIds", voteDao.getUserVotedElectionIds(user.getId()));
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Browse campus elections, check status, view candidates, and view published results.">
    <title>Elections Directory | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <nav class="navbar" id="electionsNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/index.jsp" class="nav-link">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/elections" class="nav-link active">Elections</a></li>
            <li><a href="${pageContext.request.contextPath}/candidates" class="nav-link">Candidates</a></li>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <c:choose>
                        <c:when test="${sessionScope.user.admin}">
                            <li><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">Admin Dashboard</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/dashboard.jsp" class="nav-link">My Dashboard</a></li>
                            <li><a href="${pageContext.request.contextPath}/my-status.jsp" class="nav-link">My Status</a></li>
                        </c:otherwise>
                    </c:choose>
                    <li><a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a></li>
                </c:when>
                <c:otherwise>
                    <li><a href="${pageContext.request.contextPath}/login.jsp" class="nav-link">Sign In</a></li>
                    <li><a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-primary btn-sm">Register</a></li>
                </c:otherwise>
            </c:choose>
        </ul>
    </nav>

    <div class="container">
        <div style="margin-bottom: 2rem;">
            <h1>Campus Elections</h1>
            <p class="subtitle">Official listing of university student elections and certified tallies</p>
        </div>

        <c:if test="${not empty infoMessage}">
            <div class="alert alert-info">
                <span>ℹ️</span>
                <div><c:out value="${infoMessage}" /></div>
            </div>
        </c:if>

        <!-- Published Results Viewer (if results selected) -->
        <c:if test="${not empty selectedElection and not empty results}">
            <section class="card" style="margin-bottom: 3rem; border-color: rgba(168, 85, 247, 0.4); background: #161b2e;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <span class="status-badge status-published">CERTIFIED OFFICIAL RESULTS</span>
                        <h2 style="margin-top: 0.5rem;"><c:out value="${selectedElection.electionName}" /></h2>
                        <p style="color: var(--text-secondary); font-size: 0.9rem;">Final aggregated ballot tally</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/elections" class="btn btn-outline btn-sm">Close Results View ✕</a>
                </div>

                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Rank</th>
                                <th>Candidate</th>
                                <th>Party</th>
                                <th>Symbol</th>
                                <th>Vote Count</th>
                                <th>Percentage</th>
                                <th>Tally Bar</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cand" items="${results}" varStatus="status">
                                <tr>
                                    <td>
                                        <c:choose>
                                            <c:when test="${status.index == 0}">
                                                <span style="font-weight: 800; color: #fbbf24;">🥇 1st</span>
                                            </c:when>
                                            <c:when test="${status.index == 1}">
                                                <span style="font-weight: 700; color: #94a3b8;">🥈 2nd</span>
                                            </c:when>
                                            <c:when test="${status.index == 2}">
                                                <span style="font-weight: 700; color: #b45309;">🥉 3rd</span>
                                            </c:when>
                                            <c:otherwise>
                                                #${status.index + 1}
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td style="font-weight: 700;"><c:out value="${cand.candidateName}" /></td>
                                    <td><c:out value="${cand.party}" /></td>
                                    <td><span style="background: rgba(255,255,255,0.06); padding: 0.2rem 0.6rem; border-radius: var(--radius-sm);"><c:out value="${cand.symbol}" /></span></td>
                                    <td style="font-weight: 700; font-size: 1.05rem;"><c:out value="${cand.voteCount}" /></td>
                                    <td style="font-weight: 700; color: #38bdf8;"><c:out value="${cand.votePercentage}" />%</td>
                                    <td style="min-width: 140px;">
                                        <div class="progress-bar-container">
                                            <div class="progress-bar-fill" style="width: ${cand.votePercentage}%;"></div>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </section>
        </c:if>

        <!-- All Elections Cards -->
        <div class="grid-cards">
            <c:forEach var="election" items="${elections}">
                <div class="card" id="cardElection-${election.id}">
                    <div>
                        <div class="card-header">
                            <h3 style="font-size: 1.25rem;"><c:out value="${election.electionName}" /></h3>
                            <c:choose>
                                <c:when test="${election.status == 'ACTIVE'}">
                                    <span class="status-badge status-active">ACTIVE</span>
                                </c:when>
                                <c:when test="${election.status == 'UPCOMING'}">
                                    <span class="status-badge status-upcoming">UPCOMING</span>
                                </c:when>
                                <c:when test="${election.status == 'COMPLETED'}">
                                    <span class="status-badge status-completed">COMPLETED</span>
                                </c:when>
                                <c:when test="${election.status == 'PUBLISHED'}">
                                    <span class="status-badge status-published">PUBLISHED</span>
                                </c:when>
                            </c:choose>
                        </div>

                        <p style="color: var(--text-secondary); font-size: 0.9rem; margin-bottom: 1.25rem;">
                            <c:out value="${election.description}" />
                        </p>

                        <div style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 1.5rem; line-height: 1.6;">
                            <div>🕒 <strong>Start:</strong> <fmt:formatDate value="${election.startTime}" pattern="yyyy-MM-dd HH:mm" /></div>
                            <div>🏁 <strong>End:</strong> <fmt:formatDate value="${election.endTime}" pattern="yyyy-MM-dd HH:mm" /></div>
                            <c:if test="${election.totalVotes > 0}">
                                <div>📊 <strong>Total Ballots Cast:</strong> <c:out value="${election.totalVotes}" /></div>
                            </c:if>
                        </div>
                    </div>

                    <div style="display: flex; gap: 0.75rem; flex-wrap: wrap;">
                        <a href="${pageContext.request.contextPath}/candidates?electionId=${election.id}" class="btn btn-outline btn-sm">
                            Candidates
                        </a>

                        <c:if test="${election.status == 'ACTIVE'}">
                            <c:choose>
                                <c:when test="${not empty sessionScope.user and not sessionScope.user.admin}">
                                    <c:set var="userVoted" value="false" />
                                    <c:forEach var="votedId" items="${votedElectionIds}">
                                        <c:if test="${votedId == election.id}">
                                            <c:set var="userVoted" value="true" />
                                        </c:if>
                                    </c:forEach>

                                    <c:choose>
                                        <c:when test="${userVoted}">
                                            <a href="${pageContext.request.contextPath}/my-status.jsp?electionId=${election.id}" class="btn btn-success btn-sm">
                                                ✓ Voted (Receipt)
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/voting?electionId=${election.id}" class="btn btn-primary btn-sm">
                                                Cast Vote →
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </c:when>
                                <c:when test="${empty sessionScope.user}">
                                    <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-primary btn-sm">
                                        Sign In to Vote
                                    </a>
                                </c:when>
                            </c:choose>
                        </c:if>

                        <c:if test="${election.status == 'PUBLISHED'}">
                            <a href="${pageContext.request.contextPath}/results?electionId=${election.id}" class="btn btn-primary btn-sm" style="background: #9333ea;">
                                🏆 View Results
                            </a>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </div>
    </div>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
