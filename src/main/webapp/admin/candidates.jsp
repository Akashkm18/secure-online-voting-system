<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    if (request.getAttribute("candidates") == null) {
        dao.CandidateDAO cDao = new dao.CandidateDAO();
        dao.ElectionDAO eDao = new dao.ElectionDAO();
        request.setAttribute("candidates", cDao.getAllCandidates());
        request.setAttribute("elections", eDao.getAllElections());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Candidates | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/fragments/admin-sidebar.jsp" />

        <main class="admin-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h1 style="font-size: 1.65rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">Candidate Registry</h1>
                    <p style="color: var(--text-secondary); font-size: 0.875rem; margin: 0;">Nominated candidate profiles, ballot symbols, and slate affiliations</p>
                </div>
                <div style="display: flex; gap: 0.75rem;">
                    <button type="button" class="btn btn-primary btn-sm" data-modal-open="addCandidateModal">
                        + Add Candidate
                    </button>
                </div>
            </div>

            <!-- Feedback Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <circle cx="12" cy="12" r="10"/><line x1="12" y1="8" x2="12" y2="12"/><line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <c:if test="${param.success == 'added'}">
                <div class="alert alert-success">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    <div>Candidate nominated successfully.</div>
                </div>
            </c:if>

            <c:if test="${param.success == 'updated'}">
                <div class="alert alert-success">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    <div>Candidate updated successfully.</div>
                </div>
            </c:if>

            <c:if test="${param.success == 'deleted'}">
                <div class="alert alert-success">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    <div>Candidate deleted successfully.</div>
                </div>
            </c:if>

            <!-- Search and Filter Bar -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 1rem;">
                <div style="display: flex; align-items: center; gap: 0.5rem; flex: 1; max-width: 380px;">
                    <input type="text" data-table-filter="candidatesTable" class="form-control" placeholder="Search candidates by name, party, or symbol..." style="font-size: 0.85rem;" />
                </div>
                <div style="font-size: 0.85rem; color: var(--text-secondary);">
                    Total Candidates: <strong style="color: var(--text-primary);"><c:out value="${candidates.size()}" /></strong>
                </div>
            </div>

            <!-- Candidates Table -->
            <div class="table-responsive card" style="padding: 0; overflow: hidden; background: var(--bg-surface-elevated);">
                <table class="table" id="candidatesTable">
                    <thead>
                        <tr>
                            <th style="width: 70px;">ID</th>
                            <th>Candidate Name</th>
                            <th>Party / Affiliation</th>
                            <th>Emblem Symbol</th>
                            <th>Election</th>
                            <th>Status</th>
                            <th style="text-align: right;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty candidates}">
                                <c:forEach var="c" items="${candidates}">
                                    <tr>
                                        <td style="font-family: monospace; font-size: 0.8rem; color: var(--text-muted);">#<c:out value="${c.id}" /></td>
                                        <td style="font-weight: 600; color: var(--text-primary);"><c:out value="${c.candidateName}" /></td>
                                        <td><c:out value="${c.party}" /></td>
                                        <td><span class="badge badge-pending"><c:out value="${c.symbol}" /></span></td>
                                        <td style="font-size: 0.85rem;"><c:out value="${c.electionName}" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${c.active}"><span class="badge badge-active">Active</span></c:when>
                                                <c:otherwise><span class="badge badge-completed">Deactivated</span></c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: right;">
                                            <div style="display: inline-flex; gap: 0.35rem; align-items: center;">
                                                <button type="button" class="btn btn-secondary btn-sm btn-edit-candidate"
                                                        data-id="${c.id}"
                                                        data-name="<c:out value='${c.candidateName}' />"
                                                        data-party="<c:out value='${c.party}' />"
                                                        data-symbol="<c:out value='${c.symbol}' />"
                                                        data-active="${c.active}">
                                                    Edit
                                                </button>

                                                <form action="${pageContext.request.contextPath}/admin/candidates" method="POST" style="display:inline;">
                                                    <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                                                    <input type="hidden" name="action" value="toggleActive" />
                                                    <input type="hidden" name="candidateId" value="${c.id}" />
                                                    <input type="hidden" name="active" value="${!c.active}" />
                                                    <button type="submit" class="btn btn-secondary btn-sm">
                                                        ${c.active ? 'Disable' : 'Enable'}
                                                    </button>
                                                </form>

                                                <form action="${pageContext.request.contextPath}/admin/candidates" method="POST" style="display:inline;" data-confirm="Are you sure you want to permanently delete candidate ${c.candidateName}?" data-confirm-title="Confirm Candidate Deletion">
                                                    <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                                                    <input type="hidden" name="action" value="delete" />
                                                    <input type="hidden" name="candidateId" value="${c.id}" />
                                                    <button type="submit" class="btn btn-secondary btn-sm" style="color: var(--danger);">
                                                        Delete
                                                    </button>
                                                </form>
                                            </div>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:choose>
                            <c:otherwise>
                                <tr>
                                    <td colspan="7" style="text-align: center; padding: 3rem; color: var(--text-secondary);">
                                        No candidates registered yet.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- Add Candidate Modal -->
    <div class="modal-overlay" id="addCandidateModal">
        <div class="modal-box" style="max-width: 520px; text-align: left;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.15rem; color: var(--text-primary);">Register Candidate</h3>
                <button type="button" class="btn btn-secondary btn-sm" data-modal-close="addCandidateModal">✕</button>
            </div>

            <form action="${pageContext.request.contextPath}/admin/candidates" method="POST" autocomplete="off">
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                <input type="hidden" name="action" value="add" />

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="electionId">Contesting Election</label>
                    <select id="electionId" name="electionId" class="form-control" required>
                        <option value="">-- Choose Election --</option>
                        <c:forEach var="el" items="${elections}">
                            <option value="${el.id}">#${el.id} - ${el.electionName} (${el.status})</option>
                        </c:forEach>
                    </select>
                </div>

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="candidateName">Candidate Full Name</label>
                    <input type="text" id="candidateName" name="candidateName" class="form-control" placeholder="e.g. Alex Morgan" required />
                </div>

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="party">Party / Slate Affiliation</label>
                    <input type="text" id="party" name="party" class="form-control" placeholder="e.g. Independent Student Alliance" required />
                </div>

                <div class="form-group" style="margin-bottom: 1.25rem;">
                    <label for="symbol">Emblem / Ballot Symbol</label>
                    <input type="text" id="symbol" name="symbol" class="form-control" placeholder="e.g. Torch of Liberty" required />
                </div>

                <div style="display: flex; gap: 0.75rem; justify-content: flex-end; border-top: 1px solid var(--border-color); padding-top: 1rem;">
                    <button type="button" class="btn btn-secondary btn-sm" data-modal-close="addCandidateModal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Add Candidate</button>
                </div>
            </form>
        </div>
    </div>

    <!-- Edit Candidate Modal -->
    <div class="modal-overlay" id="editCandidateModal">
        <div class="modal-box" style="max-width: 520px; text-align: left;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.15rem; color: var(--text-primary);">Edit Candidate Details</h3>
                <button type="button" class="btn btn-secondary btn-sm" data-modal-close="editCandidateModal">✕</button>
            </div>

            <form action="${pageContext.request.contextPath}/admin/candidates" method="POST">
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                <input type="hidden" name="action" value="edit" />
                <input type="hidden" name="candidateId" id="editCandidateId" />

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="editCandidateName">Candidate Full Name</label>
                    <input type="text" id="editCandidateName" name="candidateName" class="form-control" required />
                </div>

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="editParty">Party / Slate Affiliation</label>
                    <input type="text" id="editParty" name="party" class="form-control" required />
                </div>

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="editSymbol">Emblem / Ballot Symbol</label>
                    <input type="text" id="editSymbol" name="symbol" class="form-control" required />
                </div>

                <div class="form-group" style="margin-bottom: 1.25rem;">
                    <label for="editActive">Status</label>
                    <select id="editActive" name="active" class="form-control">
                        <option value="true">Active</option>
                        <option value="false">Deactivated</option>
                    </select>
                </div>

                <div style="display: flex; gap: 0.75rem; justify-content: flex-end; border-top: 1px solid var(--border-color); padding-top: 1rem;">
                    <button type="button" class="btn btn-secondary btn-sm" data-modal-close="editCandidateModal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
