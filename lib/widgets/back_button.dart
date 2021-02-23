import 'package:flutter/material.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:sale_pro_elcaptain/utilities/constants.dart';
class backButton extends StatefulWidget {
  @override
  _backButtonState createState() => _backButtonState();
}

class _backButtonState extends State<backButton> {
  AudioCache _audioCache;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _audioCache = AudioCache(prefix: "sound/", fixedPlayer: AudioPlayer()..setReleaseMode(ReleaseMode.STOP));

  }
  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context){
        return InkWell(
          onTap: () {
            _audioCache.play('butttton.mp3');
            Navigator.pop(context);
          },
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: <Widget>[
                Text('Back',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color: Color(kTextColor))),
                Container(
                  padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
                  child: Icon(Icons.keyboard_arrow_left, color: Color(kTextColor)),
                ),

              ],
            ),
          ),
        );
      },
    );
  }
}


// import 'package:sale_pro_elcaptain/utilities/constants.dart';
//
// Widget backButton() {
//   return Builder(
//     builder: (BuildContext context){
//       return InkWell(
//         onTap: () {
//           AudixoCache _audioCache;
//           _audioCache.play('butttton.mp3');
//           Navigator.pop(context);
//         },
//         child: Container(
//           padding: EdgeInsets.symmetric(horizontal: 10),
//           child: Row(
//             children: <Widget>[
//               Text('Back',
//                   style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500,color: Color(kTextColor))),
//               Container(
//                 padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
//                 child: Icon(Icons.keyboard_arrow_left, color: Color(kTextColor)),
//               ),
//
//             ],
//           ),
//         ),
//       );
//     },
//   );
// }
