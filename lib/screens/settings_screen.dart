import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sale_pro_elcaptain/services/firestore_user_service.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/screens/edit_user_screen.dart';
import 'package:sale_pro_elcaptain/screens/splash_screen.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';


class SettingsScreen extends StatefulWidget {
  final BuildContext homeContext;
  SettingsScreen(this.homeContext);
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  FirestoreUserService _firebaseUserService = FirestoreUserService();
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  var listen;
  final ItemScrollController itemScrollController = ItemScrollController();
  int userId;
  List<User> userList = List<User>();
  bool locked = false;


  listenToAnyPrivChange() async {
    int counter = 0;
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    int userId = _sharedPreferences.getInt('user_id');
    listen = _userCollection
        .doc(userId.toString())
        .snapshots(includeMetadataChanges: false)
        .listen((doc) async {
      if (doc.exists) {
        counter++;
        if (counter > 1) {
          if (context != null) {
            SharedPreferences shared = await SharedPreferences.getInstance();
            shared.setInt('user_id', null);
            shared.setString('user_name', null);
            shared.setString('user_type', null);
            Navigator.pop(widget.homeContext);
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) {
              return SplashScreen();
            }));
            listen.cancel();
          }
          counter = 0;
        }
      } else {
        print('error');
      }
    });
  }

  @override
  void initState() {
    listenToAnyPrivChange();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          elevation: 6,
          toolbarHeight: 70,
          backgroundColor: Color(kPrimaryColor),
          title: Text(
            'الإعدادات',
            style: kMainTitleTextStyle24,
          ),
          centerTitle: true,
          actions: [
            backButton(),
          ],
          shadowColor: Color(kTextColor),
          leading: SizedBox(width: 50,height: 50,),
        ),
        body: Container(
          padding: EdgeInsets.all(20),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              SizedBox(
                height: 10,
              ),
              //page body
              // كونتينر الـ users
              FutureBuilder<SharedPreferences>(
                  future: SharedPreferences.getInstance(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return Column(
                        children: [
                          Container(
                            child: Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: Color(kTextColor),
                                  size: 25,
                                ),
                                SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  snapshot.data.getString('user_type') ==
                                          'admin'
                                      ? 'المستخدمين'
                                      : 'الصلاحيات',
                                  style: kMainTitleTextStyle20,
                                ),
                              ],
                            ),
                          ),
                          snapshot.data.getString('user_type') == 'admin'
                              ? SingleChildScrollView(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 300,
                                          margin: EdgeInsets.symmetric(
                                              vertical: 20, horizontal: 10),
                                          decoration: BoxDecoration(
                                              color: Color(kPrimaryColor),
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: FutureBuilder<List<User>>(
                                            future: _firebaseUserService
                                                .getAllUsers(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return ScrollablePositionedList
                                                    .builder(
                                                  scrollDirection:
                                                      Axis.vertical,
                                                  itemCount:
                                                      snapshot.data.length,
                                                  itemScrollController:
                                                      itemScrollController,
                                                  itemBuilder:
                                                      (context, index) {
                                                    userList = List<User>();
                                                    userList
                                                        .addAll(snapshot.data);
                                                    return GestureDetector(
                                                      onTap: () {
                                                        //_audioCache.play('butttton.mp3');
                                                      },
                                                      child: Container(
                                                        margin: EdgeInsets.only(
                                                            right: 10,
                                                            left: 10),
                                                        child: Column(
                                                          children: [
                                                            Row(
                                                              children: [
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets
                                                                        .all(4),
                                                                    height: 30,
                                                                    width: 30,
                                                                    decoration: BoxDecoration(
                                                                        color: Color(
                                                                            kTextColor),
                                                                        borderRadius:
                                                                            BorderRadius.circular(15)),
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          Text(
                                                                        (index +
                                                                                1)
                                                                            .toString(),
                                                                        style: kSubTitleTextStyle14.copyWith(
                                                                            color:
                                                                                Color(kPrimaryColor)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 3,
                                                                  child:
                                                                      Container(
                                                                    margin: EdgeInsets.only(
                                                                        right:
                                                                            10),
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              snapshot.data[index].userName,
                                                                              style: kMainTitleTextStyle18,
                                                                            )
                                                                          ],
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Text(
                                                                              snapshot.data[index].userType,
                                                                              style: kSubTitleTextStyle14,
                                                                            )
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 1,
                                                                  child:
                                                                      CupertinoSwitch(
                                                                    activeColor:
                                                                        Colors
                                                                            .white,
                                                                    trackColor:
                                                                        Color(
                                                                            kTextColor),
                                                                    value:
                                                                        snapshot.data[index].locked,
                                                                    onChanged: (bool
                                                                        value) {
                                                                      setState(
                                                                          () {
                                                                            snapshot.data[index].locked =
                                                                            value;
                                                                      });
                                                                      _firebaseUserService.lockUser(snapshot.data[index]);
                                                                    },
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  width: 5,
                                                                ),
                                                                Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        SharedPreferences
                                                                            shared =
                                                                            await SharedPreferences.getInstance();
                                                                        String
                                                                            ownerUser =
                                                                            shared.getString('user_type');
                                                                        Navigator.push(
                                                                            context,
                                                                            MaterialPageRoute(
                                                                                builder: (context) => EditUserScreen(
                                                                                      currentUser: snapshot.data[index],
                                                                                      ownerUser: ownerUser,
                                                                                      homeContext: widget.homeContext,
                                                                                      settingContext: context,
                                                                                    )));
                                                                      },
                                                                      child:
                                                                          Container(
                                                                        margin:
                                                                            EdgeInsets.all(4),
                                                                        padding:
                                                                            EdgeInsets.all(4),
                                                                        height:
                                                                            30,
                                                                        width:
                                                                            30,
                                                                        decoration: BoxDecoration(
                                                                            color:
                                                                                Color(kTextColor),
                                                                            borderRadius: BorderRadius.circular(15)),
                                                                        child:
                                                                            Icon(
                                                                          FontAwesomeIcons
                                                                              .usersCog,
                                                                          color:
                                                                              Color(kPrimaryColor),
                                                                          size:
                                                                              15,
                                                                        ),
                                                                      ),
                                                                    )),
                                                              ],
                                                            ),
                                                            Divider(
                                                              color: Color(
                                                                  kTextColor),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                );
                                              } else {
                                                return Center(
                                                    child:
                                                        CircularProgressIndicator());
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                            height: 300,
                                            margin: EdgeInsets.symmetric(
                                                vertical: 20, horizontal: 10),
                                            decoration: BoxDecoration(
                                                color: Color(kPrimaryColor),
                                                borderRadius:
                                                    BorderRadius.circular(10)),
                                            child: ListView(
                                              children: [
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'اضافة فاتورة',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'add_bill'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'تعديل فاتورة',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'update_bill'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'حذف فاتورة',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'delete_bill'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'اضافة منتج',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'add_item'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'تعديل منتج',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'update_item'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'حذف منتج',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'delete_item'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'اضافة فالمنتجات الشائعة',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'add_common'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'حذف من المنتجات الشائعة',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'delete_common'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'رؤية النواقص',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'show_shortage'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'رؤية تقرير الاجماليات',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'rep_total'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'رؤية تقرير سحب الاصناف',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'rep_items_amount'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'رؤية تقرير ارباح الفواتير',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'rep_bill_profit'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'رؤية كل الفواتير',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'rep_all_bills'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  color: Colors.white54,
                                                  margin: EdgeInsets.all(5),
                                                  child: ListTile(
                                                    title: Text(
                                                      'رؤية فواتير المستخدم',
                                                      style:
                                                          kMainTitleTextStyle16,
                                                    ),
                                                    trailing: Transform.scale(
                                                      scale: 0.8,
                                                      child: CupertinoSwitch(
                                                        activeColor: Color(
                                                            kPrimaryColor),
                                                        trackColor:
                                                            Color(kTextColor),
                                                        value: snapshot.data
                                                            .getBool(
                                                                'rep_own_bills'),
                                                        onChanged: (v){

                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            )),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      );
                    } else {
                      return CircularProgressIndicator();
                    }
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
