import 'package:flutter/material.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class Title extends StatefulWidget {
  @override
  _TitleState createState() => _TitleState();
}

class _TitleState extends State<Title> {
  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'الكابتن',
        style: kMainTitleTextStyle28,
      ),
    );
  }
}
