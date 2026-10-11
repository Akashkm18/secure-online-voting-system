<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    if (request.getAttribute("elections") == null) {
        dao.ElectionDAO eDao = new dao.ElectionDAO();
        request.setAttribute("elections", eDao.getAllElections());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Elections | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/fragments/admin-sidebar.jsp" />

        <main class="admin-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h1 style="font-size: 1.65rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">Elections Management</h1>
                    <p style="color: var(--text-secondary); font-size: 0.875rem; margin: 0;">Configure voting windows, launch ballots, and publish certified tallies</p>
                </div>
                <div style="display: flex; gap: 0.75rem;">
                    <button type="button" class="btn btn-primary btn-sm" data-modal-open="createElectionModal">
                        + Create Election
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

            <c:if test="${param.success == 'created'}">
                <div class="alert alert-success">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    <div>New election created successfully.</div>
                </div>
            </c:if>

            <!-- Search and Filter Bar -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 1rem;">
                <div style="display: flex; align-items: center; gap: 0.5rem; flex: 1; max-width: 380px;">
                    <input type="text" data-table-filter="electionsTable" class="form-control" placeholder="Search elections by title or status..." style="font-size: 0.85rem;" />
                </div>
                <div style="font-size: 0.85rem; color: var(--text-secondary);">
                    Total Elections: <strong style="color: var(--text-primary);"><c:out value="${elections.size()}" /></strong>
                </div>
            </div>

            <!-- Elections Table -->
            <div class="table-responsive card" style="padding: 0; overflow: hidden; background: var(--bg-surface-elevated);">
                <table class="table" id="electionsTable">
                    <thead>
                        <tr>
                            <th style="width: 70px;">ID</th>
                            <th>Election Title</th>
                            <th>Voting Window</th>
                            <th>Ballots</th>
                            <th>Status</th>
                            <th style="text-align: right;">Lifecycle Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty elections}">
                                <c:forEach var="el" items="${elections}">
                                    <tr>
                                        <td style="font-family: monospace; font-size: 0.8rem; color: var(--text-muted);">#<c:out value="${el.id}" /></td>
                                        <td>
                                            <div style="font-weight: 600; color: var(--text-primary);"><c:out value="${el.electionName}" /></div>
                                            <div style="font-size: 0.8rem; color: var(--text-secondary);"><c:out value="${el.description}" /></div>
                                        </td>
                                        <td style="font-size: 0.82rem; color: var(--text-secondary); line-height: 1.5;">
                                            <div>Start: <fmt:formatDate value="${el.startTime}" pattern="yyyy-MM-dd HH:mm" /></div>
                                            <div>Close: <fmt:formatDate value="${el.endTime}" pattern="yyyy-MM-dd HH:mm" /></div>
                                        </td>
                                        <td style="font-weight: 700;"><c:out value="${el.totalVotes}" /></td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${el.status == 'ACTIVE'}"><span class="badge badge-active">ACTIVE</span></c:when>
                                                <c:when test="${el.status == 'UPCOMING'}"><span class="badge badge-upcoming">UPCOMING</span></c:when>
                                                <c:when test="${el.status == 'COMPLETED'}"><span class="badge badge-completed">COMPLETED</span></c:when>
                                                <c:when test="${el.status == 'PUBLISHED'}"><span class="badge badge-published">PUBLISHED</span></c:when>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: right;">
                                            <form action="${pageContext.request.contextPath}/admin/elections" method="POST" style="display:inline;" data-confirm="Are you sure you want to transition election #${el.id} status?" data-confirm-title="Update Election Lifecycle">
                                                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                                                <input type="hidden" name="action" value="updateStatus" />
                                                <input type="hidden" name="electionId" value="${el.id}" />

                                                <c:choose>
                                                    <c:when test="${el.status == 'UPCOMING'}">
                                                        <input type="hidden" name="status" value="ACTIVE" />
                                                        <button type="submit" class="btn btn-secondary btn-sm" style="color: var(--success);">Start Voting</button>
                                                    </c:when>
                                                    <c:when test="${el.status == 'ACTIVE'}">
                                                        <input type="hidden" name="status" value="COMPLETED" />
                                                        <button type="submit" class="btn btn-secondary btn-sm" style="color: var(--danger);">Close Ballot</button>
                                                    </c:when>
                                                    <c:when test="${el.status == 'COMPLETED'}">
                                                        <input type="hidden" name="status" value="PUBLISHED" />
                                                        <button type="submit" class="btn btn-primary btn-sm">Publish Results</button>
                                                    </c:when>
                                                    <c:when test="${el.status == 'PUBLISHED'}">
                                                        <a href="${pageContext.request.contextPath}/admin/results?electionId=${el.id}" class="btn btn-secondary btn-sm">
                                                            View Tally
                                                        </a>
                                                    </c:when>
                                                </c:choose>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:choose>
                            <c:otherwise>
                                <tr>
                                    <td colspan="6" style="text-align: center; padding: 3rem; color: var(--text-secondary);">
                                        No elections created yet.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- Create Election Modal -->
    <div class="modal-overlay" id="createElectionModal">
        <div class="modal-box" style="max-width: 560px; text-align: left;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.15rem; color: var(--text-primary);">Create Campus Election</h3>
                <button type="button" class="btn btn-secondary btn-sm" data-modal-close="createElectionModal">✕</button>
            </div>

            <form action="${pageContext.request.contextPath}/admin/elections" method="POST" autocomplete="off">
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                <input type="hidden" name="action" value="create" />

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="electionName">Election Title</label>
                    <input type="text" id="electionName" name="electionName" class="form-control" 
                           placeholder="e.g. Student Council Presidential Election 2026" required minlength="3" maxlength="150" />
                </div>

                <div class="form-group" style="margin-bottom: 0.85rem;">
                    <label for="description">Description / Purpose</label>
                    <textarea id="description" name="description" class="form-control" 
                              placeholder="Describe the offices contesting and ballot guidelines..." rows="3"></textarea>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; margin-bottom: 1.25rem;">
                    <div class="form-group">
                        <label for="startTime">Voting Window Opens</label>
                        <input type="datetime-local" id="startTime" name="startTime" class="form-control" required />
                    </div>

                    <div class="form-group">
                        <label for="endTime">Voting Window Closes</label>
                        <input type="datetime-local" id="endTime" name="endTime" class="form-control" required />
                    </div>
                </div>

                <div style="display: flex; gap: 0.75rem; justify-content: flex-end; border-top: 1px solid var(--border-color); padding-top: 1rem;">
                    <button type="button" class="btn btn-secondary btn-sm" data-modal-close="createElectionModal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Launch Election</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
