import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/services/assistant_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_user_service.dart';
import 'package:sale_pro_elcaptain/ui/drawe/bezierContainer.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/logo.dart';
import 'package:sale_pro_elcaptain/widgets/title.dart' as t;
import 'package:shared_preferences/shared_preferences.dart';
import 'home_screen.dart';
import 'login_screen.dart';



class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
   SharedPreferences sharedPreferences;
   FirestoreUserService _firebaseUserService = FirestoreUserService();
   Widget progress = CircularProgressIndicator(
     valueColor: AlwaysStoppedAnimation<Color>(Color(kPrimaryColor)),
   );


  checkUserLogedIn() async {
    Timer(Duration(seconds: 3), ()async{
    if(await AssistantService.checkInternet()) {
      sharedPreferences = await SharedPreferences.getInstance();
      if (sharedPreferences.getInt('user_id') != null) {
        User currentUser = (await _firebaseUserService.getUserDataById(sharedPreferences.getInt('user_id').toString()));
        if(currentUser.locked == null?true:!currentUser.locked) {
          if (currentUser.lastUpdate.millisecondsSinceEpoch >
              (sharedPreferences.getInt('last_update') == null
                  ? 1
                  : sharedPreferences.getInt('last_update'))) {
            await _firebaseUserService.storeUserInfo(currentUser);
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) {
              return HomeScreen(0);
            }));
          } else {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) {
              return HomeScreen(0);
            }));
          }
        }else{
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) {
            return LoginScreen();
          }));
        }
      } else {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) {
          return LoginScreen();
        }));
      }
    }else{
      setState(() {
        progress = Column(
          children: [
            IconButton(
              onPressed: ()async{
                setState((){
                  progress = CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(kPrimaryColor)),
                  );
                });
                await checkUserLogedIn();

              },
              icon: Icon(Icons.refresh,size: 35,color: Color(kPrimaryColor),),),
            Text('لا يوجد اتصال بالانترنت',style: TextStyle(fontSize: 24,color: Color(kTextColor)),)
          ],
        );
      });

    }
    });
  }

  @override
  void initState() {
    checkUserLogedIn();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: <Widget>[
              Positioned(
                  top: -height * .15,
                  right: -MediaQuery.of(context).size.width * .4,
                  child: BezierContainer()),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Logo(),
                    t.Title(),
                    progress,
                  ],
                ),
              ),
              //Positioned(top: 40, left: 0, child: _backButton()),
            ],
          ),
        ));
  }
}
