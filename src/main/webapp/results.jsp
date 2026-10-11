<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="View certified election tallies, voter turnout percentages, and official candidate results.">
    <title>Certified Results | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="container" style="padding-top: 2rem; padding-bottom: 3.5rem;">
        <div style="margin-bottom: 2rem; display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
            <div>
                <div style="display: flex; align-items: center; gap: 0.5rem; margin-bottom: 0.35rem;">
                    <span class="badge badge-published">Official Certified Outcomes</span>
                </div>
                <h1 style="font-size: 1.75rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">Election Results & Certified Tallies</h1>
                <p style="color: var(--text-secondary); font-size: 0.95rem;">Cryptographically verified ballot outcomes released by the Election Commission</p>
            </div>

            <!-- Election Selector Form (GET, CSP compliant, no inline onchange) -->
            <form action="${pageContext.request.contextPath}/results" method="get" style="display: flex; gap: 0.5rem; align-items: center; background: var(--bg-surface-elevated); padding: 0.5rem 0.75rem; border-radius: var(--radius-md); border: 1px solid var(--border-color);">
                <label for="electionSelect" style="font-size: 0.82rem; font-weight: 600; color: var(--text-muted); white-space: nowrap;">Election:</label>
                <select name="electionId" id="electionSelect" class="form-control" style="font-size: 0.85rem; padding: 0.4rem 0.6rem; min-width: 220px;">
                    <c:forEach var="el" items="${allElections}">
                        <c:if test="${el.published or sessionScope.user.admin}">
                            <option value="${el.id}" ${selectedElection != null and selectedElection.id == el.id ? 'selected' : ''}>
                                <c:out value="${el.electionName}"/> <c:if test="${not el.published}">(Admin Preview: ${el.status})</c:if>
                            </option>
                        </c:if>
                    </c:forEach>
                </select>
                <button type="submit" class="btn btn-primary btn-sm" id="btnLoadResults">Load Tally</button>
            </form>
        </div>

        <c:if test="${not empty infoMessage}">
            <div class="alert alert-info" style="margin-bottom: 2rem;">
                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                    <circle cx="12" cy="12" r="10"/>
                    <line x1="12" y1="16" x2="12" y2="12"/>
                    <line x1="12" y1="8" x2="12.01" y2="8"/>
                </svg>
                <div><c:out value="${infoMessage}"/></div>
            </div>
        </c:if>

        <c:choose>
            <c:when test="${not empty selectedElection and not empty results}">
                <!-- Turnout & Metric Cards -->
                <div class="stat-grid" style="margin-bottom: 2rem;">
                    <div class="stat-card">
                        <div class="stat-card-header">
                            <span class="stat-label">Total Ballots Cast</span>
                            <div class="stat-icon-wrapper blue">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                                    <polyline points="14 2 14 8 20 8"/>
                                </svg>
                            </div>
                        </div>
                        <div class="stat-value"><c:out value="${totalVotes}"/></div>
                        <div class="stat-trend" style="color: var(--text-muted);">Decrypted and tallied</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-card-header">
                            <span class="stat-label">Eligible Registered Voters</span>
                            <div class="stat-icon-wrapper purple">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                                    <circle cx="9" cy="7" r="4"/>
                                </svg>
                            </div>
                        </div>
                        <div class="stat-value"><c:out value="${eligibleVoters}"/></div>
                        <div class="stat-trend" style="color: var(--text-muted);">Verified institutional voters</div>
                    </div>

                    <div class="stat-card">
                        <div class="stat-card-header">
                            <span class="stat-label">Voter Turnout</span>
                            <div class="stat-icon-wrapper green">
                                <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M22 11.08V12a10 10 0 1 1-5.93-9.14"/>
                                    <polyline points="22 4 12 14.01 9 11.01"/>
                                </svg>
                            </div>
                        </div>
                        <div class="stat-value"><c:out value="${turnoutPercentage}"/>%</div>
                        <div class="stat-trend" style="color: var(--success);">Official participation rate</div>
                    </div>
                </div>

                <!-- Tally Table -->
                <div class="card" style="padding: 1.5rem; background: var(--bg-surface-elevated); border: 1px solid var(--border-color);">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 0.75rem;">
                        <div>
                            <h2 style="font-size: 1.25rem; font-weight: 700; margin-bottom: 0.2rem;"><c:out value="${selectedElection.electionName}"/></h2>
                            <p style="font-size: 0.85rem; color: var(--text-secondary); margin: 0;">
                                Concluded on <fmt:formatDate value="${selectedElection.endTime}" pattern="MMMM dd, yyyy HH:mm z"/>
                            </p>
                        </div>
                        <div>
                            <c:if test="${isTie}">
                                <span class="badge badge-pending" style="font-weight: 600;">Election Result: Certified Tie</span>
                            </c:if>
                        </div>
                    </div>

                    <div class="table-responsive">
                        <table class="table">
                            <thead>
                                <tr>
                                    <th style="width: 70px;">Rank</th>
                                    <th style="width: 60px;">Photo</th>
                                    <th>Candidate</th>
                                    <th>Position</th>
                                    <th>Affiliation / Party</th>
                                    <th>Ballot Symbol</th>
                                    <th style="text-align: right;">Votes</th>
                                    <th style="text-align: right; width: 90px;">Share</th>
                                    <th style="min-width: 180px;">Vote Distribution</th>
                                </tr>
                            </thead>
                            <tbody>
                                <c:forEach var="cand" items="${results}" varStatus="status">
                                    <c:set var="isWinner" value="${cand.voteCount == maxVotes and maxVotes > 0 and not isTie}"/>
                                    <c:set var="isTiedWinner" value="${cand.voteCount == maxVotes and maxVotes > 0 and isTie}"/>
                                    <tr style="${isWinner ? 'background: rgba(16, 185, 129, 0.05);' : ''}">
                                        <td style="font-weight: 700; font-size: 1.05rem;">
                                            <c:choose>
                                                <c:when test="${isWinner}">
                                                    <span style="color: #f59e0b; display: inline-flex; align-items: center; gap: 0.25rem;" title="Winner">
                                                        ★ #1
                                                    </span>
                                                </c:when>
                                                <c:when test="${isTiedWinner}">
                                                    <span style="color: #3b82f6;" title="Tied">
                                                        #1 (Tie)
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--text-muted);">#${status.index + 1}</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div style="width: 42px; height: 42px; border-radius: 50%; overflow: hidden; background: var(--bg-surface); border: 2px solid ${isWinner ? 'var(--success)' : 'var(--border-color)'}; flex-shrink: 0;">
                                                <img src="${pageContext.request.contextPath}/candidate-photo?id=${cand.id}" alt="${cand.candidateName}" style="width: 100%; height: 100%; object-fit: cover; display: block;" loading="lazy">
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-weight: 700; color: var(--text-primary); font-size: 0.95rem;">
                                                <c:out value="${cand.candidateName}"/>
                                            </div>
                                            <c:if test="${isWinner}">
                                                <span class="badge badge-active" style="margin-top: 0.2rem; font-size: 0.7rem; background: var(--success); color: white;">Certified Winner</span>
                                            </c:if>
                                        </td>
                                        <td style="color: var(--text-secondary); font-size: 0.88rem;">
                                            <c:out value="${cand.position != null ? cand.position : 'Representative'}"/>
                                        </td>
                                        <td style="font-size: 0.88rem;">
                                            <c:out value="${cand.party}"/>
                                        </td>
                                        <td>
                                            <span class="badge badge-pending" style="font-size: 0.78rem;"><c:out value="${cand.symbol}"/></span>
                                        </td>
                                        <td style="text-align: right; font-weight: 700; font-size: 1rem; color: var(--text-primary);">
                                            <fmt:formatNumber value="${cand.voteCount}" type="number"/>
                                        </td>
                                        <td style="text-align: right; font-weight: 700; font-size: 0.95rem; color: var(--primary);">
                                            <c:out value="${cand.votePercentage}"/>%
                                        </td>
                                        <td>
                                            <!-- CSS percentage bar sized by percentage -->
                                            <div class="progress-bar-container" style="background: var(--bg-main); height: 12px; border-radius: 6px; overflow: hidden; border: 1px solid var(--border-color);">
                                                <div class="progress-bar-fill" style="width: ${cand.votePercentage}%; height: 100%; background: ${isWinner ? 'linear-gradient(90deg, #10b981, #059669)' : 'linear-gradient(90deg, #3b82f6, #2563eb)'}; border-radius: 6px; transition: width 0.5s ease;"></div>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </tbody>
                        </table>
                    </div>
                </div>
            </c:when>

            <c:otherwise>
                <div class="card empty-state" style="padding: 3rem 1.5rem; text-align: center;">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--text-muted); margin-bottom: 1rem;">
                        <line x1="18" y1="20" x2="18" y2="10"/>
                        <line x1="12" y1="20" x2="12" y2="4"/>
                        <line x1="6" y1="20" x2="6" y2="14"/>
                    </svg>
                    <h3 style="font-size: 1.2rem; font-weight: 700; margin-bottom: 0.5rem; color: var(--text-primary);">No Certified Results Available</h3>
                    <p style="color: var(--text-secondary); font-size: 0.9rem; max-width: 500px; margin: 0 auto 1.5rem auto;">
                        Election results will be certified and published here once official voting has concluded and ballots are audited.
                    </p>
                    <a href="${pageContext.request.contextPath}/elections" class="btn btn-secondary btn-sm">Browse Active & Upcoming Elections</a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/voter.js"></script>
</body>
</html>
