<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    if (request.getAttribute("auditLogs") == null) {
        dao.AuditLogDAO aDao = new dao.AuditLogDAO();
        request.setAttribute("auditLogs", aDao.getRecentLogs(100));
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Audit Trail | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <nav class="navbar">
        <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="nav-brand">
            <div class="brand-icon" style="background: linear-gradient(135deg, #f59e0b, #d97706);">🛡️</div>
            <span>Admin Center</span>
        </a>
        <div class="nav-user">
            <span class="badge-role badge-admin">Admin</span>
            <span><c:out value="${sessionScope.user.fullName}" /></span>
            <a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a>
        </div>
    </nav>

    <div class="admin-layout">
        <aside class="admin-sidebar">
            <div class="sidebar-title">Navigation</div>
            <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="sidebar-link">
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
            <a href="${pageContext.request.contextPath}/admin/audit-logs" class="sidebar-link active">
                <span>📜</span> Audit Security Logs
            </a>
        </aside>

        <main class="admin-content">
            <div style="margin-bottom: 2rem;">
                <h1>Security Audit Trail</h1>
                <p class="subtitle">Immutable record of authentication, ballot submissions, and administrative events</p>
            </div>

            <div class="table-responsive">
                <table class="table">
                    <thead>
                        <tr>
                            <th>Log ID</th>
                            <th>Timestamp</th>
                            <th>Action Event</th>
                            <th>Account / Subject</th>
                            <th>Origin IP</th>
                            <th>Client User Agent</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:forEach var="log" items="${auditLogs}">
                            <tr>
                                <td>#<c:out value="${log.id}" /></td>
                                <td style="white-space: nowrap; font-size: 0.85rem; color: var(--text-secondary);">
                                    <fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                                </td>
                                <td>
                                    <code style="background: rgba(99, 102, 241, 0.12); color: #818cf8; padding: 0.2rem 0.5rem; border-radius: var(--radius-sm); font-size: 0.85rem;">
                                        <c:out value="${log.action}" />
                                    </code>
                                </td>
                                <td>
                                    <c:choose>
                                        <c:when test="${not empty log.userEmail}">
                                            <span style="font-weight: 600;"><c:out value="${log.userEmail}" /></span>
                                            <span style="color: var(--text-muted); font-size: 0.8rem;">(ID #${log.userId})</span>
                                        </c:when>
                                        <c:otherwise>
                                            <span style="color: var(--text-muted); font-style: italic;">Unauthenticated / System</span>
                                        </c:otherwise>
                                    </c:choose>
                                </td>
                                <td>
                                    <span style="font-family: monospace; font-size: 0.85rem;"><c:out value="${log.ipAddress}" /></span>
                                </td>
                                <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 0.8rem; color: var(--text-muted);" title="<c:out value='${log.userAgent}' />">
                                    <c:out value="${log.userAgent}" />
                                </td>
                            </tr>
                        </c:forEach>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
