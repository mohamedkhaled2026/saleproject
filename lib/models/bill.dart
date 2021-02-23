import 'package:cloud_firestore/cloud_firestore.dart';

class Bill {
  int billId;
  final int billUser;
  String userName;
  final Timestamp billDate;
  final num billTotalPrice;
  final num billTotalSellPrice;

  Bill(
      {this.billId,
      this.billUser,
      this.billDate,
      this.billTotalPrice,
      this.billTotalSellPrice});

  Map<String, dynamic> toJson() {
    return {
      'bill_id': this.billId,
      'bill_date': this.billDate,
      'bill_user': this.billUser,
      'bill_total_price': this.billTotalPrice,
      'bill_total_sell_price': this.billTotalSellPrice,
    };
  }

  factory Bill.fromJson(Map<String, dynamic> map) {
    return Bill(
      billId: map['bill_id'],
      billDate: map['bill_date'],
      billUser: map['bill_user'],
      billTotalPrice: map['bill_total_price'],
      billTotalSellPrice: map['bill_total_sell_price'],
    );
  }
}
