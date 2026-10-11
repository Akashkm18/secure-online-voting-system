<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Security Audit Logs" />
<%@ include file="/WEB-INF/fragments/admin-header.jspf" %>

<div class="admin-page-header">
    <div>
        <h1 class="admin-page-title">Security Audit Logs & Telemetry</h1>
        <p class="admin-page-subtitle">Immutable audit trail of authentication events, ballot submissions, and administrative changes</p>
    </div>
    <div class="admin-header-actions">
        <a href="${pageContext.request.contextPath}/admin/audit-logs?export=csv&actionFilter=${actionFilter}&userSearch=${userSearch}&startDate=${startDate}&endDate=${endDate}"
           class="btn btn-secondary btn-sm"
           title="Export Audit Trail as CSV">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="7 10 12 15 17 10"></polyline>
                <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            <span>Export CSV</span>
        </a>
    </div>
</div>

<!-- Audit Filters Form -->
<form action="${pageContext.request.contextPath}/admin/audit-logs" method="get" class="filter-bar">
    <div class="filter-group">
        <input type="text" name="actionFilter" value="<c:out value="${actionFilter}"/>" placeholder="Filter by event action..." class="filter-input" style="min-width: 180px;">
        <input type="text" name="userSearch" value="<c:out value="${userSearch}"/>" placeholder="Search by user email..." class="filter-input" style="min-width: 180px;">
        <input type="date" name="startDate" value="<c:out value="${startDate}"/>" class="filter-input" style="min-width: 130px;" title="Start Date">
        <input type="date" name="endDate" value="<c:out value="${endDate}"/>" class="filter-input" style="min-width: 130px;" title="End Date">
        <button type="submit" class="btn btn-primary btn-sm">Filter</button>
        <c:if test="${not empty actionFilter or not empty userSearch or not empty startDate or not empty endDate}">
            <a href="${pageContext.request.contextPath}/admin/audit-logs" class="btn btn-secondary btn-sm">Reset</a>
        </c:if>
    </div>
    <div style="font-size: 0.85rem; color: var(--text-secondary);">
        Total Audit Records: <strong style="color: var(--text-primary);"><c:out value="${totalItems}"/></strong>
    </div>
</form>

<!-- Audit Logs Table -->
<div class="table-responsive">
    <table class="admin-table">
        <thead>
            <tr>
                <th style="width: 50px;">ID</th>
                <th style="width: 160px;">Timestamp</th>
                <th>Event Action</th>
                <th>Subject User</th>
                <th style="width: 80px;">Role</th>
                <th>IP Address</th>
                <th style="width: 90px;">Result</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${not empty auditLogs}">
                    <c:forEach var="log" items="${auditLogs}">
                        <tr>
                            <td style="font-family: monospace; color: var(--text-muted);">#<c:out value="${log.id}"/></td>
                            <td style="font-size: 0.8rem; color: var(--text-secondary); white-space: nowrap;">
                                <fmt:formatDate value="${log.createdAt}" pattern="yyyy-MM-dd HH:mm:ss" />
                            </td>
                            <td>
                                <span style="font-family: monospace; font-size: 0.82rem; color: var(--text-primary);">
                                    <c:out value="${log.action}"/>
                                </span>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty log.userEmail}">
                                        <span style="font-size: 0.85rem; color: var(--text-primary);"><c:out value="${log.userEmail}"/></span>
                                    </c:when>
                                    <c:otherwise>
                                        <span style="color: var(--text-muted); font-style: italic; font-size: 0.82rem;">SYSTEM / Anonymous</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <span class="badge badge-secondary" style="font-size: 0.72rem; padding: 0.15rem 0.45rem; border-radius: 3px;">
                                    <c:out value="${log.userRole}"/>
                                </span>
                            </td>
                            <td style="font-family: monospace; font-size: 0.8rem; color: var(--primary);">
                                <c:out value="${log.ipAddress}"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${log.success}">
                                        <span class="badge-status badge-active">SUCCESS</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status badge-rejected">FAILURE</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 3rem;">
                            No audit log records found matching specified filters.
                        </td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</div>

<!-- Pagination Controls -->
<c:if test="${totalPages > 1}">
    <div class="pagination-bar">
        <div>Showing page <c:out value="${currentPage}"/> of <c:out value="${totalPages}"/></div>
        <div class="pagination-controls">
            <a href="${pageContext.request.contextPath}/admin/audit-logs?page=${currentPage - 1}&actionFilter=${actionFilter}&userSearch=${userSearch}&startDate=${startDate}&endDate=${endDate}"
               class="page-btn ${currentPage <= 1 ? 'disabled' : ''}">&laquo; Prev</a>
            <c:forEach var="p" begin="1" end="${totalPages}">
                <a href="${pageContext.request.contextPath}/admin/audit-logs?page=${p}&actionFilter=${actionFilter}&userSearch=${userSearch}&startDate=${startDate}&endDate=${endDate}"
                   class="page-btn ${currentPage == p ? 'active' : ''}"><c:out value="${p}"/></a>
            </c:forEach>
            <a href="${pageContext.request.contextPath}/admin/audit-logs?page=${currentPage + 1}&actionFilter=${actionFilter}&userSearch=${userSearch}&startDate=${startDate}&endDate=${endDate}"
               class="page-btn ${currentPage >= totalPages ? 'disabled' : ''}">Next &raquo;</a>
        </div>
    </div>
</c:if>

<%@ include file="/WEB-INF/fragments/admin-footer.jspf" %>
