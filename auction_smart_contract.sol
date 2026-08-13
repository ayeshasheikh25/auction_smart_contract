// SPDX-License-Identifier: MIT

pragma solidity ^0.8.34;

contract Auction {
    address payable public auctioneer;
    uint public startTime;
    uint public endTime;

    enum Auction_State {
        Started,
        Running,
        Ended,
        Cancelled
    }
    Auction_State public auctionState;

    uint public highestPayableBid;
    uint public bidInc;
    address public highestBidder;

    mapping(address => uint) public bids;
    bool alreadyWithdrawbyAuctioneer = false;
    constructor() {
        auctioneer = payable(msg.sender);
        startTime = block.number;
        endTime = block.number + 10;
        bidInc = 1 ether;
        auctionState = Auction_State.Running;
    }
    
    modifier onlyOwner(){
        require(msg.sender == auctioneer, "Only owner can do");
        _;
    }

    modifier notOwner(){
        require(msg.sender != auctioneer, "Owner cannot bid");
        _;
    }
    modifier startBid(){
         require(startTime <= block.number, "Auction doesn't started yet");
        _;
    }
    modifier beforeEnd(){
        require(block.number <= endTime, "Auction ended");
        _;
    }
    modifier checkState(){
        require(auctionState == Auction_State.Running);
        _;
    }
    
    function min(uint a, uint b) public pure returns(uint) {
        if(a <= b){
            return a;
        }
        else {
            return b;
        }
    }
    function cancelAuction() public onlyOwner{
        auctionState = Auction_State.Cancelled;
    }
    function bid() public payable  notOwner startBid beforeEnd checkState{
        require(msg.value > 1 ether , "Minimum 1 ether is required");
 
        uint currentBid = bids[msg.sender] + msg.value;
        require(currentBid > highestPayableBid , "Your bid is lower than the highest bid");
       bids[msg.sender] = currentBid;
        if(currentBid < bids[highestBidder]){
            highestPayableBid = min(currentBid + bidInc , bids[highestBidder]);
        }
        else{
            highestPayableBid = min(currentBid, bids[highestBidder]+bidInc);
            highestBidder = payable (msg.sender);
        }
    }

    function finalAuc() public {
        require(auctionState == Auction_State.Ended || auctionState == Auction_State.Cancelled || endTime < block.number);
       if(msg.sender == auctioneer){
         require(alreadyWithdrawbyAuctioneer == false , "You already withdraw");
       }
        address payable person;
        uint value;
        if(auctionState == Auction_State.Cancelled){
            person = payable (msg.sender);
            value = bids[msg.sender];
        }
        else{
            if(msg.sender == auctioneer){
                person = auctioneer;
                value = highestPayableBid;
                alreadyWithdrawbyAuctioneer = true;
            }
            else{
               person = payable (msg.sender); 
               value = bids[msg.sender]-highestPayableBid;
            }
        }
        bids[msg.sender] = 0;
        (bool success, ) = person.call{value : value}("");
        require(success, "Transaction failed");
    }
}

