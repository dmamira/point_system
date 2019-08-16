pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract point_system {

struct product{
  string name;
  uint stock;
  uint price;
  uint items;
  uint 
}

mapping(uint=>address) productToSeller;
mapping(address=>uint) proceedsToSeller;
mapping(address=>uint) buyerToPoint;
mapping(address=>product[]) cart_contents;
mapping(address=>uint) cart_price;
product[] public products;

  uint rateOfReduction = 20;

  function addItem(string calldata _productName, uint _price, uint _stock) external{
    uint productId = products.push(product(_productName,_stock,_price,0)) - 1;
    productToSeller[productId] = msg.sender;
  }
  function cart(uint _productId,uint _items) external enoughStock(_productId,_items){
    product memory  buyProduct;
    buyProduct = product(products[_productId].name,products[_productId].stock,products[_productId].price,_items);
    cart_contents[msg.sender].push(buyProduct);
    cart_price[msg.sender] += buyProduct.price * _items;
  }
  function cartView() external view returns(product[] memory){
    return cart_contents[msg.sender];
  }
  function acceptPayment() external payable returns(bool){//プロダクトIDとアイテム数をカートに入れて参照できるようにする。
    require(cart_price[msg.sender]<=msg.value);
    sub(msg.sender);
    addPoint(cart_price[msg.sender]);
    return true;
  }
  function sub(address buyer) private{
    for(uint i=0; i<cart_contents[buyer].length; i++){
      uint b = cart_contents[buyer][i].items;
      cart_contents[buyer][i].stock -= b;
    }
  }
  function addPoint(uint _totalValue) private{
    buyerToPoint[msg.sender] += _totalValue*rateOfReduction;
  }

  modifier enoughStock(uint _productId,uint _items){
    require(products[_productId].stock>=_items);
    _;
  }
}
