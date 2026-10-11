<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%
    String currentAdminUri = request.getRequestURI();
%>
<aside class="admin-sidebar" id="adminSidebar">
    <div class="sidebar-title">Management</div>
    <a href="${pageContext.request.contextPath}/admin/dashboard.jsp" class="sidebar-link <%= currentAdminUri.endsWith("dashboard.jsp") || currentAdminUri.endsWith("/dashboard") ? "active" : "" %>">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="3" width="7" height="7"/>
            <rect x="14" y="3" width="7" height="7"/>
            <rect x="14" y="14" width="7" height="7"/>
            <rect x="3" y="14" width="7" height="7"/>
        </svg>
        <span>Dashboard</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/elections" class="sidebar-link <%= currentAdminUri.contains("elections") ? "active" : "" %>">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
            <polyline points="14 2 14 8 20 8"/>
            <line x1="16" y1="13" x2="8" y2="13"/>
            <line x1="16" y1="17" x2="8" y2="17"/>
            <polyline points="10 9 9 9 8 9"/>
        </svg>
        <span>Elections</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/candidates" class="sidebar-link <%= currentAdminUri.contains("candidates") ? "active" : "" %>">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M17 21v-2a4 4 0 0 0-4-4H5a4 4 0 0 0-4 4v2"/>
            <circle cx="9" cy="7" r="4"/>
            <path d="M23 21v-2a4 4 0 0 0-3-3.87"/>
            <path d="M16 3.13a4 4 0 0 1 0 7.75"/>
        </svg>
        <span>Candidates</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/voters" class="sidebar-link <%= currentAdminUri.contains("voters") ? "active" : "" %>">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <rect x="3" y="4" width="18" height="16" rx="2"/>
            <circle cx="9" cy="10" r="2"/>
            <line x1="15" y1="8" x2="17" y2="8"/>
            <line x1="15" y1="12" x2="17" y2="12"/>
            <line x1="7" y1="16" x2="17" y2="16"/>
        </svg>
        <span>Voters Registry</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/results" class="sidebar-link <%= currentAdminUri.contains("results") ? "active" : "" %>">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <line x1="18" y1="20" x2="18" y2="10"/>
            <line x1="12" y1="20" x2="12" y2="4"/>
            <line x1="6" y1="20" x2="6" y2="14"/>
        </svg>
        <span>Results & Tally</span>
    </a>
    <a href="${pageContext.request.contextPath}/admin/audit-logs" class="sidebar-link <%= currentAdminUri.contains("audit-logs") ? "active" : "" %>">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
        </svg>
        <span>Security Audit Logs</span>
    </a>

    <div class="sidebar-title" style="margin-top: 1.5rem;">Shortcuts</div>
    <a href="${pageContext.request.contextPath}/index.jsp" class="sidebar-link" target="_blank" rel="noopener">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <circle cx="12" cy="12" r="10"/>
            <line x1="2" y1="12" x2="22" y2="12"/>
            <path d="M12 2a15.3 15.3 0 0 1 4 10 15.3 15.3 0 0 1-4 10 15.3 15.3 0 0 1-4-10 15.3 15.3 0 0 1 4-10z"/>
        </svg>
        <span>Public Portal ↗</span>
    </a>
    <a href="${pageContext.request.contextPath}/logout" class="sidebar-link" style="color: var(--danger);">
        <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/>
            <polyline points="16 17 21 12 16 7"/>
            <line x1="21" y1="12" x2="9" y2="12"/>
        </svg>
        <span>Sign Out</span>
    </a>
</aside>

<!-- Global Styled Confirmation Modal for Admin Actions -->
<div class="modal-overlay" id="appConfirmModal">
    <div class="modal-box" style="max-width: 440px;">
        <h3 class="modal-title" id="appConfirmTitle" style="color: var(--text-primary); font-size: 1.15rem; margin-top: 0;">Confirm Action</h3>
        <div class="modal-body" style="padding: 1rem 0; font-size: 0.9rem; color: var(--text-secondary); line-height: 1.5;">
            <p id="appConfirmMsg" style="margin: 0;">Are you sure you wish to execute this action?</p>
        </div>
        <div class="modal-actions" style="display: flex; gap: 0.75rem; justify-content: flex-end;">
            <button type="button" class="btn btn-secondary btn-sm" id="appConfirmCancelBtn">Cancel</button>
            <button type="button" class="btn btn-danger btn-sm" id="appConfirmSubmitBtn">Confirm</button>
        </div>
    </div>
</div>
