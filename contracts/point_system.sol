pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "/home/miraidai/point_system/node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
contract point_system {

struct product{
  string name;
  uint stock;
  uint price;
  uint items;
}
struct seller{
  string name;
  address sellerAddress;
  uint good;
  uint bad;
  uint processed;
}
struct buyer{ 
  uint point;
  uint cart_price;
  uint[] cart_contents;
  uint[] inProcessing;
  uint[] items;
}
mapping(uint=>uint) productToSeller;
mapping(address=>buyer) addressToBuyerInformation;
product[] public products;
seller[] public sellers;
uint rateOfReduction = 20;

function setRateOfReduction(uint newRateOfReduction) public Ownable()  {
  rateOfReduction = newRateOfReduction;
}
function addSeller(string calldata name) external dupCheck(msg.sender){
  sellers.push(seller(name,msg.sender,0,0,0));
}
  function addItem(string calldata _productName, uint _price, uint _stock) external exiCheck(msg.sender){
    uint productId = products.push(product(_productName,_stock,_price,0)) - 1; //乱数の精製方法を変えるかも
    for(uint i=0; i<sellers.length; i++){      //プロダクトとセラーの結びつけをしている
     if(sellers[i].sellerAddress == msg.sender){  
        productToSeller[productId] = i;
      }
    }
  }
  function AddToCart(uint _productId,uint _items) external enoughStock(_productId,_items){
    addressToBuyerInformation[msg.sender].cart_contents.push(_productId);
    for(uint i=0; i<addressToBuyerInformation[msg.sender].cart_contents.length; i++){
      if(addressToBuyerInformation[msg.sender].cart_contents[i] == _productId){     //
        addressToBuyerInformation[msg.sender].items[i] = _items;
      }
    }
    addressToBuyerInformation[msg.sender].cart_price += products[_productId].price* _items;
  }
  function cartView() external view returns(string[] memory){
      uint length = addressToBuyerInformation[msg.sender].cart_contents.length;
      string[] memory show = new string[](length);
      for(uint i=0; i<length; i++){
        show[i] = (products[addressToBuyerInformation[msg.sender].cart_contents[i]].name);
      }
      return show;
  }
  function acceptPayment() external payable returns(bool){
    uint cart_price = addressToBuyerInformation[msg.sender].cart_price;
    require(cart_price<=msg.value);
    sub(msg.sender);
    addPoint(cart_price,msg.sender);
    addProcessed(msg.sender);
    addressToBuyerInformation[msg.sender].cart_price = 0;
    for(uint i=0; i<addressToBuyerInformation[sender].cart_contents.length; i++){
      addressToBuyerInfromation[msg.sender].cart_contents[i] = addressToBuyerInformation[msg.sender].inProcessing[i];
      delete addressToBuyerInformation[msg.sender].cart_contents[i];
    }
    return true;
  }
  function getCartPrice() public view returns(uint){
      return addressToBuyerInformation[msg.sender].cart_price;
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
  function sub(address buyerAddress) private{
    for(uint i=0; i<addressToBuyerInformation[buyerAddress].cart_contents.length; i++){
      products[addressToBuyerInformation[buyerAddress].cart_contents[i]].stock -= addressToBuyerInformation[buyerAddress].items[i];
    }
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
 }