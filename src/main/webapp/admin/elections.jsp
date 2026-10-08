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
            <a href="${pageContext.request.contextPath}/admin/elections" class="sidebar-link active">
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
        </aside>

        <main class="admin-content">
            <div style="margin-bottom: 2rem;">
                <h1>Election Lifecycle Control</h1>
                <p class="subtitle">Launch student ballots, schedule voting windows, and control live status</p>
            </div>

            <!-- Feedback Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">
                    <span>⚠️</span>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <c:if test="${param.success == 'created'}">
                <div class="alert alert-success">
                    <span>✅</span>
                    <div>New election created successfully!</div>
                </div>
            </c:if>

            <!-- Create Election Form -->
            <section class="card" style="margin-bottom: 2.5rem; background: var(--bg-surface);">
                <h3 style="margin-bottom: 1.25rem;">+ Create New Campus Election</h3>
                <form action="${pageContext.request.contextPath}/admin/elections" method="POST" autocomplete="off">
                    <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                    <input type="hidden" name="action" value="create" />

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1rem;">
                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label for="electionName">Election Title</label>
                            <input type="text" id="electionName" name="electionName" class="form-control" 
                                   placeholder="Annual Student Council Executive Election" required minlength="3" maxlength="150" />
                        </div>

                        <div class="form-group" style="grid-column: 1 / -1;">
                            <label for="description">Description / Purpose</label>
                            <textarea id="description" name="description" class="form-control" 
                                      placeholder="Election to elect the President, Vice President, and Secretary..." rows="2"></textarea>
                        </div>

                        <div class="form-group">
                            <label for="startTime">Voting Window Starts</label>
                            <input type="datetime-local" id="startTime" name="startTime" class="form-control" required />
                        </div>

                        <div class="form-group">
                            <label for="endTime">Voting Window Closes</label>
                            <input type="datetime-local" id="endTime" name="endTime" class="form-control" required />
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-sm" style="margin-top: 0.5rem;">
                        <span>➕</span> Create Election
                    </button>
                </form>
            </section>

            <!-- Elections Table -->
            <section>
                <h2>All Elections (<c:out value="${elections.size()}" />)</h2>
                <div class="table-responsive" style="margin-top: 1rem;">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Title</th>
                                <th>Window</th>
                                <th>Ballots</th>
                                <th>Status</th>
                                <th>Lifecycle Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="el" items="${elections}">
                                <tr>
                                    <td>#<c:out value="${el.id}" /></td>
                                    <td>
                                        <div style="font-weight: 700;"><c:out value="${el.electionName}" /></div>
                                        <div style="font-size: 0.8rem; color: var(--text-muted);"><c:out value="${el.description}" /></div>
                                    </td>
                                    <td style="font-size: 0.85rem; color: var(--text-secondary); line-height: 1.5;">
                                        <div>From: <fmt:formatDate value="${el.startTime}" pattern="yyyy-MM-dd HH:mm" /></div>
                                        <div>To: <fmt:formatDate value="${el.endTime}" pattern="yyyy-MM-dd HH:mm" /></div>
                                    </td>
                                    <td style="font-weight: 700; font-size: 1.1rem;"><c:out value="${el.totalVotes}" /></td>
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
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/elections" method="POST" style="display:inline;">
                                            <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                                            <input type="hidden" name="action" value="updateStatus" />
                                            <input type="hidden" name="electionId" value="${el.id}" />

                                            <c:choose>
                                                <c:when test="${el.status == 'UPCOMING'}">
                                                    <input type="hidden" name="status" value="ACTIVE" />
                                                    <button type="submit" class="btn btn-success btn-sm">▶ Start Voting</button>
                                                </c:when>
                                                <c:when test="${el.status == 'ACTIVE'}">
                                                    <input type="hidden" name="status" value="COMPLETED" />
                                                    <button type="submit" class="btn btn-outline btn-sm" style="color: #ef4444;">⏹ Stop Voting</button>
                                                </c:when>
                                                <c:when test="${el.status == 'COMPLETED'}">
                                                    <input type="hidden" name="status" value="PUBLISHED" />
                                                    <button type="submit" class="btn btn-primary btn-sm" style="background: #9333ea;">📢 Publish Results</button>
                                                </c:when>
                                                <c:when test="${el.status == 'PUBLISHED'}">
                                                    <a href="${pageContext.request.contextPath}/admin/results?electionId=${el.id}" class="btn btn-outline btn-sm">
                                                        View Published Tally
                                                    </a>
                                                </c:when>
                                            </c:choose>
                                        </form>
                                    </td>
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
