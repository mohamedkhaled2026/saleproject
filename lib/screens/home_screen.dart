import 'dart:async';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sale_pro_elcaptain/models/suppliers.dart';
import 'package:sale_pro_elcaptain/models/bill.dart';
import 'package:sale_pro_elcaptain/models/bill_item.dart';
import 'package:sale_pro_elcaptain/models/category.dart';
import 'package:sale_pro_elcaptain/models/global_data.dart';
import 'package:sale_pro_elcaptain/models/store_item.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/models/waiting_item.dart';
import 'package:sale_pro_elcaptain/screens/signup_screen.dart';
import 'package:sale_pro_elcaptain/screens/splash_screen.dart';
import 'package:sale_pro_elcaptain/services/assistant_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_item_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_bill_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_supplier_service.dart';
import 'package:sale_pro_elcaptain/ui/drawe/my_drawer.dart';
import 'package:sale_pro_elcaptain/ui/drawe/rectCategoriesItem.dart';
import 'package:sale_pro_elcaptain/ui/drawe/store_item_list_card.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_store_item_screen.dart';

class HomeScreen extends StatefulWidget {
  final int categoryId;
  HomeScreen(this.categoryId);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  SharedPreferences sharedPreferences;
  var listen;
  User currentUser;
  FirestoreBillService _firestoreBillService = FirestoreBillService();
  FirestoreItemService _firestoreItemService = FirestoreItemService();
  AssistantService _assistantService = AssistantService();
  TextEditingController _searchController = TextEditingController();
  final ItemScrollController itemScrollController = ItemScrollController();
  final ItemScrollController itemScrollControllerItem = ItemScrollController();
  TextEditingController _amountController = new TextEditingController();
  List<Category> catList;
  bool firstTimeCat = true;
  List<StoreItem> storeItemsList;
  bool firstTimeItem = true;
  int catId;
  List<BillItem> billItemList = List<BillItem>();
  ScrollController _scrollController = ScrollController();
  num totalPrice = 0;
  num totalSellPrice = 0;
  bool waiting = false;
  int itemCounter = 0;
  List<String> catNameList;
  Widget container = Center();
  bool isProgress = false;
  List<StoreItem> searchResult;
  String searchWord = '';
  int itemSearchIndex = -1;
  AudioCache _audioCache;
  TextEditingController _supplierController;
  FireStoreSuppliersService _suppliersService = new FireStoreSuppliersService();
  bool _supplierIsExist = false;

  getTotalPrice() {
    num totalPriceForItem = 0;
    num totalSellPriceForItem = 0;
    for (BillItem billItem in billItemList) {
      totalPriceForItem += billItem.billItemPrice;
      totalSellPriceForItem += billItem.billItemSellPrice;
    }
    setState(() {
      totalPrice = totalPriceForItem;
      totalSellPrice = totalSellPriceForItem;
    });
  }

  initSharedPreferences() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  getCatId() async {
    catId = (await FirebaseFirestore.instance
            .collection('categories')
            .orderBy('cat_name')
            .get())
        .docs
        .first
        .data()['cat_id'];
  }

  @override
  void initState() {
    super.initState();
    _supplierController = TextEditingController();
    listenToAnyPrivChange();
    _audioCache = AudioCache(
        prefix: "sound/",
        fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
    initSharedPreferences();
    setState(() {
      catId = 0;
    });
    setState(() {
      catId = widget.categoryId;
    });
  }

  startBarcodeScanStream() async {
    int timer = 0;
    String barcode = '';
    Timer t = Timer.periodic(Duration(seconds:1), (t) {
      print(t.tick);
      timer = t.tick;
    });
    t.cancel();
    FlutterBarcodeScanner.getBarcodeStreamReceiver(
            "#ff6666", "Cancel", true, ScanMode.DEFAULT).distinct((p,n){
              print(p.toString()+'    -    '+n.toString());
              if(p.toString() == n.toString()){
                return true;
              }else{
                return false;
              }

    })
    //     .skipWhile((element) {
    //   if((timer % 3) == 0){
    //     print('take');
    //     return false;
    //   }else{
    //     print('not take');
    //     return true;
    //   }
    //
    // })6221031490491
        .listen((barcode) async {
      StoreItem storeItem = await _firestoreItemService.showProduct(barcode);
      if(storeItem != null){
      if (!storeItem.locked) {
        int count = 0;
        for (BillItem billItem in billItemList) {
          //check if billItem already Exist
          if (billItem.billItemId == storeItem.storeItemId) {
            num itemAmount = (await _firestoreBillService
                .getItemDataById(storeItem.storeItemId))
                .storeItemAmount;
            if (billItem.billItemAmount < itemAmount) {
              setState(() {
                billItem.billItemAmount++;
              });
              billItem.billItemPrice =
                  storeItem.storeItemBuyPrice * billItem.billItemAmount;
              billItem.billItemSellPrice =
                  storeItem.storeItemSellPrice * billItem.billItemAmount;
              Fluttertoast.showToast(
                  msg: barcode.toString() + storeItem.storeItemName,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              _audioCache.play('sound.mp3');
            } else {
              Fluttertoast.showToast(
                  msg: 'الكمية الموجودة غير كافية',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          } else {
            count++;
          }
        }
        num itemAmount =
            (await _firestoreBillService.getItemDataById(storeItem.storeItemId))
                .storeItemAmount;
        if (itemAmount != 0) {
          if (!waiting) {
            if (count == billItemList.length) {
              waiting = true;
              String billItemName = (await _firestoreBillService
                  .getItemDataById(storeItem.storeItemId))
                  .storeItemName;
              BillItem billItem = BillItem(
                billItemCounter: count,
                billItemId: storeItem.storeItemId,
                billItemName: billItemName,
                billItemAmount: 1,
                billItemPrice: storeItem.storeItemBuyPrice,
                billItemSellPrice: storeItem.storeItemSellPrice,
              );
              Fluttertoast.showToast(
                  msg: barcode.toString() + storeItem.storeItemName,
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              _audioCache.play('sound.mp3');
              setState(() {
                billItemList.add(billItem);
                _scrollController.animateTo(
                    _scrollController.position.maxScrollExtent + 100,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeOut);
              });
              waiting = false;
            }
          }
        } else {
          WaitingItem waitingItem = await _firestoreBillService
              .checkWaitingItemExist(storeItem.storeItemId);
          if (waitingItem == null) {
            Fluttertoast.showToast(
                msg: 'الكمية الموجودة غير كافية',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.TOP,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          } else {
            if (await _firestoreBillService.updateItem(waitingItem)) {
              Fluttertoast.showToast(
                  msg: 'تم الاضافة من المنتظر',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
              setState(() {});
            } else {
              Fluttertoast.showToast(
                  msg: 'error',
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                  fontSize: 16.0);
            }
          }
        }
        getTotalPrice();
      } else {
        Fluttertoast.showToast(
            msg: 'هذا المُنتج غير مٌتاح للوقت الحالى',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    }else{
      }
      print(barcode);
    }).onDone(() {
      t.cancel();
    });
  }

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

  bool isOpened = false;
  SpeedDial _speedDial() {
    return SpeedDial(
      marginEnd: 18,
      marginBottom: 20,
      icon: Icons.menu,
      activeIcon: Icons.clear,
      buttonSize: 56.0,
      visible: true,
      closeManually: false,
      curve: Curves.bounceIn,
      overlayColor: Colors.black,
      overlayOpacity: 0.5,
      onOpen: () => print('OPENING DIAL'),
      onClose: () => print('DIAL CLOSED'),
      tooltip: 'Speed Dial',
      heroTag: 'speed-dial-hero-tag',
      backgroundColor: Color(kPrimaryColor),
      foregroundColor: Colors.white,
      elevation: 8.0,
      shape: CircleBorder(),
      useRotationAnimation: true,
      children: [
        SpeedDialChild(
          child: Icon(
            FontAwesomeIcons.productHunt,
            size: 20,
            color: Colors.white,
          ),
          backgroundColor: Color(0xffff8800),
          label: 'إضافة مٌنتج',
          labelStyle: kSubTitleTextStyle14.copyWith(color: Colors.white),
          labelBackgroundColor: Color(0xffff8800),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return AddProductScreen();
            }));
          },
        ),
        SpeedDialChild(
          child: Icon(
            FontAwesomeIcons.userAlt,
            size: 20,
            color: Colors.white,
          ),
          backgroundColor: Color(0xffffa200),
          label: 'إضافة مُستخدم',
          labelStyle: kSubTitleTextStyle14.copyWith(color: Colors.white),
          labelBackgroundColor: Color(0xffffa200),
          onTap: () {
            _audioCache.play('butttton.mp3');
            if (sharedPreferences.getString('user_type') == 'admin') {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignUpPage()));
            } else {
              _assistantService.showToast(
                  context, 'غير مسموح', Color(kLightRedColor), 16);
            }
          },
          onLongPress: () => print('إضافة مُستخدم'),
        ),
        SpeedDialChild(
          child: Icon(
            FontAwesomeIcons.truck,
            size: 20,
            color: Colors.white,
          ),
          backgroundColor: Color(0xffffaa00),
          label: 'إضافة مُورد',
          labelStyle: kSubTitleTextStyle14.copyWith(color: Colors.white),
          labelBackgroundColor: Color(0xffffaa00),
          onTap: () {
            _audioCache.play('butttton.mp3');
            //add supplier مورد
            showDialog(
                context: context,
                builder: (context) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      child: AlertDialog(
                        title: Text(
                          'إضافة قسم',
                          style: kMainTitleTextStyle18.copyWith(
                              color: Colors.black),
                        ),
                        backgroundColor: Colors.white,
                        content: SingleChildScrollView(
                          child: Container(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              height: 50,
                              child: TextField(
                                decoration: kTextFieldDecoration.copyWith(
                                  labelText: 'أصف إسم القسم الجديد',
                                ),
                                controller: _supplierController,
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          InkWell(
                            onTap: () {
                              _audioCache.play('butttton.mp3');
                              _supplierController.text = '';
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(kTextColor),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 50,
                              height: 40,
                              child: Center(
                                child: Text(
                                  'إلغاء',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              _audioCache.play('butttton.mp3');
                              List<Suppliers> supplierList =
                                  await _suppliersService.getAllSuppliers();
                              for (Suppliers sup in supplierList) {
                                if (sup.supplierName ==
                                    _supplierController.text.toString()) {
                                  _supplierIsExist = true;
                                }
                              }
                              if (!_supplierIsExist) {
                                setState(() {
                                  _suppliersService
                                      .addSupplier(_supplierController.text);
                                  _assistantService.showToast(
                                      context,
                                      'تم إضافة القسم',
                                      Color(kLightGreenColor),
                                      16);
                                  _supplierController.text = '';
                                  Navigator.pop(context);
                                });
                              } else {
                                _assistantService.showToast(
                                    context,
                                    'المٌورد موجود بالفعل',
                                    Color(kLightRedColor),
                                    16);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(kTextColor),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 50,
                              height: 40,
                              child: Center(
                                child: Text(
                                  'تم',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
          onLongPress: () => print('إضافة مُورد'),
        ),
        SpeedDialChild(
          child: Icon(
            FontAwesomeIcons.wallet,
            size: 20,
            color: Colors.white,
          ),
          backgroundColor: Color(0xffffb700),
          label: 'إضافة مصروفات',
          labelStyle: kSubTitleTextStyle14.copyWith(color: Colors.white),
          labelBackgroundColor: Color(0xffffb700),
          onTap: () {
            _audioCache.play('butttton.mp3');
            //add petty cash المصروفات
            showDialog(
                context: context,
                builder: (context) {
                  return Directionality(
                    textDirection: TextDirection.rtl,
                    child: Container(
                      child: AlertDialog(
                        title: Text(
                          'إضافة قسم',
                          style: kMainTitleTextStyle18.copyWith(
                              color: Colors.black),
                        ),
                        backgroundColor: Colors.white,
                        content: SingleChildScrollView(
                          child: Container(
                            child: Container(
                              margin: EdgeInsets.symmetric(horizontal: 10),
                              height: 50,
                              child: TextField(
                                decoration: kTextFieldDecoration.copyWith(
                                  labelText: 'أصف إسم القسم الجديد',
                                ),
                                controller: _supplierController,
                              ),
                            ),
                          ),
                        ),
                        actions: [
                          InkWell(
                            onTap: () {
                              _audioCache.play('butttton.mp3');
                              _supplierController.text = '';
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(kTextColor),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 50,
                              height: 40,
                              child: Center(
                                child: Text(
                                  'إلغاء',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              _audioCache.play('butttton.mp3');
                              List<Suppliers> supplierList =
                                  await _suppliersService.getAllSuppliers();
                              for (Suppliers sup in supplierList) {
                                if (sup.supplierName ==
                                    _supplierController.text.toString()) {
                                  _supplierIsExist = true;
                                }
                              }
                              if (!_supplierIsExist) {
                                setState(() {
                                  _suppliersService
                                      .addSupplier(_supplierController.text);
                                  _assistantService.showToast(
                                      context,
                                      'تم إضافة القسم',
                                      Color(kLightGreenColor),
                                      16);
                                  _supplierController.text = '';
                                  Navigator.pop(context);
                                });
                              } else {
                                _assistantService.showToast(
                                    context,
                                    'المٌورد موجود بالفعل',
                                    Color(kLightRedColor),
                                    16);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(kTextColor),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              width: 50,
                              height: 40,
                              child: Center(
                                child: Text(
                                  'تم',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                });
          },
          onLongPress: () => print('إضافة مصروفات'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        drawer: Directionality(
          textDirection: TextDirection.rtl,
          child: MyDrawer(),
        ),
        appBar: AppBar(
          brightness: Brightness.dark,
          elevation: 6,
          toolbarHeight: 70,
          backgroundColor: Color(kPrimaryColor),
          title: Container(
              child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                //Search Widget
                Container(
                    width: double.infinity,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Directionality(
                        textDirection: TextDirection.rtl,
                        child: Padding(
                          padding: EdgeInsets.only(right: 10, left: 5),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      itemSearchIndex = -1;
                                      _searchController.clear();
                                      searchResult.clear();
                                    });
                                  },
                                  icon: Icon(
                                    Icons.clear,
                                    size: 22,
                                    color: Color(kTextColor),
                                  ),
                                ),
                              ),
                              Expanded(
                                  flex: 5,
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      fillColor: Colors.white,
                                      filled: true,
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                      ),
                                      contentPadding: EdgeInsets.only(
                                        bottom: 10.0,
                                      ),
                                      hintText: 'إبحث عن المُنتج',
                                      hintStyle: TextStyle(
                                        color: Color(kTextColor),
                                        fontSize: 12,
                                        fontFamily: 'Cairo',
                                      ),
                                    ),
                                  )),
                              Expanded(
                                  flex: 2,
                                  child: Text(
                                    (searchResult == null
                                            ? '0' + '/'
                                            : searchResult.length.toString() +
                                                '/') +
                                        (itemSearchIndex == -1
                                            ? '0'
                                            : (itemSearchIndex + 1).toString()),
                                    style: TextStyle(
                                        color: Color(kTextColor), fontSize: 12),
                                  )),
                              Expanded(
                                flex: 1,
                                child: IconButton(
                                  onPressed: () async {
                                    if (_searchController.text
                                        .trim()
                                        .isNotEmpty) {
                                      setState(() {
                                        isProgress = true;
                                      });
                                      _audioCache.play('butttton.mp3');
                                      if (searchWord !=
                                          _searchController.text) {
                                        itemSearchIndex = -1;
                                        //searchResult.clear();
                                      }
                                      if (itemSearchIndex == -1) {
                                        searchWord = _searchController.text;
                                        searchResult =
                                            await _firestoreBillService
                                                .itemSearch(searchWord);
                                        //itemSearchIndex = 0;
                                      }

                                      if (searchResult.length == 0) {
                                        _assistantService.showToast(
                                            context,
                                            'منتج غير معروف',
                                            Color(kLightRedColor),
                                            16);
                                        setState(() {
                                          isProgress = false;
                                        });
                                      } else {
                                        if (itemSearchIndex <
                                            (searchResult.length - 1)) {
                                          itemSearchIndex++;
                                        } else {
                                          itemSearchIndex = 0;
                                        }

                                        int itemId =
                                            searchResult[itemSearchIndex]
                                                .storeItemId;
                                        int catIdd =
                                            searchResult[itemSearchIndex]
                                                .storeItemCat;
                                        int counter = 0;
                                        int counter1 = 0;
                                        int catIndex = 0;
                                        for (Category catt in catList) {
                                          if (catt.catId == catIdd) {
                                            catIndex = counter;
                                            break;
                                          }
                                          counter++;
                                        }

                                        setState(() {
                                          catId = catIdd;
                                          catList[catIndex].isSelected = true;
                                        });
                                        Timer(Duration(seconds: 2), () {
                                          counter1 = 0;
                                          int itemIndex = 0;
                                          for (StoreItem store
                                              in storeItemsList) {
                                            if (store.storeItemId == itemId) {
                                              itemIndex = counter1;
                                              break;
                                            }
                                            counter1++;
                                          }
                                          setState(() {
                                            storeItemsList[itemIndex]
                                                .isSelected = true;
                                          });

                                          itemScrollControllerItem.scrollTo(
                                              index: itemIndex,
                                              duration: Duration(seconds: 1),
                                              curve: Curves.easeInOutCubic);
                                          setState(() {
                                            isProgress = false;
                                          });
                                        });
                                      }
                                    } else {
                                      _assistantService.showToast(
                                          context,
                                          'ادخل اسم المنتج للبحث',
                                          Color(kLightRedColor),
                                          16);
                                    }
                                  },
                                  icon: Icon(
                                    Icons.search,
                                    size: 25,
                                    color: Color(kTextColor),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ))),
              ],
            ),
          )),
          centerTitle: true,
          leading: Builder(
            // Create an inner BuildContext so that the onPressed methods
            // can refer to the Scaffold with Scaffold.of().
            builder: (BuildContext context) {
              return IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                color: Color(kTextColor),
                icon: Icon(Icons.menu),
                iconSize: 30,
              );
            },
          ),
          actions: [
            IconButton(
              onPressed: () {
                startBarcodeScanStream();
              },
              icon: Icon(
                Icons.qr_code,
                size: 25,
                color: Color(kTextColor),
              ),
            ),
          ],
        ),
        floatingActionButton: _speedDial(),
        body: ModalProgressHUD(
          inAsyncCall: isProgress,
          child: SingleChildScrollView(
            child: Container(
              margin: EdgeInsets.all(5),
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Text(
                      'الأقسام',
                      style: kMainTitleTextStyle18,
                    ),
                  ),
                  //كونتينر الأقسام
                  Container(
                    height: 70,
                    child: FutureBuilder<List<Category>>(
                      future: _firestoreBillService.getCategories(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          if (firstTimeCat) {
                            catList = snapshot.data;
                            catList[0].isSelected = true;
                            firstTimeCat = false;
                          }
                          return ScrollablePositionedList.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: snapshot.data.length,
                            itemScrollController: itemScrollController,
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  _audioCache.play('butttton.mp3');
                                  setState(() {
                                    catId = catList[index].catId;
                                    for (Category cat in catList) {
                                      cat.isSelected = false;
                                    }
                                    catList[index].isSelected = true;
                                  });
                                },
                                child: RectCategoryItem(
                                  bgColor: catList[index].isSelected
                                      ? Colors.greenAccent
                                      : Color(kPrimaryColor),
                                  categoryName: catList[index].catName,
                                ),
                              );
                            },
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  ////////////////////////////////////////////////////////////////////
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Text(
                      ' المُنتجات',
                      style: kMainTitleTextStyle18,
                    ),
                  ),
                  // كونتينر المُنتجات
                  Container(
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.only(top: 8),
                    height: (MediaQuery.of(context).size.height * .35),
                    child: FutureBuilder<List<StoreItem>>(
                      future: _firestoreBillService.getStoreItemsForCat(catId),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          storeItemsList = snapshot.data;

                          return ScrollablePositionedList.builder(
                            scrollDirection: Axis.vertical,
                            itemCount: storeItemsList.length,
                            itemScrollController: itemScrollControllerItem,
                            itemBuilder: (context, index) {
                              return StoreItemListCard(
                                onLongPress: () async {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        //alert Dialog
                                        return Directionality(
                                          textDirection: TextDirection.rtl,
                                          child: Container(
                                            child: AlertDialog(
                                                backgroundColor: Colors.white,
                                                title: Text(
                                                  'بيانات المُنتج',
                                                  style: kMainTitleTextStyle18
                                                      .copyWith(
                                                          color: Colors.black),
                                                ),
                                                content: SingleChildScrollView(
                                                  child: Container(
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height /
                                                            3.5,
                                                    margin: EdgeInsets.only(
                                                        right: 20),
                                                    padding: EdgeInsets.all(10),
                                                    child: Column(
                                                      //mainAxisAlignment: MainAxisAlignment.center,
                                                      //crossAxisAlignment: CrossAxisAlignment.center,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              'حالة المُنتج : ',
                                                              style: kMainTitleTextStyle18
                                                                  .copyWith(
                                                                      color: Colors
                                                                          .black),
                                                            ),
                                                            storeItemsList[
                                                                        index]
                                                                    .locked
                                                                ? Text(
                                                                    'غير مُتاح',
                                                                    style: kMainTitleTextStyle18
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.redAccent),
                                                                  )
                                                                : Text(
                                                                    'مُتاح',
                                                                    style: kMainTitleTextStyle18
                                                                        .copyWith(
                                                                            color:
                                                                                Colors.green),
                                                                  ),
                                                          ],
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        InkWell(
                                                          onTap: () async {
                                                            _audioCache.play(
                                                                'butttton.mp3');
                                                            if (catId != 0) {
                                                              if (sharedPreferences
                                                                      .getBool(
                                                                          'add_common') ||
                                                                  (sharedPreferences
                                                                          .getString(
                                                                              'user_type') ==
                                                                      'admin')) {
                                                                bool isAdd = await _firestoreBillService
                                                                    .addToCommonProducts(snapshot
                                                                        .data[
                                                                            index]
                                                                        .storeItemId);
                                                                if (isAdd) {
                                                                  _assistantService.showToast(
                                                                      context,
                                                                      'تم اضافة المنتج',
                                                                      Colors
                                                                          .green,
                                                                      16);
                                                                  Navigator.pop(
                                                                      context);
                                                                } else {
                                                                  _assistantService
                                                                      .showToast(
                                                                          context,
                                                                          'المنتج مضاف مسبقا',
                                                                          Colors
                                                                              .red,
                                                                          16);
                                                                }
                                                              } else {
                                                                _assistantService
                                                                    .showToast(
                                                                        context,
                                                                        'غير مسموح',
                                                                        Color(
                                                                            kLightRedColor),
                                                                        16);
                                                              }
                                                            } else {
                                                              if (sharedPreferences
                                                                      .getBool(
                                                                          'delete_common') ||
                                                                  (sharedPreferences
                                                                          .getString(
                                                                              'user_type') ==
                                                                      'admin')) {
                                                                bool isDelete =
                                                                    await _firestoreBillService.deleteFromCommonProducts(snapshot
                                                                        .data[
                                                                            index]
                                                                        .storeItemId);
                                                                if (isDelete) {
                                                                  _assistantService.showToast(
                                                                      context,
                                                                      'تم الحذف',
                                                                      Colors
                                                                          .green,
                                                                      16);
                                                                  setState(() {
                                                                    catId = 0;
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                } else {
                                                                  _assistantService
                                                                      .showToast(
                                                                          context,
                                                                          'حدث خطأ',
                                                                          Colors
                                                                              .red,
                                                                          16);
                                                                }
                                                              } else {
                                                                _assistantService
                                                                    .showToast(
                                                                        context,
                                                                        'غير مسموح',
                                                                        Color(
                                                                            kLightRedColor),
                                                                        16);
                                                              }
                                                            }
                                                          },
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        15),
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              5)),
                                                              color: Color(
                                                                  kPrimaryColor),
                                                            ),
                                                            child: Text(
                                                              catId == 0
                                                                  ? 'حذف من المنتجات الشائعة'
                                                                  : 'إضافة إلى المنتجات الشائعة',
                                                              style:
                                                                  kSubTitleTextStyle14,
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          height: 20,
                                                        ),
                                                        InkWell(
                                                          //One storeItem report
                                                          onTap: () async {
                                                            _audioCache.play(
                                                                'butttton.mp3');
                                                            Navigator.pop(
                                                                context);
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  //alert Dialog
                                                                  return Directionality(
                                                                    textDirection:
                                                                        TextDirection
                                                                            .rtl,
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          AlertDialog(
                                                                        title:
                                                                            Text(
                                                                          'تقرير المٌنتج :',
                                                                          style:
                                                                              kMainTitleTextStyle18.copyWith(color: Colors.black),
                                                                        ),
                                                                        backgroundColor:
                                                                            Colors.white,
                                                                        content:
                                                                            SingleChildScrollView(
                                                                          child:
                                                                              FutureBuilder<Map<String, dynamic>>(
                                                                            future:
                                                                                _firestoreBillService.getOneStoreItemReport(storeItemsList[index].storeItemId),
                                                                            builder:
                                                                                (context, snapshot) {
                                                                              if (snapshot.hasData) {
                                                                                return Container(
                                                                                  child: Table(
                                                                                    border: TableBorder.all(),
                                                                                    columnWidths: {
                                                                                      2: FractionColumnWidth(.15)
                                                                                    },
                                                                                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                                                                                    children: [
                                                                                      TableRow(children: [
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: 'إسم المُنتج  :',
                                                                                              style: kSubTitleTextStyle14.copyWith(color: Colors.black),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: storeItemsList[index].storeItemName.toString(),
                                                                                              style: kSubTitleTextStyle12.copyWith(color: Color(kTextColor), fontWeight: FontWeight.bold),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ]),
                                                                                      TableRow(children: [
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: 'عدد الفواتير :',
                                                                                              style: kSubTitleTextStyle14.copyWith(color: Colors.black),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: snapshot.data['bill_count'].toString(),
                                                                                              style: kSubTitleTextStyle14,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ]),
                                                                                      TableRow(children: [
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: 'الكمية التى تم بيعها :',
                                                                                              style: kSubTitleTextStyle14.copyWith(color: Colors.black),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: snapshot.data['total_sold_out_price'].toString(),
                                                                                              style: kSubTitleTextStyle14.copyWith(color: Color(kTextColor)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ]),
                                                                                      TableRow(children: [
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: 'الكمية المُتبقة :',
                                                                                              style: kSubTitleTextStyle14.copyWith(color: Colors.black),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(text: snapshot.data['total_rest_price'].toString(), style: kSubTitleTextStyle14),
                                                                                          ),
                                                                                        ),
                                                                                      ]),
                                                                                      TableRow(children: [
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: 'الربح :',
                                                                                              style: kSubTitleTextStyle14.copyWith(color: Colors.black),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                        Container(
                                                                                          margin: EdgeInsets.only(right: 5),
                                                                                          child: RichText(
                                                                                            text: TextSpan(
                                                                                              text: snapshot.data['profit'].toString(),
                                                                                              style: kSubTitleTextStyle14.copyWith(color: Color(kTextColor)),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ]),
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              } else {
                                                                                return Center(
                                                                                  child: CircularProgressIndicator(),
                                                                                );
                                                                              }
                                                                            },
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  );
                                                                });
                                                          },
                                                          child: Container(
                                                            width:
                                                                MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width,
                                                            padding: EdgeInsets
                                                                .symmetric(
                                                                    vertical:
                                                                        15),
                                                            alignment: Alignment
                                                                .center,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .all(Radius
                                                                          .circular(
                                                                              5)),
                                                              color: Color(
                                                                  kPrimaryColor),
                                                            ),
                                                            child: Text(
                                                              'تقرير المُنتج',
                                                              style:
                                                                  kSubTitleTextStyle14,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )),
                                          ),
                                        );
                                      });
                                },
                                plusPress: () async {
                                  StoreItem storeItem = storeItemsList[index];
                                  if (!storeItem.locked) {
                                    int count = 0;
                                    for (BillItem billItem in billItemList) {
                                      //check if billItem already Exist
                                      if (billItem.billItemId ==
                                          storeItem.storeItemId) {
                                        num itemAmount =
                                            (await _firestoreBillService
                                                    .getItemDataById(
                                                        storeItem.storeItemId))
                                                .storeItemAmount;
                                        if (billItem.billItemAmount <
                                            itemAmount) {
                                          setState(() {
                                            billItem.billItemAmount++;
                                          });
                                        } else {
                                          _assistantService.showToast(
                                              context,
                                              'الكمية الموجودة غير كافية',
                                              Colors.red,
                                              16);
                                        }
                                        billItem.billItemPrice =
                                            storeItem.storeItemBuyPrice *
                                                billItem.billItemAmount;
                                        billItem.billItemSellPrice =
                                            storeItem.storeItemSellPrice *
                                                billItem.billItemAmount;
                                      } else {
                                        count++;
                                      }
                                    }
                                    num itemAmount =
                                        (await _firestoreBillService
                                                .getItemDataById(
                                                    storeItem.storeItemId))
                                            .storeItemAmount;
                                    if (itemAmount != 0) {
                                      if (!waiting) {
                                        if (count == billItemList.length) {
                                          waiting = true;
                                          String billItemName =
                                              (await _firestoreBillService
                                                      .getItemDataById(storeItem
                                                          .storeItemId))
                                                  .storeItemName;
                                          BillItem billItem = BillItem(
                                            billItemCounter: count,
                                            billItemId: storeItem.storeItemId,
                                            billItemName: billItemName,
                                            billItemAmount: 1,
                                            billItemPrice:
                                                storeItem.storeItemBuyPrice,
                                            billItemSellPrice:
                                                storeItem.storeItemSellPrice,
                                          );
                                          setState(() {
                                            billItemList.add(billItem);
                                            _scrollController.animateTo(
                                                _scrollController.position
                                                        .maxScrollExtent +
                                                    100,
                                                duration:
                                                    Duration(milliseconds: 500),
                                                curve: Curves.easeOut);
                                          });
                                          waiting = false;
                                        }
                                      }
                                    } else {
                                      WaitingItem waitingItem =
                                          await _firestoreBillService
                                              .checkWaitingItemExist(
                                                  storeItem.storeItemId);
                                      if (waitingItem == null) {
                                        _assistantService.showToast(
                                            context,
                                            'الكمية الموجودة غير كافية',
                                            Colors.red,
                                            16);
                                      } else {
                                        if (await _firestoreBillService
                                            .updateItem(waitingItem)) {
                                          _assistantService.showToast(
                                              context,
                                              'تم الاضافة من المنتظر',
                                              Colors.greenAccent,
                                              16);
                                          setState(() {});
                                        } else {
                                          _assistantService.showToast(
                                              context, 'error', Colors.red, 16);
                                        }
                                      }
                                    }
                                    getTotalPrice();
                                  } else {
                                    _assistantService.showToast(
                                        context,
                                        'هذا المُنتج غير مٌتاح للوقت الحالى',
                                        Color(kLightRedColor),
                                        16);
                                  }
                                },
                                pricePress: () async {
                                  StoreItem storeItem = storeItemsList[index];
                                  for (BillItem billItem in billItemList) {
                                    if (billItem.billItemId ==
                                        storeItem.storeItemId) {
                                      setState(() {
                                        billItem.billItemPrice =
                                            storeItem.storeItemBuyPrice *
                                                billItem.billItemAmount;
                                      });
                                      billItem.billItemSellPrice =
                                          storeItem.storeItemSellPrice *
                                              billItem.billItemAmount;
                                    }
                                  }
                                  getTotalPrice();
                                },
                                gomlaPress: () async {
                                  StoreItem storeItem = storeItemsList[index];
                                  for (BillItem billItem in billItemList) {
                                    if (billItem.billItemId ==
                                        storeItem.storeItemId) {
                                      setState(() {
                                        billItem.billItemPrice =
                                            storeItem.storeItemBuyPriceGomla *
                                                billItem.billItemAmount;
                                      });
                                      billItem.billItemSellPrice =
                                          storeItem.storeItemSellPrice *
                                              billItem.billItemAmount;
                                    }
                                  }
                                  getTotalPrice();
                                },
                                bgColor: storeItemsList[index].locked
                                    ? Color(kLightRedColor)
                                    : storeItemsList[index].isSelected
                                        ? Color(kLightGreenColor)
                                        : Color(kPrimaryColor),
                                name: storeItemsList[index].storeItemName,
                                count: storeItemsList[index]
                                    .storeItemAmount
                                    .toString(),
                                price: (storeItemsList[index]
                                        .storeItemBuyPrice
                                        .toString()) +
                                    ' جـ ',
                                priceGomla: (storeItemsList[index]
                                        .storeItemBuyPriceGomla
                                        .toString()) +
                                    ' جـ ',
                                updatePress: () async {
                                  if (sharedPreferences
                                          .getBool('update_item') ||
                                      (sharedPreferences
                                              .getString('user_type') ==
                                          'admin')) {
                                    StoreItem oldStoreItem =
                                        storeItemsList[index];
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                      return AddProductScreen(
                                        storeItem: oldStoreItem,
                                        homeContext: context,
                                      );
                                    }));
                                  } else {
                                    _assistantService.showToast(context,
                                        'غير مسموح', Color(kLightRedColor), 16);
                                  }
                                },
                              );
                            },
                          );
                        } else {
                          return Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
                  ////////////////////////////////////////////////////////////////////
                  Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Text(
                      ' السلة',
                      style: kMainTitleTextStyle18,
                    ),
                  ),
                  //كونتينر المشتريات
                  Container(
                    height: (MediaQuery.of(context).size.height * .3),
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: billItemList.length,
                      controller: _scrollController,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Color(kTextColor),
                              borderRadius: BorderRadius.circular(3),
                            ),
                            margin: EdgeInsets.only(right: 8, left: 8, top: 8),
                            padding: EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                        margin: EdgeInsets.all(3),
                                        width: 30,
                                        height: 30,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          color: Color(kPrimaryColor),
                                        ),
                                        child: Center(
                                          child: Text(
                                            (billItemList[index]
                                                        .billItemCounter +
                                                    1)
                                                .toString(),
                                            style: kMainTitleTextStyle16,
                                          ),
                                        ))),
                                Expanded(
                                  flex: 6,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            child: Text(
                                              billItemList[index].billItemName,
                                              textAlign: TextAlign.center,
                                              style:
                                                  kSubTitleTextStyle14.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          Color(kPrimaryColor)),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            child: Text(
                                              ' السعر  ${billItemList[index].billItemPrice.toString()} جـ ',
                                              textAlign: TextAlign.center,
                                              style:
                                                  kSubTitleTextStyle12.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                            ),
                                          ),
                                          Container(
                                              child: InkWell(
                                            onTap: () {
                                              _audioCache.play('butttton.mp3');
                                              showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    //amount alert Dialog
                                                    return Directionality(
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      child: Container(
                                                        child: AlertDialog(
                                                          backgroundColor:
                                                              Color(kTextColor),
                                                          title: Text(
                                                            'أضف كمية',
                                                            style: kMainTitleTextStyle18
                                                                .copyWith(
                                                                    color: Color(
                                                                        kLightGreenColor)),
                                                          ),
                                                          content:
                                                              SingleChildScrollView(
                                                            child: Container(
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      right:
                                                                          10),
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(10),
                                                              child: Column(
                                                                children: [
                                                                  Directionality(
                                                                    textDirection:
                                                                        TextDirection
                                                                            .rtl,
                                                                    child:
                                                                        Container(
                                                                      child:
                                                                          Column(
                                                                        crossAxisAlignment:
                                                                            CrossAxisAlignment.start,
                                                                        children: <
                                                                            Widget>[
                                                                          Text(
                                                                            ' الكمية :',
                                                                            style: TextStyle(
                                                                                fontWeight: FontWeight.bold,
                                                                                fontSize: 14,
                                                                                color: Color(kPrimaryColor),
                                                                                fontFamily: 'Cairo'),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                50,
                                                                            child:
                                                                                TextField(
                                                                              controller: _amountController,
                                                                              decoration: InputDecoration(
                                                                                border: OutlineInputBorder(
                                                                                  borderSide: BorderSide(
                                                                                    width: 1,
                                                                                    color: Color(kLightGreenColor),
                                                                                    style: BorderStyle.solid,
                                                                                  ),
                                                                                ),
                                                                                fillColor: Colors.white,
                                                                                filled: true,
                                                                                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(5.0)), borderSide: BorderSide(color: Color(kPrimaryColor))),
                                                                                contentPadding: EdgeInsets.only(bottom: 10.0, left: 10.0, right: 10.0),
                                                                                // labelText: widget.title,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  SizedBox(
                                                                    height: 20,
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                          actions: [
                                                            Container(
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: Colors
                                                                    .white,
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            5),
                                                              ),
                                                              width: 50,
                                                              height: 40,
                                                              child: Center(
                                                                child: Text(
                                                                  'إلغاء',
                                                                  style:
                                                                      kSubTitleTextStyle12,
                                                                ),
                                                              ),
                                                            ),
                                                            InkWell(
                                                              onTap: () async {
                                                                _audioCache.play(
                                                                    'butttton.mp3');
                                                                StoreItem
                                                                    storeItem =
                                                                    await _firestoreBillService
                                                                        .getStoreItemById(
                                                                            billItemList[index].billItemId);
                                                                int itemAmount =
                                                                    (await _firestoreBillService
                                                                            .getItemDataById(storeItem.storeItemId))
                                                                        .storeItemAmount;
                                                                if (double.parse(
                                                                        _amountController
                                                                            .text) <
                                                                    itemAmount) {
                                                                  setState(() {
                                                                    billItemList[index]
                                                                            .billItemAmount =
                                                                        double.parse(
                                                                            _amountController.text);
                                                                    billItemList[
                                                                            index]
                                                                        .billItemPrice = storeItem
                                                                            .storeItemBuyPrice *
                                                                        billItemList[index]
                                                                            .billItemAmount;
                                                                    billItemList[
                                                                            index]
                                                                        .billItemSellPrice = storeItem
                                                                            .storeItemSellPrice *
                                                                        billItemList[index]
                                                                            .billItemAmount;
                                                                    getTotalPrice();
                                                                    _amountController
                                                                        .text = '';
                                                                  });
                                                                  Navigator.pop(
                                                                      context);
                                                                }
                                                              },
                                                              child: Container(
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
                                                                              5),
                                                                ),
                                                                width: 50,
                                                                height: 40,
                                                                child: Center(
                                                                  child: Text(
                                                                    'تم',
                                                                    style:
                                                                        kSubTitleTextStyle12,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  });
                                            },
                                            child: Text(
                                              ' الكمية  ${billItemList[index].billItemAmount.toString()}',
                                              textAlign: TextAlign.center,
                                              style:
                                                  kSubTitleTextStyle12.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.white),
                                            ),
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.plusCircle,
                                            color: Color(kPrimaryColor),
                                            size: 20,
                                          ),
                                          onPressed: () async {
                                            _audioCache.play('butttton.mp3');
                                            num itemAmount =
                                                (await _firestoreBillService
                                                        .getItemDataById(
                                                            billItemList[index]
                                                                .billItemId))
                                                    .storeItemAmount;
                                            setState(() {
                                              if (billItemList[index]
                                                      .billItemAmount <
                                                  itemAmount) {
                                                num itemPrice =
                                                    billItemList[index]
                                                            .billItemPrice /
                                                        billItemList[index]
                                                            .billItemAmount;
                                                num itemSellPrice =
                                                    billItemList[index]
                                                            .billItemSellPrice /
                                                        billItemList[index]
                                                            .billItemAmount;
                                                billItemList[index]
                                                    .billItemAmount++;
                                                billItemList[index]
                                                        .billItemPrice =
                                                    itemPrice *
                                                        billItemList[index]
                                                            .billItemAmount;
                                                billItemList[index]
                                                        .billItemSellPrice =
                                                    itemSellPrice *
                                                        billItemList[index]
                                                            .billItemAmount;
                                              } else {
                                                _assistantService.showToast(
                                                    context,
                                                    'الكمية الموجودة غير كافية',
                                                    Color(kLightRedColor),
                                                    16);
                                              }
                                            });
                                            getTotalPrice();
                                          }),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.minusCircle,
                                            color: Color(kPrimaryColor),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _audioCache.play('butttton.mp3');
                                            setState(() {
                                              if (billItemList[index]
                                                      .billItemAmount >
                                                  1) {
                                                num itemPrice =
                                                    billItemList[index]
                                                            .billItemPrice /
                                                        billItemList[index]
                                                            .billItemAmount;
                                                num itemSellPrice =
                                                    billItemList[index]
                                                            .billItemSellPrice /
                                                        billItemList[index]
                                                            .billItemAmount;
                                                billItemList[index]
                                                    .billItemAmount--;
                                                billItemList[index]
                                                        .billItemPrice =
                                                    itemPrice *
                                                        billItemList[index]
                                                            .billItemAmount;
                                                billItemList[index]
                                                        .billItemSellPrice =
                                                    itemSellPrice *
                                                        billItemList[index]
                                                            .billItemAmount;
                                              } else {
                                                billItemList.removeAt(index);
                                              }
                                            });
                                            getTotalPrice();
                                          }),
                                    )),
                                Expanded(
                                    flex: 1,
                                    child: Container(
                                      child: IconButton(
                                          icon: Icon(
                                            FontAwesomeIcons.trashAlt,
                                            color: Color(kPrimaryColor),
                                            size: 20,
                                          ),
                                          onPressed: () {
                                            _audioCache.play('butttton.mp3');
                                            setState(() {
                                              billItemList.removeAt(index);
                                              getTotalPrice();
                                            });
                                          }),
                                    )),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  //كونتينر التحكم فى المشتريات
                  Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        billItemList.length != 0
                            ? RaisedButton(
                                color: Color(kTextColor),
                                onPressed: () async {
                                  _audioCache.play('butttton.mp3');
                                  if (sharedPreferences.getBool('add_bill') ||
                                      (sharedPreferences
                                              .getString('user_type') ==
                                          'admin')) {
                                    if (billItemList.length != 0) {
                                      Bill bill = Bill(
                                          billDate: Timestamp.fromDate(
                                              DateTime.now()),
                                          billTotalPrice: totalPrice,
                                          billTotalSellPrice: totalSellPrice,
                                          billUser: (await GlobalData()
                                                  .getCurrentUserData())
                                              .userId);
                                      await _firestoreBillService.addbill(
                                          bill, billItemList);
                                      _assistantService.showToast(
                                          context, 'تم', Colors.green, 16);
                                      setState(() {
                                        billItemList.clear();
                                        totalPrice = 0;
                                      });
                                    } else {
                                      _assistantService.showToast(context,
                                          'لا توجد منتجات', Colors.red, 16);
                                    }
                                  } else {
                                    _assistantService.showToast(context,
                                        'غير مسموح', Color(kLightRedColor), 16);
                                  }
                                },
                                child: Text(
                                  'إتمام العملية',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Colors.white),
                                ))
                            : Text(''),
                        billItemList.length != 0
                            ? RaisedButton(
                                color: Color(kTextColor),
                                onPressed: () {
                                  _audioCache.play('butttton.mp3');
                                  setState(() {
                                    billItemList.clear();
                                    totalPrice = 0;
                                  });
                                },
                                child: Text(
                                  'حذف الفاتورة',
                                  style: kSubTitleTextStyle12.copyWith(
                                      color: Colors.white),
                                ))
                            : Text(''),
                        billItemList.length != 0
                            ? Text(
                                'الإجمالى: $totalPrice',
                                style: kMainTitleTextStyle16,
                              )
                            : Text(''),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
