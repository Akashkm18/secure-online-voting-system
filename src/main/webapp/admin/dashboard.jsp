<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    // Ensure admin metrics are loaded if visited directly
    if (request.getAttribute("totalVoters") == null) {
        dao.UserDAO uDao = new dao.UserDAO();
        dao.ElectionDAO eDao = new dao.ElectionDAO();
        dao.CandidateDAO cDao = new dao.CandidateDAO();
        dao.VoteDAO vDao = new dao.VoteDAO();
        dao.AuditLogDAO aDao = new dao.AuditLogDAO();

        int voters = uDao.countTotalVoters();
        int votes = vDao.getTotalVotesCount();
        request.setAttribute("totalVoters", voters);
        request.setAttribute("totalCandidates", cDao.countTotal());
        request.setAttribute("activeElectionsCount", eDao.countByStatus("ACTIVE"));
        request.setAttribute("completedElectionsCount", eDao.countByStatus("COMPLETED") + eDao.countByStatus("PUBLISHED"));
        request.setAttribute("totalVotesCount", votes);
        request.setAttribute("turnoutPercent", voters > 0 ? (int) Math.min(100, Math.round(((double) votes / voters) * 100)) : 0);
        request.setAttribute("recentAuditLogs", aDao.getRecentLogs(10));
        request.setAttribute("allElections", eDao.getAllElections());
    } else if (request.getAttribute("turnoutPercent") == null) {
        int vCount = (Integer) request.getAttribute("totalVoters");
        int votesCast = (Integer) request.getAttribute("totalVotesCount");
        request.setAttribute("turnoutPercent", vCount > 0 ? (int) Math.min(100, Math.round(((double) votesCast / vCount) * 100)) : 0);
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Administrator Dashboard | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/fragments/admin-sidebar.jsp" />

        <main class="admin-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h1 style="font-size: 1.65rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">Executive Overview</h1>
                    <p style="color: var(--text-secondary); font-size: 0.875rem; margin: 0;">Institutional election telemetry, ballot volume, and security posture</p>
                </div>
                <div style="display: flex; gap: 0.75rem;">
                    <button type="button" class="btn btn-secondary btn-sm" data-modal-open="addMemberModal">
                        + Enroll Voter
                    </button>
                    <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-primary btn-sm">
                        + New Election
                    </a>
                </div>
            </div>

            <!-- 4 Stat Cards: Voters, Active elections, Votes cast, Turnout % -->
            <div class="stats-grid" style="margin-bottom: 2.5rem;">
                <div class="stat-card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem;">
                        <span style="font-size: 0.8rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.05em;">Registered Voters</span>
                        <div style="width: 32px; height: 32px; border-radius: 8px; background: rgba(37, 99, 235, 0.1); color: var(--primary); display: flex; align-items: center; justify-content: center;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                                <circle cx="9" cy="7" r="4"/>
                                <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                                <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                            </svg>
                        </div>
                    </div>
                    <div class="stat-value"><c:out value="${totalVoters}" /></div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 0.35rem;">Authorized institutional voters</div>
                </div>

                <div class="stat-card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem;">
                        <span style="font-size: 0.8rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.05em;">Active Elections</span>
                        <div style="width: 32px; height: 32px; border-radius: 8px; background: rgba(16, 185, 129, 0.1); color: var(--success); display: flex; align-items: center; justify-content: center;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <rect x="3" y="4" width="18" height="18" rx="2" ry="2"/>
                                <line x1="16" y1="2" x2="16" y2="6"/>
                                <line x1="8" y1="2" x2="8" y2="6"/>
                                <line x1="3" y1="10" x2="21" y2="10"/>
                            </svg>
                        </div>
                    </div>
                    <div class="stat-value"><c:out value="${activeElectionsCount}" /></div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 0.35rem;">Ballots currently open</div>
                </div>

                <div class="stat-card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem;">
                        <span style="font-size: 0.8rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.05em;">Votes Cast</span>
                        <div style="width: 32px; height: 32px; border-radius: 8px; background: rgba(245, 158, 11, 0.1); color: #f59e0b; display: flex; align-items: center; justify-content: center;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                                <polyline points="14 2 14 8 20 8"/>
                                <line x1="16" y1="13" x2="8" y2="13"/>
                                <line x1="16" y1="17" x2="8" y2="17"/>
                                <polyline points="10 9 9 9 8 9"/>
                            </svg>
                        </div>
                    </div>
                    <div class="stat-value"><c:out value="${totalVotesCount}" /></div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 0.35rem;">Cryptographically sealed receipts</div>
                </div>

                <div class="stat-card">
                    <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.75rem;">
                        <span style="font-size: 0.8rem; font-weight: 600; color: var(--text-secondary); text-transform: uppercase; letter-spacing: 0.05em;">Turnout %</span>
                        <div style="width: 32px; height: 32px; border-radius: 8px; background: rgba(139, 92, 246, 0.1); color: #8b5cf6; display: flex; align-items: center; justify-content: center;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <circle cx="12" cy="12" r="10"/>
                                <polyline points="12 6 12 12 16 14"/>
                            </svg>
                        </div>
                    </div>
                    <div class="stat-value"><c:out value="${turnoutPercent}" />%</div>
                    <div style="font-size: 0.75rem; color: var(--text-muted); margin-top: 0.35rem;">Participation benchmark</div>
                </div>
            </div>

            <!-- Elections Summary Table -->
            <section style="margin-bottom: 2.5rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.5rem;">
                    <h2 style="font-size: 1.25rem; font-weight: 700; color: var(--text-primary); margin: 0;">Elections Summary</h2>
                    <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-secondary btn-sm">+ Manage Elections</a>
                </div>

                <div class="table-responsive card" style="padding: 0; overflow: hidden; background: var(--bg-surface-elevated);">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 70px;">ID</th>
                                <th>Election Name</th>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Status</th>
                                <th>Votes</th>
                                <th style="text-align: right;">Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty allElections}">
                                    <c:forEach var="el" items="${allElections}">
                                        <tr>
                                            <td style="font-family: monospace; font-size: 0.8rem; color: var(--text-muted);">#<c:out value="${el.id}" /></td>
                                            <td style="font-weight: 600; color: var(--text-primary);"><c:out value="${el.electionName}" /></td>
                                            <td><fmt:formatDate value="${el.startTime}" pattern="yyyy-MM-dd HH:mm" /></td>
                                            <td><fmt:formatDate value="${el.endTime}" pattern="yyyy-MM-dd HH:mm" /></td>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${el.status == 'ACTIVE'}"><span class="badge badge-active">ACTIVE</span></c:when>
                                                    <c:when test="${el.status == 'UPCOMING'}"><span class="badge badge-upcoming">UPCOMING</span></c:when>
                                                    <c:when test="${el.status == 'COMPLETED'}"><span class="badge badge-completed">COMPLETED</span></c:when>
                                                    <c:when test="${el.status == 'PUBLISHED'}"><span class="badge badge-published">PUBLISHED</span></c:when>
                                                </c:choose>
                                            </td>
                                            <td style="font-weight: 700;"><c:out value="${el.totalVotes}" /></td>
                                            <td style="text-align: right;">
                                                <a href="${pageContext.request.contextPath}/admin/results?electionId=${el.id}" class="btn btn-secondary btn-sm">
                                                    Results
                                                </a>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" style="text-align: center; padding: 2.5rem; color: var(--text-secondary);">
                                            No elections created yet.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- Recent Activity Table -->
            <section>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; flex-wrap: wrap; gap: 0.5rem;">
                    <h2 style="font-size: 1.25rem; font-weight: 700; color: var(--text-primary); margin: 0;">Recent Audit Activity</h2>
                    <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-secondary btn-sm">All Logs</a>
                </div>

                <div class="table-responsive card" style="padding: 0; overflow: hidden; background: var(--bg-surface-elevated);">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Timestamp</th>
                                <th>Action Performed</th>
                                <th>Actor Email</th>
                                <th>IP Address</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty recentAuditLogs}">
                                    <c:forEach var="log" items="${recentAuditLogs}">
                                        <tr>
                                            <td style="font-size: 0.82rem; color: var(--text-secondary);"><fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                                            <td><span class="badge badge-pending" style="font-family: monospace; font-size: 0.75rem;"><c:out value="${log.action}" /></span></td>
                                            <td style="font-size: 0.85rem;"><c:out value="${log.userEmail != null ? log.userEmail : 'System/Anonymous'}" /></td>
                                            <td style="font-family: monospace; font-size: 0.8rem; color: var(--text-muted);"><c:out value="${log.ipAddress}" /></td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="4" style="text-align: center; padding: 2rem; color: var(--text-secondary);">
                                            No audit entries recorded yet.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

    <!-- Quick Enroll Voter Modal -->
    <div class="modal-overlay" id="addMemberModal">
        <div class="modal-box" style="max-width: 520px; text-align: left;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.15rem; color: var(--text-primary);">Enroll New Student Voter</h3>
                <button type="button" class="btn btn-secondary btn-sm" data-modal-close="addMemberModal">✕</button>
            </div>

            <form action="${pageContext.request.contextPath}/admin/action" method="POST" autocomplete="off">
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                <input type="hidden" name="action" value="addVoter" />

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="modalFullName">Full Name</label>
                    <input type="text" id="modalFullName" name="fullName" class="form-control" placeholder="e.g. Alice Smith" required />
                </div>

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="modalEmail">Campus Email</label>
                    <input type="email" id="modalEmail" name="email" class="form-control" placeholder="student@institution.edu" required />
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; margin-bottom: 0.85rem;">
                    <div class="form-group">
                        <label for="modalCollegeId">Student ID Card / Roll No.</label>
                        <input type="text" id="modalCollegeId" name="collegeId" class="form-control" placeholder="e.g. STU-2026-001" required />
                    </div>

                    <div class="form-group">
                        <label for="modalPassword">Initial Password</label>
                        <input type="password" id="modalPassword" name="password" class="form-control" placeholder="Min 6 characters" minlength="6" required />
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; margin-bottom: 1.25rem;">
                    <div class="form-group">
                        <label for="modalProgram">Program / Major</label>
                        <input type="text" id="modalProgram" name="programName" class="form-control" placeholder="e.g. Computer Science" />
                    </div>

                    <div class="form-group">
                        <label for="modalJoiningYear">Admission Year</label>
                        <input type="number" id="modalJoiningYear" name="joiningYear" class="form-control" placeholder="2026" min="2000" max="2035" />
                    </div>
                </div>

                <div style="display: flex; gap: 0.75rem; justify-content: flex-end; border-top: 1px solid var(--border-color); padding-top: 1rem;">
                    <button type="button" class="btn btn-secondary btn-sm" data-modal-close="addMemberModal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Enroll Voter</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
