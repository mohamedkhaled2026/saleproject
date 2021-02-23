import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class StoreItemListCard extends StatelessWidget {
  final String price;
  final String priceGomla;
  final String name;
  final String count;
  final Color bgColor;
  final Function pricePress;
  final Function onLongPress;
  final Function updatePress;
  final Function plusPress;
  final Function gomlaPress;

  const StoreItemListCard(
      {Key key,
      this.price,
      this.priceGomla,
      this.name,
      this.count,
      this.bgColor,
      this.updatePress,
      this.pricePress,
      this.onLongPress,
      this.plusPress,
      this.gomlaPress})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(right: 10, left: 10, bottom: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: bgColor,
      ),
      child: Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: 30,
                  child: IconButton(
                    onPressed: plusPress,
                    icon: new Icon(
                      FontAwesomeIcons.plusCircle,
                      color: Color(kTextColor),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 6,
                child: GestureDetector(
                  onLongPress: onLongPress,
                  //  onTap: piecePress,
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: EdgeInsets.only(right: 10),
                                    child: Text(
                                      name,
                                      style: kSubTitleTextStyle14.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      GestureDetector(
                                        onTap: gomlaPress,
                                        child: Container(
                                          decoration:BoxDecoration(
                                            color: Color(kTextColor),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          margin: EdgeInsets.only(right: 10 , bottom: 5),
                                          child: Text(
                                            ' سعر الجملة $priceGomla',
                                            style: kSubTitleTextStyle12.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: pricePress,
                                        child: Container(
                                          decoration:BoxDecoration(
                                            color: Color(kTextColor),
                                            borderRadius: BorderRadius.circular(3),
                                          ),
                                          margin: EdgeInsets.only(right: 10 , bottom: 5),
                                          child: Text(
                                            ' سعر القطاعى $price',
                                            style: kSubTitleTextStyle12.copyWith(
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  width: 40,
                  child: IconButton(
                    onPressed: updatePress,
                    icon: new Icon(
                      FontAwesomeIcons.cog,
                      color: Color(kTextColor),
                    ),
                  ),
                ),
              ),

            ],
          )),
    );
  }
}
