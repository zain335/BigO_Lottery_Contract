// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract lottery {
    address owner;
    uint ticketPrice;
    uint escrow;
    address[] participants;
    uint seed;
    uint minimumTickets;
    address public lotteryWinner;

    constructor(uint256 _ticketPrice, uint _minTickets) {
        require(_ticketPrice > 0, "Ticket Price should be greater than zero");
        minimumTickets = _minTickets;
        owner = msg.sender;
        ticketPrice = _ticketPrice;
    }

    function purchaseTicket() public payable {
        require(msg.value >= ticketPrice, "invlaid ticket price");
        participants.push(msg.sender);
        escrow = escrow + msg.value;
    }

    function getRandomNumber() internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.prevrandao,
                        participants,
                        seed
                    )
                )
            );
    }

    function addRandomness(uint256 _seed) public {
        seed = uint256(keccak256(abi.encodePacked(_seed, seed)));
    }

    modifier _onlyOwner() {
        require(msg.sender == owner, "not authorized");
        _;
    }

    function selectWinner() internal view returns (uint256) {
        require(
            participants.length >= minimumTickets,
            "Minimum number of ticket not sold yet."
        );
        return getRandomNumber() % participants.length;
    }

    function distributePrize() public _onlyOwner {
        require(escrow > 0, "no ammount in escrow");
        uint winner = selectWinner();
        payable(participants[winner]).transfer(escrow);
        lotteryWinner = participants[winner];
        escrow = 0;
    }

    function newLottery(uint _ticketPrice, uint _minTickets) public _onlyOwner {
        require(_ticketPrice > 0, "ticket price should be greater than 0");
        require(escrow == 0, "escrow should be empty to start a new lottery");
        minimumTickets = _minTickets;
        ticketPrice = _ticketPrice;
        participants = new address[](0);
        lotteryWinner = address(0);
    }

    function getParticipants() public view returns (address[] memory) {
        return participants;
    }
}
