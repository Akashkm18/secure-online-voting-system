/**
 * Secure Online Voting System - Admin Console Interactive Utilities
 * Strictly compliant with Content Security Policy (No inline scripts or on* handlers).
 */
document.addEventListener('DOMContentLoaded', function () {
    initConfirmModals();
    initModalToggles();
    initPhotoUploadPreview();
    initDoubleSubmitProtection();
    initDetailModalTriggers();
});

/**
 * Global Styled Confirmation Modal
 * Replaces window.confirm with accessible, styled modal dialog.
 */
function initConfirmModals() {
    const modal = document.getElementById('adminConfirmModal');
    if (!modal) return;

    const titleEl = document.getElementById('confirmModalTitle');
    const msgEl = document.getElementById('confirmModalMessage');
    const confirmBtn = document.getElementById('confirmModalConfirmBtn');
    const cancelBtn = document.getElementById('confirmModalCancelBtn');
    const closeBtn = document.getElementById('confirmModalCloseBtn');

    let pendingForm = null;

    document.querySelectorAll('[data-confirm]').forEach(function (trigger) {
        trigger.addEventListener('click', function (e) {
            e.preventDefault();
            const form = trigger.closest('form');
            if (!form) return;

            pendingForm = form;
            const title = trigger.getAttribute('data-confirm-title') || 'Confirm Action';
            const msg = trigger.getAttribute('data-confirm') || 'Are you sure you wish to proceed with this operation?';
            const isDanger = trigger.classList.contains('btn-danger') || trigger.getAttribute('data-confirm-danger') === 'true';

            if (titleEl) titleEl.textContent = title;
            if (msgEl) msgEl.textContent = msg;

            if (confirmBtn) {
                if (isDanger) {
                    confirmBtn.className = 'btn btn-danger btn-sm';
                    confirmBtn.textContent = trigger.getAttribute('data-confirm-btn') || 'Proceed';
                } else {
                    confirmBtn.className = 'btn btn-primary btn-sm';
                    confirmBtn.textContent = trigger.getAttribute('data-confirm-btn') || 'Confirm';
                }
            }

            modal.classList.add('active');
        });
    });

    if (confirmBtn) {
        confirmBtn.addEventListener('click', function () {
            if (pendingForm) {
                confirmBtn.disabled = true;
                confirmBtn.textContent = 'Processing...';
                pendingForm.submit();
            }
            modal.classList.remove('active');
        });
    }

    const closeModal = function () {
        modal.classList.remove('active');
        pendingForm = null;
    };

    if (cancelBtn) cancelBtn.addEventListener('click', closeModal);
    if (closeBtn) closeBtn.addEventListener('click', closeModal);

    modal.addEventListener('click', function (e) {
        if (e.target === modal) closeModal();
    });

    document.addEventListener('keydown', function (e) {
        if (e.key === 'Escape' && modal.classList.contains('active')) {
            closeModal();
        }
    });
}

/**
 * Generic Modal Toggles (Add Election, Add Candidate, Edit Modals)
 */
function initModalToggles() {
    document.querySelectorAll('[data-modal-open]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const targetSelector = btn.getAttribute('data-modal-open');
            const targetModal = document.querySelector(targetSelector);
            if (targetModal) {
                targetModal.classList.add('active');
            }
        });
    });

    document.querySelectorAll('[data-modal-close]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            const modal = btn.closest('.modal-overlay');
            if (modal) {
                modal.classList.remove('active');
            }
        });
    });

    document.querySelectorAll('.modal-overlay').forEach(function (overlay) {
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) {
                overlay.classList.remove('active');
            }
        });
    });
}

/**
 * Candidate Photo Live Preview & Client Validation
 * Replaces/Removes photo without page reload.
 */
function initPhotoUploadPreview() {
    const photoInputs = document.querySelectorAll('input[type="file"][data-photo-input]');

    photoInputs.forEach(function (input) {
        const previewImg = document.querySelector(input.getAttribute('data-preview-target'));
        const errorEl = document.querySelector(input.getAttribute('data-error-target'));
        const clearBtn = document.querySelector(input.getAttribute('data-clear-target'));

        input.addEventListener('change', function () {
            if (errorEl) errorEl.textContent = '';
            const file = input.files && input.files[0];
            if (!file) return;

            // Check file size (max 2 MB = 2 * 1024 * 1024 bytes)
            if (file.size > 2 * 1024 * 1024) {
                if (errorEl) errorEl.textContent = 'Selected photo exceeds maximum allowed size of 2 MB.';
                input.value = '';
                return;
            }

            // Check MIME type
            if (!['image/jpeg', 'image/png'].includes(file.type)) {
                if (errorEl) errorEl.textContent = 'Only real JPEG or PNG images are allowed.';
                input.value = '';
                return;
            }

            // Read file into image preview
            const reader = new FileReader();
            reader.onload = function (e) {
                if (previewImg) {
                    previewImg.src = e.target.result;
                    previewImg.style.display = 'block';
                }
                if (clearBtn) {
                    clearBtn.style.display = 'inline-flex';
                }
            };
            reader.readAsDataURL(file);
        });

        if (clearBtn) {
            clearBtn.addEventListener('click', function () {
                input.value = '';
                if (previewImg) {
                    const defaultSrc = previewImg.getAttribute('data-default-src');
                    if (defaultSrc) {
                        previewImg.src = defaultSrc;
                    }
                }
                clearBtn.style.display = 'none';
                if (errorEl) errorEl.textContent = '';
            });
        }
    });
}

/**
 * Double-submit prevention & loading indicators on submit buttons
 */
function initDoubleSubmitProtection() {
    document.querySelectorAll('form').forEach(function (form) {
        form.addEventListener('submit', function () {
            const submitBtn = form.querySelector('button[type="submit"]:not([data-no-disable])');
            if (submitBtn) {
                // Short timeout to allow form payload serialisation
                setTimeout(function () {
                    submitBtn.disabled = true;
                    submitBtn.classList.add('loading');
                }, 20);
            }
        });
    });
}

/**
 * Voter Detail History Modal Trigger
 */
function initDetailModalTriggers() {
    const detailModal = document.getElementById('adminDetailModal');
    if (!detailModal) return;

    document.querySelectorAll('[data-detail-trigger]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            detailModal.classList.add('active');
        });
    });
}
