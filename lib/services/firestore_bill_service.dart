import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:pdf/widgets.dart';
import 'package:sale_pro_elcaptain/models/bill.dart';
import 'package:sale_pro_elcaptain/models/bill_item.dart';
import 'package:sale_pro_elcaptain/models/category.dart';
import 'package:sale_pro_elcaptain/models/store_item.dart';
import 'package:sale_pro_elcaptain/models/unit.dart';
import 'package:sale_pro_elcaptain/models/waiting_item.dart';


class FirestoreBillService {
  final CollectionReference _usersCollection =
      FirebaseFirestore.instance.collection('users');
  final CollectionReference _catCollection =
      FirebaseFirestore.instance.collection('category');
  final CollectionReference _billsCollection =
      FirebaseFirestore.instance.collection('bills');
  final CollectionReference _storeCollection =
      FirebaseFirestore.instance.collection('store');
  final CollectionReference _commonItemsCollection =
      FirebaseFirestore.instance.collection('common_items');
  final CollectionReference _unitItemsCollection =
  FirebaseFirestore.instance.collection('units');

  final CollectionReference _waitingItemsCollection =
  FirebaseFirestore.instance.collection('waiting_items');

  Future updateAllStoreItems()async{
    List<DocumentSnapshot> docs = (await _storeCollection.get()).docs;
    List<StoreItem> storeItemList = List<StoreItem>();
    for(DocumentSnapshot doc in docs){
      StoreItem storeItem = StoreItem.fromJson(doc.data());
      storeItemList.add(storeItem);
    }
    for(StoreItem s in storeItemList){
      _storeCollection.doc(s.storeItemId.toString()).update({
        'locked': false,
      });
    }
  }

  Future<StoreItem> getStoreItemById(num storeItemId)async{
    StoreItem storeItem = StoreItem.fromJson((await _storeCollection.doc(storeItemId.toString()).get()).data());
    return storeItem;
  }

  Future<List<Category>> getCategories() async {
    List<Category> catList = List<Category>();
    List<DocumentSnapshot> docs =
        (await _catCollection.orderBy('cat_name').get()).docs;
      catList.add(Category(catId: 0, catName: 'منتجات شائعة'));

    for (DocumentSnapshot doc in docs) {
      Category cat = Category.fromJson(doc.data());
      catList.add(cat);
    }
    return catList;
  }

  Future<List<Category>> getCategoriesIndexed() async {
    List<Category> catList = List<Category>();
    List<DocumentSnapshot> docs =
        (await _catCollection.orderBy('cat_id').get()).docs;
    for (DocumentSnapshot doc in docs) {
      Category cat = Category.fromJson(doc.data());
      catList.add(cat);
    }
    return catList;
  }

  Future<bool> addToWaitingItems(WaitingItem waitingItem) async{
    await _waitingItemsCollection.add(waitingItem.toJson()).whenComplete(() => true).catchError((error) => false);
    return true;
  }

  Future<List<Unit>> getUnitsIndexed() async {
    List<Unit> unitList = List<Unit>();
    List<DocumentSnapshot> docs =
        (await _unitItemsCollection.orderBy('unit_id').get()).docs;
    for (DocumentSnapshot doc in docs) {
      Unit unit = Unit.fromJson(doc.data());
      unitList.add(unit);
    }
    return unitList;
  }

  Future<Category> getCategoryById(int catId) async {
    return Category.fromJson(
        (await _catCollection.doc(catId.toString()).get()).data());
  }

  Future<List<StoreItem>> getStoreItemsForCat(int catId) async {
    List<StoreItem> storeItemList = List<StoreItem>();
    if (catId == 0) {
      List<DocumentSnapshot> docs = (await _commonItemsCollection.get()).docs;
      for(DocumentSnapshot doc in docs){
        StoreItem storeItem = await getItemDataById(doc.data()['item_id']);
        storeItemList.add(storeItem);
      }
    } else {
      List<DocumentSnapshot> docs =
          (await _storeCollection.where('item_cat', isEqualTo: catId).get())
              .docs;
      for (DocumentSnapshot doc in docs) {
        StoreItem storeItem = StoreItem.fromJson(doc.data());
        storeItemList.add(storeItem);
      }
    }
    return storeItemList;
  }

  Future<WaitingItem> checkWaitingItemExist(int waitingItemId) async{
    List<QueryDocumentSnapshot> docs = (await _waitingItemsCollection.where('waiting_item_id',isEqualTo: waitingItemId).orderBy('add_date').get()).docs;
    if(docs.length == 0){
      return null;
    }else{
      return WaitingItem.fromJson(docs.first.data());
    }
  }

  Future<bool> updateItem(WaitingItem waitingItem) async{
    _storeCollection.doc(waitingItem.waitingItemId.toString()).update({
      'item_amount': waitingItem.waitingItemAmount,
      'item_sell_price': waitingItem.waitingItemSellPrice,
      'item_buy_price': waitingItem.waitingItemBuyPrice,
      'item_buy_price_gomla': waitingItem.waitingItemBuyPriceGomla,
    }).whenComplete(() async{
      (await _waitingItemsCollection.where('waiting_item_id',isEqualTo: waitingItem.waitingItemId).orderBy('add_date').get()).docs.first.reference.delete();
      return true;
    }).catchError((onError) => false);
    return true;
  }

  Future<int> getMaxBillId() async {
    if ((await _billsCollection.orderBy('bill_id', descending: true).get())
            .docs
            .length ==
        0) {
      return 1;
    } else {
      return (await _billsCollection.orderBy('bill_id', descending: true).get())
              .docs
              .first
              .data()['bill_id'] +
          1;
    }
  }

  Future<StoreItem> getItemDataById(int itemId) async {
    return StoreItem.fromJson(
        (await _storeCollection.doc(itemId.toString()).get()).data());
  }

  addbill(Bill bill, List<BillItem> billItemList) async {
    bill.billId = await getMaxBillId();
    _billsCollection.doc(bill.billId.toString()).set(bill.toJson());
    for (BillItem billItem in billItemList) {
      _billsCollection
          .doc(bill.billId.toString())
          .collection('bill_items')
          .doc(billItem.billItemId.toString())
          .set(billItem.toJson());
      num itemAmount =
          (await _storeCollection.doc(billItem.billItemId.toString()).get())
              .data()['item_amount'];
      _storeCollection.doc(billItem.billItemId.toString()).update({
        'item_amount': (itemAmount - billItem.billItemAmount),
      });
      _storeCollection.doc(billItem.billItemId.toString()).update({
        'last_update': Timestamp.fromDate(DateTime.now()),
      });
    }
  }

  // update returned product from bill
  updateBill(Bill bill, List<BillItem> billItemList) async {
    await _billsCollection.doc(bill.billId.toString()).update(bill.toJson());
    for (BillItem billItem in billItemList) {
      await _billsCollection
          .doc(bill.billId.toString())
          .collection('bill_items')
          .doc(billItem.billItemId.toString())
          .update(billItem.toJson());
    }
  }

  //remove returned product from bill
  removeBill(num billId)async{
    await _billsCollection.doc(billId.toString()).delete();
  }
  //remove billItem from BillItemList of returned amount
  removeBillItem(Bill bill , num billItemId)async{
    await _billsCollection.doc(bill.billId.toString()).collection('bill_items').doc(billItemId.toString()).delete();

  }


  Future<Map<String, dynamic>> getTotalBillPrice(
      DateTime startDate, DateTime endDate) async {
    DateTime sDate = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime eDate = DateTime(endDate.year, endDate.month, endDate.day, 24);

    num billTotalPrice = 0;
    num billTotalSellPrice = 0;
    int billsCount = 0;
    (await _billsCollection
            .where('bill_date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(sDate),
                isLessThan: Timestamp.fromDate(eDate))
            .get())
        .docs
        .forEach((doc) {
      Bill bill = Bill.fromJson(doc.data());
      billTotalPrice += bill.billTotalPrice;
      billTotalSellPrice += bill.billTotalSellPrice;
      billsCount++;
    });
    Map<String, dynamic> map = Map<String, dynamic>();
    map['bill_total_price'] = billTotalPrice;
    map['bill_total_sell_price'] = billTotalSellPrice;
    map['profit'] = billTotalPrice - billTotalSellPrice;
    map['bill_count'] = billsCount;
    return map;
  }

  Future<String> getUserNameById(String userId) async {
    return (await _usersCollection.doc(userId).get()).data()['user_name'];

  }

  Future<String> getUserPasswordById(String userId) async {
    return ((await _usersCollection.doc(userId).get()).data()['user_password']).toString();
  }

  Future<List<Bill>> getBills(DateTime startDate, DateTime endDate,String userType,int userId) async {
    List<Bill> bills = List<Bill>();
    DateTime sDate = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime eDate = DateTime(endDate.year, endDate.month, endDate.day, 24);
    int counter = 0;
    List<DocumentSnapshot> docs;
    if(userType == 'admin'){
      docs = (await _billsCollection
          .where('bill_date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sDate),
          isLessThan: Timestamp.fromDate(eDate))
          .orderBy('bill_date')
          .get())
          .docs;
      for (DocumentSnapshot doc in docs) {
        Bill bill = Bill.fromJson(doc.data());

        String userName = await getUserNameById(bill.billUser.toString());
        bill.userName = userName;
        bills.add(bill);
        counter++;
        if (counter == docs.length) {
          break;
        }
      }
    }else{
      docs = (await _billsCollection
          .where('bill_date',
          isGreaterThanOrEqualTo: Timestamp.fromDate(sDate),
          isLessThan: Timestamp.fromDate(eDate))
          .orderBy('bill_date')
          .get())
          .docs;
      for (DocumentSnapshot doc in docs) {
        Bill bill = Bill.fromJson(doc.data());
        if(bill.billUser == userId){
          String userName = await getUserNameById(bill.billUser.toString());
          bill.userName = userName;
          bills.add(bill);
          counter++;
          if (counter == docs.length) {
            break;
          }
        }

      }
    }
    return bills;
  }


  Future<List<BillItem>> getBillDetails(String billId) async {
    List<BillItem> billItemList = List<BillItem>();
    int counter = 0;
    List<DocumentSnapshot> docs = (await _billsCollection
            .doc(billId)
            .collection('bill_items')
            .get())
        .docs;
    for (DocumentSnapshot doc in docs) {
      BillItem billItem = BillItem.fromJson(doc.data());
      StoreItem storeItem = await getItemDataById(billItem.billItemId);
      billItem.billItemName = storeItem.storeItemName;
      billItemList.add(billItem);
      if (counter == docs.length) {
        break;
      }
    }
    return billItemList;
  }

  Future<Bill> getBillById(num billId) async {
    Bill bill = Bill();
    DocumentSnapshot doc = await _billsCollection.doc(billId.toString()).get();
    bill = Bill.fromJson(doc.data());
    return bill;
  }

  Future<Map<String, dynamic>> getStoreItemDetailsTotal() async {
    Map<String, dynamic> storeItemDetailsTotal = Map<String, dynamic>();
    List<DocumentSnapshot> docs = (await _storeCollection.get()).docs;
    num totalSellPrice = 0;
    num totalButPrice = 0;
    num totalBuyPriceGomla = 0;
    num totalAmount = 0;
    int counter = 0;
    for (DocumentSnapshot doc in docs) {
      StoreItem storeItem = StoreItem.fromJson(doc.data());
      counter++;
      totalAmount += storeItem.storeItemAmount;
      totalSellPrice +=
          storeItem.storeItemAmount * storeItem.storeItemSellPrice;
      totalButPrice += storeItem.storeItemAmount * storeItem.storeItemBuyPrice;
      totalBuyPriceGomla +=
          storeItem.storeItemAmount * storeItem.storeItemBuyPriceGomla;
    }
    storeItemDetailsTotal['item_type_count'] = counter;
    storeItemDetailsTotal['total_item_count'] = totalAmount;
    storeItemDetailsTotal['total_sell_price'] = totalSellPrice;
    storeItemDetailsTotal['total_buy_price'] = totalButPrice;
    storeItemDetailsTotal['total_buy_price_gomla'] = totalBuyPriceGomla;
    return storeItemDetailsTotal;
  }

  //one store item report
  Future<Map<String, dynamic>> getOneStoreItemReport(int itemId)async{
    Map<String, dynamic> billItemDetailsTotal = Map<String, dynamic>();
    DocumentSnapshot storeItemDoc = (await _storeCollection.doc(itemId.toString()).get());
    StoreItem storeItem = StoreItem.fromJson(storeItemDoc.data());
    num totalSoldOutAmount = 0 ;
    num totalRestAmount = storeItem.storeItemAmount;
    num totalPrice = 0 ;
    num totalSellPriceGomla = 0 ;
    num profit = 0 ;

    List<BillItem> billItems = List<BillItem>();
    int counter = 0;
    List<DocumentSnapshot> billDocs;
    billDocs = (await _billsCollection.get()).docs;
    List<DocumentSnapshot> billItemsDocs;

    for(DocumentSnapshot billDoc in billDocs){
      Bill bill = Bill.fromJson(billDoc.data());
      billItemsDocs = (await _billsCollection.doc(bill.billId.toString()).collection('bill_items').get()).docs;
      //print(bill.billId);
      for(DocumentSnapshot billItemDoc in billItemsDocs){
        BillItem billItem = BillItem.fromJson(billItemDoc.data());
        //print(billItem.billItemAmount);
        if(billItem.billItemId == itemId){
          totalSoldOutAmount +=billItem.billItemAmount;
          totalPrice +=billItem.billItemPrice;
          totalSellPriceGomla +=billItem.billItemSellPrice;

          billItems.add(billItem);
          counter++;
        }
      }
    }
    profit = totalPrice - totalSellPriceGomla;
    print(' الكمية المُباعة من هذا المُنتج : ${totalSoldOutAmount}');
    print(' الكمية المٌتبقية من هذا المُنتج :${totalRestAmount}');
    print(' الربح من هذا المُنتج:${profit}');

    billItemDetailsTotal['bill_count'] = counter;
    billItemDetailsTotal['total_sold_out_price'] = totalSoldOutAmount;
    billItemDetailsTotal['total_rest_price'] = totalRestAmount;
    billItemDetailsTotal['profit'] = profit;


    return billItemDetailsTotal;
  }

  Future<List<BillItem>> getBillItemsAmount(
      DateTime startDate, DateTime endDate) async {
    List<BillItem> billItemsList = List<BillItem>();
    DateTime sDate = DateTime(startDate.year, startDate.month, startDate.day);
    DateTime eDate = DateTime(endDate.year, endDate.month, endDate.day, 24);
    List<DocumentSnapshot> docs = (await _billsCollection
            .where('bill_date',
                isGreaterThanOrEqualTo: Timestamp.fromDate(sDate),
                isLessThan: Timestamp.fromDate(eDate))
            .orderBy('bill_date')
            .get())
        .docs;
    for (DocumentSnapshot doc in docs) {
      List<DocumentSnapshot> billItemsDocs =
          (await doc.reference.collection('bill_items').get()).docs;
      for (DocumentSnapshot billItemsDoc in billItemsDocs) {
        num billItemId = billItemsDoc.data()['bill_item_id'];
        num billItemAmount = billItemsDoc.data()['bill_item_amount'];
        num billItemPrice = billItemsDoc.data()['bill_item_price'];
        int counter = 0;
        for (BillItem billItem in billItemsList) {
          if (billItem.billItemId == billItemId) {
            billItem.billItemAmount += billItemAmount;
            billItem.billItemPrice += billItemPrice;
            break;
          } else {
            counter++;
          }
        }
        if (counter == billItemsList.length) {
          StoreItem storeItem = await getItemDataById(billItemId);
          billItemsList.add(BillItem(
            billItemId: billItemId,
            billItemAmount: billItemAmount,
            billItemPrice: billItemPrice,
            billItemName: storeItem.storeItemName,
            billItemSellPrice: storeItem.storeItemSellPrice,
          ));
        }
      }
    }
    return billItemsList;
  }

  Future<List<StoreItem>> getLackItems() async {
    List<StoreItem> storeItemList = List<StoreItem>();
    List<DocumentSnapshot> docs =
        (await _storeCollection.orderBy('last_update').get()).docs;
    for (DocumentSnapshot doc in docs) {
      StoreItem storeItem = StoreItem.fromJson(doc.data());
      if (storeItem.storeItemMinAmount >= storeItem.storeItemAmount) {
        storeItemList.add(storeItem);
      }
    }
    return storeItemList;
  }

  Future<bool>addToCommonProducts(int storeItemId) async{
    int length = (await _commonItemsCollection.where('item_id',isEqualTo: storeItemId).get()).docs.length;
    if(length == 0) {
      _commonItemsCollection.doc(storeItemId.toString()).set({
        'item_id': storeItemId,
      });
      return true;
    }else{
      return false;
    }
  }

  Future<bool>deleteFromCommonProducts(int storeItemId) async{
    int length = (await _commonItemsCollection.where('item_id',isEqualTo: storeItemId).get()).docs.length;
    if(length != 0) {
      _commonItemsCollection.doc(storeItemId.toString()).delete();
      return true;
    }else{
      return false;
    }
  }

  prindPdf(pw.Widget container) async {
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await File('${systemTempDir.path}/example.pdf').create();

    var myTheme = Theme.withFont(
      base: Font.ttf(await rootBundle.load("fonts/Cairo-Regular.ttf")),
      bold: Font.ttf(await rootBundle.load("fonts/Cairo-Bold.ttf")),
    );

    final pdf = pw.Document(
      theme: myTheme,
    );
    pdf.addPage(pw.Page(
        textDirection: pw.TextDirection.rtl,
        theme: myTheme,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return container; // Center
        }));

    await file.writeAsBytes(pdf.save());

    final Reference storageReference =
        FirebaseStorage.instance.ref().child('backup');
    UploadTask storageUploadTask =
        storageReference.child('example.pdf').putFile(file);
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() => null);
    print(await storageTaskSnapshot.ref.getDownloadURL());
  }

  Future<List<StoreItem>> itemSearch(String searchWord) async {
    List<StoreItem> searchItemsList = List<StoreItem>();
    List<DocumentSnapshot> docs = (await _storeCollection.get()).docs;
    for (DocumentSnapshot doc in docs) {
      StoreItem storeItem = StoreItem.fromJson(doc.data());
      if (storeItem.storeItemName.contains(searchWord)) {
        searchItemsList.add(storeItem);
      }
    }
    return searchItemsList;
  }

  categoryCollectionBackupDownload() async {
    String backup = '';
    (await FirebaseFirestore.instance.collection('category').get())
        .docs
        .forEach((doc) {
      backup = backup +
          doc.data()['cat_id'].toString() +
          ':' +
          doc.data()['cat_name'] +
          '=';
    });
    uploadToStorage(backup, 'category_backup.txt');
  }

  uploadToStorage(String text, String fileName) async {
    final Directory systemTempDir = Directory.systemTemp;
    final File file = await File('${systemTempDir.path}/$fileName').create();
    Codec<String, String> stringToBase64 = utf8.fuse(base64);
    String encoded = stringToBase64.encode(text);
    await file.writeAsString(encoded);
    assert(await file.readAsString() == encoded);
    final Reference storageReference =
        FirebaseStorage.instance.ref().child('backup');
    UploadTask storageUploadTask =
        storageReference.child(fileName).putFile(file);
    TaskSnapshot storageTaskSnapshot =
        await storageUploadTask.whenComplete(() => null);
    print(await storageTaskSnapshot.ref.getDownloadURL());
  }

  categoryCollectionBackupUpload() async {
    String backup = await downloadFromStorage('category_backup.txt');
    List<String> docs = backup.split('=');
    int counter = 0;
    for (String doc in docs) {
      //exCol.add(data)
      counter++;
      if (docs.length != counter) {
        List<String> item = doc.split(':');
        _catCollection
            .doc(item[0])
            .set({'cat_id': int.parse(item[0]), 'cat_name': item[1]});
      }
    }
  }

  Future<String> downloadFromStorage(String fileName) async {
    final Directory systemTempDir = Directory.systemTemp;
    final File tempFile = File('${systemTempDir.path}/$fileName');
    if (tempFile.existsSync()) {
      await tempFile.delete();
    }
    await tempFile.create();
    assert(await tempFile.readAsString() == "");
    final DownloadTask task = FirebaseStorage.instance
        .ref()
        .child('backup')
        .child(fileName)
        .writeToFile(tempFile);
    task.whenComplete(() async {
      String backup = await tempFile.readAsString();
      Codec<String, String> stringToBase64 = utf8.fuse(base64);
      String decoded = stringToBase64.decode(backup);
      return decoded;
    });
    return null;
  }

  storeCollectionBackupDownload() async {
    String backup = '';
    (await _storeCollection.get()).docs.forEach((doc) {
      StoreItem storeItem = StoreItem.fromJson(doc.data());
      backup = backup +
          storeItem.storeItemId.toString() +
          ':' +
          storeItem.storeItemName +
          ':' +
          storeItem.storeItemCat.toString() +
          ':' +
          storeItem.storeItemAmount.toString() +
          ':' +
          storeItem.storeItemMinAmount.toString() +
          ':' +
          storeItem.storeItemSellPrice.toString() +
          ':' +
          storeItem.storeItemBuyPrice.toString() +
          ':' +
          storeItem.storeItemBuyPriceGomla.toString() +
          '=';
    });
    uploadToStorage(backup, 'store_backup.txt');
  }

  storeCollectionBackupUpload() async {
    String backup = await downloadFromStorage('store_backup.txt');
    List<String> docs = backup.split('=');
    CollectionReference exCol = FirebaseFirestore.instance.collection('store');
    int counter = 0;
    for (String doc in docs) {
      //exCol.add(data)
      counter++;
      if (docs.length != counter) {
        List<String> item = doc.split(':');
        StoreItem storeItem = StoreItem(
            storeItemId: int.parse(item[0]),
            storeItemName: item[1],
            storeItemCat: num.parse(item[2]),
            storeItemAmount: num.parse(item[3]),
            storeItemMinAmount: num.parse(item[4]),
            storeItemSellPrice: num.parse(item[5]),
            storeItemBuyPrice: num.parse(item[6]),
            storeItemBuyPriceGomla: num.parse(item[7]));
        _storeCollection.doc(item[0]).set(storeItem.toJson());
      }
    }
  }
}
