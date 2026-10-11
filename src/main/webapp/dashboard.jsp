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
    <meta name="description" content="Voter Dashboard - View active elections and verify your ballot status.">
    <title>Voter Dashboard | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="container" style="padding-top: 2rem; padding-bottom: 3.5rem;">
        <!-- Welcome Banner with Verified Student Identity Card -->
        <section class="card" style="margin-bottom: 2rem; background: var(--bg-surface-elevated); border: 1px solid var(--border-color); padding: 1.75rem;">
            <div style="display: flex; gap: 1.5rem; align-items: center; flex-wrap: wrap;">
                <!-- Student Photo Frame -->
                <div style="width: 84px; height: 100px; border-radius: var(--radius-md); background: var(--bg-surface); border: 1px solid var(--border-color); overflow: hidden; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <c:choose>
                        <c:when test="${not empty sessionScope.user.photoBase64}">
                            <img src="${sessionScope.user.photoBase64}" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </c:when>
                        <c:when test="${not empty sessionScope.studentPhoto}">
                            <img src="${sessionScope.studentPhoto}" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </c:when>
                        <c:otherwise>
                            <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--text-muted);">
                                <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                <circle cx="12" cy="7" r="4"/>
                            </svg>
                        </c:otherwise>
                    </c:choose>
                </div>

                <!-- Student Identity Information -->
                <div style="flex: 1; min-width: 260px;">
                    <div style="display: flex; gap: 0.5rem; align-items: center; margin-bottom: 0.35rem; flex-wrap: wrap;">
                        <span class="badge badge-active">Authorized Voter</span>
                        <c:if test="${not empty sessionScope.user.collegeId || not empty sessionScope.collegeId}">
                            <span class="badge badge-pending">
                                ID: <c:out value="${sessionScope.user.collegeId != null ? sessionScope.user.collegeId : sessionScope.collegeId}" />
                            </span>
                        </c:if>
                    </div>

                    <h1 style="font-size: 1.65rem; font-weight: 700; margin-bottom: 0.25rem; color: var(--text-primary);">
                        Welcome, <c:out value="${sessionScope.user.fullName}" />
                    </h1>

                    <c:if test="${not empty sessionScope.user.collegeName || not empty sessionScope.collegeName}">
                        <div style="color: var(--text-secondary); font-size: 0.9rem; margin-bottom: 0.35rem;">
                            <strong><c:out value="${sessionScope.user.collegeName != null ? sessionScope.user.collegeName : sessionScope.collegeName}" /></strong>
                        </div>
                    </c:if>

                    <div style="display: flex; gap: 1rem; color: var(--text-muted); font-size: 0.85rem; flex-wrap: wrap;">
                        <c:if test="${not empty sessionScope.user.programName || not empty sessionScope.programName}">
                            <span>Program: <strong style="color: var(--text-secondary);"><c:out value="${sessionScope.user.programName != null ? sessionScope.user.programName : sessionScope.programName}" /></strong></span>
                        </c:if>
                        <c:if test="${not empty sessionScope.user.joiningYear || not empty sessionScope.joiningYear}">
                            <span>Admitted: <strong style="color: var(--text-secondary);"><c:out value="${sessionScope.user.joiningYear != null ? sessionScope.user.joiningYear : sessionScope.joiningYear}" /></strong></span>
                        </c:if>
                        <c:if test="${not empty sessionScope.user.studyYear || not empty sessionScope.studyYear}">
                            <span>Year: <strong style="color: var(--text-secondary);"><c:out value="${sessionScope.user.studyYear != null ? sessionScope.user.studyYear : sessionScope.studyYear}" /></strong></span>
                        </c:if>
                    </div>

                    <p style="color: var(--text-muted); font-size: 0.8rem; margin-top: 0.5rem; margin-bottom: 0;">
                        Campus Email: <c:out value="${sessionScope.user.email}" /> • End-to-end ballot secrecy is enforced.
                    </p>
                </div>
            </div>
        </section>

        <!-- Active Elections Section -->
        <section style="margin-bottom: 2.5rem;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 0.5rem;">
                <div>
                    <h2 style="font-size: 1.35rem; font-weight: 700; margin-bottom: 0.2rem;">Active Elections</h2>
                    <p style="color: var(--text-secondary); font-size: 0.875rem;">Ballots currently open for voting</p>
                </div>
                <a href="${pageContext.request.contextPath}/elections" class="btn btn-secondary btn-sm" id="btnViewAllElections">View All Elections</a>
            </div>

            <c:choose>
                <c:when test="${not empty activeElections}">
                    <div class="grid-cards">
                        <c:forEach var="election" items="${activeElections}">
                            <div class="card" id="electionCard-${election.id}">
                                <div>
                                    <div class="card-header">
                                        <h3 style="font-size: 1.15rem; font-weight: 600;"><c:out value="${election.electionName}" /></h3>
                                        <span class="badge badge-active">ACTIVE</span>
                                    </div>
                                    <p style="color: var(--text-secondary); font-size: 0.875rem; margin-bottom: 1rem; line-height: 1.5;">
                                        <c:out value="${election.description}" />
                                    </p>
                                    <div style="font-size: 0.82rem; color: var(--text-muted); margin-bottom: 1.25rem; line-height: 1.6;">
                                        <div><strong>Starts:</strong> <fmt:formatDate value="${election.startTime}" pattern="MMM dd, yyyy HH:mm" /></div>
                                        <div><strong>Ends:</strong> <fmt:formatDate value="${election.endTime}" pattern="MMM dd, yyyy HH:mm" /></div>
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
                                            <div style="background: var(--success-bg); border: 1px solid rgba(16, 185, 129, 0.3); border-radius: var(--radius-md); padding: 0.65rem 0.85rem; display: flex; align-items: center; justify-content: space-between;">
                                                <span style="color: var(--success); font-weight: 600; font-size: 0.85rem; display: inline-flex; align-items: center; gap: 0.35rem;">
                                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.5"><polyline points="20 6 9 17 4 12"/></svg>
                                                    Ballot Cast
                                                </span>
                                                <a href="${pageContext.request.contextPath}/my-status.jsp?electionId=${election.id}" class="btn btn-secondary btn-sm" id="btnReceipt-${election.id}">
                                                    View Receipt
                                                </a>
                                            </div>
                                        </c:when>
                                        <c:otherwise>
                                            <a href="${pageContext.request.contextPath}/voting?electionId=${election.id}" class="btn btn-primary btn-block" id="btnVoteNow-${election.id}">
                                                Vote Now
                                            </a>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </div>
                        </c:forEach>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="card empty-state">
                        <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--text-muted); margin-bottom: 0.75rem;">
                            <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                            <line x1="16" y1="2" x2="16" y2="6"/>
                            <line x1="8" y1="2" x2="8" y2="6"/>
                            <line x1="3" y1="10" x2="21" y2="10"/>
                        </svg>
                        <h3 style="font-size: 1.1rem; margin-bottom: 0.35rem;">No Active Elections</h3>
                        <p style="color: var(--text-secondary); font-size: 0.875rem; margin-bottom: 1.25rem;">There are currently no active ballots accepting votes.</p>
                        <a href="${pageContext.request.contextPath}/elections" class="btn btn-secondary btn-sm" id="btnBrowseAll">Browse Upcoming & Completed Elections</a>
                    </div>
                </c:otherwise>
            </c:choose>
        </section>

        <!-- Privacy & Verification Notice -->
        <section class="card" style="background: var(--bg-surface-elevated); border-color: var(--border-color); padding: 1.25rem;">
            <div style="display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;">
                <div style="width: 36px; height: 36px; border-radius: 8px; background: rgba(37, 99, 235, 0.1); color: var(--primary); display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    </svg>
                </div>
                <div style="flex: 1; min-width: 240px;">
                    <h4 style="font-size: 0.95rem; font-weight: 600; color: var(--text-primary); margin-bottom: 0.2rem;">Ballot Secrecy Architecture</h4>
                    <p style="color: var(--text-secondary); font-size: 0.82rem; margin: 0;">
                        Your voter identity is decoupled from your ballot selections. Review your cryptographic receipt hash anytime in <a href="${pageContext.request.contextPath}/my-status.jsp" style="color: var(--primary); text-decoration: underline;">My Voting Receipts</a>.
                    </p>
                </div>
            </div>
        </section>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

</body>
</html>
