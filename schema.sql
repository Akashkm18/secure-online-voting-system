-- =====================================================================
-- SECURE ONLINE VOTING SYSTEM - DATABASE INITIALIZATION SCRIPT
-- Database: online_voting
-- =====================================================================

CREATE DATABASE IF NOT EXISTS online_voting
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE online_voting;

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
    is_verified BOOLEAN DEFAULT TRUE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_user_role CHECK (role IN ('VOTER', 'ADMIN'))
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
    CONSTRAINT chk_election_status CHECK (status IN ('UPCOMING', 'ACTIVE', 'COMPLETED', 'PUBLISHED'))
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. Table: candidates
-- ---------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS candidates (
    id INT AUTO_INCREMENT PRIMARY KEY,
    election_id INT NOT NULL,
    candidate_name VARCHAR(100) NOT NULL,
    party VARCHAR(100) NOT NULL,
    symbol VARCHAR(50) NOT NULL,
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
    action VARCHAR(100) NOT NULL,
    ip_address VARCHAR(50),
    user_agent VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id)
        REFERENCES users (id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- INITIAL SEED DATA & CLEANUP
-- Administrator Account: kakashbtech24@ced.alliance.edu.in / Akas@2006
-- (BCrypt cost 12: $2a$12$Tpnd6aLSxitfGGQy6YtZSOvbMKH.g0YY0hudAVURsnoKK7Z2kic4.)
-- ---------------------------------------------------------------------

-- Remove legacy mock accounts and old voter test records
DELETE FROM votes WHERE voter_id IN (SELECT id FROM users WHERE college_id = 'AU-2024-CED-014' OR email IN ('voter@voting.edu', 'admin@voting.edu'));
DELETE FROM users WHERE college_id = 'AU-2024-CED-014' OR email IN ('voter@voting.edu', 'admin@voting.edu');

-- Upsert System Administrator
INSERT INTO users (full_name, email, college_id, college_name, program_name, joining_year, study_year, password_hash, role, is_verified, is_active)
VALUES ('System Administrator', 'kakashbtech24@ced.alliance.edu.in', 'ADMIN-01', 'Office of Chief Election Officer', 'Election Commission', 2024, 'Faculty / Admin', '$2a$12$Tpnd6aLSxitfGGQy6YtZSOvbMKH.g0YY0hudAVURsnoKK7Z2kic4.', 'ADMIN', TRUE, TRUE)
ON DUPLICATE KEY UPDATE password_hash = '$2a$12$Tpnd6aLSxitfGGQy6YtZSOvbMKH.g0YY0hudAVURsnoKK7Z2kic4.', role = 'ADMIN', is_active = TRUE;

-- Sample Initial Election
INSERT INTO elections (id, election_name, description, start_time, end_time, status)
SELECT 1, 'Student Council Presidential Election 2026', 'Annual election to select the University Student Council President and Executive Cabinet representatives.', NOW() - INTERVAL 1 HOUR, NOW() + INTERVAL 7 DAY, 'ACTIVE'
WHERE NOT EXISTS (SELECT 1 FROM elections WHERE id = 1);

-- Sample Candidates for Election 1
INSERT INTO candidates (id, election_id, candidate_name, party, symbol, is_active)
SELECT 1, 1, 'Alex Johnson', 'Alliance Innovators', 'Torch', TRUE
WHERE NOT EXISTS (SELECT 1 FROM candidates WHERE id = 1);

INSERT INTO candidates (id, election_id, candidate_name, party, symbol, is_active)
SELECT 2, 1, 'Maya Sharma', 'Youth Progressive Wing', 'Rising Sun', TRUE
WHERE NOT EXISTS (SELECT 1 FROM candidates WHERE id = 2);

INSERT INTO candidates (id, election_id, candidate_name, party, symbol, is_active)
SELECT 3, 1, 'Carlos Silva', 'Tech & Scholars United', 'Open Book', TRUE
WHERE NOT EXISTS (SELECT 1 FROM candidates WHERE id = 3);

