import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sale_pro_elcaptain/models/store_item.dart';

class FireStoreAddStoreItemService {
  final CollectionReference _storeItemCollection = FirebaseFirestore.instance.collection('store');
  final CollectionReference _categoryCollection = FirebaseFirestore.instance.collection('category');
  final CollectionReference _unitCollection = FirebaseFirestore.instance.collection('units');

  Future<StoreItem> getItemDataById(int itemId) async{
    return StoreItem.fromJson((await _storeItemCollection.doc(itemId.toString()).get()).data());
  }

  Future<int> getItemId() async {
    int storeItemId = (await FirebaseFirestore.instance
            .collection('store')
            .orderBy('item_id', descending: true)
            .get())
        .docs
        .first
        .data()['item_id'];
    return (storeItemId + 1);
  }

  Future addItem(StoreItem storeItem ) async {
    storeItem.storeItemId = await getItemId();
      _storeItemCollection.doc(storeItem.storeItemId.toString()).set(storeItem.toJson());

  }

  Future updateItem(int itemId,StoreItem storeItem , List<StoreItem>storeItemList) async {
    itemId = storeItem.storeItemId ;
    for( StoreItem storeItem in storeItemList ){
      _storeItemCollection.doc(itemId.toString()).update(storeItem.toJson())
          .then((value) => print("item Updated"))
          .catchError((error) => print("Failed to update user: $error"));

    }

  }

  Future<bool> deleteItem(int itemId)async{
    _storeItemCollection.doc(itemId.toString()).delete().then((value) {
      return true;
    },onError: (error){
      return false;
    });
    return true;
  }

  Future<List<StoreItem>> getStoreItems() async{
    List<StoreItem> itemList = List<StoreItem>();
    List<DocumentSnapshot> docs = (await _storeItemCollection.get()).docs;
    for(DocumentSnapshot doc in docs){
      StoreItem item = StoreItem.fromJson(doc.data());
      itemList.add(item);
    }
    return itemList;
  }

  //add category
  Future<String> getMaxCatIdIdPlusOne() async {
    int userId =
    (await _categoryCollection.orderBy('cat_id', descending: true).get())
        .docs
        .first
        .data()['cat_id'];
    return (userId + 1).toString();
  }
  
  Future addCat(String catName) async {
    String uId = await getMaxCatIdIdPlusOne();

    _categoryCollection.doc(uId).set({
      'cat_id': int.parse(uId),
      'cat_name': catName,
    }).then((value) {
    }).catchError((error) {
      print("Failed to add user: $error");
    });
  }

  //add unit
  Future<String> getMaxUnitIdIdPlusOne() async {
    int userId =
    (await _categoryCollection.orderBy('unit_id', descending: true).get())
        .docs
        .first
        .data()['unit_id'];
    return (userId + 1).toString();
  }

  Future addUnit(String unitName) async {
    String uId = await getMaxCatIdIdPlusOne();

    _unitCollection.doc(uId).set({
      'unit_id': int.parse(uId),
      'unit_name': unitName,
    }).then((value) {
    }).catchError((error) {
      print("Failed to add user: $error");
    });
  }




}

