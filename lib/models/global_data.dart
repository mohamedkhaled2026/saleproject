import 'package:flutter/material.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GlobalData  {
  SharedPreferences _sharedPreferences;
  User currentUser = User();
  Future<User> getCurrentUserData() async{
    _sharedPreferences = await SharedPreferences.getInstance();
    if(_sharedPreferences.getInt('user_id') != null){
      currentUser.userId = _sharedPreferences.getInt('user_id');
      currentUser.userType = _sharedPreferences.getString('user_type');
    }
    return currentUser;
  }
}