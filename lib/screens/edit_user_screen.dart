import 'dart:ui';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:sale_pro_elcaptain/services/firestore_user_service.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';
import 'package:sale_pro_elcaptain/widgets/entry_field.dart';
import 'package:sale_pro_elcaptain/widgets/logo.dart';
import 'package:sale_pro_elcaptain/widgets/submit_button.dart';
import 'package:sale_pro_elcaptain/widgets/title.dart' as t;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sale_pro_elcaptain/models/user.dart';
import 'package:sale_pro_elcaptain/screens/splash_screen.dart';
import 'package:sale_pro_elcaptain/screens/user_power_screen.dart';
import 'package:sale_pro_elcaptain/services/assistant_service.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/bezier_container.dart';

class EditUserScreen extends StatefulWidget {
  final User currentUser;
  final String ownerUser;
  final BuildContext settingContext;
  final BuildContext homeContext;

  const EditUserScreen(
      {Key key,
      this.currentUser,
      this.ownerUser,
      this.settingContext,
      this.homeContext})
      : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  AudioCache _audioCache;
  CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');
  FirestoreUserService _firebaseUserService = FirestoreUserService();
  var listen;
  bool isProgress = false;
  AssistantService _assistantService = AssistantService();
  SharedPreferences sharedPreference;
  int userId;
  String userName;
  String userOldPassword;
  String userPassword;
  String cUserPassword;
  String userType;
  TextEditingController _userNameController = new TextEditingController();
  TextEditingController _userOldPasswordController = new TextEditingController();
  TextEditingController _userPasswordController = new TextEditingController();
  TextEditingController _cUserPasswordController = new TextEditingController();

  validateFields() async {
    setState(() {
      isProgress = true;
    });
    userName = _userNameController.text.toString();
    userOldPassword = _userOldPasswordController.text.toString();
    userPassword = _userPasswordController.text.toString();
    cUserPassword = _cUserPasswordController.text.toString();
    bool isUserExist = true;
    if (isUserExist) {
      if (userName.trim().length < 3) {
        _assistantService.showToast(
            context, ' اسم المستحدم يجب ان يكون اكثر من حرفين', Colors.red,16);
      } else {
        if (userPassword.trim().length < 3) {
          _assistantService.showToast(
              context, 'كلمة المرور يجب ان تكون اكثر من حرفين', Colors.red,16);
        } else {
          if (userPassword.trim() != cUserPassword.trim()) {
            _assistantService.showToast(
                context, 'كلمة المرور غير متطابقة', Colors.red,16);
          } else {
            if (await _firebaseUserService
                .editUser(userId, userName,userOldPassword, userPassword, userType)) {
              _assistantService.showToast(
                  context, 'تمت التعديل بنجاح', Colors.green,16);
              _userOldPasswordController.text = '';
              _userPasswordController.text = '';
              _cUserPasswordController.text = '';
            } else {
              _assistantService.showToast(
                  context, 'كلمة المرور القديمة غير صحيحة', Colors.red,14);
            }
          }
        }
      }
    }
    setState(() {
      isProgress = false;
    });
  }

  Widget userPowerButton() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: GestureDetector(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => UserPowerScreen(widget.currentUser)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Color(kTextColor),
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20), topLeft: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Color(kPrimaryColor),
                spreadRadius: 2,
                blurRadius: 1,
                offset: Offset(0, 1), // changes position of shadow
              ),
            ],
          ),
          width: 140,
          height: 40,
          child: Row(
            children: [
              SizedBox(
                width: 5,
              ),
              Text(
                'صلاحيات المُستخدم',
                style:
                    kSubTitleTextStyle12.copyWith(color: Color(kPrimaryColor)),
              ),
              SizedBox(
                width: 5,
              ),
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                    color: Color(kPrimaryColor),
                    borderRadius: BorderRadius.circular(30)),
                child: Icon(
                  FontAwesomeIcons.userTie,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  initShared() async {
    sharedPreference = await SharedPreferences.getInstance();
  }

  listenToAnyPrivChange() async {
    int counter = 0;
    SharedPreferences _sharedPreferences =
        await SharedPreferences.getInstance();
    int userId = _sharedPreferences.getInt('user_id');
    listen = _userCollection
        .doc(userId.toString())
        .snapshots(includeMetadataChanges: false)
        .listen((doc) async {
      if (doc.exists) {
        counter++;
        if (counter > 1) {
          if (context != null) {
            SharedPreferences shared = await SharedPreferences.getInstance();
            shared.setInt('user_id', null);
            shared.setString('user_name', null);
            shared.setString('user_type', null);
            if(widget.settingContext != null){
              Navigator.pop(widget.settingContext);
            }
            Navigator.pop(widget.homeContext);
            Navigator.push(context,
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
    listenToAnyPrivChange();
    initShared();
    super.initState();
    _audioCache = AudioCache(
        prefix: "sound/",
        fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
    userId = widget.currentUser.userId;
    _userNameController.text = widget.currentUser.userName;
    userType = widget.currentUser.userType;
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
                  EntryField(title: "إسم المستخدم",isPassword: false,controller: _userNameController,enabled: false,),
                  EntryField(title: "كلمة المرور القديمة",isPassword: true,controller: _userOldPasswordController),
                  EntryField(title: "كلمة المرور الجديدة",isPassword: true,controller: _userPasswordController),
                  EntryField(title: "تأكيد كلمة المرور الجدبدة",isPassword: true,controller: _cUserPasswordController),
                  widget.currentUser.userType == 'admin' ||
                      (widget.currentUser.userType == 'user' &&
                          widget.ownerUser == 'user')
                      ? SizedBox():Directionality(
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
                  widget.currentUser.userType == 'admin' ||
                      (widget.currentUser.userType == 'user' &&
                          widget.ownerUser == 'user')
                      ? SizedBox():Container(
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          widget.currentUser.userType == 'admin' ||
                                  (widget.currentUser.userType == 'user' &&
                                      widget.ownerUser == 'user')
                              ? SizedBox()
                              : userPowerButton(),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      SubmitButton(title: 'تعديل',onTap: () async{
                        _audioCache.play('butttton.mp3');
                        validateFields();
                      },),
                      SizedBox(
                        height: 20,
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