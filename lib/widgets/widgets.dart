import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';


Container SearchTab = Container(
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          //Search Widget
          Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Directionality(
                  textDirection: TextDirection.rtl,
                  child:Padding(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child:  Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: TextField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                              ),
                              contentPadding:
                              EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                              hintText: 'إبحث عن المُنتج',
                              hintStyle: TextStyle(
                                  color: Color(kTextColor),
                                  fontSize: 12,
                                  fontFamily: 'Cairo',),
                            ),
                          )
                        ),
                        Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.search,
                            size: 20,
                            color: Color(kTextColor),
                          ),
                        ),
                      ],
                    ),
                  )
              )
          ),


        ],
      ),
    )
);

TextField _field = TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(
      borderSide: BorderSide.none,
    ),
    fillColor: Colors.white,
    filled: true,
    focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(5.0)),
        borderSide: BorderSide(color: Color(kPrimaryColor))),
    contentPadding:
    EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
  ),
);




/*
Container SearchTab = Container(
    child: Directionality(
      textDirection: TextDirection.rtl,
      child: Column(
        children: [
          //Search Widget
          Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Directionality(
                  textDirection: TextDirection.rtl,
                  child:Padding(
                    padding: EdgeInsets.only(right: 10, left: 5),
                    child:  Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Text(
                            'البحث عن المنتج ',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(KTextColor),
                              fontFamily: 'Cairo',
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: Icon(
                            Icons.search,
                            size: 20,
                            color: Color(KTextColor),
                          ),
                        ),
                      ],
                    ),
                  )
              )
          ),


        ],
      ),
    )
);
 */