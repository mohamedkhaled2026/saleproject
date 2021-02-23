import 'package:flutter/material.dart';


class AppBarTitle extends StatelessWidget {
  String title;
  AppBarTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(color: Colors.white,fontSize: 28,fontWeight: FontWeight.bold),
    );
  }
}
