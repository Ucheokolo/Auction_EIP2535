// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "../contracts/facets/AuctionFacet.sol";
import "../contracts/facets/MockNft.sol";
import "../../lib/forge-std/src/Test.sol";

contract diamondAuction is Test {
    AuctionFacet auctionF;
    MockToke mockNft;

    address owner = mkaddr("Owner");

    address auctioner1 = mkaddr("auctioner1");
    address auctioner2 = mkaddr("auctioner2");

    address Bidder1 = mkaddr("Bidder1");
    address Bidder2 = mkaddr("Bidder2");
    address Bidder3 = mkaddr("Bidder3");
    address Bidder4 = mkaddr("Bidder4");

    function setUp() public {
        vm.startPrank(owner);
        auctionF = new AuctionFacet();
        mockNft = new MockToke();
        vm.stopPrank();
    }

    function testMintNFt() public {
        vm.startPrank(owner);
        mockNft.safeMint(auctioner1, "blindSpot");
        mockNft.safeMint(auctioner2, "Legacy");
        mockNft.balanceOf(auctioner1);
        mockNft.balanceOf(auctioner2);
        vm.stopPrank();
    }

    function testCreateAuction() public {
        testMintNFt();
        vm.deal(auctioner1, 100 ether);
        vm.deal(auctioner2, 80 ether);

        vm.prank(auctioner1);
        mockNft.approve(address(auctionF), 0);
        vm.prank(auctioner2);
        mockNft.approve(address(auctionF), 1);

        vm.prank(auctioner1);
        auctionF.createAuction{value: 0.2 ether}(
            address(mockNft),
            "Black Friday",
            0
        );

        vm.prank(auctioner2);
        auctionF.createAuction{value: 0.2 ether}(
            address(mockNft),
            "Clearance Sales",
            1
        );
    }

    function testbid() public {
        testCreateAuction();
        vm.deal(Bidder1, 30 ether);
        vm.deal(Bidder2, 30 ether);
        vm.deal(Bidder3, 30 ether);
        vm.deal(Bidder4, 30 ether);

        vm.startPrank(Bidder1);
        auctionF.BidForItem{value: 1.5 ether}(1);
        auctionF.BidForItem{value: 3 ether}(2);
        vm.stopPrank();

        vm.startPrank(Bidder2);
        auctionF.BidForItem{value: 1 ether}(1);
        auctionF.BidForItem{value: 3.5 ether}(2);
        vm.stopPrank();

        vm.startPrank(Bidder3);
        auctionF.BidForItem{value: 2 ether}(1);
        auctionF.BidForItem{value: 1.2 ether}(2);
        vm.stopPrank();

        vm.startPrank(Bidder4);
        auctionF.BidForItem{value: 6 ether}(1);
        auctionF.BidForItem{value: 1.1 ether}(2);
        vm.stopPrank();
    }

    function testDeclareWinner() public {
        testbid();
        vm.warp(3 minutes);
        vm.prank(auctioner1);
        auctionF.declareWinner(1);
        vm.prank(auctioner2);
        auctionF.declareWinner(2);
    }

    function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }
}
