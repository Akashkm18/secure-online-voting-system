<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Secure Online Voting System - College micro project implementing cryptographic receipts, atomic transactions, and role-based access control.">
    <title>Secure Online Voting System | College Campus Elections</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/css/style.css">
</head>
<body>

    <!-- Header Navigation -->
    <nav class="navbar" id="mainNavbar">
        <a href="${pageContext.request.contextPath}/index.jsp" class="nav-brand" id="brandLink">
            <div class="brand-icon">🗳️</div>
            <span>Secure Voting</span>
        </a>
        <ul class="nav-menu" id="navMenuList">
            <li><a href="${pageContext.request.contextPath}/index.jsp" class="nav-link active" id="navHome">Home</a></li>
            <li><a href="${pageContext.request.contextPath}/elections" class="nav-link" id="navElections">Elections</a></li>
            <li><a href="${pageContext.request.contextPath}/candidates" class="nav-link" id="navCandidates">Candidates</a></li>
            <c:choose>
                <c:when test="${not empty sessionScope.user}">
                    <c:choose>
                        <c:when test="${sessionScope.user.admin}">
                            <li><a href="${pageContext.request.contextPath}/admin/dashboard" class="nav-link" id="navAdminDash">Admin Dashboard</a></li>
                        </c:when>
                        <c:otherwise>
                            <li><a href="${pageContext.request.contextPath}/dashboard.jsp" class="nav-link" id="navVoterDash">My Dashboard</a></li>
                            <li><a href="${pageContext.request.contextPath}/my-status.jsp" class="nav-link" id="navMyStatus">My Status</a></li>
                        </c:otherwise>
                    </c:choose>
                    <li><a href="${pageContext.request.contextPath}/logout" class="btn btn-outline btn-sm" id="navLogout">Logout</a></li>
                </c:when>
                <c:otherwise>
                    <li><a href="${pageContext.request.contextPath}/login.jsp" class="nav-link" id="navLogin">Sign In</a></li>
                    <li><a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-primary btn-sm" id="navRegister">Register to Vote</a></li>
                    <li><a href="${pageContext.request.contextPath}/admin/login.jsp" class="nav-link" id="navAdminPortal" style="color: #fbbf24;">Admin Portal</a></li>
                </c:otherwise>
            </c:choose>
        </ul>
    </nav>

    <!-- Main Hero Container -->
    <main class="container" id="mainContent">
        <section style="text-align: center; max-width: 820px; margin: 3rem auto 4rem auto;">
            <div style="display: inline-flex; align-items: center; gap: 0.5rem; background: rgba(99, 102, 241, 0.12); border: 1px solid rgba(99, 102, 241, 0.3); border-radius: var(--radius-full); padding: 0.35rem 1rem; margin-bottom: 1.5rem; font-size: 0.85rem; color: #a5b4fc;">
                <span>🛡️</span> Academic Micro Project with Enterprise Security Principles
            </div>
            <h1 style="font-size: 3rem; line-height: 1.15; margin-bottom: 1.25rem;">
                Decentralized Trust for Campus Democratic Elections
            </h1>
            <p class="subtitle" style="font-size: 1.15rem; margin-bottom: 2.25rem;">
                Engineered with ACID-compliant JDBC transactions, database-enforced single-vote uniqueness, cryptographic vote receipts, and complete ballot secrecy.
            </p>
            <div style="display: flex; gap: 1rem; justify-content: center; flex-wrap: wrap;">
                <a href="${pageContext.request.contextPath}/elections" class="btn btn-primary" id="btnExploreElections">
                    <span>🗳️</span> View Active Elections
                </a>
                <c:choose>
                    <c:when test="${empty sessionScope.user}">
                        <a href="${pageContext.request.contextPath}/register.jsp" class="btn btn-secondary" id="btnRegisterHero">
                            Register as Voter
                        </a>
                        <a href="${pageContext.request.contextPath}/admin/login.jsp" class="btn btn-outline" id="btnAdminHero">
                            Admin Login
                        </a>
                    </c:when>
                    <c:otherwise>
                        <a href="${pageContext.request.contextPath}/dashboard.jsp" class="btn btn-secondary" id="btnMyDashHero">
                            Go to Dashboard
                        </a>
                    </c:otherwise>
                </c:choose>
            </div>
        </section>

        <!-- Feature Grid -->
        <section style="margin-bottom: 4rem;">
            <div style="text-align: center; margin-bottom: 2.5rem;">
                <h2>Security Architecture Highlights</h2>
                <p class="subtitle">Four foundational application-level defenses built into every request</p>
            </div>

            <div class="grid-cards">
                <div class="card">
                    <div>
                        <div class="stat-icon indigo" style="margin-bottom: 1.25rem;">🔒</div>
                        <h3>Database-Level Uniqueness</h3>
                        <p style="color: var(--text-secondary); font-size: 0.925rem; margin-top: 0.5rem;">
                            Enforced by MySQL <code>UNIQUE(election_id, voter_id)</code> constraint inside an atomic rollback transaction. Double voting is mathematically blocked.
                        </p>
                    </div>
                </div>

                <div class="card">
                    <div>
                        <div class="stat-icon emerald" style="margin-bottom: 1.25rem;">👁️</div>
                        <h3>Voter Privacy & Secrecy</h3>
                        <p style="color: var(--text-secondary); font-size: 0.925rem; margin-top: 0.5rem;">
                            Your candidate selection is strictly isolated. The voter dashboard only confirms participation receipt, never revealing choice to peers or auditors.
                        </p>
                    </div>
                </div>

                <div class="card">
                    <div>
                        <div class="stat-icon amber" style="margin-bottom: 1.25rem;">📜</div>
                        <h3>SHA-256 Receipts</h3>
                        <p style="color: var(--text-secondary); font-size: 0.925rem; margin-top: 0.5rem;">
                            Every confirmed ballot generates a unique cryptographic hash proof that voters can independently verify without exposing who they voted for.
                        </p>
                    </div>
                </div>

                <div class="card">
                    <div>
                        <div class="stat-icon sky" style="margin-bottom: 1.25rem;">🛡️</div>
                        <h3>BCrypt & CSRF Defenses</h3>
                        <p style="color: var(--text-secondary); font-size: 0.925rem; margin-top: 0.5rem;">
                            Passwords hashed with 12 rounds of BCrypt salt. Every HTTP state mutation requires verified CSRF tokens, protected against SQL injection via PreparedStatement.
                        </p>
                    </div>
                </div>
            </div>
        </section>
    </main>

    <!-- Footer -->
    <footer class="footer" id="mainFooter">
        <p>© 2026 Secure Online Voting System — College Micro Project demonstration. Built for Tomcat 10+ and Java 17+.</p>
    </footer>

    <script src="${pageContext.request.contextPath}/js/validation.js"></script>
</body>
</html>
