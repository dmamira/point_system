pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "/home/miraidai/point_system/node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract ERC20CoinInterface{
  function transfer(address _to, uint256 _value) public returns (bool);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

contract PaymentAcceptance{
    address ALISTokenAddress = 0xea610b1153477720748dc13ed378003941d84fab;
    address ARUKTokenAddress = 0x81aada684f4bd51252c8184148a78e7e4b44dc2c;
    ERC20CoinInterface ALISTokenInterface = ERC20CoinInterface(ALISTokenAddress);
    ERC20CoinInterface ARUKTokenInterface = ERC20CoinInterface(ARUKTokenAddress);
    
    function acceptPayment(uint _productId) external payable returns(bool){
    uint PaymentAmount = products[_productId].finalPrice;
    if(products[_productId].token == 1){
      ALISTokenInterface.approve(address(this),PaymentAmount);
      require(PaymentAmount<=ALISTokenInterface.allowance(msg.sender,address(this)) && products[_productId].highestBidder[products[_productId].Token] == msg.sender);
    }
   else if(products[_productId].token == 2){
    ARUKTokenInterface.approve(address(this),PaymentAmount);
    require(PaymentAmount<=ARUKTokenInterface.allowance(msg.sender,address(this)) && products[_productId].highestBidder[products[_productId].Token] == msg.sender);
   }
    if(products[_productId].token == 1){
      ALISTokenInterface.transferFrom(msg.sender,address(this),PaymentAmount);
    }
    else if(products[_productId].token == 2){
      ARUKTokenInterface.transferFrom(msg.sender,address(this),PaymentAmount);
    }
    sub(_productId);
    addPoint(PaymentAmount,msg.sender);
    products[_productId].PaymentStatus = true;
    return true;
  }

   }