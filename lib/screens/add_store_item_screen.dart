import 'dart:io';
import 'dart:math';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sale_pro_elcaptain/models/category.dart';
import 'package:sale_pro_elcaptain/models/store_item.dart';
import 'package:sale_pro_elcaptain/models/unit.dart';
import 'package:sale_pro_elcaptain/models/waiting_item.dart';
import 'package:sale_pro_elcaptain/screens/splash_screen.dart';
import 'package:sale_pro_elcaptain/services/assistant_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_add_storeItem_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_bill_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_category_service.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';


class AddProductScreen extends StatefulWidget {
  final StoreItem storeItem;
  final BuildContext homeContext;

  const AddProductScreen({this.storeItem, this.homeContext});
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  AudioCache _audioCache;
  List<File> myImages = [];
  String imageUrl;
  StoreItem myStoreItem = StoreItem();
  Category selectedCat = Category(catId: 1);
  Unit selectedUnit = Unit(unitId: 1);
  FireStoreAddStoreItemService _addStoreItemService =
      new FireStoreAddStoreItemService();
  FireStoreCategoriesService _categoriesService =
  new FireStoreCategoriesService();
  FirestoreBillService _firestoreBillService = FirestoreBillService();
  TextEditingController _storeItemNameController;
  TextEditingController _storeItemAmountController;
  TextEditingController _waitingStoreItemAmountController;
  TextEditingController _storeItemMinAmountController;
  TextEditingController _storeItemSellPriceController;
  TextEditingController _waitingStoreItemSellPriceController;
  TextEditingController _storeItemBuyPriceController;
  TextEditingController _waitingStoreItemBuyPriceController;
  TextEditingController _storeItemBuyPriceGomlaController;
  TextEditingController _waitingStoreItemBuyPriceGomlaController;
  TextEditingController _categoryNameController;
  TextEditingController _unitNameController;
  AssistantService _assistantService = AssistantService();
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  var listen;
  bool _catIsExist = false;
  bool _unitIsExist = false;
  String _scanBarcode = 'barcode';

  @override
  void initState() {
    listenToAnyPrivChange();
    super.initState();
    _audioCache = AudioCache(
        prefix: "sound/",
        fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
    _storeItemNameController = TextEditingController();
    _storeItemAmountController = TextEditingController();
    _waitingStoreItemAmountController = TextEditingController();
    _storeItemMinAmountController = TextEditingController();
    _storeItemSellPriceController = TextEditingController();
    _waitingStoreItemSellPriceController = TextEditingController();
    _storeItemBuyPriceController = TextEditingController();
    _waitingStoreItemBuyPriceController = TextEditingController();
    _storeItemBuyPriceGomlaController = TextEditingController();
    _waitingStoreItemBuyPriceGomlaController = TextEditingController();
    _categoryNameController = TextEditingController();
    _unitNameController = TextEditingController();

    if (widget.storeItem != null) {
      _storeItemNameController.text = widget.storeItem.storeItemName;
      _storeItemAmountController.text =
          widget.storeItem.storeItemAmount.toString();
      _storeItemMinAmountController.text =
          widget.storeItem.storeItemMinAmount.toString();
      _storeItemSellPriceController.text =
          widget.storeItem.storeItemSellPrice.toString();
      _storeItemBuyPriceController.text =
          widget.storeItem.storeItemBuyPrice.toString();
      _storeItemBuyPriceGomlaController.text =
          widget.storeItem.storeItemBuyPriceGomla.toString();
      imageUrl = widget.storeItem.storeItemImgUrl.toString();
      _scanBarcode = widget.storeItem.storeItemBarCode.toString();
    } else {
      _storeItemNameController.text = '';
      _storeItemAmountController.text = '';
      _storeItemMinAmountController.text = '';
      _storeItemSellPriceController.text = '';
      _storeItemBuyPriceController.text = '';
      _storeItemBuyPriceGomlaController.text = '';
      imageUrl = '';
    }
    selectedCat.catId =
        widget.storeItem == null ? 1 : widget.storeItem.storeItemCat;
    selectedUnit.unitId = widget.storeItem == null
        ? 0
        : (widget.storeItem.storeItemUnit == null
            ? 3
            : widget.storeItem.storeItemUnit);
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

  Future<void> initPlatformState() async {
    String barcodeScanRes;


    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      barcodeScanRes = await FlutterBarcodeScanner.scanBarcode("#ff6666", "Cancel",true,ScanMode.DEFAULT);


    } on PlatformException {
      barcodeScanRes = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _scanBarcode = barcodeScanRes;
    });
  }

  Widget _submitButton() {
    return InkWell(
      onTap: () {
        _audioCache.play('butttton.mp3');
        if (widget.storeItem == null) {
          myStoreItem.storeItemName = _storeItemNameController.text;
          myStoreItem.storeItemCat = selectedCat.catId;
          myStoreItem.storeItemUnit = selectedUnit.unitId;
          myStoreItem.storeItemAmount = num.parse(
              _storeItemAmountController.text == ''
                  ? '0'
                  : _storeItemAmountController.text);
          myStoreItem.storeItemMinAmount = num.parse(
              _storeItemMinAmountController.text == ''
                  ? '0'
                  : _storeItemMinAmountController.text);
          myStoreItem.storeItemSellPrice = num.parse(
              _storeItemSellPriceController.text == ''
                  ? '0'
                  : _storeItemSellPriceController.text);
          myStoreItem.storeItemBuyPrice = num.parse(
              _storeItemBuyPriceController.text == ''
                  ? '0'
                  : _storeItemBuyPriceController.text);
          myStoreItem.storeItemBuyPriceGomla = num.parse(
              _storeItemBuyPriceGomlaController.text == ''
                  ? '0'
                  : _storeItemBuyPriceGomlaController.text);
          myStoreItem.storeItemBarCode = _scanBarcode == 'barcode'?'':_scanBarcode;
          myStoreItem.storeItemImgUrl = imageUrl;
          myStoreItem.lastUpdate = Timestamp.fromDate(DateTime.now());
          if (myStoreItem.storeItemName == '') {
            _assistantService.showToast(context, 'ادخل اسم المنتج', Colors.red,16);
          } else {
            _addStoreItemService.addItem(myStoreItem);
            _assistantService.showToast(
                context, 'تم اضافة المنتج', Colors.green,16);
          }
          _storeItemNameController.text = '';
          _storeItemAmountController.text = '';
          _storeItemMinAmountController.text = '';
          _storeItemSellPriceController.text = '';
          _storeItemBuyPriceController.text = '';
          _storeItemBuyPriceGomlaController.text = '';
          imageUrl = '';
          setState(() {
            _scanBarcode = 'barcode';
          });
        } else {
          myStoreItem.storeItemId = widget.storeItem.storeItemId;
          myStoreItem.storeItemBarCode = _scanBarcode;
          myStoreItem.storeItemName = _storeItemNameController.text;
          myStoreItem.storeItemCat = selectedCat.catId;
          myStoreItem.storeItemUnit = selectedUnit.unitId;
          myStoreItem.storeItemAmount =
              num.parse(_storeItemAmountController.text);
          myStoreItem.storeItemMinAmount =
              num.parse(_storeItemMinAmountController.text);
          myStoreItem.storeItemSellPrice =
              num.parse(_storeItemSellPriceController.text);
          myStoreItem.storeItemBuyPrice =
              num.parse(_storeItemBuyPriceController.text);
          myStoreItem.storeItemBuyPriceGomla =
              num.parse(_storeItemBuyPriceGomlaController.text);
          myStoreItem.storeItemImgUrl = imageUrl;
          myStoreItem.lastUpdate = Timestamp.fromDate(DateTime.now());
          myStoreItem.locked = widget.storeItem.locked;

          CollectionReference store =
              FirebaseFirestore.instance.collection('store');



          store
              .doc(widget.storeItem.storeItemId.toString())
              .update(myStoreItem.toJson());

          Navigator.pop(widget.homeContext);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return HomeScreen(myStoreItem.storeItemCat);
          }));
        }
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
        child: Text(
          widget.storeItem != null ? 'تعديل' : 'إضافة',
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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          brightness: Brightness.dark,
          elevation: 6,
          toolbarHeight: 70,
          backgroundColor: Color(kPrimaryColor),
          title: widget.storeItem != null
              ? Text(
            'تعديل المُنتج',
            style: kMainTitleTextStyle18,
          )
              : Text(
            'اضافة المُنتج',
            style: kMainTitleTextStyle18,
          ),
          centerTitle: true,
          actions: [
            backButton(),
            IconButton(
              onPressed: (){
                initPlatformState();
              },
              icon: Icon(Icons.qr_code,
                size: 25,
                color: Color(kTextColor),),
            )
          ],
          leading: IconButton(
              onPressed: (){
                _audioCache.play('butttton.mp3');
                showDialog(
                    context: context,
                    builder: (context){
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: AlertDialog(
                          backgroundColor:
                          Colors.white,
                          title: Text(
                            'مُنتج منتظر',
                            style: kMainTitleTextStyle18
                                .copyWith(
                                color: Color(
                                    kTextColor)),
                          ),
                          content: Container(
                            height: MediaQuery.of(context)
                                .size
                                .height /
                                2.4,
                            child: Column(
                              children: [
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 50,
                                  child: TextField(
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'الكمية الموجودة',
                                    ),
                                    controller: _waitingStoreItemAmountController,
                                    keyboardType: TextInputType.numberWithOptions(),
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 50,
                                  child: TextField(
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'سعر الشراء',
                                    ),
                                    controller: _waitingStoreItemSellPriceController,
                                    keyboardType: TextInputType.numberWithOptions(),
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 50,
                                  child: TextField(
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'سعر البيع قطاعي',
                                    ),
                                    controller: _waitingStoreItemBuyPriceController,
                                    keyboardType: TextInputType.numberWithOptions(),
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                Container(
                                  margin: EdgeInsets.symmetric(horizontal: 10),
                                  height: 50,
                                  child: TextField(
                                    decoration: kTextFieldDecoration.copyWith(
                                      labelText: 'سعر البيع جملة',
                                    ),
                                    controller: _waitingStoreItemBuyPriceGomlaController,
                                    keyboardType: TextInputType.numberWithOptions(),
                                  ),
                                ),
                                SizedBox(
                                  height: 7,
                                ),
                                InkWell(
                                  onTap: () async{
                                    _audioCache.play('butttton.mp3');
                                    WaitingItem waitingItem = WaitingItem(
                                      waitingItemId: widget.storeItem.storeItemId,
                                      waitingItemAmount: num.parse(_waitingStoreItemAmountController.text),
                                      waitingItemSellPrice: num.parse(_waitingStoreItemSellPriceController.text),
                                      waitingItemBuyPrice: num.parse(_waitingStoreItemBuyPriceController.text),
                                      waitingItemBuyPriceGomla: num.parse(_waitingStoreItemBuyPriceGomlaController.text),
                                      addDate: Timestamp.fromDate(DateTime.now()),
                                    );
                                    bool result = await _firestoreBillService.addToWaitingItems(waitingItem);
                                    if(result){
                                      _assistantService.showToast(context, 'تم اضافة المنتج', Color(kLightGreenColor),16);
                                      Navigator.pop(context);
                                    }else{
                                      _assistantService.showToast(context, 'حدث خطأ حاول مرة اخرى', Color(kLightGreenColor),16);
                                    }
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
                                    child: Text('إضافة',
                                      style: TextStyle(
                                          fontSize: 14,
                                          color: Color(kTextColor),
                                          fontFamily: 'Cairo',
                                          fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      );
                    }
                );
              },
              icon: Icon(Icons.access_time_sharp,color: Color(kTextColor),)
          ),
          shadowColor: Color(kTextColor),
        ),
        body: ListView(
          children: [
            Column(
              children: [
                SizedBox(
                  height: 30,
                ),

                GestureDetector(
                  onTap: () {
                    _audioCache.play('butttton.mp3');
                    setState(() {
                      upLoadImageToFirebase();
                    });
                  },
                  child: Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Color(kTextColor),
                            blurRadius: 3,
                            spreadRadius: .1),
                      ],
                    ),
                    child: Container(
                      child: (imageUrl != '')
                          ? Image.network(widget.storeItem.storeItemImgUrl)
                          : Icon(
                              Icons.add,
                              size: 40,
                              color: Color(kTextColor),
                            ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),

                Text(_scanBarcode,),

                SizedBox(
                  height: 10,
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: TextField(
                    decoration: kTextFieldDecoration.copyWith(
                      labelText: 'اسم المنتج',
                    ),
                    controller: _storeItemNameController,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        height: 50,
                        color: Colors.grey.withOpacity(.2),
                        child: FutureBuilder<List<Category>>(
                          future: _firestoreBillService.getCategoriesIndexed(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return Directionality(
                                textDirection: TextDirection.rtl,
                                child: DropdownSearch<Category>(
                                  dropdownBuilder:
                                      (context, selectedItem, itemAsString) {
                                    return Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Container(
                                        padding: EdgeInsets.only(right: 10),
                                        child: Text(
                                          itemAsString,
                                        ),
                                      ),
                                    );
                                  },
                                  mode: Mode.MENU,
                                  items: snapshot.data,
                                  itemAsString: (cat) => cat.catName,
                                  hint: 'القسم',
                                  onChanged: (val) {
                                    selectedCat = val;
                                  },
                                  selectedItem: snapshot.data[widget.storeItem == null
                                      ? 0
                                      : (widget.storeItem.storeItemCat - 1)],
                                  popupItemBuilder: (BuildContext context,
                                      Category cat, bool isSelected) {
                                    return Directionality(
                                      textDirection: TextDirection.rtl,
                                      child: Container(
                                        margin: EdgeInsets.symmetric(horizontal: 8),
                                        decoration: !isSelected
                                            ? null
                                            : BoxDecoration(
                                          border: Border.all(
                                              color: Theme.of(context)
                                                  .primaryColor),
                                          borderRadius:
                                          BorderRadius.circular(5),
                                          color: Colors.white,
                                        ),
                                        child: ListTile(
                                          selected: isSelected,
                                          title: Text(cat.catName),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ),
                    //booooo
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        decoration:BoxDecoration(
                          border: Border.all(
                              color: Color(kTextColor)),
                          borderRadius:
                          BorderRadius.circular(5),
                          color: Color(kPrimaryColor),
                        ),
                          child : IconButton(
                            onPressed: () {
                              _audioCache.play('butttton.mp3');
                              //add category
                              showDialog(
                                context: context,
                                builder: (context){
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Container(
                                      child: AlertDialog(
                                        title: Text(
                                          'إضافة قسم',
                                          style: kMainTitleTextStyle18.copyWith(color: Colors.black),),
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
                                                controller: _categoryNameController,
                                              ),
                                            ),

                                          ),
                                        ),
                                        actions: [
                                          InkWell(
                                            onTap: (){
                                              _audioCache.play('butttton.mp3');
                                              _categoryNameController.text = '';
                                              Navigator.pop(context);
                                            },
                                            child:Container(
                                              decoration: BoxDecoration(
                                                color: Color(kTextColor),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              width: 50,
                                              height: 40,

                                              child: Center(
                                                child: Text('إلغاء',
                                                  style: kSubTitleTextStyle12
                                                      .copyWith(color: Colors.white),),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: ()async{
                                              _audioCache.play('butttton.mp3');
                                              List<Category> catList = await _categoriesService.getAllCat();
                                              for(Category cat in catList){
                                                if(cat.catName == _categoryNameController.text.toString()){
                                                  _catIsExist = true;
                                                }
                                              }
                                              if(!_catIsExist){
                                                setState(() {
                                                  _addStoreItemService.addCat(_categoryNameController.text);
                                                  _assistantService.showToast(context, 'تم إضافة القسم', Color(kLightGreenColor),16);
                                                  _categoryNameController.text = '';
                                                  Navigator.pop(context);
                                                });
                                              }else{
                                                _assistantService.showToast(context, 'القسم موجود بالفعل', Color(kLightRedColor),16);
                                              }
                                            },
                                            child:Container(
                                              decoration: BoxDecoration(
                                                color: Color(kTextColor),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              width: 50,
                                              height: 40,

                                              child: Center(
                                                child: Text('تم',
                                                  style: kSubTitleTextStyle12
                                                  .copyWith(color: Colors.white),),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                              );
                            },
                            color: Color(kPrimaryColor),
                            icon: Icon(FontAwesomeIcons.cog,color: Color(kTextColor),),
                            iconSize: 30,
                          ),

                      ),
                    ),
                  ],
                ),



                SizedBox(
                  height: 10,
                ),

                //TextField of Description
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: TextField(
                    decoration: kTextFieldDecoration.copyWith(
                      labelText: 'الكمية الموجودة',
                    ),
                    controller: _storeItemAmountController,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: TextField(
                    decoration: kTextFieldDecoration.copyWith(
                      labelText: 'أقل كمية يجب أن تكون مُتاحة',
                    ),
                    controller: _storeItemMinAmountController,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),

                Row(
                  children: [
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        height: 50,
                        color: Colors.grey.withOpacity(.2),
                        child: FutureBuilder<List<Unit>>(
                          future: _firestoreBillService.getUnitsIndexed(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              return DropdownSearch<Unit>(
                                dropdownBuilder:
                                    (context, selectedItem, itemAsString) {
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Container(
                                      //Text(itemAsString),
                                      padding: EdgeInsets.only(right: 10),
                                      child: Text(
                                        itemAsString,
                                      ),
                                    ),
                                  );
                                },
                                mode: Mode.MENU,
                                items: snapshot.data,
                                itemAsString: (cat) => cat.unitName,
                                hint: "الوحدة",
                                onChanged: (val) {
                                  selectedUnit = val;
                                  print(selectedUnit.unitId.toString());
                                },
                                selectedItem: snapshot.data[widget.storeItem == null
                                    ? 0
                                    : ((widget.storeItem.storeItemUnit == null
                                    ? 1
                                    : widget.storeItem.storeItemUnit) -
                                    1)],
                                popupItemBuilder: (BuildContext context, Unit unit,
                                    bool isSelected) {
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 8),
                                      decoration: !isSelected
                                          ? null
                                          : BoxDecoration(
                                        border: Border.all(
                                            color:
                                            Theme.of(context).primaryColor),
                                        borderRadius: BorderRadius.circular(5),
                                        color: Colors.white,
                                      ),
                                      child: ListTile(
                                        selected: isSelected,
                                        title: Text(unit.unitName),
                                      ),
                                    ),
                                  );
                                },
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    ),
                    //booooo
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.only(left: 10),
                        decoration:BoxDecoration(
                          border: Border.all(
                              color: Color(kTextColor)),
                          borderRadius:
                          BorderRadius.circular(5),
                          color: Color(kPrimaryColor),
                        ),
                        child : IconButton(
                          onPressed: () {
                            _audioCache.play('butttton.mp3');
                            //add unit
                            showDialog(
                                context: context,
                                builder: (context){
                                  return Directionality(
                                    textDirection: TextDirection.rtl,
                                    child: Container(
                                      child: AlertDialog(
                                        title: Text(
                                          'إضافة كمية جديدة',
                                          style: kMainTitleTextStyle18.copyWith(color: Colors.black),),
                                        backgroundColor: Colors.white,
                                        content: SingleChildScrollView(
                                          child: Container(
                                            child: Container(
                                              margin: EdgeInsets.symmetric(horizontal: 10),
                                              height: 50,
                                              child: TextField(
                                                decoration: kTextFieldDecoration.copyWith(
                                                  labelText: 'أصف إسم الكمية الجديدة',
                                                ),
                                                controller: _categoryNameController,
                                              ),
                                            ),

                                          ),
                                        ),
                                        actions: [
                                          InkWell(
                                            onTap: (){
                                              _audioCache.play('butttton.mp3');
                                              _categoryNameController.text = '';
                                              Navigator.pop(context);
                                            },
                                            child:Container(
                                              decoration: BoxDecoration(
                                                color: Color(kTextColor),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              width: 50,
                                              height: 40,

                                              child: Center(
                                                child: Text('إلغاء',
                                                  style: kSubTitleTextStyle12
                                                      .copyWith(color: Colors.white),),
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: ()async{
                                              _audioCache.play('butttton.mp3');
                                              List<Unit> unitList = await _categoriesService.getAllCatUnit();
                                              for(Unit unit in unitList){
                                                if(unit.unitName == _unitNameController.text.toString()){
                                                  _unitIsExist = true;
                                                }
                                              }
                                              if(!_unitIsExist){
                                                setState(() {
                                                  _addStoreItemService.addUnit(_unitNameController.text);
                                                  _assistantService.showToast(context, 'تم إضافة القسم', Color(kLightGreenColor),16);
                                                  _unitNameController.text = '';
                                                  Navigator.pop(context);
                                                });
                                              }else{
                                                _assistantService.showToast(context, 'القسم موجود بالفعل', Color(kLightRedColor),16);
                                              }
                                            },
                                            child:Container(
                                              decoration: BoxDecoration(
                                                color: Color(kTextColor),
                                                borderRadius: BorderRadius.circular(5),
                                              ),
                                              width: 50,
                                              height: 40,

                                              child: Center(
                                                child: Text('تم',
                                                  style: kSubTitleTextStyle12
                                                      .copyWith(color: Colors.white),),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }
                            );

                          },
                          color: Color(kTextColor),
                          icon: Icon(FontAwesomeIcons.cog),
                          iconSize: 30,
                        ),

                      ),
                    ),
                  ],
                ),


                SizedBox(
                  height: 10,
                ),

                //TextField of price
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: TextField(
                    decoration: kTextFieldDecoration.copyWith(
                      labelText: 'سعر الشراء',
                    ),
                    controller: _storeItemSellPriceController,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),

                //TextField of Description
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: TextField(
                    decoration: kTextFieldDecoration.copyWith(
                      labelText: ' سعر البيع قطاعى',
                    ),
                    controller: _storeItemBuyPriceController,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),

                SizedBox(
                  height: 10,
                ),

                //TextField of price Gomla
                Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  height: 50,
                  child: TextField(
                    decoration: kTextFieldDecoration.copyWith(
                      labelText: 'سعر البيع بالجملة',
                    ),
                    controller: _storeItemBuyPriceGomlaController,
                    keyboardType: TextInputType.numberWithOptions(),
                  ),
                ),
                widget.storeItem == null ?
                Container() :
                Column(
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.2),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        width: MediaQuery.of(context).size.width,
                        height: 50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                              flex: 5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                    'تعطيل المُنتج',
                                    style: kSubTitleTextStyle12.copyWith(
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),),
                            Expanded(
                              flex: 1,
                              child: Transform.scale(
                                scale: 0.8,
                                child: CupertinoSwitch(
                                  activeColor: Color(kDarkRedColor),
                                  trackColor: Color(kTextColor),
                                  value: widget.storeItem.locked,
                                  onChanged: (bool value) {
                                    setState(() {
                                      widget.storeItem.locked = value;
                                    });
                                  },
                                ),
                              ),),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 40,
                ),
                //Add Button
                _submitButton(),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  upLoadImageToFirebase() async {
    final _storage = FirebaseStorage.instance;
    final _picker = ImagePicker();
    PickedFile image;

    //check permissions
    await Permission.photos.request();
    var permissionStatus = await Permission.photos.status;
    if (permissionStatus.isGranted) {
      //Select Image
      image = await _picker.getImage(source: ImageSource.gallery);
      var file = File(image.path);

      // make random image name
      int randomNumber = Random().nextInt(100000);
      String imageLocation = 'images/image$randomNumber.jpg';

      if (image != null) {
        //Upload to Firebase
        var snapshot = await _storage
            .ref()
            .child('myImages/$imageLocation')
            .putFile(file);

        var downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          imageUrl = downloadUrl.toString();
        });
      } else {
        print('No Pass Received ');
      }
    } else {
      print('Grant permission and try again');
    }
  }
}

