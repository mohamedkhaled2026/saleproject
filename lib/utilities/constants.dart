import 'dart:io';

import 'package:flutter/material.dart';

const kPrimaryColor = 0xFFFDCC55;
const kTextColor = 0xFF535353;
const kDarkRedColor = 0xffDB4437;
const kLightRedColor = 0xffde5246;
const kLightGreenColor = 0xff90ee90;

const kMainTitleTextStyle16 = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 16.0,
  color: Color(kTextColor),
  fontWeight: FontWeight.w600,
);

const kMainTitleTextStyle18 = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 18.0,
  color: Color(kTextColor),
  fontWeight: FontWeight.w600,
);

const kMainTitleTextStyle20 = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 20.0,
  color: Color(kTextColor),
  fontWeight: FontWeight.w700,
);

const kMainTitleTextStyle24 = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 24.0,
  color: Color(kTextColor),
  fontWeight: FontWeight.w700,
);

const kMainTitleTextStyle28 = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 28.0,
  color: Color(kTextColor),
  fontWeight: FontWeight.w700,
);

const kSubTitleTextStyle12 = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 12.0,
  color: Color(kTextColor),
  fontWeight: FontWeight.w600,
);

const kSubTitleTextStyle14 = TextStyle(
  fontFamily: 'Cairo',
  fontSize: 14.0,
  color: Color(kTextColor),
  fontWeight: FontWeight.w600,
);

var kRoundBoxDecoration = BoxDecoration(
color: Color(kPrimaryColor),
borderRadius: BorderRadius.circular(30),
);

var kRectBoxDecoration = BoxDecoration(
  color: Color(kPrimaryColor),
  borderRadius: BorderRadius.circular(5),
);

var kTextFieldDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderSide: BorderSide(
      width: 1,
      color: Color(kTextColor),
      style: BorderStyle.solid,
    ),
  ),
  fillColor: Colors.grey.withOpacity(.2),
  filled: true,
  focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(5.0)),
      borderSide: BorderSide(color: Color(kPrimaryColor))),
  contentPadding:
  EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
  // labelText: widget.title,
);


 const TextStyle optionStyle = TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
 const List<Widget> widgetOptions = <Widget>[
  Text(
    'Index 0: Home',
    style: optionStyle,
  ),
  Text(
    'Index 2: School',
    style: optionStyle,
  ),
];

class Constants{

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

}

// const KToast = Fluttertoast.showToast(
//
// );
