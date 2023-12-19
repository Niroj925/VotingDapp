// SPDX-License-Identifier: MIT
pragma solidity ^0.8.2;

contract Voting{
    //create a templet for each candidate 

    struct Candidate{
        uint256 id;
        string name;
        uint256 numberOfVotes;
    }

    //list of all candidates
    Candidate[] public candidates;

    //owner address
    address public owner;
    
    //map all the voters address
    mapping(address => bool) public voters;

    //map all voters 
    address[] public listOfVoters;

    //create a voting start and end session
    uint256 public votingStart;
    uint256 public votingEnd;

    //create election status
    bool public electionStarted;

    //restrict creating election to the owner only
    modifier onlyOwner(){
        require(msg.sender == owner,"you are not authorized to enroll in election");
        _;
    }

    //check if an election is ongoing
    modifier electionOnGoing(){
        require(electionStarted,"No election yet");
        _;
    }

    //create constructor
    constructor(){
        owner=msg.sender;
    }
    
    //to start an election
    function startElection(
        string[] memory _candidates,
        uint256 _votingDuration
    )public onlyOwner{
        require(electionStarted == false,"Election is currently ongoing");
        delete candidates;
        resetAllVoterStatus();

        for (uint256 i=0;i< _candidates.length;i++){
            candidates.push(
                Candidate({id:i,name:_candidates[i],numberOfVotes:0})
            );

        }
        electionStarted=true;
        votingStart=block.timestamp;
        votingEnd=block.timestamp + (_votingDuration * 1 minutes);
    }

    //to add a new candidates
    function addCandidate(
        string memory _name
    )public onlyOwner electionOnGoing{
        require(checkElectionPeriod(),"Election period has ended");
        candidates.push(
            Candidate({id: candidates.length,name:_name,numberOfVotes:0})
        );
    }

    //check voter's status
    function voterStatus(
        address _voter
        ) public view electionOnGoing returns (bool){
             if(voters[_voter]==true){
                return true;
             }
             return false;
        }

        //to vote function 
        function voteTo(uint256 _id) public electionOnGoing{
            require(checkElectionPeriod(),"Election period is finish");
            require(!voterStatus(msg.sender),"you have already voted only once");
            candidates[_id].numberOfVotes++;
            voters[msg.sender]=true;
            listOfVoters.push(msg.sender);
        }

     //get the number of votes 
     function retrieveVotes() public view returns (Candidate[] memory){
        return candidates;
     }

     //monitor the election time 
     function electionTimer() public view electionOnGoing returns (uint256){
        if(block.timestamp >= votingEnd){
            return 0;
        }
        return (votingEnd - block.timestamp);
     }

     //check if elction period is still ongoing
     function checkElectionPeriod() public returns (bool){
        if(electionTimer() > 0){
            return true;
        }

        electionStarted=false;
        return false;
     }

     //reset all voters status 
     function resetAllVoterStatus() public onlyOwner {
        for(uint256 i=0;i<listOfVoters.length;i++){
            voters[listOfVoters[i]]=false;
        }
        delete listOfVoters;
     }

}