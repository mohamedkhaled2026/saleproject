import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sale_pro_elcaptain/models/suppliers.dart';
import 'package:sale_pro_elcaptain/models/category.dart';
import 'package:sale_pro_elcaptain/models/unit.dart';


class FireStoreSuppliersService {
  final CollectionReference _suppItemCollection = FirebaseFirestore.instance.collection('suppliers');
  final CollectionReference _unitItemCollection = FirebaseFirestore.instance.collection('units');

  Future<Suppliers> getSupDataById(int itemId) async{
    return Suppliers.fromJson((await _suppItemCollection.doc(itemId.toString()).get()).data());
  }


  Future<List<Suppliers>> getAllSuppliers() async{
    List<Suppliers> supList = List<Suppliers>();
    List<DocumentSnapshot> docs = (await _suppItemCollection.get()).docs;
    for(DocumentSnapshot doc in docs){
      Suppliers sup = Suppliers.fromJson(doc.data());
      supList.add(sup);
    }
    return supList;
  }

  //add supplier
  Future<String> getMaxCatIdIdPlusOne() async {
    int userId =
    (await _suppItemCollection.orderBy('supplier_id', descending: true).get())
        .docs
        .first
        .data()['supplier_id'];
    return (userId + 1).toString();
  }

  Future addSupplier(String catName) async {
    String uId = await getMaxCatIdIdPlusOne();

    _suppItemCollection.doc(uId).set({
      'supplier_id': int.parse(uId),
      'supplier_name': catName,
    }).then((value) {
    }).catchError((error) {
      print("Failed to add user: $error");
    });
  }

}


