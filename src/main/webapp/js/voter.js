/**
 * voter.js - Interactive behaviors for Voter Portal (Strict CSP compliant, zero inline scripts)
 */
document.addEventListener('DOMContentLoaded', function () {
    // 1. Candidate details modal dialogs
    document.querySelectorAll('[data-candidate-modal]').forEach(function (btn) {
        btn.addEventListener('click', function (e) {
            e.preventDefault();
            var modalId = btn.getAttribute('data-candidate-modal');
            var modal = document.getElementById(modalId);
            if (modal) {
                modal.classList.add('active');
                modal.style.display = 'flex';
            }
        });
    });

    // Close any modal via data-modal-close
    document.querySelectorAll('[data-modal-close]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var modal = btn.closest('.modal-overlay');
            if (modal) {
                modal.classList.remove('active');
                modal.style.display = 'none';
            }
        });
    });

    // Close modal on backdrop click
    document.querySelectorAll('.modal-overlay').forEach(function (overlay) {
        overlay.addEventListener('click', function (e) {
            if (e.target === overlay) {
                overlay.classList.remove('active');
                overlay.style.display = 'none';
            }
        });
    });

    // 2. Ballot Card Selection & Confirm Modal on vote.jsp
    var ballotForm = document.getElementById('ballotForm');
    var ballotCards = document.querySelectorAll('.candidate-ballot-card');
    ballotCards.forEach(function (card) {
        var radio = card.querySelector('input[type="radio"]');
        card.addEventListener('click', function (e) {
            if (e.target !== radio) {
                if (radio) radio.checked = true;
            }
            ballotCards.forEach(function (c) { c.classList.remove('selected'); });
            card.classList.add('selected');
        });
        if (radio) {
            radio.addEventListener('change', function () {
                ballotCards.forEach(function (c) { c.classList.remove('selected'); });
                if (radio.checked) card.classList.add('selected');
            });
            if (radio.checked) card.classList.add('selected');
        }
    });

    var btnSubmitVote = document.getElementById('btnSubmitVote');
    var voteConfirmModal = document.getElementById('voteConfirmModal');
    var confirmVoteBtn = document.getElementById('confirmVoteBtn');
    var cancelVoteBtn = document.getElementById('cancelVoteBtn');

    if (btnSubmitVote && voteConfirmModal && ballotForm) {
        btnSubmitVote.addEventListener('click', function (e) {
            var selectedRadio = ballotForm.querySelector('input[name="candidateId"]:checked');
            if (!selectedRadio) {
                alert('Please select a candidate before proceeding.');
                return;
            }
            e.preventDefault();
            voteConfirmModal.classList.add('active');
            voteConfirmModal.style.display = 'flex';
        });

        if (confirmVoteBtn) {
            confirmVoteBtn.addEventListener('click', function () {
                confirmVoteBtn.disabled = true;
                confirmVoteBtn.textContent = 'Submitting Ballot...';
                ballotForm.submit();
            });
        }

        if (cancelVoteBtn) {
            cancelVoteBtn.addEventListener('click', function () {
                voteConfirmModal.classList.remove('active');
                voteConfirmModal.style.display = 'none';
            });
        }
    }

    // 3. Copy Receipt Hash button on vote-success.jsp
    var btnCopyHash = document.getElementById('btnCopyHash');
    if (btnCopyHash) {
        btnCopyHash.addEventListener('click', function () {
            var input = document.getElementById('receiptHashInput');
            if (input && input.value) {
                navigator.clipboard.writeText(input.value).then(function () {
                    var btnText = document.getElementById('copyBtnText');
                    if (btnText) {
                        var orig = btnText.textContent;
                        btnText.textContent = 'Copied!';
                        setTimeout(function () { btnText.textContent = orig; }, 2000);
                    }
                }).catch(function() {
                    input.select();
                    document.execCommand('copy');
                });
            }
        });
    }

    // Multi-item copy buttons on my-status.jsp
    document.querySelectorAll('[data-copy-target]').forEach(function (btn) {
        btn.addEventListener('click', function () {
            var targetSelector = btn.getAttribute('data-copy-target');
            var input = document.querySelector(targetSelector);
            if (input && input.value) {
                navigator.clipboard.writeText(input.value).then(function () {
                    var orig = btn.textContent;
                    btn.textContent = 'Copied!';
                    setTimeout(function () { btn.textContent = orig; }, 2000);
                }).catch(function() {
                    input.select();
                    document.execCommand('copy');
                });
            }
        });
    });

    // 4. Double-submit prevention on any standard submit button
    document.querySelectorAll('form').forEach(function (form) {
        form.addEventListener('submit', function () {
            var submitBtn = form.querySelector('button[type="submit"]');
            if (submitBtn && !submitBtn.disabled) {
                setTimeout(function () {
                    submitBtn.disabled = true;
                }, 50);
            }
        });
    });

    // Mobile nav toggle
    var mobileNavToggle = document.getElementById('mobileNavToggle');
    var primaryNav = document.getElementById('primaryNav');
    if (mobileNavToggle && primaryNav) {
        mobileNavToggle.addEventListener('click', function () {
            primaryNav.classList.toggle('active');
        });
    }
});
