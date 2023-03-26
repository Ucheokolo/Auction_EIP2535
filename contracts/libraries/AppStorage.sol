// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../libraries/Structs.sol";

struct AppStorage {
    address owner;
    uint auctionID;
    uint creationCharge;
    mapping(uint => AuctionDetails) uniqueAuctionSummary;
    AuctionDetails[] allAuctionDetails;
    mapping(uint => Bidders[]) uniqueAuctionPool;
    uint[] arrID;
    mapping(address => mapping(uint => uint)) userBid;
    mapping(address => mapping(uint => bool)) hasBidded;
}
