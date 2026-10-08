<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Sign in to your campus voter account with College ID Card verification.">
    <title>Voter Sign In & ID Scan | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <!-- Tesseract.js for Optical Character Recognition (OCR) -->
    <script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
</head>
<body>

    <nav class="navbar" id="loginNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand" id="brandLink">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/index.jsp" class="nav-link">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/register.jsp" class="nav-link">Register</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/login.jsp" class="nav-link" style="color: #fbbf24;">Admin Portal</a></li>
        </ul>
    </nav>

    <div class="auth-wrapper">
        <div class="auth-card" id="voterLoginFormCard" style="max-width: 480px;">
            <div style="text-align: center; margin-bottom: 2rem;">
                <div class="brand-icon" style="margin: 0 auto 1rem auto; width: 48px; height: 48px; font-size: 1.5rem;">🪪</div>
                <h2>Student Voter Sign In</h2>
                <p style="color: var(--text-secondary); font-size: 0.9rem;">
                    Enter your credentials and scan your official College ID Card
                </p>
            </div>

            <!-- Error Notifications -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" id="alertError">
                    <span>⚠️</span>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <c:if test="${param.error == 'unauthorized'}">
                <div class="alert alert-danger" id="alertUnauthorized">
                    <span>🔒</span>
                    <div>Please sign in to access that page.</div>
                </div>
            </c:if>

            <c:if test="${param.error == 'account_disabled'}">
                <div class="alert alert-danger" id="alertDisabled">
                    <span>⛔</span>
                    <div>Your account has been deactivated. Please contact an administrator.</div>
                </div>
            </c:if>

            <!-- Success Notifications -->
            <c:if test="${param.success == 'registered'}">
                <div class="alert alert-success" id="alertRegistered">
                    <span>✅</span>
                    <div>Registration successful! You may now sign in with your College ID card.</div>
                </div>
            </c:if>

            <c:if test="${param.info == 'logged_out'}">
                <div class="alert alert-info" id="alertLoggedOut">
                    <span>ℹ️</span>
                    <div>You have been successfully logged out.</div>
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
                           placeholder="student@voting.edu" value="<c:out value='${param.email}' />" required />
                </div>

                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; flex-wrap: wrap; gap: 0.25rem;">
                        <label for="collegeId" style="margin: 0;">College ID Card Number</label>
                        <div style="display: flex; gap: 0.4rem; align-items: center;">
                            <button type="button" class="btn btn-sm" id="btnQuickFillAkash" style="background: rgba(16, 185, 129, 0.2); color: #34d399; border: 1px solid rgba(16, 185, 129, 0.45); padding: 0.22rem 0.65rem; font-size: 0.78rem; font-weight: 600; border-radius: var(--radius-sm); cursor: pointer; display: flex; align-items: center; gap: 0.3rem;">
                                <span>⚡</span> Instant Scan (Akash K M)
                            </button>
                            <button type="button" class="btn btn-outline btn-sm" id="btnOpenIdScanner" style="padding: 0.22rem 0.65rem; font-size: 0.78rem; color: #818cf8; border-color: rgba(99, 102, 241, 0.4); display: flex; align-items: center; gap: 0.3rem;">
                                <span>🪪</span> Live Scanner
                            </button>
                        </div>
                    </div>
                    <div style="position: relative;">
                        <input type="text" id="collegeId" name="collegeId" class="form-control" 
                               placeholder="e.g. ALU-2026-1001 or AU-2024-CED-014" required />
                        <span id="scanStatusBadge" style="display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); font-size: 0.75rem; background: var(--success-bg); color: var(--success); padding: 0.2rem 0.5rem; border-radius: var(--radius-sm); border: 1px solid rgba(16, 185, 129, 0.3);">
                            ✓ Scanned
                        </span>
                    </div>
                    <small style="color: var(--text-muted); font-size: 0.78rem; display: block; margin-top: 0.35rem;">
                        Click <strong>Instant Scan (Akash K M)</strong> or <strong>Live Scanner</strong> to detect college, program, batch year, and student photo.
                    </small>
                </div>

                <!-- Verified Student Card Widget (Shown when card is scanned) -->
                <div id="studentCardPreviewWidget" style="display: none; margin-bottom: 1.25rem; background: linear-gradient(135deg, rgba(79, 70, 229, 0.12), rgba(16, 185, 129, 0.08)); border: 1px solid rgba(99, 102, 241, 0.3); border-radius: var(--radius-md); padding: 0.85rem; text-align: left;">
                    <div style="display: flex; gap: 0.85rem; align-items: center;">
                        <div id="widgetPhotoBox" style="width: 58px; height: 68px; border-radius: 6px; background: #1e1b4b; border: 2px solid #6366f1; overflow: hidden; display: flex; align-items: center; justify-content: center; flex-shrink: 0;">
                            <img id="widgetPhotoImg" src="" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover; display: none;" />
                            <span id="widgetPhotoPlaceholder" style="font-size: 1.8rem;">👤</span>
                        </div>
                        <div style="flex-grow: 1; min-width: 0;">
                            <div style="display: flex; justify-content: space-between; align-items: flex-start;">
                                <span class="status-badge status-active" style="font-size: 0.65rem; padding: 0.15rem 0.4rem; margin-bottom: 0.25rem;">✓ Card Verified</span>
                                <button type="button" id="btnReScanCard" style="background: none; border: none; color: #818cf8; font-size: 0.75rem; cursor: pointer; text-decoration: underline;">Change Card</button>
                            </div>
                            <div id="widgetCollegeName" style="font-weight: 600; font-size: 0.85rem; color: #f8fafc; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">Alliance University</div>
                            <div id="widgetProgramName" style="font-size: 0.78rem; color: #94a3b8; white-space: nowrap; overflow: hidden; text-overflow: ellipsis;">B.Tech Computer Science</div>
                            <div style="font-size: 0.75rem; color: #38bdf8; margin-top: 0.15rem;">
                                Joined: <strong id="widgetJoiningYear">2024</strong> • <span id="widgetStudyYear">2nd Year</span>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.35rem;">
                        <label for="password" style="margin-bottom: 0;">Password</label>
                        <a href="${pageContext.request.contextPath}/forgot-password" style="font-size: 0.75rem; color: #818cf8; text-decoration: none;">Forgot Password?</a>
                    </div>
                    <input type="password" id="password" name="password" class="form-control" placeholder="••••••••" required />
                </div>

                <button type="submit" class="btn btn-primary btn-block" id="submitLoginBtn" style="margin-top: 1.5rem;">
                    <span>🛡️</span> Authenticate & Enter Ballot Box
                </button>
            </form>

            <div style="margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid var(--border-color); text-align: center; font-size: 0.875rem; color: var(--text-secondary);">
                Don't have an account yet? 
                <a href="${pageContext.request.contextPath}/register.jsp" style="color: var(--primary-light); font-weight: 600; text-decoration: none;" id="linkToRegister">
                    Register with College ID
                </a>
                <div style="margin-top: 0.75rem;">
                    Are you an election official? 
                    <a href="${pageContext.request.contextPath}/admin/login.jsp" style="color: #fbbf24; text-decoration: none;" id="linkToAdminLogin">
                        Admin Login Portal →
                    </a>
                </div>
            </div>
        </div>
    </div>

    <!-- College ID Card Live Scanner & Intelligent Detector Modal -->
    <div class="modal-overlay" id="idScannerModal">
        <div class="modal-box" style="max-width: 600px; text-align: center; max-height: 90vh; overflow-y: auto;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.25rem; display: flex; align-items: center; gap: 0.5rem;">
                    <span>🪪</span> College ID Scanner & Student Detector
                </h3>
                <button type="button" class="btn btn-outline btn-sm" id="btnCloseIdScanner">✕</button>
            </div>

            <!-- Scanner Modes Switch Tabs -->
            <div style="display: flex; gap: 0.5rem; margin-bottom: 1rem; justify-content: center; background: rgba(255,255,255,0.04); padding: 0.35rem; border-radius: var(--radius-sm);">
                <button type="button" class="btn btn-sm btn-scanner-tab active" id="tabCameraScan" style="flex: 1; font-size: 0.8rem;">
                    📹 Live Camera
                </button>
                <button type="button" class="btn btn-sm btn-outline btn-scanner-tab" id="tabUploadScan" style="flex: 1; font-size: 0.8rem;">
                    📁 Upload Card Photo
                </button>
            </div>

            <!-- TAB 1: Live Camera Viewport -->
            <div id="sectionCameraScan">
                <div id="scannerViewport" style="position: relative; width: 100%; height: 260px; background: #000; border-radius: var(--radius-md); overflow: hidden; margin-bottom: 1rem; border: 2px dashed #4f46e5; display: flex; align-items: center; justify-content: center;">
                    <video id="idCameraVideo" autoplay playsinline muted style="width: 100%; height: 100%; object-fit: cover; display: none;"></video>
                    <canvas id="idCaptureCanvas" style="display: none;"></canvas>
                    
                    <!-- Simulated / Virtual Scanner Card View -->
                    <div id="virtualCardDisplay" style="display: none; position: absolute; inset: 0; background: linear-gradient(135deg, #090d16, #1e1b4b); padding: 1rem; flex-direction: column; align-items: center; justify-content: center; z-index: 5;">
                        <div style="background: rgba(15, 23, 42, 0.95); border: 2px solid #38bdf8; border-radius: 8px; width: 92%; max-width: 320px; padding: 0.75rem; text-align: left; box-shadow: 0 4px 20px rgba(56, 189, 248, 0.25);">
                            <div style="display: flex; justify-content: space-between; align-items: center; border-bottom: 1px solid rgba(255,255,255,0.1); padding-bottom: 0.35rem; margin-bottom: 0.5rem;">
                                <span style="font-size: 0.7rem; font-weight: 700; color: #f8fafc; letter-spacing: 0.5px;">ALLIANCE UNIVERSITY</span>
                                <span style="font-size: 0.65rem; background: #0284c7; color: white; padding: 0.1rem 0.35rem; border-radius: 3px;">STUDENT ID</span>
                            </div>
                            <div style="display: flex; gap: 0.6rem; align-items: center;">
                                <div style="width: 48px; height: 58px; background: #1e293b; border-radius: 4px; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; border: 1px solid #64748b;">
                                    👨‍🎓
                                </div>
                                <div style="font-size: 0.75rem; line-height: 1.3;">
                                    <div style="font-weight: 700; color: #f1f5f9;">Akash K M</div>
                                    <div style="color: #38bdf8; font-weight: 600;">ID: AU-2024-CED-014</div>
                                    <div style="color: #94a3b8; font-size: 0.68rem;">B.Tech CSE • Batch 2024-2028</div>
                                </div>
                            </div>
                        </div>
                        <div style="margin-top: 0.6rem; font-size: 0.78rem; color: #38bdf8; font-weight: 600; display: flex; align-items: center; gap: 0.4rem;">
                            <span>⚡ Live Virtual Scanner Active — Processing Card...</span>
                        </div>
                    </div>

                    <!-- Scanning laser frame -->
                    <div id="scannerOverlay" style="position: absolute; inset: 20px; border: 2px solid #6366f1; border-radius: var(--radius-sm); pointer-events: none; box-shadow: 0 0 15px rgba(99, 102, 241, 0.4);">
                        <div style="position: absolute; top: 0; left: 0; right: 0; height: 3px; background: #38bdf8; box-shadow: 0 0 10px #38bdf8; animation: scanLine 2s infinite ease-in-out;"></div>
                    </div>

                    <div id="cameraStandbyMsg" style="color: var(--text-muted); font-size: 0.9rem; padding: 1.5rem; text-align: center;">
                        <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">🪪</div>
                        <div>Align student ID card in front of your camera</div>
                        <small style="color: #94a3b8; display: block; margin-top: 0.35rem;">Click "Start Camera" or "Virtual Scanner" below</small>
                    </div>

                    <!-- Permission Denied / Fallback Guidance Banner -->
                    <div id="cameraPermissionBanner" style="display: none; position: absolute; inset: 0; background: rgba(15, 23, 42, 0.96); padding: 1.25rem; text-align: center; flex-direction: column; align-items: center; justify-content: center; z-index: 10;">
                        <div style="font-size: 2rem; margin-bottom: 0.35rem;">👆</div>
                        <h4 style="color: #f87171; margin-bottom: 0.4rem; font-size: 1rem;">Allow Camera in Edge Address Bar</h4>
                        <p style="color: #cbd5e1; font-size: 0.8rem; margin-bottom: 0.5rem; max-width: 400px; line-height: 1.4;">
                            Look at your top address bar: click the <strong style="background: rgba(255,255,255,0.18); padding: 2px 7px; border-radius: 4px; color: #38bdf8;">ⓘ</strong> icon next to <strong>localhost:8080</strong>, change <strong>Camera</strong> to <strong>Allow</strong>, then click the white <strong>Refresh</strong> button!
                        </p>
                        <div id="cameraErrorDetails" style="display: none; font-family: monospace; font-size: 0.75rem; color: #fca5a5; background: rgba(0,0,0,0.4); padding: 2px 8px; border-radius: 4px; margin-bottom: 0.75rem;"></div>
                        <div style="display: flex; gap: 0.5rem; flex-wrap: wrap; justify-content: center;">
                            <button type="button" class="btn btn-outline btn-sm" id="btnRetryCamera" style="border-color: #38bdf8; color: #38bdf8; font-weight: 600;">🔄 Retry Camera</button>
                            <button type="button" class="btn btn-success btn-sm" id="btnBannerQuickScan" style="background: #10b981; border-color: #10b981; font-weight: 600;">⚡ Scan Virtual Card</button>
                            <button type="button" class="btn btn-primary btn-sm" id="btnSwitchToUpload">📁 Upload Card File</button>
                        </div>
                    </div>
                </div>

                <div style="display: flex; gap: 0.75rem; justify-content: center; margin-bottom: 1rem; flex-wrap: wrap;">
                    <button type="button" class="btn btn-primary btn-sm" id="btnStartCamera">
                        <span>📹</span> Start Camera
                    </button>
                    <button type="button" class="btn btn-success btn-sm" id="btnCaptureIdCard" style="display: none;">
                        <span>📸</span> Capture & Detect Details
                    </button>
                </div>
            </div>

            <!-- TAB 2: Upload Card Section -->
            <div id="sectionUploadScan" style="display: none; margin-bottom: 1rem;">
                <div id="dropZone" style="border: 2px dashed #6366f1; border-radius: var(--radius-md); padding: 2rem 1rem; background: rgba(99, 102, 241, 0.05); cursor: pointer; transition: background 0.2s;">
                    <div style="font-size: 2.5rem; margin-bottom: 0.5rem;">📤</div>
                    <h4 style="font-size: 1rem; margin-bottom: 0.25rem;">Drop your Student ID Card image here</h4>
                    <p style="color: var(--text-secondary); font-size: 0.8rem; margin-bottom: 1rem;">Supports JPG, PNG, WebP college cards</p>
                    <label class="btn btn-primary btn-sm" style="cursor: pointer; display: inline-flex;">
                        <span>📁</span> Browse ID Card File
                        <input type="file" id="idCardFileInput" accept="image/*" style="display: none;" />
                    </label>
                </div>


            </div>



            <!-- REAL-TIME DETECTION RESULT CARD (Shown after scan/upload/demo selection) -->
            <div id="scanResultCard" style="display: none; background: #0f172a; border: 2px solid #10b981; border-radius: var(--radius-md); padding: 1.25rem; text-align: left; margin-top: 1rem; box-shadow: 0 0 20px rgba(16, 185, 129, 0.2);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.85rem; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 0.5rem;">
                    <div style="display: flex; align-items: center; gap: 0.4rem;">
                        <span style="font-size: 1.2rem;">✨</span>
                        <strong style="color: #10b981; font-size: 0.95rem;">Card Detected Successfully!</strong>
                    </div>
                    <span class="status-badge status-active" style="font-size: 0.7rem;">OCR Verified</span>
                </div>

                <div style="display: flex; gap: 1rem; align-items: flex-start; flex-wrap: wrap;">
                    <!-- Cropped Student Photo Preview -->
                    <div style="text-align: center;">
                        <div id="detectedPhotoFrame" style="width: 82px; height: 96px; border-radius: 6px; background: #1e293b; border: 2px solid #38bdf8; overflow: hidden; display: flex; align-items: center; justify-content: center; margin-bottom: 0.35rem; box-shadow: 0 4px 10px rgba(0,0,0,0.5);">
                            <img id="detectedPhotoImg" src="" alt="Cropped Student Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </div>
                        <span style="font-size: 0.68rem; color: #38bdf8; display: block; font-weight: 600;">Student Photo</span>
                    </div>

                    <!-- Extracted Metadata Attributes -->
                    <div style="flex: 1; min-width: 220px; font-size: 0.85rem;">
                        <div style="margin-bottom: 0.35rem;">
                            <span style="color: var(--text-muted); font-size: 0.72rem; display: block;">🏛️ COLLEGE / UNIVERSITY</span>
                            <strong id="detCollegeName" style="color: #f8fafc;">Alliance University - CED</strong>
                        </div>

                        <div style="margin-bottom: 0.35rem;">
                            <span style="color: var(--text-muted); font-size: 0.72rem; display: block;">🎓 DEGREE / PROGRAM</span>
                            <span id="detProgramName" style="color: #cbd5e1; font-weight: 500;">B.Tech Computer Science & Engineering</span>
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; margin-bottom: 0.35rem;">
                            <div>
                                <span style="color: var(--text-muted); font-size: 0.72rem; display: block;">📅 JOINED YEAR</span>
                                <strong id="detJoiningYear" style="color: #38bdf8;">2024</strong>
                            </div>
                            <div>
                                <span style="color: var(--text-muted); font-size: 0.72rem; display: block;">⏳ ACADEMIC STANDING</span>
                                <strong id="detStudyYear" style="color: #34d399;">2nd Year</strong>
                            </div>
                        </div>

                        <div>
                            <span style="color: var(--text-muted); font-size: 0.72rem; display: block;">🪪 VERIFIED COLLEGE ID</span>
                            <span id="detCollegeId" style="font-family: monospace; font-size: 0.95rem; color: #a5b4fc; font-weight: 700;">AU-2024-CED-014</span>
                        </div>
                    </div>
                </div>

                <!-- Confirmation Action Buttons -->
                <div style="display: flex; gap: 0.75rem; margin-top: 1rem; border-top: 1px solid rgba(255,255,255,0.08); padding-top: 0.75rem;">
                    <button type="button" class="btn btn-success btn-sm btn-block" id="btnApplyDetectedId" style="font-size: 0.85rem;">
                        <span>✓</span> Apply Scanned Card to Sign In
                    </button>
                    <button type="button" class="btn btn-outline btn-sm" id="btnCancelDetectedId" style="width: auto;">
                        Scan Again
                    </button>
                </div>
            </div>

            <!-- SCAN PROCESSING LOADER CARD (Shows while optical analyzer runs) -->
            <div id="scanProcessingCard" style="display: none; background: #0f172a; border: 1px solid #38bdf8; border-radius: var(--radius-md); padding: 1.25rem; text-align: center; margin-top: 1rem;">
                <div class="spinner" style="width: 26px; height: 26px; border: 3px solid rgba(56, 189, 248, 0.2); border-top-color: #38bdf8; border-radius: 50%; margin: 0 auto 0.5rem; animation: spin 0.8s linear infinite;"></div>
                <strong style="color: #38bdf8; font-size: 0.88rem; display: block;">Analyzing Document Structure...</strong>
                <span style="color: #94a3b8; font-size: 0.75rem;">Validating institutional banner, student photo frame & text lines</span>
            </div>

            <!-- SCAN REJECTION ERROR CARD (Shown when uploaded photo is NOT an ID card, e.g. car, selfie, scenery) -->
            <div id="scanErrorCard" style="display: none; background: #1a0f14; border: 2px solid #ef4444; border-radius: var(--radius-md); padding: 1.25rem; text-align: left; margin-top: 1rem; box-shadow: 0 0 20px rgba(239, 68, 68, 0.25);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.75rem; border-bottom: 1px solid rgba(239,68,68,0.25); padding-bottom: 0.5rem;">
                    <div style="display: flex; align-items: center; gap: 0.4rem;">
                        <span style="font-size: 1.3rem;">🚫</span>
                        <strong style="color: #f87171; font-size: 0.95rem;">Invalid Document: Not a College ID Card</strong>
                    </div>
                    <span class="status-badge" style="background: rgba(239, 68, 68, 0.2); color: #f87171; border: 1px solid #ef4444; font-size: 0.68rem;">Rejected</span>
                </div>

                <div style="display: flex; gap: 0.85rem; align-items: center; margin-bottom: 0.75rem;">
                    <div style="width: 58px; height: 68px; border-radius: 6px; background: #261620; border: 2px dashed #f87171; display: flex; align-items: center; justify-content: center; font-size: 1.6rem; flex-shrink: 0;">
                        📸
                    </div>
                    <div style="font-size: 0.825rem; color: #cbd5e1; line-height: 1.45;">
                        <div id="scanErrorReason" style="color: #fca5a5; font-weight: 600; margin-bottom: 0.25rem;">
                            The uploaded image does not contain an official student ID card.
                        </div>
                        <div style="color: #94a3b8; font-size: 0.76rem;">
                            Photos of cars, scenery, or personal snapshots are rejected. Only official institutional ID cards are accepted for voting security.
                        </div>
                    </div>
                </div>

                <div style="background: rgba(255,255,255,0.03); border: 1px solid rgba(255,255,255,0.08); border-radius: 6px; padding: 0.5rem 0.75rem; font-size: 0.75rem; color: #94a3b8; margin-bottom: 0.85rem;">
                    <strong style="color: #f1f5f9; display: block; margin-bottom: 0.2rem;">📋 Required Card Elements:</strong>
                    • Institutional header (e.g., Alliance University / CED)<br>
                    • Student passport photograph in designated frame<br>
                    • Official student enrollment / ID number
                </div>

                <div style="display: flex; gap: 0.5rem; justify-content: flex-end; flex-wrap: wrap;">
                    <button type="button" class="btn btn-outline btn-sm" id="btnErrorTryUpload" style="font-size: 0.8rem;">
                        📁 Try Another File
                    </button>

                </div>
            </div>
        </div>
    </div>

    <style>
        @keyframes scanLine {
            0% { top: 0; opacity: 0.8; }
            50% { top: calc(100% - 3px); opacity: 1; }
            100% { top: 0; opacity: 0.8; }
        }
        .btn-scanner-tab.active {
            background: #4f46e5 !important;
            color: #fff !important;
            border-color: #4f46e5 !important;
        }
        .demo-id-card-btn:hover {
            transform: translateY(-2px);
            border-color: #818cf8 !important;
        }
    </style>

    <footer class="footer">
        <p>© 2026 Secure Online Voting System — College Micro Project</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/validation.js?v=<%= System.currentTimeMillis() %>"></script>
</body>
</html>
