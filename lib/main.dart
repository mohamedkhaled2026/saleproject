import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:sale_pro_elcaptain/screens/splash_screen.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home:SplashScreen(),
      debugShowCheckedModeBanner: false,
    ),
  );
}


