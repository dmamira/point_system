pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;
import "./point_system.sol";

contract transfer_system is point_system{
  function ConfirmOfReceipt(uint contentsNumber,uint items,uint evaluation) public confirmContentsNumber(contentsNumber,items,evaluation){  //modifierで、該当するContentsNumberがinProcessingの中に入っているということが証明されたため、ContentsNumberを信頼してもOK)
      if(evaluation == 1){
          sellers[productToSeller[contentsNumber]].good++;
      }else if(evaluation == 2){
          sellers[productToSeller[contentsNumber]].bad++;
      }
      uint transferValue = products[addressToBuyerInformation[sender].inProcessing[iForReference]].price * addressToBuyerInformation[sender].items[iForReference];
      delete addressToBuyerInformation[sender].inProcessing[iForReference]; //カートコンテンツを消すことでEtherが返還される。
      delete iForReference;  
  }
  modifier confirmContentsNumber(uint contentsNumber,uint items,uint evaluation,address sender){
      bool check = false;
      bool evaluationCheck = false;
      for(uint i=0; i<addressToBuyerInformation[sender].cart_contents.length; i++){
          uint CheckContentsNumber = addressToBuyerInformation[sender].inProcessing[i];
          uint CheckItems = addressToBuyerInformation[sender].items[i];
          if(CheckContentsNumber == contentsNumber && CheckItems == items){
             check = true;
             uint storage iForReference = i;
             break;
          }
      }
      if(evaluation == 1 || evaluation == 2){
          evaluationCheck = true;
      }
      require(check == true && evaluationCheck == true);
    }
  }