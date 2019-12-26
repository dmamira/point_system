pragma solidity ^0.5.15;
pragma experimental ABIEncoderV2;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";

contract ERC20CoinInterface{
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
  function allowance(address _owner, address _spender) public view returns (uint256);
  function transfer(address recipient, uint256 amount) public returns (bool);
}
contract PaymentAcceptance1 is Ownable{
    address ThanksTokenAddress = 0x58ba596F6A27eB947a3Fd8453eB7f8c57533Ccb8; //demo
    address SorryTokenAddress = 0xF3340d54Cd133E59d37DdB48545645B934aF5Bd7;  //demo
    address basecontract = 0x9876e235a87F520c827317a8987C9E1FDe804485; //demo
    ERC20CoinInterface ThanksTokenInterface = ERC20CoinInterface(ThanksTokenAddress);
    ERC20CoinInterface SorryTokenInterface = ERC20CoinInterface(SorryTokenAddress);
    
    function changebaseContract(address _new) public onlyOwner(){
        basecontract = _new;
    }
    
    function acceptPaymentForAltCoin(uint _price,address _sender,uint _token) external payable returns(bool){
    require(msg.sender==basecontract,"worng address");
    if(_token == 0){
      uint allowanceAmount = ThanksTokenInterface.allowance(_sender,address(this));
      require(allowanceAmount>=_price*(10**15));
      bool Check0 = ThanksTokenInterface.transferFrom(_sender,address(this),_price*(10**15));
      return Check0;
    }
   else if(_token == 1){
       uint allowanceAmount1 = SorryTokenInterface.allowance(_sender,address(this));
       require(allowanceAmount1>=_price*(10**15),"not enough");
       bool Check1 = SorryTokenInterface.transferFrom(_sender,address(this),_price*(10**15));
       return Check1;
   }
  }
    function ConfirmOfReceipt(uint _finalPrice,uint _Token,address payable _sellersAddress) public { 
      require(msg.sender == basecontract);
      uint transferValue = _finalPrice;
      if(_Token == 0){
      ThanksTokenInterface.transfer(_sellersAddress,transferValue*(10**15));
      }
      else if(_Token == 1){
          SorryTokenInterface.transfer(_sellersAddress,transferValue*(10**15));
      }
    }
}