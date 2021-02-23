import 'package:flutter/material.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class SubmitButton extends StatefulWidget {
  final String title;
  final Function onTap;
  SubmitButton({this.title,this.onTap});
  @override
  _SubmitButtonState createState() => _SubmitButtonState();
}

class _SubmitButtonState extends State<SubmitButton> {
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey.shade200,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          color: Color(kPrimaryColor),
        ),
        child: Text(
          widget.title,
          style: TextStyle(
              fontSize: 14,
              color: Color(kTextColor),
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
