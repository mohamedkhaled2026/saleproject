class Category{
  int catId;
  String catName;
  bool isSelected = false;
  Category({this.catId,this.catName});

  Map<String,dynamic> toJson(){
    return {
      'cat_id': this.catId,
      'cat_name':this.catName,
    };
  }

  factory Category.fromJson(Map<String,dynamic> map){

    return Category(
      catId: map['cat_id'],
      catName: map['cat_name']
    );
  }

}