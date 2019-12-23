pragma solidity >=0.4.20;
pragma experimental ABIEncoderV2;
import "/home/miraidai/point_system/contracts/point_system.sol";
import "./Ownable.sol";

contract ERC20CoinInterface{
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256);
  function transfer(address recipient, uint256 amount) public returns (bool);
}

contract PaymentAcceptance is point_system{
    address ThanksTokenAddress = 0x692a70D2e424a56D2C6C27aA97D1a86395877b3A;
    address SorryTokenAddress = 0x0FdF4894a3b7C5a101686829063BE52Ad45bcfb7;
    ERC20CoinInterface ThanksTokenInterface = ERC20CoinInterface(ThanksTokenAddress);
    ERC20CoinInterface SorryTokenInterface = ERC20CoinInterface(SorryTokenAddress);
    
    function acceptPaymentForAltCoin(uint _price,address _sender,uint _token) external payable returns(bool){
    if(_token == 0){
      uint paymentamount = _price;
      uint allowanceAmount = ThanksTokenInterface.allowance(_sender,address(this));
      require(allowanceAmount>=paymentamount);
      bool Check0 = ThanksTokenInterface.transferFrom(_sender,address(this),paymentamount);
      return Check0;
    }
   else if(_token == 1){
       uint PaymentAmount = _price;
       uint allowanceAmount1 = SorryTokenInterface.allowance(_sender,address(this));
       require(allowanceAmount1>=PaymentAmount);
       bool Check1 = SorryTokenInterface.transferFrom(_sender,address(this),PaymentAmount);
       return Check1;
   }
  }
  function AcceptPaymentForETH(uint _price, address _sender){
    uint WeiPrice = _price*10**18;
    require(msg.value>=WeiPrice);
    return true;
  }
    function ConfirmOfReceipt(uint _finalPrice,uint _Token,address _sellersAddress) internal { 
      uint transferValue = _finalPrice;
      if(_Token == 0){
      ThanksTokenInterface.transfer(_sellersAddress,transferValue);
      }
      else if(_Token == 1){
          SorryTokenInterface.transfer(_sellersAddress,transferValue);
      }
    }
}