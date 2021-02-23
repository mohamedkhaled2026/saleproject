import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sale_pro_elcaptain/services/assistant_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_user_service.dart';
import 'package:sale_pro_elcaptain/ui/drawe/bezierContainer.dart';
import 'file:///C:/Users/Itachi/AndroidStudioProjects/sale_pro_elcaptain/lib/widgets/entry_field.dart';
import 'file:///C:/Users/Itachi/AndroidStudioProjects/sale_pro_elcaptain/lib/widgets/submit_button.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/logo.dart';
import 'package:sale_pro_elcaptain/widgets/title.dart' as t;
import 'home_screen.dart';



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  AudioCache _audioCache;
  FirestoreUserService _firebaseUserService = FirestoreUserService();
  TextEditingController userName;
  TextEditingController password;
  bool isProgress = false;
  AssistantService _assistantService = AssistantService();

  @override
  void initState() {
    _audioCache = AudioCache(prefix: "sound/", fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
    userName = TextEditingController();
    password = TextEditingController();
    setState(() {
      isProgress = true;
    });
    setState(() {
      isProgress = false;
    });
    super.initState();
  }



  validateFields() async {
    if(await AssistantService.checkInternet()) {
      if (userName.text
          .trim()
          .isEmpty) {
        _assistantService.showToast(
            context, 'ادخل اسم المستخدم', Colors.red, 16);
      } else {
        if (password.text
            .trim()
            .isEmpty) {
          _assistantService.showToast(
              context, 'ادخل كلمة المرور', Colors.red, 16);
        } else {
          setState(() {
            isProgress = true;
          });

          if (await _firebaseUserService.signIn(userName.text, password.text)) {
            if (await _firebaseUserService.isUserLocked(
                userName.text, password.text)) {
              _assistantService.showToast(
                  context, 'تم اغلاق حسابك برجاء مراجعة الادارة',
                  Color(kLightRedColor), 14);
            } else {
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context) {
                    return HomeScreen(0);
                  }));
            }
          } else {
            _assistantService.showToast(
                context, 'اسم المستخدم او كلمة المرور غير صحيحة', Colors.red,
                14);
          }
          setState(() {
            isProgress = false;
          });
        }
      }
    }else{
      _assistantService.showToast(
          context, 'لا يوجد اتصال بالانترنت', Colors.red,
          14);
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIOverlays([]);
    final height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: isProgress,
      child: Directionality(
          textDirection: TextDirection.rtl,
          child: Scaffold(
              body: Container(
                height: height,
                child: Stack(
                  children: <Widget>[
                    Positioned(
                        top: -height * .15,
                        right: -MediaQuery.of(context).size.width * .4,
                        child: BezierContainer()),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            SizedBox(height: height * .2),
                            Logo(),
                            t.Title(),
                            SizedBox(height: 40),
                            EntryField(title: "اسم المستخدم" ,isPassword: false ,controller: userName),
                            EntryField(title: "كلمة المرور",isPassword: true ,controller: password),
                            SizedBox(height: 20),
                            SubmitButton(title: 'تسجيل الدخول',onTap: () {
                              _audioCache.play('butttton.mp3');
                              validateFields();
                            }),
                          ],
                        ),
                      ),
                    ),
                    //Positioned(top: 40, left: 0, child: _backButton()),
                  ],
                ),
              ))),
    );
  }
}
