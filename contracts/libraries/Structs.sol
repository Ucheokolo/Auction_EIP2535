// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
struct AuctionDetails {
    address auctionCreator;
    string auctionName;
    address nftContractAddr;
    uint nftID;
    uint openingTime;
    uint duration;
    address winnerAddress;
    uint highestBid;
}

struct Bidders {
    uint auctionId;
    address bidderAddr;
    uint bidAmount;
}
