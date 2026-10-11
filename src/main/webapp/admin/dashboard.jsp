<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Dashboard Overview" />
<%@ include file="/WEB-INF/fragments/admin-header.jspf" %>

<div class="admin-page-header">
    <div>
        <h1 class="admin-page-title">Executive Dashboard</h1>
        <p class="admin-page-subtitle">Institutional election metrics, voter registry volume, and security posture</p>
    </div>
    <div class="admin-header-actions">
        <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-primary btn-sm">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            <span>Create Election</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/candidates" class="btn btn-secondary btn-sm">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M16 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"></path>
                <circle cx="8.5" cy="7" r="4"></circle>
                <line x1="20" y1="8" x2="20" y2="14"></line>
                <line x1="23" y1="11" x2="17" y2="11"></line>
            </svg>
            <span>Add Candidate</span>
        </a>
        <a href="${pageContext.request.contextPath}/admin/voters?status=PENDING" class="btn btn-secondary btn-sm">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
                <polyline points="14 2 14 8 20 8"></polyline>
                <line x1="16" y1="13" x2="8" y2="13"></line>
            </svg>
            <span>Review Pending Voters</span>
        </a>
    </div>
</div>

<!-- 5 Institutional Stat Cards -->
<div class="stat-grid">
    <div class="stat-card">
        <div class="stat-label">Registered Voters</div>
        <div class="stat-value"><c:out value="${totalVoters}"/></div>
        <div class="stat-sub">Authorized institutional students</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Pending Approvals</div>
        <div class="stat-value" style="color: ${pendingApprovals > 0 ? '#fbbf24' : 'var(--text-primary)'};">
            <c:out value="${pendingApprovals}"/>
        </div>
        <div class="stat-sub">Applications awaiting review</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Active Elections</div>
        <div class="stat-value" style="color: #34d399;">
            <c:out value="${activeElectionsCount}"/>
        </div>
        <div class="stat-sub">Ballots open for voting</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Total Votes Cast</div>
        <div class="stat-value"><c:out value="${totalVotesCount}"/></div>
        <div class="stat-sub">Cryptographically verified</div>
    </div>

    <div class="stat-card">
        <div class="stat-label">Overall Turnout</div>
        <div class="stat-value"><c:out value="${turnoutPercentage}"/>%</div>
        <div class="stat-sub">Participation across elections</div>
    </div>
</div>

<!-- Two-Column Section: Latest Elections & Recent Audit Activity -->
<div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(420px, 1fr)); gap: 1.5rem; margin-top: 1rem;">
    <!-- Latest Elections Table -->
    <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 1.25rem;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
            <h2 style="font-size: 1.1rem; font-weight: 700; color: var(--text-primary); margin: 0;">Institutional Elections</h2>
            <a href="${pageContext.request.contextPath}/admin/elections" style="font-size: 0.82rem; color: #60a5fa; text-decoration: none;">View All &rarr;</a>
        </div>

        <div class="table-responsive" style="margin-bottom: 0;">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Title</th>
                        <th>Status</th>
                        <th>Candidates</th>
                        <th>Votes</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty latestElections}">
                            <c:forEach var="el" items="${latestElections}">
                                <tr>
                                    <td>
                                        <div style="font-weight: 600; color: var(--text-primary);"><c:out value="${el.electionName}"/></div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${el.status == 'ACTIVE'}">
                                                <span class="badge-status badge-active">ACTIVE</span>
                                            </c:when>
                                            <c:when test="${el.status == 'UPCOMING'}">
                                                <span class="badge-status badge-upcoming">UPCOMING</span>
                                            </c:when>
                                            <c:when test="${el.status == 'COMPLETED'}">
                                                <span class="badge-status badge-completed">COMPLETED</span>
                                            </c:when>
                                            <c:when test="${el.status == 'PUBLISHED'}">
                                                <span class="badge-status badge-published">PUBLISHED</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status badge-disabled"><c:out value="${el.status}"/></span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td><c:out value="${el.candidatesCount}"/></td>
                                    <td><c:out value="${el.totalVotes}"/></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/results?electionId=${el.id}" class="btn btn-secondary btn-xs" style="padding: 0.2rem 0.5rem; font-size: 0.75rem;">Tally</a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 2rem;">No elections registered yet.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>

    <!-- Recent Security Audit Logs -->
    <div style="background: var(--bg-surface); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 1.25rem;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
            <h2 style="font-size: 1.1rem; font-weight: 700; color: var(--text-primary); margin: 0;">Recent Security Activity</h2>
            <a href="${pageContext.request.contextPath}/admin/audit-logs" style="font-size: 0.82rem; color: #60a5fa; text-decoration: none;">Full Audit &rarr;</a>
        </div>

        <div class="table-responsive" style="margin-bottom: 0;">
            <table class="admin-table">
                <thead>
                    <tr>
                        <th>Time</th>
                        <th>Event Action</th>
                        <th>User</th>
                        <th>Result</th>
                    </tr>
                </thead>
                <tbody>
                    <c:choose>
                        <c:when test="${not empty recentAuditLogs}">
                            <c:forEach var="log" items="${recentAuditLogs}">
                                <tr>
                                    <td style="font-size: 0.75rem; color: var(--text-muted); white-space: nowrap;">
                                        <fmt:formatDate value="${log.createdAt}" pattern="MMM dd, HH:mm" />
                                    </td>
                                    <td style="font-family: monospace; font-size: 0.8rem; color: var(--text-primary);">
                                        <c:out value="${log.action}"/>
                                    </td>
                                    <td style="font-size: 0.8rem; color: var(--text-secondary);">
                                        <c:out value="${log.userEmail != null ? log.userEmail : 'SYSTEM'}"/>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${log.success}">
                                                <span class="badge-status badge-active" style="font-size: 0.65rem;">OK</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="badge-status badge-rejected" style="font-size: 0.65rem;">FAIL</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                </tr>
                            </c:forEach>
                        </c:when>
                        <c:otherwise>
                            <tr>
                                <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 2rem;">No audit logs recorded yet.</td>
                            </tr>
                        </c:otherwise>
                    </c:choose>
                </tbody>
            </table>
        </div>
    </div>
</div>

<%@ include file="/WEB-INF/fragments/admin-footer.jspf" %>
