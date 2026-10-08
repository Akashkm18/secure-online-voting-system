<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
<%
    if (request.getAttribute("elections") == null) {
        dao.ElectionDAO eDao = new dao.ElectionDAO();
        dao.VoteDAO vDao = new dao.VoteDAO();
        java.util.List<model.Election> elections = eDao.getAllElections();
        request.setAttribute("elections", elections);

        String paramId = request.getParameter("electionId");
        Integer electionId = util.ValidationUtil.parsePositiveInt(paramId);
        if (electionId == null && !elections.isEmpty()) {
            electionId = elections.get(0).getId();
        }

        if (electionId != null) {
            request.setAttribute("selectedElection", eDao.findById(electionId));
            request.setAttribute("results", vDao.getElectionResults(electionId));
        }
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Election Results & Tallies | Secure Online Voting System</title>
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
            <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link">
                <span>🎫</span> Manage Voters
            </a>
            <a href="${pageContext.request.contextPath}/admin/results" class="sidebar-link active">
                <span>🏆</span> Live Results & Tally
            </a>
            <a href="${pageContext.request.contextPath}/admin/audit-logs" class="sidebar-link">
                <span>📜</span> Audit Security Logs
            </a>
        </aside>

        <main class="admin-content">
            <div style="margin-bottom: 2rem;">
                <h1>Official Ballot Tallies & Results</h1>
                <p class="subtitle">Aggregate candidate vote totals, percentage shares, and official result certification</p>
            </div>

            <!-- Election Selector -->
            <section class="card" style="margin-bottom: 2rem; background: var(--bg-surface); padding: 1.25rem;">
                <form action="${pageContext.request.contextPath}/admin/results" method="GET" style="display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;">
                    <label for="electionSelect" style="margin: 0; font-weight: 600;">Select Election:</label>
                    <select id="electionSelect" name="electionId" class="form-control" style="max-width: 380px;" onchange="this.form.submit()">
                        <c:forEach var="el" items="${elections}">
                            <option value="${el.id}" ${el.id == selectedElection.id ? 'selected' : ''}>
                                #${el.id} - ${el.electionName} (${el.status})
                            </option>
                        </c:forEach>
                    </select>
                    <noscript><button type="submit" class="btn btn-outline btn-sm">Load</button></noscript>
                </form>
            </section>

            <c:if test="${not empty selectedElection}">
                <!-- Selected Election Banner -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <h2><c:out value="${selectedElection.electionName}" /></h2>
                        <div style="display: flex; gap: 0.75rem; align-items: center; margin-top: 0.5rem;">
                            <span class="status-badge ${selectedElection.status == 'ACTIVE' ? 'status-active' : (selectedElection.status == 'PUBLISHED' ? 'status-published' : 'status-completed')}">
                                <c:out value="${selectedElection.status}" />
                            </span>
                            <span style="color: var(--text-muted); font-size: 0.85rem;">
                                Window: <fmt:formatDate value="${selectedElection.startTime}" pattern="yyyy-MM-dd" /> to <fmt:formatDate value="${selectedElection.endTime}" pattern="yyyy-MM-dd" />
                            </span>
                        </div>
                    </div>

                    <!-- Publish Button -->
                    <c:if test="${selectedElection.status != 'PUBLISHED'}">
                        <form action="${pageContext.request.contextPath}/results" method="POST" onsubmit="return confirm('Publish official election results to all students?');">
                            <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                            <input type="hidden" name="action" value="publish" />
                            <input type="hidden" name="electionId" value="${selectedElection.id}" />
                            <button type="submit" class="btn btn-primary" style="background: #9333ea;">
                                📢 Publish Results Publicly
                            </button>
                        </form>
                    </c:if>
                </div>

                <!-- Results Table -->
                <div class="table-responsive">
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Position</th>
                                <th>Candidate Name</th>
                                <th>Party Affiliation</th>
                                <th>Symbol</th>
                                <th>Total Votes</th>
                                <th>Vote Share (%)</th>
                                <th>Visual Distribution</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty results}">
                                    <c:forEach var="r" items="${results}" varStatus="status">
                                        <tr>
                                            <td>
                                                <c:choose>
                                                    <c:when test="${status.index == 0}">
                                                        <span style="font-weight: 800; color: #fbbf24; font-size: 1.05rem;">🥇 Winner</span>
                                                    </c:when>
                                                    <c:when test="${status.index == 1}">
                                                        <span style="font-weight: 700; color: #94a3b8;">🥈 2nd</span>
                                                    </c:when>
                                                    <c:when test="${status.index == 2}">
                                                        <span style="font-weight: 700; color: #b45309;">🥉 3rd</span>
                                                    </c:when>
                                                    <c:otherwise>
                                                        #${status.index + 1}
                                                    </c:otherwise>
                                                </c:choose>
                                            </td>
                                            <td style="font-weight: 700; font-size: 1rem;"><c:out value="${r.candidateName}" /></td>
                                            <td><c:out value="${r.party}" /></td>
                                            <td><span style="background: rgba(255,255,255,0.06); padding: 0.2rem 0.6rem; border-radius: var(--radius-sm);"><c:out value="${r.symbol}" /></span></td>
                                            <td style="font-weight: 800; font-size: 1.15rem; color: var(--text-primary);"><c:out value="${r.voteCount}" /></td>
                                            <td style="font-weight: 700; color: #38bdf8;"><c:out value="${r.votePercentage}" />%</td>
                                            <td style="min-width: 160px;">
                                                <div class="progress-bar-container">
                                                    <div class="progress-bar-fill" style="width: ${r.votePercentage}%;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" style="text-align: center; padding: 2rem; color: var(--text-secondary);">
                                            No candidates or votes recorded for this election.
                                        </td>
                                    </tr>
                                </c:otherwise>
                            </c:choose>
                        </tbody>
                    </table>
                </div>
            </c:if>
        </main>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
