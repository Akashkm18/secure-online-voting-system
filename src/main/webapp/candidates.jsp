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

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="container" style="padding-top: 2rem; padding-bottom: 3.5rem;">
        <div style="margin-bottom: 2rem;">
            <h1 style="font-size: 1.75rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;">Candidate Profiles</h1>
            <p style="color: var(--text-secondary); font-size: 0.95rem;">Nominated student candidates participating in official campus elections</p>
        </div>

        <c:choose>
            <c:when test="${not empty candidates}">
                <div class="grid-cards">
                    <c:forEach var="c" items="${candidates}">
                        <div class="card" id="candidateCard-${c.id}">
                            <div style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1.25rem;">
                                <div style="width: 44px; height: 44px; border-radius: 10px; background: rgba(37, 99, 235, 0.1); color: var(--primary); display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                        <circle cx="12" cy="7" r="4"/>
                                    </svg>
                                </div>
                                <div>
                                    <h3 style="font-size: 1.15rem; font-weight: 600; margin-bottom: 0.2rem;"><c:out value="${c.candidateName}" /></h3>
                                    <p style="color: var(--primary); font-weight: 500; font-size: 0.85rem;"><c:out value="${c.party}" /></p>
                                </div>
                            </div>

                            <div style="background: var(--bg-surface-elevated); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 0.85rem; margin-bottom: 1.25rem;">
                                <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-bottom: 0.2rem;">Ballot Symbol</div>
                                <div style="font-size: 1rem; font-weight: 600; color: var(--text-primary);"><c:out value="${c.symbol}" /></div>
                                <div style="font-size: 0.75rem; color: var(--text-muted); text-transform: uppercase; letter-spacing: 0.05em; margin-top: 0.75rem; margin-bottom: 0.2rem;">Contesting In</div>
                                <div style="font-size: 0.85rem; color: var(--text-secondary);"><c:out value="${c.electionName != null ? c.electionName : 'Active Election'}" /></div>
                            </div>

                            <div>
                                <c:choose>
                                    <c:when test="${c.active}">
                                        <span class="badge badge-active">Active Contender</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-completed">Deactivated</span>
                                    </c:otherwise>
                                </c:choose>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card empty-state">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--text-muted); margin-bottom: 0.75rem;">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                    <h3 style="font-size: 1.1rem; margin-bottom: 0.35rem;">No Candidates Found</h3>
                    <p style="color: var(--text-secondary); font-size: 0.875rem;">There are currently no registered candidates to display.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

</body>
</html>
