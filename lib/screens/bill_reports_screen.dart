import 'dart:io';

import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_pro_elcaptain/models/bill.dart';
import 'package:sale_pro_elcaptain/models/bill_item.dart';
import 'package:sale_pro_elcaptain/models/store_item.dart';
import 'package:sale_pro_elcaptain/models/unit.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/screens/return_product_screen.dart';
import 'package:sale_pro_elcaptain/screens/splash_screen.dart';
import 'package:sale_pro_elcaptain/services/assistant_service.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:sale_pro_elcaptain/services/firestore_bill_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class BillReportsScreen extends StatefulWidget {
  BuildContext homeContext;
  BillReportsScreen(this.homeContext);
  @override
  _BillReportsScreenState createState() => _BillReportsScreenState();
}

class _BillReportsScreenState extends State<BillReportsScreen> {
  AudioCache _audioCache;
  FirestoreBillService _firestoreBillService = FirestoreBillService();
  CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('users');
  var listen;
  Widget container = Center(
    child: Text(''),
  );
  DateTime startDate;
  DateTime endDate;
  int _selectedIndex = 3;
  SharedPreferences sharedPreferences;

  listenToAnyPrivChange() async {
    int counter = 0;
    SharedPreferences _sharedPreferences =
    await SharedPreferences.getInstance();
    int userId = _sharedPreferences.getInt('user_id');
    listen = _userCollection
        .doc(userId.toString())
        .snapshots(includeMetadataChanges: false)
        .listen((doc) async{
      if (doc.exists) {
        User user = User.fromJson(doc.data());
        counter++;
        if (counter > 1) {
          if(context != null) {
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
  
  Future<pw.Widget> allStoreItems()async{
    List<DocumentSnapshot> docs = (await FirebaseFirestore.instance.collection('store').orderBy('item_name',descending: false).limit(20).get()).docs;
    List<DocumentSnapshot> unitDocs = (await FirebaseFirestore.instance.collection('units').get()).docs;
    List<Unit> unitsList = List<Unit>();
    for(DocumentSnapshot doc in unitDocs){
      unitsList.add(Unit.fromJson(doc.data()));
    }
    List<pw.Widget> storeItemsList = List<pw.Widget>();
    int counter = 0;
    for(DocumentSnapshot doc in docs){
      StoreItem storeItem = StoreItem.fromJson(doc.data());
      counter++;
      storeItemsList.add(pw.Container(
        height: 40,
        decoration: pw.BoxDecoration(
            color: PdfColors.greenAccent,
            border: pw.Border(
              top: pw.BorderSide(
                  color: PdfColors.grey, width: .5),
            )),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: <pw.Widget>[
            pw.Expanded(
              child: pw.Container(
                height: 40,
                decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        top: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        left: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        right: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5))),
                child: pw.Text(
                  storeItem.storeItemBuyPrice.toString(),
                  style: pw.TextStyle(
                    color: PdfColors.lightBlueAccent,
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,),
                  textDirection: pw.TextDirection.rtl,
                  textAlign: pw.TextAlign.center,
                ),
              ),
              flex: 1,
            ),
            pw.Expanded(
              child: pw.Container(
                height: 40,
                decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        top: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        left: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        right: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5))),
                child: pw.Text(
                  storeItem.storeItemBuyPriceGomla.toString(),
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.lightBlueAccent),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              flex: 1,
            ),
            pw.Expanded(
              child: pw.Container(
                height: 40,
                decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        top: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        left: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        right: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5))),
                child: pw.Text(
                  unitsList[(storeItem.storeItemUnit == 0?3:storeItem.storeItemUnit) - 1].unitName,
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.lightBlueAccent),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              flex: 2,
            ),
            pw.Expanded(
              child: pw.Container(
                height: 40,
                decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        top: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        left: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        right: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5))),
                child: pw.Text(
                  storeItem.storeItemName.toString(),
                  style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.lightBlueAccent),
                  textAlign: pw.TextAlign.center,
                ),
              ),
              flex: 4,
            ),
            pw.Expanded(
              child: pw.Container(
                height: 40,
                decoration: pw.BoxDecoration(
                    border: pw.Border(
                        bottom: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        top: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        left: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5),
                        right: pw.BorderSide(
                            color: PdfColors.grey,
                            width: .5))),
                child: pw.Text(
                  counter.toString(),
                  style: pw.TextStyle(
                      fontSize: 10,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.lightBlueAccent),
                  textAlign: pw.TextAlign.center,
                  textDirection: pw.TextDirection.rtl,
                ),
              ),
              flex: 1,
            ),
          ],
        ),
      ),);
    }
    print(storeItemsList.length);
    return
      pw.Directionality(
        textDirection: pw.TextDirection.rtl,
        child: pw.Container(
            child: pw.ListView(
              children: storeItemsList,
            )
        ),
      );
  }


  initRep() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      if(sharedPreferences.getBool('rep_total') || sharedPreferences.getString('user_type') == 'admin') {
        container = FutureBuilder<Map<String, dynamic>>(
          future: _firestoreBillService.getStoreItemDetailsTotal(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              print(snapshot.data.length.toString()+'sssssssssssssssssss');
              return Container(
                  width: MediaQuery
                      .of(context)
                      .size
                      .width,
                  height: 300,
                  margin: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Color(kTextColor),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        bottom: 15,
                        left: 15,
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'images/profits-analytics.svg',
                              height: 80,
                              width: 80,
                              color: Color(kLightGreenColor),
                            ),
                            Text(
                              'إجمالى ربح البيع بالجملة',
                              style: kSubTitleTextStyle14.copyWith(
                                  color: Colors.white38),
                            ),
                            Text(
                              '${(snapshot.data['total_buy_price_gomla'] -
                                  snapshot.data['total_sell_price'])
                                  .toStringAsFixed(2)}  \$ ',
                              style: kMainTitleTextStyle28.copyWith(
                                  color: Color(kLightGreenColor)),
                            ),
                            Text(
                              'إجمالى ربح البيع بالقطاعى',
                              style: kSubTitleTextStyle14.copyWith(
                                  color: Colors.white38),
                            ),
                            Text(
                              '${(snapshot.data['total_buy_price'] -
                                  snapshot.data['total_sell_price'])
                                  .toStringAsFixed(2)}  \$ ',
                              style: kMainTitleTextStyle28.copyWith(
                                  color: Color(kLightGreenColor)),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 15,
                        right: 15,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              'عدد الأصناف ',
                              style: kSubTitleTextStyle14.copyWith(
                                  color: Colors.white38),
                            ),
                            Text(
                              '${snapshot.data['item_type_count']
                                  .toString()}  ',
                              style: kMainTitleTextStyle18.copyWith(
                                  color: Color(kPrimaryColor)),
                            ),
                            Text(
                              'عدد القطع الموجودة منها',
                              style: kSubTitleTextStyle14.copyWith(
                                  color: Colors.white38),
                            ),
                            Text(
                              '${snapshot.data['total_item_count']
                                  .toString()}  ',
                              style: kMainTitleTextStyle18.copyWith(
                                  color: Color(kPrimaryColor)),
                            ),
                            Text(
                              'سعر شراء البضاعة',
                              style: kSubTitleTextStyle14.copyWith(
                                  color: Colors.white38),
                            ),
                            Text(
                              '${snapshot.data['total_sell_price']
                                  .toStringAsFixed(2)}  ',
                              style: kMainTitleTextStyle18.copyWith(
                                  color: Color(kPrimaryColor)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ));
            } else {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
          },
        );
      }else{
        container = Center(child: Text('غير مسموح',style: TextStyle(fontSize: 26,color: Color(kPrimaryColor)),));
      }
    });
  }
  
  

  void _onItemTapped(int index) {
    setState(() {
      _audioCache.play('butttton.mp3');
      _selectedIndex = index;
    });
    print(index);
    if (index == 0) {
      setState(() {
        print(sharedPreferences.getBool('rep_all_bills').toString());
        if(sharedPreferences.getBool('rep_all_bills') || sharedPreferences.getBool('rep_own_bills') || sharedPreferences.getString('user_type') == 'admin') {
          if (startDate != null && endDate != null) {
            container = Container(
              child: Column(
                children: <Widget>[
                  FutureBuilder<List<Bill>>(
                    future: _firestoreBillService.getBills(startDate, endDate , sharedPreferences.getString('user_type'),sharedPreferences.getInt('user_id')),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        List<Widget> billWidgetList = List<Widget>();
                        List<Bill> billList = snapshot.data;
                        for (Bill bill in billList) {
                          Widget billWidget = Container(
                            child: Column(
                              children: <Widget>[
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width,
                                    height: 40,
                                    margin:
                                    EdgeInsets.only(right: 10, left: 10),
                                    padding: EdgeInsets.all(5),
                                    color: Color(kTextColor),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        InkWell(
                                          child: Icon(
                                            FontAwesomeIcons.cog,
                                            color: Color(kPrimaryColor),
                                            size: 25,
                                          ),
                                          onTap: () {
                                            _audioCache.play('butttton.mp3');
                                            showDialog(
                                                context: context,
                                                builder: (context) {
                                                  //alert Dialog
                                                  return Container(
                                                      child: Directionality(
                                                        textDirection:
                                                        TextDirection.rtl,
                                                        child: AlertDialog(
                                                          backgroundColor:
                                                          Color(kPrimaryColor),
                                                          title: Text(
                                                            'بيانات الفاتورة',
                                                            style:
                                                            kMainTitleTextStyle16,
                                                          ),
                                                          content: Container(
                                                            height: 230,
                                                            child: Column(
                                                              children: <Widget>[
                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      'رقم الفاتورة : ${bill.billId.toString()}',
                                                                      style:
                                                                      kSubTitleTextStyle14,
                                                                    ),
                                                                  ],
                                                                ),

                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      'المستخدم : ${bill.userName}',
                                                                      style:
                                                                      kSubTitleTextStyle14,
                                                                    ),
                                                                  ],
                                                                ),

                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      ' تاريخ الفاتورة :',
                                                                      style:
                                                                      kSubTitleTextStyle14,
                                                                    ),
                                                                  ],
                                                                ),

                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      bill.billDate
                                                                          .toDate()
                                                                          .toString(),
                                                                      style:
                                                                      kSubTitleTextStyle14,
                                                                    ),
                                                                  ],
                                                                ),

                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      'اجمالي الفاتورة : ${bill.billTotalPrice.toStringAsFixed(2)}',
                                                                      style:
                                                                      kSubTitleTextStyle14,
                                                                    ),
                                                                  ],
                                                                ),

                                                                Row(
                                                                  children: <
                                                                      Widget>[
                                                                    Text(
                                                                      'الربح : ${(bill.billTotalPrice - bill.billTotalSellPrice).toStringAsFixed(2)}',
                                                                      style:
                                                                      kSubTitleTextStyle14,
                                                                    ),
                                                                  ],
                                                                ),

                                                                SizedBox(
                                                                  height: 10,
                                                                ),

                                                                // edit button
                                                                InkWell(
                                                                  onTap: () {
                                                                    Navigator.push(context, MaterialPageRoute(builder:
                                                                        (context) => ReturnProductScreen(bill: bill,)));

                                                                  },
                                                                  child: Container(
                                                                      margin: EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                          10),
                                                                      width: MediaQuery.of(
                                                                          context)
                                                                          .size
                                                                          .width,
                                                                      padding: EdgeInsets
                                                                          .symmetric(
                                                                          vertical:
                                                                          15),
                                                                      alignment:
                                                                      Alignment
                                                                          .center,
                                                                      decoration:
                                                                      BoxDecoration(
                                                                        borderRadius:
                                                                        BorderRadius.all(
                                                                            Radius.circular(5)),
                                                                        boxShadow: <
                                                                            BoxShadow>[
                                                                          BoxShadow(
                                                                              color: Color(
                                                                                  kLightRedColor),
                                                                              offset: Offset(1,
                                                                                  1),
                                                                              blurRadius:
                                                                              5,
                                                                              spreadRadius:
                                                                              2)
                                                                        ],
                                                                        color: Color(
                                                                            kTextColor),
                                                                      ),
                                                                      child:
                                                                      Directionality(
                                                                        textDirection:
                                                                        TextDirection
                                                                            .rtl,
                                                                        child: Text(
                                                                          'مُرتجع ',
                                                                          style: TextStyle(
                                                                              fontSize:
                                                                              14,
                                                                              color: Color(
                                                                                  kLightGreenColor),
                                                                              fontFamily:
                                                                              'Cairo',
                                                                              fontWeight:
                                                                              FontWeight.w600),
                                                                        ),
                                                                      )),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ));
                                                });
                                          },
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          '  فاتورة رقم : ${bill.billId} ',
                                          style: kSubTitleTextStyle14.copyWith(
                                              color: Color(kPrimaryColor)),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // رأس جدول الفاتورة
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Container(
                                    margin:
                                    EdgeInsets.only(right: 10, left: 10),
                                    height: 40,
                                    color: Color(kTextColor),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    top: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    left: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    right: BorderSide(
                                                        color: Colors.white,
                                                        width: .5))),
                                            child: Text(
                                              'اسم الصنف',
                                              style:
                                              kSubTitleTextStyle12.copyWith(
                                                  color:
                                                  Color(kPrimaryColor)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    top: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    left: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    right: BorderSide(
                                                        color: Colors.white,
                                                        width: .5))),
                                            child: Text(
                                              'السعر',
                                              style:
                                              kSubTitleTextStyle12.copyWith(
                                                  color:
                                                  Color(kPrimaryColor)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 40,
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    top: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    left: BorderSide(
                                                        color: Colors.white,
                                                        width: .5),
                                                    right: BorderSide(
                                                        color: Colors.white,
                                                        width: .5))),
                                            child: Text(
                                              'الكمية',
                                              style:
                                              kSubTitleTextStyle12.copyWith(
                                                  color:
                                                  Color(kPrimaryColor)),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // جدول تفاصيل الفاتورة
                                FutureBuilder<List<BillItem>>(
                                  future: _firestoreBillService
                                      .getBillDetails(bill.billId.toString()),
                                  builder: (context, snap) {
                                    if (snap.hasData) {
                                      List<Widget> billItemWidgetList =
                                      List<Widget>();
                                      List<BillItem> billItemList = snap.data;
                                      for (BillItem billItem in billItemList) {
                                        Widget billItemWidget = Directionality(
                                            textDirection: TextDirection.rtl,
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  right: 10, left: 10),
                                              child: Row(
                                                children: <Widget>[
                                                  Expanded(
                                                    child: Container(
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              top: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              left: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              right: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5))),
                                                      child: Center(
                                                        child: Text(
                                                          billItem.billItemName,
                                                          style:
                                                          kSubTitleTextStyle14,
                                                          textAlign:
                                                          TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    flex: 2,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              top: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              left: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              right: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5))),
                                                      child: Center(
                                                        child: Text(
                                                          billItem.billItemPrice
                                                              .toStringAsFixed(
                                                              2),
                                                          style:
                                                          kSubTitleTextStyle14,
                                                          textAlign:
                                                          TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    flex: 2,
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      height: 50,
                                                      decoration: BoxDecoration(
                                                          border: Border(
                                                              bottom: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              top: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              left: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5),
                                                              right: BorderSide(
                                                                  color: Colors
                                                                      .grey,
                                                                  width: .5))),
                                                      child: Center(
                                                        child: Text(
                                                          billItem
                                                              .billItemAmount
                                                              .toString(),
                                                          style:
                                                          kSubTitleTextStyle14,
                                                          textAlign:
                                                          TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    flex: 2,
                                                  ),
                                                ],
                                              ),
                                            )
                                        );
                                        billItemWidgetList.add(billItemWidget);
                                      }

                                      return Column(
                                        children: billItemWidgetList,
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),

                                SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          );
                          billWidgetList.add(billWidget);
                        }
                        return Container(
                            child: Column(
                              children: billWidgetList,
                            ));
                      } else {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            AssistantService()
                .showToast(context, 'ادخل الفترة', Color(kTextColor),16);
          }
        }else{
          container = Center(child: Text('غير مسموح',style: TextStyle(fontSize: 26,color: Color(kPrimaryColor)),));
        }
      });
    } else if (index == 1) {
      setState(() {
        if(sharedPreferences.getBool('rep_items_amount') || sharedPreferences.getString('user_type') == 'admin') {
          if (startDate != null && endDate != null) {
            container = FutureBuilder<Map<String, dynamic>>(
              future: _firestoreBillService.getTotalBillPrice(
                  startDate, endDate),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                      width: MediaQuery
                          .of(context)
                          .size
                          .width,
                      height: 200,
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Color(kTextColor),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 30,
                            left: 30,
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'images/profits-bar-chart.svg',
                                  height: 80,
                                  width: 80,
                                  color: Color(kLightGreenColor),
                                ),
                                Text(
                                  'الربح',
                                  style: kSubTitleTextStyle14.copyWith(
                                      color: Colors.white38),
                                ),
                                Text(
                                  '${snapshot.data['profit'].toStringAsFixed(
                                      2)}  \$ ',
                                  style: kMainTitleTextStyle28.copyWith(
                                      color: Color(kLightGreenColor)),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 30,
                            right: 30,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Text(
                                  'اجمالي عدد الفواتير ',
                                  style: kSubTitleTextStyle14.copyWith(
                                      color: Colors.white38),
                                ),
                                Text(
                                  '${snapshot.data['bill_count'].toString()}  ',
                                  style: kMainTitleTextStyle18.copyWith(
                                      color: Color(kPrimaryColor)),
                                ),
                                Text(
                                  'اجمالي ثمن الفواتير',
                                  style: kSubTitleTextStyle14.copyWith(
                                      color: Colors.white38),
                                ),
                                Text(
                                  '${snapshot.data['bill_total_price']
                                      .toStringAsFixed(2)}  ',
                                  style: kMainTitleTextStyle18.copyWith(
                                      color: Color(kPrimaryColor)),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ));
                } else {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            );
          } else {
            AssistantService()
                .showToast(context, 'ادخل الفترة', Color(kTextColor),16);
          }
        }else{
          container = Center(child: Text('غير مسموح',style: TextStyle(fontSize: 26,color: Color(kPrimaryColor)),));
        }
      });
    } else if (index == 2) {
      setState(() {
        if(sharedPreferences.getBool('rep_items_amount') || sharedPreferences.getString('user_type') == 'admin') {
          if (startDate != null && endDate != null) {
            container = Container(
              child: Column(
                children: <Widget>[
                  // رأس جدول الفاتورة
                  Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      margin: EdgeInsets.only(right: 10, left: 10),
                      height: 40,
                      color: Color(kTextColor),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.white, width: .5),
                                      top: BorderSide(
                                          color: Colors.white, width: .5),
                                      left: BorderSide(
                                          color: Colors.white, width: .5),
                                      right: BorderSide(
                                          color: Colors.white, width: .5))),
                              child: Center(
                                child: Text(
                                  'اسم الصنف',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Color(kPrimaryColor)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.white, width: .5),
                                      top: BorderSide(
                                          color: Colors.white, width: .5),
                                      left: BorderSide(
                                          color: Colors.white, width: .5),
                                      right: BorderSide(
                                          color: Colors.white, width: .5))),
                              child: Center(
                                child: Text(
                                  'السعر',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Color(kPrimaryColor)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.white, width: .5),
                                      top: BorderSide(
                                          color: Colors.white, width: .5),
                                      left: BorderSide(
                                          color: Colors.white, width: .5),
                                      right: BorderSide(
                                          color: Colors.white, width: .5))),
                              child: Center(
                                child: Text(
                                  'الكمية',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Color(kPrimaryColor)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            flex: 2,
                          ),
                          Expanded(
                            child: Container(
                              height: 40,
                              decoration: BoxDecoration(
                                  border: Border(
                                      bottom: BorderSide(
                                          color: Colors.white, width: .5),
                                      top: BorderSide(
                                          color: Colors.white, width: .5),
                                      left: BorderSide(
                                          color: Colors.white, width: .5),
                                      right: BorderSide(
                                          color: Colors.white, width: .5))),
                              child: Center(
                                child: Text(
                                  'الربح',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Color(kPrimaryColor)),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            flex: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  FutureBuilder<List<BillItem>>(
                    future: _firestoreBillService.getBillItemsAmount(
                        startDate, endDate),
                    builder: (context, snap) {
                      if (snap.hasData) {
                        List<Widget> billItemWidgetList = List<Widget>();
                        List<BillItem> billItemList = snap.data;
                        for (BillItem billItem in billItemList) {
                          Widget billItemWidget = Directionality(
                              textDirection: TextDirection.rtl,
                              child: Column(
                                children: [
                                  // جدول تفاصيل الفاتورة
                                  Container(
                                    margin: EdgeInsets.only(
                                        right: 10, left: 10),
                                    child: Row(
                                      children: <Widget>[
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    top: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    left: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    right: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5))),
                                            child: Center(
                                              child: Text(
                                                billItem.billItemName,
                                                style: kSubTitleTextStyle14,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    top: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    left: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    right: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5))),
                                            child: Center(
                                              child: Text(
                                                billItem.billItemPrice
                                                    .toStringAsFixed(2),
                                                style: kSubTitleTextStyle14,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    top: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    left: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    right: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5))),
                                            child: Center(
                                              child: Text(
                                                billItem.billItemAmount
                                                    .toString(),
                                                style: kSubTitleTextStyle14,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                        Expanded(
                                          child: Container(
                                            height: 50,
                                            decoration: BoxDecoration(
                                                border: Border(
                                                    bottom: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    top: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    left: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5),
                                                    right: BorderSide(
                                                        color: Colors.grey,
                                                        width: .5))),
                                            child: Center(
                                              child: Text(
                                                '${(billItem.billItemPrice -
                                                    (billItem
                                                        .billItemSellPrice *
                                                        billItem
                                                            .billItemAmount))
                                                    .toStringAsFixed(2)}',
                                                style: kSubTitleTextStyle14,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                          flex: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ));
                          billItemWidgetList.add(billItemWidget);
                        }

                        return Column(
                          children: billItemWidgetList,
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            );
          } else {
            AssistantService()
                .showToast(context, 'ادخل الفترة', Color(kTextColor),16);
          }
        }else{
          container = Center(child: Text('غير مسموح',style: TextStyle(fontSize: 26,color: Color(kPrimaryColor)),));
        }
      });
    } else if (index == 3) {
      setState(() {
        if(sharedPreferences.getBool('rep_total') || sharedPreferences.getString('user_type') == 'admin') {
          container = FutureBuilder<Map<String, dynamic>>(
            future: _firestoreBillService.getStoreItemDetailsTotal(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                    width: MediaQuery
                        .of(context)
                        .size
                        .width,
                    height: 300,
                    margin: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Color(kTextColor),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 15,
                          left: 15,
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'images/profits-analytics.svg',
                                height: 80,
                                width: 80,
                                color: Color(kLightGreenColor),
                              ),
                              Text(
                                'إجمالى ربح البيع بالجملة',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white38),
                              ),
                              Text(
                                '${(snapshot.data['total_buy_price_gomla'] -
                                    snapshot.data['total_sell_price'])
                                    .toStringAsFixed(2)}  \$ ',
                                style: kMainTitleTextStyle28.copyWith(
                                    color: Color(kLightGreenColor)),
                              ),
                              Text(
                                'إجمالى ربح البيع بالقطاعى',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white38),
                              ),
                              Text(
                                '${(snapshot.data['total_buy_price'] -
                                    snapshot.data['total_sell_price'])
                                    .toStringAsFixed(2)}  \$ ',
                                style: kMainTitleTextStyle28.copyWith(
                                    color: Color(kLightGreenColor)),
                              ),
                            ],
                          ),
                        ),
                        Positioned(
                          top: 15,
                          right: 15,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text(
                                'عدد الأصناف ',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white38),
                              ),
                              Text(
                                '${snapshot.data['item_type_count']
                                    .toString()}  ',
                                style: kMainTitleTextStyle18.copyWith(
                                    color: Color(kPrimaryColor)),
                              ),
                              Text(
                                'عدد القطع الموجودة منها',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white38),
                              ),
                              Text(
                                '${snapshot.data['total_item_count']
                                    .toString()}  ',
                                style: kMainTitleTextStyle18.copyWith(
                                    color: Color(kPrimaryColor)),
                              ),
                              Text(
                                'سعر شراء البضاعة',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white38),
                              ),
                              Text(
                                '${snapshot.data['total_sell_price']
                                    .toStringAsFixed(2)}  ',
                                style: kMainTitleTextStyle18.copyWith(
                                    color: Color(kPrimaryColor)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ));
              } else {
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          );
        }else{
          container = Center(child: Text('غير مسموح',style: TextStyle(fontSize: 26,color: Color(kPrimaryColor)),));
        }
      });
    }
  }


  @override
  void initState() {
    initRep();
    _audioCache = AudioCache(
        prefix: "sound/",
        fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));

    listenToAnyPrivChange();
    super.initState();
  }

  Widget _submitStartDataButton() {
    return InkWell(
      onTap: () {
        _audioCache.play('butttton.mp3');
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(2020, 1, 1),
            maxTime: DateTime.now(),
            theme: DatePickerTheme(
                headerColor: Color(kPrimaryColor),
                backgroundColor: Color(kTextColor),
                itemStyle: TextStyle(
                    color: Color(kPrimaryColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                doneStyle: TextStyle(color: Color(kTextColor), fontSize: 16)),
            onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          setState(() {
            startDate = DateTime(date.year, date.month, date.day);
          });
          print('confirm $startDate');
        }, currentTime: DateTime.now(), locale: LocaleType.ar);
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            color: Color(kPrimaryColor),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              startDate != null
                  ? ' البحث من تاريخ : ${startDate.day} / ${startDate.month} / ${startDate.year}'
                  : 'البحث من تاريخ   --- ',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(kTextColor),
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600),
            ),
          )),
    );
  }

  Widget _submitEndDataButton() {
    return InkWell(
      onTap: () {
        _audioCache.play('butttton.mp3');
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(2020, 1, 1),
            maxTime: DateTime.now(),
            theme: DatePickerTheme(
              headerColor: Color(kPrimaryColor),
              backgroundColor: Color(kTextColor),
              itemStyle: TextStyle(
                  color: Color(kPrimaryColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              doneStyle: TextStyle(color: Color(kTextColor), fontSize: 16),
            ), onChanged: (date) {
          print('change $date in time zone ' +
              date.timeZoneOffset.inHours.toString());
        }, onConfirm: (date) {
          setState(() {
            endDate = DateTime(date.year, date.month, date.day);
          });
          print('confirm $endDate');
        }, currentTime: DateTime.now(), locale: LocaleType.ar);
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            color: Color(kPrimaryColor),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              endDate != null
                  ? '  إلى تاريخ :${endDate.day} / ${endDate.month} / ${endDate.year}'
                  : 'إلى تاريخ   --- ',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(kTextColor),
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600),
            ),
          )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 6,
        bottomOpacity: 3,
        toolbarHeight: 60,
        title: Container(
          margin: EdgeInsets.only(top: 10),
          child: Text(
            ' الفواتير والتقارير',
            style: kMainTitleTextStyle18,
          ),
        ),
        centerTitle: true,
        backgroundColor: Color(kPrimaryColor),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.only(top: 40),
          child: Column(
            children: [
              _submitStartDataButton(),
              SizedBox(
                height: 20,
              ),
              _submitEndDataButton(),
              SizedBox(
                height: 40,
              ),
              container,
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.fileInvoice),
            label: 'الفواتير',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chartPie),
            label: 'ربح الفواتير',
            backgroundColor: Color(kTextColor),
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.clipboardCheck),
            label: 'إجمالى الأصناف',
          ),
          BottomNavigationBarItem(
            icon: Icon(FontAwesomeIcons.chartLine),
            label: 'جرد مُختصر',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(kLightGreenColor),
        onTap: _onItemTapped,
        backgroundColor: Color(kTextColor),
        unselectedItemColor: Color(kPrimaryColor),
      ),
    );
  }
}
