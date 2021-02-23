import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class RoundCategoryItem extends StatelessWidget {
  // final String categoryImage;
  final String categoryName;

  RoundCategoryItem({
    // this.categoryImage,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 100,
      height: 100,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(left: 10,right: 10),
      decoration: BoxDecoration(
        color: Color(kPrimaryColor),
        borderRadius: BorderRadius.circular(80),
      ),
      child: Column(
        children: [
          Container(
              child: Text(
                categoryName,
                style: kSubTitleTextStyle14,

              ),
            // child: SvgPicture.asset(
            //   categoryImage,
            //   color: Color(kTextColor),
            //   width: 30,
            //   height: 30,
            // ),

          ),

        ],
      ),
    );
  }
}
