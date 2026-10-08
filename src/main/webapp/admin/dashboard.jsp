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

        request.setAttribute("totalVoters", uDao.countTotalVoters());
        request.setAttribute("totalCandidates", cDao.countTotal());
        request.setAttribute("activeElectionsCount", eDao.countByStatus("ACTIVE"));
        request.setAttribute("completedElectionsCount", eDao.countByStatus("COMPLETED") + eDao.countByStatus("PUBLISHED"));
        request.setAttribute("totalVotesCount", vDao.getTotalVotesCount());
        request.setAttribute("recentAuditLogs", aDao.getRecentLogs(10));
        request.setAttribute("allElections", eDao.getAllElections());
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

    <!-- Top Bar -->
    <nav class="navbar" id="adminTopNavbar">
        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-brand">
            <div class="brand-icon" style="background: linear-gradient(135deg, #f59e0b, #d97706);">🛡️</div>
            <span>Admin Center</span>
        </a>
        <div class="nav-user">
            <span class="badge-role badge-admin">Admin</span>
            <span style="font-weight: 600;"><c:out value="${sessionScope.user.fullName}" /></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>
    </nav>

    <div class="admin-layout">
        <!-- Sidebar Navigation -->
        <aside class="admin-sidebar" id="adminSidebar">
            <div class="sidebar-title">Navigation</div>
            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="sidebar-link active">
                <span>📊</span> Dashboard Overview
            </a>
            <a href="${pageContext.request.contextPath}/admin/elections" class="sidebar-link">
                <span>🗳️</span> Manage Elections
            </a>
            <a href="${pageContext.request.contextPath}/admin/candidates" class="sidebar-link">
                <span>👥</span> Manage Candidates
            </a>
            <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link">
                <span>🎫</span> Manage Voters
            </a>
            <a href="${pageContext.request.contextPath}/admin/results" class="sidebar-link">
                <span>🏆</span> Live Results & Tally
            </a>
            <a href="${pageContext.request.contextPath}/admin/audit-logs" class="sidebar-link">
                <span>📜</span> Audit Security Logs
            </a>

            <div class="sidebar-title" style="margin-top: 2rem;">System Actions</div>
            <a href="${pageContext.request.contextPath}/index.jsp" class="sidebar-link" target="_blank">
                <span>🌐</span> Public Portal ↗
            </a>
            <a href="${pageContext.request.contextPath}/logout" class="sidebar-link" style="color: #ef4444;">
                <span>🚪</span> Sign Out
            </a>
        </aside>

        <!-- Main Content Area -->
        <main class="admin-content">
            <div style="margin-bottom: 2rem;">
                <h1>System Overview</h1>
                <p class="subtitle">Real-time election metrics, turnout, and active voter statistics</p>
            </div>

            <!-- Stats Grid -->
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-icon indigo">👥</div>
                    <div class="stat-info">
                        <h4>Registered Voters</h4>
                        <div class="stat-value"><c:out value="${totalVoters}" /></div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon emerald">🗳️</div>
                    <div class="stat-info">
                        <h4>Total Ballots Cast</h4>
                        <div class="stat-value"><c:out value="${totalVotesCount}" /></div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon amber">⚡</div>
                    <div class="stat-info">
                        <h4>Active Elections</h4>
                        <div class="stat-value"><c:out value="${activeElectionsCount}" /></div>
                    </div>
                </div>

                <div class="stat-card">
                    <div class="stat-icon sky">🏛️</div>
                    <div class="stat-info">
                        <h4>Total Candidates</h4>
                        <div class="stat-value"><c:out value="${totalCandidates}" /></div>
                    </div>
                </div>
            </div>

            <!-- Election Summary Table -->
            <section style="margin-bottom: 3rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem;">
                    <h2>Elections Summary</h2>
                    <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-outline btn-sm">+ Create New Election</a>
                </div>

                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Election Name</th>
                                <th>Start Date</th>
                                <th>End Date</th>
                                <th>Status</th>
                                <th>Ballots Cast</th>
                                <th>Quick Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="el" items="${allElections}">
                                <tr>
                                    <td>#<c:out value="${el.id}" /></td>
                                    <td style="font-weight: 600;"><c:out value="${el.electionName}" /></td>
                                    <td><fmt:formatDate value="${el.startTime}" pattern="yyyy-MM-dd HH:mm" /></td>
                                    <td><fmt:formatDate value="${el.endTime}" pattern="yyyy-MM-dd HH:mm" /></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${el.status == 'ACTIVE'}">
                                                <span class="status-badge status-active">ACTIVE</span>
                                            </c:when>
                                            <c:when test="${el.status == 'UPCOMING'}">
                                                <span class="status-badge status-upcoming">UPCOMING</span>
                                            </c:when>
                                            <c:when test="${el.status == 'COMPLETED'}">
                                                <span class="status-badge status-completed">COMPLETED</span>
                                            </c:when>
                                            <c:when test="${el.status == 'PUBLISHED'}">
                                                <span class="status-badge status-published">PUBLISHED</span>
                                            </c:when>
                                        </c:choose>
                                    </td>
                                    <td style="font-weight: 700;"><c:out value="${el.totalVotes}" /></td>
                                    <td>
                                        <a href="${pageContext.request.contextPath}/admin/results?electionId=${el.id}" class="btn btn-outline btn-sm">
                                            View Tally
                                        </a>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </section>

            <!-- Recent Security Audit Trail Preview -->
            <section>
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem;">
                    <h2>Recent Audit Trail</h2>
                    <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-outline btn-sm">Full Security Log →</a>
                </div>

                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Time</th>
                                <th>Action</th>
                                <th>User</th>
                                <th>IP Address</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="log" items="${recentAuditLogs}">
                                <tr>
                                    <td><fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" /></td>
                                    <td><code style="color: #818cf8;"><c:out value="${log.action}" /></code></td>
                                    <td><c:out value="${log.userEmail != null ? log.userEmail : 'System/Anonymous'}" /></td>
                                    <td><c:out value="${log.ipAddress}" /></td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
