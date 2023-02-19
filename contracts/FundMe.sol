//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./PriceConverter.sol";

error notOwner() ;
contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 50 * 1e18;
    address[] public funders;
    mapping(address => uint256) public findAmount;
    address public immutable i_owner;

    //constructor
    constructor() {
        i_owner = msg.sender;
    }

    function fund() public payable { //payable makes a function different and shows that it can pay
        //1. How do we send ETH to the contract
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough!"); /* 1) msg.value is a GLOBAL variable that shows the value of ether being send
                                                              2) 1e18 == 10^18 wei == 1eth
                                                              3) require() is a GLOBAL function that reverts the transaction if the 
                                                                 condition isn't fulfilled */
        funders.push(msg.sender);
        findAmount[msg.sender] = msg.value;
    }


    //function to withdraw amounts and also reset the array and the mapping
    function withdraw() public onlyOwner{
        for(uint256 i=0; i < funders.length; ++i) {
            address funder = funders[i];
            findAmount[funder] = 0; //Resetting the Mapping
        }
        funders  = new address[](0); //Resetting the Array

        //1. transfer
        // payable(msg.sender).transfer(address(this).balance); 
        /* msg.sender = address
           payable(msg.sender) = payable address */
        
        //2. send
        // bool success = payable(msg.sender).send(address(this).balance);
        // require(success, "Error in withdrawing");

        /* transfer -> It automatically reverts the transaction when it fails
           send     -> It returns a boolean based on whether the transaction succeeded ot not */
        
        //3. call
        (bool successCall, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(successCall, "Error in withdrawing");
    }

    modifier onlyOwner {       
        //require(msg.sender == i_owner, "You don't have the permission");
        if(msg.sender != i_owner){ revert notOwner(); }
        _; // This represents the rest of the code in the function the modifier is used in
    }

    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }
}