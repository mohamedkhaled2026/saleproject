import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/services/firestore_user_service.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';

class UserPowerScreen extends StatefulWidget {
  final User currentUser;
  UserPowerScreen(this.currentUser);
  @override
  _UserPowerScreenState createState() => _UserPowerScreenState();
}

class _UserPowerScreenState extends State<UserPowerScreen> {
  FirestoreUserService _firebaseUserService =FirestoreUserService();
  AudioCache audioCache;


  Widget _submitButton() {
    return InkWell(
      onTap: () {
        widget.currentUser.lastUpdate = Timestamp.fromDate(DateTime.now());
        _firebaseUserService.editUserPrivileges(widget.currentUser);
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 5),
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
                color: Colors.grey,
                offset: Offset(2, 4),
                blurRadius: 5,
                spreadRadius: 2)
          ],
          color: Color(kPrimaryColor),
        ),
        child: Text(
          'تأكيد',
          style: TextStyle(
              fontSize: 14,
              color: Color(kTextColor),
              fontFamily: 'Cairo',
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    audioCache = AudioCache(prefix: "sound/", fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));

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
            title: Container(
              margin: EdgeInsets.only(top: 20),
                child: Text(
                  'صلاحيات المُستخدمين',
                  style: kMainTitleTextStyle18,
                ),
            ),
            centerTitle: true,
            leading: Container(),

          ),
          body: Container(
            color: Colors.black12,
            padding: EdgeInsets.all(10),
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 150,
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Color(kTextColor),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 10,
                            right: 10,
                            child: Icon(
                              FontAwesomeIcons.solidLightbulb ,
                              color: Color(kPrimaryColor),
                              size: 50,
                            ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 30 , right: 70),
                          child: Text('’’ التغير فى هذه الإعدادت سوف يُتيح للمستخدم أن يكون مسئول عن صلاحيات لم تكن مٌتاحة له ‘‘' ,
                          style: kMainTitleTextStyle18.copyWith(color: Color(kPrimaryColor)),
                        ),)
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('اضافة فاتورة'  , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.addBill,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.addBill = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.addBill = !widget.currentUser.addBill;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('تعديل فاتورة', style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.updateBill,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.updateBill = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.updateBill = !widget.currentUser.updateBill;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('حذف فاتورة', style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.deleteBill,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.deleteBill = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.deleteBill = !widget.currentUser.deleteBill;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('اضافة منتج', style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.addItem,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.addItem = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.addItem = !widget.currentUser.addItem;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('تعديل منتج' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.updateItem,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.updateItem = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.updateItem = !widget.currentUser.updateItem;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('حذف منتج'  , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.deleteItem,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.deleteItem = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.deleteItem = !widget.currentUser.deleteItem;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('اضافة فالمنتجات الشائعة' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.addCommon,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.addCommon = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.addCommon = !widget.currentUser.addCommon;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('حذف من المنتجات الشائعة' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.deleteCommon,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.deleteCommon = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.deleteCommon = !widget.currentUser.deleteCommon;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('رؤية النواقص' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.showShortage,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.showShortage = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.showShortage = !widget.currentUser.showShortage;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('رؤية تقرير الاجماليات' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.repTotal,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.repTotal = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.repTotal = !widget.currentUser.repTotal;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('رؤية تقرير سحب الاصناف' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.repItemsAmount,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.repItemsAmount = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.repItemsAmount = !widget.currentUser.repItemsAmount;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('رؤية تقرير ارباح الفواتير' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.repBillProfit,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.repBillProfit = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.repBillProfit = !widget.currentUser.repBillProfit;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('رؤية كل الفواتير' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.repAllBills,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.repAllBills = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.repAllBills = !widget.currentUser.repAllBills;
                          });
                        },
                      ),
                    ),
                  ),
                  Container(
                    color: Colors.white54,
                    margin: EdgeInsets.all(5),
                    child: MergeSemantics(
                      child: ListTile(
                        title: Text('رؤية فواتير المستخدم' , style: kMainTitleTextStyle16,),
                        trailing: Transform.scale(
                          scale: 0.8,
                          child: CupertinoSwitch(
                            activeColor: Color(kPrimaryColor),
                            trackColor: Color(kTextColor),

                            value: widget.currentUser.repOwnBills,
                            onChanged: (bool value) {
                              setState(() {
                                widget.currentUser.repOwnBills = value;
                              });
                            },
                          ),
                        ),
                        onTap: () {
                          setState(() {
                            widget.currentUser.repOwnBills = !widget.currentUser.repOwnBills;
                          });
                        },
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  _submitButton(),

                ],
              ),
            ),
          ),
        )
    );
  }
}
