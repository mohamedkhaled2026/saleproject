import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:sale_pro_elcaptain/models/bill.dart';
import 'package:sale_pro_elcaptain/models/bill_item.dart';
import 'package:sale_pro_elcaptain/models/global_data.dart';
import 'package:sale_pro_elcaptain/models/store_item.dart';
import 'package:sale_pro_elcaptain/services/assistant_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_add_storeItem_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_bill_service.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';

class ReturnProductScreen extends StatefulWidget {
  final Bill bill;

  const ReturnProductScreen({
    Key key,
    this.bill,
  }) : super(key: key);
  @override
  _ReturnProductScreenState createState() => _ReturnProductScreenState();
}

class _ReturnProductScreenState extends State<ReturnProductScreen> {
  AudioCache _audioCache;
  AssistantService _assistantService = AssistantService();
  final ItemScrollController itemScrollController = ItemScrollController();
  FirestoreBillService _firestoreBillService = FirestoreBillService();
  num oldTotalPrice = 0;
  num totalPrice = 0;
  num totalSellPrice = 0;
  List<BillItem> billItemList = List<BillItem>();
  List<BillItem> oldBillItemList = List<BillItem>();
  CollectionReference _storeCollection =
      FirebaseFirestore.instance.collection('store');
  bool firstTime = true;

  @override
  void initState() {
    //getCatId();
    super.initState();
    _audioCache = AudioCache(
        prefix: "sound/",
        fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
  }

  getToatalPrice() {
    num totalPriceForItem = 0;
    num totalSellPriceForItem = 0;
    for (BillItem billItem in billItemList) {
      totalPriceForItem += billItem.billItemPrice;
      totalSellPriceForItem += billItem.billItemSellPrice;
    }
    totalPrice = totalPriceForItem;
    totalSellPrice = totalSellPriceForItem;
    print(oldTotalPrice.toString()+'oldddddd');
    print(billItemList[0].billItemAmount.toString()+'newwwwwwwww');

  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 6,
          bottomOpacity: 3,
          toolbarHeight: 60,
          title: Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              ' مُرتجع ',
              style: kMainTitleTextStyle18,
            ),
          ),
          centerTitle: true,
          leading: Container(),
          actions: [
            backButton(),
          ],
          backgroundColor: Color(kPrimaryColor),
        ),
        body: Container(
          padding: EdgeInsets.all(10),
          child: FutureBuilder<Bill>(
            future: _firestoreBillService.getBillById(widget.bill.billId),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                oldTotalPrice = widget.bill.billTotalPrice;
                return Column(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5),
                      height: 50,
                      decoration: BoxDecoration(
                          color: Color(kTextColor),
                          borderRadius: BorderRadius.circular(10)),
                      margin: EdgeInsets.only(
                          right: 10, left: 10, bottom: 5, top: 5),
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            flex: 3,
                            child: Center(
                              child: Text(
                                'المُنتج',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'السعر',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'الكمية',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Center(
                              child: Text(
                                'مُرتجع',
                                style: kSubTitleTextStyle14.copyWith(
                                    color: Colors.white),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 400,
                      child: FutureBuilder<List<BillItem>>(
                        future: _firestoreBillService
                            .getBillDetails(widget.bill.billId.toString()),
                        builder: (context, snap) {
                          if (snap.hasData) {
                            if (firstTime) {
                              //billItemList = snap.data;
                              for (BillItem billItem in snap.data) {
                                billItemList.add(BillItem(
                                    billItemId: billItem.billItemId,
                                    billItemName: billItem.billItemName,
                                    billItemAmount: billItem.billItemAmount,
                                    billItemPrice: billItem.billItemPrice,
                                    billItemSellPrice:
                                        billItem.billItemSellPrice));
                              }
                              firstTime = false;
                            } else {

                            }
                            oldBillItemList = snap.data;
                            return ScrollablePositionedList.builder(
                              scrollDirection: Axis.vertical,
                              itemCount: snap.data.length,
                              itemScrollController: itemScrollController,
                              itemBuilder: (context, index) {
                                return Column(
                                  children: [
                                    Container(
                                      child: Directionality(
                                        textDirection: TextDirection.rtl,
                                        child: Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 5),
                                          height: 50,
                                          decoration: BoxDecoration(
                                              color: Colors.black12,
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          margin: EdgeInsets.only(
                                              right: 10,
                                              left: 10,
                                              bottom: 5,
                                              top: 5),
                                          child: Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 3,
                                                child: Center(
                                                  child: Text(
                                                    snap.data[index]
                                                        .billItemName,
                                                    style: kSubTitleTextStyle14,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    snap.data[index]
                                                        .billItemPrice
                                                        .toStringAsFixed(2),
                                                    style: kSubTitleTextStyle14,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 2,
                                                child: Center(
                                                  child: Text(
                                                    snap.data[index]
                                                        .billItemAmount
                                                        .toString(),
                                                    style: kSubTitleTextStyle14,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      //plus press
                                                      child: GestureDetector(
                                                        onTap: () async {
                                                          _audioCache.play(
                                                              'butttton.mp3');
                                                          setState(() {
                                                            if (billItemList[
                                                                        index]
                                                                    .billItemAmount <
                                                                snap.data[index]
                                                                    .billItemAmount) {
                                                              num itemPrice = billItemList[
                                                              index]
                                                                  .billItemPrice /
                                                                  billItemList[
                                                                  index]
                                                                      .billItemAmount;
                                                              num itemSellPrice = billItemList[
                                                              index]
                                                                  .billItemSellPrice /
                                                                  billItemList[
                                                                  index]
                                                                      .billItemAmount;
                                                              //1- edit item amount
                                                              billItemList[
                                                                      index]
                                                                  .billItemAmount++;

                                                              billItemList[
                                                                          index]
                                                                      .billItemPrice =
                                                                  itemPrice *
                                                                      billItemList[
                                                                              index]
                                                                          .billItemAmount;


                                                              billItemList[
                                                                          index]
                                                                      .billItemSellPrice =
                                                                  itemSellPrice *
                                                                      billItemList[
                                                                              index]
                                                                          .billItemAmount;
                                                            } else {
                                                              _assistantService
                                                                  .showToast(
                                                                      context,
                                                                      'لا يمكن زيادة المُرتجع عن عدد الفاتورة !',
                                                                      Color(
                                                                          kLightRedColor),16);
                                                            }
                                                          });
                                                        },
                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                kTextColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .plus,
                                                            size: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Center(
                                                        child: Text(
                                                          billItemList[index]
                                                              .billItemAmount
                                                              .toString(),
                                                          style:
                                                              kSubTitleTextStyle14,
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: GestureDetector(
                                                        //minus press
                                                        onTap: () async {
                                                          _audioCache.play(
                                                              'butttton.mp3');

                                                          if (billItemList[
                                                                      index]
                                                                  .billItemAmount >
                                                              0) {

                                                            //1- edit item amount
                                                            num itemPrice = billItemList[index].billItemPrice / billItemList[index].billItemAmount;
                                                            num itemSellPrice = billItemList[index].billItemSellPrice / billItemList[index].billItemAmount;
                                                            setState(() {
                                                              billItemList[
                                                                      index]
                                                                  .billItemAmount--;

                                                            });

                                                            billItemList[index].billItemPrice = itemPrice * billItemList[index].billItemAmount;
                                                            billItemList[index].billItemSellPrice = itemSellPrice * billItemList[index].billItemAmount;
                                                          } else {
                                                          }
                                                        },

                                                        child: Container(
                                                          width: 30,
                                                          height: 30,
                                                          padding:
                                                              EdgeInsets.all(3),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                kTextColor),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        5),
                                                          ),
                                                          child: Icon(
                                                            FontAwesomeIcons
                                                                .minus,
                                                            size: 15,
                                                            color: Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                flex: 2,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            return Container(
                              height: 40,
                              width: 40,
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                    Container(
                      child: InkWell(
                        child: Text(
                          'click me',
                          style: kMainTitleTextStyle28,
                        ),
                        onTap: () async {
                          _audioCache.play('butttton.mp3');
                          getToatalPrice();

                          if (billItemList.length != 0) {

                            Bill bill = Bill(
                                billId: widget.bill.billId,
                                billDate: Timestamp.fromDate(DateTime.now()),
                                billTotalPrice: totalPrice,
                                billTotalSellPrice: totalSellPrice,
                                billUser: (await GlobalData().getCurrentUserData()).userId
                            );

                            if (oldTotalPrice == totalPrice) {
                              _assistantService.showToast(context,
                                  'لم يحدث أى تغيير', Color(kLightRedColor),16);
                            } else {

                              //edit storeItem Amount
                              int counter = 0;
                              for (BillItem billItem in billItemList) {
                                num itemAmount = (await _storeCollection.doc(billItem.billItemId.toString()).get()).data()['item_amount'];
                                _storeCollection.doc(billItem.billItemId.toString())
                                .update({
                                  'item_amount': (itemAmount + (oldBillItemList[counter].billItemAmount - billItem.billItemAmount)),
                                });
                                _storeCollection.doc(billItem.billItemId.toString())
                                    .update({
                                  'last_update':
                                      Timestamp.fromDate(DateTime.now()),
                                });
                                counter++;
                              }

                              await _firestoreBillService.updateBill(bill, billItemList);

                              //remove billItem when billItemAmount equal zero
                              for(BillItem billItem in billItemList){
                                if(billItem.billItemAmount == 0){
                                  setState(() {
                                    _firestoreBillService.removeBillItem(widget.bill, billItem.billItemId);
                                    billItemList.remove(billItem);
                                  });
                                }
                              }
                              if(totalPrice == 0){
                                await _firestoreBillService.removeBill(widget.bill.billId);
                              }
                                _assistantService.showToast(
                                    context, 'تم', Colors.green,16);
                                setState(() {
                                  oldBillItemList.clear();
                                  totalPrice = 0;
                                });



                            }

                          }
                        },
                      ),
                    ),
                  ],
                );
              } else {
                return Container(
                  height: 40,
                  width: 40,
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}


