// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

error FundMe__notOwner();

contract FundMe {
      using PriceConverter for uint256;
      mapping(address /*funder*/ => uint256 /*amountFunded*/) private s_addressToAmountFunded;
      address[] private s_funders;
      address private immutable i_owner;
      
      AggregatorV3Interface public s_priceFeed;
      uint256 public constant MINIMUMUSD = 5e18;
  
    
    
    constructor(address pricefeed) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(pricefeed);
    }

    function fund() public payable {
    require(msg.value.convertedPrice(s_priceFeed) >= MINIMUMUSD, "fund is not enough");
    s_addressToAmountFunded[msg.sender] += msg.value; 
     s_funders.push(msg.sender);
    }

     function getVersion() public view returns (uint256) {
    //   AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
      return s_priceFeed.version();
     }

    modifier onlyOwner {    
    // require(msg.sender == i_owner, "you are not the owner");
    if (msg.sender != i_owner) { revert FundMe__notOwner(); }
    _;
    }

    function withdraw() public onlyOwner {
        
        for(uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            //funder = funders[index keberapa] (tipe address)
            address funder = s_funders[funderIndex];
            //set mapping key address, ke value = 0
            s_addressToAmountFunded[funder] = 0;
         
        }
        //reset funders ke 0 tipe address
    s_funders = new address[](0);
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success, "Call failed");
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;
        for(uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            //funder = funders[index keberapa] (tipe address)
            address funder = s_funders[funderIndex];
            //set mapping key address, ke value = 0
            s_addressToAmountFunded[funder] = 0;
         
        }
        //reset funders ke 0 tipe address
    s_funders = new address[](0);
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success, "Call failed");
    }

    
receive() external payable { 
    fund();
}
fallback() external payable { 
    fund();
}


//view/pure function getters

function getAddressToAmountFunded(address fundingAddress) public view returns (uint256) {
    return s_addressToAmountFunded[fundingAddress];
}
function getFunder(uint256 index) public view returns (address) {
    return s_funders[index];
}
function getOwner() public view returns (address) {
    return i_owner;
}

}