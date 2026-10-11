<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Sign in to your campus voter account with College ID Card verification.">
    <title>Voter Sign In | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <!-- Tesseract.js for Optical Character Recognition (OCR) -->
    <script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
    
    <!-- ZXing for Barcode/QR Code Detection -->
    <script src="https://cdn.jsdelivr.net/npm/@zxing/library@latest/umd/index.min.js"></script>
</head>
<body>

    <!-- Shared Header Navigation Fragment -->
    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <div class="auth-wrapper">
        <div class="auth-card" id="voterLoginFormCard" style="max-width: 480px;">
            <div class="auth-header">
                <div class="auth-header-icon">
                    <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/>
                        <path d="m9 12 2 2 4-4"/>
                    </svg>
                </div>
                <h1 class="auth-title">Voter Sign In</h1>
                <p class="auth-subtitle">
                    Enter your student credentials and verify your College ID Card
                </p>
            </div>

            <!-- Error Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" id="alertError">
                    <svg class="alert-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <c:if test="${param.error == 'unauthorized'}">
                <div class="alert alert-danger" id="alertUnauthorized">
                    <svg class="alert-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div>Please sign in to access your voter portal.</div>
                </div>
            </c:if>

            <c:if test="${param.error == 'account_disabled'}">
                <div class="alert alert-danger" id="alertDisabled">
                    <svg class="alert-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div>Your account has been deactivated. Please contact an election official.</div>
                </div>
            </c:if>

            <!-- Success Notifications -->
            <c:if test="${param.success == 'registered'}">
                <div class="alert alert-success" id="alertRegistered">
                    <svg class="alert-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="20 6 9 17 4 12"/>
                    </svg>
                    <div>Registration successful! You may now sign in with your College ID card.</div>
                </div>
            </c:if>

            <c:if test="${param.info == 'logged_out'}">
                <div class="alert alert-info" id="alertLoggedOut">
                    <svg class="alert-icon" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="16" x2="12" y2="12"/>
                        <line x1="12" y1="8" x2="12.01" y2="8"/>
                    </svg>
                    <div>You have been successfully signed out.</div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/login" method="POST" id="voterLoginForm" autocomplete="off">
                <!-- CSRF Token -->
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />

                <!-- Scanned Metadata Hidden Fields -->
                <input type="hidden" name="collegeName" id="hiddenCollegeName" value="" />
                <input type="hidden" name="programName" id="hiddenProgramName" value="" />
                <input type="hidden" name="joiningYear" id="hiddenJoiningYear" value="" />
                <input type="hidden" name="studyYear" id="hiddenStudyYear" value="" />
                <input type="hidden" name="photoBase64" id="hiddenPhotoBase64" value="" />

                <div class="form-group">
                    <label for="email">Campus Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           placeholder="student@institution.edu" value="<c:out value='${param.email}' />" required />
                </div>

                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.35rem; flex-wrap: wrap; gap: 0.25rem;">
                        <label for="collegeId" style="margin: 0;">College ID / Card Number</label>
                        <button type="button" class="btn btn-outline btn-sm" id="btnOpenIdScanner" style="padding: 0.2rem 0.6rem; font-size: 0.775rem;">
                            <svg width="13" height="13" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 3px;">
                                <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                                <line x1="8" y1="21" x2="16" y2="21"/>
                                <line x1="12" y1="17" x2="12" y2="21"/>
                            </svg>
                            Scan ID Card
                        </button>
                    </div>
                    <div style="position: relative;">
                        <input type="text" id="collegeId" name="collegeId" class="form-control" 
                               placeholder="Enter or scan your official Student ID" required />
                        <span id="scanStatusBadge" style="display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); font-size: 0.75rem; background: var(--success-bg); color: var(--success); padding: 0.2rem 0.5rem; border-radius: var(--radius-sm); border: 1px solid var(--success-border);">
                            ✓ Attached
                        </span>
                    </div>
                    <span class="form-text">Enter your student ID or use the scanner to verify automatically.</span>
                </div>

                <!-- Verified Student Card Widget (Shown when card is scanned) -->
                <div id="studentCardPreviewWidget" style="display: none; margin-bottom: 1.25rem; background: rgba(37, 99, 235, 0.08); border: 1px solid rgba(59, 130, 246, 0.3); border-radius: var(--radius-md); padding: 0.85rem; text-align: left;">
                    <div style="display: flex; gap: 0.85rem; align-items: center;">
                        <div id="widgetPhotoBox" style="width: 58px; height: 68px; border-radius: 6px; background: #0b1120; border: 1px solid var(--primary-light); overflow: hidden; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                            <img id="widgetPhotoImg" src="" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover; display: none;" />
                            <span id="widgetPhotoPlaceholder" style="font-size: 1.5rem; color: var(--text-muted);">
                                <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                    <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                    <circle cx="12" cy="7" r="4"/>
                                </svg>
                            </span>
                        </div>
                        <div style="flex-grow: 1; min-width: 0;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                                <span class="badge status-active" style="font-size: 0.65rem; padding: 0.15rem 0.4rem; margin-bottom: 0.25rem;">✓ Card Verified</span>
                                <button type="button" id="btnReScanCard" style="background: none; border: none; color: var(--primary-light); font-size: 0.75rem; cursor: pointer; text-decoration: underline;">Change Card</button>
                            </div>
                            <div id="widgetCollegeName" style="font-weight: 600; font-size: 0.85rem; color: #f8fafc; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Institution Verified</div>
                            <div id="widgetProgramName" style="font-size: 0.78rem; color: var(--text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Academic Program</div>
                            <div style="font-size: 0.75rem; color: #38bdf8; margin-top: 0.15rem;">
                                Joined: <strong id="widgetJoiningYear">2024</strong> • <span id="widgetStudyYear">Active</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.35rem;">
                        <label for="password" style="margin-bottom: 0;">Password</label>
                        <a href="${pageContext.request.contextPath}/forgot-password.jsp" style="font-size: 0.78rem; color: var(--primary-light);">Forgot Password?</a>
                    </div>
                    <div class="input-password-wrapper">
                        <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required />
                        <button type="button" class="password-toggle-btn" aria-label="Toggle password visibility">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-block" id="submitLoginBtn" style="margin-top: 1.25rem;">
                    Authenticate & Access Ballot Box
                </button>
            </form>

            <div style="margin-top: 1.5rem; padding-top: 1.25rem; border-top: 1px solid var(--border-color); text-align: center; font-size: 0.85rem; color: var(--text-secondary);">
                Don't have an account yet? 
                <a href="${pageContext.request.contextPath}/register.jsp" style="font-weight: 600;" id="linkToRegister">
                    Register with Student ID
                </a>
            </div>
        </div>
    </div>

    <!-- College ID Card Verification Modal -->
    <div class="modal-overlay" id="idScannerModal">
        <div class="modal-box" style="max-width: 540px; text-align: center; max-height: 92vh; overflow-y: auto;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.15rem; display: flex; align-items: center; gap: 0.5rem;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="color: var(--primary-light);">
                        <rect x="2" y="3" width="20" height="14" rx="2" ry="2"/>
                        <line x1="8" y1="21" x2="16" y2="21"/>
                        <line x1="12" y1="17" x2="12" y2="21"/>
                    </svg>
                    Student ID Card Verification
                </h3>
                <button type="button" class="btn btn-ghost btn-sm" id="btnCloseIdScanner" aria-label="Close modal">✕</button>
            </div>

            <!-- Mode Switcher Tabs -->
            <div style="display: flex; gap: 0.5rem; justify-content: center; margin-bottom: 1.25rem; background: rgba(15, 23, 42, 0.7); padding: 0.35rem; border-radius: var(--radius-sm); border: 1px solid var(--border-color);">
                <button type="button" class="btn btn-sm btn-scanner-tab active" id="tabCameraBtn" style="flex: 1; font-size: 0.85rem;">
                    Live Camera
                </button>
                <button type="button" class="btn btn-sm btn-scanner-tab" id="tabUploadBtn" style="flex: 1; font-size: 0.85rem; background: transparent; color: var(--text-secondary); border: none;">
                    Upload Photo
                </button>
            </div>

            <!-- TAB 1: Live Camera Scanner Section -->
            <div id="sectionCameraScan" style="margin-bottom: 1rem;">
                <div id="cameraViewfinderContainer" style="position: relative; width: 100%; max-width: 480px; height: 280px; margin: 0 auto; background: #090d16; border-radius: var(--radius-sm); overflow: hidden; border: 1px solid var(--primary-light);">
                    <video id="idCameraVideo" autoplay playsinline muted style="width: 100%; height: 100%; object-fit: cover;"></video>
                    <canvas id="idCaptureCanvas" style="display: none;"></canvas>

                    <!-- Flash animation overlay on capture -->
                    <div id="cameraFlashOverlay" style="position: absolute; inset: 0; background: #fff; opacity: 0; pointer-events: none; transition: opacity 0.15s ease-out;"></div>

                    <!-- Target Card Alignment Frame -->
                    <div id="cameraCardGuide" style="position: absolute; inset: 22px; border: 2px dashed rgba(56, 189, 248, 0.8); border-radius: 6px; pointer-events: none;">
                        <!-- Laser scanline -->
                        <div id="cameraScanLine" style="position: absolute; top: 0; left: 0; right: 0; height: 2px; background: #38bdf8; box-shadow: 0 0 8px #38bdf8; animation: scanLine 2.2s infinite ease-in-out;"></div>
                    </div>

                    <!-- Alignment text badge -->
                    <div style="position: absolute; top: 10px; left: 50%; transform: translateX(-50%); background: rgba(15, 23, 42, 0.85); color: #38bdf8; font-size: 0.725rem; font-weight: 600; padding: 0.2rem 0.65rem; border-radius: 20px; border: 1px solid rgba(56, 189, 248, 0.3); pointer-events: none; white-space: nowrap;">
                        Align ID Card within the guide frame
                    </div>

                    <!-- Permission Denied / Error guidance banner -->
                    <div id="cameraPermissionBanner" style="display: none; position: absolute; inset: 0; background: rgba(15, 23, 42, 0.95); padding: 1.5rem; text-align: center; flex-direction: column; align-items: center; justify-content: center; z-index: 10;">
                        <h4 style="color: #f87171; font-size: 0.95rem; margin-bottom: 0.35rem;">Camera Access Notice</h4>
                        <p id="cameraPermissionGuidance" style="color: var(--text-secondary); font-size: 0.8rem; margin-bottom: 0.75rem; max-width: 320px; line-height: 1.4;">
                            Please allow camera permissions or switch to photo upload.
                        </p>
                        <div style="display: flex; gap: 0.5rem; justify-content: center; flex-wrap: wrap;">
                            <button type="button" class="btn btn-outline btn-sm" id="btnRetryCamera">Retry Camera</button>
                            <button type="button" class="btn btn-primary btn-sm" id="btnSwitchToUpload">Switch to Upload</button>
                        </div>
                    </div>
                </div>

                <!-- Camera Controls Toolbar -->
                <div style="display: flex; gap: 0.6rem; justify-content: center; align-items: center; margin-top: 0.85rem; flex-wrap: wrap;">
                    <button type="button" class="btn btn-primary btn-sm" id="btnCaptureIdCard">
                        <svg width="15" height="15" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                            <circle cx="12" cy="13" r="4"/>
                        </svg>
                        Capture & Scan Card
                    </button>
                    <button type="button" class="btn btn-outline btn-sm" id="btnFlipCamera" title="Switch camera">
                        <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M21.5 2v6h-6M21.34 15.57a10 10 0 1 1-.57-8.38l5.67-5.67"/>
                        </svg>
                        Flip Camera
                    </button>
                </div>
            </div>

            <!-- TAB 2: Upload Card Section -->
            <div id="sectionUploadScan" style="display: none; margin-bottom: 1rem;">
                <div id="dropZone" style="border: 2px dashed var(--border-color); border-radius: var(--radius-sm); padding: 2.25rem 1.25rem; background: rgba(15, 23, 42, 0.4); cursor: pointer; transition: border-color 0.2s ease;">
                    <div style="color: var(--primary-light); margin-bottom: 0.5rem;">
                        <svg width="36" height="36" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                            <polyline points="17 8 12 3 7 8"/>
                            <line x1="12" y1="3" x2="12" y2="15"/>
                        </svg>
                    </div>
                    <h4 style="font-size: 0.95rem; margin-bottom: 0.25rem;">Select or drop ID Card image</h4>
                    <p style="color: var(--text-muted); font-size: 0.8rem; margin-bottom: 1rem;">
                        Upload a photo of your official Student ID Card to auto-detect credentials.
                    </p>
                    <label class="btn btn-primary btn-sm" style="cursor: pointer;">
                        Browse ID Photo
                        <input type="file" id="idCardFileInput" accept="image/*" style="display: none;" />
                    </label>
                </div>
            </div>

            <!-- SCAN PROCESSING LOADER CARD -->
            <div id="scanProcessingCard" style="display: none; background: #090d16; border: 1px solid var(--primary-light); border-radius: var(--radius-sm); padding: 1.5rem; text-align: center; margin-top: 1rem;">
                <strong id="ocrStatusTitle" style="color: #38bdf8; font-size: 0.925rem; display: block; margin-bottom: 0.25rem;">Analyzing ID Card...</strong>
                <span id="ocrStatusSubtitle" style="color: var(--text-muted); font-size: 0.775rem;">Detecting card attributes and text credentials...</span>
                <div id="ocrProgressBarContainer" style="width: 100%; max-width: 240px; height: 5px; background: rgba(255,255,255,0.1); border-radius: 10px; margin: 0.75rem auto 0 auto; overflow: hidden; display: none;">
                    <div id="ocrProgressBar" style="width: 0%; height: 100%; background: var(--primary-light); transition: width 0.2s;"></div>
                </div>
            </div>

            <!-- REAL-TIME DETECTION RESULT CARD (With Editable Inputs) -->
            <div id="scanResultCard" style="display: none; background: #090d16; border: 1px solid var(--success); border-radius: var(--radius-sm); padding: 1.25rem; text-align: left; margin-top: 1rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem;">
                    <strong style="color: var(--success); font-size: 0.9rem;">Card Detected</strong>
                    <span class="badge status-active" style="font-size: 0.68rem;">Verified</span>
                </div>

                <div style="display: flex; gap: 1rem; align-items: flex-start; flex-wrap: wrap;">
                    <!-- Student Photo Preview -->
                    <div style="text-align: center;">
                        <div id="detectedPhotoFrame" style="width: 80px; height: 96px; border-radius: 4px; background: #0f172a; border: 1px solid var(--border-color); overflow: hidden; display: flex; align-items: center; justify-content: center; margin-bottom: 0.25rem;">
                            <img id="detectedPhotoImg" src="" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </div>
                        <span style="font-size: 0.68rem; color: var(--text-muted); display: block;">Photo</span>
                    </div>

                    <!-- Extracted & Editable Metadata Attributes -->
                    <div style="flex: 1; min-width: 220px; font-size: 0.85rem; display: flex; flex-direction: column; gap: 0.4rem;">
                        <div>
                            <label style="color: var(--text-muted); font-size: 0.7rem; display: block; margin-bottom: 0.1rem;">COLLEGE ID / ROLL NUMBER</label>
                            <input type="text" id="detCollegeIdInput" class="form-control" style="font-family: monospace; font-size: 0.9rem; font-weight: 600; color: #38bdf8; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.7rem; display: block; margin-bottom: 0.1rem;">STUDENT NAME</label>
                            <input type="text" id="detStudentNameInput" class="form-control" style="font-size: 0.85rem; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.7rem; display: block; margin-bottom: 0.1rem;">COLLEGE / INSTITUTION</label>
                            <input type="text" id="detCollegeNameInput" class="form-control" style="font-size: 0.8rem; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.7rem; display: block; margin-bottom: 0.1rem;">DEGREE / PROGRAM</label>
                            <input type="text" id="detProgramNameInput" class="form-control" style="font-size: 0.8rem; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem;">
                            <div>
                                <label style="color: var(--text-muted); font-size: 0.7rem; display: block; margin-bottom: 0.1rem;">JOINED YEAR</label>
                                <input type="text" id="detJoiningYearInput" class="form-control" style="font-size: 0.8rem; padding: 0.35rem 0.6rem;" />
                            </div>
                            <div>
                                <label style="color: var(--text-muted); font-size: 0.7rem; display: block; margin-bottom: 0.1rem;">ACADEMIC STANDING</label>
                                <input type="text" id="detStudyYearInput" class="form-control" style="font-size: 0.8rem; padding: 0.35rem 0.6rem;" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Confirmation Action Buttons -->
                <div style="display: flex; gap: 0.5rem; margin-top: 1rem; border-top: 1px solid var(--border-color); padding-top: 0.75rem;">
                    <button type="button" class="btn btn-success btn-sm btn-block" id="btnApplyDetectedId">
                        ✓ Apply to Sign In Form
                    </button>
                    <button type="button" class="btn btn-outline btn-sm" id="btnCancelDetectedId">
                        Scan Again
                    </button>
                </div>
            </div>
        </div>
    </div>

    <style>
        @keyframes scanLine {
            0% { top: 0; opacity: 0.8; }
            50% { top: calc(100% - 2px); opacity: 1; }
            100% { top: 0; opacity: 0.8; }
        }
        .btn-scanner-tab.active {
            background: var(--primary) !important;
            color: #ffffff !important;
        }
    </style>

    <!-- Shared Footer Fragment -->
    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/validation.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
