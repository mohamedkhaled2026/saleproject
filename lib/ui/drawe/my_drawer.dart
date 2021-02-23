import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/screens/shortcomings_screen.dart';
import 'package:sale_pro_elcaptain/screens/wallet_screen.dart';
import 'package:sale_pro_elcaptain/screens/bill_reports_screen.dart';
import 'package:sale_pro_elcaptain/screens/edit_user_screen.dart';
import 'package:sale_pro_elcaptain/screens/home_screen.dart';
import 'package:sale_pro_elcaptain/screens/petty_cash_screen.dart';
import 'package:sale_pro_elcaptain/screens/settings_screen.dart';
import 'package:sale_pro_elcaptain/services/firestore_user_service.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'my_drawer_items.dart';
class MyDrawer extends StatelessWidget {
  final FirestoreUserService _firebaseUserService = FirestoreUserService();
  @override
  Widget build(BuildContext context) {
    return  Drawer(
      child: Container(
        color: Color(kPrimaryColor),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child:Column(
                children: [
                  Row(
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        color: Color(kTextColor),
                        size: 25,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'معلومات الحساب',
                        style: kMainTitleTextStyle20,
                      ),
                    ],
                  ),
                  // the Header of page
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    decoration: BoxDecoration(
                        color: Color(kPrimaryColor),
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context){
                              return SettingsScreen(context);
                            }));
                          },
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Icon(
                              FontAwesomeIcons.solidUserCircle,
                              size: 50,
                              color: Color(kTextColor),
                            ),
                          ),
                        ),
                        FutureBuilder<Map<String, dynamic>>(
                            future: _firebaseUserService.getUserInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.hasData) {
                                return Row(
                                  children: [
                                    Container(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            height: 8,
                                          ),
                                          Text(
                                            snapshot.data['user_name'],
                                            style: kMainTitleTextStyle18.copyWith(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(snapshot.data['user_type'],
                                              style: kMainTitleTextStyle16),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                    ),
                                    GestureDetector(
                                      onTap: () async {
                                        SharedPreferences shared =
                                        await SharedPreferences.getInstance();
                                        String ownerUser =
                                        shared.getString('user_type');
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    EditUserScreen(
                                                      currentUser: User(
                                                          userId: snapshot
                                                              .data['user_id'],
                                                          userName: snapshot
                                                              .data['user_name'],
                                                          userType: snapshot
                                                              .data['user_type']),
                                                      ownerUser: ownerUser,
                                                      homeContext:
                                                      context,
                                                    )));
                                      },
                                      child: Container(
                                        margin: EdgeInsets.all(4),
                                        padding: EdgeInsets.all(4),
                                        height: 60,
                                        width: 60,
                                        decoration: BoxDecoration(
                                            color: Color(kTextColor),
                                            borderRadius:
                                            BorderRadius.circular(30)),
                                        child: Icon(
                                          FontAwesomeIcons.usersCog,
                                          color: Color(kPrimaryColor),
                                          size: 30,
                                        ),
                                      ),
                                    )
                                  ],
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            }),
                      ],
                    ),
                  ),
                ],
              )
            ),
            MyDrawerItem(
              name: 'الرئيسية',
              icon: FontAwesomeIcons.home,
              onPress: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return HomeScreen(0);
                }));
              },
            ),
            MyDrawerItem(
              name: 'الخزنة',
              icon: FontAwesomeIcons.wallet,
              onPress: (){
              Navigator.push(context, MaterialPageRoute(builder: (context){
                return WalletScreen();
              }));
              },
            ),
            MyDrawerItem(
              name: 'المصروفات',
              icon: FontAwesomeIcons.handHoldingUsd,
              onPress: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return PettyCashScreen();
                }));
              },
            ),
            MyDrawerItem(
              name: 'النواقص',
              icon: FontAwesomeIcons.cartPlus,
              onPress: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return ShortcomingsScreen(context);
                }));
              },
            ),
            MyDrawerItem(
              name: 'التقارير',
              icon: FontAwesomeIcons.clipboardList,
              onPress: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return BillReportsScreen(context);
                }));
              },
            ),
            MyDrawerItem(
              name: 'الفواتير',
              icon: FontAwesomeIcons.fileInvoiceDollar,
              onPress: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return WalletScreen();
                }));
              },
            ),
            MyDrawerItem(
              name: 'الموردين',
              icon: FontAwesomeIcons.truck,
              onPress: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return WalletScreen();
                }));
              },
            ),
            MyDrawerItem(
              name: 'الإعدادات',
              icon: FontAwesomeIcons.cog,
              onPress: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return WalletScreen();
                }));
              },
            ),
            MyDrawerItem(
              name: 'تواصل معنا',
              icon: FontAwesomeIcons.solidQuestionCircle,
              onPress: (){
                Navigator.push(context, MaterialPageRoute(builder: (context){
                  return WalletScreen();
                }));
              },
            ),
            MyDrawerItem(
              name: 'تسجيل الخروج',
              icon: FontAwesomeIcons.doorOpen,
              onPress: () async{
                _firebaseUserService.signOut(context);
              },
            ),

          ],
        ),
      ),
    );
  }
}
