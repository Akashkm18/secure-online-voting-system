<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Secure, transparent election platform with verified ballot integrity and cryptographic receipts.">
    <title>Campus Elections | Secure Online Voting System</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Shared Header Navigation Fragment -->
    <jsp:include page="/WEB-INF/fragments/navbar.jsp" />

    <!-- Main Container -->
    <main class="container" id="mainContent">
        <!-- Hero Section -->
        <section style="text-align: center; max-width: 760px; margin: 3.5rem auto 3.5rem auto;">
            <h1 style="font-size: 2.75rem; line-height: 1.15; margin-bottom: 1rem; letter-spacing: -0.02em;">
                Secure, Transparent Campus Elections
            </h1>
            <p style="font-size: 1.1rem; color: var(--text-secondary); margin-bottom: 2rem; max-width: 620px; margin-left: auto; margin-right: auto;">
                An institutional voting platform ensuring verified student participation, secret ballots, and tamper-evident results.
            </p>
            <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/elections" class="btn btn-primary btn-lg" id="btnExploreElections">
                    <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <rect x="2" y="7" width="20" height="14" rx="2" ry="2"/>
                        <path d="M16 21V5a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/>
                    </svg>
                    View Active Elections
                </a>
                <c:choose>
                    <c:when test="${empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/login.jsp" class="btn btn-secondary btn-lg" id="btnVoterSignInHero">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M15 3h4a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2h-4"/>
                                <polyline points="10 17 15 12 10 7"/>
                                <line x1="15" y1="12" x2="3" y2="12"/>
                            </svg>
                            Voter Sign In
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-secondary btn-lg" id="btnMyDashHero">
                            <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <rect x="3" y="3" width="7" height="7"/>
                                <rect x="14" y="3" width="7" height="7"/>
                                <rect x="14" y="14" width="7" height="7"/>
                                <rect x="3" y="14" width="7" height="7"/>
                            </svg>
                            Go to Dashboard
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <!-- Compact 3-Step "How It Works" Row -->
        <section style="margin-bottom: 3.5rem;">
            <div style="text-align: center; margin-bottom: 1.75rem;">
                <h2 style="font-size: 1.35rem;">How It Works</h2>
            </div>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(240px, 1fr)); gap: 1.25rem;">
                <div class="card" style="padding: 1.5rem; text-align: center;">
                    <div style="width: 40px; height: 40px; border-radius: var(--radius-full); background: var(--primary-subtle); color: var(--primary-light); display: flex; align-items: center; justify-content: center; margin: 0 auto 1rem auto; font-weight: 700;">
                        1
                    </div>
                    <h3 style="font-size: 1.05rem; margin-bottom: 0.35rem;">Register</h3>
                    <p style="font-size: 0.875rem;">Verify your official student credentials and enroll your voter profile.</p>
                </div>

                <div class="card" style="padding: 1.5rem; text-align: center;">
                    <div style="width: 40px; height: 40px; border-radius: var(--radius-full); background: var(--primary-subtle); color: var(--primary-light); display: flex; align-items: center; justify-content: center; margin: 0 auto 1rem auto; font-weight: 700;">
                        2
                    </div>
                    <h3 style="font-size: 1.05rem; margin-bottom: 0.35rem;">Vote</h3>
                    <p style="font-size: 0.875rem;">Cast your secret ballot securely in active campus elections.</p>
                </div>

                <div class="card" style="padding: 1.5rem; text-align: center;">
                    <div style="width: 40px; height: 40px; border-radius: var(--radius-full); background: var(--primary-subtle); color: var(--primary-light); display: flex; align-items: center; justify-content: center; margin: 0 auto 1rem auto; font-weight: 700;">
                        3
                    </div>
                    <h3 style="font-size: 1.05rem; margin-bottom: 0.35rem;">Verify Receipt</h3>
                    <p style="font-size: 0.875rem;">Receive a unique cryptographic token confirming your vote was counted.</p>
                </div>
            </div>
        </section>

        <!-- Trust & Security Pillars (3 Cards, 1 sentence each) -->
        <section id="security" style="margin-bottom: 3.5rem;">
            <div style="text-align: center; margin-bottom: 1.75rem;">
                <h2 style="font-size: 1.35rem;">Institutional Security Standard</h2>
            </div>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(260px, 1fr)); gap: 1.25rem;">
                <div class="card" style="padding: 1.5rem;">
                    <div style="color: var(--primary-light); margin-bottom: 0.75rem;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <rect x="3" y="11" width="18" height="11" rx="2" ry="2"/>
                            <path d="M7 11V7a5 5 0 0 1 10 0v4"/>
                        </svg>
                    </div>
                    <h3 style="font-size: 1.05rem; margin-bottom: 0.35rem;">One Vote Per Voter</h3>
                    <p style="font-size: 0.875rem;">Database-level uniqueness constraints strictly prevent duplicate ballot submissions.</p>
                </div>

                <div class="card" style="padding: 1.5rem;">
                    <div style="color: #10b981; margin-bottom: 0.75rem;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M2 12s3-7 10-7 10 7 10 7-3 7-10 7-10-7-10-7Z"/>
                            <circle cx="12" cy="12" r="3"/>
                        </svg>
                    </div>
                    <h3 style="font-size: 1.05rem; margin-bottom: 0.35rem;">Anonymous Ballots</h3>
                    <p style="font-size: 0.875rem;">Voter identity is detached from candidate selection to maintain total secrecy.</p>
                </div>

                <div class="card" style="padding: 1.5rem;">
                    <div style="color: #38bdf8; margin-bottom: 0.75rem;">
                        <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/>
                            <polyline points="14 2 14 8 20 8"/>
                            <line x1="16" y1="13" x2="8" y2="13"/>
                            <line x1="16" y1="17" x2="8" y2="17"/>
                            <polyline points="10 9 9 9 8 9"/>
                        </svg>
                    </div>
                    <h3 style="font-size: 1.05rem; margin-bottom: 0.35rem;">Verifiable Receipts</h3>
                    <p style="font-size: 0.875rem;">Every ballot produces a SHA-256 cryptographic receipt that voters can inspect anytime.</p>
                </div>
            </div>
        </section>
    </main>

    <!-- Shared Footer Fragment -->
    <jsp:include page="/WEB-INF/fragments/footer.jsp" />

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
