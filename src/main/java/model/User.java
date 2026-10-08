package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class User implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String fullName;
    private String email;
    private String collegeId;
    private String collegeName;
    private String programName;
    private Integer joiningYear;
    private String studyYear;
    private String photoBase64;
    private String passwordHash;
    private String role;
    private boolean verified;
    private boolean active;
    private Timestamp createdAt;

    public User() {}

    public User(int id, String fullName, String email, String collegeId, String passwordHash, String role, boolean verified, boolean active, Timestamp createdAt) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.collegeId = collegeId;
        this.passwordHash = passwordHash;
        this.role = role;
        this.verified = verified;
        this.active = active;
        this.createdAt = createdAt;
    }

    public User(int id, String fullName, String email, String collegeId, String collegeName, String programName, Integer joiningYear, String studyYear, String photoBase64, String passwordHash, String role, boolean verified, boolean active, Timestamp createdAt) {
        this.id = id;
        this.fullName = fullName;
        this.email = email;
        this.collegeId = collegeId;
        this.collegeName = collegeName;
        this.programName = programName;
        this.joiningYear = joiningYear;
        this.studyYear = studyYear;
        this.photoBase64 = photoBase64;
        this.passwordHash = passwordHash;
        this.role = role;
        this.verified = verified;
        this.active = active;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getFullName() { return fullName; }
    public void setFullName(String fullName) { this.fullName = fullName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getCollegeId() { return collegeId; }
    public void setCollegeId(String collegeId) { this.collegeId = collegeId; }

    public String getCollegeName() { return collegeName; }
    public void setCollegeName(String collegeName) { this.collegeName = collegeName; }

    public String getProgramName() { return programName; }
    public void setProgramName(String programName) { this.programName = programName; }

    public Integer getJoiningYear() { return joiningYear; }
    public void setJoiningYear(Integer joiningYear) { this.joiningYear = joiningYear; }

    public String getStudyYear() { return studyYear; }
    public void setStudyYear(String studyYear) { this.studyYear = studyYear; }

    public String getPhotoBase64() { return photoBase64; }
    public void setPhotoBase64(String photoBase64) { this.photoBase64 = photoBase64; }

    public String getPasswordHash() { return passwordHash; }
    public void setPasswordHash(String passwordHash) { this.passwordHash = passwordHash; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public boolean isVerified() { return verified; }
    public void setVerified(boolean verified) { this.verified = verified; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public boolean isAdmin() {
        return "ADMIN".equalsIgnoreCase(this.role);
    }
}
