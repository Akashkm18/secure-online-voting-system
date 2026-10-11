<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Reset your voting account password using your verified student credentials.">
    <title>Reset Password | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    <script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="auth-wrapper" style="min-height: calc(100vh - 160px);">
        <div class="auth-card" id="forgotPasswordCard" style="max-width: 480px;">
            <div style="text-align: center; margin-bottom: 1.75rem;">
                <div style="width: 48px; height: 48px; margin: 0 auto 1rem auto; border-radius: 12px; background: rgba(37, 99, 235, 0.12); display: flex; align-items: center; justify-content: center; color: var(--primary);">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                        <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                        <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                    </svg>
                </div>
                <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;">Reset Password</h1>
                <p style="color: var(--text-secondary); font-size: 0.875rem;">
                    Enter your registered email and student ID to update your password
                </p>
            </div>

            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/forgot-password" method="POST" id="forgotPasswordForm">
                <input type="hidden" id="csrfToken" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}">
                
                <div class="form-group">
                    <label for="email">Campus Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           placeholder="student@institution.edu" required />
                </div>

                <div class="form-group">
                    <label>Verify with Student ID Card (Optional OCR)</label>
                    <div id="dropZone" style="border: 2px dashed var(--border-color); border-radius: var(--radius-md); padding: 1.5rem 1rem; background: var(--bg-surface-elevated); cursor: pointer; text-align: center; transition: border-color 0.2s; margin-bottom: 0.5rem;">
                        <svg width="32" height="32" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--primary); margin-bottom: 0.5rem;">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                            <polyline points="17 8 12 3 7 8"/>
                            <line x1="12" y1="3" x2="12" y2="15"/>
                        </svg>
                        <h4 style="font-size: 0.95rem; margin-bottom: 0.2rem; color: var(--text-primary);">Drop ID Card photo here</h4>
                        <p style="color: var(--text-secondary); font-size: 0.78rem; margin-bottom: 0.75rem;">Supports JPG, PNG student ID cards</p>
                        <label class="btn btn-secondary btn-sm" style="cursor: pointer; display: inline-flex;">
                            <span>Browse ID Card File</span>
                            <input type="file" id="idCardFileInput" accept="image/*" style="display: none;" />
                        </label>
                    </div>
                    <div id="ocrStatusMsg" style="display: none; font-size: 0.82rem; padding: 0.5rem; text-align: center; border-radius: var(--radius-sm);"></div>
                </div>

                <div class="form-group">
                    <label for="collegeId">Student ID Card / Roll Number</label>
                    <input type="text" id="collegeId" name="collegeId" class="form-control" 
                           placeholder="Enter your student ID number" required />
                </div>

                <div id="passwordFields" style="display: none;">
                    <div class="form-group" style="margin-top: 1.25rem;">
                        <label for="newPassword">New Password (min 6 characters)</label>
                        <div class="input-password-wrapper">
                            <input type="password" id="newPassword" name="newPassword" class="form-control" 
                                   placeholder="••••••••" minlength="6" />
                            <button type="button" class="password-toggle-btn" aria-label="Toggle password visibility">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/>
                                    <circle cx="12" cy="12" r="3"/>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <div class="form-group">
                        <label for="confirmPassword">Confirm New Password</label>
                        <div class="input-password-wrapper">
                            <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                                   placeholder="••••••••" minlength="6" />
                            <button type="button" class="password-toggle-btn" aria-label="Toggle password visibility">
                                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                    <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/>
                                    <circle cx="12" cy="12" r="3"/>
                                </svg>
                            </button>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-primary btn-block" style="margin-top: 1.25rem;">
                        Reset Password
                    </button>
                </div>
            </form>

            <div style="margin-top: 1.75rem; padding-top: 1.25rem; border-top: 1px solid var(--border-color); text-align: center; font-size: 0.875rem; color: var(--text-secondary);">
                Remembered your credentials? 
                <a href="${pageContext.request.contextPath}/login.jsp" style="color: var(--primary); font-weight: 600; text-decoration: none;">
                    Back to Sign In
                </a>
            </div>
        </div>
    </main>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
    <script src="${pageContext.request.contextPath}/js/forgot-password.js"></script>
</body>
</html>
