import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_pro_elcaptain/models/store_item.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/screens/splash_screen.dart';
import 'package:sale_pro_elcaptain/services/firestore_bill_service.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';
class ShortcomingsScreen extends StatefulWidget {
  BuildContext homeContext;
  ShortcomingsScreen(this.homeContext);
  @override
  _ShortcomingsScreenState createState() => _ShortcomingsScreenState();
}

class _ShortcomingsScreenState extends State<ShortcomingsScreen> {
  FirestoreBillService _firestoreBillService = FirestoreBillService();
  int minAmount = 3;

  CollectionReference _userCollection =
  FirebaseFirestore.instance.collection('users');
  var listen;

  listenToAnyPrivChange() async {
    int counter = 0;
    SharedPreferences _sharedPreferences =
    await SharedPreferences.getInstance();
    int userId = _sharedPreferences.getInt('user_id');
    listen = _userCollection
        .doc(userId.toString())
        .snapshots(includeMetadataChanges: false)
        .listen((doc) async{
      if (doc.exists) {
        User user = User.fromJson(doc.data());
        counter++;
        if (counter > 1) {
          if(context != null) {
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

  @override
  void initState() {
    // TODO: implement initState
    listenToAnyPrivChange();
    super.initState();
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
            title: Container(
              margin: EdgeInsets.only(top: 10),
              child: Text(
                'النواقص',
                style: kMainTitleTextStyle18,
                textAlign: TextAlign.center,
              ),
            ),
            centerTitle: true,
            actions: [
              backButton(),
            ],
            leading: Container(),
            shadowColor: Color(kTextColor),
          ),
          body: Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.only(top: 8),
            height: (MediaQuery
                .of(context)
                .size
                .height ),
            child: FutureBuilder<List<StoreItem>>(
              future: _firestoreBillService.getLackItems(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    scrollDirection: Axis.vertical,
                    itemCount: snapshot.data.length,
                    itemBuilder: (context, index) {
                      return Directionality(
                        textDirection: TextDirection.rtl,
                        child: Container(
                          height: 60,
                          padding: EdgeInsets.only(right: 10, left: 10),
                          margin: EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Color(kTextColor),
                          ),
                          child: ListTile(
                            title: Text(
                              snapshot.data[index].storeItemName ,
                              style: kMainTitleTextStyle16.copyWith(color: Color(kPrimaryColor)),
                            ),
                            subtitle: Text(
                              'الكمية الموجودة : ${snapshot.data[index].storeItemAmount.toString()}' ,
                              style: kSubTitleTextStyle12.copyWith(color: Colors.white),
                            ),
                          )


                        ),);
                    },
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ),
    );
  }
}
