<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<c:set var="pageTitle" value="Voters Registry" />
<%@ include file="/WEB-INF/fragments/admin-header.jspf" %>

<div class="admin-page-header">
    <div>
        <h1 class="admin-page-title">Voter Registry & Identity Verification</h1>
        <p class="admin-page-subtitle">Roster of student voters, identity document approvals, and voting participation records</p>
    </div>
    <div class="admin-header-actions">
        <a href="${pageContext.request.contextPath}/admin/voters?export=csv&q=${searchQuery}&status=${currentStatus}" class="btn btn-secondary btn-sm" title="Download Voter Registry as CSV">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="7 10 12 15 17 10"></polyline>
                <line x1="12" y1="15" x2="12" y2="3"></line>
            </svg>
            <span>Export CSV</span>
        </a>
    </div>
</div>

<!-- Search, Status Filter & Summary Tabs -->
<form action="${pageContext.request.contextPath}/admin/voters" method="get" class="filter-bar">
    <div class="filter-group">
        <input type="text" name="q" value="<c:out value="${searchQuery}"/>" placeholder="Search by name, email, student ID..." class="filter-input">
        <select name="status" class="filter-select">
            <option value="ALL" ${currentStatus == 'ALL' ? 'selected' : ''}>All Statuses (${totalItems})</option>
            <option value="PENDING" ${currentStatus == 'PENDING' ? 'selected' : ''}>Pending (${pendingCount})</option>
            <option value="APPROVED" ${currentStatus == 'APPROVED' ? 'selected' : ''}>Approved (${approvedCount})</option>
            <option value="REJECTED" ${currentStatus == 'REJECTED' ? 'selected' : ''}>Rejected (${rejectedCount})</option>
            <option value="DISABLED" ${currentStatus == 'DISABLED' ? 'selected' : ''}>Disabled (${disabledCount})</option>
        </select>
        <button type="submit" class="btn btn-secondary btn-sm">Search</button>
        <c:if test="${not empty searchQuery or currentStatus != 'ALL'}">
            <a href="${pageContext.request.contextPath}/admin/voters" class="btn btn-secondary btn-sm">Reset</a>
        </c:if>
    </div>
    <div style="font-size: 0.85rem; color: var(--text-secondary);">
        Found Voters: <strong style="color: var(--text-primary);"><c:out value="${totalItems}"/></strong>
    </div>
</form>

<!-- Voters Registry Table -->
<div class="table-responsive">
    <table class="admin-table">
        <thead>
            <tr>
                <th style="width: 50px;">Photo</th>
                <th>Student Name</th>
                <th>Institutional Email</th>
                <th>Student ID</th>
                <th>Status</th>
                <th>Has Voted</th>
                <th>Registered At</th>
                <th style="text-align: right;">Actions</th>
            </tr>
        </thead>
        <tbody>
            <c:choose>
                <c:when test="${not empty voters}">
                    <c:forEach var="v" items="${voters}">
                        <tr>
                            <td>
                                <c:choose>
                                    <c:when test="${not empty v.photoBase64}">
                                        <img src="${v.photoBase64}" alt="<c:out value="${v.fullName}"/>" class="candidate-avatar-thumb">
                                    </c:when>
                                    <c:otherwise>
                                        <div class="candidate-avatar-thumb" style="display:flex; align-items:center; justify-content:center; background:#1e293b; color:var(--text-muted); font-size:0.75rem; font-weight:700;">
                                            AU
                                        </div>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <div style="font-weight: 600; color: var(--text-primary);">
                                    <c:out value="${v.fullName}"/>
                                </div>
                                <div style="font-size: 0.75rem; color: var(--text-secondary);">
                                    <c:out value="${v.programName != null ? v.programName : 'Student'}"/>
                                </div>
                            </td>
                            <td style="color: var(--text-secondary); font-size: 0.85rem;">
                                <c:out value="${v.email}"/>
                            </td>
                            <td style="font-family: monospace; font-size: 0.82rem; color: var(--text-primary);">
                                <c:out value="${v.collegeId != null ? v.collegeId : 'N/A'}"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${v.status == 'APPROVED'}">
                                        <span class="badge-status badge-approved">APPROVED</span>
                                    </c:when>
                                    <c:when test="${v.status == 'PENDING'}">
                                        <span class="badge-status badge-pending">PENDING</span>
                                    </c:when>
                                    <c:when test="${v.status == 'REJECTED'}">
                                        <span class="badge-status badge-rejected" title="<c:out value="${v.rejectionReason}"/>">REJECTED</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status badge-disabled">DISABLED</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${v.hasVoted}">
                                        <span class="badge-status badge-active" style="font-size: 0.68rem;">YES</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status badge-disabled" style="font-size: 0.68rem;">NO</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="font-size: 0.78rem; color: var(--text-secondary); white-space: nowrap;">
                                <fmt:formatDate value="${v.createdAt}" pattern="MMM dd, yyyy" />
                            </td>
                            <td style="text-align: right; white-space: nowrap;">
                                <div style="display: inline-flex; align-items: center; gap: 0.35rem;">
                                    <!-- Voter Detail View Button -->
                                    <a href="${pageContext.request.contextPath}/admin/voters?detailId=${v.id}&q=${searchQuery}&status=${currentStatus}"
                                       class="btn btn-secondary btn-xs"
                                       title="View Voter Details & Election Participation History">
                                        Detail
                                    </a>

                                    <!-- Approve button for pending accounts -->
                                    <c:if test="${v.status == 'PENDING' || v.status == 'REJECTED'}">
                                        <form action="${pageContext.request.contextPath}/admin/voters" method="post" style="display:inline; margin:0;">
                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                            <input type="hidden" name="action" value="approve">
                                            <input type="hidden" name="voterId" value="${v.id}">
                                            <button type="submit" class="btn btn-success btn-xs"
                                                    data-confirm="Approve voter '${v.fullName}' (${v.email}) for official election balloting?"
                                                    data-confirm-title="Approve Voter Identity">
                                                Approve
                                            </button>
                                        </form>
                                    </c:if>

                                    <!-- Reject Modal Trigger for pending accounts -->
                                    <c:if test="${v.status == 'PENDING'}">
                                        <button type="button" class="btn btn-danger btn-xs" data-modal-open="#rejectModal_${v.id}">
                                            Reject
                                        </button>

                                        <!-- Reject Modal with Reason Input -->
                                        <div class="modal-overlay" id="rejectModal_${v.id}">
                                            <div class="modal-box" style="text-align: left;">
                                                <div class="modal-header">
                                                    <h3 class="modal-title">Reject Voter Application</h3>
                                                    <button type="button" class="modal-close-btn" data-modal-close>&times;</button>
                                                </div>
                                                <form action="${pageContext.request.contextPath}/admin/voters" method="post">
                                                    <input type="hidden" name="_csrf" value="${csrfToken}">
                                                    <input type="hidden" name="action" value="reject">
                                                    <input type="hidden" name="voterId" value="${v.id}">

                                                    <div style="font-size: 0.9rem; color: var(--text-secondary); margin-bottom: 1rem;">
                                                        Rejecting registration for <strong><c:out value="${v.fullName}"/></strong> (<c:out value="${v.email}"/>). Please supply a rejection reason:
                                                    </div>

                                                    <div class="form-group" style="margin-bottom: 1rem;">
                                                        <label class="form-label">Rejection Reason *</label>
                                                        <textarea name="rejectionReason" required rows="3" class="form-control" placeholder="e.g. Scanned College ID is blurry or does not match institutional student roster..."></textarea>
                                                    </div>

                                                    <div class="modal-actions">
                                                        <button type="button" class="btn btn-secondary btn-sm" data-modal-close>Cancel</button>
                                                        <button type="submit" class="btn btn-danger btn-sm">Confirm Rejection</button>
                                                    </div>
                                                </form>
                                            </div>
                                        </div>
                                    </c:if>

                                    <!-- Toggle Active / Disabled Button -->
                                    <c:if test="${v.status != 'PENDING'}">
                                        <form action="${pageContext.request.contextPath}/admin/voters" method="post" style="display:inline; margin:0;">
                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                            <input type="hidden" name="action" value="toggleStatus">
                                            <input type="hidden" name="voterId" value="${v.id}">
                                            <button type="submit" class="btn btn-secondary btn-xs"
                                                    data-confirm="${v.active ? 'Disable account access for this voter?' : 'Enable account access for this voter?'}"
                                                    data-confirm-title="Change Access Status">
                                                <c:out value="${v.active ? 'Disable' : 'Enable'}"/>
                                            </button>
                                        </form>
                                    </c:if>

                                    <!-- Reset Password Button (One-time temporary password generated) -->
                                    <form action="${pageContext.request.contextPath}/admin/voters" method="post" style="display:inline; margin:0;">
                                        <input type="hidden" name="_csrf" value="${csrfToken}">
                                        <input type="hidden" name="action" value="resetPassword">
                                        <input type="hidden" name="voterId" value="${v.id}">
                                        <button type="submit" class="btn btn-warning btn-xs"
                                                data-confirm="Generate a one-time temporary password for '${v.fullName}'? The user will be required to change their password on the next login."
                                                data-confirm-title="Reset Voter Password"
                                                title="Generate Temporary Password">
                                            Reset PW
                                        </button>
                                    </form>

                                    <!-- Delete Button (Only if has not voted) -->
                                    <c:choose>
                                        <c:when test="${!v.hasVoted}">
                                            <form action="${pageContext.request.contextPath}/admin/voters" method="post" style="display:inline; margin:0;">
                                                <input type="hidden" name="_csrf" value="${csrfToken}">
                                                <input type="hidden" name="action" value="delete">
                                                <input type="hidden" name="voterId" value="${v.id}">
                                                <button type="submit" class="btn btn-danger btn-xs"
                                                        data-confirm="Permanently delete voter record for '${v.fullName}'?"
                                                        data-confirm-title="Delete Voter"
                                                        data-confirm-danger="true"
                                                        title="Delete Voter">
                                                    Delete
                                                </button>
                                            </form>
                                        </c:when>
                                        <c:otherwise>
                                            <button type="button" class="btn btn-secondary btn-xs" disabled title="Cannot delete: voter has cast votes.">
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
                        <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 3rem;">
                            No voter records found matching query.
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
            <a href="${pageContext.request.contextPath}/admin/voters?page=${currentPage - 1}&q=${searchQuery}&status=${currentStatus}"
               class="page-btn ${currentPage <= 1 ? 'disabled' : ''}">&laquo; Prev</a>
            <c:forEach var="p" begin="1" end="${totalPages}">
                <a href="${pageContext.request.contextPath}/admin/voters?page=${p}&q=${searchQuery}&status=${currentStatus}"
                   class="page-btn ${currentPage == p ? 'active' : ''}"><c:out value="${p}"/></a>
            </c:forEach>
            <a href="${pageContext.request.contextPath}/admin/voters?page=${currentPage + 1}&q=${searchQuery}&status=${currentStatus}"
               class="page-btn ${currentPage >= totalPages ? 'disabled' : ''}">Next &raquo;</a>
        </div>
    </div>
</c:if>

<!-- Voter Detail View Modal (Profile, Status, and Election Participation) -->
<c:if test="${not empty voterDetail}">
    <div class="modal-overlay active" id="adminDetailModal">
        <div class="modal-box" style="max-width: 620px;">
            <div class="modal-header">
                <h3 class="modal-title">Voter Profile & Participation History</h3>
                <a href="${pageContext.request.contextPath}/admin/voters?q=${searchQuery}&status=${currentStatus}" class="modal-close-btn">&times;</a>
            </div>

            <!-- Profile Summary Card -->
            <div style="display: flex; gap: 1.25rem; align-items: center; padding: 1rem; background: var(--bg-main); border-radius: var(--radius-sm); margin-bottom: 1.5rem;">
                <c:choose>
                    <c:when test="${not empty voterDetail.photoBase64}">
                        <img src="${voterDetail.photoBase64}" alt="<c:out value="${voterDetail.fullName}"/>" style="width: 72px; height: 72px; border-radius: 50%; object-fit: cover; border: 2px solid var(--primary);">
                    </c:when>
                    <c:otherwise>
                        <div style="width: 72px; height: 72px; border-radius: 50%; background: #1e293b; color: var(--text-secondary); display: flex; align-items: center; justify-content: center; font-weight: 700; font-size: 1.25rem;">
                            AU
                        </div>
                    </c:otherwise>
                </c:choose>
                <div>
                    <h4 style="font-size: 1.1rem; color: var(--text-primary); margin: 0 0 0.25rem 0;"><c:out value="${voterDetail.fullName}"/></h4>
                    <div style="font-size: 0.85rem; color: var(--text-secondary);"><c:out value="${voterDetail.email}"/></div>
                    <div style="font-size: 0.82rem; color: var(--text-muted); margin-top: 0.25rem;">
                        Student ID: <strong><c:out value="${voterDetail.collegeId}"/></strong> | Status: <strong style="color:#60a5fa;"><c:out value="${voterDetail.status}"/></strong>
                    </div>
                    <c:if test="${not empty voterDetail.rejectionReason}">
                        <div style="font-size: 0.8rem; color: #f87171; margin-top: 0.35rem;">Reason: <c:out value="${voterDetail.rejectionReason}"/></div>
                    </c:if>
                </div>
            </div>

            <!-- Participation per Election (100% Ballot Secrecy Maintained: Shows voted/not, NEVER candidate) -->
            <h4 style="font-size: 0.95rem; color: var(--text-primary); margin-bottom: 0.75rem;">Election Participation Telemetry</h4>
            <div class="table-responsive" style="margin-bottom: 1rem;">
                <table class="admin-table">
                    <thead>
                        <tr>
                            <th>Election Title</th>
                            <th>Status</th>
                            <th>Turnout</th>
                            <th>Timestamp</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty voterParticipation}">
                                <c:forEach var="p" items="${voterParticipation}">
                                    <tr>
                                        <td style="font-weight: 600; color: var(--text-primary);">
                                            <c:out value="${p.electionName}"/>
                                        </td>
                                        <td>
                                            <span class="badge-status badge-${p.electionStatus == 'ACTIVE' ? 'active' : 'disabled'}">
                                                <c:out value="${p.electionStatus}"/>
                                            </span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${p.hasVoted}">
                                                    <span class="badge-status badge-active" style="font-size: 0.7rem;">BALLOT CAST</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge-status badge-disabled" style="font-size: 0.7rem;">DID NOT VOTE</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="font-size: 0.75rem; color: var(--text-secondary);">
                                            <c:choose>
                                                <c:when test="${not empty p.votedAt}">
                                                    <fmt:formatDate value="${p.votedAt}" pattern="MMM dd, HH:mm" />
                                                </c:when>
                                                <c:otherwise>&mdash;</c:otherwise>
                                            </c:choose>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:when>
                            <c:otherwise>
                                <tr>
                                    <td colspan="4" style="text-align: center; color: var(--text-muted); padding: 1.5rem;">
                                        No election participation records found.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>

            <div class="modal-actions">
                <a href="${pageContext.request.contextPath}/admin/voters?q=${searchQuery}&status=${currentStatus}" class="btn btn-secondary btn-sm">Close</a>
            </div>
        </div>
    </div>
</c:if>

<%@ include file="/WEB-INF/fragments/admin-footer.jspf" %>
