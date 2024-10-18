// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../contracts/facets/OwnershipFacet.sol";
import "../contracts/facets/DiamondNftFacet.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/upgradeInitializers/DiamondInit.sol";
import "../contracts/Diamond.sol";


import "forge-std/Test.sol";

contract DiamondDeployer is Test, IDiamondCut {
   //contract types of facets to be deployed
   Diamond diamond;
   DiamondCutFacet dCutFacet;
   DiamondLoupeFacet dLoupe;
   OwnershipFacet ownerF;
   DiamondInit dInit;
   DiamondNftFacet nftF;

   function setUp() public {
       //deploy facets
       dCutFacet = new DiamondCutFacet();
       diamond = new Diamond(address(this), address(dCutFacet));
       dLoupe = new DiamondLoupeFacet();
       ownerF = new OwnershipFacet();
       dInit = new DiamondInit();
       nftF = new DiamondNftFacet();

       //upgrade diamond with facets

       //build cut struct
       FacetCut[] memory cut = new FacetCut[](4);

       cut[0] = (
           FacetCut({
               facetAddress: address(dLoupe),
               action: FacetCutAction.Add,
               functionSelectors: generateSelectors("DiamondLoupeFacet")
           })
       );

       cut[1] = (
           FacetCut({
               facetAddress: address(ownerF),
               action: FacetCutAction.Add,
               functionSelectors: generateSelectors("OwnershipFacet")
           })
       );

       cut[2] = (
           FacetCut({
               facetAddress: address(dInit),
               action: FacetCutAction.Add,
               functionSelectors: generateSelectors("DiamondInit")
           })
       );

       cut[3] = (
           FacetCut({
               facetAddress: address(nftF),
               action: FacetCutAction.Add,
               functionSelectors: generateSelectors("DiamondNftFacet")
           })
       );

       //upgrade diamond
       IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

       //Initialization
       DiamondInit(address(diamond)).init();
   }

   function testDiamondNft() public {
       // Assuming you have an NFT facet with a mint function
       DiamondNftFacet nftFacet = DiamondNftFacet(address(diamond));

       // Mint a new NFT
       nftFacet.mint(address(this), 1, "test");

       // Check the owner of the newly minted NFT
       address owner = nftFacet.ownerOf(1);
       assertEq(owner, address(this));

       // Check the balance of the NFT owner
       uint256 balance = nftFacet.balanceOf(address(this));
       assertEq(balance, 1);

       assertEq(nftFacet.ownerOf(1), address(this));
       assertEq(nftFacet.getApproved(1), address(0));
       assertEq(nftFacet.isApprovedForAll(address(this), address(0)), false);
   }

   // multiple initialization should fail
   function testMultipleInitialize() public {
       vm.expectRevert(AlreadyInitialized.selector);
       DiamondInit(address(diamond)).init();
   }

function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[])); // Change from bytes4 to bytes4[]
    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
