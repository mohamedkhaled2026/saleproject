class PettyCash{
  int pettyCashId;
  String pettyCashName;
  String pettyCashPrice;
  bool isSelected = false;
  PettyCash({this.pettyCashId,this.pettyCashName , this.pettyCashPrice});

  Map<String,dynamic> toJson(){
    return {
      'petty_cash_id': this.pettyCashId,
      'petty_cash_name':this.pettyCashName,
      'petty_cash_price':this.pettyCashPrice,
    };
  }

  factory PettyCash.fromJson(Map<String,dynamic> map){

    return PettyCash(
        pettyCashId:  map['petty_cash_id'],
        pettyCashName: map['petty_cash_name'],
        pettyCashPrice: map['petty_cash_price'],
    );
  }

}