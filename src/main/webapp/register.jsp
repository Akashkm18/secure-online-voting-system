<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Register as an authorized campus voter to participate in official campus elections.">
    <title>Voter Registration | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
    
    <!-- Tesseract.js for Optical Character Recognition (OCR) -->
    <script src="https://cdn.jsdelivr.net/npm/tesseract.js@5/dist/tesseract.min.js"></script>
    
    <!-- ZXing for Barcode/QR Code Detection -->
    <script src="https://cdn.jsdelivr.net/npm/@zxing/library@latest/umd/index.min.js"></script>
</head>
<body>

    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <main class="auth-wrapper">
        <div class="auth-card" id="voterRegisterCard">
            <div style="text-align: center; margin-bottom: 1.75rem;">
                <div style="width: 48px; height: 48px; margin: 0 auto 1rem auto; border-radius: 12px; background: rgba(37, 99, 235, 0.12); display: flex; align-items: center; justify-content: center; color: var(--primary);">
                    <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/>
                        <circle cx="9" cy="7" r="4"/>
                        <line x1="19" y1="8" x2="19" y2="14"/>
                        <line x1="22" y1="11" x2="16" y2="11"/>
                    </svg>
                </div>
                <h1 style="font-size: 1.5rem; font-weight: 700; color: var(--text-primary); margin-bottom: 0.35rem;">Voter Registration</h1>
                <p style="color: var(--text-secondary); font-size: 0.875rem;">Create your verified credentials for campus elections</p>
            </div>

            <!-- Error Notification -->
            <c:if test="${not empty errorMessage}">
                <div class="alert alert-danger" id="alertRegisterError">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink:0;">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
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
                    <label for="fullName">Full Legal Name</label>
                    <input type="text" id="fullName" name="fullName" class="form-control" 
                           placeholder="e.g. John Doe" value="<c:out value='${fullName}' />" required minlength="2" maxlength="100" />
                </div>

                <div class="form-group">
                    <label for="email">Institutional Email Address</label>
                    <input type="email" id="email" name="email" class="form-control" 
                           placeholder="student@institution.edu" value="<c:out value='${email}' />" required maxlength="150" />
                </div>

                <!-- Compulsory ID Scan & Photo Verification Alert -->
                <div class="alert alert-danger" id="compulsoryScanAlert" style="display: none; align-items: flex-start; gap: 0.65rem; margin-bottom: 1.25rem;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="flex-shrink: 0; margin-top: 2px;">
                        <circle cx="12" cy="12" r="10"/>
                        <line x1="12" y1="8" x2="12" y2="12"/>
                        <line x1="12" y1="16" x2="12.01" y2="16"/>
                    </svg>
                    <div>
                        <strong style="display: block; font-size: 0.9rem; margin-bottom: 2px;">Student ID Card Scan Required</strong>
                        <span>Scanning or uploading your official student ID card is compulsory. Your portrait photo is required to complete voter verification.</span>
                    </div>
                </div>

                <!-- Compulsory ID Card & Official Photo Panel -->
                <div class="form-group" style="background: rgba(37, 99, 235, 0.05); border: 2px solid rgba(59, 130, 246, 0.4); border-radius: var(--radius-md); padding: 1.25rem; margin-bottom: 1.25rem;">
                    <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.5rem; flex-wrap: wrap; gap: 0.5rem;">
                        <label for="collegeId" style="margin: 0; font-weight: 700; color: var(--text-primary); display: flex; align-items: center; gap: 0.4rem; font-size: 0.95rem;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--primary);">
                                <rect x="3" y="4" width="18" height="16" rx="2"/>
                                <circle cx="9" cy="10" r="2"/>
                                <line x1="15" y1="8" x2="17" y2="8"/>
                                <line x1="15" y1="12" x2="17" y2="12"/>
                            </svg>
                            Student ID Card Verification <span style="color: var(--danger); font-size: 0.82rem;">* Compulsory</span>
                        </label>
                        <span class="badge badge-active" style="font-size: 0.72rem; padding: 0.2rem 0.55rem; letter-spacing: 0.04em;">Photo Required</span>
                    </div>

                    <p style="color: var(--text-secondary); font-size: 0.8rem; margin-bottom: 0.9rem; line-height: 1.4;">
                        Select either option below to verify your card and capture your official portrait photo for the voter registry.
                    </p>

                    <!-- Prominent Dual Action Buttons -->
                    <input type="file" id="directCardFileInput" accept="image/*" style="display: none;" onchange="handleDirectUpload(this)" />
                    <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.65rem; margin-bottom: 1rem;">
                        <button type="button" class="btn btn-primary btn-sm" id="btnOpenIdScanner" onclick="openIdScannerModal('camera')" style="display: flex; align-items: center; justify-content: center; gap: 0.45rem; padding: 0.65rem 0.5rem; font-weight: 600; font-size: 0.85rem; cursor: pointer;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                                <circle cx="12" cy="13" r="4"/>
                            </svg>
                            <span>Live Camera</span>
                        </button>
                        <button type="button" class="btn btn-secondary btn-sm" id="btnOpenUploadScanner" onclick="document.getElementById('directCardFileInput').click()" style="display: flex; align-items: center; justify-content: center; gap: 0.45rem; padding: 0.65rem 0.5rem; font-weight: 600; font-size: 0.85rem; cursor: pointer;">
                            <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                                <polyline points="17 8 12 3 7 8"/>
                                <line x1="12" y1="3" x2="12" y2="15"/>
                            </svg>
                            <span>Upload ID Photo</span>
                        </button>
                    </div>

                    <!-- Verified Student ID Card Input -->
                    <div>
                        <label for="collegeId" style="font-size: 0.78rem; color: var(--text-muted); margin-bottom: 0.25rem; display: block;">STUDENT ID / ROLL NUMBER</label>
                        <div style="position: relative;">
                            <input type="text" id="collegeId" name="collegeId" class="form-control" 
                                   placeholder="e.g. 4107241562 or STU-2026-001" value="<c:out value='${collegeId}' />" required minlength="3" maxlength="50" style="font-family: monospace; font-weight: 600;" />
                            <span id="scanStatusBadge" style="display: none; position: absolute; right: 10px; top: 50%; transform: translateY(-50%); font-size: 0.75rem; background: var(--success-bg); color: var(--success); padding: 0.2rem 0.55rem; border-radius: var(--radius-sm); border: 1px solid rgba(16, 185, 129, 0.3); font-weight: 600;">
                                ✓ Photo Captured
                            </span>
                        </div>
                    </div>

                    <!-- Verified Student Card Widget (Displays captured photo prominently) -->
                    <div id="studentCardPreviewWidget" style="display: none; margin-top: 1rem; background: var(--bg-surface); border: 1px solid var(--success); border-radius: var(--radius-md); padding: 0.85rem; text-align: left;">
                        <div style="display: flex; gap: 0.85rem; align-items: center;">
                            <div id="widgetPhotoBox" style="width: 64px; height: 76px; border-radius: 6px; background: #000; border: 2px solid var(--success); overflow: hidden; display: flex; align-items: center; justify-content: center; flex-shrink: 0; box-shadow: var(--shadow-sm);">
                                <img id="widgetPhotoImg" src="" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover; display: none;" />
                                <span id="widgetPhotoPlaceholder" style="font-size: 1.5rem; color: var(--text-muted);">
                                    <svg width="28" height="28" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                        <path d="M20 21v-2a4 4 0 0 0-4-4H8a4 4 0 0 0-4 4v2"/>
                                        <circle cx="12" cy="7" r="4"/>
                                    </svg>
                                </span>
                            </div>
                            <div style="flex-grow: 1; min-width: 0;">
                                <div style="display: flex; justify-content: space-between; align-items: flex-start; margin-bottom: 0.25rem;">
                                    <span class="badge badge-active" style="font-size: 0.7rem; background: var(--success-bg); color: var(--success); border-color: rgba(16, 185, 129, 0.4);">✓ ID Card & Photo Attached</span>
                                    <button type="button" id="btnReScanCard" onclick="openIdScannerModal('camera')" style="background: none; border: none; color: var(--primary); font-size: 0.75rem; cursor: pointer; text-decoration: underline; font-weight: 600;">Change / Rescan</button>
                                </div>
                                <div id="widgetCollegeName" style="font-weight: 600; font-size: 0.85rem; color: var(--text-primary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"></div>
                                <div id="widgetProgramName" style="font-size: 0.78rem; color: var(--text-secondary); white-space: nowrap; overflow: hidden; text-overflow: ellipsis;"></div>
                                <div style="font-size: 0.75rem; color: var(--primary); margin-top: 0.15rem;">
                                    Year: <strong id="widgetJoiningYear"></strong> • <span id="widgetStudyYear"></span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="form-group">
                    <label for="password">Create Password (min 6 characters)</label>
                    <div style="position: relative;">
                        <input type="password" id="password" name="password" class="form-control" 
                               placeholder="••••••••" required minlength="6" style="padding-right: 2.75rem;" />
                        <button type="button" class="btn-toggle-pw" onclick="togglePasswordVisibility('password', this)" aria-label="Toggle password visibility" style="position: absolute; right: 8px; top: 50%; transform: translateY(-50%); background: none; border: none; color: var(--text-muted); cursor: pointer; padding: 4px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <div class="form-group">
                    <label for="confirmPassword">Confirm Password</label>
                    <div style="position: relative;">
                        <input type="password" id="confirmPassword" name="confirmPassword" class="form-control" 
                               placeholder="••••••••" required minlength="6" style="padding-right: 2.75rem;" />
                        <button type="button" class="btn-toggle-pw" onclick="togglePasswordVisibility('confirmPassword', this)" aria-label="Toggle password visibility" style="position: absolute; right: 8px; top: 50%; transform: translateY(-50%); background: none; border: none; color: var(--text-muted); cursor: pointer; padding: 4px;">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                                <path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/>
                                <circle cx="12" cy="12" r="3"/>
                            </svg>
                        </button>
                    </div>
                </div>

                <button type="submit" class="btn btn-primary btn-block" id="submitRegisterBtn" style="margin-top: 1.5rem;">
                    Complete Registration
                </button>
            </form>

            <div style="margin-top: 1.75rem; padding-top: 1.25rem; border-top: 1px solid var(--border-color); text-align: center; font-size: 0.875rem; color: var(--text-secondary);">
                Already registered? 
                <a href="${pageContext.request.contextPath}/login.jsp" style="color: var(--primary); font-weight: 600; text-decoration: none;" id="linkToLogin">
                    Sign In
                </a>
            </div>
        </div>
    </main>

    <!-- Student ID Card Verification Modal -->
    <div class="modal-overlay" id="idScannerModal">
        <div class="modal-box" style="max-width: 540px; text-align: center; max-height: 92vh; overflow-y: auto;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.75rem;">
                <h3 class="modal-title" style="margin: 0; font-size: 1.15rem; display: flex; align-items: center; gap: 0.5rem;">
                    <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="color: var(--primary);">
                        <rect x="3" y="4" width="18" height="16" rx="2"/>
                        <circle cx="9" cy="10" r="2"/>
                        <line x1="15" y1="8" x2="17" y2="8"/>
                        <line x1="15" y1="12" x2="17" y2="12"/>
                        <line x1="7" y1="16" x2="17" y2="16"/>
                    </svg>
                    Student ID Card Verification
                </h3>
                <button type="button" class="btn btn-secondary btn-sm" id="btnCloseIdScanner" onclick="closeIdScannerModal()" aria-label="Close modal">✕</button>
            </div>

            <!-- Mode Switcher Tabs -->
            <div style="display: flex; gap: 0.5rem; justify-content: center; margin-bottom: 1.25rem; background: var(--bg-surface-elevated); padding: 0.25rem; border-radius: var(--radius-md); border: 1px solid var(--border-color);">
                <button type="button" class="btn btn-sm btn-scanner-tab active" id="tabCameraBtn" onclick="switchModeTab('camera')" style="flex: 1; border-radius: var(--radius-sm); font-size: 0.82rem; font-weight: 600; padding: 0.5rem;">
                    Live Camera Scanner
                </button>
                <button type="button" class="btn btn-sm btn-scanner-tab" id="tabUploadBtn" onclick="switchModeTab('upload')" style="flex: 1; border-radius: var(--radius-sm); font-size: 0.82rem; font-weight: 600; padding: 0.5rem; background: transparent; color: var(--text-secondary); border: none;">
                    Upload ID Photo
                </button>
            </div>

            <!-- TAB 1: Live Camera Scanner Section -->
            <div id="sectionCameraScan" style="margin-bottom: 1rem;">
                <div id="cameraViewfinderContainer" style="position: relative; width: 100%; max-width: 480px; height: 280px; margin: 0 auto; background: #000; border-radius: var(--radius-md); overflow: hidden; border: 1px solid var(--border-color);">
                    <video id="idCameraVideo" autoplay playsinline muted style="width: 100%; height: 100%; object-fit: cover;"></video>
                    <canvas id="idCaptureCanvas" style="display: none;"></canvas>

                    <!-- Flash animation overlay on capture -->
                    <div id="cameraFlashOverlay" style="position: absolute; inset: 0; background: #fff; opacity: 0; pointer-events: none; transition: opacity 0.15s ease-out;"></div>

                    <!-- Target Card Alignment Frame -->
                    <div id="cameraCardGuide" style="position: absolute; inset: 22px; border: 2px dashed rgba(37, 99, 235, 0.85); border-radius: 8px; pointer-events: none;">
                        <!-- Laser scanline -->
                        <div id="cameraScanLine" style="position: absolute; top: 0; left: 0; right: 0; height: 2px; background: var(--primary); box-shadow: 0 0 8px var(--primary); animation: scanLine 2.2s infinite ease-in-out;"></div>
                        <!-- Corner indicators -->
                        <span style="position: absolute; top: -2px; left: -2px; width: 14px; height: 14px; border-top: 3px solid var(--primary); border-left: 3px solid var(--primary);"></span>
                        <span style="position: absolute; top: -2px; right: -2px; width: 14px; height: 14px; border-top: 3px solid var(--primary); border-right: 3px solid var(--primary);"></span>
                        <span style="position: absolute; bottom: -2px; left: -2px; width: 14px; height: 14px; border-bottom: 3px solid var(--primary); border-left: 3px solid var(--primary);"></span>
                        <span style="position: absolute; bottom: -2px; right: -2px; width: 14px; height: 14px; border-bottom: 3px solid var(--primary); border-right: 3px solid var(--primary);"></span>
                    </div>

                    <!-- Alignment text badge -->
                    <div style="position: absolute; top: 10px; left: 50%; transform: translateX(-50%); background: rgba(15, 23, 42, 0.88); color: var(--text-primary); font-size: 0.72rem; font-weight: 600; padding: 0.25rem 0.75rem; border-radius: 20px; border: 1px solid var(--border-color); pointer-events: none; white-space: nowrap;">
                        Align ID Card within frame
                    </div>

                    <!-- Permission Denied / Error guidance banner -->
                    <div id="cameraPermissionBanner" style="display: none; position: absolute; inset: 0; background: rgba(15, 23, 42, 0.95); padding: 1.5rem; text-align: center; flex-direction: column; align-items: center; justify-content: center; z-index: 10;">
                        <h4 style="color: var(--danger); font-size: 1rem; margin-bottom: 0.35rem;">Camera Access Required</h4>
                        <p id="cameraPermissionGuidance" style="color: var(--text-secondary); font-size: 0.8rem; margin-bottom: 0.75rem; max-width: 340px; line-height: 1.4;">
                            Please allow camera permissions in your browser or switch to file upload below.
                        </p>
                        <div style="display: flex; gap: 0.5rem; justify-content: center; flex-wrap: wrap;">
                            <button type="button" class="btn btn-secondary btn-sm" id="btnRetryCamera">Retry Camera</button>
                            <button type="button" class="btn btn-primary btn-sm" id="btnSwitchToUpload">Switch to Upload</button>
                        </div>
                    </div>
                </div>

                <!-- Camera Controls Toolbar -->
                <div style="display: flex; gap: 0.6rem; justify-content: center; align-items: center; margin-top: 0.85rem; flex-wrap: wrap;">
                    <button type="button" class="btn btn-primary btn-sm" id="btnCaptureIdCard" style="display: inline-flex; align-items: center; gap: 0.4rem; padding: 0.55rem 1.4rem; font-weight: 600; font-size: 0.88rem;">
                        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2">
                            <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                            <circle cx="12" cy="13" r="4"/>
                        </svg>
                        <span>Capture & Scan Card</span>
                    </button>
                    <button type="button" class="btn btn-secondary btn-sm" id="btnFlipCamera" style="display: inline-flex; align-items: center; gap: 0.3rem; font-size: 0.8rem;" title="Switch camera">
                        <span>Flip Camera</span>
                    </button>
                </div>
            </div>

            <!-- TAB 2: Upload Card Section -->
            <div id="sectionUploadScan" style="display: none; margin-bottom: 1rem;">
                <div id="dropZone" style="border: 2px dashed var(--border-color); border-radius: var(--radius-md); padding: 2.25rem 1.25rem; background: var(--bg-surface-elevated); cursor: pointer; transition: all 0.2s ease;">
                    <svg width="40" height="40" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.5" style="color: var(--primary); margin-bottom: 0.75rem;">
                        <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"/>
                        <polyline points="17 8 12 3 7 8"/>
                        <line x1="12" y1="3" x2="12" y2="15"/>
                    </svg>
                    <h4 style="font-size: 1rem; margin-bottom: 0.35rem; color: var(--text-primary);">Select or drop ID Card photo</h4>
                    <p style="color: var(--text-secondary); font-size: 0.82rem; margin-bottom: 1.15rem;">
                        Upload a clear image of your official Student ID Card. Built-in OCR will extract your credentials.
                    </p>
                    <label class="btn btn-primary btn-sm" style="cursor: pointer; display: inline-flex; align-items: center; gap: 0.4rem; padding: 0.6rem 1.25rem; font-weight: 600;">
                        <span>Browse File</span>
                        <input type="file" id="idCardFileInput" accept="image/*" style="display: none;" />
                    </label>
                </div>
            </div>

            <!-- SCAN PROCESSING LOADER CARD -->
            <div id="scanProcessingCard" style="display: none; background: var(--bg-surface-elevated); border: 1px solid var(--border-color); border-radius: var(--radius-md); padding: 1.5rem; text-align: center; margin-top: 1rem;">
                <div class="spinner" style="width: 28px; height: 28px; border: 3px solid rgba(37, 99, 235, 0.2); border-top-color: var(--primary); border-radius: 50%; margin: 0 auto 0.75rem; animation: spin 0.8s linear infinite;"></div>
                <strong id="ocrStatusTitle" style="color: var(--primary); font-size: 0.95rem; display: block; margin-bottom: 0.25rem;">Processing ID Card...</strong>
                <span id="ocrStatusSubtitle" style="color: var(--text-secondary); font-size: 0.78rem;">Analyzing document text, barcodes, and student credentials...</span>
                <div id="ocrProgressBarContainer" style="width: 100%; max-width: 260px; height: 4px; background: rgba(255,255,255,0.1); border-radius: 10px; margin: 0.75rem auto 0 auto; overflow: hidden; display: none;">
                    <div id="ocrProgressBar" style="width: 0%; height: 100%; background: var(--primary); transition: width 0.2s;"></div>
                </div>
            </div>

            <!-- REAL-TIME DETECTION RESULT CARD -->
            <div id="scanResultCard" style="display: none; background: var(--bg-surface-elevated); border: 1px solid var(--success); border-radius: var(--radius-md); padding: 1.25rem; text-align: left; margin-top: 1rem;">
                <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 0.85rem; border-bottom: 1px solid var(--border-color); padding-bottom: 0.5rem;">
                    <strong style="color: var(--success); font-size: 0.95rem;">Card Detected Successfully</strong>
                    <span class="badge badge-active" style="font-size: 0.7rem;">OCR Verified</span>
                </div>

                <div style="display: flex; gap: 1rem; align-items: flex-start; flex-wrap: wrap;">
                    <!-- Student Photo Preview -->
                    <div style="text-align: center;">
                        <div id="detectedPhotoFrame" style="width: 88px; height: 104px; border-radius: 6px; background: var(--bg-surface); border: 1px solid var(--border-color); overflow: hidden; display: flex; align-items: center; justify-content: center; margin-bottom: 0.35rem;">
                            <img id="detectedPhotoImg" src="" alt="Student Photo" style="width: 100%; height: 100%; object-fit: cover;" />
                        </div>
                        <span style="font-size: 0.68rem; color: var(--text-muted); display: block;">Student Photo</span>
                    </div>

                    <!-- Extracted & Editable Metadata Attributes -->
                    <div style="flex: 1; min-width: 240px; font-size: 0.85rem; display: flex; flex-direction: column; gap: 0.45rem;">
                        <div>
                            <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">STUDENT ID / ROLL NO</label>
                            <input type="text" id="detCollegeIdInput" class="form-control" style="font-family: monospace; font-size: 0.9rem; font-weight: 600; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">FULL NAME</label>
                            <input type="text" id="detStudentNameInput" class="form-control" style="font-size: 0.85rem; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">INSTITUTION</label>
                            <input type="text" id="detCollegeNameInput" class="form-control" style="font-size: 0.8rem; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div>
                            <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">PROGRAM / DEGREE</label>
                            <input type="text" id="detProgramNameInput" class="form-control" style="font-size: 0.8rem; padding: 0.35rem 0.6rem;" />
                        </div>

                        <div style="display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem;">
                            <div>
                                <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">ADMISSION YEAR</label>
                                <input type="text" id="detJoiningYearInput" class="form-control" style="font-size: 0.8rem; padding: 0.35rem 0.6rem;" />
                            </div>
                            <div>
                                <label style="color: var(--text-muted); font-size: 0.72rem; display: block; margin-bottom: 0.15rem;">ACADEMIC YEAR</label>
                                <input type="text" id="detStudyYearInput" class="form-control" style="font-size: 0.8rem; padding: 0.35rem 0.6rem;" />
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Confirmation Action Buttons -->
                <div style="display: flex; gap: 0.75rem; margin-top: 1rem; border-top: 1px solid var(--border-color); padding-top: 0.75rem;">
                    <button type="button" class="btn btn-primary btn-sm btn-block" id="btnApplyDetectedId" style="font-size: 0.85rem; font-weight: 600;">
                        Apply to Registration
                    </button>
                    <button type="button" class="btn btn-secondary btn-sm" id="btnCancelDetectedId" style="width: auto;">
                        Scan Again
                    </button>
                </div>
            </div>
        </div>
    </div>

    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/validation.js?v=<%= System.currentTimeMillis() %>"></script>

    <script>
    // Fail-safe global functions for Register page
    function openIdScannerModal(mode) {
        var modal = document.getElementById('idScannerModal');
        if (modal) {
            modal.classList.add('active');
            modal.style.display = 'flex';
        }
        if (typeof switchModeTab === 'function') {
            switchModeTab(mode || 'camera');
        }
    }

    function closeIdScannerModal() {
        var modal = document.getElementById('idScannerModal');
        if (modal) {
            modal.classList.remove('active');
            modal.style.display = 'none';
        }
        if (typeof stopCamera === 'function') {
            stopCamera();
        }
    }

    function handleDirectUpload(input) {
        if (!input || !input.files || !input.files[0]) return;
        var file = input.files[0];
        var reader = new FileReader();
        reader.onload = function (e) {
            var img = new Image();
            img.onload = function () {
                var maxW = 540;
                var maxH = 540;
                var w = img.naturalWidth || img.width;
                var h = img.naturalHeight || img.height;
                var scale = Math.min(1, maxW / w, maxH / h);
                var targetW = Math.round(w * scale);
                var targetH = Math.round(h * scale);

                var canvas = document.createElement('canvas');
                canvas.width = targetW;
                canvas.height = targetH;
                var ctx = canvas.getContext('2d');
                ctx.drawImage(img, 0, 0, targetW, targetH);
                var compressedDataUrl = canvas.toDataURL('image/jpeg', 0.82);

                var hiddenPhoto = document.getElementById('hiddenPhotoBase64');
                if (hiddenPhoto) hiddenPhoto.value = compressedDataUrl;

                var widget = document.getElementById('studentCardPreviewWidget');
                var widgetImg = document.getElementById('widgetPhotoImg');
                var placeholder = document.getElementById('widgetPhotoPlaceholder');
                var badge = document.getElementById('scanStatusBadge');

                if (widgetImg) {
                    widgetImg.src = compressedDataUrl;
                    widgetImg.style.display = 'block';
                }
                if (placeholder) placeholder.style.display = 'none';
                if (widget) widget.style.display = 'block';
                if (badge) {
                    badge.style.display = 'inline-block';
                    badge.textContent = '✓ Photo Attached';
                }

                var alertBox = document.getElementById('compulsoryScanAlert');
                if (alertBox) alertBox.style.display = 'none';

                // Also run OCR & barcode scanner if available in background
                if (typeof runOpticalScanning === 'function') {
                    try {
                        runOpticalScanning(canvas, file.name);
                    } catch(err) {
                        console.warn('Background scan warning:', err);
                    }
                }
            };
            img.src = e.target.result;
        };
        reader.readAsDataURL(file);
    }
    </script>
</body>
</html>
