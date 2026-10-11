document.addEventListener('DOMContentLoaded', function () {
    const fileInput = document.getElementById('idCardFileInput');
    const dropZone = document.getElementById('dropZone');
    const statusMsg = document.getElementById('ocrStatusMsg');
    const collegeIdInput = document.getElementById('collegeId');
    const passwordFields = document.getElementById('passwordFields');

    if (dropZone && fileInput) {
        dropZone.addEventListener('click', function (e) {
            if (e.target !== fileInput) {
                fileInput.click();
            }
        });

        dropZone.addEventListener('dragover', function (e) {
            e.preventDefault();
            dropZone.style.borderColor = 'var(--primary)';
        });

        dropZone.addEventListener('dragleave', function () {
            dropZone.style.borderColor = 'var(--border-color)';
        });

        dropZone.addEventListener('drop', function (e) {
            e.preventDefault();
            dropZone.style.borderColor = 'var(--border-color)';
            if (e.dataTransfer.files && e.dataTransfer.files.length) {
                fileInput.files = e.dataTransfer.files;
                processImage(fileInput.files[0]);
            }
        });

        fileInput.addEventListener('change', function (e) {
            if (e.target.files && e.target.files.length) {
                processImage(e.target.files[0]);
            }
        });
    }

    if (collegeIdInput) {
        collegeIdInput.addEventListener('input', function () {
            if (collegeIdInput.value.trim().length >= 3 && passwordFields) {
                passwordFields.style.display = 'block';
                const newPw = document.getElementById('newPassword');
                const confPw = document.getElementById('confirmPassword');
                if (newPw) newPw.required = true;
                if (confPw) confPw.required = true;
            }
        });
    }

    async function processImage(file) {
        if (!statusMsg || !collegeIdInput || !passwordFields) return;
        statusMsg.style.display = 'block';
        statusMsg.style.background = 'rgba(37, 99, 235, 0.1)';
        statusMsg.style.color = 'var(--primary)';
        statusMsg.textContent = 'Processing ID Card with OCR... Please wait.';

        const imageUrl = URL.createObjectURL(file);

        try {
            if (typeof Tesseract !== 'undefined') {
                const result = await Tesseract.recognize(imageUrl, 'eng');
                const text = result.data.text || '';
                
                // Regex for standard student IDs: e.g. 2411021061524, AU-2024-CED-014, STU-2026-001, ALU-..., alphanumeric codes
                const idMatch = text.match(/\b([A-Z]{2,4}-\d{4}-[A-Z0-9]+|\d{9,15}|[A-Z0-9]{3,}-\d{2,})\b/i);
                
                if (idMatch) {
                    onSuccess(idMatch[1].toUpperCase());
                } else {
                    // Try to extract any potential ID token or let user confirm
                    const fallbackMatch = text.match(/\b([A-Z0-9]{4,15})\b/);
                    if (fallbackMatch) {
                        onSuccess(fallbackMatch[1].toUpperCase());
                    } else {
                        statusMsg.style.background = 'rgba(239, 68, 68, 0.1)';
                        statusMsg.style.color = 'var(--danger)';
                        statusMsg.textContent = 'Could not clearly detect an ID number. Please enter your ID manually below.';
                        passwordFields.style.display = 'block';
                    }
                }
            } else {
                statusMsg.style.display = 'none';
                passwordFields.style.display = 'block';
            }
        } catch (err) {
            console.error('Tesseract Error:', err);
            statusMsg.style.background = 'rgba(239, 68, 68, 0.1)';
            statusMsg.style.color = 'var(--danger)';
            statusMsg.textContent = 'OCR processing unavailable. Please type your Student ID manually.';
            passwordFields.style.display = 'block';
        }
    }

    function onSuccess(extractedId) {
        collegeIdInput.value = extractedId;
        statusMsg.style.background = 'var(--success-bg)';
        statusMsg.style.color = 'var(--success)';
        statusMsg.textContent = 'Student ID Detected! You may now set your new password.';
        passwordFields.style.display = 'block';
        const newPw = document.getElementById('newPassword');
        const confPw = document.getElementById('confirmPassword');
        if (newPw) newPw.required = true;
        if (confPw) confPw.required = true;
    }
});
