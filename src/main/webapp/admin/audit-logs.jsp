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

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/fragments/admin-sidebar.jsp" />

        <main class="admin-content">
            <div style="margin-bottom: 2rem;">
                <h1 style="font-size: 1.65rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">Security Audit Trail</h1>
                <p style="color: var(--text-secondary); font-size: 0.875rem; margin: 0;">Immutable ledger of authentication, ballot submissions, and administrative events</p>
            </div>

            <!-- Search and Filter Bar -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 1rem;">
                <div style="display: flex; align-items: center; gap: 0.5rem; flex: 1; max-width: 380px;">
                    <input type="text" data-table-filter="auditTable" class="form-control" placeholder="Filter logs by action, email, or IP..." style="font-size: 0.85rem;" />
                </div>
                <div style="font-size: 0.85rem; color: var(--text-secondary);">
                    Recent Log Entries: <strong style="color: var(--text-primary);"><c:out value="${auditLogs.size()}" /></strong>
                </div>
            </div>

            <div class="table-responsive card" style="padding: 0; overflow: hidden; background: var(--bg-surface-elevated);">
                <table class="table" id="auditTable">
                    <thead>
                        <tr>
                            <th style="width: 70px;">Log ID</th>
                            <th>Timestamp</th>
                            <th>Event Action</th>
                            <th>Subject Account</th>
                            <th>Origin IP</th>
                            <th>Client Agent</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty auditLogs}">
                                <c:forEach var="log" items="${auditLogs}">
                                    <tr>
                                        <td style="font-family: monospace; font-size: 0.8rem; color: var(--text-muted);">#<c:out value="${log.id}" /></td>
                                        <td style="white-space: nowrap; font-size: 0.82rem; color: var(--text-secondary);">
                                            <fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                                        </td>
                                        <td>
                                            <span class="badge badge-pending" style="font-family: monospace; font-size: 0.75rem;">
                                                <c:out value="${log.action}" />
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty log.userEmail}">
                                                    <span style="font-weight: 600; font-size: 0.85rem; color: var(--text-primary);"><c:out value="${log.userEmail}" /></span>
                                                    <span style="color: var(--text-muted); font-size: 0.75rem;">(#${log.userId})</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--text-muted); font-style: italic; font-size: 0.82rem;">System / Anonymous</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <span style="font-family: monospace; font-size: 0.82rem; color: var(--primary);"><c:out value="${log.ipAddress}" /></span>
                                        </td>
                                        <td style="max-width: 250px; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; font-size: 0.78rem; color: var(--text-muted);" title="<c:out value='${log.userAgent}' />">
                                            <c:out value="${log.userAgent}" />
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:choose>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 2.5rem; color: var(--text-secondary);">
                                        No audit entries recorded yet.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
