import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sale_pro_elcaptain/models/store_item.dart';

class FirestoreItemService{
  final CollectionReference _storeCollection =
  FirebaseFirestore.instance.collection('store');
  
  Future<StoreItem> showProduct(String itemBarCode) async{
    print(itemBarCode);
    int lenght = (await _storeCollection.where('item_bar_code',isEqualTo: itemBarCode).get()).docs.length;
    if(lenght > 0) {
      return StoreItem.fromJson(
          (await _storeCollection.where('item_bar_code', isEqualTo: itemBarCode)
              .get()).docs.first.data());
    }else{
      print('no element');
    }
  }
}