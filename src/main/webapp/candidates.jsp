<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Ensure candidates list is loaded if visited directly
    if (request.getAttribute("candidates") == null) {
        dao.CandidateDAO candidateDao = new dao.CandidateDAO();
        request.setAttribute("candidates", candidateDao.getAllCandidates());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="View candidates running in student council and campus elections.">
    <title>Candidate Profiles | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <nav class="navbar" id="candidatesNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/index.jsp" class="nav-link">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/elections" class="nav-link">Elections</a></li>
            <li><a href="${pageContext.request.contextPath}/candidates" class="nav-link active">Candidates</a></li>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <c:choose>
                        <c:when test="${sessionScope.user.admin}">
                            <li><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link">Admin Dashboard</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/dashboard.jsp" class="nav-link">My Dashboard</a></li>
                        </c:otherwise>
                    </c:choose>
                    <li><a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm">Logout</a></li>
                </c:when>
                <c:otherwise>
                    <li><a href="${pageContext.request.contextPath}/login.jsp" class="nav-link">Sign In</a></li>
                    <li><a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-primary btn-sm">Register</a></li>
                </c:otherwise>
            </c:choose>
        </ul>
    </nav>

    <div class="container">
        <div style="margin-bottom: 2rem;">
            <h1>Candidate Profiles</h1>
            <p class="subtitle">Nominated student candidates participating in active and upcoming elections</p>
        </div>

        <c:choose>
            <c:when test="${not empty candidates}">
                <div class="grid-cards">
                    <c:forEach var="c" items="${candidates}">
                        <div class="card" id="candidateCard-${c.id}">
                            <div style="display: flex; gap: 1.25rem; align-items: center; margin-bottom: 1.25rem;">
                                <div class="symbol-badge">
                                    <span>🏛️</span>
                                </div>
                                <div>
                                    <h3 style="font-size: 1.25rem; margin-bottom: 0.25rem;"><c:out value="${c.candidateName}" /></h3>
                                    <p style="color: #818cf8; font-weight: 600; font-size: 0.9rem;"><c:out value="${c.party}" /></p>
                                </div>
                            </div>

                            <div style="background: rgba(255, 255, 255, 0.03); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 1rem; margin-bottom: 1.25rem;">
                                <div style="font-size: 0.85rem; color: var(--text-muted); margin-bottom: 0.35rem;">Assigned Symbol</div>
                                <div style="font-size: 1.1rem; font-weight: 700; color: var(--text-primary);"><c:out value="${c.symbol}" /></div>
                                <div style="font-size: 0.85rem; color: var(--text-muted); margin-top: 0.75rem;">Contesting In</div>
                                <div style="font-size: 0.9rem; color: var(--text-secondary);"><c:out value="${c.electionName != null ? c.electionName : 'Active Election'}" /></div>
                            </div>

                            <div>
                                <c:choose>
                                    <c:when test="${c.active}">
                                        <span class="status-badge status-active">Active Contender</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="status-badge" style="background: #334155; color: #94a3b8;">Deactivated</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card" style="text-align: center; padding: 3rem;">
                    <div style="font-size: 2.5rem; margin-bottom: 1rem;">👥</div>
                    <h3>No Candidates Found</h3>
                    <p style="color: var(--text-secondary);">There are currently no registered candidates to display.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </div>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
