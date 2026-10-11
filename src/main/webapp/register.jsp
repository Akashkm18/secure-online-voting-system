<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Register as an authorized campus voter to participate in student elections.">
    <title>Voter Registration | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <!-- Tesseract.js for Optical Character Recognition (OCR) -->
    <script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
    
    <!-- ZXing for Barcode/QR Code Detection -->
    <script src="https://cdn.jsdelivr.net/npm/@zxing/library@latest/umd/index.min.js"></script>
</head>
<body>

    <nav class="navbar" id="registerNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand" id="brandLink">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <ul class="nav-menu">
            <li><a href="${pageContext.request.contextPath}/index.jsp" class="nav-link">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/login.jsp" class="nav-link">Sign In</a></li>
            <li><a href="${pageContext.request.contextPath}/admin/login.jsp" class="nav-link" style="color: #fbbf24;">Admin Portal</a></li>
        </ul>
    </nav>

    <div class="auth-wrapper">
        <div class="auth-card" id="voterRegisterCard">
            <div style="text-align: center; margin-bottom: 2rem;">
                <div class="brand-icon" style="margin: 0 auto 1rem auto; width: 48px; height: 48px; font-size: 1.5rem;">📝</div>
                <h2>Voter Registration</h2>
                <p style="color: var(--text-secondary); font-size: 0.9rem;">Create your secure voting account</p>
            </div>

            <!-- Error Notification -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" id="alertRegisterError">
                    <span>⚠️</span>
                    <div><c:out value="${errorMessage}" /></div>
                </div>
            </c:if>

            <form action="${pageContext.request.contextPath}/register" method="POST" id="registerForm" autocomplete="off">
                <!-- CSRF Token -->
                <input type="hidden" name="_csrf" value="${csrfToken != null ? csrfToken : sessionScope._csrf_token}" />

                <!-- Scanned Metadata Hidden Fields -->
                <input type="hidden" name="collegeName" id="hiddenCollegeName" value="" />
                <input type="hidden" name="programName" id="hiddenProgramName" value="" />
                <input type="hidden" name="joiningYear" id="hiddenJoiningYear" value="" />
                <input type="hidden" name="studyYear" id="hiddenStudyYear" value="" />
                <input type="hidden" name="photoBase64" id="hiddenPhotoBase64" value="" />

                <div class="form-group">
                    <label for="fullName">Full Name</label>
                    <input type="text" id="fullName" name="fullName" class="form-control" 
                           placeholder="John Doe" value="<c:out value='${fullName}' />" required minlength="2" maxlength="100" />
                </div>

                <div class="form-group">
                    <label for="email">Campus Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           placeholder="student@voting.edu" value="<c:out value='${email}' />" required maxlength="150" />
                </div>

                <div class="form-group">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; flex-wrap: wrap; gap: 0.25rem;">
                        <label for="collegeId" style="margin: 0;">College ID Card Number / Roll No.</label>
                        <div>
                            <button type="button" class="btn btn-outline btn-sm" id="btnOpenIdScanner" style="padding: 0.22rem 0.65rem; font-size: 0.78rem; color: #818cf8; border-color: rgba(99, 102, 241, 0.4); display: flex; align-items: center; gap: 0.35rem; cursor: pointer;">
                                <span>📁</span> Upload ID Card
                            </button>
                        </div>
                    </div>
                    <div style="position: relative;">
                        <input type="text" id="collegeId" name="collegeId" class="form-control" 
                               placeholder="e.g. ALU-2026-1001 or AU-2024-CED-014" value="<c:out value='${collegeId}' />" required minlength="3" maxlength="50" />
                        <span id="scanStatusBadge" style="display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); font-size: 0.75rem; background: var(--success-bg); color: var(--success); padding: 0.2rem 0.5rem; border-radius: var(--radius-sm); border: 1px solid rgba(16, 185, 129, 0.3);">
                            ✓ Attached
                        </span>
                    </div>
                    <small style="color: var(--text-muted); font-size: 0.78rem; display: block; margin-top: 0.35rem;">
                        Upload your official Student ID Card image or enter your ID number.
                    </small>
                </div>

                <!-- Verified Student Card Widget -->
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
                    <label for="password">Create Password (min 6 characters)</label>
                    <input type="password" id="password" name="password" class="form-control" 
                           placeholder="••••••••" required minlength="6" />
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                           placeholder="••••••••" required minlength="6" />
                </div>

                <button type="submit" class="btn btn-primary btn-block" id="submitRegisterBtn" style="margin-top: 1.5rem;">
                    Complete Registration
                </button>
            </form>

            <div style="margin-top: 2rem; padding-top: 1.5rem; border-top: 1px solid var(--border-color); text-align: center; font-size: 0.875rem; color: var(--text-secondary);">
                Already registered? 
                <a href="${pageContext.request.contextPath}/login.jsp" style="color: var(--primary-light); font-weight: 600; text-decoration: none;" id="linkToLogin">
                    Sign In Here
                </a>
            </div>
        </div>
    </div>

    <!-- College ID Card Verification Modal -->
    <div class="modal-overlay" id="idScannerModal">
        <div class="modal-box" style="max-width: 540px; text-align: center; max-height: 92vh; overflow-y: auto;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.25rem; display: flex; align-items: center; gap: 0.5rem;">
                    <span>🪪</span> Student ID Card Scanner
                </h3>
                <button type="button" class="btn btn-outline btn-sm" id="btnCloseIdScanner">✕</button>
            </div>

            <!-- Mode Switcher Tabs -->
            <div style="display: flex; gap: 0.5rem; justify-content: center; margin-bottom: 1.25rem; background: rgba(15, 23, 42, 0.6); padding: 0.35rem; border-radius: var(--radius-md); border: 1px solid var(--border-color);">
                <button type="button" class="btn btn-sm btn-scanner-tab active" id="tabCameraBtn" style="flex: 1; border-radius: var(--radius-sm); font-size: 0.85rem; font-weight: 600; padding: 0.5rem;">
                    <span>📹</span> Live Camera Scanner
                </button>
                <button type="button" class="btn btn-sm btn-scanner-tab" id="tabUploadBtn" style="flex: 1; border-radius: var(--radius-sm); font-size: 0.85rem; font-weight: 600; padding: 0.5rem; background: transparent; color: var(--text-secondary); border: none;">
                    <span>📁</span> Upload ID Photo
                </button>
            </div>

            <!-- TAB 1: Live Camera Scanner Section -->
            <div id="sectionCameraScan" style="margin-bottom: 1rem;">
                <div id="cameraViewfinderContainer" style="position: relative; width: 100%; max-width: 480px; height: 280px; margin: 0 auto; background: #090d16; border-radius: var(--radius-md); overflow: hidden; border: 2px solid #6366f1; box-shadow: 0 0 25px rgba(99, 102, 241, 0.35);">
                    <video id="idCameraVideo" autoplay playsinline muted style="width: 100%; height: 100%; object-fit: cover;"></video>
                    <canvas id="idCaptureCanvas" style="display: none;"></canvas>

                    <!-- Flash animation overlay on capture -->
                    <div id="cameraFlashOverlay" style="position: absolute; inset: 0; background: #fff; opacity: 0; pointer-events: none; transition: opacity 0.15s ease-out;"></div>

                    <!-- Target Card Alignment Frame -->
                    <div id="cameraCardGuide" style="position: absolute; inset: 22px; border: 2px dashed rgba(56, 189, 248, 0.85); border-radius: 8px; pointer-events: none; box-shadow: inset 0 0 25px rgba(56, 189, 248, 0.2);">
                        <!-- Laser scanline -->
                        <div id="cameraScanLine" style="position: absolute; top: 0; left: 0; right: 0; height: 3px; background: #38bdf8; box-shadow: 0 0 12px #38bdf8; animation: scanLine 2.2s infinite ease-in-out;"></div>
                        <!-- Corner indicators -->
                        <span style="position: absolute; top: -2px; left: -2px; width: 14px; height: 14px; border-top: 3px solid #38bdf8; border-left: 3px solid #38bdf8;"></span>
                        <span style="position: absolute; top: -2px; right: -2px; width: 14px; height: 14px; border-top: 3px solid #38bdf8; border-right: 3px solid #38bdf8;"></span>
                        <span style="position: absolute; bottom: -2px; left: -2px; width: 14px; height: 14px; border-bottom: 3px solid #38bdf8; border-left: 3px solid #38bdf8;"></span>
                        <span style="position: absolute; bottom: -2px; right: -2px; width: 14px; height: 14px; border-bottom: 3px solid #38bdf8; border-right: 3px solid #38bdf8;"></span>
                    </div>

                    <!-- Alignment text badge -->
                    <div style="position: absolute; top: 10px; left: 50%; transform: translateX(-50%); background: rgba(15, 23, 42, 0.88); color: #38bdf8; font-size: 0.72rem; font-weight: 600; padding: 0.25rem 0.75rem; border-radius: 20px; border: 1px solid rgba(56, 189, 248, 0.4); pointer-events: none; white-space: nowrap;">
                        🪪 Align Student ID Card inside box
                    </div>

                    <!-- Permission Denied / Error guidance banner -->
                    <div id="cameraPermissionBanner" style="display: none; position: absolute; inset: 0; background: rgba(15, 23, 42, 0.95); padding: 1.5rem; text-align: center; flex-direction: column; align-items: center; justify-content: center; z-index: 10;">
                        <div style="font-size: 2.2rem; margin-bottom: 0.5rem;">📹</div>
                        <h4 style="color: #f87171; font-size: 1rem; margin-bottom: 0.35rem;">Camera Access Notice</h4>
                        <p id="cameraPermissionGuidance" style="color: #cbd5e1; font-size: 0.8rem; margin-bottom: 0.75rem; max-width: 340px; line-height: 1.4;">
                            Please allow camera permissions in your browser or switch to file upload below.
                        </p>
                        <div style="display: flex; gap: 0.5rem; justify-content: center; flex-wrap: wrap;">
                            <button type="button" class="btn btn-outline btn-sm" id="btnRetryCamera" style="border-color: #38bdf8; color: #38bdf8;">🔄 Retry Camera</button>
                            <button type="button" class="btn btn-primary btn-sm" id="btnSwitchToUpload">📁 Switch to Upload</button>
                        </div>
                    </div>
                </div>

                <!-- Camera Controls Toolbar -->
                <div style="display: flex; gap: 0.6rem; justify-content: center; align-items: center; margin-top: 0.85rem; flex-wrap: wrap;">
                    <button type="button" class="btn btn-primary btn-sm" id="btnCaptureIdCard" style="display: inline-flex; align-items: center; gap: 0.4rem; padding: 0.55rem 1.4rem; font-weight: 700; font-size: 0.88rem; box-shadow: 0 0 15px rgba(99, 102, 241, 0.4);">
                        <span>📸</span> Capture & Scan Card
                    </button>
                    <button type="button" class="btn btn-outline btn-sm" id="btnFlipCamera" style="display: inline-flex; align-items: center; gap: 0.3rem; font-size: 0.8rem;" title="Switch between front and back camera">
                        <span>🔄</span> Flip Camera
                    </button>
                </div>
            </div>

            <!-- TAB 2: Upload Card Section -->
            <div id="sectionUploadScan" style="display: none; margin-bottom: 1rem;">
                <div id="dropZone" style="border: 2px dashed #6366f1; border-radius: var(--radius-md); padding: 2.25rem 1.25rem; background: rgba(99, 102, 241, 0.05); cursor: pointer; transition: all 0.2s ease;">
                    <div style="font-size: 2.75rem; margin-bottom: 0.75rem;">📤</div>
                    <h4 style="font-size: 1.05rem; margin-bottom: 0.35rem; color: #f1f5f9;">Select or drop your College ID Card image</h4>
                    <p style="color: var(--text-secondary); font-size: 0.82rem; margin-bottom: 1.15rem;">
                        Upload a clear photo of your official Student ID Card. Built-in OCR will automatically detect your credentials.
                    </p>
                    <label class="btn btn-primary btn-sm" style="cursor: pointer; display: inline-flex; align-items: center; gap: 0.4rem; padding: 0.6rem 1.25rem; font-weight: 600;">
                        <span>📁</span> Browse ID Card Photo
                        <input type="file" id="idCardFileInput" accept="image/*" style="display: none;" />
                    </label>
                </div>
            </div>

            <!-- SCAN PROCESSING LOADER CARD -->
            <div id="scanProcessingCard" style="display: none; background: #0f172a; border: 1px solid #38bdf8; border-radius: var(--radius-md); padding: 1.5rem; text-align: center; margin-top: 1rem;">
                <div class="spinner" style="width: 32px; height: 32px; border: 3px solid rgba(56, 189, 248, 0.2); border-top-color: #38bdf8; border-radius: 50%; margin: 0 auto 0.75rem; animation: spin 0.8s linear infinite;"></div>
                <strong id="ocrStatusTitle" style="color: #38bdf8; font-size: 0.95rem; display: block; margin-bottom: 0.25rem;">🔍 Scanning ID Card with OCR...</strong>
                <span id="ocrStatusSubtitle" style="color: #94a3b8; font-size: 0.78rem;">Analyzing document text, barcodes, and student credentials...</span>
                <div id="ocrProgressBarContainer" style="width: 100%; max-width: 260px; height: 6px; background: rgba(255,255,255,0.1); border-radius: 10px; margin: 0.75rem auto 0 auto; overflow: hidden; display: none;">
                    <div id="ocrProgressBar" style="width: 0%; height: 100%; background: #38bdf8; transition: width 0.2s;"></div>
                </div>
            </div>

            <!-- REAL-TIME DETECTION RESULT CARD (With Editable Inputs for 100% Accuracy) -->
            <div id="scanResultCard" style="display: none; background: #0f172a; border: 2px solid #10b981; border-radius: var(--radius-md); padding: 1.25rem; text-align: left; margin-top: 1rem; box-shadow: 0 0 20px rgba(16, 185, 129, 0.2);">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.85rem; border-bottom: 1px solid rgba(255,255,255,0.08); padding-bottom: 0.5rem;">
                    <div style="display: flex; align-items: center; gap: 0.4rem;">
                        <span style="font-size: 1.2rem;">✨</span>
                        <strong style="color: #10b981; font-size: 0.95rem;">Card Scanned Successfully!</strong>
                    </div>
                    <span class="status-badge status-active" style="font-size: 0.7rem;">✓ OCR Verified</span>
                </div>

                <div style="display: flex; gap: 1rem; align-items: flex-start; flex-wrap: wrap;">
                    <!-- Student Photo Preview -->
                    <div style="text-align: center;">
                        <div id="detectedPhotoFrame" style="width: 88px; height: 104px; border-radius: 6px; background: #1e293b; border: 2px solid #38bdf8; overflow: hidden; display: flex; align-items: center; justify-content: center; margin-bottom: 0.35rem; box-shadow: 0 4px 10px rgba(0,0,0,0.5);">
                            <img id="detectedPhotoImg" src="" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </div>
                        <span style="font-size: 0.68rem; color: #38bdf8; display: block; font-weight: 600;">Student Photo</span>
                    </div>

                    <!-- Extracted & Editable Metadata Attributes -->
                    <div style="flex: 1; min-width: 240px; font-size: 0.85rem; display: flex; flex-direction: column; gap: 0.45rem;">
                        <div>
                            <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">🪪 VERIFIED COLLEGE ID</label>
                            <input type="text" id="detCollegeIdInput" class="form-control" style="font-family: monospace; font-size: 0.95rem; font-weight: 700; color: #38bdf8; background: #1e293b; border-color: #38bdf8; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">👤 STUDENT NAME</label>
                            <input type="text" id="detStudentNameInput" class="form-control" style="font-size: 0.85rem; font-weight: 600; color: #f8fafc; background: #1e293b; border-color: rgba(255,255,255,0.15); padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">🏛️ COLLEGE / UNIVERSITY</label>
                            <input type="text" id="detCollegeNameInput" class="form-control" style="font-size: 0.8rem; color: #cbd5e1; background: #1e293b; border-color: rgba(255,255,255,0.15); padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">🎓 DEGREE / PROGRAM</label>
                            <input type="text" id="detProgramNameInput" class="form-control" style="font-size: 0.8rem; color: #cbd5e1; background: #1e293b; border-color: rgba(255,255,255,0.15); padding: 0.35rem 0.6rem;" />
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem;">
                            <div>
                                <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">📅 ADMIT YEAR</label>
                                <input type="text" id="detJoiningYearInput" class="form-control" style="font-size: 0.8rem; color: #38bdf8; background: #1e293b; border-color: rgba(255,255,255,0.15); padding: 0.35rem 0.6rem;" />
                            </div>
                            <div>
                                <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">⏳ ACADEMIC YEAR</label>
                                <input type="text" id="detStudyYearInput" class="form-control" style="font-size: 0.8rem; color: #34d399; background: #1e293b; border-color: rgba(255,255,255,0.15); padding: 0.35rem 0.6rem;" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Confirmation Action Buttons -->
                <div style="display: flex; gap: 0.75rem; margin-top: 1rem; border-top: 1px solid rgba(255,255,255,0.08); padding-top: 0.75rem;">
                    <button type="button" class="btn btn-success btn-sm btn-block" id="btnApplyDetectedId" style="font-size: 0.85rem; font-weight: 600;">
                        <span>✓</span> Apply Scanned Card to Registration
                    </button>
                    <button type="button" class="btn btn-outline btn-sm" id="btnCancelDetectedId" style="width: auto;">
                        Scan Again
                    </button>
                </div>
            </div>
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
