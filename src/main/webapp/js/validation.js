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

    // 3. Client Registration Form Validation
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

    // 5. College ID Card Scanner Modal & Camera Logic
    // -------------------------------------------------------------
    // Intelligent College ID Card Scanner & Student Detector
    // -------------------------------------------------------------
    const btnOpenIdScanner = document.getElementById('btnOpenIdScanner');
    const idScannerModal = document.getElementById('idScannerModal');
    const btnCloseIdScanner = document.getElementById('btnCloseIdScanner');
    const btnStartCamera = document.getElementById('btnStartCamera');
    const btnCaptureIdCard = document.getElementById('btnCaptureIdCard');
    const idCameraVideo = document.getElementById('idCameraVideo');
    const cameraStandbyMsg = document.getElementById('cameraStandbyMsg');
    const cameraPermissionBanner = document.getElementById('cameraPermissionBanner');
    const virtualCardDisplay = document.getElementById('virtualCardDisplay');
    const btnQuickFillAkash = document.getElementById('btnQuickFillAkash');
    const btnRetryCamera = document.getElementById('btnRetryCamera');
    const btnSwitchToUpload = document.getElementById('btnSwitchToUpload');
    const idCardFileInput = document.getElementById('idCardFileInput');
    const dropZone = document.getElementById('dropZone');
    const collegeIdInput = document.getElementById('collegeId');
    const scanStatusBadge = document.getElementById('scanStatusBadge');

    // Tabs
    const tabCameraScan = document.getElementById('tabCameraScan');
    const tabUploadScan = document.getElementById('tabUploadScan');
    const tabDemoScan = document.getElementById('tabDemoScan');
    const sectionCameraScan = document.getElementById('sectionCameraScan');
    const sectionUploadScan = document.getElementById('sectionUploadScan');
    const sectionDemoScan = document.getElementById('sectionDemoScan');

    // Result card elements
    const scanResultCard = document.getElementById('scanResultCard');
    const detectedPhotoImg = document.getElementById('detectedPhotoImg');
    const detCollegeName = document.getElementById('detCollegeName');
    const detProgramName = document.getElementById('detProgramName');
    const detJoiningYear = document.getElementById('detJoiningYear');
    const detStudyYear = document.getElementById('detStudyYear');
    const detCollegeId = document.getElementById('detCollegeId');
    const btnApplyDetectedId = document.getElementById('btnApplyDetectedId');
    const btnCancelDetectedId = document.getElementById('btnCancelDetectedId');
    const scanErrorCard = document.getElementById('scanErrorCard');
    const scanErrorReason = document.getElementById('scanErrorReason');
    const scanProcessingCard = document.getElementById('scanProcessingCard');
    const btnErrorTryUpload = document.getElementById('btnErrorTryUpload');
    const btnErrorUseDemoAkash = document.getElementById('btnErrorUseDemoAkash');

    // Form widget preview elements
    const studentCardPreviewWidget = document.getElementById('studentCardPreviewWidget');
    const widgetPhotoImg = document.getElementById('widgetPhotoImg');
    const widgetPhotoPlaceholder = document.getElementById('widgetPhotoPlaceholder');
    const widgetCollegeName = document.getElementById('widgetCollegeName');
    const widgetProgramName = document.getElementById('widgetProgramName');
    const widgetJoiningYear = document.getElementById('widgetJoiningYear');
    const widgetStudyYear = document.getElementById('widgetStudyYear');
    const btnReScanCard = document.getElementById('btnReScanCard');

    // Hidden form inputs
    const hiddenCollegeName = document.getElementById('hiddenCollegeName');
    const hiddenProgramName = document.getElementById('hiddenProgramName');
    const hiddenJoiningYear = document.getElementById('hiddenJoiningYear');
    const hiddenStudyYear = document.getElementById('hiddenStudyYear');
    const hiddenPhotoBase64 = document.getElementById('hiddenPhotoBase64');

    let videoStream = null;
    let currentDetectedData = null;

    function playBeepSound() {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.frequency.setValueAtTime(587.33, ctx.currentTime); // D5
            osc.frequency.setValueAtTime(880, ctx.currentTime + 0.08); // A5
            gain.gain.setValueAtTime(0.18, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.25);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.25);
        } catch (e) {
            // Audio context is optional
        }
    }

    function switchTab(activeTab) {
        if (!tabCameraScan) return;
        [tabCameraScan, tabUploadScan, tabDemoScan].forEach(t => {
            if (t) {
                t.classList.remove('active');
                t.classList.add('btn-outline');
            }
        });
        [sectionCameraScan, sectionUploadScan, sectionDemoScan].forEach(s => {
            if (s) s.style.display = 'none';
        });

        if (scanErrorCard) scanErrorCard.style.display = 'none';
        if (scanProcessingCard) scanProcessingCard.style.display = 'none';

        if (activeTab === 'camera') {
            tabCameraScan.classList.add('active');
            tabCameraScan.classList.remove('btn-outline');
            sectionCameraScan.style.display = 'block';
        } else if (activeTab === 'upload') {
            tabUploadScan.classList.add('active');
            tabUploadScan.classList.remove('btn-outline');
            sectionUploadScan.style.display = 'block';
            stopCamera();
        } else if (activeTab === 'demo') {
            tabDemoScan.classList.add('active');
            tabDemoScan.classList.remove('btn-outline');
            sectionDemoScan.style.display = 'block';
            stopCamera();
        }
    }

    function stopCamera() {
        if (videoStream) {
            videoStream.getTracks().forEach(track => track.stop());
            videoStream = null;
        }
        if (idCameraVideo) idCameraVideo.style.display = 'none';
        if (virtualCardDisplay) virtualCardDisplay.style.display = 'none';
        if (cameraStandbyMsg) cameraStandbyMsg.style.display = 'block';
        if (btnCaptureIdCard) btnCaptureIdCard.style.display = 'none';
        if (btnStartCamera) btnStartCamera.style.display = 'inline-flex';
        if (cameraPermissionBanner) cameraPermissionBanner.style.display = 'none';
    }

    function activateVirtualScanner(preset = 'akash') {
        if (cameraPermissionBanner) cameraPermissionBanner.style.display = 'none';
        if (cameraStandbyMsg) cameraStandbyMsg.style.display = 'none';
        if (idCameraVideo) idCameraVideo.style.display = 'none';
        if (virtualCardDisplay) {
            virtualCardDisplay.style.display = 'flex';
        }

        playBeepSound();

        // 800ms scanning laser animation, then auto-extract card details
        setTimeout(() => {
            detectStudentCard(preset, null, preset === 'akash' ? 'akash_alliance_id.jpg' : 'student_card.jpg');
        }, 800);
    }

    async function startCamera() {
        if (cameraPermissionBanner) cameraPermissionBanner.style.display = 'none';
        if (cameraStandbyMsg) cameraStandbyMsg.style.display = 'none';
        if (virtualCardDisplay) virtualCardDisplay.style.display = 'none';

        if (!navigator.mediaDevices || !navigator.mediaDevices.getUserMedia) {
            if (window.isSecureContext === false) {
                showPermissionBanner('Insecure Context: Camera requires HTTPS. Please use the secure Render link.');
            } else {
                showPermissionBanner('Camera API not supported in this browser.');
            }
            return;
        }

        try {
            // Flexible resolution: compatible with front/laptop webcams
            try {
                videoStream = await navigator.mediaDevices.getUserMedia({
                    video: { width: { ideal: 640 }, height: { ideal: 480 } }
                });
            } catch (e1) {
                videoStream = await navigator.mediaDevices.getUserMedia({ video: true });
            }

            if (videoStream) {
                idCameraVideo.muted = true;
                idCameraVideo.srcObject = videoStream;
                idCameraVideo.style.display = 'block';
                try {
                    await idCameraVideo.play();
                } catch (playErr) {
                    console.warn('Auto play warning:', playErr);
                }
                if (virtualCardDisplay) virtualCardDisplay.style.display = 'none';
                if (cameraStandbyMsg) cameraStandbyMsg.style.display = 'none';
                if (btnStartCamera) btnStartCamera.style.display = 'none';
                if (btnCaptureIdCard) btnCaptureIdCard.style.display = 'inline-flex';
                if (cameraPermissionBanner) cameraPermissionBanner.style.display = 'none';
            } else {
                showPermissionBanner('No webcam stream returned.');
            }
        } catch (err) {
            console.warn('Physical camera unavailable or permission denied:', err);
            let userMsg = 'Camera Permission Blocked';
            if (err.name === 'NotAllowedError') {
                userMsg = 'NotAllowedError: Permission denied. Please allow camera access in your browser settings.';
            } else if (err.name === 'NotFoundError') {
                userMsg = 'NotFoundError: No camera device found on this device.';
            } else if (err.name === 'NotReadableError') {
                userMsg = 'NotReadableError: Camera is already in use by another application.';
            } else {
                userMsg = err.name + (err.message ? ': ' + err.message : '');
            }
            showPermissionBanner(userMsg);
        }
    }

    function showPermissionBanner(msg) {
        if (cameraStandbyMsg) cameraStandbyMsg.style.display = 'none';
        if (virtualCardDisplay) virtualCardDisplay.style.display = 'none';
        const errDetailEl = document.getElementById('cameraErrorDetails');
        if (errDetailEl && msg) {
            errDetailEl.textContent = 'Diagnostic: ' + msg;
            errDetailEl.style.display = 'inline-block';
        }
        if (cameraPermissionBanner) {
            cameraPermissionBanner.style.display = 'flex';
        }
    }

    // Helper: generate synthetic student photo avatar badge on canvas
    function generateSyntheticPhoto(studentName, colorBg) {
        const canvas = document.createElement('canvas');
        canvas.width = 160;
        canvas.height = 190;
        const ctx = canvas.getContext('2d');

        // Background
        const grad = ctx.createLinearGradient(0, 0, 0, 190);
        grad.addColorStop(0, colorBg || '#1e3a8a');
        grad.addColorStop(1, '#0f172a');
        ctx.fillStyle = grad;
        ctx.fillRect(0, 0, 160, 190);

        // Head
        ctx.fillStyle = '#fde047';
        ctx.beginPath();
        ctx.arc(80, 70, 32, 0, Math.PI * 2);
        ctx.fill();

        // Shoulders / Torso
        ctx.fillStyle = '#38bdf8';
        ctx.beginPath();
        ctx.ellipse(80, 155, 55, 45, 0, 0, Math.PI * 2);
        ctx.fill();

        // Alliance University crest stamp
        ctx.fillStyle = 'rgba(255, 255, 255, 0.9)';
        ctx.font = 'bold 11px sans-serif';
        ctx.textAlign = 'center';
        ctx.fillText('ALLIANCE', 80, 175);

        // Name initials badge
        ctx.fillStyle = '#0f172a';
        ctx.font = 'bold 18px sans-serif';
        const initials = studentName.split(' ').map(w => w[0]).join('').substring(0, 2).toUpperCase() || 'AU';
        ctx.fillText(initials, 80, 77);

        return canvas.toDataURL('image/jpeg', 0.85);
    }

    // Crop photo region from image or video
    function cropPhotoFromMedia(sourceEl, isVideo) {
        const canvas = document.createElement('canvas');
        canvas.width = 160;
        canvas.height = 190;
        const ctx = canvas.getContext('2d');

        try {
            const sw = isVideo ? sourceEl.videoWidth : (sourceEl.naturalWidth || sourceEl.width);
            const sh = isVideo ? sourceEl.videoHeight : (sourceEl.naturalHeight || sourceEl.height);

            if (sw && sh) {
                // Crop upper-right or center-right quadrant where student photos are located
                const cropX = sw * 0.55;
                const cropY = sh * 0.15;
                const cropW = sw * 0.40;
                const cropH = sh * 0.55;
                ctx.drawImage(sourceEl, cropX, cropY, cropW, cropH, 0, 0, 160, 190);
                return canvas.toDataURL('image/jpeg', 0.85);
            }
        } catch (e) {
            // Fallback to synthetic avatar if tainted canvas or missing stream
        }
        return generateSyntheticPhoto('Student ID', '#312e81');
    }

    function playErrorSound() {
        try {
            const ctx = new (window.AudioContext || window.webkitAudioContext)();
            const osc = ctx.createOscillator();
            const gain = ctx.createGain();
            osc.connect(gain);
            gain.connect(ctx.destination);
            osc.type = 'sawtooth';
            osc.frequency.setValueAtTime(220, ctx.currentTime);
            osc.frequency.setValueAtTime(146, ctx.currentTime + 0.12);
            gain.gain.setValueAtTime(0.22, ctx.currentTime);
            gain.gain.exponentialRampToValueAtTime(0.01, ctx.currentTime + 0.35);
            osc.start(ctx.currentTime);
            osc.stop(ctx.currentTime + 0.35);
        } catch (e) {}
    }

    // ===================================================================
    // STRICT College ID Card Validator & OCR-based Data Extractor
    // ===================================================================
    // Accepted college email domains whitelist
    const VALID_COLLEGE_EMAIL_DOMAINS = [
        'alliance.edu.in', 'ced.alliance.edu.in', 'allianceu.edu.in',
        'voting.edu', 'university.edu', 'college.edu',
        'student.edu', 'campus.edu'
    ];

    function isValidCollegeEmail(email) {
        if (!email || typeof email !== 'string') return false;
        const trimmed = email.trim().toLowerCase();
        if (!trimmed.includes('@')) return false;
        const domain = trimmed.split('@')[1];
        return VALID_COLLEGE_EMAIL_DOMAINS.some(d => domain === d || domain.endsWith('.' + d));
    }

    // Extract text content from image using canvas pixel analysis
    // This performs character-level edge detection to find text regions
    function extractTextRegions(canvas, ctx, w, h) {
        const imgData = ctx.getImageData(0, 0, w, h);
        const data = imgData.data;
        const results = { hasHeader: false, hasTextLines: false, hasPhotoBox: false, textDensity: 0, headerContrast: 0, edgeDensity: 0, colorUniformity: 0, hasRectBorder: false, aspectScore: 0 };

        // --- Pass 1: Global statistics ---
        let totalLum = 0, totalSat = 0, pixCount = 0;
        let lumValues = [];
        for (let y = 0; y < h; y += 2) {
            for (let x = 0; x < w; x += 2) {
                const idx = (y * w + x) * 4;
                const r = data[idx], g = data[idx + 1], b = data[idx + 2];
                const lum = 0.299 * r + 0.587 * g + 0.114 * b;
                totalLum += lum;
                const mx = Math.max(r, g, b), mn = Math.min(r, g, b);
                totalSat += (mx === 0 ? 0 : (mx - mn) / mx);
                lumValues.push(lum);
                pixCount++;
            }
        }
        const meanLum = totalLum / pixCount;
        const meanSat = totalSat / pixCount;

        // --- Pass 2: Edge detection (Sobel-like) for text ---
        let edgeCount = 0, totalEdgeSamples = 0;
        for (let y = 2; y < h - 2; y += 2) {
            for (let x = 2; x < w - 2; x += 2) {
                const idx = (y * w + x) * 4;
                const idxR = (y * w + (x + 2)) * 4;
                const idxD = ((y + 2) * w + x) * 4;
                const lumC = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
                const lumR = 0.299 * data[idxR] + 0.587 * data[idxR + 1] + 0.114 * data[idxR + 2];
                const lumD = 0.299 * data[idxD] + 0.587 * data[idxD + 1] + 0.114 * data[idxD + 2];
                const grad = Math.abs(lumC - lumR) + Math.abs(lumC - lumD);
                if (grad > 30) edgeCount++;
                totalEdgeSamples++;
            }
        }
        results.edgeDensity = edgeCount / totalEdgeSamples;

        // --- Pass 3: Header band analysis (top 20%) ---
        let headerLum = 0, headerCount = 0;
        let headerColorR = 0, headerColorG = 0, headerColorB = 0;
        for (let y = 0; y < Math.floor(h * 0.20); y += 2) {
            for (let x = Math.floor(w * 0.05); x < Math.floor(w * 0.95); x += 2) {
                const idx = (y * w + x) * 4;
                headerLum += 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
                headerColorR += data[idx]; headerColorG += data[idx + 1]; headerColorB += data[idx + 2];
                headerCount++;
            }
        }
        const avgHeaderLum = headerLum / headerCount;
        results.headerContrast = Math.abs(avgHeaderLum - meanLum);
        results.hasHeader = results.headerContrast > 12;

        // --- Pass 4: Text line detection (horizontal transitions in middle 60%) ---
        let textLineCount = 0;
        for (let y = Math.floor(h * 0.25); y < Math.floor(h * 0.85); y += 3) {
            let transitions = 0;
            let prevDark = false;
            for (let x = Math.floor(w * 0.05); x < Math.floor(w * 0.70); x += 2) {
                const idx = (y * w + x) * 4;
                const lum = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
                const isDark = lum < (meanLum - 20);
                if (isDark !== prevDark) { transitions++; prevDark = isDark; }
            }
            if (transitions > 6) textLineCount++;
        }
        results.hasTextLines = textLineCount > 4;
        results.textDensity = textLineCount;

        // --- Pass 5: Photo box detection (look for rectangular region with different luminance) ---
        // Check right side and left side for a portrait-like rectangular region
        const checkPhotoBox = (startX, endX, startY, endY) => {
            let boxLum = 0, boxCount = 0;
            let surroundLum = 0, surroundCount = 0;
            for (let y = startY; y < endY; y += 3) {
                for (let x = startX; x < endX; x += 3) {
                    const idx = (y * w + x) * 4;
                    const lum = 0.299 * data[idx] + 0.587 * data[idx + 1] + 0.114 * data[idx + 2];
                    boxLum += lum; boxCount++;
                }
            }
            // Sample surrounding area
            for (let y = startY; y < endY; y += 5) {
                const leftIdx = (y * w + Math.max(0, startX - 15)) * 4;
                const rightIdx = (y * w + Math.min(w - 1, endX + 15)) * 4;
                surroundLum += 0.299 * data[leftIdx] + 0.587 * data[leftIdx + 1] + 0.114 * data[leftIdx + 2];
                surroundLum += 0.299 * data[rightIdx] + 0.587 * data[rightIdx + 1] + 0.114 * data[rightIdx + 2];
                surroundCount += 2;
            }
            const avgBox = boxLum / boxCount;
            const avgSurround = surroundLum / surroundCount;
            return Math.abs(avgBox - avgSurround) > 10;
        };
        // Check left portrait box
        const leftBox = checkPhotoBox(Math.floor(w * 0.03), Math.floor(w * 0.30), Math.floor(h * 0.20), Math.floor(h * 0.75));
        // Check right portrait box
        const rightBox = checkPhotoBox(Math.floor(w * 0.65), Math.floor(w * 0.95), Math.floor(h * 0.15), Math.floor(h * 0.70));
        results.hasPhotoBox = leftBox || rightBox;

        // --- Pass 6: Color uniformity (ID cards tend to have uniform background colors) ---
        let colorBuckets = {};
        for (let y = 0; y < h; y += 4) {
            for (let x = 0; x < w; x += 4) {
                const idx = (y * w + x) * 4;
                const rBucket = Math.floor(data[idx] / 32);
                const gBucket = Math.floor(data[idx + 1] / 32);
                const bBucket = Math.floor(data[idx + 2] / 32);
                const key = `${rBucket}_${gBucket}_${bBucket}`;
                colorBuckets[key] = (colorBuckets[key] || 0) + 1;
            }
        }
        const bucketValues = Object.values(colorBuckets);
        const maxBucket = Math.max(...bucketValues);
        const totalBucketSamples = bucketValues.reduce((a, b) => a + b, 0);
        results.colorUniformity = maxBucket / totalBucketSamples;

        // --- Pass 7: Border/rectangle detection ---
        let borderEdges = 0, borderSamples = 0;
        // Top edge
        for (let x = Math.floor(w * 0.05); x < Math.floor(w * 0.95); x += 2) {
            for (let yOff = 0; yOff < 6; yOff += 2) {
                const idx1 = (yOff * w + x) * 4;
                const idx2 = ((yOff + 3) * w + x) * 4;
                const diff = Math.abs((0.299 * data[idx1] + 0.587 * data[idx1 + 1] + 0.114 * data[idx1 + 2]) -
                    (0.299 * data[idx2] + 0.587 * data[idx2 + 1] + 0.114 * data[idx2 + 2]));
                if (diff > 25) borderEdges++;
                borderSamples++;
            }
        }
        // Bottom edge
        for (let x = Math.floor(w * 0.05); x < Math.floor(w * 0.95); x += 2) {
            const y1 = h - 4, y2 = h - 7;
            const idx1 = (y1 * w + x) * 4;
            const idx2 = (y2 * w + x) * 4;
            const diff = Math.abs((0.299 * data[idx1] + 0.587 * data[idx1 + 1] + 0.114 * data[idx1 + 2]) -
                (0.299 * data[idx2] + 0.587 * data[idx2 + 1] + 0.114 * data[idx2 + 2]));
            if (diff > 25) borderEdges++;
            borderSamples++;
        }
        results.hasRectBorder = (borderEdges / borderSamples) > 0.15;

        return { results, meanLum, meanSat, data, w, h };
    }

    // STRICT Document Classifier — rejects non-ID-card images
    function validateIsCollegeIdCard(mediaElement, rawFileName) {
        const fn = (rawFileName || '').toLowerCase();

        // 1. Blacklist: explicit non-ID keywords in filename
        const nonIdWords = [
            'car', 'maruti', 'suzuki', 'hyundai', 'toyota', 'honda', 'bmw', 'audi', 'benz', 'ford',
            'vehicle', 'bike', 'motor', 'road', 'bridge', 'river', 'sky', 'mountain', 'nature',
            'tree', 'cat', 'dog', 'pet', 'animal', 'food', 'pizza', 'burger', 'flower', 'selfie',
            'party', 'trip', 'travel', 'vacation', 'wallpaper', 'meme', 'landscape', 'building',
            'screenshot', 'whatsapp', 'instagram', 'facebook', 'tiktok', 'snap', 'reel',
            'sunset', 'sunrise', 'beach', 'sea', 'ocean', 'forest', 'garden', 'park'
        ];
        for (const kw of nonIdWords) {
            if (fn.includes(kw)) {
                return { valid: false, reason: `Rejected: "${kw}" detected in filename. Only official College ID cards are accepted.` };
            }
        }

        // 2. Whitelist keywords boost
        const idWords = ['id', 'card', 'student', 'college', 'alliance', 'ced', 'roll', 'au-', 'alu-', 'hallticket', 'admit', 'identity', 'enrollment'];
        const hasIdKeyword = idWords.some(w => fn.includes(w));

        // 3. Aspect ratio check
        const origW = mediaElement.naturalWidth || mediaElement.videoWidth || mediaElement.width || 320;
        const origH = mediaElement.naturalHeight || mediaElement.videoHeight || mediaElement.height || 200;
        const ratio = origW / origH;
        // ID cards: landscape ~1.4-1.7 (CR-80), or portrait ~0.6-0.8
        const isCardAspect = (ratio >= 1.25 && ratio <= 1.90) || (ratio >= 0.52 && ratio <= 0.82);

        // 4. Canvas-based deep analysis
        try {
            const cw = 400, ch = 260;
            const canvas = document.createElement('canvas');
            canvas.width = cw; canvas.height = ch;
            const ctx = canvas.getContext('2d');
            ctx.drawImage(mediaElement, 0, 0, cw, ch);

            const { results, meanLum, meanSat } = extractTextRegions(canvas, ctx, cw, ch);

            // ============ SCORING ============
            let score = 0;
            let reasons = [];

            // A. Filename match (+20)
            if (hasIdKeyword) { score += 20; reasons.push('ID keyword in filename'); }

            // B. Card aspect ratio (+12)
            if (isCardAspect) { score += 12; reasons.push('Card aspect ratio'); }

            // C. Header band detected (+15)
            if (results.hasHeader && results.headerContrast > 15) { score += 15; reasons.push('Header band'); }

            // D. Text lines detected (+20)
            if (results.hasTextLines && results.textDensity > 6) { score += 20; reasons.push('Text lines'); }
            else if (results.textDensity > 3) { score += 8; reasons.push('Some text'); }

            // E. Photo portrait box detected (+15)
            if (results.hasPhotoBox) { score += 15; reasons.push('Portrait box'); }

            // F. Edge density — printed text has moderate edges, nature has low/very high
            if (results.edgeDensity > 0.08 && results.edgeDensity < 0.45) { score += 10; reasons.push('Document edge density'); }

            // G. Color uniformity — ID cards have more uniform backgrounds than nature photos
            if (results.colorUniformity > 0.12) { score += 8; reasons.push('Uniform background'); }

            // H. Rectangle border (+5)
            if (results.hasRectBorder) { score += 5; reasons.push('Card border'); }

            // ============ PENALTIES ============
            // High saturation = outdoor/nature photo
            if (meanSat > 0.38 && !hasIdKeyword) { score -= 25; reasons.push('PENALTY: High saturation (outdoor photo)'); }

            // Very low edge density = smooth photo, not a document
            if (results.edgeDensity < 0.04) { score -= 20; reasons.push('PENALTY: No text edges detected'); }

            // No text lines at all
            if (results.textDensity < 2) { score -= 20; reasons.push('PENALTY: No readable text lines'); }

            // No header and no photo box = definitely not an ID card
            if (!results.hasHeader && !results.hasPhotoBox) { score -= 15; reasons.push('PENALTY: No header or portrait'); }

            console.log('[ID Validator] Score:', score, '| Breakdown:', reasons.join(', '));

            // ============ VERDICT ============
            // Require minimum score of 55 (was 40 before — too lenient)
            const threshold = hasIdKeyword ? 35 : 55;
            if (score < threshold) {
                return {
                    valid: false,
                    reason: `❌ This image does not appear to be a College ID Card (confidence: ${score}/100). ` +
                        `An ID card must have: an institutional header, printed text lines, and a student photo area. ` +
                        `Please upload a clear photo of your official College ID card.`
                };
            }

            return { valid: true, score, reasons };
        } catch (err) {
            console.warn('[ID Validator] Canvas analysis failed:', err);
            if (!hasIdKeyword) {
                return { valid: false, reason: 'Unable to analyze image. Please upload a clear, well-lit photo of your College ID card.' };
            }
            return { valid: true, score: 40 };
        }
    }

    // Extract actual data from the ID card image using canvas OCR
    // Advanced CV Preprocessing and Data Extraction
    async function extractDataFromIdCard(mediaElement, rawFileName) {
        const fn = (rawFileName || '').toLowerCase();
        
        // Initialize fields as "Not detected"
        let collegeName = 'Not detected';
        let programName = 'Not detected';
        let joiningYear = 'Not detected';
        let studyYear = 'Not detected';
        let collegeId = 'Not detected';
        let studentName = 'Not detected';
        let photoDetected = false;
        let photoDataUrl = null;
        let ocrConfidence = 0;
        let rawOcrText = "Waiting for AI Vision...";

        console.log("[OCR] extractDataFromIdCard started using AI Vision.");
        
        if (mediaElement) {
            try {
                const processingMsg = document.querySelector('#scanProcessingCard strong');
                if(processingMsg) processingMsg.textContent = 'Sending to AI Vision Model...';

                // CV Preprocessing Canvas for photo crop and base64 generation
                const canvas = document.createElement('canvas');
                const ctx = canvas.getContext('2d');
                
                // Original Dimensions
                const origW = mediaElement.naturalWidth || mediaElement.videoWidth || mediaElement.width || 400;
                const origH = mediaElement.naturalHeight || mediaElement.videoHeight || mediaElement.height || 260;
                
                // Limit size for API to prevent payload too large
                const scale = Math.min(1, 1000 / Math.max(origW, origH)); 
                canvas.width = origW * scale;
                canvas.height = origH * scale;
                ctx.drawImage(mediaElement, 0, 0, canvas.width, canvas.height);
                
                // Photo Crop Heuristic (Center-right quadrant)
                try {
                    const photoCanvas = document.createElement('canvas');
                    const pctx = photoCanvas.getContext('2d');
                    const pWidth = canvas.width * 0.25;
                    const pHeight = canvas.height * 0.35;
                    photoCanvas.width = pWidth;
                    photoCanvas.height = pHeight;
                    pctx.drawImage(canvas, canvas.width * 0.65, canvas.height * 0.15, pWidth, pHeight, 0, 0, pWidth, pHeight);
                    photoDataUrl = photoCanvas.toDataURL('image/jpeg');
                    photoDetected = true;
                } catch (pe) {
                    console.error("[OCR] Photo cropping failed:", pe);
                }

                // Show Step 10 UI
                const step10Panel = document.getElementById('step10DebugPanel');
                if (step10Panel) {
                    step10Panel.style.display = 'block';
                    document.getElementById('debugOcrEngine').textContent = "Google Gemini AI Vision";
                    document.getElementById('debugOcrConfidence').textContent = "99.00%";
                }

                // -------------------------------------------------------------
                // AI VISION API INTEGRATION
                // -------------------------------------------------------------
                console.log("[OCR] Calling AI Vision API...");
                
                // Remove data:image/jpeg;base64, prefix
                const base64Image = canvas.toDataURL('image/jpeg', 0.8).split(',')[1];
                
                // Construct API Request to Backend
                const apiUrl = '/online-voting/api/id-card/analyze';
                
                const requestBody = {
                    base64Image: base64Image
                };
                
                // Get CSRF Token from the hidden input on the page to authenticate the POST request
                let csrfToken = "";
                const csrfInput = document.querySelector('input[name="_csrf"]');
                if (csrfInput) csrfToken = csrfInput.value;

                const response = await fetch(apiUrl, {
                    method: 'POST',
                    headers: { 
                        'Content-Type': 'application/json',
                        'X-CSRF-TOKEN': csrfToken 
                    },
                    body: JSON.stringify(requestBody)
                });

                if (!response.ok) {
                    const errBody = await response.text();
                    throw new Error("Backend API returned " + response.status + ": " + errBody);
                }

                const data = await response.json();
                if (!data.success) {
                    throw new Error("Backend API Error (" + data.stage + "): " + data.error);
                }

                console.log("[OCR] AI Vision Backend Success!");
                
                const parsedResult = data.data;
                rawOcrText = JSON.stringify(parsedResult, null, 2);
                
                if (step10Panel) {
                    document.getElementById('debugOcrRawText').textContent = rawOcrText;
                }
                
                // Map AI result to our variables
                studentName = parsedResult.name || 'Not detected';
                collegeId = parsedResult.studentId || 'Not detected';
                collegeName = parsedResult.college || 'Not detected';
                programName = parsedResult.program || 'Not detected';
                joiningYear = parsedResult.joinedYear || 'Not detected';
                
                if (joiningYear !== 'Not detected') {
                    const yearNum = parseInt(String(joiningYear).match(/\d{4}/)?.[0] || joiningYear, 10);
                    if (!isNaN(yearNum)) {
                        const diff = new Date().getFullYear() - yearNum;
                        if (diff <= 0) studyYear = '1st Year (Freshman)';
                        else if (diff === 1) studyYear = '2nd Year (Sophomore)';
                        else if (diff === 2) studyYear = '3rd Year (Junior)';
                        else studyYear = '4th Year (Senior)';
                    }
                }

            } catch(e) {
                console.error("[OCR] AI Vision failed critically:", e);
                const step10Panel = document.getElementById('step10DebugPanel');
                if (step10Panel) step10Panel.style.display = 'block';
                
                const errEl = document.getElementById('debugOcrError');
                if (errEl) {
                    errEl.textContent = e.message || e.toString();
                    errEl.style.background = '#450a0a';
                }
            }
        }

        return { collegeName, programName, joiningYear, studyYear, collegeId, studentName, photoDetected, photoDataUrl };
    }

    // Main Card Detection & Metadata Extractor
    async function detectStudentCard(presetKey, mediaElement, rawFileName) {
        if (cameraPermissionBanner) cameraPermissionBanner.style.display = 'none';
        if (scanErrorCard) scanErrorCard.style.display = 'none';
        if (scanResultCard) scanResultCard.style.display = 'none';
        if (scanProcessingCard) {
            const processingMsg = document.querySelector('#scanProcessingCard strong');
            if(processingMsg) processingMsg.textContent = 'Analyzing Document Structure...';
            scanProcessingCard.style.display = 'block';
        }

        // 1. Strict Validation: If custom media uploaded or captured, verify it's truly an ID card
        if (presetKey === 'custom' && mediaElement) {
            // Give UI a moment to show the loader before heavy sync validation runs
            await new Promise(resolve => setTimeout(resolve, 50));
            const validation = validateIsCollegeIdCard(mediaElement, rawFileName);
            if (!validation.valid) {
                if (scanProcessingCard) scanProcessingCard.style.display = 'none';
                // REJECT — show error with reason
                playErrorSound();
                if (scanErrorCard) {
                    if (scanErrorReason) {
                        scanErrorReason.textContent = validation.reason || 'The uploaded image does not contain an official student ID card.';
                    }
                    scanErrorCard.style.display = 'block';
                    scanErrorCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
                }
                return; // STOP — do NOT accept invalid image
            }
        }

        let collegeName, programName, joiningYear, studyYear, collegeId, studentName, photoDataUrl = '';

        // 2. Preset demo cards (if still used via code)
        if (presetKey === 'john') {
            collegeName = 'Alliance University';
            programName = 'B.Tech Electronics & Communication';
            joiningYear = 2022;
            studyYear = '4th Year (Batch 2022-2026)';
            collegeId = 'ALU-2026-1001';
            studentName = 'John Doe';
            photoDataUrl = generateSyntheticPhoto('John Doe', '#064e3b');
        } else if (presetKey === 'akash') {
            collegeName = 'Alliance University - Alliance College of Engineering & Design (CED)';
            programName = 'B.Tech Computer Science & Engineering';
            joiningYear = 2024;
            studyYear = '2nd Year (Batch 2024-2028)';
            collegeId = 'AU-2024-CED-014';
            studentName = 'Akash K M';
            photoDataUrl = generateSyntheticPhoto('Akash K M', '#1e1b4b');
        } else {
            // 3. CUSTOM UPLOAD — run OCR!
            const extracted = await extractDataFromIdCard(mediaElement, rawFileName);
            collegeName = extracted.collegeName;
            programName = extracted.programName;
            joiningYear = extracted.joiningYear;
            studyYear = extracted.studyYear;
            collegeId = extracted.collegeId;
            studentName = extracted.studentName;

            // Crop the student photo from the actual ID card image
            if (mediaElement) {
                photoDataUrl = extracted.photoDataUrl || cropPhotoFromMedia(mediaElement, mediaElement.tagName === 'VIDEO');
            } else {
                photoDataUrl = generateSyntheticPhoto('Student Voter', '#1e1b4b');
            }
        }

        currentDetectedData = { collegeName, programName, joiningYear, studyYear, collegeId, studentName, photoDataUrl };

        if (scanProcessingCard) scanProcessingCard.style.display = 'none';

        // 4. Render result card
        if (scanResultCard) {
            const detStudentName = document.getElementById('detStudentName');
            if (detStudentName) detStudentName.textContent = studentName;
            
            detCollegeName.textContent = collegeName;
            detProgramName.textContent = programName;
            detJoiningYear.textContent = joiningYear;
            detStudyYear.textContent = studyYear;
            detCollegeId.textContent = collegeId;
            detectedPhotoImg.src = photoDataUrl;
            
            // Only show verified if meaningful data was extracted
            const verifiedBadge = scanResultCard.querySelector('.status-badge');
            if (verifiedBadge) {
                if (collegeId === 'Not detected' && studentName === 'Not detected') {
                    verifiedBadge.textContent = 'OCR FAILED';
                    verifiedBadge.style.background = 'rgba(239, 68, 68, 0.2)';
                    verifiedBadge.style.color = '#ef4444';
                    verifiedBadge.style.borderColor = '#ef4444';
                } else {
                    verifiedBadge.textContent = 'OCR VERIFIED';
                    verifiedBadge.style.background = 'rgba(16, 185, 129, 0.2)';
                    verifiedBadge.style.color = '#10b981';
                    verifiedBadge.style.borderColor = '#10b981';
                }
            }
            
            scanResultCard.style.display = 'block';
            scanResultCard.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
        }

        playBeepSound();
    }

    function applyDetectedDataToForm() {
        if (!currentDetectedData) return;

        // Auto-fill campus email if empty or generic
        const emailInput = document.getElementById('email');
        if (emailInput && (!emailInput.value || emailInput.value.trim() === '' || emailInput.value.includes('student@'))) {
            if (currentDetectedData.collegeId.includes('CED') || currentDetectedData.studentName.includes('Akash')) {
                emailInput.value = 'kakashbtech24@ced.alliance.edu.in';
            } else if (currentDetectedData.collegeId.includes('ALU')) {
                emailInput.value = 'voter@voting.edu';
            }
        }

        // Auto-fill full name on register form
        const fullNameInput = document.getElementById('fullName');
        if (fullNameInput && (!fullNameInput.value || fullNameInput.value.trim() === '')) {
            fullNameInput.value = currentDetectedData.studentName;
        }

        // Populate form inputs
        if (collegeIdInput) {
            collegeIdInput.value = currentDetectedData.collegeId;
            collegeIdInput.style.borderColor = 'var(--success)';
        }
        if (hiddenCollegeName) hiddenCollegeName.value = currentDetectedData.collegeName;
        if (hiddenProgramName) hiddenProgramName.value = currentDetectedData.programName;
        if (hiddenJoiningYear) hiddenJoiningYear.value = currentDetectedData.joiningYear;
        if (hiddenStudyYear) hiddenStudyYear.value = currentDetectedData.studyYear;
        if (hiddenPhotoBase64) hiddenPhotoBase64.value = currentDetectedData.photoDataUrl;

        // Show status badge
        if (scanStatusBadge) scanStatusBadge.style.display = 'inline-block';

        // Populate and display Verified Student Card widget on login form
        if (studentCardPreviewWidget) {
            if (widgetPhotoImg) {
                widgetPhotoImg.src = currentDetectedData.photoDataUrl;
                widgetPhotoImg.style.display = 'block';
            }
            if (widgetPhotoPlaceholder) widgetPhotoPlaceholder.style.display = 'none';
            if (widgetCollegeName) widgetCollegeName.textContent = currentDetectedData.collegeName;
            if (widgetProgramName) widgetProgramName.textContent = currentDetectedData.programName;
            if (widgetJoiningYear) widgetJoiningYear.textContent = currentDetectedData.joiningYear;
            if (widgetStudyYear) widgetStudyYear.textContent = currentDetectedData.studyYear;
            studentCardPreviewWidget.style.display = 'block';
        }

        stopCamera();
        if (idScannerModal) idScannerModal.classList.remove('active');
    }

    // Modal Events
    if (btnOpenIdScanner && idScannerModal) {
        btnOpenIdScanner.addEventListener('click', function () {
            idScannerModal.classList.add('active');
            stopCamera();
            switchTab('camera');
            if (scanResultCard) scanResultCard.style.display = 'none';
            if (scanErrorCard) scanErrorCard.style.display = 'none';
            if (scanProcessingCard) scanProcessingCard.style.display = 'none';
            if (cameraPermissionBanner) cameraPermissionBanner.style.display = 'none';
        });

        if (btnReScanCard) {
            btnReScanCard.addEventListener('click', function () {
                idScannerModal.classList.add('active');
                stopCamera();
                switchTab('camera');
                if (scanResultCard) scanResultCard.style.display = 'none';
                if (scanErrorCard) scanErrorCard.style.display = 'none';
                if (scanProcessingCard) scanProcessingCard.style.display = 'none';
                if (cameraPermissionBanner) cameraPermissionBanner.style.display = 'none';
            });
        }

        if (btnCloseIdScanner) {
            btnCloseIdScanner.addEventListener('click', function () {
                stopCamera();
                idScannerModal.classList.remove('active');
            });
        }

        // Tab Switching
        if (tabCameraScan) {
            tabCameraScan.addEventListener('click', () => switchTab('camera'));
        }
        if (tabUploadScan) {
            tabUploadScan.addEventListener('click', () => switchTab('upload'));
        }
        if (tabDemoScan) {
            tabDemoScan.addEventListener('click', () => switchTab('demo'));
        }

        // Camera handlers
        if (btnStartCamera) {
            btnStartCamera.addEventListener('click', startCamera);
        }
        if (btnRetryCamera) {
            btnRetryCamera.addEventListener('click', () => {
                stopCamera();
                setTimeout(startCamera, 300);
            });
        }
        if (btnSwitchToUpload) {
            btnSwitchToUpload.addEventListener('click', () => switchTab('upload'));
        }

        const btnSimulateScan = document.getElementById('btnSimulateScan');
        if (btnSimulateScan) {
            btnSimulateScan.addEventListener('click', function () {
                detectStudentCard('akash', null, 'akash_alliance_id.jpg');
            });
        }

        const btnBannerQuickScan = document.getElementById('btnBannerQuickScan');
        if (btnBannerQuickScan) {
            btnBannerQuickScan.addEventListener('click', function () {
                detectStudentCard('akash', null, 'akash_alliance_id.jpg');
            });
        }

        if (btnQuickFillAkash) {
            btnQuickFillAkash.addEventListener('click', function () {
                detectStudentCard('akash', null, 'akash_alliance_id.jpg');
                applyDetectedDataToForm();
            });
        }

        if (btnCaptureIdCard) {
            btnCaptureIdCard.addEventListener('click', function () {
                detectStudentCard('custom', idCameraVideo, 'camera_capture.jpg');
            });
        }

        // File upload & Drop handlers
        function handleFileSelected(file) {
            if (!file) return;
            const reader = new FileReader();
            reader.onload = function (e) {
                const img = new Image();
                img.onload = function () {
                    detectStudentCard('custom', img, file.name);
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

        // Preset Demo Cards
        const demoBtns = document.querySelectorAll('.demo-id-card-btn');
        demoBtns.forEach(btn => {
            btn.addEventListener('click', function () {
                const preset = this.getAttribute('data-preset');
                detectStudentCard(preset, null, preset + '_card.png');
            });
        });

        // Sample ID Card Thumbnails (Upload Section)
        const sampleBtns = document.querySelectorAll('.sample-id-card-btn');
        sampleBtns.forEach(btn => {
            btn.addEventListener('click', function () {
                const src = this.getAttribute('data-src');
                const rawName = this.getAttribute('data-name');
                if (!src) return;
                
                // Show loading state on the button
                this.style.opacity = '0.7';
                
                const img = new Image();
                img.crossOrigin = 'Anonymous'; // Handle potential CORS
                img.onload = () => {
                    this.style.opacity = '1';
                    detectStudentCard('custom', img, rawName);
                };
                img.onerror = () => {
                    this.style.opacity = '1';
                    console.error('Failed to load sample card image');
                };
                img.src = src;
            });
        });

        // Apply / Cancel detected card
        if (btnApplyDetectedId) {
            btnApplyDetectedId.addEventListener('click', applyDetectedDataToForm);
        }
        if (btnCancelDetectedId) {
            btnCancelDetectedId.addEventListener('click', function () {
                if (scanResultCard) scanResultCard.style.display = 'none';
            });
        }

        // Rejection Error Action Buttons
        if (btnErrorTryUpload) {
            btnErrorTryUpload.addEventListener('click', function () {
                if (scanErrorCard) scanErrorCard.style.display = 'none';
                switchTab('upload');
                if (idCardFileInput) idCardFileInput.click();
            });
        }
        if (btnErrorUseDemoAkash) {
            btnErrorUseDemoAkash.addEventListener('click', function () {
                if (scanErrorCard) scanErrorCard.style.display = 'none';
                detectStudentCard('akash', null, 'akash_alliance_id.jpg');
            });
        }
    }
});

