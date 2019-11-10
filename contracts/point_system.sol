pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "/home/miraidai/point_system/node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";

contract ERC20CoinInterface{
  function transfer(address _to, uint256 _value) public returns (bool);
  function approve(address spender, uint tokens) public returns (bool success);
  function transferFrom(address from, address to, uint tokens) public returns (bool success);
}

contract point_system {
  
struct product{
  string name;
  uint stock;  //基本オークションは一個のみなので在庫も必要なし
  uint items;   //items必要なし
  mapping(uint=>uint) NowPrice;
  address[] highestBidder;  //通貨ごとの最高入札者が必要
  uint biddingPeriod;   //Seconds
  uint finalPrice;
  uint Token;
  bool PaymentStatus;
}
struct seller{
  string name;
  address payable sellerAddress;
  uint good;
  uint bad;
  uint processed;
}
mapping(address=>uint) addressToPoint;
mapping(uint=>uint) productToSeller;
mapping(address=>buyer) addressToBuyerInformation;
address[] public PermissionPersonList;
product[] public products;
seller[] public sellers;
uint rateOfReduction = 4;
uint Fee = 2;
address ALISTokenAddress = 0xea610b1153477720748dc13ed378003941d84fab;
address ARUKTokenAddress = 0x81aada684f4bd51252c8184148a78e7e4b44dc2c;
ERC20CoinInterface ALISTokenInterface = ERC20CoinInterface(ALISTokenAddress);
ERC20CoinInterface ARUKTokenInterface = ERC20CoinInterface(ARUKTokenAddress);

function setRateOfReduction(uint newRateOfReduction) public Ownable() {
  rateOfReduction = newRateOfReduction;
}
function AddPermissionAddress(address pemissionPerson) public Ownable(){
  PermissionPersonList.push(permissionPerson);
}
function setFee(uint newFee) public Ownable(){
  Fee = newFee;
}
function addSeller(string calldata name) external dupCheck(msg.sender) p(msg.sender){
  sellers.push(seller(name,msg.sender,0,0,0));
}
  function addItem(string calldata _productName,uint _stock,uint[] StartPrice,uint[] TypeOfCurrency,uint period) external exiCheck(msg.sender){
    uint productId = products.push(product(_productName,_stock,_price,0)) - 1;
    products[_productId].biddingPeriod = now + period;
    for(uint i=0; i<TypeOfCurrency.length; i++){
      products[_productId].NowPrice[TypeOfCurrency[i]] = StartPrice[i];   //通貨ごとにオークション開始値段を分けている
    }
    for(uint i=0; i<sellers.length; i++){ //プロダクトとセラーの結びつけをしている
     if(sellers[i].sellerAddress == msg.sender){
        productToSeller[productId] = i;
      }
    }
  }

  function bidding(uint _productId,uint _biddingPrice,uint _items, uint TypeOfCurrency) external enoughtStock(_productId,_items){
    require(_biddingPrice>products[_productId].NowPrice[TypeOfCurrency] && products[_productId].biddingPeriod>=now);
    products[_productId].NowPrice[TypeOfCurrency] = _biddingPrice;
    products[_productId].highestBidder = msg.sender;
  }
  function ViewNowPrice(uint _productId,uint TypeOfCurrency) external view returns(uint){
    return products[_productId].NowPrice[TypeOfCurrency];
  }
  function chooseCurrency(uint _productId,uint TypeOfCurrency) public{
    require(productToSeller[_productId].sellerAddress == msg.sender && now>=products[_productId].biddingPeriod);
    products[_productId].finalPrice = products[_productId].NowPrice[TypeOfCurrency];
    products[_productId].Token = TypeOfCurrency;
  }
  function addProcessed(address buyer_address) private returns(uint){
     for(uint m=0; m<addressToBuyerInformation[buyer_address].cart_contents.length; m++){ 
      for(uint i=0; i<products.length; i++){ 
        if(i == addressToBuyerInformation[buyer_address].cart_contents[m]){
        sellers[productToSeller[i]].processed += addressToBuyerInformation[buyer_address].items[m] * products[i].price;
      }
     }
    }
   }
  function sub(uint _productId) private{
    //products[_productId].stock -=;
  }
  function addPoint(uint _totalValue, address _buyer_address) private{
    addressToBuyerInformation[_buyer_address].point += _totalValue*rateOfReduction;
  }
  function usepoint(uint _amount) external{
    require(addressToBuyerInformation[msg.sender].point>=_amount);
    addressToBuyerInformation[msg.sender].cart_price -= _amount;
    addressToBuyerInformation[msg.sender].point -= _amount;
  }

  modifier enoughStock(uint _productId,uint _items){
    require(products[_productId].stock>=_items);
    _;
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
   uint check = false;
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