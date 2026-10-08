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
            <a href="${pageContext.request.contextPath}/admin/candidates" class="sidebar-link active">
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
        </aside>

        <main class="admin-content">
            <div style="margin-bottom: 2rem;">
                <h1>Candidate Nominations</h1>
                <p class="subtitle">Register candidates, assign political parties and election symbols</p>
            </div>

            <!-- Feedback Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">
                    <span>⚠️</span>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <c:if test="${param.success == 'added'}">
                <div class="alert alert-success">
                    <span>✅</span>
                    <div>Candidate added successfully!</div>
                </div>
            </c:if>

            <c:if test="${param.success == 'updated'}">
                <div class="alert alert-success">
                    <span>✅</span>
                    <div>Candidate updated successfully!</div>
                </div>
            </c:if>

            <c:if test="${param.success == 'deleted'}">
                <div class="alert alert-success">
                    <span>✅</span>
                    <div>Candidate deleted successfully.</div>
                </div>
            </c:if>

            <!-- Add Candidate Form -->
            <section class="card" style="margin-bottom: 2.5rem; background: var(--bg-surface);">
                <h3 style="margin-bottom: 1.25rem;">+ Register Candidate for an Election</h3>
                <form action="${pageContext.request.contextPath}/admin/candidates" method="POST" autocomplete="off">
                    <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                    <input type="hidden" name="action" value="add" />

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
                        <div class="form-group">
                            <label for="electionId">Target Election</label>
                            <select id="electionId" name="electionId" class="form-control" required>
                                <option value="">-- Choose Election --</option>
                                <c:forEach var="el" items="${elections}">
                                    <option value="${el.id}">#${el.id} - ${el.electionName} (${el.status})</option>
                                </c:forEach>
                            </select>
                        </div>

                        <div class="form-group">
                            <label for="candidateName">Candidate Full Name</label>
                            <input type="text" id="candidateName" name="candidateName" class="form-control" placeholder="Maya Sharma" required />
                        </div>

                        <div class="form-group">
                            <label for="party">Party / Slate Name</label>
                            <input type="text" id="party" name="party" class="form-control" placeholder="Youth Progressive Wing" required />
                        </div>

                        <div class="form-group">
                            <label for="symbol">Ballot Symbol / Emblem</label>
                            <input type="text" id="symbol" name="symbol" class="form-control" placeholder="Rising Sun" required />
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-sm" style="margin-top: 0.5rem;">
                        <span>➕</span> Add Candidate to Ballot
                    </button>
                </form>
            </section>

            <!-- Candidates Table -->
            <section>
                <h2>Candidate Registry (<c:out value="${candidates.size()}" />)</h2>
                <div class="table-responsive" style="margin-top: 1rem;">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Party</th>
                                <th>Symbol</th>
                                <th>Election</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="c" items="${candidates}">
                                <tr>
                                    <td>#<c:out value="${c.id}" /></td>
                                    <td style="font-weight: 700;"><c:out value="${c.candidateName}" /></td>
                                    <td><c:out value="${c.party}" /></td>
                                    <td><span style="background: rgba(255,255,255,0.06); padding: 0.2rem 0.5rem; border-radius: var(--radius-sm);"><c:out value="${c.symbol}" /></span></td>
                                    <td><c:out value="${c.electionName}" /></td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${c.active}">
                                                <span class="status-badge status-active">Active</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge" style="background: var(--danger-bg); color: var(--danger);">Deactivated</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <div style="display: flex; gap: 0.5rem;">
                                            <button type="button" class="btn btn-outline btn-sm btn-edit-candidate"
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
                                                <button type="submit" class="btn btn-outline btn-sm">
                                                    ${c.active ? 'Deactivate' : 'Activate'}
                                                </button>
                                            </form>

                                            <form action="${pageContext.request.contextPath}/admin/candidates" method="POST" style="display:inline;" onsubmit="return confirm('Delete this candidate permanently?');">
                                                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                                                <input type="hidden" name="action" value="delete" />
                                                <input type="hidden" name="candidateId" value="${c.id}" />
                                                <button type="submit" class="btn btn-danger btn-sm">
                                                    Delete
                                                </button>
                                            </form>
                                        </div>
                                    </td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </div>
            </section>
        </main>
    </div>

    <!-- Edit Candidate Modal -->
    <div class="modal-overlay" id="editCandidateModal">
        <div class="modal-box">
            <h3 class="modal-title">Edit Candidate</h3>
            <form action="${pageContext.request.contextPath}/admin/candidates" method="POST">
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                <input type="hidden" name="action" value="edit" />
                <input type="hidden" name="candidateId" id="editCandidateId" />

                <div class="form-group">
                    <label for="editCandidateName">Candidate Name</label>
                    <input type="text" id="editCandidateName" name="candidateName" class="form-control" required />
                </div>

                <div class="form-group">
                    <label for="editParty">Party / Slate</label>
                    <input type="text" id="editParty" name="party" class="form-control" required />
                </div>

                <div class="form-group">
                    <label for="editSymbol">Symbol</label>
                    <input type="text" id="editSymbol" name="symbol" class="form-control" required />
                </div>

                <div class="form-group">
                    <label for="editActive">Active Status</label>
                    <select id="editActive" name="active" class="form-control">
                        <option value="true">Active</option>
                        <option value="false">Deactivated</option>
                    </select>
                </div>

                <div class="modal-actions" style="margin-top: 1.5rem;">
                    <button type="button" class="btn btn-secondary" id="cancelEditBtn">Cancel</button>
                    <button type="submit" class="btn btn-primary">Save Changes</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
