import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class MyDrawerHeader extends StatelessWidget {
  final String userName ;
  final String userPhone ;

  MyDrawerHeader({
    this.userPhone,
    this.userName
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Color(kPrimaryColor),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                color: Color(kTextColor),
              ),
              child: Container(
                padding: EdgeInsets.all(15),
                child: Icon(FontAwesomeIcons.userAlt,
                  color: Color(kPrimaryColor),
                  size: 30,),
              )
          ),
          ),
          SizedBox(width: 10,),
          Expanded(
            flex: 6,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //Image.asset(logo),
                    Text(
                      userName,
                      style: kMainTitleTextStyle18,
                    ),
                    Text(
                      userPhone,
                      style: kSubTitleTextStyle14,
                    )
                  ],
                ),

              ],
            ),          ),
          Expanded(
            flex: 1,
            child: InkWell(
              onTap: (){

              },
              child: Icon(
                FontAwesomeIcons.cog,
                color: Color(kTextColor),
              ),
            ),
          )
        ],
      ),
    );
  }
}
