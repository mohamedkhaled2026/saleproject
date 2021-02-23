import 'package:flutter/material.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class EntryField extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final bool isPassword;
  bool enabled = true;
  EntryField({this.title,this.isPassword,this.controller,this.enabled});
  @override
  _EntryFieldState createState() => _EntryFieldState();
}

class _EntryFieldState extends State<EntryField> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(kTextColor),
                  fontFamily: 'Cairo'),
            ),
            Container(
              height: 50,
              child: TextField(
                controller: widget.controller,
                obscureText: widget.isPassword,
                enabled: widget.enabled,
                decoration: InputDecoration(
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
                  labelText: widget.title,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
