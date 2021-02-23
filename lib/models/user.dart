import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  int userId;
  final String userName;
  String userType;
  String userPassword;
  Timestamp lastUpdate;
  bool locked;
  bool addBill;
  bool updateBill;
  bool deleteBill;
  bool addItem;
  bool updateItem;
  bool deleteItem;
  bool addCommon;
  bool deleteCommon;
  bool showShortage;
  bool repTotal;
  bool repItemsAmount;
  bool repBillProfit;
  bool repAllBills;
  bool repOwnBills;
  User(
      {this.userId,
        this.userName,
        this.userType,
        this.lastUpdate,
        this.locked,
        this.addBill,
        this.updateBill,
        this.deleteBill,
        this.addItem,
        this.updateItem,
        this.deleteItem,
        this.addCommon,
        this.deleteCommon,
        this.showShortage,
        this.repTotal,
        this.repItemsAmount,
        this.repBillProfit,
        this.repAllBills,
        this.repOwnBills,
        this.userPassword,
      });

  Map<String, dynamic> toJson() {
    return {
      'user_id': this.userId,
      'user_name': this.userName,
      'user_type': this.userType,
      'last_update': this.lastUpdate,
      'locked': locked,
      'add_bill': addBill,
      'update_bill': updateBill,
      'delete_bill': deleteBill,
      'add_item': addItem,//
      'update_item': updateItem,
      'delete_item': deleteItem,
      'add_common': addCommon,
      'delete_common': deleteCommon,
      'show_shortage': showShortage,//
      'rep_total': repTotal,
      'rep_items_amount': repItemsAmount,
      'rep_bill_profit': repBillProfit,
      'rep_all_bills': repAllBills,
      'rep_own_bills': repOwnBills,
      'user_password': userPassword,
    };
  }

  factory User.fromJson(Map<String, dynamic> map) {
    return User(
      userId: map['user_id'],
      userName: map['user_name'],
      userType: map['user_type'],
      userPassword: map['user_password'],
      lastUpdate: map['last_update'],
      locked: map['locked'],
      addBill: map['add_bill'] == null? true:map['add_bill'],
      updateBill: map['update_bill'] == null? true:map['update_bill'],
      deleteBill: map['delete_bill'] == null? true:map['delete_bill'],
      addItem: map['add_item'] == null? true:map['add_item'],
      updateItem: map['update_item'] == null? true:map['update_item'],
      deleteItem: map['delete_item'] == null? true:map['delete_item'],
      addCommon: map['add_common'] == null? true:map['add_common'],
      deleteCommon: map['delete_common'] == null? true:map['delete_common'],
      showShortage: map['show_shortage'] == null? true:map['show_shortage'],
      repTotal: map['rep_total'] == null? true:map['rep_total'],
      repItemsAmount: map['rep_items_amount'] == null? true:map['rep_items_amount'],
      repBillProfit: map['rep_bill_profit'] == null? true:map['rep_bill_profit'],
      repAllBills: map['rep_all_bills'] == null? true:map['rep_all_bills'],
      repOwnBills: map['rep_own_bills'] == null? true:map['rep_own_bills'],

    );
  }
}
