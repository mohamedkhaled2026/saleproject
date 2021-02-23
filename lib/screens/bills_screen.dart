import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:sale_pro_elcaptain/ui/drawe/my_drawer.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
import 'package:sale_pro_elcaptain/widgets/back_button.dart';

class BillsScreen extends StatefulWidget {
  @override
  _BillsScreenState createState() => _BillsScreenState();
}

class _BillsScreenState extends State<BillsScreen> {

  DateTime startDate;
  DateTime endDate;
  Widget container;

  Widget _submitStartDataButton() {
    return InkWell(
      onTap: () {
        _audioCache.play('butttton.mp3');
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(2020, 1, 1),
            maxTime: DateTime.now(),
            theme: DatePickerTheme(
                headerColor: Color(kPrimaryColor),
                backgroundColor: Color(kTextColor),
                itemStyle: TextStyle(
                    color: Color(kPrimaryColor),
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                doneStyle: TextStyle(color: Color(kTextColor), fontSize: 16)),
            onChanged: (date) {
              print('change $date in time zone ' +
                  date.timeZoneOffset.inHours.toString());
            }, onConfirm: (date) {
              setState(() {
                startDate = DateTime(date.year, date.month, date.day);
              });
              print('confirm $startDate');
            }, currentTime: DateTime.now(), locale: LocaleType.ar);
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            color: Color(kPrimaryColor),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              startDate != null
                  ? ' البحث من تاريخ : ${startDate.day} / ${startDate.month} / ${startDate.year}'
                  : 'البحث من تاريخ   --- ',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(kTextColor),
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600),
            ),
          )),
    );
  }

  Widget _submitEndDataButton() {
    return InkWell(
      onTap: () {
        _audioCache.play('butttton.mp3');
        DatePicker.showDatePicker(context,
            showTitleActions: true,
            minTime: DateTime(2020, 1, 1),
            maxTime: DateTime.now(),
            theme: DatePickerTheme(
              headerColor: Color(kPrimaryColor),
              backgroundColor: Color(kTextColor),
              itemStyle: TextStyle(
                  color: Color(kPrimaryColor),
                  fontWeight: FontWeight.bold,
                  fontSize: 18),
              doneStyle: TextStyle(color: Color(kTextColor), fontSize: 16),
            ), onChanged: (date) {
              print('change $date in time zone ' +
                  date.timeZoneOffset.inHours.toString());
            }, onConfirm: (date) {
              setState(() {
                endDate = DateTime(date.year, date.month, date.day);
              });
              print('confirm $endDate');
            }, currentTime: DateTime.now(), locale: LocaleType.ar);
      },
      child: Container(
          margin: EdgeInsets.symmetric(horizontal: 10),
          width: MediaQuery.of(context).size.width,
          padding: EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: <BoxShadow>[
              BoxShadow(
                  color: Colors.grey.shade200,
                  offset: Offset(2, 4),
                  blurRadius: 5,
                  spreadRadius: 2)
            ],
            color: Color(kPrimaryColor),
          ),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
              endDate != null
                  ? '  إلى تاريخ :${endDate.day} / ${endDate.month} / ${endDate.year}'
                  : 'إلى تاريخ   --- ',
              style: TextStyle(
                  fontSize: 14,
                  color: Color(kTextColor),
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w600),
            ),
          )),
    );
  }

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
              'الخزنة ورأس المال',
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
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(top: 40),
            child: Column(
              children: [
                _submitStartDataButton(),
                SizedBox(
                  height: 20,
                ),
                _submitEndDataButton(),
                SizedBox(
                  height: 40,
                ),
                container,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
