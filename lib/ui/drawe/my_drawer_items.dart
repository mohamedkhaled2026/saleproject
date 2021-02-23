import 'package:flutter/material.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class MyDrawerItem extends StatelessWidget {
  final String name ;
  final IconData icon ;
  final Function onPress;

   MyDrawerItem({
    this.name,
    this.icon,
     this.onPress,
  });
  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        name,
        style: kSubTitleTextStyle14
      ),
      leading: Icon(
        icon,
        color: Color(kTextColor),
        size: 25,
        textDirection: TextDirection.rtl,
      ),
      onTap: onPress,
    );
  }
}
