<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Elections Management" />
<%@ include file="/WEB-INF/fragments/admin-header.jspf" %>

<div class="admin-page-header">
    <div>
        <h1 class="admin-page-title">Elections Lifecycle Management</h1>
        <p class="admin-page-subtitle">Configure voting windows, execute workflow transitions, and certify election tallies</p>
    </div>
    <div class="admin-header-actions">
        <button type="button" class="btn btn-primary btn-sm" data-modal-open="#createElectionModal">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            <span>Create New Election</span>
        </button>
    </div>
</div>

<!-- Search & Status Filter Bar -->
<form action="${pageContext.request.contextPath}/admin/elections" method="get" class="filter-bar">
    <div class="filter-group">
        <input type="text" name="q" value="<c:out value="${searchQuery}"/>" placeholder="Search elections by title..." class="filter-input">
        <select name="status" class="filter-select">
            <option value="ALL" ${currentStatus == 'ALL' ? 'selected' : ''}>All Statuses</option>
            <option value="UPCOMING" ${currentStatus == 'UPCOMING' ? 'selected' : ''}>Upcoming</option>
            <option value="ACTIVE" ${currentStatus == 'ACTIVE' ? 'selected' : ''}>Active</option>
            <option value="COMPLETED" ${currentStatus == 'COMPLETED' ? 'selected' : ''}>Completed</option>
            <option value="PUBLISHED" ${currentStatus == 'PUBLISHED' ? 'selected' : ''}>Published</option>
            <option value="ARCHIVED" ${currentStatus == 'ARCHIVED' ? 'selected' : ''}>Archived</option>
        </select>
        <button type="submit" class="btn btn-secondary btn-sm">Filter</button>
        <c:if test="${not empty searchQuery or currentStatus != 'ALL'}">
            <a href="${pageContext.request.contextPath}/admin/elections" class="btn btn-secondary btn-sm">Reset</a>
        </c:if>
    </div>
    <div style="font-size: 0.85rem; color: var(--text-secondary);">
        Total Elections: <strong style="color: var(--text-primary);"><c:out value="${totalItems}"/></strong>
    </div>
</form>

<!-- Elections Table -->
<div class="table-responsive">
    <table class="admin-table">
        <thead>
            <tr>
                <th style="width: 50px;">ID</th>
                <th>Title & Description</th>
                <th>Voting Window</th>
                <th>Status</th>
                <th>Candidates</th>
                <th>Votes</th>
                <th style="text-align: right;">Workflow & Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${not empty elections}">
                    <c:forEach var="el" items="${elections}">
                        <tr>
                            <td style="font-family: monospace; color: var(--text-muted);">#<c:out value="${el.id}"/></td>
                            <td>
                                <div style="font-weight: 600; color: var(--text-primary); font-size: 0.95rem;">
                                    <c:out value="${el.electionName}"/>
                                </div>
                                <div style="font-size: 0.8rem; color: var(--text-secondary); max-width: 320px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                    <c:out value="${el.description}"/>
                                </div>
                            </td>
                            <td style="font-size: 0.8rem; color: var(--text-secondary); line-height: 1.5;">
                                <div><strong>Start:</strong> <fmt:formatDate value="${el.startTime}" pattern="MMM dd, yyyy HH:mm" /></div>
                                <div><strong>End:</strong> <fmt:formatDate value="${el.endTime}" pattern="MMM dd, yyyy HH:mm" /></div>
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
                            <td>
                                <a href="${pageContext.request.contextPath}/admin/candidates?electionId=${el.id}" style="color: #60a5fa; text-decoration: none; font-weight: 600;">
                                    <c:out value="${el.candidatesCount}"/>
                                </a>
                            </td>
                            <td style="font-weight: 700;">
                                <c:out value="${el.totalVotes}"/>
                            </td>
                            <td style="text-align: right; white-space: nowrap;">
                                <div style="display: inline-flex; align-items: center; gap: 0.4rem;">
                                    <!-- Status Workflow Action Buttons (Server Enforced) -->
                                    <c:if test="${el.status == 'UPCOMING'}">
                                        <form action="${pageContext.request.contextPath}/admin/elections" method="post" style="display:inline; margin:0;">
                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                            <input type="hidden" name="action" value="transition">
                                            <input type="hidden" name="electionId" value="${el.id}">
                                            <input type="hidden" name="targetStatus" value="ACTIVE">
                                            <button type="submit" class="btn btn-primary btn-xs"
                                                    data-confirm="Start election '${el.electionName}' and immediately open voting for students?"
                                                    data-confirm-title="Start Election">
                                                Start
                                            </button>
                                        </form>
                                    </c:if>

                                    <c:if test="${el.status == 'ACTIVE'}">
                                        <form action="${pageContext.request.contextPath}/admin/elections" method="post" style="display:inline; margin:0;">
                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                            <input type="hidden" name="action" value="transition">
                                            <input type="hidden" name="electionId" value="${el.id}">
                                            <input type="hidden" name="targetStatus" value="COMPLETED">
                                            <button type="submit" class="btn btn-warning btn-xs"
                                                    data-confirm="Close voting for '${el.electionName}'? No further ballots will be accepted."
                                                    data-confirm-title="Close Voting">
                                                Close
                                            </button>
                                        </form>
                                    </c:if>

                                    <c:if test="${el.status == 'COMPLETED'}">
                                        <form action="${pageContext.request.contextPath}/admin/results" method="post" style="display:inline; margin:0;">
                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                            <input type="hidden" name="action" value="publish">
                                            <input type="hidden" name="electionId" value="${el.id}">
                                            <button type="submit" class="btn btn-success btn-xs"
                                                    data-confirm="Certify and publish results for '${el.electionName}'? Certified tally will be visible to all voters."
                                                    data-confirm-title="Publish Certified Results">
                                                Publish
                                            </button>
                                        </form>
                                    </c:if>

                                    <a href="${pageContext.request.contextPath}/admin/results?electionId=${el.id}" class="btn btn-secondary btn-xs" title="View Results & Tally">
                                        Tally
                                    </a>

                                    <!-- Delete Button (Blocked on server if votes exist) -->
                                    <c:choose>
                                        <c:when test="${el.totalVotes == 0}">
                                            <form action="${pageContext.request.contextPath}/admin/elections" method="post" style="display:inline; margin:0;">
                                                <input type="hidden" name="_csrf" value="${csrfToken}">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="electionId" value="${el.id}">
                                                <button type="submit" class="btn btn-danger btn-xs"
                                                        data-confirm="Permanently delete election '${el.electionName}'? This cannot be undone."
                                                        data-confirm-title="Delete Election"
                                                        data-confirm-danger="true"
                                                        title="Delete Election">
                                                    Delete
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="btn btn-secondary btn-xs" disabled title="Cannot delete: votes have been cast.">
                                                Locked
                                            </button>
                                        </c:otherwise>
                                    </c:choose>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 3rem;">
                            No elections found matching current filters.
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
            <a href="${pageContext.request.contextPath}/admin/elections?page=${currentPage - 1}&q=${searchQuery}&status=${currentStatus}"
               class="page-btn ${currentPage <= 1 ? 'disabled' : ''}">&laquo; Prev</a>
            <c:forEach var="p" begin="1" end="${totalPages}">
                <a href="${pageContext.request.contextPath}/admin/elections?page=${p}&q=${searchQuery}&status=${currentStatus}"
                   class="page-btn ${currentPage == p ? 'active' : ''}"><c:out value="${p}"/></a>
            </c:forEach>
            <a href="${pageContext.request.contextPath}/admin/elections?page=${currentPage + 1}&q=${searchQuery}&status=${currentStatus}"
               class="page-btn ${currentPage >= totalPages ? 'disabled' : ''}">Next &raquo;</a>
        </div>
    </div>
</c:if>

<!-- Create Election Modal -->
<div class="modal-overlay" id="createElectionModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title">Create New Election</h3>
            <button type="button" class="modal-close-btn" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/elections" method="post">
            <input type="hidden" name="_csrf" value="${csrfToken}">
            <input type="hidden" name="action" value="create">

            <div class="form-group" style="margin-bottom: 1rem;">
                <label class="form-label">Election Title *</label>
                <input type="text" name="electionName" required minlength="3" maxlength="150" class="form-control" placeholder="e.g. Student Council Presidential Election 2026">
            </div>

            <div class="form-group" style="margin-bottom: 1rem;">
                <label class="form-label">Description</label>
                <textarea name="description" rows="3" class="form-control" placeholder="Institutional guidelines and ballot description..."></textarea>
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 1rem; margin-bottom: 1rem;">
                <div class="form-group">
                    <label class="form-label">Start Date & Time *</label>
                    <input type="datetime-local" name="startTime" required class="form-control">
                </div>
                <div class="form-group">
                    <label class="form-label">End Date & Time *</label>
                    <input type="datetime-local" name="endTime" required class="form-control">
                </div>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-secondary btn-sm" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary btn-sm">Create Election</button>
            </div>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/fragments/admin-footer.jspf" %>
