pragma solidity ^0.5.11;

pragma experimental ABIEncoderV2;
import "./Ownable.sol";

contract PaymentAcceptance{
     function acceptPaymentForAltCoin(uint _finalPrice,address _sender,uint _token) external payable returns(bool);
     function ConfirmOfReceipt(uint _finalPrice,address _sellersAddress,uint _Token,uint evaluation) public;
}

contract point_system is Ownable {
    address PaymentAcceptanceAddress = 0x8046085fb6806cAa9b19a4Cd7b3cd96374dD9573;
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
  address sellerAddress;
  uint good;
  uint bad;
}
mapping(address=>uint) addressToPoint;
mapping(uint=>uint) productToSeller;
product[] public products;
seller[] public sellers;

function setPaymentAcceptanceAddress(address _new) public onlyOwner(){
    PaymentAcceptanceAddress = _new;
}
function addSeller(string _name) external dupCheck(msg.sender) {
  sellers.push(seller(_name,msg.sender,0,0));
}
  function addItem(string _productName) external exiCheck(msg.sender){
    uint productId = products.push(product(_productName,false)) - 1;
    ConnectingSellerWithProduct(productId,msg.sender);
  }
  function ConnectingSellerWithProduct(uint _productId,address _sender) private{
    for(uint i=0; i<sellers.length; i++){ //プロダクトとセラーの結びつけをしている
     if(sellers[i].sellerAddress == _sender){
        productToSeller[_productId] = i;
      }
    }
  }
  function Buying(uint _productId,uint _token) public{
    if(_token != 2){
    products[_productId].PaymentStatus = acceptPaymentForAltCoin(products[_productId].TokenToPrice[_token],msg.sender,_token);
    products[_productId].finalToken = _token;
    if(products[_productId].Status == true){
      products[_productId.Buyer] = msg.sender;
    }
  }
    else{
      products[_productId].PaymentStatus = acceptPaymentForETH(products[_productId].TokenToPrice[_token],msg.sender,_token);
      products[_productId].finalToken = _token;
      if(products[_productId].Status == true){
      products[_productId.Buyer] = msg.sender;
    }
    }
  }
  function ConfirmOfReceipit(uint _productId,uint _evaluation) external{
      require(products[_productId].Buyer == msg.sender && products[_productId].PaymentStatus == true);
      uint finalprice = products[_productId].finalToken;
      address sellerAddress = sellers[productToSeller[_productid]].sellerAddress;
      if(_evaluation == 1){
          sellers[productToSeller[_productId]].good++;
      }else if(_evaluation == 2){
          sellers[productToSeller[_productId]].bad++;
      }
      PaymentAcceptance.ConfirmOfReceipt(finalprice,finalToken,sellerAddress);
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