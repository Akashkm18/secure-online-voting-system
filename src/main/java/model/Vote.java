package model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Vote implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int electionId;
    private int voterId;
    private int candidateId;
    private String voteHash;
    private Timestamp votedAt;

    public Vote() {}

    public Vote(int id, int electionId, int voterId, int candidateId, String voteHash, Timestamp votedAt) {
        this.id = id;
        this.electionId = electionId;
        this.voterId = voterId;
        this.candidateId = candidateId;
        this.voteHash = voteHash;
        this.votedAt = votedAt;
    }

    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public int getElectionId() { return electionId; }
    public void setElectionId(int electionId) { this.electionId = electionId; }

    public int getVoterId() { return voterId; }
    public void setVoterId(int voterId) { this.voterId = voterId; }

    public int getCandidateId() { return candidateId; }
    public void setCandidateId(int candidateId) { this.candidateId = candidateId; }

    public String getVoteHash() { return voteHash; }
    public void setVoteHash(String voteHash) { this.voteHash = voteHash; }

    public Timestamp getVotedAt() { return votedAt; }
    public void setVotedAt(Timestamp votedAt) { this.votedAt = votedAt; }
}
