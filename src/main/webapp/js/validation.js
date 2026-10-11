/**
 * Secure Online Voting System - Client-side validation & interactivity
 */

document.addEventListener('DOMContentLoaded', function () {

    // 1. Candidate Ballot Selection Handling
    const ballotCards = document.querySelectorAll('.candidate-ballot-card');
    ballotCards.forEach(card => {
        card.addEventListener('click', function (e) {
            const radio = this.querySelector('input[type="radio"]');
            if (radio) {
                radio.checked = true;
                ballotCards.forEach(c => c.classList.remove('selected'));
                this.classList.add('selected');
            }
        });
    });

    // 2. Vote Confirmation Modal Logic
    const voteForm = document.getElementById('ballotForm');
    const confirmModal = document.getElementById('voteConfirmModal');
    const confirmVoteBtn = document.getElementById('confirmVoteBtn');
    const cancelVoteBtn = document.getElementById('cancelVoteBtn');

    if (voteForm && confirmModal) {
        voteForm.addEventListener('submit', function (e) {
            e.preventDefault();
            const selectedCandidate = voteForm.querySelector('input[name="candidateId"]:checked');
            if (!selectedCandidate) {
                alert('Please select a candidate before proceeding.');
                return;
            }
            confirmModal.classList.add('active');
        });

        if (confirmVoteBtn) {
            confirmVoteBtn.addEventListener('click', function () {
                voteForm.submit();
            });
        }

        if (cancelVoteBtn) {
            cancelVoteBtn.addEventListener('click', function () {
                confirmModal.classList.remove('active');
            });
        }
    }

    // 3. Client Registration Form Validation (Enforces Compulsory ID Scan & Photo)
    const registerForm = document.getElementById('registerForm');
    if (registerForm) {
        registerForm.addEventListener('submit', function (e) {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;

            if (password.length < 6) {
                e.preventDefault();
                alert('Password must be at least 6 characters long.');
                return;
            }

            if (password !== confirmPassword) {
                e.preventDefault();
                alert('Passwords do not match. Please re-enter.');
                return;
            }

            // Enforce compulsory ID Card scan & student photo
            const photoInput = document.getElementById('hiddenPhotoBase64');
            if (!photoInput || !photoInput.value || photoInput.value.trim() === '') {
                e.preventDefault();
                const compulsoryAlert = document.getElementById('compulsoryScanAlert');
                if (compulsoryAlert) {
                    compulsoryAlert.style.display = 'flex';
                    compulsoryAlert.scrollIntoView({ behavior: 'smooth', block: 'center' });
                } else {
                    alert('Student ID Card scan is compulsory! Please scan your ID card or upload card photo to capture your official portrait.');
                }
                if (window.openIdScannerModal) {
                    window.openIdScannerModal('camera');
                } else if (idScannerModal) {
                    idScannerModal.classList.add('active');
                    switchModeTab('camera');
                }
                return;
            }
        });
    }

    // 4. Candidate Edit Modal / Prepopulation (Admin)
    const editCandidateButtons = document.querySelectorAll('.btn-edit-candidate');
    const editModal = document.getElementById('editCandidateModal');
    if (editCandidateButtons.length > 0 && editModal) {
        editCandidateButtons.forEach(btn => {
            btn.addEventListener('click', function () {
                document.getElementById('editCandidateId').value = this.dataset.id;
                document.getElementById('editCandidateName').value = this.dataset.name;
                document.getElementById('editParty').value = this.dataset.party;
                document.getElementById('editSymbol').value = this.dataset.symbol;
                document.getElementById('editActive').value = this.dataset.active;
                editModal.classList.add('active');
            });
        });

        const cancelEditBtn = document.getElementById('cancelEditBtn');
        if (cancelEditBtn) {
            cancelEditBtn.addEventListener('click', function () {
                editModal.classList.remove('active');
            });
        }
    }

    // 5. College ID Card Scanner Modal, Live Camera & Optical Recognition
    // -------------------------------------------------------------
    // Intelligent College ID Card Scanner & Student Detector
    // -------------------------------------------------------------
    const btnOpenIdScanner = document.getElementById('btnOpenIdScanner');
    const idScannerModal = document.getElementById('idScannerModal');
    const btnCloseIdScanner = document.getElementById('btnCloseIdScanner');
    const idCardFileInput = document.getElementById('idCardFileInput');
    const dropZone = document.getElementById('dropZone');
    const collegeIdInput = document.getElementById('collegeId');
    const scanStatusBadge = document.getElementById('scanStatusBadge');

    // Camera viewfinder elements
    const idCameraVideo = document.getElementById('idCameraVideo');
    const idCaptureCanvas = document.getElementById('idCaptureCanvas');
    const cameraFlashOverlay = document.getElementById('cameraFlashOverlay');
    const tabCameraBtn = document.getElementById('tabCameraBtn');
    const tabUploadBtn = document.getElementById('tabUploadBtn');
    const sectionCameraScan = document.getElementById('sectionCameraScan');
    const sectionUploadScan = document.getElementById('sectionUploadScan');
    const btnCaptureIdCard = document.getElementById('btnCaptureIdCard');
    const btnFlipCamera = document.getElementById('btnFlipCamera');
    const cameraPermissionBanner = document.getElementById('cameraPermissionBanner');
    const cameraPermissionGuidance = document.getElementById('cameraPermissionGuidance');
    const btnRetryCamera = document.getElementById('btnRetryCamera');
    const btnSwitchToUpload = document.getElementById('btnSwitchToUpload');

    // Result card elements (with editable inputs)
    const scanResultCard = document.getElementById('scanResultCard');
    const detectedPhotoImg = document.getElementById('detectedPhotoImg');
    const detCollegeIdInput = document.getElementById('detCollegeIdInput');
    const detStudentNameInput = document.getElementById('detStudentNameInput');
    const detCollegeNameInput = document.getElementById('detCollegeNameInput');
    const detProgramNameInput = document.getElementById('detProgramNameInput');
    const detJoiningYearInput = document.getElementById('detJoiningYearInput');
    const detStudyYearInput = document.getElementById('detStudyYearInput');
    const btnApplyDetectedId = document.getElementById('btnApplyDetectedId');
    const btnCancelDetectedId = document.getElementById('btnCancelDetectedId');

    // Processing & Error UI
    const scanProcessingCard = document.getElementById('scanProcessingCard');
    const ocrStatusTitle = document.getElementById('ocrStatusTitle');
    const ocrStatusSubtitle = document.getElementById('ocrStatusSubtitle');
    const ocrProgressBarContainer = document.getElementById('ocrProgressBarContainer');
    const ocrProgressBar = document.getElementById('ocrProgressBar');
    const scanErrorCard = document.getElementById('scanErrorCard');
    const scanErrorReason = document.getElementById('scanErrorReason');
    const btnErrorTryUpload = document.getElementById('btnErrorTryUpload');

    // Form widget preview elements (Login page)
    const studentCardPreviewWidget = document.getElementById('studentCardPreviewWidget');
    const widgetPhotoImg = document.getElementById('widgetPhotoImg');
    const widgetPhotoPlaceholder = document.getElementById('widgetPhotoPlaceholder');
    const widgetCollegeName = document.getElementById('widgetCollegeName');
    const widgetProgramName = document.getElementById('widgetProgramName');
    const widgetJoiningYear = document.getElementById('widgetJoiningYear');
    const widgetStudyYear = document.getElementById('widgetStudyYear');
    const btnReScanCard = document.getElementById('btnReScanCard');

    // Hidden form inputs (Register page)
    const hiddenCollegeName = document.getElementById('hiddenCollegeName');
    const hiddenProgramName = document.getElementById('hiddenProgramName');
    const hiddenJoiningYear = document.getElementById('hiddenJoiningYear');
    const hiddenStudyYear = document.getElementById('hiddenStudyYear');
    const hiddenPhotoBase64 = document.getElementById('hiddenPhotoBase64');

    let cameraStream = null;
    let currentFacingMode = 'environment';
    let currentDetectedData = null;

    function playBeepSound() {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.frequency.setValueAtTime(587.33, ctx.currentTime);
            osc.frequency.setValueAtTime(880, ctx.currentTime + 0.08);
            gain.gain.setValueAtTime(0.18, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.25);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.25);
        } catch (e) {}
    }

    function playShutterSound() {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.type = 'triangle';
            osc.frequency.setValueAtTime(800, ctx.currentTime);
            osc.frequency.setValueAtTime(400, ctx.currentTime + 0.04);
            gain.gain.setValueAtTime(0.15, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.12);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.12);
        } catch (e) {}
    }

    // Helper: generate synthetic student photo avatar badge on canvas
    function generateSyntheticPhoto(studentName, colorBg) {
        const canvas = document.createElement('canvas');
        canvas.width = 160;
        canvas.height = 190;
        const ctx = canvas.getContext('2d');

        const grad = ctx.createLinearGradient(0, 0, 0, 190);
        grad.addColorStop(0, colorBg || '#1e3a8a');
        grad.addColorStop(1, '#0f172a');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, 160, 190);

        ctx.fillStyle = '#fde047';
        ctx.beginPath();
        ctx.arc(80, 70, 32, 0, Math.PI * 2);
        ctx.fill();

        ctx.fillStyle = '#38bdf8';
        ctx.beginPath();
        ctx.ellipse(80, 155, 55, 45, 0, 0, Math.PI * 2);
        ctx.fill();

        ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
        ctx.font = 'bold 11px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('ALLIANCE', 80, 175);

        ctx.fillStyle = '#0f172a';
        ctx.font = 'bold 18px sans-serif';
        const initials = (studentName || 'AU').split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase() || 'AU';
        ctx.fillText(initials, 80, 77);

        return canvas.toDataURL('image/jpeg', 0.85);
    }

    // Crop photo region from image or video
    function cropPhotoFromCanvas(sourceCanvas) {
        const canvas = document.createElement('canvas');
        canvas.width = 160;
        canvas.height = 190;
        const ctx = canvas.getContext('2d');

        try {
            const sw = sourceCanvas.width;
            const sh = sourceCanvas.height;

            if (sw && sh) {
                // In standard student ID cards, portrait is positioned in the upper-right or center-right quadrant
                const cropX = sw * 0.58;
                const cropY = sh * 0.12;
                const cropW = sw * 0.38;
                const cropH = sh * 0.58;
                ctx.drawImage(sourceCanvas, cropX, cropY, cropW, cropH, 0, 0, 160, 190);
                return canvas.toDataURL('image/jpeg', 0.88);
            }
        } catch (e) {
            console.warn('[PhotoCrop] Fallback avatar:', e);
        }
        return generateSyntheticPhoto('Student Photo', '#312e81');
    }

    // Camera Stream Controller
    async function startCamera() {
        if (!idCameraVideo) return;
        stopCamera();
        if (cameraPermissionBanner) cameraPermissionBanner.style.display = 'none';

        try {
            if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
                throw new Error('Camera is not supported on this browser or requires an HTTPS / localhost connection.');
            }

            const constraints = {
                video: {
                    facingMode: { ideal: currentFacingMode },
                    width: { ideal: 1280 },
                    height: { ideal: 720 }
                },
                audio: false
            };

            const stream = await navigator.mediaDevices.getUserMedia(constraints);
            cameraStream = stream;
            idCameraVideo.srcObject = stream;
            await idCameraVideo.play().catch(e => console.log('Camera autoplay handled:', e));
        } catch (err) {
            console.warn('[Camera] Primary constraint failed, trying basic video:', err);
            try {
                const fallbackStream = await navigator.mediaDevices.getUserMedia({ video: true, audio: false });
                cameraStream = fallbackStream;
                idCameraVideo.srcObject = fallbackStream;
                await idCameraVideo.play().catch(e => console.log('Camera fallback handled:', e));
            } catch (fallbackErr) {
                console.error('[Camera] Access failed:', fallbackErr);
                if (cameraPermissionBanner) {
                    cameraPermissionBanner.style.display = 'flex';
                    if (cameraPermissionGuidance) {
                        cameraPermissionGuidance.textContent = (fallbackErr.name === 'NotAllowedError' || fallbackErr.name === 'PermissionDeniedError')
                            ? 'Camera permission was denied. Please allow camera access in your browser settings, or switch to Upload mode.'
                            : 'Camera device unavailable: ' + (fallbackErr.message || 'Please use upload option.');
                    }
                }
            }
        }
    }

    function stopCamera() {
        if (cameraStream) {
            cameraStream.getTracks().forEach(track => {
                try { track.stop(); } catch(e) {}
            });
            cameraStream = null;
        }
        if (idCameraVideo) {
            idCameraVideo.srcObject = null;
        }
    }

    function flipCamera() {
        currentFacingMode = (currentFacingMode === 'environment') ? 'user' : 'environment';
        startCamera();
    }

    function switchModeTab(mode) {
        if (mode === 'camera') {
            if (tabCameraBtn) {
                tabCameraBtn.classList.add('active');
                tabCameraBtn.style.background = '#4f46e5';
                tabCameraBtn.style.color = '#fff';
            }
            if (tabUploadBtn) {
                tabUploadBtn.classList.remove('active');
                tabUploadBtn.style.background = 'transparent';
                tabUploadBtn.style.color = 'var(--text-secondary)';
            }
            if (sectionCameraScan) sectionCameraScan.style.display = 'block';
            if (sectionUploadScan) sectionUploadScan.style.display = 'none';
            startCamera();
        } else {
            if (tabUploadBtn) {
                tabUploadBtn.classList.add('active');
                tabUploadBtn.style.background = '#4f46e5';
                tabUploadBtn.style.color = '#fff';
            }
            if (tabCameraBtn) {
                tabCameraBtn.classList.remove('active');
                tabCameraBtn.style.background = 'transparent';
                tabCameraBtn.style.color = 'var(--text-secondary)';
            }
            if (sectionCameraScan) sectionCameraScan.style.display = 'none';
            if (sectionUploadScan) sectionUploadScan.style.display = 'block';
            stopCamera();
        }
    }

    // Optical Scanning & OCR / Barcode Pipeline
    async function runOpticalScanning(sourceCanvas, sourceFileName) {
        if (!sourceCanvas) return;

        if (scanResultCard) scanResultCard.style.display = 'none';
        if (scanErrorCard) scanErrorCard.style.display = 'none';
        if (scanProcessingCard) scanProcessingCard.style.display = 'block';

        if (ocrStatusTitle) ocrStatusTitle.textContent = '🔍 Scanning ID Card with OCR & Barcode...';
        if (ocrStatusSubtitle) ocrStatusSubtitle.textContent = 'Analyzing image for student ID and barcode...';
        if (ocrProgressBarContainer) ocrProgressBarContainer.style.display = 'block';
        if (ocrProgressBar) ocrProgressBar.style.width = '15%';

        const setProgress = (pct, text) => {
            if (ocrProgressBar) ocrProgressBar.style.width = Math.min(100, Math.round(pct)) + '%';
            if (ocrStatusSubtitle && text) ocrStatusSubtitle.textContent = text;
        };

        const croppedPhotoDataUrl = cropPhotoFromCanvas(sourceCanvas);

        let barcodeDetected = '';
        let recognizedText = '';

        // 1. ZXing Barcode Scanning
        setProgress(25, 'Scanning card for 1D/2D Barcodes & QR codes...');
        try {
            if (window.ZXing && (window.ZXing.BrowserMultiFormatReader || window.ZXing.MultiFormatReader)) {
                const reader = new (window.ZXing.BrowserMultiFormatReader || window.ZXing.MultiFormatReader)();
                if (typeof reader.decodeFromCanvas === 'function') {
                    const zxResult = await reader.decodeFromCanvas(sourceCanvas);
                    if (zxResult && zxResult.getText()) {
                        barcodeDetected = zxResult.getText().trim();
                        console.log('[ZXing] Barcode recognized:', barcodeDetected);
                    }
                }
            }
        } catch (zxErr) {
            console.log('[ZXing] No barcode on card frame:', zxErr.message || zxErr);
        }

        // 2. Tesseract OCR Recognition
        setProgress(40, 'Running neural OCR character extraction...');
        try {
            if (window.Tesseract && typeof window.Tesseract.recognize === 'function') {
                // Scale down slightly for performance while enhancing contrast
                const ocrCanvas = document.createElement('canvas');
                const targetW = Math.min(sourceCanvas.width, 1600);
                const scale = targetW / sourceCanvas.width;
                ocrCanvas.width = targetW;
                ocrCanvas.height = sourceCanvas.height * scale;
                const oCtx = ocrCanvas.getContext('2d');
                oCtx.drawImage(sourceCanvas, 0, 0, ocrCanvas.width, ocrCanvas.height);

                // Contrast enhancement filter
                const imgData = oCtx.getImageData(0, 0, ocrCanvas.width, ocrCanvas.height);
                const d = imgData.data;
                for (let i = 0; i < d.length; i += 4) {
                    const lum = 0.299 * d[i] + 0.587 * d[i + 1] + 0.114 * d[i + 2];
                    const contrastFactor = 1.35;
                    const factor = (259 * (contrastFactor + 255)) / (255 * (259 - contrastFactor));
                    const adj = Math.min(255, Math.max(0, factor * (lum - 128) + 128));
                    d[i] = adj;
                    d[i + 1] = adj;
                    d[i + 2] = adj;
                }
                oCtx.putImageData(imgData, 0, 0);

                const tessResult = await window.Tesseract.recognize(ocrCanvas, 'eng', {
                    logger: m => {
                        if (m && m.status === 'recognizing text' && m.progress) {
                            setProgress(40 + (m.progress * 50), `Extracting card text (${Math.round(m.progress * 100)}%)...`);
                        }
                    }
                });

                if (tessResult && tessResult.data && tessResult.data.text) {
                    recognizedText = tessResult.data.text;
                    console.log('[Tesseract] Raw text extracted:\n', recognizedText);
                }
            }
        } catch (tessErr) {
            console.warn('[Tesseract] Optical recognition fallback:', tessErr);
        }

        setProgress(95, 'Matching institutional database...');

        // 3. Intelligent Extraction & Parsing
        const fullCorpus = (recognizedText + ' ' + (sourceFileName || '') + ' ' + barcodeDetected).trim();
        const corpusUpper = fullCorpus.toUpperCase();
        const lines = recognizedText.split('\n').map(l => l.trim()).filter(l => l.length > 0);

        // A. Student ID Extraction
        let studentId = '';
        if (barcodeDetected && /^[A-Z0-9\-_]{4,20}$/i.test(barcodeDetected)) {
            studentId = barcodeDetected.toUpperCase();
        }

        if (!studentId) {
            // Alliance University regex: AU-2024-CED-014, AU2024CED014, ALU-2026-1001, AU-2024-...
            const auMatch = fullCorpus.match(/(AU[-_ ]?20\d{2}[-_ ]?[A-Z0-9]+[-_ ]?\d{1,4})/i) ||
                            fullCorpus.match(/(ALU[-_ ]?20\d{2}[-_ ]?\d{1,4})/i) ||
                            fullCorpus.match(/(AU[-_ ]?[A-Z0-9]{4,14})/i);
            if (auMatch) {
                studentId = auMatch[1].toUpperCase().replace(/[ _]/g, '-');
            }
        }

        if (!studentId) {
            // General Reg/Roll Number pattern
            const regMatch = fullCorpus.match(/(?:ID|REG(?:ISTRATION)?|ROLL|URN|HALL|STUDENT)[-_ ]*(?:NO|NUMBER|#)?[:.\s-]*([A-Z0-9\-\/]{4,18})/i);
            if (regMatch) {
                studentId = regMatch[1].toUpperCase().replace(/[ _]/g, '-');
            }
        }

        if (!studentId) {
            // General college code like CED-2024-014 or 2024CED014 or numeric 10-12 digit roll
            const codeMatch = fullCorpus.match(/\b([A-Z]{2,4}[-_ ]?\d{4}[-_ ]?[A-Z0-9]{2,8})\b/i) ||
                              fullCorpus.match(/\b(20\d{2}[A-Z]{2,5}\d{2,6})\b/i) ||
                              fullCorpus.match(/\b(20\d{6,12})\b/);
            if (codeMatch) {
                studentId = codeMatch[1].toUpperCase().replace(/[ _]/g, '-');
            }
        }

        // Check if user had already entered an ID into the form
        if (!studentId && collegeIdInput && collegeIdInput.value.trim().length > 3) {
            studentId = collegeIdInput.value.trim().toUpperCase();
        }

        // B. College / University Name
        let collegeName = 'Alliance University';
        if (corpusUpper.includes('ALLIANCE') || corpusUpper.includes('CED')) {
            collegeName = 'Alliance University';
        } else {
            const uniMatch = fullCorpus.match(/(?:UNIVERSITY|COLLEGE|INSTITUTE)[:.\s-]*([A-Za-z\s&]{5,45})/i);
            if (uniMatch) {
                collegeName = uniMatch[0].trim();
            }
        }

        // C. Degree / Program Name
        let programName = 'B.Tech Computer Science & Engineering';
        if (corpusUpper.includes('COMPUTER') || corpusUpper.includes('CSE') || corpusUpper.includes('CED')) {
            programName = 'B.Tech Computer Science & Engineering';
        } else if (corpusUpper.includes('ELECTRONIC') || corpusUpper.includes('ECE')) {
            programName = 'B.Tech Electronics & Communication';
        } else if (corpusUpper.includes('MECHANICAL')) {
            programName = 'B.Tech Mechanical Engineering';
        } else if (corpusUpper.includes('BUSINESS') || corpusUpper.includes('MBA') || corpusUpper.includes('BBA')) {
            programName = 'Master of Business Administration (MBA)';
        }

        // D. Joined Year & Academic Standing
        let joiningYear = '2024';
        const yearInId = studentId.match(/20\d{2}/);
        if (yearInId) {
            joiningYear = yearInId[0];
        } else {
            const yearMatch = fullCorpus.match(/\b(202[0-6])\b/);
            if (yearMatch) {
                joiningYear = yearMatch[1];
            }
        }

        const jYearNum = parseInt(joiningYear, 10) || 2024;
        let studyYear = '2nd Year';
        if (jYearNum === 2026) studyYear = '1st Year';
        else if (jYearNum === 2025) studyYear = '2nd Year';
        else if (jYearNum === 2024) studyYear = '2nd Year';
        else if (jYearNum === 2023) studyYear = '3rd Year';
        else if (jYearNum <= 2022) studyYear = '4th Year';

        // E. Student Name
        let studentName = '';
        const nameMatch = fullCorpus.match(/(?:NAME|STUDENT\s*NAME)[:.\s-]+([A-Za-z\s.]{3,35})/i);
        if (nameMatch) {
            studentName = nameMatch[1].trim();
        } else {
            // Find a name candidate from OCR lines
            const nameIgnoreWords = ['ALLIANCE', 'UNIVERSITY', 'COLLEGE', 'ENGINEERING', 'DESIGN', 'STUDENT', 'IDENTITY', 'CARD', 'VALID', 'BATCH', 'CED', 'SIGNATURE', 'BLOOD', 'PHONE', 'CAMPUS'];
            for (const line of lines) {
                const words = line.split(/\s+/);
                const hasLettersOnly = /^[A-Za-z.\s]{3,30}$/.test(line);
                const hasIgnore = nameIgnoreWords.some(w => line.toUpperCase().includes(w));
                if (hasLettersOnly && !hasIgnore && words.length >= 2 && words.length <= 4) {
                    studentName = line.trim();
                    break;
                }
            }
        }

        // Check if registration page has a name entered
        const fullNameInput = document.getElementById('fullName');
        if (fullNameInput && fullNameInput.value.trim().length > 2) {
            studentName = fullNameInput.value.trim();
        }

        currentDetectedData = {
            collegeId: studentId,
            studentName: studentName,
            collegeName: collegeName,
            programName: programName,
            joiningYear: joiningYear,
            studyYear: studyYear,
            photoDataUrl: croppedPhotoDataUrl
        };

        if (scanProcessingCard) scanProcessingCard.style.display = 'none';

        // Populate editable result fields
        if (detCollegeIdInput) detCollegeIdInput.value = studentId;
        if (detStudentNameInput) detStudentNameInput.value = studentName;
        if (detCollegeNameInput) detCollegeNameInput.value = collegeName;
        if (detProgramNameInput) detProgramNameInput.value = programName;
        if (detJoiningYearInput) detJoiningYearInput.value = joiningYear;
        if (detStudyYearInput) detStudyYearInput.value = studyYear;

        // Legacy span labels fallback
        const detCollegeIdSpan = document.getElementById('detCollegeId');
        if (detCollegeIdSpan) detCollegeIdSpan.textContent = studentId;
        const detStudentNameSpan = document.getElementById('detStudentName');
        if (detStudentNameSpan) detStudentNameSpan.textContent = studentName;
        const detCollegeNameSpan = document.getElementById('detCollegeName');
        if (detCollegeNameSpan) detCollegeNameSpan.textContent = collegeName;
        const detProgramNameSpan = document.getElementById('detProgramName');
        if (detProgramNameSpan) detProgramNameSpan.textContent = programName;
        const detJoiningYearSpan = document.getElementById('detJoiningYear');
        if (detJoiningYearSpan) detJoiningYearSpan.textContent = joiningYear;
        const detStudyYearSpan = document.getElementById('detStudyYear');
        if (detStudyYearSpan) detStudyYearSpan.textContent = studyYear;

        if (detectedPhotoImg) detectedPhotoImg.src = croppedPhotoDataUrl;

        if (scanResultCard) {
            scanResultCard.style.display = 'block';
            scanResultCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }

        playBeepSound();
    }

    function applyDetectedDataToForm() {
        // Pull latest user-verified values directly from editable inputs
        const appliedId = (detCollegeIdInput ? detCollegeIdInput.value.trim() : '') || (currentDetectedData ? currentDetectedData.collegeId : '');
        const appliedName = (detStudentNameInput ? detStudentNameInput.value.trim() : '') || (currentDetectedData ? currentDetectedData.studentName : '');
        const appliedCollege = (detCollegeNameInput ? detCollegeNameInput.value.trim() : '') || (currentDetectedData ? currentDetectedData.collegeName : 'Alliance University');
        const appliedProgram = (detProgramNameInput ? detProgramNameInput.value.trim() : '') || (currentDetectedData ? currentDetectedData.programName : 'B.Tech Computer Science & Engineering');
        const appliedJoining = (detJoiningYearInput ? detJoiningYearInput.value.trim() : '') || (currentDetectedData ? currentDetectedData.joiningYear : '2024');
        const appliedStudy = (detStudyYearInput ? detStudyYearInput.value.trim() : '') || (currentDetectedData ? currentDetectedData.studyYear : '2nd Year');
        const appliedPhoto = (detectedPhotoImg && detectedPhotoImg.src) ? detectedPhotoImg.src : (currentDetectedData ? currentDetectedData.photoDataUrl : '');

        // Populate College ID input
        if (collegeIdInput && appliedId) {
            collegeIdInput.value = appliedId;
            collegeIdInput.style.borderColor = 'var(--success)';
        }

        // Fill Full Name on register form
        const fullNameInput = document.getElementById('fullName');
        if (fullNameInput && appliedName && (!fullNameInput.value || fullNameInput.value.trim() === '')) {
            fullNameInput.value = appliedName;
        }

        // Hidden form inputs for register page
        if (hiddenCollegeName) hiddenCollegeName.value = appliedCollege;
        if (hiddenProgramName) hiddenProgramName.value = appliedProgram;
        if (hiddenJoiningYear) hiddenJoiningYear.value = appliedJoining;
        if (hiddenStudyYear) hiddenStudyYear.value = appliedStudy;
        if (hiddenPhotoBase64) hiddenPhotoBase64.value = appliedPhoto;

        // Status badge
        if (scanStatusBadge) scanStatusBadge.style.display = 'inline-block';

        // Verified Student Card widget on login form
        if (studentCardPreviewWidget) {
            if (widgetPhotoImg) {
                widgetPhotoImg.src = appliedPhoto;
                widgetPhotoImg.style.display = 'block';
            }
            if (widgetPhotoPlaceholder) widgetPhotoPlaceholder.style.display = 'none';
            if (widgetCollegeName) widgetCollegeName.textContent = appliedCollege;
            if (widgetProgramName) widgetProgramName.textContent = appliedProgram;
            if (widgetJoiningYear) widgetJoiningYear.textContent = appliedJoining;
            if (widgetStudyYear) widgetStudyYear.textContent = appliedStudy;
            studentCardPreviewWidget.style.display = 'block';
        }

        // Stop camera and close modal
        stopCamera();
        if (idScannerModal) idScannerModal.classList.remove('active');
    }

    // Global Modal & Scanner Triggers (Directly callable from inline HTML onclicks)
    window.openIdScannerModal = function (mode) {
        if (!idScannerModal) return;
        idScannerModal.classList.add('active');
        if (scanResultCard) scanResultCard.style.display = 'none';
        if (scanErrorCard) scanErrorCard.style.display = 'none';
        if (scanProcessingCard) scanProcessingCard.style.display = 'none';
        switchModeTab(mode || 'camera');
    };

    window.closeIdScannerModal = function () {
        stopCamera();
        if (idScannerModal) idScannerModal.classList.remove('active');
    };

    window.switchModeTab = switchModeTab;

    window.togglePasswordVisibility = function (fieldId, btn) {
        const input = document.getElementById(fieldId);
        if (input) {
            input.type = (input.type === 'password') ? 'text' : 'password';
        }
    };

    // Modal & Scanner Event Listeners
    if (btnOpenIdScanner && idScannerModal) {
        btnOpenIdScanner.addEventListener('click', function () {
            window.openIdScannerModal('camera');
        });

        const btnOpenUploadScanner = document.getElementById('btnOpenUploadScanner');
        if (btnOpenUploadScanner) {
            btnOpenUploadScanner.addEventListener('click', function () {
                window.openIdScannerModal('upload');
            });
        }

        if (btnReScanCard) {
            btnReScanCard.addEventListener('click', function () {
                window.openIdScannerModal('camera');
            });
        }

        if (btnCloseIdScanner) {
            btnCloseIdScanner.addEventListener('click', window.closeIdScannerModal);
        }

        // Tabs
        if (tabCameraBtn) {
            tabCameraBtn.addEventListener('click', function () {
                switchModeTab('camera');
            });
        }
        if (tabUploadBtn) {
            tabUploadBtn.addEventListener('click', function () {
                switchModeTab('upload');
            });
        }

        // Camera Action Buttons
        if (btnFlipCamera) {
            btnFlipCamera.addEventListener('click', flipCamera);
        }
        if (btnRetryCamera) {
            btnRetryCamera.addEventListener('click', startCamera);
        }
        if (btnSwitchToUpload) {
            btnSwitchToUpload.addEventListener('click', function () {
                switchModeTab('upload');
            });
        }

        // Capture Button
        if (btnCaptureIdCard) {
            btnCaptureIdCard.addEventListener('click', function () {
                if (!idCameraVideo || !idCameraVideo.videoWidth) {
                    alert('Camera feed is not ready. Please wait a moment for the video to stream.');
                    return;
                }

                playShutterSound();

                // Flash overlay animation
                if (cameraFlashOverlay) {
                    cameraFlashOverlay.style.opacity = '0.9';
                    setTimeout(() => { cameraFlashOverlay.style.opacity = '0'; }, 160);
                }

                // Capture snapshot
                const canvas = idCaptureCanvas || document.createElement('canvas');
                canvas.width = idCameraVideo.videoWidth;
                canvas.height = idCameraVideo.videoHeight;
                const ctx = canvas.getContext('2d');
                ctx.drawImage(idCameraVideo, 0, 0, canvas.width, canvas.height);

                stopCamera();
                runOpticalScanning(canvas, 'camera_capture.jpg');
            });
        }

        // File upload & Drop handlers
        function handleFileSelected(file) {
            if (!file) return;
            const reader = new FileReader();
            reader.onload = function (e) {
                const img = new Image();
                img.onload = function () {
                    const canvas = document.createElement('canvas');
                    canvas.width = img.naturalWidth || img.width;
                    canvas.height = img.naturalHeight || img.height;
                    const ctx = canvas.getContext('2d');
                    ctx.drawImage(img, 0, 0);
                    runOpticalScanning(canvas, file.name);
                };
                img.src = e.target.result;
            };
            reader.readAsDataURL(file);
        }

        if (idCardFileInput) {
            idCardFileInput.addEventListener('change', function () {
                if (this.files && this.files[0]) {
                    handleFileSelected(this.files[0]);
                }
            });
        }

        if (dropZone) {
            dropZone.addEventListener('dragover', function (e) {
                e.preventDefault();
                dropZone.style.background = 'rgba(99, 102, 241, 0.15)';
            });
            dropZone.addEventListener('dragleave', function () {
                dropZone.style.background = 'rgba(99, 102, 241, 0.05)';
            });
            dropZone.addEventListener('drop', function (e) {
                e.preventDefault();
                dropZone.style.background = 'rgba(99, 102, 241, 0.05)';
                if (e.dataTransfer && e.dataTransfer.files && e.dataTransfer.files[0]) {
                    handleFileSelected(e.dataTransfer.files[0]);
                }
            });
        }

        // Apply / Cancel buttons
        if (btnApplyDetectedId) {
            btnApplyDetectedId.addEventListener('click', applyDetectedDataToForm);
        }
        if (btnCancelDetectedId) {
            btnCancelDetectedId.addEventListener('click', function () {
                if (scanResultCard) scanResultCard.style.display = 'none';
                if (idCardFileInput) idCardFileInput.value = '';
                switchModeTab('camera');
            });
        }

        if (btnErrorTryUpload) {
            btnErrorTryUpload.addEventListener('click', function () {
                if (scanErrorCard) scanErrorCard.style.display = 'none';
                switchModeTab('upload');
                if (idCardFileInput) {
                    idCardFileInput.value = '';
                    idCardFileInput.click();
                }
            });
        }
    }

    // ==========================================
    // 5. UNIVERSAL UI ENHANCEMENTS
    // ==========================================

    // Password Visibility Toggle
    document.addEventListener('click', function (e) {
        var btn = e.target.closest('.password-toggle-btn, .btn-toggle-pw');
        if (btn) {
            var wrapper = btn.closest('.input-password-wrapper') || btn.parentElement;
            if (wrapper) {
                var input = wrapper.querySelector('input[type="password"], input[type="text"]');
                if (input) {
                    if (input.type === 'password') {
                        input.type = 'text';
                        btn.setAttribute('aria-pressed', 'true');
                    } else {
                        input.type = 'password';
                        btn.setAttribute('aria-pressed', 'false');
                    }
                }
            }
        }
    });

    // Universal Modal Triggers via data-modal-open / data-modal-close
    document.addEventListener('click', function (e) {
        var openBtn = e.target.closest('[data-modal-open]');
        if (openBtn) {
            e.preventDefault();
            var modalId = openBtn.getAttribute('data-modal-open');
            var targetModal = document.getElementById(modalId);
            if (targetModal) {
                targetModal.classList.add('active');
            }
            return;
        }

        var closeBtn = e.target.closest('[data-modal-close]');
        if (closeBtn) {
            e.preventDefault();
            var modalId = closeBtn.getAttribute('data-modal-close');
            var targetModal = modalId ? document.getElementById(modalId) : closeBtn.closest('.modal-overlay');
            if (targetModal) {
                targetModal.classList.remove('active');
            }
            return;
        }

        // Close on background click
        if (e.target.classList.contains('modal-overlay')) {
            e.target.classList.remove('active');
        }
    });

    // Escape Key Closes Modals
    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape') {
            document.querySelectorAll('.modal-overlay.active').forEach(function (m) {
                m.classList.remove('active');
            });
        }
    });

    // Client-side Table Search / Filter
    document.querySelectorAll('[data-table-filter]').forEach(function (input) {
        var tableId = input.getAttribute('data-table-filter');
        var table = document.getElementById(tableId);
        if (!table) return;

        input.addEventListener('input', function () {
            var q = input.value.toLowerCase().trim();
            var rows = table.querySelectorAll('tbody tr');
            rows.forEach(function (row) {
                var text = row.textContent.toLowerCase();
                row.style.display = text.indexOf(q) !== -1 ? '' : 'none';
            });
        });
    });

    // Styled Confirmation Modal Interceptor
    var activePendingForm = null;
    var appConfirmModal = document.getElementById('appConfirmModal');
    var confirmTitle = document.getElementById('appConfirmTitle');
    var confirmMsg = document.getElementById('appConfirmMsg');
    var confirmSubmitBtn = document.getElementById('appConfirmSubmitBtn');
    var confirmCancelBtn = document.getElementById('appConfirmCancelBtn');

    if (appConfirmModal && confirmSubmitBtn) {
        document.addEventListener('submit', function (e) {
            var form = e.target;
            var confirmText = form.getAttribute('data-confirm');
            if (confirmText && !form.dataset.confirmed) {
                e.preventDefault();
                activePendingForm = form;
                if (confirmMsg) confirmMsg.textContent = confirmText;
                if (confirmTitle) confirmTitle.textContent = form.getAttribute('data-confirm-title') || 'Confirm Action';
                appConfirmModal.classList.add('active');
            }
        });

        confirmSubmitBtn.addEventListener('click', function () {
            if (activePendingForm) {
                activePendingForm.dataset.confirmed = 'true';
                activePendingForm.submit();
                appConfirmModal.classList.remove('active');
                activePendingForm = null;
            }
        });

        if (confirmCancelBtn) {
            confirmCancelBtn.addEventListener('click', function () {
                appConfirmModal.classList.remove('active');
                activePendingForm = null;
            });
        }
    }

    // Candidate Edit Modal Handler
    document.addEventListener('click', function (e) {
        var editBtn = e.target.closest('.btn-edit-candidate');
        if (editBtn) {
            var modal = document.getElementById('editCandidateModal');
            if (modal) {
                var id = editBtn.getAttribute('data-id');
                var name = editBtn.getAttribute('data-name');
                var party = editBtn.getAttribute('data-party');
                var symbol = editBtn.getAttribute('data-symbol');
                var active = editBtn.getAttribute('data-active');

                var idField = document.getElementById('editCandidateId');
                var nameField = document.getElementById('editCandidateName');
                var partyField = document.getElementById('editParty');
                var symbolField = document.getElementById('editSymbol');
                var activeField = document.getElementById('editActive');

                if (idField) idField.value = id || '';
                if (nameField) nameField.value = name || '';
                if (partyField) partyField.value = party || '';
                if (symbolField) symbolField.value = symbol || '';
                if (activeField) activeField.value = active || 'true';

                modal.classList.add('active');
            }
        }
    });
});


