<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    if (request.getAttribute("voters") == null) {
        dao.UserDAO uDao = new dao.UserDAO();
        request.setAttribute("voters", uDao.getAllVoters());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Voters | Secure Online Voting System</title>
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
            <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link active">
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
                <h1>Voter Registry Management</h1>
                <p class="subtitle">Enroll student voters, view credentials status, and manage access</p>
            </div>

            <!-- Feedback Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">
                    <span>⚠️</span>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <c:if test="${param.success == 'voter_added'}">
                <div class="alert alert-success">
                    <span>✅</span>
                    <div>New voter account enrolled successfully!</div>
                </div>
            </c:if>

            <c:if test="${param.success == 'status_updated'}">
                <div class="alert alert-success">
                    <span>✅</span>
                    <div>Voter access status updated.</div>
                </div>
            </c:if>

            <!-- Enroll Voter Form -->
            <section class="card" style="margin-bottom: 2.5rem; background: var(--bg-surface);">
                <h3 style="margin-bottom: 1.25rem;">+ Enroll New Campus Voter</h3>
                <form action="${pageContext.request.contextPath}/admin/action" method="POST" autocomplete="off">
                    <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                    <input type="hidden" name="action" value="addVoter" />

                    <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 1rem;">
                        <div class="form-group">
                            <label for="fullName">Full Name</label>
                            <input type="text" id="fullName" name="fullName" class="form-control" placeholder="Alice Smith" required />
                        </div>

                        <div class="form-group">
                            <label for="email">Campus Email</label>
                            <input type="email" id="email" name="email" class="form-control" placeholder="alice@voting.edu" required />
                        </div>

                        <div class="form-group">
                            <label for="collegeId">College ID / Roll No.</label>
                            <input type="text" id="collegeId" name="collegeId" class="form-control" placeholder="AU-2024-CED-015" required />
                        </div>

                        <div class="form-group">
                            <label for="collegeName">College / University</label>
                            <input type="text" id="collegeName" name="collegeName" class="form-control" value="Alliance University" />
                        </div>

                        <div class="form-group">
                            <label for="programName">Degree / Program</label>
                            <input type="text" id="programName" name="programName" class="form-control" value="B.Tech Computer Science & Engineering" />
                        </div>

                        <div class="form-group">
                            <label for="joiningYear">Joining Year</label>
                            <input type="number" id="joiningYear" name="joiningYear" class="form-control" value="2024" min="2018" max="2030" />
                        </div>

                        <div class="form-group">
                            <label for="studyYear">Academic Standing</label>
                            <input type="text" id="studyYear" name="studyYear" class="form-control" value="2nd Year" />
                        </div>

                        <div class="form-group">
                            <label for="password">Initial Password</label>
                            <input type="password" id="password" name="password" class="form-control" placeholder="Password@123" required minlength="6" />
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-sm" style="margin-top: 0.5rem;">
                        <span>➕</span> Enroll Voter
                    </button>
                </form>
            </section>

            <!-- Registered Voters Table -->
            <section>
                <h2>Registered Voters List (<c:out value="${voters.size()}" />)</h2>
                <div class="table-responsive" style="margin-top: 1rem;">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Photo</th>
                                <th>ID & Name</th>
                                <th>Email</th>
                                <th>College ID</th>
                                <th>College & Program</th>
                                <th>Batch / Year</th>
                                <th>Status</th>
                                <th>Access Action</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="v" items="${voters}">
                                <tr>
                                    <td>
                                        <div style="width: 40px; height: 48px; border-radius: 4px; background: #1e1b4b; border: 1px solid #6366f1; overflow: hidden; display: flex; align-items: center; justify-content: center;">
                                            <c:choose>
                                                <c:when test="${not empty v.photoBase64}">
                                                    <img src="${v.photoBase64}" alt="Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="font-size: 1.2rem;">👤</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </div>
                                    </td>
                                    <td>
                                        <div style="font-weight: 600;"><c:out value="${v.fullName}" /></div>
                                        <small style="color: var(--text-muted);">#<c:out value="${v.id}" /></small>
                                    </td>
                                    <td><c:out value="${v.email}" /></td>
                                    <td><span style="font-family: monospace; font-size: 0.85rem; color: #818cf8; font-weight: 600;"><c:out value="${v.collegeId != null ? v.collegeId : 'N/A'}" /></span></td>
                                    <td>
                                        <div style="font-size: 0.85rem; color: #f8fafc;"><c:out value="${v.collegeName != null ? v.collegeName : 'Alliance University'}" /></div>
                                        <div style="font-size: 0.75rem; color: #94a3b8;"><c:out value="${v.programName != null ? v.programName : 'B.Tech'}" /></div>
                                    </td>
                                    <td>
                                        <div style="font-size: 0.8rem; color: #38bdf8;">Joined: <c:out value="${v.joiningYear != null ? v.joiningYear : '2024'}" /></div>
                                        <div style="font-size: 0.75rem; color: #34d399;"><c:out value="${v.studyYear != null ? v.studyYear : '2nd Year'}" /></div>
                                    </td>
                                    <td>
                                        <c:choose>
                                            <c:when test="${v.active}">
                                                <span class="status-badge status-active">Active</span>
                                            </c:when>
                                            <c:otherwise>
                                                <span class="status-badge" style="background: var(--danger-bg); color: var(--danger);">Disabled</span>
                                            </c:otherwise>
                                        </c:choose>
                                    </td>
                                    <td>
                                        <form action="${pageContext.request.contextPath}/admin/action" method="POST" style="display:inline;">
                                            <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                                            <input type="hidden" name="action" value="toggleVoterStatus" />
                                            <input type="hidden" name="voterId" value="${v.id}" />
                                            <input type="hidden" name="active" value="${!v.active}" />
                                            <c:choose>
                                                <c:when test="${v.active}">
                                                    <button type="submit" class="btn btn-outline btn-sm" style="color: #ef4444;" onclick="return confirm('Deactivate this voter? They will be unable to sign in.');">
                                                        Deactivate
                                                    </button>
                                                </c:when>
                                                <c:otherwise>
                                                    <button type="submit" class="btn btn-success btn-sm">
                                                        Re-activate
                                                    </button>
                                                </c:otherwise>
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

    <script src="${pageContext.request.contextPath}/js/validation.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
