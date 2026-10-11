-- =====================================================================
-- SECURE ONLINE VOTING SYSTEM - DATABASE INITIALIZATION & MIGRATION SCRIPT
-- Database: online_voting (Compatible with MySQL 8.0+ and PostgreSQL 14+)
-- =====================================================================

-- ---------------------------------------------------------------------
-- 1. Table: users
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    college_id VARCHAR(50) NULL UNIQUE,
    college_name VARCHAR(150) NULL DEFAULT 'Alliance University',
    program_name VARCHAR(100) NULL DEFAULT 'B.Tech Computer Science & Engineering',
    joining_year INT NULL DEFAULT 2024,
    study_year VARCHAR(30) NULL DEFAULT '2nd Year',
    photo_base64 MEDIUMTEXT NULL,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'VOTER',
    status VARCHAR(20) NOT NULL DEFAULT 'APPROVED',
    rejection_reason VARCHAR(255) NULL,
    force_password_reset BOOLEAN DEFAULT FALSE,
    is_verified BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_user_role CHECK (role IN ('VOTER', 'ADMIN')),
    CONSTRAINT chk_user_status CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED', 'DISABLED'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. Table: elections
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS elections (
    id INT AUTO_INCREMENT PRIMARY KEY,
    election_name VARCHAR(150) NOT NULL,
    description TEXT,
    start_time DATETIME NOT NULL,
    end_time DATETIME NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'UPCOMING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_election_status CHECK (status IN ('UPCOMING', 'ACTIVE', 'COMPLETED', 'PUBLISHED', 'ARCHIVED'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Table: candidates
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS candidates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    election_id INT NOT NULL,
    candidate_name VARCHAR(100) NOT NULL,
    party VARCHAR(100) NOT NULL,
    position VARCHAR(100) NOT NULL DEFAULT 'Executive Representative',
    symbol VARCHAR(50) NOT NULL,
    bio VARCHAR(500) NULL,
    manifesto VARCHAR(1000) NULL,
    photo_data LONGBLOB NULL, -- In PostgreSQL use BYTEA
    photo_type VARCHAR(20) NULL,
    photo_updated_at TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    CONSTRAINT fk_candidate_election FOREIGN KEY (election_id)
        REFERENCES elections (id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. Table: votes
-- Critical Security Requirement: UNIQUE(election_id, voter_id)
-- Enforces one vote per voter per election at database level.
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS votes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    election_id INT NOT NULL,
    voter_id INT NOT NULL,
    candidate_id INT NOT NULL,
    vote_hash VARCHAR(64) NOT NULL,
    voted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_vote_election FOREIGN KEY (election_id)
        REFERENCES elections (id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_voter FOREIGN KEY (voter_id)
        REFERENCES users (id) ON DELETE CASCADE,
    CONSTRAINT fk_vote_candidate FOREIGN KEY (candidate_id)
        REFERENCES candidates (id) ON DELETE CASCADE,
    CONSTRAINT uq_election_voter UNIQUE (election_id, voter_id)
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. Table: audit_logs
-- Tracks security events: logins, votes, administrative modifications
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS audit_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NULL,
    user_role VARCHAR(20) NULL,
    action VARCHAR(100) NOT NULL,
    ip_address VARCHAR(50),
    user_agent VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- INITIAL SEED DATA
-- ---------------------------------------------------------------------

-- Chief Election Administrator (Backup Admin account)
INSERT INTO users (full_name, email, college_id, college_name, program_name, joining_year, study_year, password_hash, role, status, is_verified, is_active)
VALUES ('Chief Election Officer', 'admin@alliance.edu.in', 'ADMIN-AU', 'Office of Chief Election Officer', 'Election Commission', 2024, 'Faculty / Admin', '$2a$12$/nPDV4EbzMJsKlktc12sWel4wajpR46zcICV.2mh6kg3OCfqJ77h.', 'ADMIN', 'APPROVED', TRUE, TRUE)
ON DUPLICATE KEY UPDATE role = 'ADMIN', status = 'APPROVED', is_active = TRUE;

-- Primary Administrator (Akash K M)
INSERT INTO users (full_name, email, college_id, college_name, program_name, joining_year, study_year, password_hash, role, status, is_verified, is_active)
VALUES ('Akash K M', 'kakashbtech24@ced.alliance.edu.in', '4107241562', 'Alliance University', 'B.Tech Computer Science & Engineering', 2024, '2nd Year', '$2a$12$/nPDV4EbzMJsKlktc12sWel4wajpR46zcICV.2mh6kg3OCfqJ77h.', 'ADMIN', 'APPROVED', TRUE, TRUE)
ON DUPLICATE KEY UPDATE role = 'ADMIN', status = 'APPROVED', is_active = TRUE;

-- Sample Active Election
INSERT INTO elections (id, election_name, description, start_time, end_time, status)
SELECT 1, 'Student Council Presidential Election 2026', 'Annual election to select the University Student Council President and Executive Cabinet representatives.', NOW() - INTERVAL 1 HOUR, NOW() + INTERVAL 7 DAY, 'ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM elections WHERE id = 1);

-- Sample Candidates for Election 1 (Default avatars dynamically generated via /candidate-photo)
INSERT INTO candidates (id, election_id, candidate_name, party, position, symbol, bio, manifesto, is_active)
SELECT 1, 1, 'Alex Johnson', 'Alliance Innovators', 'President', 'Torch', 
       'Senior student representative committed to expanding digital campus resources and transparent governance.', 
       '1. 24/7 library access during exam cycles.\n2. Streamlined funding allocation for student academic clubs.\n3. Transparent semester fee breakdown and lab upgrades.', 
       TRUE
WHERE NOT EXISTS (SELECT 1 FROM candidates WHERE id = 1);

INSERT INTO candidates (id, election_id, candidate_name, party, position, symbol, bio, manifesto, is_active)
SELECT 2, 1, 'Maya Sharma', 'Youth Progressive Wing', 'Vice President', 'Rising Sun', 
       'Student advocate championing student mental health, campus accessibility, and inclusive sports.', 
       '1. Enhanced student wellbeing counselors on campus.\n2. Renovation of student recreation spaces and sports courts.\n3. Student dining committee oversight and quality audits.', 
       TRUE
WHERE NOT EXISTS (SELECT 1 FROM candidates WHERE id = 2);

INSERT INTO candidates (id, election_id, candidate_name, party, position, symbol, bio, manifesto, is_active)
SELECT 3, 1, 'Carlos Silva', 'Tech & Scholars United', 'General Secretary', 'Open Book', 
       'Engineering honor society lead focused on career mentorship and student-industry alliances.', 
       '1. Annual campus hackathon and tech symposium sponsorship.\n2. Peer-to-peer tutoring network across disciplines.\n3. Real-time campus transport shuttle tracking mobile app.', 
       TRUE
WHERE NOT EXISTS (SELECT 1 FROM candidates WHERE id = 3);

-- =====================================================================
-- DATABASE MIGRATION SCRIPTS FOR EXISTING DEPLOYMENTS
-- (The application also runs these automatically at startup via DatabaseMigration.java)
-- =====================================================================

/*
-- ---------------------------------------------------------------------
-- MYSQL MIGRATION SCRIPT
-- ---------------------------------------------------------------------
ALTER TABLE candidates ADD COLUMN position VARCHAR(100) NOT NULL DEFAULT 'Executive Representative';
ALTER TABLE candidates ADD COLUMN bio VARCHAR(500) NULL;
ALTER TABLE candidates ADD COLUMN manifesto VARCHAR(1000) NULL;
ALTER TABLE candidates ADD COLUMN photo_data LONGBLOB NULL;
ALTER TABLE candidates ADD COLUMN photo_type VARCHAR(20) NULL;
ALTER TABLE candidates ADD COLUMN photo_updated_at TIMESTAMP NULL;

ALTER TABLE users ADD COLUMN status VARCHAR(20) NOT NULL DEFAULT 'APPROVED';
ALTER TABLE users ADD COLUMN rejection_reason VARCHAR(255) NULL;
ALTER TABLE users ADD COLUMN force_password_reset BOOLEAN DEFAULT FALSE;

ALTER TABLE audit_logs ADD COLUMN user_role VARCHAR(20) NULL;

-- ---------------------------------------------------------------------
-- POSTGRESQL MIGRATION SCRIPT
-- ---------------------------------------------------------------------
ALTER TABLE candidates ADD COLUMN IF NOT EXISTS position VARCHAR(100) NOT NULL DEFAULT 'Executive Representative';
ALTER TABLE candidates ADD COLUMN IF NOT EXISTS bio VARCHAR(500) NULL;
ALTER TABLE candidates ADD COLUMN IF NOT EXISTS manifesto VARCHAR(1000) NULL;
ALTER TABLE candidates ADD COLUMN IF NOT EXISTS photo_data BYTEA NULL;
ALTER TABLE candidates ADD COLUMN IF NOT EXISTS photo_type VARCHAR(20) NULL;
ALTER TABLE candidates ADD COLUMN IF NOT EXISTS photo_updated_at TIMESTAMP NULL;

ALTER TABLE users ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'APPROVED';
ALTER TABLE users ADD COLUMN IF NOT EXISTS rejection_reason VARCHAR(255) NULL;
ALTER TABLE users ADD COLUMN IF NOT EXISTS force_password_reset BOOLEAN DEFAULT FALSE;

ALTER TABLE audit_logs ADD COLUMN IF NOT EXISTS user_role VARCHAR(20) NULL;
*/
