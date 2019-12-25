```solidity
pragma solidity ^0.5.15;

pragma experimental ABIEncoderV2;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/ownership/Ownable.sol";
contract PaymentAcceptance{
     function ConfirmOfReceipt(uint _finalPrice,uint _Token,address _sellersAddress) public;
     function acceptPaymentForAltCoin(uint _price,address _sender,uint _token) external payable returns(bool);
}

contract point_system3 is Ownable {
    address PaymentAcceptanceAddress = 0x375EaE23b65fEB1833072328647902f1FE9afA61;
    PaymentAcceptance PaymentAcceptance1 = PaymentAcceptance(PaymentAcceptanceAddress);
struct product{
  string name;
  mapping(uint=>uint) TokenToPrice;
  bool PaymentStatus;
  address Buyer;
  uint FinalToken;
}
struct seller{
  string name;
  address payable sellerAddress;
  uint good;
  uint bad;
}
mapping(address=>uint) addressToPoint;
mapping(uint=>uint) productToSeller;
product[] public products;
seller[] public sellers;

function setPaymentAcceptanceAddress(address _new) public onlyOwner(){
    PaymentAcceptanceAddress = _new;
    PaymentAcceptance1 = PaymentAcceptance(PaymentAcceptanceAddress);
}
function addSeller(string calldata _name) external dupCheck(msg.sender) {
  sellers.push(seller(_name,msg.sender,0,0));
}
  function addItem(string calldata _productName,uint[] calldata _price,uint[] calldata _token) external exiCheck(msg.sender){
    uint productId = products.push(product(_productName,false,0x0000000000000000000000000000000000000000,0)) - 1;
    for(uint i = 0; i<_token.length; i++){
        products[productId].TokenToPrice[_token[i]] = _price[i];
    }
    ConnectingSellerWithProduct(productId,msg.sender);
  }
  function ConnectingSellerWithProduct(uint _productId,address _sender) private{
    for(uint i=0; i<sellers.length; i++){ //プロダクトとセラーの結びつけをしている
     if(sellers[i].sellerAddress == _sender){
        productToSeller[_productId] = i;
      }
    }
  }
  function getPrice(uint _productId,uint _tokenId) public view returns(uint){
      uint returnPrice = products[_productId].TokenToPrice[_tokenId];
      return returnPrice;
  }
  function Buying(uint _productId,uint _token) public payable returns(bool){
    require(products[_productId].PaymentStatus != true,"It was already bought by someone");
    if(_token != 2){
    products[_productId].PaymentStatus = PaymentAcceptance1.acceptPaymentForAltCoin(products[_productId].TokenToPrice[_token],msg.sender,_token);
    products[_productId].FinalToken = _token;
    if(products[_productId].PaymentStatus == true){
      products[_productId].Buyer = msg.sender;
    }
  }
    else{
    require(msg.value>=products[_productId].TokenToPrice[2]*(10**15),"not enough");
    products[_productId].Buyer = msg.sender;
    products[_productId].PaymentStatus = true;
    products[_productId].FinalToken = _token;
    return true;
  }
}
function TransferETH(uint _productId) private{
    uint amount = products[_productId].TokenToPrice[2];
    address payable sellerAddress = sellers[productToSeller[_productId]].sellerAddress;
    sellerAddress.transfer(amount*(10**15));
}
function getPaymentAcceptanceAddress() public view returns(address){
    return PaymentAcceptanceAddress;
}
  function ConfirmOfReceipt(uint _productId,uint _evaluation) external{
      require(products[_productId].Buyer == msg.sender && products[_productId].PaymentStatus == true);
      uint finalprice = products[_productId].FinalToken;
      uint finaltoken = products[_productId].FinalToken;
      address sellerAddress = sellers[productToSeller[_productId]].sellerAddress;
      if(_evaluation == 1){
          sellers[productToSeller[_productId]].good++;
      }else if(_evaluation == 2){
          sellers[productToSeller[_productId]].bad++;
      }
      if(finaltoken == 2){
          TransferETH(_productId);
      }
      else{
      PaymentAcceptance1.ConfirmOfReceipt(finalprice,finaltoken,sellerAddress);
      }
  }
  modifier dupCheck(address seller1){
    int check = -5;
    for(int i=0;i<int(sellers.length);i++){
      if(sellers[uint(i)].sellerAddress == seller1){
        check =  -1;
      }
    } 
    require(check!=-1);
    _;
  }

modifier exiCheck(address seller2){
    int check2 = -1;
    for(int i=0; i<int(sellers.length); i++){
      if(sellers[uint(i)].sellerAddress == seller2){
        check2 =  i;
      }
    }
    require(check2!=-1);
    _;
  }
}
//商品に対するいいねを押すことでトークンをゲットできる　出品でトークンをゲットできる　購入ではポイントのようにトークンをゲットできる
//受取相手の評価をすることでトークンをゲットできるなど、トークンエコノミーと結び付けられるかも？
