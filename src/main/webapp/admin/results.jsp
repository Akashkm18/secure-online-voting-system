<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Results & Tally" />
<%@ include file="/WEB-INF/fragments/admin-header.jspf" %>

<div class="admin-page-header">
    <div>
        <h1 class="admin-page-title">Certified Results & Ballot Tallies</h1>
        <p class="admin-page-subtitle">Tabulate candidate vote totals, turnout telemetry, and officially certify election outcomes</p>
    </div>
    <c:if test="${not empty selectedElection}">
        <div class="admin-header-actions">
            <a href="${pageContext.request.contextPath}/admin/results?electionId=${selectedElection.id}&export=csv" class="btn btn-secondary btn-sm" title="Download certified results CSV">
                <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                    <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                    <polyline points="7 10 12 15 17 10"></polyline>
                    <line x1="12" y1="15" x2="12" y2="3"></line>
                </svg>
                <span>Export CSV</span>
            </a>

            <!-- Publish Certified Results (Strictly enforces COMPLETED status on client & server) -->
            <c:choose>
                <c:when test="${selectedElection.status == 'COMPLETED'}">
                    <form action="${pageContext.request.contextPath}/admin/results" method="post" style="display:inline; margin:0;">
                        <input type="hidden" name="_csrf" value="${csrfToken}">
                        <input type="hidden" name="action" value="publish">
                        <input type="hidden" name="electionId" value="${selectedElection.id}">
                        <button type="submit" class="btn btn-success btn-sm"
                                data-confirm="Certify and publish final tally for '${selectedElection.electionName}'? Results will immediately be publicly viewable on voter portal."
                                data-confirm-title="Certify & Publish Results">
                            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <polyline points="20 6 9 17 4 12"></polyline>
                            </svg>
                            <span>Publish Certified Results</span>
                        </button>
                    </form>
                </c:when>
                <c:when test="${selectedElection.status == 'PUBLISHED'}">
                    <span class="badge-status badge-published" style="padding: 0.4rem 0.8rem; font-size: 0.8rem;">
                        CERTIFIED & PUBLISHED
                    </span>
                </c:when>
                <c:otherwise>
                    <button type="button" class="btn btn-secondary btn-sm" disabled title="Results can only be certified and published once the election has ended in COMPLETED status. Current status is ${selectedElection.status}.">
                        Publish Locked (Election ${selectedElection.status})
                    </button>
                </c:otherwise>
            </c:choose>
        </div>
    </c:if>
</div>

<!-- Election Selector Form -->
<form action="${pageContext.request.contextPath}/admin/results" method="get" class="filter-bar">
    <div class="filter-group">
        <label for="electionSelect" style="font-size: 0.85rem; color: var(--text-secondary);">Target Election:</label>
        <select id="electionSelect" name="electionId" class="filter-select" style="min-width: 320px;">
            <c:forEach var="el" items="${allElections}">
                <option value="${el.id}" ${selectedElection.id == el.id ? 'selected' : ''}>
                    #${el.id} - <c:out value="${el.electionName}"/> (<c:out value="${el.status}"/>)
                </option>
            </c:forEach>
        </select>
        <button type="submit" class="btn btn-primary btn-sm">Load Tally</button>
    </div>
    <c:if test="${not empty selectedElection}">
        <div style="font-size: 0.85rem; color: var(--text-secondary);">
            Status: <span class="badge-status badge-${selectedElection.status == 'ACTIVE' ? 'active' : (selectedElection.status == 'PUBLISHED' ? 'published' : 'completed')}"><c:out value="${selectedElection.status}"/></span>
        </div>
    </c:if>
</form>

<c:if test="${not empty selectedElection}">
    <!-- Turnout & Telemetry Cards -->
    <div class="stat-grid" style="margin-bottom: 2rem;">
        <div class="stat-card">
            <div class="stat-label">Total Ballots Cast</div>
            <div class="stat-value"><c:out value="${totalVotesInElection}"/></div>
            <div class="stat-sub">Valid cryptographic votes</div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Eligible Registered Voters</div>
            <div class="stat-value"><c:out value="${eligibleVoters}"/></div>
            <div class="stat-sub">Total active university roster</div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Overall Turnout Rate</div>
            <div class="stat-value" style="color: #60a5fa;"><c:out value="${turnoutPercentage}"/>%</div>
            <div class="stat-sub">Calculated institutional turnout</div>
        </div>

        <div class="stat-card">
            <div class="stat-label">Certification Status</div>
            <div class="stat-value" style="font-size: 1.35rem; color: ${selectedElection.status == 'PUBLISHED' ? '#818cf8' : (selectedElection.status == 'COMPLETED' ? '#fbbf24' : '#34d399')};">
                <c:out value="${selectedElection.status}"/>
            </div>
            <div class="stat-sub">
                <c:choose>
                    <c:when test="${selectedElection.status == 'PUBLISHED'}">Public on voter portal</c:when>
                    <c:when test="${selectedElection.status == 'COMPLETED'}">Ready for certification</c:when>
                    <c:otherwise>Voting in progress</c:otherwise>
                </c:choose>
            </div>
        </div>
    </div>

    <!-- Official Tally Table with Candidate Photos & Sized Percentage Bars -->
    <div class="table-responsive">
        <table class="admin-table">
            <thead>
                <tr>
                    <th style="width: 50px;">Rank</th>
                    <th style="width: 60px;">Photo</th>
                    <th>Candidate & Position</th>
                    <th>Party / Slate</th>
                    <th>Emblem</th>
                    <th style="width: 100px;">Total Votes</th>
                    <th style="width: 90px;">Share (%)</th>
                    <th style="min-width: 180px;">Tally Percentage Bar</th>
                </tr>
            </thead>
            <tbody>
                <c:choose>
                    <c:when test="${not empty results}">
                        <c:forEach var="c" items="${results}" varStatus="status">
                            <tr class="${c.voteCount == winningVoteCount && winningVoteCount > 0 ? 'winner-highlight' : ''}">
                                <td style="font-weight: 700; color: var(--text-muted); font-size: 0.95rem;">
                                    #${status.index + 1}
                                </td>
                                <td>
                                    <img src="${pageContext.request.contextPath}/candidate-photo?id=${c.id}"
                                         alt="<c:out value="${c.candidateName}"/>"
                                         class="candidate-avatar-thumb">
                                </td>
                                <td>
                                    <div style="font-weight: 600; color: var(--text-primary); display: flex; align-items: center;">
                                        <c:out value="${c.candidateName}"/>
                                        <c:if test="${c.voteCount == winningVoteCount && winningVoteCount > 0}">
                                            <c:choose>
                                                <c:when test="${isTie}">
                                                    <span class="badge badge-warning" style="margin-left: 0.5rem; font-size: 0.65rem; background: rgba(245, 158, 11, 0.2); color: #fbbf24; border: 1px solid rgba(245, 158, 11, 0.4); border-radius: 4px; padding: 0.1rem 0.4rem;">TIED</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="winner-crown">WINNER</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </c:if>
                                    </div>
                                    <div style="font-size: 0.78rem; color: var(--text-secondary);">
                                        <c:out value="${c.position != null ? c.position : 'Candidate'}"/>
                                    </div>
                                </td>
                                <td>
                                    <span style="font-weight: 500;"><c:out value="${c.party}"/></span>
                                </td>
                                <td>
                                    <span class="badge badge-secondary" style="font-size: 0.75rem; background: rgba(255,255,255,0.06); padding: 0.2rem 0.5rem; border-radius: 4px;">
                                        <c:out value="${c.symbol}"/>
                                    </span>
                                </td>
                                <td style="font-weight: 700; font-size: 1rem; color: var(--text-primary);">
                                    <c:out value="${c.voteCount}"/>
                                </td>
                                <td style="font-weight: 600; color: #60a5fa;">
                                    <c:out value="${c.votePercentage}"/>%
                                </td>
                                <td>
                                    <!-- CSS Tally Percentage Bar with dynamic width -->
                                    <div class="tally-bar-container" title="${c.votePercentage}%">
                                        <div class="tally-bar-fill ${c.voteCount == winningVoteCount && winningVoteCount > 0 ? 'tally-bar-winner' : ''}"
                                             style="width: ${c.votePercentage}%;"></div>
                                    </div>
                                </td>
                            </tr>
                        </c:forEach>
                    </c:when>
                    <c:otherwise>
                        <tr>
                            <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 3rem;">
                                No candidates or votes recorded for this election.
                            </td>
                        </tr>
                    </c:otherwise>
                </c:choose>
            </tbody>
        </table>
    </div>
</c:if>

<%@ include file="/WEB-INF/fragments/admin-footer.jspf" %>
