import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class Logo extends StatefulWidget {
  @override
  _LogoState createState() => _LogoState();
}

class _LogoState extends State<Logo> {
  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'images/soccer-ball.svg',
      height: 80,
      width: 80,
      color: Color(kPrimaryColor),
    );
  }
}
