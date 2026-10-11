<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<header class="app-header">
    <div class="nav-container">
        <a href="${pageContext.request.contextPath}/index.jsp" class="brand-link" id="mainBrandLink">
            <span class="brand-logo-icon">
                <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                    <path d="m9 12 2 2 4-4"/>
                </svg>
            </span>
            <span class="brand-title">Secure Online Voting</span>
        </a>

        <button type="button" class="mobile-nav-toggle" id="mobileNavToggle" aria-label="Toggle navigation menu">
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="4" y1="12" x2="20" y2="12"></line>
                <line x1="4" y1="6" x2="20" y2="6"></line>
                <line x1="4" y1="18" x2="20" y2="18"></line>
            </svg>
        </button>

        <nav class="nav-links" id="primaryNav">
            <c:choose>
                <%-- Logged-in Administrator --%>
                <c:when test="${not empty sessionScope.user and sessionScope.user.admin}">
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item ${activeNav == 'dashboard' or pageContext.request.requestURI.contains('/admin/dashboard') ? 'active' : ''}">Dashboard</a>
                    <a href="${pageContext.request.contextPath}/admin/elections" class="nav-item ${activeNav == 'elections' or pageContext.request.requestURI.contains('/admin/elections') ? 'active' : ''}">Elections</a>
                    <a href="${pageContext.request.contextPath}/admin/candidates" class="nav-item ${activeNav == 'candidates' or pageContext.request.requestURI.contains('/admin/candidates') ? 'active' : ''}">Candidates</a>
                    <a href="${pageContext.request.contextPath}/admin/voters" class="nav-item ${activeNav == 'voters' or pageContext.request.requestURI.contains('/admin/voters') ? 'active' : ''}">Voters</a>
                    <a href="${pageContext.request.contextPath}/admin/results" class="nav-item ${activeNav == 'results' or pageContext.request.requestURI.contains('/admin/results') ? 'active' : ''}">Results</a>
                    <a href="${pageContext.request.contextPath}/admin/audit-logs" class="nav-item ${activeNav == 'audit-logs' or pageContext.request.requestURI.contains('/admin/audit-logs') ? 'active' : ''}">Audit Logs</a>
                    <div class="nav-user-actions">
                        <span class="badge badge-admin">Admin</span>
                        <span class="nav-user-name"><c:out value="${sessionScope.user.fullName}" /></span>
                        <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline; margin:0;">
                            <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}">
                            <button type="submit" class="btn btn-secondary btn-sm" id="navLogoutBtn" title="Sign Out">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px;">
                                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                                    <polyline points="16 17 21 12 16 7"/>
                                    <line x1="21" y1="12" x2="9" y2="12"/>
                                </svg>
                                Logout
                            </button>
                        </form>
                    </div>
                </c:when>

                <%-- Logged-in Voter --%>
                <c:when test="${not empty sessionScope.user and not sessionScope.user.admin}">
                    <a href="${pageContext.request.contextPath}/dashboard.jsp" class="nav-item ${pageContext.request.requestURI.endsWith('/dashboard.jsp') ? 'active' : ''}">Dashboard</a>
                    <a href="${pageContext.request.contextPath}/elections" class="nav-item ${pageContext.request.requestURI.endsWith('/elections') or pageContext.request.requestURI.endsWith('/elections.jsp') ? 'active' : ''}">Elections</a>
                    <a href="${pageContext.request.contextPath}/candidates" class="nav-item ${pageContext.request.requestURI.endsWith('/candidates') or pageContext.request.requestURI.endsWith('/candidates.jsp') ? 'active' : ''}">Candidates</a>
                    <a href="${pageContext.request.contextPath}/results" class="nav-item ${pageContext.request.requestURI.endsWith('/results') or pageContext.request.requestURI.endsWith('/results.jsp') ? 'active' : ''}">Results</a>
                    <a href="${pageContext.request.contextPath}/my-status.jsp" class="nav-item ${pageContext.request.requestURI.endsWith('/my-status.jsp') ? 'active' : ''}">My Receipts</a>
                    <div class="nav-user-actions">
                        <c:choose>
                            <c:when test="${not empty sessionScope.user.photoBase64}">
                                <img src="${sessionScope.user.photoBase64}" alt="Voter" class="nav-user-avatar" />
                            </c:when>
                            <c:otherwise>
                                <span class="nav-user-avatar-placeholder">
                                    <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                        <circle cx="12" cy="7" r="4"/>
                                    </svg>
                                </span>
                            </c:otherwise>
                        </c:choose>
                        <span class="nav-user-name"><c:out value="${sessionScope.user.fullName}" /></span>
                        <form action="${pageContext.request.contextPath}/logout" method="post" style="display:inline; margin:0;">
                            <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}">
                            <button type="submit" class="btn btn-secondary btn-sm" id="navVoterLogoutBtn" title="Sign Out">
                                <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="margin-right: 4px;">
                                    <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
                                    <polyline points="16 17 21 12 16 7"/>
                                    <line x1="21" y1="12" x2="9" y2="12"/>
                                </svg>
                                Logout
                            </button>
                        </form>
                    </div>
                </c:when>

                <%-- Public (Not Logged In) --%>
                <c:otherwise>
                    <a href="${pageContext.request.contextPath}/index.jsp" class="nav-item ${pageContext.request.requestURI.endsWith('/index.jsp') or pageContext.request.requestURI.endsWith('/') ? 'active' : ''}">Home</a>
                    <a href="${pageContext.request.contextPath}/elections" class="nav-item ${pageContext.request.requestURI.contains('/elections') ? 'active' : ''}">Elections</a>
                    <a href="${pageContext.request.contextPath}/candidates" class="nav-item ${pageContext.request.requestURI.contains('/candidates') ? 'active' : ''}">Candidates</a>
                    <a href="${pageContext.request.contextPath}/results" class="nav-item ${pageContext.request.requestURI.contains('/results') ? 'active' : ''}">Results</a>
                    <a href="${pageContext.request.contextPath}/login.jsp" class="nav-item ${not pageContext.request.requestURI.contains('/admin') and (pageContext.request.requestURI.endsWith('/login.jsp') or pageContext.request.requestURI.endsWith('/login')) ? 'active' : ''}" id="navSignInBtn">Sign In</a>
                    <a href="${pageContext.request.contextPath}/register.jsp" class="nav-item ${pageContext.request.requestURI.endsWith('/register.jsp') or pageContext.request.requestURI.endsWith('/register') ? 'active' : ''}" id="navRegisterBtn">Register</a>
                    <a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-item ${pageContext.request.requestURI.contains('/admin') ? 'active' : ''}" id="navAdminPortalBtn" style="font-size: 0.82rem; color: var(--text-muted); opacity: 0.85;" title="Official Administrator Access">Admin</a>
                </c:otherwise>
            </c:choose>
        </nav>
    </div>
</header>
