import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirestoreUserService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  SharedPreferences sharedPreferences;

  Future<String> getMaxIdPlusOne() async {
    int userId =
        (await _usersCollection.orderBy('user_id', descending: true).get())
            .docs
            .first
            .data()['user_id'];
    return (userId + 1).toString();
  }

  Future<bool> checkUserExist(String userName) async {
    List<DocumentSnapshot> docs = (await _usersCollection.get()).docs;
    for (DocumentSnapshot doc in docs) {
      if (doc.data()['user_name'] == userName) {
        return true;
      }
    }
    return false;
  }

  addUser(String userName, String userPassword, String userType) async {
    String uId = await getMaxIdPlusOne();

    _usersCollection.doc(uId).set({
      'user_id': int.parse(uId),
      'user_name': userName,
      'user_password': userPassword,
      'user_type': userType,
      'last_update': Timestamp.fromDate(DateTime.now()),
      'locked': false,
      'add_bill': true,
      'update_bill': false,
      'delete_bill': false,
      'add_item': false,
      'update_item': false,
      'delete_item': false,
      'add_common': false,
      'delete_common': false,
      'show_shortage': false,
      'rep_total': false,
      'rep_items_amount': false,
      'rep_bill_profit': false,
      'rep_all_bills': false,
      'rep_own_bills': true,
    }).then((value) {
      return true;
    }).catchError((error) {
      print("Failed to add user: $error");
      return false;
    });
    return true;
  }

  Future<bool> editUser(int userId, String userName,String userOldPassword, String userPassword, String userType) async {
    if((await _usersCollection.doc(userId.toString()).get()).data()['user_password'] == userOldPassword) {
      _usersCollection.doc(userId.toString()).update({
        'user_id': userId,
        'user_name': userName,
        'user_password': userPassword,
        'user_type': userType,
        'last_update': Timestamp.fromDate(DateTime.now()),
      }).then((value) {
        return true;
      }).catchError((error) {
        print("Failed to update user: $error");
        return false;
      });
    }else{
      return false;
    }
    return true;
  }

  lockUser(User user) {
    _usersCollection
        .doc(user
        .userId
        .toString())
        .update({
      'locked':
      user.locked,
    });
  }

  storeUserInfo(User currentUser) async {
    SharedPreferences sharedPreferences;
    sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setInt('user_id', currentUser.userId);
    sharedPreferences.setString('user_name', currentUser.userName);
    sharedPreferences.setString('user_type', currentUser.userType);
    sharedPreferences.setInt(
        'last_update', currentUser.lastUpdate.millisecondsSinceEpoch);
  }

  Future<User> getUserDataById(String userId) async {
    return (User.fromJson((await _usersCollection.doc(userId).get()).data()));
  }

  Future<Map<String, dynamic>> getUserInfo() async {
    sharedPreferences = await SharedPreferences.getInstance();
    Map<String, dynamic> userInfo = Map<String, dynamic>();
    userInfo['user_id'] = sharedPreferences.getInt('user_id');
    userInfo['user_name'] = sharedPreferences.getString('user_name');
    userInfo['user_type'] = sharedPreferences.getString('user_type');
    return userInfo;
  }

  Future<bool> signIn(String userName, String password) async {
    QuerySnapshot querySnapshot = (await _usersCollection
        .where('user_name', isEqualTo: userName)
        .where('user_password', isEqualTo: password)
        .get());
    if (querySnapshot.docs.length != 0) {
      User currentUser = User.fromJson(querySnapshot.docs.first.data());
      sharedPreferences = await SharedPreferences.getInstance();
      sharedPreferences.setInt('user_id', currentUser.userId);
      sharedPreferences.setString('user_name', userName);
      sharedPreferences.setString('user_type', currentUser.userType);
      sharedPreferences.setBool('locked', currentUser.locked);
      sharedPreferences.setBool('add_bill', currentUser.addBill);
      sharedPreferences.setBool('update_bill', currentUser.updateBill);
      sharedPreferences.setBool('delete_bill', currentUser.deleteBill);
      sharedPreferences.setBool('add_item', currentUser.addItem);
      sharedPreferences.setBool('update_item', currentUser.updateItem);
      sharedPreferences.setBool('delete_item', currentUser.deleteItem);
      sharedPreferences.setBool('add_common', currentUser.addCommon);
      sharedPreferences.setBool('delete_common', currentUser.deleteCommon);
      sharedPreferences.setBool('show_shortage', currentUser.showShortage);
      sharedPreferences.setBool('rep_total', currentUser.repTotal);
      sharedPreferences.setBool('rep_items_amount', currentUser.repItemsAmount);
      sharedPreferences.setBool('rep_bill_profit', currentUser.repBillProfit);
      sharedPreferences.setBool('rep_all_bills', currentUser.repAllBills);
      sharedPreferences.setBool('rep_own_bills', currentUser.repOwnBills);
      return true;
    } else {
      return false;
    }
  }

  signOut(BuildContext context) async{
    SharedPreferences shared = await SharedPreferences.getInstance();
    shared.setInt('user_id', null);
    shared.setString('user_name', null);
    shared.setString('user_type', null);
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }));
  }

  Future<bool> editUserPrivileges(User currentUser) async {
    _usersCollection
        .doc(currentUser.userId.toString())
        .update(currentUser.toJson())
        .then((value) {
      return true;
    }).catchError((error) {
      print("Failed to update user: $error");
      return false;
    });
    return true;
  }

  Future<bool> isUserLocked(String userName, String password) async {
    return (await FirebaseFirestore.instance
            .collection('users')
            .where('user_name', isEqualTo: userName)
            .where('user_password', isEqualTo: password)
            .get())
        .docs
        .first
        .data()['locked'];
  }

  Future<List<User>> getAllUsers() async {
    List<User> usersList = List<User>();
    List<DocumentSnapshot> docs =
        (await _usersCollection.where('user_id', isNotEqualTo: 1).get()).docs;
    for (DocumentSnapshot doc in docs) {
      User user = User.fromJson(doc.data());
      usersList.add(user);
    }
    return usersList;
  }
}
