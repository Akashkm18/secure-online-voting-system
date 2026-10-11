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

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="container" style="padding-top: 2rem; padding-bottom: 3.5rem;">
        <div style="margin-bottom: 2rem;">
            <h1 style="font-size: 1.75rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;">Campus Elections</h1>
            <p style="color: var(--text-secondary); font-size: 0.95rem;">Official directory of institutional elections and certified tallies</p>
        </div>

        <c:if test="${not empty infoMessage}">
            <div class="alert alert-info">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                <div><c:out value="${infoMessage}" /></div>
            </div>
        </c:if>

        <!-- Published Results Viewer (if results selected) -->
        <c:if test="${not empty selectedElection and not empty results}">
            <section class="card" style="margin-bottom: 2.5rem; border-color: var(--primary); background: var(--bg-surface-elevated);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <span class="badge badge-published" style="margin-bottom: 0.35rem;">Certified Results</span>
                        <h2 style="font-size: 1.35rem; font-weight: 700; color: var(--text-primary);"><c:out value="${selectedElection.electionName}" /></h2>
                        <p style="color: var(--text-secondary); font-size: 0.875rem;">Official aggregated ballot outcome</p>
                    </div>
                    <a href="${pageContext.request.contextPath}/elections" class="btn btn-secondary btn-sm">Close Results</a>
                </div>

                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 80px;">Rank</th>
                                <th>Candidate</th>
                                <th>Affiliation / Party</th>
                                <th>Ballot Symbol</th>
                                <th>Vote Count</th>
                                <th>Share</th>
                                <th style="min-width: 140px;">Distribution</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="cand" items="${results}" varStatus="status">
                                <tr>
                                    <td style="font-weight: 600; color: var(--text-primary);">
                                        #${status.index + 1}
                                    </td>
                                    <td style="font-weight: 600; color: var(--text-primary);"><c:out value="${cand.candidateName}" /></td>
                                    <td><c:out value="${cand.party}" /></td>
                                    <td><span class="badge badge-pending"><c:out value="${cand.symbol}" /></span></td>
                                    <td style="font-weight: 700;"><c:out value="${cand.voteCount}" /></td>
                                    <td style="font-weight: 700; color: var(--primary);"><c:out value="${cand.votePercentage}" />%</td>
                                    <td>
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
                            <h3 style="font-size: 1.15rem; font-weight: 600;"><c:out value="${election.electionName}" /></h3>
                            <c:choose>
                                <c:when test="${election.status == 'ACTIVE'}">
                                    <span class="badge badge-active">ACTIVE</span>
                                </c:when>
                                <c:when test="${election.status == 'UPCOMING'}">
                                    <span class="badge badge-upcoming">UPCOMING</span>
                                </c:when>
                                <c:when test="${election.status == 'COMPLETED'}">
                                    <span class="badge badge-completed">COMPLETED</span>
                                </c:when>
                                <c:when test="${election.status == 'PUBLISHED'}">
                                    <span class="badge badge-published">PUBLISHED</span>
                                </c:when>
                            </c:choose>
                        </div>

                        <p style="color: var(--text-secondary); font-size: 0.875rem; margin-bottom: 1.25rem; line-height: 1.5;">
                            <c:out value="${election.description}" />
                        </p>

                        <div style="font-size: 0.82rem; color: var(--text-muted); margin-bottom: 1.5rem; line-height: 1.6;">
                            <div><strong>Start:</strong> <fmt:formatDate value="${election.startTime}" pattern="yyyy-MM-dd HH:mm" /></div>
                            <div><strong>End:</strong> <fmt:formatDate value="${election.endTime}" pattern="yyyy-MM-dd HH:mm" /></div>
                            <c:if test="${election.totalVotes > 0}">
                                <div><strong>Total Ballots Cast:</strong> <c:out value="${election.totalVotes}" /></div>
                            </c:if>
                        </div>
                    </div>

                    <div style="display: flex; gap: 0.5rem; flex-wrap: wrap; margin-top: auto;">
                        <a href="${pageContext.request.contextPath}/candidates?electionId=${election.id}" class="btn btn-secondary btn-sm">
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
                                            <a href="${pageContext.request.contextPath}/my-status.jsp?electionId=${election.id}" class="btn btn-secondary btn-sm" style="color: var(--success);">
                                                ✓ Receipt
                                            </a>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/voting?electionId=${election.id}" class="btn btn-primary btn-sm">
                                                Vote
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
                            <a href="${pageContext.request.contextPath}/results?electionId=${election.id}" class="btn btn-primary btn-sm">
                                View Results
                            </a>
                        </c:if>
                    </div>
                </div>
            </c:forEach>
        </div>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

</body>
</html>
