pragma solidity ^0.4.24;

pragma experimental ABIEncoderV2;
import "./Ownable.sol";
contract ERC20CoinInterface{
  function transfer(address _to, uint256 _value) public returns (bool);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

contract point_system is Ownable {
  
struct product{
  string name;
  mapping(uint=>uint) NowPrice;
  address[] highestBidder; 
  uint biddingPeriod;   //Seconds
  uint finalPrice;
  uint Token;
  bool PaymentStatus;
}
struct seller{
  string name;
  address sellerAddress;
  uint good;
  uint bad;
  uint processed;
}
mapping(address=>uint) addressToPoint;
mapping(uint=>uint) productToSeller;
address[] public PermissionPersonList;
product[] public products;
seller[] public sellers;
address ALISTokenAddress = 0xEA610B1153477720748DC13ED378003941d84fAB;
address ARUKTokenAddress = 0x81AADA684F4Bd51252c8184148A78e7E4B44dc2c;
address satelliteAddress; 
ERC20CoinInterface ALISTokenInterface = ERC20CoinInterface(ALISTokenAddress);
ERC20CoinInterface ARUKTokenInterface = ERC20CoinInterface(ARUKTokenAddress);

function AddPermissionAddress(address _permissionPerson) public onlyOwner(){
  PermissionPersonList.push(_permissionPerson);
}

function addSeller(string _name) external dupCheck(msg.sender) PermissionCheck(msg.sender){
  sellers.push(seller(_name,msg.sender,0,0,0));
}
  function addItem(string _productName,uint[] _StartPrice,uint[] TypeOfCurrency,uint period) external exiCheck(msg.sender){
    address[] memory a;
    uint productId = products.push(product(_productName,a,0,0,0,false)) - 1;
    products[productId].biddingPeriod = now + period;
    for(uint i=0; i<TypeOfCurrency.length; i++){
      products[productId].NowPrice[TypeOfCurrency[i]] = _StartPrice[i];   //通貨ごとにオークション開始値段を分けている
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
  function bidding(uint _productId,uint _biddingPrice, uint TypeOfCurrency) external{
    require(_biddingPrice>products[_productId].NowPrice[TypeOfCurrency] && products[_productId].biddingPeriod>=now);
    products[_productId].NowPrice[TypeOfCurrency] = _biddingPrice;
    products[_productId].highestBidder[TypeOfCurrency] = msg.sender;
  }
  function ViewNowPrice(uint _productId,uint TypeOfCurrency) external view returns(uint){
    return products[_productId].NowPrice[TypeOfCurrency];
  }
  function ViewHightestBidder(uint _productId,uint _TypeOfCurrency) external view returns(address){
    return products[_productId].highestBidder[_TypeOfCurrency];
  }
  function chooseCurrency(uint _productId,uint TypeOfCurrency) external{
    require(sellers[productToSeller[_productId]].sellerAddress == msg.sender && now>=products[_productId].biddingPeriod);
    products[_productId].finalPrice = products[_productId].NowPrice[TypeOfCurrency];
    products[_productId].Token = TypeOfCurrency;
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
 modifier PermissionCheck(address person){
   bool check = false;
   for(uint i = 0; i<PermissionPersonList.length; i++ ){
     if(PermissionPersonList[i] == person){
       check = true;
       break;
     }
   }
   require(check==true,"You aren't in the permission list ");
   _;
 }
}

//商品に対するいいねを押すことでトークンをゲットできる　出品でトークンをゲットできる　購入ではポイントのようにトークンをゲットできる
//受取相手の評価をすることでトークンをゲットできるなど、トークンエコノミーと結び付けられるかも？