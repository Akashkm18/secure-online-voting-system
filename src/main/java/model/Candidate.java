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

    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }

    public int getVoteCount() { return voteCount; }
    public void setVoteCount(int voteCount) { this.voteCount = voteCount; }

    public double getVotePercentage() { return votePercentage; }
    public void setVotePercentage(double votePercentage) { this.votePercentage = votePercentage; }
}
