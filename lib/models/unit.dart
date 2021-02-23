class Unit{
  int unitId;
  String unitName;
  bool isSelected = false;
  Unit({this.unitId,this.unitName});

  Map<String,dynamic> toJson(){
    return {
      'unit_id': this.unitId,
      'unit_name':this.unitName,
    };
  }

  factory Unit.fromJson(Map<String,dynamic> map){

    return Unit(
        unitId: map['unit_id'],
        unitName: map['unit_name']
    );
  }

}