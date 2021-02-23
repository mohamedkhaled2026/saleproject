class Suppliers{
  int supplierId;
  String supplierName;
  bool isSelected = false;
  Suppliers({this.supplierId,this.supplierName});

  Map<String,dynamic> toJson(){
    return {
      'supplier_id': this.supplierId,
      'supplier_name':this.supplierName,
    };
  }

  factory Suppliers.fromJson(Map<String,dynamic> map){

    return Suppliers(
        supplierId: map['supplier_id'],
        supplierName: map['supplier_name']
    );
  }

}