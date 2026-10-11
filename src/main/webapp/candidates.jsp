<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    // Ensure candidates list is loaded if visited directly without servlet
    if (request.getAttribute("candidates") == null) {
        dao.CandidateDAO candidateDao = new dao.CandidateDAO();
        dao.ElectionDAO electionDao = new dao.ElectionDAO();
        request.setAttribute("candidates", candidateDao.getAllCandidates());
        request.setAttribute("allElections", electionDao.getAllElections());
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="View candidates running in student council and campus elections with campaign bios and manifestos.">
    <title>Candidate Profiles | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="container" style="padding-top: 2rem; padding-bottom: 3.5rem;">
        <div style="margin-bottom: 2rem; display: flex; justify-content: space-between; align-items: flex-start; flex-wrap: wrap; gap: 1rem;">
            <div>
                <h1 style="font-size: 1.75rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;">Nominated Candidates</h1>
                <p style="color: var(--text-secondary); font-size: 0.95rem;">Official student contenders, campaign platforms, and manifestos</p>
            </div>

            <!-- Filter by Election (GET, CSP compliant, no inline scripts) -->
            <form action="${pageContext.request.contextPath}/candidates" method="get" style="display: flex; gap: 0.5rem; align-items: center; background: var(--bg-surface-elevated); padding: 0.5rem 0.75rem; border-radius: var(--radius-md); border: 1px solid var(--border-color);">
                <label for="filterElection" style="font-size: 0.82rem; font-weight: 600; color: var(--text-muted); white-space: nowrap;">Filter:</label>
                <select name="electionId" id="filterElection" class="form-control" style="font-size: 0.85rem; padding: 0.4rem 0.6rem; min-width: 200px;">
                    <option value="">All Elections</option>
                    <c:forEach var="el" items="${allElections}">
                        <option value="${el.id}" ${selectedElection != null and selectedElection.id == el.id ? 'selected' : ''}>
                            <c:out value="${el.electionName}"/>
                        </option>
                    </c:forEach>
                </select>
                <button type="submit" class="btn btn-secondary btn-sm" id="btnFilterCandidates">Filter</button>
            </form>
        </div>

        <c:choose>
            <c:when test="${not empty candidates}">
                <div class="grid-cards" style="grid-template-columns: repeat(auto-fill, minmax(320px, 1fr));">
                    <c:forEach var="c" items="${candidates}">
                        <div class="card" id="candidateCard-${c.id}" style="display: flex; flex-direction: column; justify-content: space-between; padding: 1.5rem;">
                            <div>
                                <!-- Candidate Header: Round Photo + Name + Position -->
                                <div style="display: flex; gap: 1rem; align-items: center; margin-bottom: 1.25rem;">
                                    <div style="width: 64px; height: 64px; border-radius: 50%; overflow: hidden; background: var(--bg-surface-elevated); border: 2px solid var(--border-color); flex-shrink: 0; box-shadow: 0 4px 10px rgba(0,0,0,0.2);">
                                        <img src="${pageContext.request.contextPath}/candidate-photo?id=${c.id}" alt="${c.candidateName}" style="width: 100%; height: 100%; object-fit: cover; display: block;" loading="lazy">
                                    </div>
                                    <div style="flex: 1; min-width: 0;">
                                        <h3 style="font-size: 1.15rem; font-weight: 700; margin-bottom: 0.2rem; color: var(--text-primary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                            <c:out value="${c.candidateName}" />
                                        </h3>
                                        <div style="color: var(--primary); font-weight: 600; font-size: 0.85rem; margin-bottom: 0.2rem;">
                                            <c:out value="${c.position != null ? c.position : 'Candidate'}" />
                                        </div>
                                        <div style="color: var(--text-secondary); font-size: 0.82rem;">
                                            <c:out value="${c.party}" />
                                        </div>
                                    </div>
                                </div>

                                <!-- Metadata Pill Box -->
                                <div style="background: var(--bg-surface-elevated); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 0.75rem 0.85rem; margin-bottom: 1.25rem; font-size: 0.82rem;">
                                    <div style="display: flex; justify-content: space-between; margin-bottom: 0.4rem;">
                                        <span style="color: var(--text-muted);">Ballot Symbol:</span>
                                        <span class="badge badge-pending" style="font-size: 0.78rem;"><c:out value="${c.symbol}" /></span>
                                    </div>
                                    <div style="display: flex; justify-content: space-between;">
                                        <span style="color: var(--text-muted);">Election:</span>
                                        <span style="color: var(--text-primary); font-weight: 500; text-align: right; max-width: 180px; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">
                                            <c:out value="${c.electionName != null ? c.electionName : 'Campus Election'}" />
                                        </span>
                                    </div>
                                </div>

                                <!-- Campaign Bio Preview -->
                                <div style="margin-bottom: 1.25rem;">
                                    <div style="font-size: 0.75rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); margin-bottom: 0.35rem; font-weight: 600;">
                                        Candidate Statement
                                    </div>
                                    <p style="font-size: 0.875rem; color: var(--text-secondary); line-height: 1.5; margin: 0; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden;">
                                        <c:choose>
                                            <c:when test="${not empty c.bio}">
                                                <c:out value="${c.bio}" />
                                            </c:when>
                                            <c:otherwise>
                                                Committed to institutional student representation, academic excellence, and student community empowerment.
                                            </c:otherwise>
                                        </c:choose>
                                    </p>
                                </div>
                            </div>

                            <!-- Action Button to Open View Details Modal -->
                            <div style="border-top: 1px solid var(--border-color); padding-top: 1rem; display: flex; justify-content: space-between; align-items: center;">
                                <c:choose>
                                    <c:when test="${c.active}">
                                        <span class="badge badge-active">Active Contender</span>
                                    </c:when>
                                    <c:otherwise>
                                        <span class="badge badge-completed">Deactivated</span>
                                    </c:otherwise>
                                </c:choose>

                                <button type="button" class="btn btn-secondary btn-sm" data-candidate-modal="candModal_${c.id}">
                                    View Platform
                                </button>
                            </div>
                        </div>

                        <!-- Candidate Platform & Manifesto Modal Dialog -->
                        <div class="modal-overlay" id="candModal_${c.id}">
                            <div class="modal-box" style="max-width: 580px;">
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 1.25rem;">
                                    <div style="display: flex; gap: 1rem; align-items: center;">
                                        <div style="width: 72px; height: 72px; border-radius: 50%; overflow: hidden; background: var(--bg-surface); border: 2px solid var(--border-color); flex-shrink: 0;">
                                            <img src="${pageContext.request.contextPath}/candidate-photo?id=${c.id}" alt="${c.candidateName}" style="width: 100%; height: 100%; object-fit: cover; display: block;">
                                        </div>
                                        <div>
                                            <h3 style="font-size: 1.3rem; font-weight: 700; color: var(--text-primary); margin: 0 0 0.2rem 0;">
                                                <c:out value="${c.candidateName}" />
                                            </h3>
                                            <div style="color: var(--primary); font-weight: 600; font-size: 0.9rem;">
                                                <c:out value="${c.position != null ? c.position : 'Candidate'}" />
                                            </div>
                                            <div style="color: var(--text-secondary); font-size: 0.85rem;">
                                                <c:out value="${c.party}" /> • Symbol: <strong><c:out value="${c.symbol}" /></strong>
                                            </div>
                                        </div>
                                    </div>
                                    <button type="button" class="btn btn-secondary btn-sm" data-modal-close aria-label="Close dialog">✕</button>
                                </div>

                                <div style="margin-bottom: 1.25rem;">
                                    <h4 style="font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); margin-bottom: 0.4rem;">
                                        Biography & Background
                                    </h4>
                                    <div style="background: var(--bg-surface-elevated); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 0.85rem; font-size: 0.9rem; color: var(--text-secondary); line-height: 1.6;">
                                        <c:choose>
                                            <c:when test="${not empty c.bio}">
                                                <c:out value="${c.bio}" />
                                            </c:when>
                                            <c:otherwise>
                                                No biography submitted by this candidate.
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <div style="margin-bottom: 1.5rem;">
                                    <h4 style="font-size: 0.85rem; text-transform: uppercase; letter-spacing: 0.05em; color: var(--text-muted); margin-bottom: 0.4rem;">
                                        Campaign Manifesto & Key Pledges
                                    </h4>
                                    <div style="background: var(--bg-surface-elevated); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 0.85rem; font-size: 0.9rem; color: var(--text-primary); line-height: 1.6; white-space: pre-wrap;">
                                        <c:choose>
                                            <c:when test="${not empty c.manifesto}">
                                                <c:out value="${c.manifesto}" />
                                            </c:when>
                                            <c:otherwise>
                                                No formal manifesto uploaded. Candidate pledges support for student body welfare and institutional excellence.
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </div>

                                <div style="display: flex; justify-content: flex-end; gap: 0.75rem;">
                                    <button type="button" class="btn btn-secondary btn-sm" data-modal-close>Close</button>
                                    <a href="${pageContext.request.contextPath}/voting?electionId=${c.electionId}" class="btn btn-primary btn-sm">
                                        Vote in this Election
                                    </a>
                                </div>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </c:when>
            <c:otherwise>
                <div class="card empty-state" style="padding: 3rem 1.5rem; text-align: center;">
                    <svg width="48" height="48" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--text-muted); margin-bottom: 1rem;">
                        <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
                        <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
                    </svg>
                    <h3 style="font-size: 1.2rem; font-weight: 700; margin-bottom: 0.5rem; color: var(--text-primary);">No Candidates Found</h3>
                    <p style="color: var(--text-secondary); font-size: 0.9rem; max-width: 450px; margin: 0 auto 1.5rem auto;">
                        There are currently no registered candidates matching your criteria.
                    </p>
                    <a href="${pageContext.request.contextPath}/elections" class="btn btn-secondary btn-sm">Browse Campus Elections</a>
                </div>
            </c:otherwise>
        </c:choose>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/voter.js"></script>
</body>
</html>
