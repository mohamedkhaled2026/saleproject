import 'dart:ui';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sale_pro_elcaptain/services/assistant_service.dart';
import 'package:sale_pro_elcaptain/services/firestore_user_service.dart';
import 'package:sale_pro_elcaptain/ui/drawe/bezierContainer.dart';
import 'file:///C:/Users/Itachi/AndroidStudioProjects/sale_pro_elcaptain/lib/widgets/entry_field.dart';
import 'file:///C:/Users/Itachi/AndroidStudioProjects/sale_pro_elcaptain/lib/widgets/submit_button.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';
import 'package:sale_pro_elcaptain/widgets/logo.dart';
import 'package:sale_pro_elcaptain/widgets/title.dart' as t;


class SignUpPage extends StatefulWidget {
  SignUpPage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  AudioCache _audioCache;
  bool isProgress = false;
  AssistantService _assistantService = AssistantService();
  FirestoreUserService _firebaseUserService = FirestoreUserService();
  String userName;
  String userPassword;
  String cUserPassword;
  String userType = 'user';
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _userPasswordController = new TextEditingController();
  TextEditingController _cUserPasswordController = new TextEditingController();

  validateFields() async {
    setState(() {
      isProgress = true;
    });
    if(await AssistantService.checkInternet()) {
      userName = _userNameController.text.toString();
      userPassword = _userPasswordController.text.toString();
      cUserPassword = _cUserPasswordController.text.toString();

      if (await _firebaseUserService.checkUserExist(userName.trim())) {
        _assistantService.showToast(
            context, 'المستخدم موجود مسبقا', Colors.red, 16);
      } else {
        if (userName
            .trim()
            .length < 3) {
          _assistantService.showToast(
              context, ' اسم المستحدم يجب ان يكون اكثر من حرفين', Colors.red,
              14);
        } else {
          if (userPassword
              .trim()
              .length < 3) {
            _assistantService.showToast(
                context, 'كلمة المرور يجب ان تكون اكثر من حرفين', Colors.red,
                14);
          } else {
            if (userPassword.trim() != cUserPassword.trim()) {
              _assistantService.showToast(
                  context, 'كلمة المرور غير متطابقة', Colors.red, 14);
            } else {
              if (await _firebaseUserService.addUser(
                  userName, userPassword, userType)) {
                _assistantService.showToast(
                    context, 'تمت الاضافة بنجاح', Colors.green, 16);
                _userNameController.text = '';
                _userPasswordController.text = '';
                _cUserPasswordController.text = '';
              } else {
                _assistantService.showToast(
                    context, 'حدث خطاء حاول مرة اخرى', Colors.red, 14);
              }
            }
          }
        }
      }

    }else{
      _assistantService.showToast(
          context, 'لا يوجد اتصال بالانترنت', Colors.red,
          14);
    }
    setState(() {
      isProgress = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _audioCache = AudioCache(
        prefix: "sound/",
        fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
    userName = _userNameController.text.toString();
    userPassword = _userPasswordController.text.toString();
    cUserPassword = _cUserPasswordController.text.toString();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return ModalProgressHUD(
      inAsyncCall: isProgress,
      child: Scaffold(
        body: Container(
          height: height,
          child: Stack(
            children: <Widget>[
              Positioned(
                top: -MediaQuery.of(context).size.height * .15,
                right: -MediaQuery.of(context).size.width * .3,
                child: BezierContainer(),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(height: height * .2),
                    Logo(),
                    t.Title(),
                      SizedBox(
                        height: 50,
                      ),
                      EntryField(
                          title: "إسم المستخدم",
                          isPassword: false,
                          controller: _userNameController),
                      EntryField(
                          title: "كلمة المرور",
                          isPassword: true,
                          controller: _userPasswordController),
                      EntryField(
                          title: "تأكيد كلمة المرور",
                          isPassword: true,
                          controller: _cUserPasswordController),
                      Directionality(
                        textDirection: TextDirection.rtl,
                        child: Container(
                          margin: EdgeInsets.symmetric(vertical: 10),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                'نوع الحساب',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Color(kTextColor),
                                    fontFamily: 'Cairo'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        height: 50,
                        color: Colors.grey.withOpacity(.2),
                        child: DropdownSearch<String>(
                            mode: Mode.MENU,
                            showSelectedItem: true,
                            items: ["user", "admin"],
                            hint: "نوع الحساب",
                            onChanged: (val) {
                              userType = val;
                            },
                            selectedItem: "user"),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SubmitButton(
                          title: 'إنشاء حساب',
                          onTap: () {
                            _audioCache.play('butttton.mp3');
                            validateFields();
                          }),
                      SizedBox(
                        height: 10,
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(top: 40, left: 0, child: backButton()),
            ],
          ),
        ),
      ),
    );
  }
}
