// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./AppStorage.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";
import "../../lib/openzeppelin-contracts/contracts/token/ERC721/IERC721Receiver.sol";

library LibAuction {
    function appStorage() internal pure returns (AppStorage storage ds) {
        assembly {
            ds.slot := 0
        }
    }

    function numberExistingAuction() internal view returns (uint number) {
        AppStorage storage ds = appStorage();
        number = ds.allAuctionDetails.length;
    }

    function getUniqueAuction(
        uint _auctionPosition
    ) internal view returns (AuctionDetails memory getAuction) {
        AppStorage storage ds = appStorage();
        getAuction = ds.allAuctionDetails[_auctionPosition];
    }

    function getAuctionBidder(
        uint _auctionID,
        uint _arrayPosition
    ) internal view returns (Bidders memory getBidder) {
        AppStorage storage ds = appStorage();
        getBidder = ds.uniqueAuctionPool[_auctionID][_arrayPosition];
    }

    function uniqueAuctionDetail(
        uint _auctionID
    ) internal view returns (AuctionDetails memory details) {
        AppStorage storage ds = appStorage();
        details = ds.uniqueAuctionSummary[_auctionID];
    }

    //Remember to make function payable in facet
    function createAuction(
        address _nftContract,
        string memory _auctionName,
        uint _nftID
    ) internal {
        AppStorage storage ds = appStorage();
        require(msg.sender != address(0), "Unauthorized address");
        require(_nftContract != address(0), "Address Zero prohibited");
        // get the size/number of created auctions...
        uint idArrSize = ds.arrID.length;
        for (uint i = 0; i < idArrSize; i++) {
            //loops through id array and ensure item has not been listed by checking nft and id....
            require(
                ds.uniqueAuctionSummary[i].nftContractAddr != _nftContract &&
                    ds.uniqueAuctionSummary[i].nftID != _nftID,
                "item has been listed"
            );
        }
        // checks for minimum auction listing price
        require(
            msg.value >= ds.creationCharge,
            "Auction Creation charge is 0.02 ethers"
        );

        //initiializes struct uniqueAuctionSummary struct....
        AuctionDetails memory newAuction = AuctionDetails(
            msg.sender,
            _auctionName,
            _nftContract,
            _nftID,
            block.timestamp,
            100 seconds,
            0x0000000000000000000000000000000000000000,
            0
        );
        ds.auctionID++;
        ds.arrID.push(ds.auctionID);
        ds.uniqueAuctionSummary[ds.auctionID] = newAuction;
        ds.allAuctionDetails.push(newAuction);

        IERC721(_nftContract).transferFrom(msg.sender, address(this), _nftID);
    }

    //Remember to make function payable in facet
    function BidForItem(uint _auctionId) internal {
        AppStorage storage ds = appStorage();
        require(msg.sender != ds.owner, "Auction cannot bid for item");
        require(
            ds.hasBidded[msg.sender][_auctionId] == false,
            "You cam't bid twice"
        );
        require(msg.value > 0, "Nothing is free");
        require(
            msg.sender != ds.uniqueAuctionSummary[_auctionId].auctionCreator,
            "can not bid for this item!!!"
        );
        require(
            block.timestamp <=
                ds.uniqueAuctionSummary[_auctionId].openingTime +
                    ds.uniqueAuctionSummary[_auctionId].duration,
            "Bidding has ended!!!"
        );

        ds.userBid[msg.sender][_auctionId] = msg.value;
        Bidders memory _bidderDetails = Bidders(
            _auctionId,
            msg.sender,
            msg.value
        );

        ds.uniqueAuctionPool[_auctionId].push(_bidderDetails);

        if (msg.value > ds.uniqueAuctionSummary[_auctionId].highestBid) {
            ds.uniqueAuctionSummary[_auctionId].highestBid = (msg.value);
            ds.uniqueAuctionSummary[_auctionId].winnerAddress = msg.sender;
        }

        // bytes32 take = keccak256(abi.encodePacked(msg.value));

        ds.hasBidded[msg.sender][_auctionId] = true;
    }

    //Remember to make function payable in facet
    function declareWinner(uint _auctionID) internal {
        AppStorage storage ds = appStorage();
        require(
            ds.uniqueAuctionSummary[_auctionID].auctionCreator == msg.sender ||
                ds.owner == msg.sender,
            "Only auction creator or contract Owner can call this function"
        );
        require(
            block.timestamp >
                ds.uniqueAuctionSummary[_auctionID].openingTime +
                    ds.uniqueAuctionSummary[_auctionID].duration,
            "Bidding still in progress"
        );

        Bidders[] memory uniquePool = ds.uniqueAuctionPool[_auctionID];
        uint uniquePoolSize = uniquePool.length;
        address _winner = ds.uniqueAuctionSummary[_auctionID].winnerAddress;
        for (uint i = 0; i < uniquePoolSize; i++) {
            address _bidder = uniquePool[i].bidderAddr;
            if (_bidder != _winner) {
                uint amount = uniquePool[i].bidAmount;
                (bool sent, bytes memory data) = payable(address(_bidder)).call{
                    value: amount
                }("");
                require(sent, "failed to send ether");
            }
        }

        address _nftAddr = ds.uniqueAuctionSummary[_auctionID].nftContractAddr;
        uint _nftId = ds.uniqueAuctionSummary[_auctionID].nftID;

        IERC721(_nftAddr).transferFrom(address(this), _winner, _nftId);
    }
}
