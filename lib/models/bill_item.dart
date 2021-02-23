class BillItem{
  int billItemCounter;
  int billItemId;
  String billItemName;
  num billItemAmount;
  num billItemPrice;
  num billItemSellPrice;

  BillItem({this.billItemId,this.billItemAmount,this.billItemPrice,this.billItemName,this.billItemSellPrice,this.billItemCounter,});


  Map<String,dynamic> toJson(){
    return{
      'bill_item_id':this.billItemId,
      'bill_item_amount':this.billItemAmount,
      'bill_item_price':this.billItemPrice,
      'bill_item_sell_price' :this.billItemSellPrice,


    };
  }

  factory BillItem.fromJson(Map<String,dynamic> map){
    return BillItem(
      billItemId: map['bill_item_id'],
      billItemAmount: map['bill_item_amount'],
      billItemPrice: map['bill_item_price'],
      billItemSellPrice: map['bill_item_sell_price'],

    );
  }


}