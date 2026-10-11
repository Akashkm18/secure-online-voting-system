<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<c:set var="pageTitle" value="Candidate Registry" />
<%@ include file="/WEB-INF/fragments/admin-header.jspf" %>

<div class="admin-page-header">
    <div>
        <h1 class="admin-page-title">Candidate Registry & Photos</h1>
        <p class="admin-page-subtitle">Nominated candidate profiles, high-resolution official photos, and election slates</p>
    </div>
    <div class="admin-header-actions">
        <button type="button" class="btn btn-primary btn-sm" data-modal-open="#addCandidateModal">
            <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            <span>Add Candidate</span>
        </button>
    </div>
</div>

<!-- Election Filter Bar -->
<form action="${pageContext.request.contextPath}/admin/candidates" method="get" class="filter-bar">
    <div class="filter-group">
        <label for="electionFilter" style="font-size: 0.85rem; color: var(--text-secondary);">Election Filter:</label>
        <select id="electionFilter" name="electionId" class="filter-select" onchange="this.form.submit()">
            <option value="">All Elections</option>
            <c:forEach var="el" items="${allElections}">
                <option value="${el.id}" ${selectedElectionId == el.id ? 'selected' : ''}>
                    <c:out value="${el.electionName}"/> (<c:out value="${el.status}"/>)
                </option>
            </c:forEach>
        </select>
        <c:if test="${not empty selectedElectionId}">
            <a href="${pageContext.request.contextPath}/admin/candidates" class="btn btn-secondary btn-sm">Clear Filter</a>
        </c:if>
    </div>
    <div style="font-size: 0.85rem; color: var(--text-secondary);">
        Total Candidates: <strong style="color: var(--text-primary);"><c:out value="${candidates.size()}"/></strong>
    </div>
</form>

<!-- Candidates Table with Photo Avatars -->
<div class="table-responsive">
    <table class="admin-table">
        <thead>
            <tr>
                <th style="width: 60px;">Photo</th>
                <th>Candidate Name & Position</th>
                <th>Party / Slate</th>
                <th>Emblem</th>
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
                            <td>
                                <img src="${pageContext.request.contextPath}/candidate-photo?id=${c.id}"
                                     alt="<c:out value="${c.candidateName}"/>"
                                     class="candidate-avatar-thumb">
                            </td>
                            <td>
                                <div style="font-weight: 600; color: var(--text-primary); font-size: 0.92rem;">
                                    <c:out value="${c.candidateName}"/>
                                </div>
                                <div style="font-size: 0.8rem; color: var(--text-secondary);">
                                    <c:out value="${c.position != null ? c.position : 'Candidate'}"/>
                                </div>
                            </td>
                            <td>
                                <span style="color: var(--text-primary); font-weight: 500;"><c:out value="${c.party}"/></span>
                            </td>
                            <td>
                                <span class="badge badge-secondary" style="font-size: 0.75rem; background: rgba(255,255,255,0.06); padding: 0.2rem 0.5rem; border-radius: 4px;">
                                    <c:out value="${c.symbol}"/>
                                </span>
                            </td>
                            <td style="font-size: 0.85rem; color: var(--text-secondary);">
                                <c:out value="${c.electionName}"/>
                            </td>
                            <td>
                                <c:choose>
                                    <c:when test="${c.active}">
                                        <span class="badge-status badge-active">ACTIVE</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge-status badge-disabled">INACTIVE</span>
                                    </c:otherwise>
                                </c:choose>
                            </td>
                            <td style="text-align: right; white-space: nowrap;">
                                <div style="display: inline-flex; align-items: center; gap: 0.4rem;">
                                    <button type="button" class="btn btn-secondary btn-xs" data-modal-open="#editModal_${c.id}">
                                        Edit
                                    </button>

                                    <!-- Delete candidate form (vote-protected) -->
                                    <form action="${pageContext.request.contextPath}/admin/candidates?_csrf=${csrfToken}" method="post" style="display:inline; margin:0;">
                                        <input type="hidden" name="_csrf" value="${csrfToken}">
                                        <input type="hidden" name="action" value="delete">
                                        <input type="hidden" name="candidateId" value="${c.id}">
                                        <input type="hidden" name="filterElectionId" value="${selectedElectionId}">
                                        <button type="submit" class="btn btn-danger btn-xs"
                                                data-confirm="Permanently delete candidate '${c.candidateName}'? Cannot be deleted if votes have already been cast."
                                                data-confirm-title="Delete Candidate"
                                                data-confirm-danger="true">
                                            Delete
                                        </button>
                                    </form>
                                </div>

                                <!-- Individual Edit Candidate Modal -->
                                <div class="modal-overlay" id="editModal_${c.id}">
                                    <div class="modal-box" style="text-align: left;">
                                        <div class="modal-header">
                                            <h3 class="modal-title">Edit Candidate: <c:out value="${c.candidateName}"/></h3>
                                            <button type="button" class="modal-close-btn" data-modal-close>&times;</button>
                                        </div>
                                        <form action="${pageContext.request.contextPath}/admin/candidates?_csrf=${csrfToken}"
                                              method="post"
                                              enctype="multipart/form-data">
                                            <input type="hidden" name="_csrf" value="${csrfToken}">
                                            <input type="hidden" name="action" value="edit">
                                            <input type="hidden" name="candidateId" value="${c.id}">
                                            <input type="hidden" name="filterElectionId" value="${selectedElectionId}">

                                            <!-- Photo Preview & Replace -->
                                            <div style="text-align: center; margin-bottom: 1.25rem;">
                                                <img id="editPhotoPreview_${c.id}"
                                                     src="${pageContext.request.contextPath}/candidate-photo?id=${c.id}"
                                                     data-default-src="${pageContext.request.contextPath}/candidate-photo?id=${c.id}"
                                                     class="candidate-photo-preview"
                                                     alt="Candidate Photo">

                                                <label class="btn btn-secondary btn-xs" style="cursor: pointer; margin-right: 0.5rem;">
                                                    Replace Photo
                                                    <input type="file" name="photo" accept="image/png,image/jpeg" style="display:none;"
                                                           data-photo-input
                                                           data-preview-target="#editPhotoPreview_${c.id}"
                                                           data-error-target="#editPhotoError_${c.id}">
                                                </label>
                                                <div id="editPhotoError_${c.id}" style="color: var(--danger); font-size: 0.75rem; margin-top: 0.25rem;"></div>
                                            </div>

                                            <div class="form-group" style="margin-bottom: 0.85rem;">
                                                <label class="form-label">Full Name *</label>
                                                <input type="text" name="candidateName" value="<c:out value="${c.candidateName}"/>" required maxlength="100" class="form-control">
                                            </div>

                                            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; margin-bottom: 0.85rem;">
                                                <div class="form-group">
                                                    <label class="form-label">Position *</label>
                                                    <input type="text" name="position" value="<c:out value="${c.position}"/>" maxlength="100" class="form-control">
                                                </div>
                                                <div class="form-group">
                                                    <label class="form-label">Party / Slate *</label>
                                                    <input type="text" name="party" value="<c:out value="${c.party}"/>" required maxlength="100" class="form-control">
                                                </div>
                                            </div>

                                            <div class="form-group" style="margin-bottom: 0.85rem;">
                                                <label class="form-label">Emblem / Symbol *</label>
                                                <input type="text" name="symbol" value="<c:out value="${c.symbol}"/>" required maxlength="50" class="form-control">
                                            </div>

                                            <div class="form-group" style="margin-bottom: 0.85rem;">
                                                <label class="form-label">Short Bio (Max 500 chars)</label>
                                                <textarea name="bio" rows="2" maxlength="500" class="form-control"><c:out value="${c.bio}"/></textarea>
                                            </div>

                                            <div class="form-group" style="margin-bottom: 0.85rem;">
                                                <label class="form-label">Manifesto (Max 1000 chars)</label>
                                                <textarea name="manifesto" rows="3" maxlength="1000" class="form-control"><c:out value="${c.manifesto}"/></textarea>
                                            </div>

                                            <div class="modal-actions">
                                                <button type="button" class="btn btn-secondary btn-sm" data-modal-close>Cancel</button>
                                                <button type="submit" class="btn btn-primary btn-sm">Save Changes</button>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                            </td>
                        </tr>
                    </c:forEach>
                </c:when>
                <c:otherwise>
                    <tr>
                        <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 3rem;">
                            No candidates registered under the selected election. Click "Add Candidate" to nominate candidates.
                        </td>
                    </tr>
                </c:otherwise>
            </c:choose>
        </tbody>
    </table>
</div>

<!-- Add Candidate Modal -->
<div class="modal-overlay" id="addCandidateModal">
    <div class="modal-box">
        <div class="modal-header">
            <h3 class="modal-title">Add Candidate Nominee</h3>
            <button type="button" class="modal-close-btn" data-modal-close>&times;</button>
        </div>
        <form action="${pageContext.request.contextPath}/admin/candidates?_csrf=${csrfToken}"
              method="post"
              enctype="multipart/form-data">
            <input type="hidden" name="_csrf" value="${csrfToken}">
            <input type="hidden" name="action" value="add">
            <input type="hidden" name="filterElectionId" value="${selectedElectionId}">

            <!-- Photo Upload Area with Live Preview -->
            <div style="text-align: center; margin-bottom: 1.25rem;">
                <img id="addPhotoPreview"
                     src="${pageContext.request.contextPath}/candidate-photo?id=0"
                     data-default-src="${pageContext.request.contextPath}/candidate-photo?id=0"
                     class="candidate-photo-preview"
                     alt="Photo Preview">

                <div style="display: flex; justify-content: center; gap: 0.5rem; align-items: center;">
                    <label class="btn btn-secondary btn-xs" style="cursor: pointer;">
                        Choose Photo (JPEG/PNG &le; 2MB)
                        <input type="file" name="photo" accept="image/png,image/jpeg" style="display:none;"
                               data-photo-input
                               data-preview-target="#addPhotoPreview"
                               data-error-target="#addPhotoError"
                               data-clear-target="#clearAddPhotoBtn">
                    </label>
                    <button type="button" id="clearAddPhotoBtn" class="btn btn-danger btn-xs" style="display:none;">Remove</button>
                </div>
                <div id="addPhotoError" style="color: var(--danger); font-size: 0.75rem; margin-top: 0.25rem;"></div>
            </div>

            <div class="form-group" style="margin-bottom: 0.85rem;">
                <label class="form-label">Election *</label>
                <select name="electionId" required class="form-control">
                    <option value="">-- Select Election --</option>
                    <c:forEach var="el" items="${allElections}">
                        <option value="${el.id}" ${selectedElectionId == el.id ? 'selected' : ''}>
                            <c:out value="${el.electionName}"/> (<c:out value="${el.status}"/>)
                        </option>
                    </c:forEach>
                </select>
            </div>

            <div class="form-group" style="margin-bottom: 0.85rem;">
                <label class="form-label">Candidate Full Name *</label>
                <input type="text" name="candidateName" required maxlength="100" class="form-control" placeholder="e.g. Maya Sharma">
            </div>

            <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.75rem; margin-bottom: 0.85rem;">
                <div class="form-group">
                    <label class="form-label">Position *</label>
                    <input type="text" name="position" maxlength="100" class="form-control" placeholder="e.g. Student Council President" value="President">
                </div>
                <div class="form-group">
                    <label class="form-label">Party / Slate *</label>
                    <input type="text" name="party" required maxlength="100" class="form-control" placeholder="e.g. Alliance Innovators">
                </div>
            </div>

            <div class="form-group" style="margin-bottom: 0.85rem;">
                <label class="form-label">Emblem / Symbol *</label>
                <input type="text" name="symbol" required maxlength="50" class="form-control" placeholder="e.g. Rising Sun">
            </div>

            <div class="form-group" style="margin-bottom: 0.85rem;">
                <label class="form-label">Short Bio (Max 500 chars)</label>
                <textarea name="bio" rows="2" maxlength="500" class="form-control" placeholder="Background, major, and student leadership experience..."></textarea>
            </div>

            <div class="form-group" style="margin-bottom: 0.85rem;">
                <label class="form-label">Manifesto (Max 1000 chars)</label>
                <textarea name="manifesto" rows="3" maxlength="1000" class="form-control" placeholder="Key campaign priorities, campus reforms, and commitments..."></textarea>
            </div>

            <div class="modal-actions">
                <button type="button" class="btn btn-secondary btn-sm" data-modal-close>Cancel</button>
                <button type="submit" class="btn btn-primary btn-sm">Add Candidate</button>
            </div>
        </form>
    </div>
</div>

<%@ include file="/WEB-INF/fragments/admin-footer.jspf" %>
