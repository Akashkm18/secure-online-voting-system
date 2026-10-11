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
    <title>Official Results & Tallies | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/fragments/admin-sidebar.jsp" />

        <main class="admin-content">
            <div style="margin-bottom: 2rem;">
                <h1 style="font-size: 1.65rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">Official Ballot Tallies & Results</h1>
                <p style="color: var(--text-secondary); font-size: 0.875rem; margin: 0;">Aggregate candidate vote totals, percentage shares, and official result certification</p>
            </div>

            <!-- Election Selector -->
            <section class="card" style="margin-bottom: 2rem; background: var(--bg-surface-elevated); padding: 1.25rem;">
                <form action="${pageContext.request.contextPath}/admin/results" method="GET" style="display: flex; gap: 1rem; align-items: center; flex-wrap: wrap;">
                    <label for="electionSelect" style="margin: 0; font-weight: 600; font-size: 0.9rem;">Target Election:</label>
                    <select id="electionSelect" name="electionId" class="form-control" style="max-width: 400px;">
                        <c:forEach var="el" items="${elections}">
                            <option value="${el.id}" ${el.id == selectedElection.id ? 'selected' : ''}>
                                #${el.id} - ${el.electionName} (${el.status})
                            </option>
                        </c:forEach>
                    </select>
                    <button type="submit" class="btn btn-secondary btn-sm">Load Tally</button>
                </form>
            </section>

            <c:if test="${not empty selectedElection}">
                <!-- Selected Election Banner -->
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.5rem; flex-wrap: wrap; gap: 1rem;">
                    <div>
                        <h2 style="font-size: 1.35rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;"><c:out value="${selectedElection.electionName}" /></h2>
                        <div style="display: flex; gap: 0.75rem; align-items: center;">
                            <span class="badge ${selectedElection.status == 'ACTIVE' ? 'badge-active' : (selectedElection.status == 'PUBLISHED' ? 'badge-published' : 'badge-completed')}">
                                <c:out value="${selectedElection.status}" />
                            </span>
                            <span style="color: var(--text-muted); font-size: 0.82rem;">
                                Window: <fmt:formatDate value="${selectedElection.startTime}" pattern="yyyy-MM-dd" /> to <fmt:formatDate value="${selectedElection.endTime}" pattern="yyyy-MM-dd" />
                            </span>
                        </div>
                    </div>

                    <!-- Publish Button -->
                    <c:if test="${selectedElection.status != 'PUBLISHED'}">
                        <form action="${pageContext.request.contextPath}/results" method="POST" data-confirm="Publish official election results to all students and voters?" data-confirm-title="Confirm Results Publication">
                            <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                            <input type="hidden" name="action" value="publish" />
                            <input type="hidden" name="electionId" value="${selectedElection.id}" />
                            <button type="submit" class="btn btn-primary btn-sm">
                                Publish Certified Results
                            </button>
                        </form>
                    </c:if>
                </div>

                <!-- Results Table with CSS-only Progress Bars -->
                <div class="table-responsive card" style="padding: 0; overflow: hidden; background: var(--bg-surface-elevated);">
                    <table class="table">
                        <thead>
                            <tr>
                                <th style="width: 80px;">Rank</th>
                                <th>Candidate</th>
                                <th>Party / Slate</th>
                                <th>Emblem</th>
                                <th>Total Votes</th>
                                <th>Share (%)</th>
                                <th style="min-width: 160px;">Tally Percentage Bar</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:choose>
                                <c:when test="${not empty results}">
                                    <c:forEach var="r" items="${results}" varStatus="status">
                                        <tr>
                                            <td style="font-weight: 600; color: var(--text-primary);">
                                                #${status.index + 1}
                                            </td>
                                            <td style="font-weight: 600; font-size: 0.95rem; color: var(--text-primary);"><c:out value="${r.candidateName}" /></td>
                                            <td><c:out value="${r.party}" /></td>
                                            <td><span class="badge badge-pending"><c:out value="${r.symbol}" /></span></td>
                                            <td style="font-weight: 700; font-size: 1.05rem;"><c:out value="${r.voteCount}" /></td>
                                            <td style="font-weight: 700; color: var(--primary);"><c:out value="${r.votePercentage}" />%</td>
                                            <td>
                                                <div class="progress-bar-container">
                                                    <div class="progress-bar-fill" style="width: ${r.votePercentage}%;"></div>
                                                </div>
                                            </td>
                                        </tr>
                                    </c:forEach>
                                </c:when>
                                <c:otherwise>
                                    <tr>
                                        <td colspan="7" style="text-align: center; padding: 2.5rem; color: var(--text-secondary);">
                                            No candidates or ballots recorded for this election.
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
