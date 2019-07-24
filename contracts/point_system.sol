pragma solidity ^0.5.0;


contract point_system {

struct product{
  string name;
  uint stock;
  uint price;
}

mapping(uint=>address) productToSeller;

product[] public products;

  uint rateOfReduction = 20;

  function addItem(string calldata _productName, uint _price, uint _stock) external{
    uint productId = products.push(product(_productName,_stock,_price)) - 1;
    productToSeller[productId] = msg.sender;
  }




}
