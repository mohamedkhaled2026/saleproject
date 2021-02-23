import 'package:cloud_firestore/cloud_firestore.dart';

class WaitingItem{

  int waitingItemId;
  num waitingItemAmount;
  num waitingItemSellPrice;
  num waitingItemBuyPrice;
  num waitingItemBuyPriceGomla;
  Timestamp addDate;

  WaitingItem({ this.waitingItemId,
        this.waitingItemAmount,
        this.waitingItemBuyPrice,
        this.waitingItemBuyPriceGomla,
        this.waitingItemSellPrice,
        this.addDate});

  Map<String, dynamic> toJson() {
    return {
      'waiting_item_id': this.waitingItemId,
      'waiting_item_amount': this.waitingItemAmount,
      'waiting_item_sell_price': this.waitingItemSellPrice,
      'waiting_item_buy_price': this.waitingItemBuyPrice,
      'waiting_item_buy_price_gomla': this.waitingItemBuyPriceGomla,
      'add_date': this.addDate,
    };
  }

  factory WaitingItem.fromJson(Map<String, dynamic> map) {
    return WaitingItem(
        waitingItemId: map['waiting_item_id'],
        waitingItemAmount: map['waiting_item_amount'],
        waitingItemSellPrice: map['waiting_item_sell_price'],
        waitingItemBuyPrice: map['waiting_item_buy_price'],
        waitingItemBuyPriceGomla: map['waiting_item_buy_price_gomla'],
        addDate: map['add_date']);
  }
}