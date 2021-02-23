import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sale_pro_elcaptain/models/category.dart';
import 'package:sale_pro_elcaptain/models/unit.dart';


class FireStoreCategoriesService {
  final CollectionReference _catItemCollection = FirebaseFirestore.instance.collection('category');
  final CollectionReference _unitItemCollection = FirebaseFirestore.instance.collection('units');

  Future<Category> getCatDataById(int itemId) async{
    return Category.fromJson((await _catItemCollection.doc(itemId.toString()).get()).data());
  }


  Future<List<Category>> getAllCat() async{
    List<Category> catList = List<Category>();
    List<DocumentSnapshot> docs = (await _catItemCollection.get()).docs;
    for(DocumentSnapshot doc in docs){
      Category cat = Category.fromJson(doc.data());
      catList.add(cat);
    }
    return catList;
  }

  //get All Unit
  Future<List<Unit>> getAllCatUnit() async{
    List<Unit> unitList = List<Unit>();
    List<DocumentSnapshot> docs = (await _unitItemCollection.get()).docs;
    for(DocumentSnapshot doc in docs){
      Unit unit = Unit.fromJson(doc.data());
      unitList.add(unit);
    }
    return unitList;
  }

  Future<List<Category>> getCategories() async{
    List<Category> catList = List<Category>();
    List<DocumentSnapshot> docs = (await _catItemCollection.get()).docs;
    for(DocumentSnapshot doc in docs){
      Category cat = Category.fromJson(doc.data());
      catList.add(cat);
    }
    return catList;
  }

  Future<List<String>> getCategoriesName() async{
    List<String> catNameList = List<String>();
    List<DocumentSnapshot> docs = (await _catItemCollection.get()).docs;
    for(DocumentSnapshot doc in docs){
      String catName = Category.fromJson(doc.data()).toString();
      catNameList.add(catName);
    }
    return catNameList;
  }
}


