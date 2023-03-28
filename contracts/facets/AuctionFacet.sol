// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// import "../libraries/AppStorage.sol";
import "../libraries/libAuction.sol";

contract AuctionFacet {
    function getNumberExistingAuction()
        public
        view
        returns (uint existingAuctions_)
    {
        existingAuctions_ = LibAuction.numberExistingAuction();
    }

    function getAuctionDetails(
        uint auctionPosition_
    ) public view returns (AuctionDetails memory getAuctionD) {
        getAuctionD = LibAuction.getUniqueAuction(auctionPosition_);
    }

    function getBidder(
        uint auctionID_,
        uint arrayPosition_
    ) public view returns (Bidders memory getBidder_) {
        getBidder_ = LibAuction.getAuctionBidder(auctionID_, arrayPosition_);
    }

    function getUniqueAuctionDetail(
        uint auctionID_
    ) public view returns (AuctionDetails memory details_) {
        details_ = LibAuction.uniqueAuctionDetail(auctionID_);
    }

    function createAuction(
        address _nftContract,
        string memory _auctionName,
        uint _nftID
    ) public payable {
        LibAuction.createAuction(_nftContract, _auctionName, _nftID);
    }

    function BidForItem(uint _auctionId) public payable {
        LibAuction.BidForItem(_auctionId);
    }

    function declareWinner(uint _auctionID) public payable {
        LibAuction.declareWinner(_auctionID);
    }
}
