package model;

import java.io.Serializable;

public class Candidate implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int electionId;
    private String electionName;
    private String candidateName;
    private String party;
    private String symbol;
    private String position;
    private String bio;
    private String manifesto;
    private byte[] photoData;
    private String photoType;
    private java.sql.Timestamp photoUpdatedAt;
    private boolean active;
    private int voteCount;
    private double votePercentage;

    public Candidate() {}

    public Candidate(int id, int electionId, String candidateName, String party, String symbol, boolean active) {
        this.id = id;
        this.electionId = electionId;
        this.candidateName = candidateName;
        this.party = party;
        this.symbol = symbol;
        this.active = active;
        this.position = "Candidate";
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getElectionId() { return electionId; }
    public void setElectionId(int electionId) { this.electionId = electionId; }

    public String getElectionName() { return electionName; }
    public void setElectionName(String electionName) { this.electionName = electionName; }

    public String getCandidateName() { return candidateName; }
    public void setCandidateName(String candidateName) { this.candidateName = candidateName; }

    public String getParty() { return party; }
    public void setParty(String party) { this.party = party; }

    public String getSymbol() { return symbol; }
    public void setSymbol(String symbol) { this.symbol = symbol; }

    public String getPosition() { return position != null && !position.isEmpty() ? position : "Candidate"; }
    public void setPosition(String position) { this.position = position; }

    public String getBio() { return bio; }
    public void setBio(String bio) { this.bio = bio; }

    public String getManifesto() { return manifesto; }
    public void setManifesto(String manifesto) { this.manifesto = manifesto; }

    public byte[] getPhotoData() { return photoData; }
    public void setPhotoData(byte[] photoData) { this.photoData = photoData; }

    public String getPhotoType() { return photoType; }
    public void setPhotoType(String photoType) { this.photoType = photoType; }

    public java.sql.Timestamp getPhotoUpdatedAt() { return photoUpdatedAt; }
    public void setPhotoUpdatedAt(java.sql.Timestamp photoUpdatedAt) { this.photoUpdatedAt = photoUpdatedAt; }

    public boolean hasPhoto() { return photoData != null && photoData.length > 0; }

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public int getVoteCount() { return voteCount; }
    public void setVoteCount(int voteCount) { this.voteCount = voteCount; }

    public double getVotePercentage() { return votePercentage; }
    public void setVotePercentage(double votePercentage) { this.votePercentage = votePercentage; }
}
