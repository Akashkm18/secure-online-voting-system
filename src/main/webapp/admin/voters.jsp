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

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <div class="admin-layout">
        <jsp:include page="/WEB-INF/fragments/admin-sidebar.jsp" />

        <main class="admin-content">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 2rem; flex-wrap: wrap; gap: 1rem;">
                <div>
                    <h1 style="font-size: 1.65rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.25rem;">Voter Registry Management</h1>
                    <p style="color: var(--text-secondary); font-size: 0.875rem; margin: 0;">Verified student voter roster with biometric ID credentials</p>
                </div>
                <div style="display: flex; gap: 0.75rem;">
                    <button type="button" class="btn btn-primary btn-sm" data-modal-open="enrollVoterModal">
                        + Enroll New Voter
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

            <c:if test="${param.success == 'voter_added'}">
                <div class="alert alert-success">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    <div>New voter account enrolled successfully.</div>
                </div>
            </c:if>

            <c:if test="${param.success == 'status_updated'}">
                <div class="alert alert-success">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    <div>Voter access status successfully updated.</div>
                </div>
            </c:if>

            <!-- Search and Filter Bar -->
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; flex-wrap: wrap; gap: 1rem;">
                <div style="display: flex; align-items: center; gap: 0.5rem; flex: 1; max-width: 380px;">
                    <input type="text" data-table-filter="votersTable" class="form-control" placeholder="Search by name, email, or Student ID..." style="font-size: 0.85rem;" />
                </div>
                <div style="font-size: 0.85rem; color: var(--text-secondary);">
                    Total Enrolled Voters: <strong style="color: var(--text-primary);"><c:out value="${voters.size()}" /></strong>
                </div>
            </div>

            <!-- Registered Voters Table -->
            <div class="table-responsive card" style="padding: 0; overflow: hidden; background: var(--bg-surface-elevated);">
                <table class="table" id="votersTable">
                    <thead>
                        <tr>
                            <th style="width: 80px;">ID Photo</th>
                            <th>Student Name</th>
                            <th>Institutional Email</th>
                            <th>Student ID / Roll No.</th>
                            <th>Academic Program</th>
                            <th>Admission</th>
                            <th>Status</th>
                            <th style="text-align: right;">Action</th>
                        </tr>
                    </thead>
                    <tbody>
                        <c:choose>
                            <c:when test="${not empty voters}">
                                <c:forEach var="v" items="${voters}">
                                    <tr>
                                        <td>
                                            <div style="width: 50px; height: 60px; border-radius: 6px; background: #000; border: 1px solid var(--border-color); overflow: hidden; display: flex; align-items: center; justify-content: center; box-shadow: var(--shadow-sm); cursor: pointer;" title="Click to view full photo">
                                                <c:choose>
                                                    <c:when test="${not empty v.photoBase64}">
                                                        <img src="${v.photoBase64}" alt="Voter Photo" style="width: 100%; height: 100%; object-fit: cover;" loading="lazy" onclick="if(this.src){window.open(this.src,'_blank');}" />
                                                    </c:when>
                                                    <c:otherwise>
                                                        <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--text-muted);">
                                                            <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                                            <circle cx="12" cy="7" r="4"/>
                                                        </svg>
                                                    </c:otherwise>
                                                </c:choose>
                                            </div>
                                        </td>
                                        <td>
                                            <div style="font-weight: 600; color: var(--text-primary);"><c:out value="${v.fullName}" /></div>
                                            <span style="font-size: 0.75rem; color: var(--text-muted); font-family: monospace;">UID: #<c:out value="${v.id}" /></span>
                                        </td>
                                        <td>
                                            <span style="font-size: 0.85rem; color: var(--text-secondary);"><c:out value="${v.email}" /></span>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty v.collegeId}">
                                                    <span class="badge badge-pending" style="font-family: monospace; font-size: 0.78rem;">
                                                        <c:out value="${v.collegeId}" />
                                                    </span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--text-muted); font-size: 0.8rem;">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <div style="font-size: 0.85rem; color: var(--text-primary);">
                                                <c:out value="${not empty v.programName ? v.programName : '—'}" />
                                            </div>
                                            <c:if test="${not empty v.collegeName}">
                                                <small style="color: var(--text-muted); display: block;"><c:out value="${v.collegeName}" /></small>
                                            </c:if>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${not empty v.joiningYear}">
                                                    <span style="font-size: 0.82rem; color: var(--text-secondary);"><c:out value="${v.joiningYear}" /></span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span style="color: var(--text-muted); font-size: 0.8rem;">—</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td>
                                            <c:choose>
                                                <c:when test="${v.active}">
                                                    <span class="badge badge-active">Active</span>
                                                </c:when>
                                                <c:otherwise>
                                                    <span class="badge badge-completed">Disabled</span>
                                                </c:otherwise>
                                            </c:choose>
                                        </td>
                                        <td style="text-align: right;">
                                            <form action="${pageContext.request.contextPath}/admin/action" method="POST" style="display:inline;" data-confirm="Are you sure you want to ${v.active ? 'deactivate' : 'activate'} voter ${v.fullName}?" data-confirm-title="Update Voter Access">
                                                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                                                <input type="hidden" name="action" value="toggleVoterStatus" />
                                                <input type="hidden" name="voterId" value="${v.id}" />
                                                <input type="hidden" name="active" value="${!v.active}" />
                                                <c:choose>
                                                    <c:when test="${v.active}">
                                                        <button type="submit" class="btn btn-secondary btn-sm" style="color: var(--danger);">
                                                            Disable
                                                        </button>
                                                    </c:when>
                                                    <c:otherwise>
                                                        <button type="submit" class="btn btn-secondary btn-sm" style="color: var(--success);">
                                                            Activate
                                                        </button>
                                                    </c:otherwise>
                                                </c:choose>
                                            </form>
                                        </td>
                                    </tr>
                                </c:forEach>
                            </c:choose>
                            <c:otherwise>
                                <tr>
                                    <td colspan="8" style="text-align: center; padding: 3rem; color: var(--text-secondary);">
                                        No registered voters found. Enroll a new voter using the button above.
                                    </td>
                                </tr>
                            </c:otherwise>
                        </c:choose>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <!-- Enroll Voter Modal -->
    <div class="modal-overlay" id="enrollVoterModal">
        <div class="modal-box" style="max-width: 560px; text-align: left;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1.25rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.15rem; color: var(--text-primary);">Enroll New Student Voter</h3>
                <button type="button" class="btn btn-secondary btn-sm" data-modal-close="enrollVoterModal">✕</button>
            </div>

            <form action="${pageContext.request.contextPath}/admin/action" method="POST" autocomplete="off">
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />
                <input type="hidden" name="action" value="addVoter" />

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; margin-bottom: 0.85rem;">
                    <div class="form-group">
                        <label for="fullName">Full Name</label>
                        <input type="text" id="fullName" name="fullName" class="form-control" placeholder="e.g. Jane Doe" required />
                    </div>

                    <div class="form-group">
                        <label for="email">Campus Email</label>
                        <input type="email" id="email" name="email" class="form-control" placeholder="student@institution.edu" required />
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; margin-bottom: 0.85rem;">
                    <div class="form-group">
                        <label for="collegeId">Student ID Card / Roll No.</label>
                        <input type="text" id="collegeId" name="collegeId" class="form-control" placeholder="e.g. STU-2026-001" required />
                    </div>

                    <div class="form-group">
                        <label for="password">Initial Password</label>
                        <input type="password" id="password" name="password" class="form-control" placeholder="Min 6 characters" required minlength="6" />
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; margin-bottom: 0.85rem;">
                    <div class="form-group">
                        <label for="collegeName">Institution / School</label>
                        <input type="text" id="collegeName" name="collegeName" class="form-control" placeholder="e.g. School of Engineering" />
                    </div>

                    <div class="form-group">
                        <label for="programName">Program / Major</label>
                        <input type="text" id="programName" name="programName" class="form-control" placeholder="e.g. Computer Science" />
                    </div>
                </div>

                <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.85rem; margin-bottom: 1.25rem;">
                    <div class="form-group">
                        <label for="joiningYear">Admission Year</label>
                        <input type="number" id="joiningYear" name="joiningYear" class="form-control" placeholder="2026" min="2000" max="2035" />
                    </div>

                    <div class="form-group">
                        <label for="studyYear">Academic Standing</label>
                        <input type="text" id="studyYear" name="studyYear" class="form-control" placeholder="e.g. 1st Year" />
                    </div>
                </div>

                <div style="display: flex; gap: 0.75rem; justify-content: flex-end; border-top: 1px solid var(--border-color); padding-top: 1rem;">
                    <button type="button" class="btn btn-secondary btn-sm" data-modal-close="enrollVoterModal">Cancel</button>
                    <button type="submit" class="btn btn-primary btn-sm">Complete Enrollment</button>
                </div>
            </form>
        </div>
    </div>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
