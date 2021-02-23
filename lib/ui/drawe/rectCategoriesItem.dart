import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
class RectCategoryItem extends StatelessWidget {
  // final String categoryImage;
  final String categoryName;
  final Color bgColor;

  RectCategoryItem({
    // this.categoryImage,
    this.categoryName,
    this.bgColor
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      height: 70,
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: 5),
            child: Text(
              categoryName,
              style: kSubTitleTextStyle14.copyWith(
                wordSpacing: 2,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),

            ),

          ),

        ],
      ),
    );
  }
}
