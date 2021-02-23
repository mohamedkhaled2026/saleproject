import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';

class ContactUsScreen extends StatefulWidget {
  @override
  _ContactUsScreenState createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 6,
          bottomOpacity: 3,
          toolbarHeight: 80,
          title: Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              'الخزنة ورأس المال',
              style: kMainTitleTextStyle18.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            backButton(),
          ],
          leading: Container(),
          centerTitle: true,
          backgroundColor: Color(kPrimaryColor),
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(kTextColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                child: SvgPicture.asset(
                  'images/safe-box.svg',
                  height: MediaQuery.of(context).size.width * .6,
                  width: 150,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text('المبلغ الموجود بالخزنة : ', style: kMainTitleTextStyle28
                  .copyWith(
                color: Color(kLightGreenColor,),
                fontWeight: FontWeight.bold,),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.moneyBillWave,
                    color: Color(kLightGreenColor),
                    size: 25,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text('1000000' , style: kMainTitleTextStyle28
                      .copyWith(
                    fontSize: 48,
                    color: Color(kLightGreenColor,),
                    fontWeight: FontWeight.bold,
                  ),),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
