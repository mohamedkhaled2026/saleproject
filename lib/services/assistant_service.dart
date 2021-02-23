import 'dart:io';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
class AssistantService {

  FToast fToast;
  static Future<bool> checkInternet() async{
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
  }

  void showToast(BuildContext context,String message,Color color,num fontSize){
    fToast = FToast();
    fToast.init(context);
    Widget toast = Container(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Color(kTextColor),
      ),
      child: Column(
        children: [
          SvgPicture.asset(
            'images/magician-svg.svg',
            height: 70,
            width: 70,
            color: color,
          ),

          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(message,style: kMainTitleTextStyle16.copyWith(color: Colors.white,fontSize: fontSize.toDouble())),
            ],
          ),
        ],
      )
    );
    fToast.showToast(child: toast,gravity: ToastGravity.TOP,toastDuration: Duration(seconds: 3));
  }

}