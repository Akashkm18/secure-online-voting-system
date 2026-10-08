# Secure Online Voting System

[![Java Version](https://img.shields.io/badge/Java-17%2B-blue.svg)](https://openjdk.org/)
[![Apache Tomcat](https://img.shields.io/badge/Tomcat-10.1%2B-orange.svg)](https://tomcat.apache.org/)
[![Maven Build](https://img.shields.io/badge/Maven-Build%20Passing-brightgreen.svg)](https://maven.apache.org/)
[![Security](https://img.shields.io/badge/BCrypt-Cost%2012-success.svg)](https://en.wikipedia.org/wiki/Bcrypt)

> **Academic Project Disclaimer:**  
> This system is designed as a college micro-project demonstrating modern application-level security, MVC web architecture, cryptographic vote receipts, and database-level integrity. It is intended for educational demonstrations, campus student council elections, or collegiate society polling. It is **not** certified for sovereign government elections.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Key Features](#key-features)
3. [Technology Stack](#technology-stack)
4. [Software Architecture (MVC)](#software-architecture-mvc)
5. [Database Setup & MySQL Schema](#database-setup--mysql-schema)
6. [Environment Variables & Configuration](#environment-variables--configuration)
7. [Building with Maven](#building-with-maven)
8. [Deploying to Apache Tomcat 10+](#deploying-to-apache-tomcat-10)
9. [Running in Antigravity IDE / VS Code](#running-in-antigravity-ide--vs-code)
10. [Step-by-Step Workflow Guides](#step-by-step-workflow-guides)
    - [Creating the Administrator Account](#creating-the-administrator-account)
    - [Enrolling Voters](#enrolling-voters)
    - [Creating an Election](#creating-an-election)
    - [Registering Candidates](#registering-candidates)
    - [Casting a Vote](#casting-a-vote)
    - [Results & Official Publication](#results--official-publication)
11. [Security Engineering & Protection Analysis](#security-engineering--protection-analysis)
12. [Automated Test Suite](#automated-test-suite)
13. [Known Limitations & Future Scope](#known-limitations--future-scope)

---

## 1. Project Overview

The **Secure Online Voting System** is a full-featured campus voting web application engineered using modern Java technologies (`Java 17+`, `Jakarta Servlets 6.0`, `JSP`, `JSTL`, `JDBC`, and `MySQL`). 

The application solves the critical vulnerabilities frequently found in student voting projects:
- **Duplicate voting** is physically eliminated at the database storage engine layer via a composite `UNIQUE(election_id, voter_id)` index.
- **Vote tampering or partial writes** are prevented using ACID-compliant JDBC transaction rollbacks.
- **Ballot privacy** is strictly enforced: normal voters cannot view the selected candidate in their profile or voting history; only tamper-evident cryptographic SHA-256 receipts are shown.
- **CSRF, XSS, and SQL Injection** are defended against at the application boundary via dedicated security filters and `PreparedStatement` query parametrization.

---

## 2. Key Features

### For Voters:
- **Registration & Authentication:** Secure enrollment with input validation and BCrypt password encryption.
- **Voter Dashboard:** Real-time visibility into open campus ballots and active voting windows.
- **Ballot Casting:** Intuitive candidate selection cards with emblems, party affiliations, and confirmation dialogues.
- **Tamper-Evident Receipts:** Immediate SHA-256 cryptographic verification token upon submission.
- **Ballot Secrecy & Status Ledger:** Transparent proof of participation while keeping the individual choice completely confidential.
- **Duplicate Vote Prevention:** Hard database-level restriction preventing multiple ballots per election.

### For Election Administrators:
- **Isolated Admin Portal:** Dedicated administrative login endpoint protected by `AdminFilter`.
- **System Metrics Dashboard:** Live metrics displaying registered voters, cast ballots, active elections, and candidates.
- **Election Lifecycle Management:** Schedule start/end dates, activate voting windows, and halt elections.
- **Candidate Registry:** Add candidates, assign parties, designate ballot symbols, edit details, or deactivate contenders.
- **Voter Account Administration:** Direct enrollment, inspection, and temporary deactivation of voter accounts.
- **Live Results & Certification:** Real-time percentage breakdowns, candidate rankings, and one-click official public certification.
- **Security Audit Logging:** Immutable trail capturing login attempts, IP addresses, user agents, and administrative actions.

---

## 3. Technology Stack

| Layer | Component | Description |
| :--- | :--- | :--- |
| **Runtime & Language** | Java SE 17+ | Eclipse Adoptium / Oracle JDK 17+ |
| **Web Server / Servlet Engine** | Apache Tomcat 10.1+ | Jakarta EE 10 (`jakarta.servlet.*` API) |
| **Backend Architecture** | Java Servlets & DAO | Clean MVC pattern with PreparedStatements |
| **View Layer** | JSP & JSTL 3.0 | Scriptlet-free templates with escaping |
| **Database** | MySQL 8.0+ | InnoDB engine with Foreign Keys & Constraints |
| **Password Security** | BCrypt (`at.favre.lib:bcrypt`) | Cost factor 12 with automatic salt generation |
| **Build & Dependency Tool** | Apache Maven 3.9+ | Standard WAR packaging |
| **Frontend Styling & Scripts** | HTML5, CSS3, JavaScript | Responsive dark mode theme using Google Font Inter |

---

## 4. Software Architecture (MVC)

```
c:\...\Voting/
├── pom.xml                               # Maven project descriptor
├── mvn.cmd / mvnw.cmd                    # Maven execution wrappers
├── schema.sql                            # Complete MySQL database initialization script
├── .env.example                          # Environment variable template
├── src/
│   ├── main/
│   │   ├── java/
│   │   │   ├── controller/               # MVC Controllers (Jakarta Servlets)
│   │   │   │   ├── LoginServlet.java     # Authentication, lockout & session regeneration
│   │   │   │   ├── RegisterServlet.java  # Voter account self-registration
│   │   │   │   ├── LogoutServlet.java    # Session invalidation & cleanup
│   │   │   │   ├── VotingServlet.java    # Ballot submission & receipt generation
│   │   │   │   ├── ElectionServlet.java  # Election listing & admin lifecycle control
│   │   │   │   ├── CandidateServlet.java # Candidate management & profile viewing
│   │   │   │   ├── ResultServlet.java    # Election tally & publication
│   │   │   │   └── AdminServlet.java     # Admin stats & voter management
│   │   │   │
│   │   │   ├── dao/                      # Data Access Objects (Raw JDBC)
│   │   │   │   ├── UserDAO.java          # PreparedStatements for user queries
│   │   │   │   ├── ElectionDAO.java      # Election data operations
│   │   │   │   ├── CandidateDAO.java     # Candidate records
│   │   │   │   ├── VoteDAO.java          # Atomic voting transactions & tallies
│   │   │   │   └── AuditLogDAO.java      # Security audit trail logging
│   │   │   │
│   │   │   ├── model/                    # Domain Entity Models
│   │   │   │   ├── User.java
│   │   │   │   ├── Election.java
│   │   │   │   ├── Candidate.java
│   │   │   │   ├── Vote.java
│   │   │   │   └── AuditLog.java
│   │   │   │
│   │   │   ├── filter/                   # Security Filters
│   │   │   │   ├── SecurityHeadersFilter.java # CSP, HSTS, X-Frame-Options, Cache-Control
│   │   │   │   ├── CSRFProtectionFilter.java  # Token validation for state-changing requests
│   │   │   │   ├── AuthFilter.java            # Protects voter areas from unauthenticated users
│   │   │   │   └── AdminFilter.java           # Protects /admin/* routes with role verification
│   │   │   │
│   │   │   └── util/                     # Security & Database Utilities
│   │   │       ├── DatabaseConnection.java    # JDBC connection manager (.env support)
│   │   │       ├── PasswordUtil.java          # BCrypt cost-12 hashing
│   │   │       ├── CSRFUtil.java              # Constant-time token generator & validator
│   │   │       ├── ValidationUtil.java        # Server-side input & parameter validation
│   │   │       └── SecurityUtil.java          # XSS escaping, client IP & vote hash receipt
│   │   │
│   │   └── webapp/
│   │       ├── WEB-INF/
│   │       │   └── web.xml               # Servlet 6.0 deployment descriptor
│   │       ├── css/
│   │       │   └── style.css             # Unified modern dark theme design system
│   │       ├── js/
│   │       │   └── validation.js         # Interactive ballot modal & client validation
│   │       ├── admin/                    # Administrative Views
│   │       │   ├── login.jsp
│   │       │   ├── dashboard.jsp
│   │       │   ├── elections.jsp
│   │       │   ├── candidates.jsp
│   │       │   ├── voters.jsp
│   │       │   ├── results.jsp
│   │       │   └── audit-logs.jsp
│   │       ├── index.jsp                 # Landing page & security overview
│   │       ├── login.jsp                 # Voter sign in
│   │       ├── register.jsp              # Voter enrollment
│   │       ├── dashboard.jsp             # Voter dashboard
│   │       ├── elections.jsp             # Public elections directory & published results
│   │       ├── candidates.jsp            # Candidate directory
│   │       ├── vote.jsp                  # Ballot voting screen with modal confirmation
│   │       ├── vote-success.jsp          # Cryptographic receipt screen
│   │       ├── my-status.jsp             # Voter's confidential participation ledger
│   │       └── error.jsp                 # Secure generic error page (no stack traces)
│   │
│   └── test/java/                        # Comprehensive Automated JUnit 5 Test Suite
│       ├── util/PasswordUtilTest.java
│       ├── util/ValidationUtilTest.java
│       ├── util/SecurityUtilTest.java
│       └── dao/VotingSecurityTest.java   # In-memory H2 MySQL mode integration tests
```

---

## 5. Database Setup & MySQL Schema

### Setup Instructions
1. Open MySQL Command Line Client or MySQL Workbench.
2. Execute the included script `schema.sql`:
   ```bash
   mysql -u root -p < schema.sql
   ```
   Or execute directly in MySQL CLI:
   ```sql
   source schema.sql;
   ```

### Schema Summary
The database `online_voting` utilizes InnoDB tables with referential integrity and checks:

```sql
CREATE DATABASE IF NOT EXISTS online_voting CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE online_voting;

-- 1. Users Table
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'VOTER',
    is_verified BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_user_role CHECK (role IN ('VOTER', 'ADMIN'))
) ENGINE=InnoDB;

-- 2. Elections Table
CREATE TABLE elections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    election_name VARCHAR(150) NOT NULL,
    description TEXT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'UPCOMING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_election_status CHECK (status IN ('UPCOMING', 'ACTIVE', 'COMPLETED', 'PUBLISHED'))
) ENGINE=InnoDB;

-- 3. Candidates Table
CREATE TABLE candidates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    election_id INT NOT NULL,
    candidate_name VARCHAR(100) NOT NULL,
    party VARCHAR(100) NOT NULL,
    symbol VARCHAR(50) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_candidate_election FOREIGN KEY (election_id)
        REFERENCES elections (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. Votes Table (Critical Duplicate Protection)
CREATE TABLE votes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    election_id INT NOT NULL,
    voter_id INT NOT NULL,
    candidate_id INT NOT NULL,
    vote_hash VARCHAR(64) NOT NULL,
    voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vote_election FOREIGN KEY (election_id) REFERENCES elections (id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_voter FOREIGN KEY (voter_id) REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_candidate FOREIGN KEY (candidate_id) REFERENCES candidates (id) ON DELETE CASCADE,
    CONSTRAINT uq_election_voter UNIQUE (election_id, voter_id)
) ENGINE=InnoDB;

-- 5. Audit Logs Table
CREATE TABLE audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    action VARCHAR(100) NOT NULL,
    ip_address VARCHAR(50),
    user_agent VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB;
```

---

## 6. Environment Variables & Configuration

The application reads its database configuration dynamically from environment variables, preventing committed credentials:

| Variable | Description | Default Fallback Value |
| :--- | :--- | :--- |
| `DB_URL` | JDBC Connection URL with SSL/Timezone flags | `jdbc:mysql://localhost:3306/online_voting?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC` |
| `DB_USERNAME` | MySQL user account | `root` |
| `DB_PASSWORD` | MySQL account password | `""` (empty string) |

### Setting Environment Variables in Windows (PowerShell):
```powershell
$env:DB_URL="jdbc:mysql://localhost:3306/online_voting?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
$env:DB_USERNAME="root"
$env:DB_PASSWORD="your_mysql_password"
```

### Setting Environment Variables in Tomcat:
Add to `$CATALINA_HOME/bin/setenv.bat`:
```batch
set "DB_URL=jdbc:mysql://localhost:3306/online_voting?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
set "DB_USERNAME=root"
set "DB_PASSWORD=your_mysql_password"
```

---

## 7. Building with Maven

The project comes with a configured Maven wrapper (`.\mvn.cmd` and `.\mvnw.cmd`).

### 1. Compile and Run Automated Tests:
```powershell
.\mvn.cmd clean test
```
*Executes all 17 automated tests verifying BCrypt hashing, XSS escaping, parameter validation, voting transactions, duplicate vote prevention, and concurrency resilience.*

### 2. Package the Deployable WAR File:
```powershell
.\mvn.cmd clean package
```
Output:
`target/online-voting.war` (~7.8 MB) containing all dependencies.

---

## 8. Deploying to Apache Tomcat 10+

> **Important:** This project uses Jakarta EE 10 packages (`jakarta.servlet.*`), designed for **Apache Tomcat 10.0+ / 10.1+**. Do not deploy on Tomcat 9 or earlier.

### Step 1: Copy WAR File
Copy `target/online-voting.war` into your Tomcat installation's `webapps` directory:
```powershell
Copy-Item ".\target\online-voting.war" -Destination "C:\apache-tomcat-10.1.x\webapps\"
```

### Step 2: Start Tomcat
Navigate to Tomcat's `bin` directory and execute:
```powershell
.\startup.bat
```

### Step 3: Access Application
Open your browser and navigate to:
```
http://localhost:8080/online-voting/
```

---

## 9. Running in Antigravity IDE / VS Code

1. **Open Workspace:** Open the project root folder in Antigravity IDE or VS Code.
2. **Java Extension Pack:** Ensure the *Extension Pack for Java* (Language Support for Java, Maven for Java) is installed.
3. **Community Server Connectors / Tomcat Extension:**
   - Install the *Community Server Connectors* or *Tomcat for Java* extension.
   - Point the server to your local Apache Tomcat 10.1+ installation directory.
   - Right-click `target/online-voting.war` or the project root and select **"Run on Server"**.
4. **Browser Testing:** Open `http://localhost:8080/online-voting/` in the integrated browser preview.

---

## 10. Step-by-Step Workflow Guides

### Default Pre-Configured Credentials

| Role | Email Address | College ID Card Number | Password | Login Portal |
| :--- | :--- | :--- | :--- | :--- |
| **Chief Administrator** | `admin@voting.edu` | `ALU-ADMIN-01` | Alliance University | Office of Chief Election Officer | Faculty / Admin | `Admin@123` |
| **Student Voter (Demo 1)** | `voter@voting.edu` | `ALU-2026-1001` | Alliance University | B.Tech Electronics | 4th Year (Joined 2022) | `Voter@123` |
| **Student Voter (Demo 2)** | `kakashbtech24@ced.alliance.edu.in` | `AU-2024-CED-014` | Alliance University (CED) | B.Tech Computer Science | 2nd Year (Joined 2024) | `Voter@123` |

---

### Student Voter Authentication with Intelligent College ID Scanner
1. Navigate to the voter login portal: `http://localhost:8080/online-voting/login.jsp` (or registration: `/register.jsp`).
2. Click the **🪪 Scan College ID** button to open the scanner modal dialog.
3. The scanner provides three flexible scanning modes:
   - **📹 Live Camera:** Point your physical student ID card at your webcam. A real-time laser animation scans the card. Click **"Capture & Detect Details"** to automatically crop the student portrait and extract all credentials. *(If camera permission was denied in your browser, a clear in-modal guidance banner guides you to allow Camera access via the address bar 🔒 lock icon).*
   - **📁 Upload Card Photo:** Drag-and-drop or select any student ID card image file (JPG, PNG, WebP) directly from your computer.
   - **🎯 Alliance ID Demos:** Click preset demo cards (`Akash K M - AU-2024-CED-014` or `John Doe - ALU-2026-1001`) for instantaneous evaluation.
4. **Intelligent Detection Engine Automatically Extracts:**
   - 🏛️ **College / University:** Identifies the issuing campus (e.g. *Alliance University - College of Engineering & Design*).
   - 🎓 **Degree Program:** Identifies the student's department (e.g. *B.Tech Computer Science & Engineering*).
   - 📅 **Joining Year:** Extracts admission year (e.g. *2024*).
   - ⏳ **Current Academic Standing:** Computes standing based on year (e.g. *2nd Year - Batch 2024–2028*).
   - 🪪 **Verified ID Number:** Formats the registration code (e.g. *AU-2024-CED-014*).
   - 👤 **Student Photo:** Crops and extracts the official student portrait photo from the card to an HTML5 canvas and converts to base64.
5. Click **"✓ Apply Scanned Card to Sign In"**. The scanner automatically:
   - Populates the College ID Card field.
   - Embeds the verified College Name, Program, Joining Year, Standing, and Photo.
   - Renders a **Verified Student Card Preview Badge** directly on the login form showing the student's portrait and credentials.
6. Enter password (`Voter@123`) and click **🛡️ Authenticate & Enter Ballot Box**.
7. The student lands on the **Voter Dashboard** (`/dashboard.jsp`), where their student photo, college, program, batch, and status are prominently displayed!

---

### Enrolling Voters
1. **Self-Registration:** A student navigates to `/register.jsp`, fills in full name, campus email, College ID card number (e.g. `AU-2026-CED-099`), and password.
2. **Admin Enrollment:** An administrator navigates to `/admin/voters`, enters the student's name, email, College ID, and initial password, or toggles active/inactive status.

---

### Creating an Election
1. Log in as Admin at `/admin/login.jsp`.
2. Navigate to **Manage Elections** (`/admin/elections`).
3. Fill in Title, Description, Voting Start Date/Time, and Voting End Date/Time.
4. Click **Create Election**. The election is created with status `UPCOMING`.
5. When ready, click **▶ Start Voting** to set status to `ACTIVE`.

---

### Registering Candidates
1. In the Admin Center, go to **Manage Candidates** (`/admin/candidates`).
2. Select the target election from the dropdown.
3. Enter Candidate Full Name, Party/Slate Name, and Emblem/Symbol (e.g. "Torch", "Book", "Rising Sun").
4. Click **Add Candidate to Ballot**.

---

### Casting a Vote
1. Log in as a voter at `/login.jsp` (e.g. `voter@voting.edu` / `Voter@123` with scanned College ID `ALU-2026-1001`).
2. From the **Voter Dashboard** (`/dashboard.jsp`), click **Cast Your Vote** on any active election.
3. On the ballot page (`/vote.jsp`), click the candidate card to select your choice.
4. Click **Confirm & Submit Vote**.
5. An interactive confirmation modal appears:
   > *"Are you sure you want to submit your vote? Your vote cannot be changed after submission."*
6. Click **Yes, Submit My Vote**.
7. The system redirects to `/vote-success.jsp` displaying your unique **SHA-256 Receipt Hash**.

---

### Results & Official Publication
1. Administrators can view live tallies and percentage bars at `/admin/results`.
2. When the election closes, the administrator clicks **📢 Publish Results Publicly**.
3. Status changes to `PUBLISHED`, enabling public students and voters to inspect certified results on the public `/elections.jsp` page.

---

## 11. Security Engineering & Protection Analysis

### 1. Database-Level Uniqueness
```sql
CONSTRAINT uq_election_voter UNIQUE (election_id, voter_id)
```
- Most student projects rely merely on `if (hasVoted)` statements, which are vulnerable to race conditions (two parallel tabs clicking submit simultaneously).
- In this system, the database storage engine guarantees that a voter can never be inserted twice for the same election, even in high-concurrency conditions.

### 2. Atomic ACID JDBC Transactions
In [`VoteDAO.java`](file:///c:/Users/AKASH%20K%20M/OneDrive%20-%20Alliance%20University/New%20folder/Voting/src/main/java/dao/VoteDAO.java):
```java
con.setAutoCommit(false);
// 1. Verify election exists & is active
// 2. Verify candidate belongs to election & is active
// 3. Verify voter has not voted
// 4. Insert vote
// 5. Insert audit log
con.commit();
```
If any check fails or duplicate error occurs, `con.rollback()` is immediately invoked, preventing inconsistent or partial states.

### 3. Ballot Secrecy & Privacy Preservation
- In accordance with democratic principles, once a vote is cast, the candidate selected is **never linked or revealed** in the voter's dashboard or history.
- The voter dashboard only displays confirmation receipts (`vote_hash` and timestamp), preventing vote-coercion or ballot inspection by unauthorized parties.

### 4. Cross-Site Request Forgery (CSRF) Defense
- Managed by [`CSRFProtectionFilter.java`](file:///c:/Users/AKASH%20K%20M/OneDrive%20-%20Alliance%20University/New%20folder/Voting/src/main/java/filter/CSRFProtectionFilter.java) and [`CSRFUtil.java`](file:///c:/Users/AKASH%20K%20M/OneDrive%20-%20Alliance%20University/New%20folder/Voting/src/main/java/util/CSRFUtil.java).
- Cryptographically secure 32-byte tokens generated via `SecureRandom`.
- All `POST` forms require `_csrf` tokens; validation uses constant-time byte comparison (`MessageDigest.isEqual`) to defeat timing attacks.

### 5. Cross-Site Scripting (XSS) & Header Hardening
- [`SecurityHeadersFilter.java`](file:///c:/Users/AKASH%20K%20M/OneDrive%20-%20Alliance%20University/New%20folder/Voting/src/main/java/filter/SecurityHeadersFilter.java) injects:
  - `Content-Security-Policy`: restricts origins and script execution.
  - `X-Frame-Options: DENY`: prevents clickjacking inside iframe containers.
  - `X-Content-Type-Options: nosniff`: blocks MIME-type confusion attacks.
  - `Cache-Control: no-cache, no-store, must-revalidate`: prevents backward browser navigation from leaking authenticated data.

### 6. Brute Force Protection & Rate Limiting
- In [`LoginServlet.java`](file:///c:/Users/AKASH%20K%20M/OneDrive%20-%20Alliance%20University/New%20folder/Voting/src/main/java/controller/LoginServlet.java), IP-level attempt tracking automatically locks out clients after 5 consecutive failed attempts for 3 minutes.
- Error messages are strictly generic: *"Invalid email or password"*, preventing email enumeration.

---

## 12. Automated Test Suite

Run tests via Maven:
```powershell
.\mvn.cmd test
```

### Test Coverage Highlights:
1. **`PasswordUtilTest`:** BCrypt hash generation, cost-12 verification, wrong-password rejection.
2. **`ValidationUtilTest`:** Email regex checks, SQL injection string neutralization, parameter boundary checks.
3. **`SecurityUtilTest`:** HTML character escaping, SHA-256 vote receipt hash generation.
4. **`VotingSecurityTest` (In-Memory H2 MySQL Mode Integration Tests):**
   - Successful voter registration.
   - Duplicate email registration rejection.
   - Successful login and wrong password rejection.
   - Candidate-election mismatch detection.
   - Atomic vote casting and receipt privacy verification.
   - **Single-vote constraint rejection** upon second attempt.
   - **Concurrent duplicate vote attack:** multithreaded simulation ensuring exactly 1 concurrent vote commits while the second is aborted.
   - Election tally calculation and status transitions.

---

## 13. Known Limitations & Future Scope

While suitable for academic projects and campus student councils, the following enhancements could be considered for larger institutional deployments:

1. **End-to-End Cryptographic Zero-Knowledge Proofs (ZKPs):**
   Homomorphic encryption (e.g. Paillier cryptosystem) or ZK-SNARKs could allow anyone to mathematically verify the complete tally without decrypting individual ballots.
2. **Hardware Security Modules (HSM):**
   Government elections store digital election signing keys in dedicated FIPS 140-2 Level 3 hardware security modules.
3. **Multi-Factor Authentication (MFA):**
   Future iterations could add WebAuthn / TOTP authenticators for administrator actions.
4. **Distributed Ledger:**
   Deploying vote hashes to an immutable private permissioned consortium blockchain (e.g. Hyperledger Fabric) for cross-institutional auditing.

---

## License & Author
- **Author:** College Micro Project Submission
- **Year:** 2026
- **Status:** Complete & Ready for Evaluation
