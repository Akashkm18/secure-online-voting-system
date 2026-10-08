package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Election implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String electionName;
    private String description;
    private Timestamp startTime;
    private Timestamp endTime;
    private String status; // UPCOMING, ACTIVE, COMPLETED, PUBLISHED
    private Timestamp createdAt;
    private int totalVotes; // aggregate metric

    public Election() {}

    public Election(int id, String electionName, String description, Timestamp startTime, Timestamp endTime, String status, Timestamp createdAt) {
        this.id = id;
        this.electionName = electionName;
        this.description = description;
        this.startTime = startTime;
        this.endTime = endTime;
        this.status = status;
        this.createdAt = createdAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getElectionName() { return electionName; }
    public void setElectionName(String electionName) { this.electionName = electionName; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }

    public Timestamp getStartTime() { return startTime; }
    public void setStartTime(Timestamp startTime) { this.startTime = startTime; }

    public Timestamp getEndTime() { return endTime; }
    public void setEndTime(Timestamp endTime) { this.endTime = endTime; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public int getTotalVotes() { return totalVotes; }
    public void setTotalVotes(int totalVotes) { this.totalVotes = totalVotes; }

    public boolean isActive() {
        return "ACTIVE".equalsIgnoreCase(this.status);
    }

    public boolean isPublished() {
        return "PUBLISHED".equalsIgnoreCase(this.status);
    }

    public boolean isCompleted() {
        return "COMPLETED".equalsIgnoreCase(this.status) || "PUBLISHED".equalsIgnoreCase(this.status);
    }
}
