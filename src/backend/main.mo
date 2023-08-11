import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Hash "mo:base/Hash";
import Time "mo:base/Time";
import TrieMap "mo:base/TrieMap";
import Result "mo:base/Result";
import Principal "mo:base/Principal";
import Array "mo:base/Array";
import Buffer "mo:base/Buffer";

actor class safeVoting(idPrincipal : Text) {
  type Time = Int;
  var admin : Text = idPrincipal;
  /*
  public type Election = {
    idElection: Nat;
    name: Text;
    dateStart: Time;
    dateEnd: Time;
    candidatesNumber: Nat;
  };

  public type ElectionCall = {
    name: Text;
    dateStart: Time;
    dateEnd: Time;
    candidatesNumber: Nat;
  };
*/
  public type Candidate = {
    idCandidate : Nat;
    //idElection: Nat;
    name : Text;
    votes : Nat;
  };

  public type CandidateCall = {
    //idElection: Nat;
    name : Text;
  };

  public type Voter = {
    //idVoter : Nat;
    //principalVoter : Principal;
    principalVoter : Text;
    //candidate : Nat;
  };

  //var elections = TrieMap.TrieMap<Text, Election>(Text.equal, Text.hash);
  var candidates = TrieMap.TrieMap<Text, Candidate>(Text.equal, Text.hash);
  var voters = TrieMap.TrieMap<Text, Voter>(Text.equal, Text.hash);

  /*
  public shared func createElection(election : ElectionCall) : async Bool {
    let id = elections.size();
    let newElection : Election = {
      idElection = id;
      name = election.name;
      dateStart = election.dateStart;
      dateEnd = election.dateEnd;
      candidatesNumber = election.candidatesNumber;
    };
    elections.put(Nat.toText(id), newElection);
    return true
  };
*/

  public shared (msg) func createCandidate(candidate : CandidateCall) : async Bool {
    if (admin == Principal.toText(msg.caller)) {
      let id = candidates.size();
      let newCandidate : Candidate = {
        idCandidate = id;
        //idElection = candidate.idElection;
        name = candidate.name;
        votes = 0;
      };
      candidates.put(Nat.toText(id), newCandidate);
      return true;
    };
    return false;
  };

    public shared (msg) func createCandidate2(candidate : Text) : async Bool {
    if (admin == Principal.toText(msg.caller)) {
      let id = candidates.size();
      let newCandidate : Candidate = {
        idCandidate = id;
        //idElection = candidate.idElection;
        name = candidate;
        votes = 0;
      };
      candidates.put(Nat.toText(id), newCandidate);
      return true;
    };
    return false;
  };

  /*
  public shared func getElections() : async Result.Result<Election, Text> {
    for (value in elections.vals()) {
          return #ok(value)
    };
    return #err "No elections found"
  };
*/

  public shared query func getAllVoters() : async [Voter] {
    let VoterBuffer : Buffer.Buffer<Voter> = Buffer.Buffer<Voter>(0);
    for (value in voters.vals()) {
      let VoterToResponse : Voter = {
        //idVoter = value.idVoter;
        principalVoter = value.principalVoter;
      };
      VoterBuffer.add(VoterToResponse);
    };
    return Buffer.toArray(VoterBuffer);
  };

  public shared query func getAllCandidates() : async [Candidate] {
    let CandidateBuffer : Buffer.Buffer<Candidate> = Buffer.Buffer<Candidate>(0);
    for (value in candidates.vals()) {
      let CandidateToResponse : Candidate = {
        idCandidate = value.idCandidate;
        //idElection: Nat;
        name = value.name;
        votes = value.votes;
      };
      CandidateBuffer.add(CandidateToResponse);
    };
    return Buffer.toArray(CandidateBuffer);
  };

  public shared (msg) func vote(candidateId : Nat) : async Bool {
    let voterId : Text = Principal.toText(msg.caller);
    let voterPrincipal : Principal = msg.caller;

    switch (voters.get(voterId)) {
      case null {
        let idVoter = voters.size();
        let newVoter : Voter = {
          //idVoter = idVoter;
          //principalVoter = voterPrincipal;
          principalVoter = voterId;
        };
        //voters.put(Nat.toText(idVoter), newVoter);
        voters.put(voterId, newVoter);
      };
      case (?found) { return false };
    };

    switch (candidates.get(Nat.toText(candidateId))) {
      case null { false };
      case (?found) {
        let newCandidate : Candidate = {
          idCandidate = candidateId;
          name = found.name;
          votes = found.votes + 1;
        };
        ignore candidates.replace(Nat.toText(candidateId), newCandidate);
        return true;
      };
    };
  };

  public shared query (msg) func getCaller() : async Principal {
    let caller : Principal = msg.caller;
    return caller;
  };

  public shared query func getAdmin() : async Text {
    return admin;
  };

  public shared (msg) func isAdmin() : async Bool {
    if (admin == Principal.toText(msg.caller)) {
      return true;
    };
    return false;
  };

};
