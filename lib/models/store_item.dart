import 'package:cloud_firestore/cloud_firestore.dart';

class StoreItem {
  int storeItemId;
  String storeItemBarCode;
  String storeItemName;
  int storeItemCat;
  String storeItemImgUrl;
  num storeItemAmount;
  num storeItemMinAmount;
  int storeItemUnit;
  num storeItemSellPrice;
  num storeItemBuyPrice;
  num storeItemBuyPriceGomla;
  bool isSelected = false;
  Timestamp lastUpdate;
  bool locked = false;
  StoreItem(
      {this.storeItemAmount,
      this.storeItemBuyPrice,
      this.storeItemBuyPriceGomla,
      this.storeItemCat,
      this.storeItemUnit,
      this.storeItemId,
      this.storeItemBarCode,
      this.storeItemImgUrl,
      this.storeItemMinAmount,
      this.storeItemName,
      this.storeItemSellPrice,
      this.locked
      });

  Map<String, dynamic> toJson() {
    return {
      'item_id': this.storeItemId,
      'item_bar_code': this.storeItemBarCode,
      'item_name': this.storeItemName,
      'item_cat': this.storeItemCat,
      'item_img_url': this.storeItemImgUrl,
      'item_amount': this.storeItemAmount,
      'item_min_amount': this.storeItemMinAmount,
      'item_unit': this.storeItemUnit,
      'item_sell_price': this.storeItemSellPrice,
      'item_buy_price': this.storeItemBuyPrice,
      'item_buy_price_gomla': this.storeItemBuyPriceGomla,
      'last_update' : this.lastUpdate,
      'locked': locked,
    };
  }

  factory StoreItem.fromJson(Map<String, dynamic> map) {
    return StoreItem(
        storeItemId: map['item_id'],
        storeItemBarCode: map['item_bar_code'] == null?'':map['item_bar_code'],
        storeItemName: map['item_name'],
        storeItemCat: map['item_cat'],
        storeItemUnit: map['item_unit'],
        storeItemImgUrl: map['item_img_url'] == null ? '':map['item_img_url'],
        storeItemAmount: map['item_amount'],
        storeItemMinAmount: map['item_min_amount'],
        storeItemSellPrice: map['item_sell_price'],
        storeItemBuyPrice: map['item_buy_price'],
        storeItemBuyPriceGomla: map['item_buy_price_gomla'],
        locked: map['locked'] == null?false:map['locked'],
    );

  }
}
