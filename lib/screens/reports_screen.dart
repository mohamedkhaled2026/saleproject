import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';

class ReportScreen extends StatefulWidget {
  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {

  AudioCache _audioCache;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _audioCache = AudioCache(prefix: "sound/", fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 6,
          bottomOpacity: 3,
          toolbarHeight: 80,
          title: Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              'التقارير',
              style: kMainTitleTextStyle18.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          actions: [
            backButton(),
          ],
          leading: Container(),
          centerTitle: true,
          backgroundColor: Color(kPrimaryColor),
        ),
        body: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Color(kTextColor),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 100,
              ),
              Center(
                child: SvgPicture.asset(
                  'images/safe-box.svg',
                  height: MediaQuery.of(context).size.width * .6,
                  width: 150,
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Text('المبلغ الموجود بالخزنة : ', style: kMainTitleTextStyle28
                  .copyWith(
                color: Color(kLightGreenColor,),
                fontWeight: FontWeight.bold,),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    FontAwesomeIcons.moneyBillWave,
                    color: Color(kLightGreenColor),
                    size: 25,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Text('1000000' , style: kMainTitleTextStyle28
                      .copyWith(
                    fontSize: 48,
                    color: Color(kLightGreenColor,),
                    fontWeight: FontWeight.bold,
                  ),),


                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
